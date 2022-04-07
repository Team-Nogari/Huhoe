//
//  CandleStickNetwork.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/08.
//

import Foundation
import RxSwift

final class CandlestickNetwork {
    private let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func fetchCandlestick(with coinSymbol: String) -> Observable<[Candlestick]> {
        return network.fetch(.candlestick, with: coinSymbol)
            .map {
                try! JSONDecoder().decode([Candlestick].self, from: $0)
            }
    }
}

struct Candlestick: Decodable { }
