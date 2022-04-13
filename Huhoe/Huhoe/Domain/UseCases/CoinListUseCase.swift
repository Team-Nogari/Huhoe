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
    func bind() -> Observable<[CoinInfo]> {
        let tickerObservable = tickerRepository.tickerRelay.asObservable()
        let transactionObservable = transactionRepository.transactionHistoryRelay.asObservable()
        let candlestickObservable = candlestickRepository.coinPriceHistoryRelay.asObservable()
        
        return Observable.zip(tickerObservable, transactionObservable, candlestickObservable)
            .map { tickers, transactions, coinPriceHistory -> [CoinInfo] in
                var cellItems = [CoinInfo]()
                
                for index in tickers.indices {
                    let cellItem = CoinInfo(
                        symbol: tickers[index].coinSymbol,
                        currentPrice: transactions[index].price,
                        priceHistory: coinPriceHistory[index].price,
                        date: coinPriceHistory[index].date
                    )
                    
                    cellItems.append(cellItem)
                }
                
                return cellItems
            }
    }
    
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

struct CoinInfo: Hashable {
    let symbol: String
    let currentPrice: Double
    let priceHistory: [Double]
    let date: [Date]
}
