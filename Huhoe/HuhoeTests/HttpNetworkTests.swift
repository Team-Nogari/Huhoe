//
//  HuhoeTests.swift
//  HuhoeTests
//
//  Created by 임지성 on 2022/04/06.
//

import XCTest
import RxSwift
@testable import Huhoe

class HttpNetworkTests: XCTestCase {
    var sut: HttpNetworkProvider!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        sut = HttpNetworkProvider(session: urlSession)
    }

    override func tearDownWithError() throws {
        sut = nil
        disposeBag = DisposeBag()
    }

    func test_success_response() throws {
        guard let url = URL(string: "ht"),
              let response = HTTPURLResponse(
              url: url,
              statusCode: 200,
              httpVersion: nil,
              headerFields: nil) else {
            return
        }
//        let data = readJSONFromFile(fileName: "MockTickerData")  // Success Code
        guard let path = Bundle.main.path(forResource: "MockTickerData", ofType: "json") else {
            return
        }
        guard let jsonString = try? String(contentsOfFile: path) else {
            return
        }
        guard let data = jsonString.data(using: .utf8) else {
            return
        }
    
        MockURLProtocol.responseType = .suceess(response, data)
        
        let tickerNetwork = sut.makeTickerNetwork()
        tickerNetwork.fetchTicker(with: "BTC")
            .subscribe(onNext: {
                XCTAssertNotNil($0)
            })
            .disposed(by: disposeBag)
    }
    
    func test_fail_response() throws {
        guard let url = URL(string: "ht"),
              let response = HTTPURLResponse(
              url: url,
              statusCode: 400,
              httpVersion: nil,
              headerFields: nil) else {
            return
        }
//        let data = readJSONFromFile(fileName: "MockTickerData")  // Success Code
        guard let path = Bundle.main.path(forResource: "MockTickerData", ofType: "json") else {
            return
        }
        guard let jsonString = try? String(contentsOfFile: path) else {
            return
        }
        guard let data = jsonString.data(using: .utf8) else {
            return
        }
    
        MockURLProtocol.responseType = .suceess(response, data)
        
        let tickerNetwork = sut.makeTickerNetwork()
        tickerNetwork.fetchTicker(with: "BTC")
            .subscribe(onNext: {
                XCTAssertNotNil($0)
            })
            .disposed(by: disposeBag)
    }
}

private func readJSONFromFile(fileName: String) -> Data? {
    
//    guard let path = Bundle.main.path(forResource: fileName, ofType: "json"),
//          let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
//        preconditionFailure("Unable to find file named: \(fileName).json")
//    }
    guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
        return nil
    }
    guard let jsonString = try? String(contentsOfFile: path) else {
        return nil
    }
    guard let data = jsonString.data(using: .utf8) else {
        return nil
    }
    
    return data
}
