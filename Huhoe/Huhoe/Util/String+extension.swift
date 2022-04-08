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
}
