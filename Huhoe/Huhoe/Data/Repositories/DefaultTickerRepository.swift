//
//  DefaultTickerRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/08.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultTickerRepository {
    let tickerRelay = PublishRelay<[Ticker]>()
    private var disposeBag = DisposeBag()
    let network: TickerNetwork
    
    init(network: TickerNetwork = NetworkProvider().makeTickerNetwork()) {
        self.network = network
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}

extension DefaultTickerRepository: TickerRepository {
    func fetchTicker(coinSymbol: String) {
        network.fetchTicker(with: coinSymbol)
            .map {
                let tickersCount = $0.toDomain().tickers.count
                
                return $0.toDomain().tickers
                    .sorted {
                        $0.accTradeValue24Hour > $1.accTradeValue24Hour
                    }
                    .dropLast(tickersCount - 100)
            }
            .subscribe(onNext: { [weak self] in
                self?.tickerRelay.accept($0)
            })
            .disposed(by: disposeBag)
    }
}
