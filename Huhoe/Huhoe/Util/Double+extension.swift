//
//  Double+extension.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/28.
//

import Foundation

extension Double {
    func toString(digit: Int = 0) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = digit
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(for: self) ?? ""
    }
}
