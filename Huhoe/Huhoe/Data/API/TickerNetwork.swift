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
    
    func fetchTicker(with coinSymbol: String) -> Observable<TickerResponseDTO> {
        return network.fetch(.ticker, with: coinSymbol)
            .map {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try! decoder.decode(TickerResponseDTO.self, from: $0)
            }
    }
}
