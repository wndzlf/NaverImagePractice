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

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var items: [Item] = []
    private let cellId = "cellId"
    private var paging = 1
    private var searchQuery = ""
    private var storeBeforSearchText = ""
    private let numberOfImageDisplay = 10
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        searchBar.backgroundColor = .lightGray
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        return searchBar
    }()
    
    var imageDic: [String: UIImage] = [:]
    private var naverImageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naverImageCache.countLimit = 5 
        setupTableView()
        requestNaverImageResult(query: searchQuery, display: numberOfImageDisplay, start: paging, sort: "1", filter: "1")
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
    
        tableView.allowsSelection = false
        
        let naverImageTableViewCellNIB = UINib(nibName: "NaverImageTableViewCell", bundle: nil)
        tableView.register(naverImageTableViewCellNIB, forCellReuseIdentifier: cellId)
        tableView.isEditing = false
        
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc private func handleRefreshControl() {
        items.removeAll()
        if let searchBarText = searchBar.text {
            paging = 1
            requestNaverImageResult(query: searchBarText, display: numberOfImageDisplay, start: paging, sort: "1", filter: "2")
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func requestNaverImageResult(query: String, display: Int, start: Int, sort: String, filter: String) {
        NaverImageAPI.request(query: query, display: display, start: start, sort: sort, filter: filter) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let naverImageResult):
                self.items.append(contentsOf: naverImageResult.items)
                self.tableView.reloadData()
            case .failure(.JsonParksingError):
                break
            }
        }
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("didEndEditing")
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, searchQuery != searchText {
            items.removeAll()
            searchQuery = searchText
            requestNaverImageResult(query: searchText, display: numberOfImageDisplay, start: paging, sort: "1", filter: "2")
        }
        searchBar.resignFirstResponder()
        print("searchBarSearchButtonClicked")
    }
    

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? NaverImageTableViewCell else {
            return .init()
        }
        cell.imageDicDelegate = self
        guard let titleLabel = items[safeIndex: indexPath.row]?.title , let imageURLString = items[safeIndex: indexPath.row]?.link else {
            return .init()
        }
        cell.titleLabel.text = titleLabel
        cell.imageURLString = imageURLString
        cell.indexPathRow = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.count == 1, let row = indexPaths.last?.row, row >= items.count - 5 {
            paging += 1
            self.requestNaverImageResult(query: searchQuery, display: numberOfImageDisplay, start: paging, sort: "1", filter: "1")
        }
    }
}

extension ViewController: imageCachingDelegate {
    func updateCache(link: String, value: UIImage) {
        naverImageCache.setObject(value, forKey: link as NSString)
    }
    
    func image(link: String) -> UIImage? {
        return naverImageCache.object(forKey: link as NSString)
    }
    
}
