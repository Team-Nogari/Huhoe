//
//  CoinInfoItem.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/16.
//

import Foundation

struct CoinInfoItem: Hashable {
    let coinName: String
    let coinSymbol: String
    let calculatedPrice: Double
    let rate: Double
    let profitAndLoss: Double
    let currentPrice: Double
    let oldPrice: Double
}

extension CoinInfoItem {
    var calculatedPriceString: String {
        return self.calculatedPrice.toString()
    }
    
    var rateString: String {
        return self.rate.toString(digit: 2)
    }
    
    var profitAndLossString: String {
        return profitAndLoss.toString()
    }
    
    var currentPriceString: String {
        return currentPrice.toString(digit: 4)
    }
    
    var oldPriceString: String {
        return oldPrice.toString(digit: 4)
    }
}
