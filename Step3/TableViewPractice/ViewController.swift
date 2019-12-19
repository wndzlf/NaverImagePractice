//
//  ViewController.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/08.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

protocol imageCachingDelegate: AnyObject {
    func updateCache(link: String, value: UIImage)
    func image(link: String) -> UIImage?
}

// CollectionView Dismiss시 동기화
struct PrefetchElemet {
    private(set) var paging: Int = 1
    private(set) var items: [Item] = []
    private(set) var searchQuery: String = ""
    private(set) var numberOfImageDisplay: Int = 10
    
    mutating func updatePaging(){
        guard paging <= 98 else { return }
        paging += 1
    }
    
    mutating func updateSearchText(with newValue: String) {
        searchQuery = newValue
    }
    
    mutating func updateItems(with newItems: [Item]) {
        items.appendWithoutDuplicate(array: newItems)
    }
    
    mutating func updateItemsEstimatedValue(_ indexPath: IndexPath, estimated: CGFloat) {
        if indexPath.row < items.count {
            items[indexPath.row].estimatedHeight = estimated
        }
    }
    
    mutating func removeAllItems() {
        items.removeAll()
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var prefetchElement = PrefetchElemet()
    
    private let cellId = "cellId"
    private var cellHeight: NSMutableDictionary = [:]
    
    private var isRequest = false
    
    private var naverImageCache = NSCache<NSString, UIImage>()
    
    var currentIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        return searchBar
    }()
    
    private lazy var noDataLabel: UILabel = {
        let noDataLabel = UILabel()
        noDataLabel.text = "데이터가 없습니다."
        noDataLabel.textAlignment = .center
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        return noDataLabel
    }()
    
    private let footerHeight: CGFloat = 70
    private let footerHeightWhenDataFinished: CGFloat = 0
    
    private lazy var footerActivityIndicator: UIActivityIndicatorView = {
        let acitivityView = UIActivityIndicatorView(style: .medium)
        acitivityView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: footerHeight)
        acitivityView.startAnimating()
        return acitivityView
    }()
    
    private lazy var tableActivityIndicatorView: UIActivityIndicatorView = {
        let acitivityView = UIActivityIndicatorView(style: .medium)
        acitivityView.translatesAutoresizingMaskIntoConstraints = false
        acitivityView.hidesWhenStopped = true
        acitivityView.backgroundColor = .lightGray
        acitivityView.alpha = 0.6
        return acitivityView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naverImageCache.delegate = self
        
        setupTableView()
        setupTableViewActivitiyView()
        
//        requestNaverImageResult(query: prefetchElement.searchQuery, display: prefetchElement.numberOfImageDisplay, start: prefetchElement.paging, sort: "1", filter: "1") { [weak self] items in
//            
//            self?.prefetchElement.updateItems(with: items)
//            self?.tableView.reloadData()
//        }
    }
    
    private func setupTableViewActivitiyView() {
        tableView.addSubview(tableActivityIndicatorView)
        
        tableActivityIndicatorView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        tableActivityIndicatorView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableActivityIndicatorView.heightAnchor.constraint(equalTo: tableView.heightAnchor).isActive = true
        tableActivityIndicatorView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        
        let naverImageTableViewCellNIB = UINib(nibName: "NaverImageTableViewCell", bundle: nil)
        tableView.register(naverImageTableViewCellNIB, forCellReuseIdentifier: cellId)
        tableView.isEditing = false
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc private func handleRefreshControl() {
        prefetchElement.removeAllItems()
        if let searchBarText = searchBar.text {
            prefetchElement.updatePaging()
            defer {
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
            requestNaverImageResult(query: searchBarText, display: prefetchElement.numberOfImageDisplay, start: prefetchElement.paging, sort: "1", filter: "2") { [weak self] items in
                
                self?.prefetchElement.updateSearchText(with: searchBarText)
                self?.prefetchElement.updateItems(with: items)
                self?.tableView.reloadData()
            }
        }
    }
    
    private func requestNaverImageResult(query: String, display: Int, start: Int, sort: String, filter: String, completion: @escaping ([Item]) -> Void) {
        NaverImageAPI.request(query: query, display: display, start: start, sort: sort, filter: filter) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let naverImageResult):
                completion(naverImageResult.items)
            case .failure(.JsonParksingError):
                DispatchQueue.main.async {
                    self.tableView.tableFooterView = nil
                    self.tableView.sectionFooterHeight = 0
                }
                break
            }
        }
    }
    
}

// MARK: - UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - SearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, prefetchElement.searchQuery != searchText {
            prefetchElement.removeAllItems()
            prefetchElement.updateSearchText(with: searchText)
            
            self.tableActivityIndicatorView.startAnimating()
            requestNaverImageResult(query: searchText, display: prefetchElement.numberOfImageDisplay, start: prefetchElement.paging, sort: "1", filter: "2") { [weak self] items in
                
                self?.prefetchElement.updateItems(with: items)
                self?.handleNoData(itemsCount: items.count)
                self?.tableActivityIndicatorView.stopAnimating()
                self?.tableView.reloadData()
            }
        }
        naverImageCache.removeAllObjects()
        searchBar.resignFirstResponder()
    }
    
    private func handleNoData(itemsCount: Int) {
        guard itemsCount == 0 else {
            noDataLabel.removeFromSuperview()
            return
        }
        
        tableView.addSubview(noDataLabel)
        noDataLabel.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
        noDataLabel.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
        noDataLabel.widthAnchor.constraint(equalTo: self.tableView.widthAnchor).isActive = true
        noDataLabel.heightAnchor.constraint(equalTo: self.tableView.heightAnchor).isActive = true
    }
}

// MARK: - TableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prefetchElement.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? NaverImageTableViewCell else {
            return .init()
        }
        guard let titleLabel = prefetchElement.items[safeIndex: indexPath.row]?.title, let imageURLString = prefetchElement.items[safeIndex: indexPath.row]?.link else {
            return .init()
        }
        
        cell.imageDicDelegate = self
        cell.titleLabel.text = titleLabel
        cell.imageURLString = imageURLString
        cell.indexPathRow = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ratio = self.ratio(with: indexPath.row)
        
        let currentWidth = self.tableView.frame.width - 8
        let resultHeight = currentWidth * ratio
        
        return resultHeight + 34
    }
    
    private func ratio(with indexPathRow: Int) -> CGFloat {
        guard let width = prefetchElement.items[safeIndex: indexPathRow]?.sizewidth, let height = prefetchElement.items[safeIndex: indexPathRow]?.sizeheight else {
            return 0
        }
        
        var ratio: Float = 0
        if let imageWidth = Float(width) , let imageHeight = Float(height) {
            ratio = imageHeight / imageWidth
        }
        return CGFloat(ratio)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        prefetchElement.updateItemsEstimatedValue(indexPath, estimated: cell.frame.size.height)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < prefetchElement.items.count else {
            return UITableView.automaticDimension
        }
        if let height = prefetchElement.items[indexPath.row].estimatedHeight {
            return height
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ImageViewer", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(identifier: "ImageViewerViewController") as? ImageViewerViewController else {
            return
        }
        //viewController.items = prefetchElement.items
        viewController.prefetechElement = prefetchElement
        viewController.naverImageCache = naverImageCache
        viewController.indexPath = indexPath
        //viewController.modalPresentationStyle = .fullScreen
        
        self.present(viewController, animated: true, completion: nil)
    }

}

// MARK: - TableViewDataSourcePrefetching
extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let row = indexPaths.last?.row, row >= prefetchElement.items.count - 4 {
            prefetchElement.updatePaging()
            
            tableView.tableFooterView = footerActivityIndicator
            tableView.sectionFooterHeight = footerHeight
            
            isRequest = true
            self.requestNaverImageResult(query: prefetchElement.searchQuery, display: prefetchElement.numberOfImageDisplay, start: prefetchElement.paging, sort: "1", filter: "1") { [weak self] items in
                
                self?.prefetchElement.updateItems(with: items)
                self?.tableView.reloadData()
                
                self?.tableView.tableFooterView = nil
                self?.tableView.sectionFooterHeight = 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? NaverImageTableViewCell else {
            return
        }
        //cell.httpTask?.cancel()
    }
}

// MARK: - ImageCaching
extension ViewController: imageCachingDelegate {
    func updateCache(link: String, value: UIImage) {
        naverImageCache.setObject(value, forKey: link as NSString)
    }
    
    func image(link: String) -> UIImage? {
        return naverImageCache.object(forKey: link as NSString)
    }
}

extension ViewController: NSCacheDelegate {
    private func cache(_ cache: NSCache<NSString, UIImage>, willEvictObject obj: Any) {
        
    }
}


