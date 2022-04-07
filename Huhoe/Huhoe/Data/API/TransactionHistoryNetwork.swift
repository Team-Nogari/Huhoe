//
//  TransactionHistoryNetwork.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation
import RxSwift

final class TransactionHistoryNetwork {
    private let network: Network<TransactionHistory>
    
    init(network: Network<TransactionHistory>) {
        self.network = network
    }
    
    func fetchTransactionHistory() -> Observable<[TransactionHistory]> {
        return network.fetch(.transactionHistory)
    }
}

struct TransactionHistory: Decodable { }
