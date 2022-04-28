//
//  String+extension.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/08.
//

import Foundation

extension String {
    var toDouble: Double {
        guard let convertedDouble = Double(self) else {
            return Double.zero
        }
        
        return convertedDouble
    }
    
    var toTimeInterval: TimeInterval {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        
        return formatter.date(from: self)?.timeIntervalSince1970 ?? .zero
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}
