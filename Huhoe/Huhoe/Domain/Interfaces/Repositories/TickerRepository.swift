//
//  TickerRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/08.
//

import Foundation
import RxSwift

protocol TickerRepository {
    var dataSource: TickerDataSource { get }
    func fetchTicker(coinSymbol: String) -> Observable<[Ticker]>
}
