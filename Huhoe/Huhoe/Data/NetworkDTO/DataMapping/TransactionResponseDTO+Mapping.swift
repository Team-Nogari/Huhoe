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
        let type: tradeType
        let unitsTraded: String
        let price: String
        let total: String
    }
}

extension TransactionResponseDTO {
    enum tradeType: Decodable {
        case bid
        case ask
    }
}

extension TransactionResponseDTO {
    func toDomain(coinSymbol: String) -> Transaction {
        if let price = transactionDTO.filter({ $0.type == .bid }).last?.price.toDouble {
            return Transaction(coinSymbol: coinSymbol, price: price)
        }
        
        return Transaction(coinSymbol: coinSymbol, price: Double.zero)
    }
}
