//
//  ViewController.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/08.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

protocol ImageDicDelegate: AnyObject {
    func updateImageDictioinary(link: String, value: UIImage)
    func getImage(link:String) -> UIImage?
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var items: [Item] = []
    private let cellId = "cellId"
    private var paging = 1
    private var searchQuery = "트와이스"
    
    var imageDic: [String: UIImage] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        requestNaverImageResult(query: searchQuery, display: 10, start: paging, sort: "1", filter: "1")
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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? NaverImageTableViewCell else {
            return .init()
        }
        cell.imageDicDelegate = self
        cell.titleLabel.text = items[indexPath.row].title
        cell.imageURLString = items[indexPath.row].link
        cell.indexPathRow = indexPath.row
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        
        searchBar.backgroundColor = .lightGray
        searchBar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
         
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
            self.requestNaverImageResult(query: searchQuery, display: 10, start: paging, sort: "1", filter: "1")
        }
    }
}

extension ViewController: ImageDicDelegate {
    func updateImageDictioinary(link: String, value: UIImage) {
        imageDic.updateValue(value, forKey: link)
    }
    
    func getImage(link: String) -> UIImage? {
        return imageDic[link]
    }
    
}

