//
//  APIPath.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation

enum APIPath {
    case ticker
    case orderBook
    case transactionHistory
    
    var path: String {
        switch self {
        case .ticker:
            return String(describing: APIPath.ticker)
        case .orderBook:
            return String(describing: APIPath.orderBook)
        case .transactionHistory:
            return String(describing: APIPath.transactionHistory)
        }
    }
    
    var orderCurrency: String {
        switch self {
        case .ticker, .orderBook:
            return "ALL"
        case .transactionHistory:
            return "BTC"
        }
    }
    
    var paymentCurrency: String {
        return "KRW"
    }
}
