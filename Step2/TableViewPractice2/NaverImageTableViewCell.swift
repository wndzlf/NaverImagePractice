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
    @IBOutlet weak var naverImageHeightConstraint: NSLayoutConstraint!
    
    var httpTask: URLSessionDataTask?
    var indexPathRow: Int = 0
    
    weak var imageDicDelegate: ImageDicDelegate?
    
    var imageURLString: String? {
        didSet {
            guard let imageURLString = imageURLString else {
                return
            }
            if let naverImage = self.imageDicDelegate?.getImage(link: imageURLString) {
                self.naverImage.image = naverImage
                return
            }
            downloadImage(from: imageURLString) { [weak self] data, response, error in
                guard let data = data, let image = UIImage(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setImageHeight(image.size)
                    self?.naverImage.image = image
                    self?.imageDicDelegate?.updateImageDictioinary(link: imageURLString, value: image)
                }
            }
        }
    }
    
    private func setImageHeight(_ imageSize: CGSize) {
        var ratio = imageSize.height / imageSize.width
        if ratio > 1.3 {
            ratio = 1.3
        } else if ratio < 0.7 {
            ratio = 0.7
        }
        naverImageHeightConstraint.constant = naverImageHeightConstraint.constant * ratio
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.naverImage.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        naverImage.image = nil
        titleLabel.text = nil
        
        print("prepareForReuse: indexPathRow\(indexPathRow)")
        httpTask?.cancel()
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
