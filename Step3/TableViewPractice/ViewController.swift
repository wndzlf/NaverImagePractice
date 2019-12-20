//
//  ViewController.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/08.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit
import MobileCoreServices

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
    
    mutating func deleteItem(at indexPath: IndexPath) {
        items.remove(at: indexPath.row)
    }
    
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        guard let item = items[safeIndex: indexPath.item] else {
            return []
        }
        
        let data = archive(w: item)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTagClassMIMEType as String, visibility: .all) { completion in
            completion(data,nil)
            return nil
        }
        
        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }
    
    func archive<T>(w: T) -> Data {
        var fw = w
        print("arcive \(MemoryLayout<T>.stride)")
        return Data(bytes: &fw, count: MemoryLayout<T>.stride)
    }
    
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    mutating func moveItem(at sourceIndexPathRow: Int, to destinationIndexPathRow: Int) {
        guard sourceIndexPathRow != destinationIndexPathRow else { return }
        
        if let item = items[safeIndex: sourceIndexPathRow] {
            items.remove(at: sourceIndexPathRow)
            items.insert(item, at: destinationIndexPathRow)
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var prefetchElement = PrefetchElemet()
    var currentIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    private var isRequest = false
    
    private var naverImageCache = NSCache<NSString, UIImage>()
    
    private let cellId = "cellId"
    private var cellHeight: NSMutableDictionary = [:]

    private let footerHeight: CGFloat = 70
    private let footerHeightWhenDataFinished: CGFloat = 0
    
    private lazy var searchBar: UISearchBar = { () -> UISearchBar in
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
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        tableView.dragInteractionEnabled = true
        
        tableView.separatorColor = .blue
        //tableView.isEditing = true
        tableView.isMultipleTouchEnabled = false
        
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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableViewDelegate, TableViewDataSource
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            prefetchElement.deleteItem(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        prefetchElement.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    // MARK: - TableViewDataSourcePrefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let row = indexPaths.last?.row, row >= prefetchElement.items.count - 4 {
            prefetchElement.updatePaging()
            
            tableView.tableFooterView = footerActivityIndicator
            tableView.sectionFooterHeight = footerHeight
            
            isRequest = true
            self.requestNaverImageResult(query: prefetchElement.searchQuery, display: prefetchElement.numberOfImageDisplay, start: prefetchElement.paging, sort: "1", filter: "1") { [weak self] items in
                
                print("prefetching Paing \(self?.prefetchElement.paging)")
                self?.prefetchElement.updateItems(with: items)
                self?.tableView.reloadData()
                
                self?.tableView.tableFooterView = nil
                self?.tableView.sectionFooterHeight = 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // 여기서 특정 indexPath에 맞는 셀만
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

extension ViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        print("itemProvider 진입")
        if let destinationIndexPath = coordinator.destinationIndexPath {
            
            coordinator.session.loadObjects(ofClass: NSString.self) { itemProvider in
                guard let item = itemProvider as? [Item] else {
                    print("itemProvider 실패")
                    return
                }
                print("itemProvider 성공")
            }
        }
    }
    
    // MARK: - TableView DragDelegate
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print("itemProvider drag시작")
        tableView.allowsSelection = false
        return prefetchElement.dragItems(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidEnter session: UIDropSession) {
        print("dropSessionDidEnter")
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidExit session: UIDropSession) {
        print("dropSessionDidExit")
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidEnd session: UIDropSession) {
        tableView.allowsSelection = true
        print("dropSessionDidEnd")
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        
        
        if tableView.hasActiveDrag {
            print("dropsessiondidupdate")
            if session.items.count > 1 {
                print("dropsessiondidupdate cancel")
                return UITableViewDropProposal(operation: .cancel)
            } else {
                print("dropsessiondidupdate move")
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            print("dropsessiondidupdate copy")
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
}

