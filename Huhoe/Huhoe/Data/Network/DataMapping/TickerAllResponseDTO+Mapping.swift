//
//  TickerResponseDTO+Mapping.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/07.
//

import Foundation

// MARK: - Data Transfer Object

struct TickerAllResponseDTO: Decodable {
    let status: String
    let tickerDTO: [String: DynamicValue]
    
    enum CodingKeys: String, CodingKey {
        case status
        case tickerDTO = "data"
    }
}

extension TickerAllResponseDTO {
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
