//
//  HuhoeDateFormatter.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/09.
//

import Foundation

final class HuhoeDateFormatter {
    static let shared = HuhoeDateFormatter()
    
    private init() { }
    
    private let dateFormatter: DateFormatter = DateFormatter()
    
    func toTimeInterval(str: String) -> TimeInterval {
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return dateFormatter.date(from: str)?.timeIntervalSince1970 ?? .zero
    }
    
    func toDateString(timeInterval: TimeInterval) -> String {
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = Date(timeIntervalSince1970: timeInterval)
        
        return dateFormatter.string(from: date)
    }
}
