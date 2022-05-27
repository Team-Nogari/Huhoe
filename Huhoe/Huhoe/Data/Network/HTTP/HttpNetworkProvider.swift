//
//  NetworkProvider.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation

final class HttpNetworkProvider {
    private let apiEndPoint: String
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.apiEndPoint = "https://api.bithumb.com/public"
        self.session = session
    }
    
    func makeTickerNetwork() -> TickerNetwork {
        let network = HttpNetwork(endPoint: apiEndPoint, session: session)
        return TickerNetwork(network: network)
    }
    
    func makeTransactionHistoryNetwork() -> TransactionHistoryNetwork {
        let network = HttpNetwork(endPoint: apiEndPoint, session: session)
        return TransactionHistoryNetwork(network: network)
    }
    
    func makeCandlestickNetwork() -> CandlestickNetwork {
        let network = HttpNetwork(endPoint: apiEndPoint, session: session)
        return CandlestickNetwork(network: network)
    }
}
