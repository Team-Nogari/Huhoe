//
//  ViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/06.
//

import UIKit
import RxSwift

class HuhoeMainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let a = DefaultTransactionHistoryRepository()
//        a.fetchTransactionHistory(coinSymbol: ["GALA","ETH"])
//        a.transactionHistory?.subscribe(onNext: {
//            print($0)
//        })
        
        let b = DefaultCandlestickRepository()
        b.fetchCandlestick(coinSymbol: ["GALA","ETH"])
        b.coinPriceHistory?.subscribe(onNext: {
            print($0)
        })
    }
}

