//
//  HuhoeDetailViewController.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/23.
//

import UIKit

final class HuhoeDetailViewController: UIViewController {
    
    // MARK: - Collection View
    
    private enum Section {
        case main
    }
        
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, CoinHistoryItem>
    private var dataSource: DiffableDataSource?
    
    struct CoinHistoryItem: Hashable {
        let name: String
    }
    
    private let tempItems: [CoinHistoryItem] = [
        CoinHistoryItem(name: "1"),
        CoinHistoryItem(name: "2"),
        CoinHistoryItem(name: "3"),
        CoinHistoryItem(name: "4"),
        CoinHistoryItem(name: "5")
    ]
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var currentPriceLabel: UILabel!
    @IBOutlet private weak var dateChangeButton: UIButton!
    @IBOutlet private weak var moneyTextField: UITextField!
    @IBOutlet private weak var pastPriceLabel: UILabel!
    @IBOutlet private weak var pastQuantityLabel: UILabel!
    @IBOutlet private weak var coinHistoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        configureDateChangeButton()
        configureCollectionView()
        
        applySnapShot(tempItems)
    }
}

// MARK: - Configure View

extension HuhoeDetailViewController {
    private func configureBackButton() {
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.topItem?.title = String()
    }
    
    private func configureDateChangeButton() {
        dateChangeButton.layer.cornerRadius = 6
    }
    
    private func configureCollectionView() {
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        
        coinHistoryCollectionView.keyboardDismissMode = .onDrag
    }
}

// MARK: - Collecion View Methods

extension HuhoeDetailViewController {
    private func configureCollectionViewLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = false
        coinHistoryCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: listConfig)
    }
    
    private func configureCollectionViewDataSource() {
        typealias CellRegistration = UICollectionView.CellRegistration<CoinHistoryCell, CoinHistoryItem> // 임시 Item
        
        let cellNib = UINib(nibName: CoinHistoryCell.identifier, bundle: nil)
        
        let coinListRegistration = CellRegistration(cellNib: cellNib) { cell, indexPath, item in
            // 임시
        }
        
        dataSource = DiffableDataSource(collectionView: coinHistoryCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: coinListRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func applySnapShot(_ items: [CoinHistoryItem]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, CoinHistoryItem>()
        
        snapShot.appendSections([.main])
        snapShot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapShot)
    }
}
