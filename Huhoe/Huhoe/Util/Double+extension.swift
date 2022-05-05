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
    
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let date = Date(timeIntervalSince1970: self)
        
        return formatter.string(from: date)
    }
}
