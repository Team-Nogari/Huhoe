//
//  ViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/06.
//

import UIKit
import RxSwift
import RxCocoa

class HuhoeMainViewController: UIViewController {
    private enum Section {
        case main
    }

    @IBOutlet weak var coinListCollectionView: UICollectionView!
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, CoinInfoItem>
    private var dataSource: DiffableDataSource?
    
    private let viewModel = HuhoeMainViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        
        let date: Date = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dateString = dateFormatter.string(from: date)
        
        let input = HuhoeMainViewModel.Input(
            viewWillAppear: Observable.empty(),
            changeMoney: Observable.just("10000"),
            changeDate: Observable.just(dateString)
        )
        
        let output = viewModel.transform(input)
        output.coinInfo
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] in
                self?.applySnapShot($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureCollectionViewLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = false
        coinListCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: listConfig)
    }
    
    private func configureCollectionViewDataSource() {
        typealias CellRegistration = UICollectionView.CellRegistration<CoinListCell, CoinInfoItem>
        
        let cellNib = UINib(nibName: CoinListCell.identifier, bundle: nil)
        
        let coinListRegistration = CellRegistration(cellNib: cellNib) { cell, indexPath, itemIdentifier in
//            print(cell.reuseIdentifier)
        }
        
        dataSource = DiffableDataSource(collectionView: coinListCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: coinListRegistration, for: indexPath, item: item)
        }
    }
    
    private func applySnapShot(_ items: [CoinInfoItem]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, CoinInfoItem>()
        
        snapShot.appendSections([.main])
        snapShot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapShot)
    }
}

