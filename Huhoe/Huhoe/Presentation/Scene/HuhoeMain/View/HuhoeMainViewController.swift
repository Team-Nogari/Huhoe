//
//  ViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/06.
//

import UIKit
import RxSwift

class HuhoeMainViewController: UIViewController {
//
    let a = DefaultTickerRepository()
    let b = DefaultTransactionHistoryRepository()
    let c = DefaultCandlestickRepository()

    lazy var dd = CoinListUseCase(tickerRepository: a, transactionRepository: b, candlestickRepository: c)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let a = DefaultTransactionHistoryRepository()
//        a.fetchTransactionHistory(coinSymbol: ["GALA","ETH"])
//        a.transactionHistory?.subscribe(onNext: {
//            print($0)
//        })
        
//        let b = DefaultCandlestickRepository()
//        b.fetchCandlestick(coinSymbol: ["GALA","ETH"])
//        b.coinPriceHistory?.subscribe(onNext: {
//            print($0)
//        })
        
        dd.fetch()

//        a.tickerRelay
//            .subscribe(onNext: {
//                print($0.count)
//            })
//
//        b.transactionHistoryRelay
//            .subscribe(onNext: {
//                print($0.count)
//            })
//
//        c.coinPriceHistoryRelay
//            .subscribe(onNext: {
//                print($0.count)
//            })
//
        dd.bind()
            .subscribe(onNext: {
                print($0[0].date.last, $0[0].priceHistory.last)
            })
    }
}

