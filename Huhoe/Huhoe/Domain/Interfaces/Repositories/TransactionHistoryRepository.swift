//
//  TransactionHistoryRepository.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/08.
//

import Foundation
import RxRelay

protocol TransactionHistoryRepository {
    var transactionHistoryRelay: PublishRelay<[Transaction]> { get }
    func fetchTransactionHistory(coinSymbol: [String])
}
