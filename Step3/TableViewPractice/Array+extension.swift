//
//  Array+extension.swift
//  TableViewPractice
//
//  Created by 조중현 on 2019/12/13.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}
