//
//  Network.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation
import RxSwift

final class Network {
    private let endPoint: String
    private let session: URLSeesionProtocol
    
    init(endPoint: String, session: URLSeesionProtocol = URLSession.shared) {
        self.endPoint = endPoint
        self.session = session
    }
    
    func fetch(_ path: APIPath, with coinSymbol: String) -> Observable<Data> {
        let path = "\(endPoint)/\(path.path)/\(coinSymbol)_\(path.paymentCurrency)"
        print(path)
        guard let url = URL(string: path) else {
            return .empty()
        }
        
        return Observable<Data>.create { [weak self] emmiter in
            let task = self?.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    emmiter.onError(NetworkError.unknownError(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    emmiter.onError(NetworkError.invalidResponse)
                    return
                }
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    emmiter.onError(NetworkError.abnormalStatusCode(httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    emmiter.onError(NetworkError.invalidResponse)
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


