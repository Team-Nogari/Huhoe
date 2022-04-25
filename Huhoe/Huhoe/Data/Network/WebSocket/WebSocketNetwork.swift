//
//  WebSocketNetwork.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/25.
//

import Foundation
import RxSwift

final class WebSocketNetwork {
    private let endPoint: String
    private let session: URLSessionWebSocketProtocol
    
    var subject = PublishSubject<Data>()
    
    init(endPoint: String = "wss://pubwss.bithumb.com/pub/ws", session: URLSession = .shared) {
        self.endPoint = endPoint
        self.session = session
    }
    
    func connect() { // 열고 보이는 셀들만 요청(send) or 첫 화면서 열고 보이는 셀들 요청 안보이면 선택된 셀의 정보만 요청
        guard let url = URL(string: endPoint) else {
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let task = session.webSocketTask(with: urlRequest)
        
        task.resume()

        listen(with: task) // Test
        
        let message = #"{"type":"transaction", "symbols":["BTC_KRW"]}"# // Test

        let dd = message.data(using: .utf8) ?? Data() // Test

        task.send(.data(dd)) { err in // Test
            if let err = err {
                print(err)
            }
        }
    }
    
//    func send(path: APIPath, with symbol: [String]) {
//
//    }
    
    
    func listen(with webSocketTask: URLSessionWebSocketTask) {
        DispatchQueue.global().async {
            webSocketTask.receive { [weak self] result in
                switch result {
                case .success(let message):
                    print(message)
                    
                    switch message {
                    case .data(let data):
                        self?.subject.onNext(data)
                    case .string(let str):
                        self?.subject.onNext(str.data(using: .utf8) ?? Data())
                    default:
                        break
                    }
                    
                case .failure(let error):
                    //                    print(error)
                    self?.subject.onError(error)
                }
                
                self?.listen(with: webSocketTask)
            }
        }
    }
}
