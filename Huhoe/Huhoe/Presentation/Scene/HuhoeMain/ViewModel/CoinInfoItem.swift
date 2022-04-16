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
}

extension CoinInfoItem {
    var calculatedPriceString: String {
        return self.calculatedPrice.toString
    }
    
    var rateString: String {
        return self.rate.toString
    }
    
    var profitAndLossString: String {
        return profitAndLoss.toString
    }
    
    var currentPriceString: String {
        return currentPrice.toString
    }
}

private extension Double {
    var toString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 4
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(for: self) ?? ""
    }
}
