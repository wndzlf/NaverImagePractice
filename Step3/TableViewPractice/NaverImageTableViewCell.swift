//
//  NaverImageTableViewCell.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/10.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class NaverImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var naverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton?
    
    var httpTask: URLSessionDataTask?
    var httpDownloadTask: URLSessionDownloadTask?
    
    
    var indexPathRow: Int = 0 {
        didSet {
    
        }
    }
    weak var imageDicDelegate: imageCachingDelegate?
    
    var imageURLString: String? {
        didSet {
            guard let imageURLString = imageURLString else {
                return
            }
            guard let linkButton = linkButton else {
                return
            }
            linkButton.setTitle(imageURLString, for: .normal)
            if let naverImage = self.imageDicDelegate?.image(link: imageURLString) {
                self.naverImage.image = naverImage
                return
            }
            downloadImage(from: imageURLString) { [weak self] data, response, error in
                guard let self = self else {
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    self.naverImage.image = image
                    self.imageDicDelegate?.updateCache(link: imageURLString, value: image)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isEditing = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        naverImage.image = nil
        titleLabel.text = nil
    
        httpTask?.cancel()
        httpDownloadTask?.cancel { data in
            
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        httpTask = URLSession.shared.dataTask(with: url, completionHandler: completion)
        httpTask?.resume()
    }
    
    func downloadImage(from urlString: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> () ) {
        guard let url = URL(string: urlString) else {return}
        getData(from: url, completion: completionHandler)
    }
}
