//
//  Date+extension.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/19.
//

import Foundation

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    }
}
