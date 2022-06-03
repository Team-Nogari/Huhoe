//
//  TransactionWebSocketResponseDTO.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/25.
//

import Foundation

struct TransactionWebSocketResponseDTO: Decodable {
    let type: String
    let transactionWebSocketData: TransactionWebSocketData
    
    enum CodingKeys: String, CodingKey {
        case type
        case transactionWebSocketData = "content"
    }
}

struct TransactionWebSocketData: Decodable {
    let list: [TransactionWithWebSocket]
    
    struct TransactionWithWebSocket: Decodable {
        let transactionType: TransactionType
        let coinSymbol: String
        let price: String
        let quantity: String
        let amount: String
        let date: String
        let bullOrBear: PriceBullBear

        enum CodingKeys: String, CodingKey {
            case transactionType = "buySellGb"
            case coinSymbol = "symbol"
            case price = "contPrice"
            case quantity = "contQty"
            case amount = "contAmt"
            case date = "contDtm"
            case bullOrBear = "updn"
        }
    }
    
    enum TransactionType: String, Decodable {
        case ask = "1"
        case bid = "2"
    }
    
    enum PriceBullBear: String, Decodable {
        case bullish = "up"
        case bearish = "dn"
    }
}

extension TransactionWebSocketResponseDTO {
    func toDomain() -> RealTimeCoinPrice {
        if let item = transactionWebSocketData.list.first {
            return RealTimeCoinPrice(coinSymbol: item.coinSymbol, price: item.price.toDouble)
        }
        
        return RealTimeCoinPrice(
            coinSymbol: "",
            price: Double.zero
        )
    }
}

