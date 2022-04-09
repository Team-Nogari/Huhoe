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
    let tickerRelay = BehaviorRelay<[Ticker]>(value: [])
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
            .map { $0.toDomain().tickers
                .sorted {
                    $0.accTradeValue24Hour > $1.accTradeValue24Hour
                }
            }.subscribe(onNext: { [weak self] in
                self?.tickerRelay.accept($0)
            })
            .disposed(by: disposeBag)
    }
}
