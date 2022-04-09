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
    var coinPriceHistoryRelay = BehaviorRelay<[CoinPriceHistory]>(value: [])
    let network: CandlestickNetwork
    private let disposeBag = DisposeBag()
    
    init(network: CandlestickNetwork = NetworkProvider().makeCandlestickNetwork()) {
        self.network = network
    }
}

extension DefaultCandlestickRepository: CandlestickRepository {
    func fetchCandlestick(coinSymbol: [String]) {
        let coinPriceHistoryObservables = coinSymbol.map { coin in
            network.fetchCandlestick(with: coin).compactMap { $0?.toDomain(coinSymbol: coin) }
        }
        
        Observable.zip(coinPriceHistoryObservables)
            .subscribe(onNext: { [weak self] in
                self?.coinPriceHistoryRelay.accept($0)
            }).disposed(by: disposeBag)
    }
}
