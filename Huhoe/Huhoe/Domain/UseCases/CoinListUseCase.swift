//
//  CoinListUseCase.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/09.
//

import Foundation
import RxSwift

final class CoinListUseCase {
    let tickerRepository: TickerRepository
    let transactionRepository: TransactionHistoryRepository
    let candlestickRepository: CandlestickRepository
    private let disposeBag = DisposeBag()
    
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
    func fetch() {
        fetchCoinList()
        
        tickerRepository.tickerRelay
            .asObservable()
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(queue: .global()))
            .subscribe(onNext: { [weak self] in
                let symbols = $0.map {
                    $0.coinSymbol
                }
                self?.fetchTransactionHistroy(coinSymbols: symbols)
                self?.fetchCoinPirceHistory(coinSymbols: symbols)
            }).disposed(by: disposeBag)
    }
    
    private func fetchCoinList() {
        tickerRepository.fetchTicker(coinSymbol: "ALL")
    }
    
    private func fetchTransactionHistroy(coinSymbols: [String]) {
        transactionRepository.fetchTransactionHistory(coinSymbol: coinSymbols)
    }
    
    private func fetchCoinPirceHistory(coinSymbols: [String]) {
        candlestickRepository.fetchCandlestick(coinSymbol: coinSymbols)
    }
}
