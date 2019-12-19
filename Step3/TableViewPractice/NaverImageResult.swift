//
//  NaverImageResult.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/10.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

// MARK: - NaverImagResult
struct NaverImagResult: Codable {
    let lastBuildDate: String?
    let total: Int?
    let start: Int?
    let display: Int?
    let items: [Item]
}

// MARK: - Item
struct Item: Codable, Equatable {
    let title: String
    let link: String
    let thumbnail: String
    let sizeheight, sizewidth: String
    
    var estimatedHeight: CGFloat?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.title == rhs.title {
            return true
        } else {
            return false
        }
    }
}
