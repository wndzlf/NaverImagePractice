//
//  NaverImageCellModel.swift
//  TableViewPractice
//
//  Created by 조중현 on 2020/01/09.
//  Copyright © 2020 wndzlf. All rights reserved.
//

import UIKit

protocol NaverImageGettable: class {
    var urlString: String { get }
    var httpTask: URLSessionDataTask? { set get }
    func downloadImage(completionHandler: @escaping (Data?, URLResponse?, Error?) -> ())
}

extension NaverImageGettable {
    func downloadImage(completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: urlString) else {return}
        
        httpTask = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        httpTask?.resume()
    }
}

class NaverImageCellModel: NaverImageGettable {
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
        downloadImage { data, response, error in
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
