//
//  TransactionHistoryDTO+Mapping.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/07.
//

import Foundation

struct TransactionResponseDTO: Decodable {
    let status: String
    let transactionDTO: [TransactionDTO]
    
    enum CodingKeys: String, CodingKey {
        case status
        case transactionDTO = "data"
    }
}

extension TransactionResponseDTO {
    struct TransactionDTO: Decodable {
        let transactionDate: String
        let type: String
        let unitsTraded: String
        let price: String
        let total: String
    }
}
