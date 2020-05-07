//
//  ImageViewerViewController.swift
//  TableViewPractice
//
//  Created by 조중현 on 2019/12/17.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class ImageViewerViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var prefetechElement = PrefetchElemet()
    var naverImageCache = NSCache<NSString, UIImage>()
    var indexPath: IndexPath?
    var isUserScrollNow: Bool = false
    var httpTask: URLSessionTask?
    
    private var currentIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: "forSupplementaryViewOfKind", withReuseIdentifier: "withReuseIdentifier")
        collectionView.collectionViewLayout = PhotoViewerLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .black
        
        collectionView.allowsSelection = true
        collectionView.pinchGestureRecognizer?.addTarget(self, action: #selector(handlePinch))
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            //self.collectionView.reloadData()
//            
//            //invalidateLayout이 dataSource 함수나 delegate 함수를 호출하지는 않는다.
//            //그러면 언제 invalideLayout으로 crash가 나는가?
//            //
//            self.collectionView.collectionViewLayout.invalidateLayout()
//        }
    }
    
    @objc private func handlePinch() {
        print("handlePinch")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let indexPath = indexPath, isUserScrollNow == false {
            collectionView.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let presenting = self.presentingViewController as? ViewController else {
            return
        }
        
        presenting.currentIndexPath = currentIndexPath
        presenting.prefetchElement = prefetechElement
        presenting.tableView.reloadData()
        presenting.tableView.scrollToRow(at: IndexPath(row: currentIndexPath.item, section: 0), at: .middle, animated: false)
    }
    
    private func requestNaverImageResult(query: String, display: Int, start: Int, sort: String, filter: String, completion: @escaping ([Item]) -> Void) {
        NaverImageAPI.request(query: query, display: display, start: start, sort: sort, filter: filter) { result in
            switch result {
            case .success(let naverImageResult):
                completion(naverImageResult.items)
            case .failure(.JsonParksingError):
                print("JsonParsingError in CollectionViewController")
                break
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        //collectionView.reloadData()
        // invalildateLayout() 함수가 dataSource 함수를 호출한다. 모든 데이터가 제대로 들어가있지 않는 상황이라면 crash 발생여지가 있다.
        //collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension ImageViewerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return prefetechElement.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewerCollectionViewCell", for: indexPath) as? ImageViewerCollectionViewCell else {
            return .init()
        }
        
        var item: Item?
        if let prefetchItem = prefetechElement.items[safeIndex: indexPath.item] {
            item = prefetchItem
            //cell.item = item
        }
        
        cell.configure(self, item)
        return cell
    }

}

extension ImageViewerViewController: imageCachingDelegate {
   func updateCache(link: String, value: UIImage) {
        naverImageCache.setObject(value, forKey: link as NSString)
    }
    
    func image(link: String) -> UIImage? {
        return naverImageCache.object(forKey: link as NSString)
    }
}

extension ImageViewerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isUserScrollNow = true
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isUserScrollNow = false
    }
}

extension ImageViewerViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let last = indexPaths.last?.last else {
            return
        }
        
        if prefetechElement.items.count - 1 == last {
            prefetechElement.updatePaging()
            requestNaverImageResult(query: prefetechElement.searchQuery, display: prefetechElement.numberOfImageDisplay, start: prefetechElement.paging, sort: "1", filter: "1") { [weak self] items in
                guard let self = self else {
                    return
                }
                self.prefetechElement.updateItems(with: items)
                self.collectionView.reloadData()
            }
        }
    }
    
}
