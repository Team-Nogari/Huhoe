//
//  MockURLProtocol.swift
//  HuhoeTests
//
//  Created by 임지성 on 2022/05/27.
//

import Foundation
@testable import Huhoe

final class MockURLProtocol: URLProtocol {
    enum ResponseType {
        case suceess(HTTPURLResponse, Data)
        case failure(HttpNetworkError)
    }
    
    static var responseType: ResponseType!
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        switch MockURLProtocol.responseType {
        case .suceess(let response, let data):
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        default:
            break
        }
    }
    
    override func stopLoading() {
        task?.cancel()
    }
}
