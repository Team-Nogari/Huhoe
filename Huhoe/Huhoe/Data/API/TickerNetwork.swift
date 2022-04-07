//
//  TickerNetwork.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation
import RxSwift

final class TickerNetwork {
    private let network: Network<Ticker>
    
    init(network: Network<Ticker>) {
        self.network = network
    }
    
    func fetchTicker() -> Observable<[Ticker]> {
        return network.fetch(.ticker)
    }
}

struct Ticker: Decodable { }
