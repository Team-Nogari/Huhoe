//
//  DefaultCandlestickRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/09.
//

import Foundation
import RxSwift

final class DefaultCandlestickRepository {
    var coinPriceHistory: Observable<[CoinPriceHistory]>?
    let network: CandlestickNetwork
    
    init(network: CandlestickNetwork = NetworkProvider().makeCandlestickNetwork()) {
        self.network = network
    }
}

extension DefaultCandlestickRepository: CandlestickRepository {
    func fetchCandlestick(coinSymbol: [String]) {
        let coinPriceHistoryObservables = coinSymbol.map { coin in
                network.fetchCandlestick(with: coin).compactMap { $0?.toDomain(coinSymbol: coin)
            }
        }
        
        let coinPriceHistories = Observable.zip(coinPriceHistoryObservables)
        
        coinPriceHistory = coinPriceHistories
    }
}
