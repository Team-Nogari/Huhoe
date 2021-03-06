//
//  TransactionHistoryRepository.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/08.
//

import Foundation
import RxSwift

protocol TransactionHistoryRepository {
    var dataSource: TransactionHistoryDataSource { get }
    func fetchTransactionHistory(coinSymbol: [String]) -> Observable<[Transaction]>
}
