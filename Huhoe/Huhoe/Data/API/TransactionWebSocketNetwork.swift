//
//  TransactionWebSocketNetwork.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/25.
//

import Foundation
import RxSwift

final class TransactionWebSocketNetwork {
    private let network: WebSocketNetworkService
    
    init(network: WebSocketNetworkService) {
        self.network = network
    }
    
    func fetchTransaction(with coinsymbols: [String]) -> Observable<TransactionWebSocketResponseDTO> {
        network.connect(to: "transaction", with: coinsymbols)
        
        return network.webSocketDataSubject
            .map {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(TransactionWebSocketResponseDTO.self, from: $0)
            }
    }
}
