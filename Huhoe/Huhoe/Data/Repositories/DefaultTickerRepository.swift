//
//  DefaultTickerRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/08.
//

import Foundation
import RxSwift

final class DefaultTickerRepository {
    var dataSource: TickerDataSource = DefaultTickerDatsSource()
    let network: TickerNetwork
    
    init(network: TickerNetwork = HttpNetworkProvider().makeTickerNetwork()) {
        self.network = network
    }
}

extension DefaultTickerRepository: TickerRepository {
    func fetchTicker(coinSymbol: String) -> Observable<[Ticker]> {
        return network.fetchTicker(with: coinSymbol)
            .map {
                let tickersCount = $0.toDomain().tickers.count
                let sortedTicker = $0.toDomain().tickers
                    .sorted {
                        $0.accTradeValue24Hour > $1.accTradeValue24Hour
                    }
                    .dropLast(tickersCount - 6)
                
                self.dataSource.tickers = Array(sortedTicker)
                
                return Array(sortedTicker)
            }
    }
}
