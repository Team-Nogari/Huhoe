//
//  Network.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation
import RxSwift

final class HttpNetwork {
    private let endPoint: String
    private let session: URLSessionProtocol
    
    init(endPoint: String, session: URLSessionProtocol = URLSession.shared) {
        self.endPoint = endPoint
        self.session = session
    }
    
    func fetch(_ path: APIPath, with coinSymbol: String) -> Observable<Data> {
        let path = "\(endPoint)/\(path.path)/\(coinSymbol)_\(path.paymentCurrency)"
        print(path)
        guard let url = URL(string: path) else {
            return .empty()
        }
        
        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        
        return Observable<Data>.create { [weak self] emmiter in
            let task = self?.session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    emmiter.onError(HttpNetworkError.unknownError(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    emmiter.onError(HttpNetworkError.invalidResponse)
                    return
                }
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    emmiter.onError(HttpNetworkError.abnormalStatusCode(httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    emmiter.onError(HttpNetworkError.invalidResponse)
                    return
                }
                
                emmiter.onNext(data)
                emmiter.onCompleted()
            }
            task?.resume()
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}


