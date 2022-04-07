//
//  Network.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation

final class Network<T: Decodable> {
    private let endPoint: String
    
    init(_ endPoint: String) {
        self.endPoint = endPoint
    }
}
