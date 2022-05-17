//
//  CandlestickResponseDTO+Mapping.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/07.
//

import Foundation

struct CandlestickResponseDTO {
    let status: String
    let candlestickDTO: [CandlestickDTO]
    
    init?(serializedData: [String: Any]?) {
        guard let status = serializedData?["status"] as? String,
              let candlestickData = serializedData?["data"] as? [[Any]]
        else {
            return nil
        }
        
        let candlesticksDTO = candlestickData.compactMap {
            CandlestickDTO(data: $0)
        }
        
        self.status = status
        self.candlestickDTO = candlesticksDTO
    }
}

struct CandlestickDTO {
    let time: Double
    let openPrice: String
    let closePrice: String
    let lowPrice: String
    let highPrice: String
    let volume: String
    
    init?(data: [Any]) {
        guard let time = data[0] as? Double,
              let openPrice = data[1] as? String,
              let closePrice = data[2] as? String,
              let lowPrice = data[3] as? String,
              let highPrice = data[4] as? String,
              let volume = data[5] as? String
        else {
            return nil
        }
        
        self.time = time
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.volume = volume
    }
}

// MARK: - Mapping to Domain

extension CandlestickResponseDTO {
    func toDomain(coinSymbol: String) -> CoinPriceHistory {
        let dates = candlestickDTO
            .map { $0.time * 0.001 }
        
        let price = candlestickDTO
            .map{ $0.closePrice.toDouble }
        
        return CoinPriceHistory(
            coinSymbol: coinSymbol,
            date: dates,
            price: price
        )
    }
}
