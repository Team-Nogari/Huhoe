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
    
    func fetchCandlestick(with coinSymbol: String) -> Observable<CandlestickResponseDTO?> {
        Thread.sleep(forTimeInterval: 0.02) // API 요청 제한
        return network.fetch(.candlestick, with: coinSymbol)
            .map {
                let data = try? JSONSerialization.jsonObject(with: $0) as? [String: Any]
                return CandlestickResponseDTO(serializedData: data)
            }
    }
}
