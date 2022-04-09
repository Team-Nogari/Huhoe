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
    var tickerRelay: BehaviorRelay<[Ticker]> { get set }
    func fetchTicker(coinSymbol: String)
}
