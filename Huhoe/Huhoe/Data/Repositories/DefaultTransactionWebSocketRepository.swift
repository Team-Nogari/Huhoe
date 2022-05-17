//
//  DefaultTransactionWebSocketRepository.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/26.
//

import Foundation
import RxSwift

final class DefaultTransactionWebSocketRepository {
    let network: TransactionWebSocketNetwork
    
    init(network: TransactionWebSocketNetwork = TransactionWebSocketNetwork(network: WebSocketNetworkService())) {
        self.network = network
    }
    
    func fetchTransaction(with coinsymbols: [String]) -> Observable<RealTimeCoinPrice> {
        let transactionObservable = network.fetchTransaction(with: coinsymbols)
            .compactMap { data in
                data?.toDomain()
            }
            .filterNil()
        
        return transactionObservable
    }
}
