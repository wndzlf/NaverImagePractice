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
    
    var item: Item? {
        didSet {
            guard let link = item?.link else {
                return
            }
            if let cachedImage = imageDicDelegate?.image(link: link) {
                imageView.image = cachedImage
            } else {
                downloadImage(url: link) { [weak self] image in
                    self?.imageView.image = image
                    self?.imageDicDelegate?.updateCache(link: link , value: image)
                }
            }
            if let height = item?.estimatedHeight {
                heightConstraint.constant = height
            }
        }
    }
    weak var imageDicDelegate: imageCachingDelegate?
    private var httpTask: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        httpTask?.cancel()
    }
    
    private func downloadImage(url: String, completionHandler: @escaping (UIImage) -> Void) {
        guard let url = URL(string: url) else {
            return
        }
        httpTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                 completionHandler(image)
            }
        }
        httpTask?.resume()
    }
}
