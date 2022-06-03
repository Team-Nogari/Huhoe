//
//  DefaultTransactionHistoryRepository.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/08.
//

import Foundation
import RxSwift

final class DefaultTransactionHistoryRepository {
    var dataSource: TransactionHistoryDataSource = DefaultTransactionHistoryDataSource()
    let network: TransactionHistoryNetwork
    
    init(network: TransactionHistoryNetwork = HttpNetworkProvider().makeTransactionHistoryNetwork()) {
        self.network = network
    }
}

extension DefaultTransactionHistoryRepository: TransactionHistoryRepository {
    func fetchTransactionHistory(coinSymbol: [String]) -> Observable<[Transaction]> {
        let transactionObservables = coinSymbol.map { coin in
            network.fetchTransactionHistory(with: coin).compactMap { $0?.toDomain(coinSymbol: coin) }
        }
        
        _ = Observable.zip(transactionObservables)
            .map { self.dataSource.transactionHistory = $0 }
        
        return Observable.zip(transactionObservables)
    }
}
