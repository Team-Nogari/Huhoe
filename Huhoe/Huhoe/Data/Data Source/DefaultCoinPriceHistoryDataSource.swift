//
//  DefaultCandlestickDataSource.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/15.
//

import Foundation

protocol CoinPriceHistoryDataSource {
    var coinPriceHistory: [CoinPriceHistory] { get set }
}

class DefaultCoinPriceHistoryDataSource: CoinPriceHistoryDataSource {
    var coinPriceHistory = [CoinPriceHistory]()
}
