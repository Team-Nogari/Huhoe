//
//  OrderBookNetwork.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation
import RxSwift

final class OrderBookNetwork {
    private let network: Network<OrderBook>
    
    init(network: Network<OrderBook>) {
        self.network = network
    }
    
    func fetchOrderBook() -> Observable<[OrderBook]> {
        return network.fetch(.orderBook)
    }
}

struct OrderBook: Decodable { }
