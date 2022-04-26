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
    let transactionWebSocketRepository: DefaultTransactionWebSocketRepository // 추상화 필요
    private let disposeBag = DisposeBag()
    
    init(
        tickerRepository: TickerRepository = DefaultTickerRepository(),
        transactionRepository: TransactionHistoryRepository = DefaultTransactionHistoryRepository(),
        candlestickRepository: CandlestickRepository = DefaultCandlestickRepository(),
        transactionWebSocketRepository: DefaultTransactionWebSocketRepository = DefaultTransactionWebSocketRepository()
    ) {
        self.tickerRepository = tickerRepository
        self.transactionRepository = transactionRepository
        self.candlestickRepository = candlestickRepository
        self.transactionWebSocketRepository = transactionWebSocketRepository
    }
}

extension CoinListUseCase {
    func fetch() -> Observable<([Ticker], [Transaction], [CoinPriceHistory])> {
        let tickerObservable = tickerRepository.fetchTicker(coinSymbol: "ALL")
            
        let transactionObservable = tickerObservable
            .flatMap { tickers -> Observable<[Transaction]> in
                let symbols = tickers.map {
                    $0.coinSymbol
                }
                
                return self.transactionRepository.fetchTransactionHistory(coinSymbol: symbols)
            }
        
        let coinPriceHistoryObservable = tickerObservable
            .flatMap { tickers -> Observable<[CoinPriceHistory]> in
                let symbols = tickers.map {
                    $0.coinSymbol
                }
                
                return self.candlestickRepository.fetchCandlestick(coinSymbol: symbols)
            }
        
        return Observable.zip(tickerObservable, transactionObservable, coinPriceHistoryObservable)
    }
    
    func fetchTransactionWebSocket(with coinSymbols: [String]) -> Observable<RealTimeCoinPrice> {
        
        
        return transactionWebSocketRepository.fetchTransaction(with: coinSymbols)
    }
}

struct CoinInfo: Hashable {
    let symbol: String
    let currentPrice: Double
    let priceHistory: [Double]
    let date: [Date]
}
