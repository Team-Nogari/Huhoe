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
    
    func fetchTransactionHistory(with coinSymbol: String) -> Observable<[TransactionHistory]> {
        return network.fetch(.transactionHistory, with: coinSymbol)
            .map {
                try! JSONDecoder().decode([TransactionHistory].self, from: $0)
            }
    }
}

struct TransactionHistory: Decodable { }
