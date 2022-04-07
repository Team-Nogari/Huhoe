//
//  TickerResponseDTO+Mapping.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/07.
//

import Foundation

struct TickerResponseDTO: Decodable {
    let status: String
    let tickerDTO: TickerDTO
    
    enum CodingKeys: String, CodingKey {
        case status
        case tickerDTO = "data"
    }
}
