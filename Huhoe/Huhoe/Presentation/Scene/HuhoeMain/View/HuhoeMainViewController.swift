//
//  ViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/06.
//

import UIKit
import RxSwift

class HuhoeMainViewController: UIViewController {
    private enum Section {
        case main
    }

    @IBOutlet weak var coinListCollectionView: UICollectionView!
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, CoinInfo>
    private var dataSource: DiffableDataSource?
    private let use = CoinListUseCase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        use.fetch()
            .subscribe(onNext: { tickers, transactions, coinPriceHistory in
                var cellItems = [CoinInfo]()
                
                for index in tickers.indices {
                    let cellItem = CoinInfo(
                        symbol: tickers[index].coinSymbol,
                        currentPrice: transactions[index].price,
                        priceHistory: coinPriceHistory[index].price,
                        date: coinPriceHistory[index].date
                    )
                    
                    cellItems.append(cellItem)
                }
                
                self.applySnapShot(cellItems)
            })
    }
    
    private func configureCollectionViewLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = false
        coinListCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: listConfig)
    }
    
    private func configureCollectionViewDataSource() {
        typealias CellRegistration = UICollectionView.CellRegistration<CoinListCell, CoinInfo>
        
        let cellNib = UINib(nibName: CoinListCell.identifier, bundle: nil)
        
        let coinListRegistration = CellRegistration(cellNib: cellNib) { cell, indexPath, itemIdentifier in
//            print(cell.reuseIdentifier)
        }
        
        dataSource = DiffableDataSource(collectionView: coinListCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: coinListRegistration, for: indexPath, item: item)
        }
    }
    
    private func applySnapShot(_ items: [CoinInfo]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, CoinInfo>()
        
        snapShot.appendSections([.main])
        snapShot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapShot)
    }
}

