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
        
        let a = DefaultTickerRepository()
        a.fetchTicker(coinSymbol: "ALL")
        a.ticker?.subscribe(onNext: {
            print($0)
        })
    }
}

