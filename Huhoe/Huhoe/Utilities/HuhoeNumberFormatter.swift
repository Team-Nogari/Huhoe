//
//  HuhoeNumberFormatter.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/26.
//

import Foundation

final class HuhoeNumberFormatter {
    static let shared = HuhoeNumberFormatter()
    
    private init() { }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    func toString(number: Double, digit: Int = 0) -> String {
        numberFormatter.maximumFractionDigits = digit
        
        return numberFormatter.string(for: number) ?? ""
    }
}
