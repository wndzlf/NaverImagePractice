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
    
    var imageURLString: String? {
        didSet {
            guard let imageURLString = imageURLString else {
                return
            }
            downloadImage(from: imageURLString) { [weak self] data, response, error in
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    self?.naverImage.image = UIImage(data: data)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from urlString: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> () ) {
        guard let url = URL(string: urlString) else {return}
        getData(from: url, completion: completionHandler)
    }

}
