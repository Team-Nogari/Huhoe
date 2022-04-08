//
//  TickerResponseDTO+Mapping.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/07.
//

import Foundation

// MARK: - Ticker All Response DTO

struct TickerResponseDTO: Decodable {
    let status: String
    let tickerDTO: [String: DynamicValue]
    
    enum CodingKeys: String, CodingKey {
        case status
        case tickerDTO = "data"
    }
}

// MARK: - Ticker DTO

extension TickerResponseDTO {
    struct TickerDTO: Decodable {
        let openingPrice: String
        let closingPrice: String
        let minPrice: String
        let maxPrice: String
        let unitsTraded: String
        let accTradeValue: String
        let prevClosingPrice: String
        let unitsTraded24Hour: String
        let accTradeValue24Hour: String
        let fluctate24Hour: String
        let fluctateRate24Hour: String
        let date: String?
        
        enum CodingKeys: String, CodingKey {
            case openingPrice
            case closingPrice
            case minPrice
            case maxPrice
            case unitsTraded
            case accTradeValue
            case prevClosingPrice
            case date
            case unitsTraded24Hour = "unitsTraded24H"
            case accTradeValue24Hour = "accTradeValue24H"
            case fluctate24Hour = "fluctate24H"
            case fluctateRate24Hour = "fluctateRate24H"
        }
    }
}

// MARK: - Dynamic Value

extension TickerResponseDTO {
    enum DynamicValue: Decodable {
        case string(String)
        case tickerData(TickerDTO)
        
        init(from decoder: Decoder) throws {
            if let string = try? decoder.singleValueContainer().decode(String.self) {
                self = .string(string)
                return
            }
            
            if let tickerData = try? decoder.singleValueContainer().decode(TickerDTO.self) {
                self = .tickerData(tickerData)
                return
            }
            
            throw DynamicError.noMatchingType
        }
        
        enum DynamicError: Error {
            case noMatchingType
        }
    }
}

extension TickerResponseDTO.DynamicValue {
    var tickerData: TickerResponseDTO.TickerDTO? {
        if case let .tickerData(tickerData) = self {
            return tickerData
        }
        return nil
    }
}


// MARK: - Mapping to Domain

extension TickerResponseDTO {
    func toDomain() -> TickerResponse {
        var tickers = [Ticker]()
        
        tickerDTO.forEach { key, dynamicValue in
            if let tickerDTO = dynamicValue.tickerData {
                let ticker = tickerDTO.toDomain(coinSymbol: key)
                tickers.append(ticker)
            }
        }

        return TickerResponse(
            status: status,
            tickers: tickers
        )
    }
}

extension TickerResponseDTO.TickerDTO {
    func toDomain(coinSymbol: String) -> Ticker {
        return Ticker(
            coinSymbol: coinSymbol,
            openPirce: openingPrice.toDouble,
            accTradeValue24Hour: accTradeValue24Hour.toDouble
        )
    }
}

// MARK: - Double Extention

private extension String {
    var toDouble: Double {
        guard let convertedDouble = Double(self) else {
            return Double.zero
        }
        
        return convertedDouble
    }
}
