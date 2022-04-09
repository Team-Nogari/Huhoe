//
//  TransactionHistoryRepository.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/08.
//

import Foundation

protocol TransactionHistoryRepository {
    func fetchTransactionHistory(coinSymbol: [String])
}
