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

// 현재 Array에서 하나라도 같은 값이 있다면 return true
extension Array where Element: Equatable {
    func contains(array: [Element]) -> Bool {
        for item in array {
            if self.contains(item) {
               return true
            }
        }
        return false
    }
}

//중복없이 추가한다.
extension Array where Element: Equatable {
    mutating func appendWithoutDuplicate(array: [Element]) {
        for item in array {
            if self.contains(item) == false {
                self.append(item)
            }
        }
    }
}
