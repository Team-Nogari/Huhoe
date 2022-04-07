//
//  Network.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/07.
//

import Foundation
import RxSwift

final class Network<T: Decodable> {
    private let endPoint: String
    private let session: URLSeesionProtocol
    
    init(endPoint: String, session: URLSeesionProtocol = URLSession.shared) {
        self.endPoint = endPoint
        self.session = session
    }
    
    func fetch(_ path: APIPath) -> Observable<[T]> {
        let path = "\(endPoint)/\(path.path)/\(path.orderCurrency)_\(path.paymentCurrency)"
        guard let url = URL(string: path) else {
            return .empty()
        }
        
        return Observable<[T]>.create { [weak self] emmiter in
            let task = self?.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    emmiter.onError(error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    emmiter.onError(error!)
                    return
                }
                
                guard let data = data,
                      let decodedData = try? JSONDecoder().decode([T].self, from: data) else {
                    emmiter.onError(error!)
                    return
                }
                
                emmiter.onNext(decodedData)
                emmiter.onCompleted()
            }
            task?.resume()
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}


