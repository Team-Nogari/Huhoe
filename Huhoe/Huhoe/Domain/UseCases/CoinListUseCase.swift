//
//  CoinListUseCase.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/09.
//

import Foundation
import UIKit

final class CoinListUseCase {
    let tickerRepository: TickerRepository
    let transactionRepository: TransactionHistoryRepository
    let candlestickRepository: CandlestickRepository
    
    init(
        tickerRepository: TickerRepository = DefaultTickerRepository(),
        transactionRepository: TransactionHistoryRepository = DefaultTransactionHistoryRepository(),
        candlestickRepository: CandlestickRepository = DefaultCandlestickRepository()
    ) {
        self.tickerRepository = tickerRepository
        self.transactionRepository = transactionRepository
        self.candlestickRepository = candlestickRepository
    }
}

extension CoinListUseCase {
    func bind() {
        tickerRepository.tickerRelay
            .asObservable()
            .subscribe(onNext: { [weak self] in
                let symbols = $0.map {
                    $0.coinSymbol
                }
                self?.fetchTransactionHistroy(coinSymbols: symbols)
                self?.fetchCoinPirceHistory(coinSymbols: symbols)
            })
    }
    
    func fetchCoinList() {
        tickerRepository.fetchTicker(coinSymbol: "ALL")
    }
    
    func fetchTransactionHistroy(coinSymbols: [String]) {
        transactionRepository.fetchTransactionHistory(coinSymbol: coinSymbols)
    }
    
    func fetchCoinPirceHistory(coinSymbols: [String]) {
        candlestickRepository.fetchCandlestick(coinSymbol: coinSymbols)
    }
}
