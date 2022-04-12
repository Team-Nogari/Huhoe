//
//  TickerRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/08.
//

import Foundation
import RxSwift
import RxRelay

protocol TickerRepository {
    var tickerRelay: PublishRelay<[Ticker]> { get }
    func fetchTicker(coinSymbol: String)
}
