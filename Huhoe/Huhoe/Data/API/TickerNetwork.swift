//
//  TickerNetwork.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation
import RxSwift

final class TickerNetwork {
    private let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func fetchTicker(with coinSymbol: String) -> Observable<[Ticker]> {
        return network.fetch(.ticker, with: coinSymbol)
            .map {
                try! JSONDecoder().decode([Ticker].self, from: $0)
            }
    }
}

struct Ticker: Decodable { }
