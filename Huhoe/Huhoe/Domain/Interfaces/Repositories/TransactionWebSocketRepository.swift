//
//  TransactionWebSocketRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/26.
//

import Foundation
import RxSwift

protocol TransactionWebSocketRepository {
    var network: TransactionWebSocketNetwork { get }
    func fetchTransaction(with coinsymbols: [String]) -> Observable<RealTimeCoinPrice>
}
