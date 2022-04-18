//
//  ViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/06.
//

import UIKit
import RxSwift
import RxCocoa

final class HuhoeMainViewController: UIViewController {
    
    // MARK: - Collection View
    
    private enum Section {
        case main
    }

    @IBOutlet private weak var coinListCollectionView: UICollectionView!
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, CoinInfoItem>
    private var dataSource: DiffableDataSource?
    
    // MARK: - ViewModel
    
    private let viewModel = HuhoeMainViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Text Field
    
    @IBOutlet private weak var moneyTextField: UITextField!
    
    // MARK: - life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        
        bindViewModel()
    }
}

// MARK: - View Model Methods

extension HuhoeMainViewController {
    
    // MARK: - Bind ViewModel
    
    private func bindViewModel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH"
        let dateString = dateFormatter.string(from: Date())
        
        // MARK: - Input
        
        let input = HuhoeMainViewModel.Input(
            viewWillAppear: Observable.empty(),
            changeMoney: moneyTextField.rx.text.orEmpty.map {
                $0.onlyNumber
            }.asObservable(),
            changeDate: Observable.just(dateString)
        )
        
        // MARK: - Output
        
        let output = viewModel.transform(input)
        output.coinInfo
            .retry(5)
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] in
                self?.applySnapShot($0)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Collection View Methods

extension HuhoeMainViewController {
    private func configureCollectionViewLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = false
        coinListCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: listConfig)
    }
    
    private func configureCollectionViewDataSource() {
        typealias CellRegistration = UICollectionView.CellRegistration<CoinListCell, CoinInfoItem>
        
        let cellNib = UINib(nibName: CoinListCell.identifier, bundle: nil)
        
        let coinListRegistration = CellRegistration(cellNib: cellNib) { cell, indexPath, item in
            cell.configureCell(item: item)
        }
        
        dataSource = DiffableDataSource(collectionView: coinListCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: coinListRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func applySnapShot(_ items: [CoinInfoItem]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, CoinInfoItem>()
        
        snapShot.appendSections([.main])
        snapShot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapShot)
    }
}

// MARK: - Collection View Methods

private extension String {
    var onlyNumber: String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
}
