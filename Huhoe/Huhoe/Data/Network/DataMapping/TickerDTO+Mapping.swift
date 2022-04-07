//
//  TickerDTO+Mapping.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/07.
//

import Foundation

// MARK: - Data Transfer Object

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
