//
//  NaverImageTableViewCell.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/10.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

protocol NaverImageDownloadable: class {
    var urlString: String { get }
    var httpTask: URLSessionDataTask? { set get }
    func downloadImage(completionHandler: @escaping (Data?, URLResponse?, Error?) -> ())
}

extension NaverImageDownloadable {
    func downloadImage(completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: urlString) else {return}
        
        httpTask = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        httpTask?.resume()
    }
}

class NaverImageCellModel: NaverImageDownloadable {
    var httpTask: URLSessionDataTask?
    var urlString: String
    weak var imageDicDelegate: imageCachingDelegate?
    
    init(_ urlString: String) {
        self.urlString = urlString
    }
    
    func downloadImage(completionHandler: @escaping (UIImage) -> ()) {
        if let naverImage = self.imageDicDelegate?.image(link: urlString) {
            completionHandler(naverImage)
            return
        }
        downloadImage() { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            self.imageDicDelegate?.updateCache(link: self.urlString, value: image)
            DispatchQueue.main.async {
                completionHandler(image)
            }
        }
    }
    
    func prepareForReuse() {
        httpTask?.cancel()
    }
}

class NaverImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var naverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton?
    
    var indexPathRow: Int = 0 {
        didSet {
    
        }
    }
    
    var cellModel: NaverImageCellModel?
    
    var imageURLString: String? {
        didSet {
            guard let imageURLString = imageURLString, let linkButton = linkButton else {
                return
            }
            linkButton.setTitle(imageURLString, for: .normal)
            
            cellModel = NaverImageCellModel(imageURLString)
            cellModel?.downloadImage() { [weak self] image in
                self?.naverImage.image = image
            }
        }
    }
    
    private func configure() {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isEditing = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellModel?.prepareForReuse()
        naverImage.image = nil
        titleLabel.text = nil
    }
}
