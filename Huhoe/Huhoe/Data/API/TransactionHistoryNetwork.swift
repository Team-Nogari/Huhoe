//
//  TransactionHistoryNetwork.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation
import RxSwift

final class TransactionHistoryNetwork {
    private let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func fetchTransactionHistory(with coinSymbol: String) -> Observable<TransactionResponseDTO> {
        Thread.sleep(forTimeInterval: 0.05) // API 요청 제한 문제때문에..
        return network.fetch(.transactionHistory, with: coinSymbol)
            .map {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try! decoder.decode(TransactionResponseDTO.self, from: $0) // 강제 수정 필요
            }
    }
}
