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
    
    var items: [Item] = []
    var naverImageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = PhotoViewerLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
    }
}

extension ImageViewerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewerCollectionViewCell", for: indexPath) as? ImageViewerCollectionViewCell else {
            return .init()
        }
        
        if let cahcedImage = naverImageCache.object(forKey: items[indexPath.item].link as NSString) {
            cell.imageView.image = cahcedImage
        }
        if let height = items[indexPath.item].estimatedHeight {
            cell.heightConstraint.constant = height
        }
        
        return cell
    }
    
}

//extension ImageViewerViewController: UICollectionViewDataSourcePrefetching {
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        <#code#>
//    }
//
//}
