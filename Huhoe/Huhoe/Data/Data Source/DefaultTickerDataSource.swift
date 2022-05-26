//
//  DefaultTickerDataSource.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/15.
//

import Foundation

protocol TickerDataSource {
    var tickers: [Ticker] { get set }
}

final class DefaultTickerDatsSource: TickerDataSource {
    var tickers = [Ticker]()
}
