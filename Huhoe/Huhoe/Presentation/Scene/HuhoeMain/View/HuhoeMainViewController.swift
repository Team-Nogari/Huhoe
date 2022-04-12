//
//  ViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/06.
//

import UIKit
import RxSwift

class HuhoeMainViewController: UIViewController {

    @IBOutlet weak var CoinListCollectionView: UICollectionView!
    
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
        
        let cellNib: UINib = UINib(nibName: "CoinListCell", bundle: nil)
        CoinListCollectionView.register(cellNib, forCellWithReuseIdentifier: "CoinListCell")
        CoinListCollectionView.dataSource = self
    }
}

extension HuhoeMainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinListCell", for: indexPath)
        
        return cell
    }
}

