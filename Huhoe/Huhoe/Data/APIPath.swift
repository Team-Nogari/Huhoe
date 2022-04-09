//
//  APIPath.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation

enum APIPath {
    case ticker
    case transactionHistory
    case candlestick
    
    var path: String {
        switch self {
        case .ticker:
            return String(describing: APIPath.ticker)
        case .transactionHistory:
            return "transaction_history"
        case .candlestick:
            return String(describing: APIPath.candlestick)
        }
    }
    
    var paymentCurrency: String {
        return "KRW"
    }
}
