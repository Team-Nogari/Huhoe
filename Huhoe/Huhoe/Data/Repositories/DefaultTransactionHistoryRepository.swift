//
//  DefaultTransactionHistoryRepository.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/08.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultTransactionHistoryRepository {
    let transactionHistoryRelay = BehaviorRelay<[Transaction]>(value: [])
    let network: TransactionHistoryNetwork
    private let disposeBag = DisposeBag()
    
    init(network: TransactionHistoryNetwork = NetworkProvider().makeTransactionHistoryNetwork()) {
        self.network = network
    }
}

extension DefaultTransactionHistoryRepository: TransactionHistoryRepository {
    func fetchTransactionHistory(coinSymbol: [String]) {
        let transactionObservables = coinSymbol.map { coin in
            network.fetchTransactionHistory(with: coin).map { $0.toDomain(coinSymbol: coin) }
        }
        
        Observable.zip(transactionObservables)
            .subscribe(onNext: { [weak self] in
                self?.transactionHistoryRelay.accept($0)
            }).disposed(by: disposeBag)
    }
}
