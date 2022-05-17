//
//  URLSessionWebSocketProtocol.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/25.
//

import Foundation

protocol URLSessionWebSocketProtocol {
    func webSocketTask(with request: URLRequest) -> URLSessionWebSocketTask
}

extension URLSession: URLSessionWebSocketProtocol { }
