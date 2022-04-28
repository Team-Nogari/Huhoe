//
//  CandlestickRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/09.
//

import Foundation
import RxSwift

protocol CandlestickRepository {
    var dataSource: CoinPriceHistoryDataSource { get }
    func fetchCandlestick(coinSymbol: [String]) -> Observable<[CoinPriceHistory]>
    func fetchCoinPriceHistory(with coinSymbol: String) -> Observable<CoinPriceHistory>
}

