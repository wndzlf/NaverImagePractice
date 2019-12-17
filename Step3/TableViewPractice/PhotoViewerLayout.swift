//
//  PhotoViewerLayout.swift
//  TableViewPractice
//
//  Created by 조중현 on 2019/12/17.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class PhotoViewerLayout: UICollectionViewLayout {

    var contentBounds = CGRect.zero
    var cachedAttryibutes = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else {
            return
        }
        
        cachedAttryibutes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        
        let count = collectionView.numberOfItems(inSection: 0)
        var currentIndex = 0

        var currentX: CGFloat = 0
        
        while currentIndex < count {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentIndex, section: 0))
            attributes.frame = CGRect(x: currentX, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
            
            cachedAttryibutes.append(attributes)
            currentIndex += 1
            currentX = collectionView.frame.width * CGFloat(currentIndex)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }
        return CGSize(width: collectionView.bounds.width * CGFloat(collectionView.numberOfItems(inSection: 0)),
                      height: collectionView.bounds.height)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return newBounds.size.equalTo(collectionView.bounds.size) == false
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttryibutes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttryibutes
    }
}
