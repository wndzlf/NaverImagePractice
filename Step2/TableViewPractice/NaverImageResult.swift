//
//  NaverImageResult.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/10.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import Foundation

// MARK: - NaverImagResult
struct NaverImagResult: Codable {
    let lastBuildDate: String
    let total, start, display: Int
    let items: [Item]
}

// MARK: - Item
struct Item: Codable {
    let title: String
    let link: String
    let thumbnail: String
    let sizeheight, sizewidth: String
}
