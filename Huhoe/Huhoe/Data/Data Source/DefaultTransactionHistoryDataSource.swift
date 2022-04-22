//
//  DefaultTransactionHistoryDataSource.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/15.
//

import Foundation
import RxSwift

protocol TransactionHistoryDataSource {
    var transactionHistory: [Transaction] { get set }
    func fetch(_ transaction: [Transaction]) -> Completable
}

class DefaultTransactionHistoryDataSource: TransactionHistoryDataSource {
    var transactionHistory = [Transaction]()
    
    func fetch(_ transaction: [Transaction]) -> Completable {
        return Completable.create { completable in
            self.transactionHistory = transaction
            
            completable(.completed)
            
            return Disposables.create()
        }
    }
}
