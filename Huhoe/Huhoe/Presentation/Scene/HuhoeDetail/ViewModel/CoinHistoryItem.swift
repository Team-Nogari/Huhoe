//
//  CoinHistoryItem.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/28.
//

import Foundation

struct CoinHistoryItem: Hashable {
    let date: String
    let calculatedPrice: Double
    let rate: Double
    let profitAndLoss: Double
}

extension CoinHistoryItem {
    var calculatedPriceString: String {
        return self.calculatedPrice.toString()
    }
    
    var rateString: String {
        return self.rate.toString(digit: 2)
    }
    
    var profitAndLossString: String {
        return profitAndLoss.toString()
    }
}
