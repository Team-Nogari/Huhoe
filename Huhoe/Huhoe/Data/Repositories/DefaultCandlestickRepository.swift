//
//  DefaultCandlestickRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/09.
//

import Foundation
import RxSwift

final class DefaultCandlestickRepository {
    var dataSource: CoinPriceHistoryDataSource = DefaultCoinPriceHistoryDataSource()
    let network: CandlestickNetwork
    
    init(network: CandlestickNetwork = HttpNetworkProvider().makeCandlestickNetwork()) {
        self.network = network
    }
}

extension DefaultCandlestickRepository: CandlestickRepository {
    func fetchCandlestick(coinSymbol: [String]) -> Observable<[CoinPriceHistory]> {
        let coinPriceHistoryObservables = coinSymbol.map { coin in
            network.fetchCandlestick(with: coin).compactMap { [weak self] dto -> CoinPriceHistory? in
                let coinPriceHistory = dto?.toDomain(coinSymbol: coin)
                self?.dataSource.coinPriceHistory.append(coinPriceHistory)
                return coinPriceHistory
            }
        }
        
        return Observable.zip(coinPriceHistoryObservables)
    }
    
    func fetchCoinPriceHistory(with coinSymbol: String) -> Observable<CoinPriceHistory> {
        guard let coinPriceHistory = dataSource.coinPriceHistory
                .filter({ $0?.coinSymbol == coinSymbol }).first
        else {
            return .empty()
        }
        
        return Observable.just(coinPriceHistory)
            .filterNil()
    }
}
