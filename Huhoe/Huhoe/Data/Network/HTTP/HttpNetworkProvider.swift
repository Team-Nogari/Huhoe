//
//  NetworkProvider.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation

final class HttpNetworkProvider {
    private let apiEndPoint: String
    
    init() {
        apiEndPoint = "https://api.bithumb.com/public"
    }
    
    func makeTickerNetwork() -> TickerNetwork {
        let network = HttpNetwork(endPoint: apiEndPoint)
        return TickerNetwork(network: network)
    }
    
    func makeTransactionHistoryNetwork() -> TransactionHistoryNetwork {
        let network = HttpNetwork(endPoint: apiEndPoint)
        return TransactionHistoryNetwork(network: network)
    }
    
    func makeCandlestickNetwork() -> CandlestickNetwork {
        let network = HttpNetwork(endPoint: apiEndPoint)
        return CandlestickNetwork(network: network)
    }
}
