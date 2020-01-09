//
//  ImageViewerCollectionViewCell.swift
//  TableViewPractice
//
//  Created by 조중현 on 2019/12/17.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class ImageViewerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var cellModel: NaverImageCellModel?
    var item: Item?
    
    func configure(_ imageCachingDelegate: imageCachingDelegate, _ item: Item?) {
        guard let item = item else {
            return
        }
        cellModel = NaverImageCellModel(item.link)
        cellModel?.imageDicDelegate = imageCachingDelegate
        
        cellModel?.downloadImage { [weak self] image in
            self?.imageView.image = image
        }
        if let height = item.estimatedHeight {
            guard height <= self.frame.height * 0.8 else {
                self.heightConstraint.constant = self.frame.height * 0.8
                return
            }
            self.heightConstraint.constant = height
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        cellModel?.prepareForReuse()
    }
}
