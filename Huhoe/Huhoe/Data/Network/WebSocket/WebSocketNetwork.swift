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
    
    init(endPoint: String, session: URLSession = .shared) {
        self.endPoint = endPoint
        self.session = session
    }
    
//    func open() -> Observable<Data> { // 열고 보이는 셀들만 요청(send) or 첫 화면서 열고 보이는 셀들 요청 안보이면 선택된 셀의 정보만 요청
//
//    }
}
