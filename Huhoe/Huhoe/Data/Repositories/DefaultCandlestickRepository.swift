//
//  DefaultCandlestickRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/09.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultCandlestickRepository {
    var dataSource: CoinPriceHistoryDataSource = DefaultCoinPriceHistoryDataSource()
    let network: CandlestickNetwork
    
    init(network: CandlestickNetwork = NetworkProvider().makeCandlestickNetwork()) {
        self.network = network
    }
}

extension DefaultCandlestickRepository: CandlestickRepository {
    func fetchCandlestick(coinSymbol: [String]) -> Observable<[CoinPriceHistory]> {
        let coinPriceHistoryObservables = coinSymbol.map { coin in
            network.fetchCandlestick(with: coin).compactMap { $0?.toDomain(coinSymbol: coin) }
        }
        
        _ = Observable.zip(coinPriceHistoryObservables)
            .map { self.dataSource.coinPriceHistory = $0 }
        
        return Observable.zip(coinPriceHistoryObservables)
    }
}
