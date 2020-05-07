//
//  PhotoViewerLayout.swift
//  TableViewPractice
//
//  Created by 조중현 on 2019/12/17.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

// UICollectionViewLayout은 collectionView를 참조하고있다.
// collectionView.collectionLayout이 collectionViewLayout을 참조하고, collectionViewLayout은 collecionView를 참조하고 있다.
class PhotoViewerLayout: UICollectionViewLayout {

    var contentBounds = CGRect.zero
    var cachedAttryibutes = [UICollectionViewLayoutAttributes]()
    var attribute: UICollectionViewLayoutAttributes?
    
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
        
        attribute =  UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "forSupplementaryViewOfKind", with: IndexPath(item: 0, section: 0))
        attribute?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    }
    
    // 혹시 collectionViewContentSize를 재정의 하지 않아서 기본값으로 나타내주기 때문에?
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }
        
        if collectionView.traitCollection.verticalSizeClass == .regular {
            return CGSize(width: collectionView.bounds.width * CGFloat(collectionView.numberOfItems(inSection: 0)),
            height: collectionView.bounds.height)
        } else {
            return CGSize(width: 50, height: 110)
        }
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
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attribute
    }
}
