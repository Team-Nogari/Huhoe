//
//  DefaultTransactionHistoryRepository.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/08.
//

import Foundation
import RxSwift

final class DefaultTransactionHistoryRepository {
    var transactionHistory: Observable<[Transaction]>?
    let network: TransactionHistoryNetwork
    
    init(network: TransactionHistoryNetwork = NetworkProvider().makeTransactionHistoryNetwork()) {
        self.network = network
    }
}

extension DefaultTransactionHistoryRepository: TransactionHistoryRepository {
    func fetchTransactionHistory(coinSymbol: [String]) {
        let transactionObservables = coinSymbol.map { coin in
            network.fetchTransactionHistory(with: coin).map { $0.toDomain(coinSymbol: coin) }
        }
        
        let transactionHistories = Observable.zip(transactionObservables)
        
        transactionHistory = transactionHistories
    }
}
