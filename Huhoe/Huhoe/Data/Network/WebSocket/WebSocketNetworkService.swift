//
//  WebSocketNetwork.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/25.
//

import Foundation
import RxSwift

final class WebSocketNetworkService {
    private let endPoint: String
    private let session: URLSessionWebSocketProtocol
    private var task: URLSessionWebSocketTask?
    
    let webSocketDataSubject = PublishSubject<Data>() // 구독시 동일한 데이터 공유를 위해 서브젝트 사용
    
    init(endPoint: String = "wss://pubwss.bithumb.com/pub/ws", session: URLSession = .shared) {
        self.endPoint = endPoint
        self.session = session
    }
    
    func connect(to path: String, with symbols: [String]) { // 열고 보이는 셀들만 요청(send) or 첫 화면서 열고 보이는 셀들 요청 안보이면 선택된 셀의 정보만 요청
        guard let url = URL(string: endPoint) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        
        task = session.webSocketTask(with: urlRequest)
        task?.resume()
        
        send(to: path, with: symbols)
        
        listen()
    }
    
    private func send(to path: String, with symbols: [String]) {
        let symbolsTransformed = symbols.map { "\"\($0)\"" }.joined(separator: ", ")
        let message = #"{"type":"\#(path)", "symbols":[\#(symbolsTransformed)]}"#
        guard let data = message.data(using: .utf8) else {
            return
        }
        
        task?.send(.data(data)) { err in
            if let err = err {
                print(err)
            }
        }
    }
    
    private func listen() {
        self.task?.receive { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let str):
                self?.webSocketDataSubject.onNext(str.data(using: .utf8) ?? Data())
            default:
                break
            }
            
            self?.listen()
        }
    }
}
