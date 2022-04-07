//
//  NetworkProvider.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation

final class NetworkProvider {
    private let apiEndPoint: String
    
    init() {
        apiEndPoint = "https://api.bithumb.com/public"
    }
    
    func makeTickerNetwork() -> TickerNetwork {
        let network = Network<Ticker>(endPoint: apiEndPoint)
        return TickerNetwork(network: network)
    }
}
