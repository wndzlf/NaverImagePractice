//
//  ViewController.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/08.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var items: [Item] = []
    private let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        requestNaverImageResult(query: "사람", display: 0, start: 0, sort: "1", filter: "1")
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let naverImageTableViewCellNIB = UINib(nibName: "NaverImageTableViewCell", bundle: nil)
        tableView.register(naverImageTableViewCellNIB, forCellReuseIdentifier: cellId)
        tableView.isEditing = false
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func requestNaverImageResult(query: String, display: Int, start: Int, sort: String, filter: String) {
        NaverImageAPI.request(query: query, display: display, start: start, sort: sort, filter: filter) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let naverImageResult):
                self.items = naverImageResult.items
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? NaverImageTableViewCell else {
            return .init()
        }
        cell.titleLabel.text = items[indexPath.row].title
        cell.imageURLString = items[indexPath.row].link
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}

