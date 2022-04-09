//
//  CandlestickRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/09.
//

import Foundation
import RxRelay

protocol CandlestickRepository {
    var coinPriceHistoryRelay: BehaviorRelay<[CoinPriceHistory]> { get }
    func fetchCandlestick(coinSymbol: [String])
}

