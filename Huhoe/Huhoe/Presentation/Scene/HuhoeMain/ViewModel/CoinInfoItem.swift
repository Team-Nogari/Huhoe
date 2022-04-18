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
}

private extension Double {
    func toString(digit: Int = 0) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = digit
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(for: self) ?? ""
    }
}
