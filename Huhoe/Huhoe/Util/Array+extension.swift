//
//  Array+extension.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/28.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
