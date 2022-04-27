//
//  CoinDetailUseCase.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/27.
//

import Foundation
import RxSwift

final class CoinDetailUseCase {
    let candlestickRepository: CandlestickRepository
    let transactionWebSocketRepository: DefaultTransactionWebSocketRepository // 추상화 필요
    private let disposeBag = DisposeBag()
    
    init(
        candlestickRepository: CandlestickRepository = DefaultCandlestickRepository(),
        transactionWebSocketRepository: DefaultTransactionWebSocketRepository = DefaultTransactionWebSocketRepository()
    ) {
        self.candlestickRepository = candlestickRepository
        self.transactionWebSocketRepository = transactionWebSocketRepository
    }
}

