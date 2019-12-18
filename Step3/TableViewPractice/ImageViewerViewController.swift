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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = PhotoViewerLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .black
        collectionView.allowsSelection = true
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
        presenting.prefetchElement = prefetechElement
        presenting.tableView.reloadData()
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
        if let item = prefetechElement.items[safeIndex: indexPath.item] {
            cell.item = item
        }
        cell.imageDicDelegate = self
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
            
        }
    }

}
