//
//  DefaultTickerRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/08.
//

import Foundation
import RxSwift

final class DefaultTickerRepository {
    var ticker: Observable<[Ticker]>?
    let network: TickerNetwork
    
    init(network: TickerNetwork = NetworkProvider().makeTickerNetwork()) {
        self.network = network
    }
}

extension DefaultTickerRepository: TickerRepository {
    func fetchTicker(coinSymbol: String) {
        ticker = network.fetchTicker(with: coinSymbol)
            .map { $0.toDomain().tickers
                .sorted {
                    $0.accTradeValue24Hour > $1.accTradeValue24Hour
                }
            } 
    }
}
