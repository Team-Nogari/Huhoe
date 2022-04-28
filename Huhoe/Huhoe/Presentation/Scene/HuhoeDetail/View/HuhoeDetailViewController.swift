//
//  HuhoeDetailViewController.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/23.
//

import UIKit
import RxSwift
import RxCocoa

final class HuhoeDetailViewController: UIViewController {
    
    // MARK: - Collection View
    
    private enum Section: String, CaseIterable {
        case today = "오늘"
        case past = "과거"
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
    
    private let tempItem: CoinHistoryItem = CoinHistoryItem(name: "6")
    
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var currentPriceLabel: UILabel!
    @IBOutlet private weak var dateChangeButton: UIButton!
    @IBOutlet private weak var moneyTextField: UITextField!
    @IBOutlet private weak var pastPriceLabel: UILabel!
    @IBOutlet private weak var pastQuantityLabel: UILabel!
    @IBOutlet private weak var coinHistoryCollectionView: UICollectionView!
    
    // MARK: - ViewModel
    var viewModel: HuhoeDetailViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        configureDateChangeButton()
        configureCollectionView()
        
        bindViewModel()
        bindTapGesture()
        
        applySnapShot(tempItems, tempItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
}

// MARK: - View Model Methods

extension HuhoeDetailViewController {
    
    // MARK: - Bind ViewModel
    
    private func bindViewModel() {
        
        // MARK: - Input
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateChangeButton.setTitle(dateFormatter.string(from: Date().yesterday), for: .normal)
        let textRelay = BehaviorRelay<String>(value: dateChangeButton.titleLabel?.text ?? "")
        
        dateChangeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let selectedDate = dateFormatter.date(from: textRelay.value)
                
                let alert = UIAlertController(title: "날짜 선택", message: nil, preferredStyle: .alert)
                
                alert.addDatePicker(date: selectedDate) {
                    let dateString = dateFormatter.string(from: $0)
                    self?.dateChangeButton.setTitle(dateString, for: .normal)
                    textRelay.accept(dateString)
                }
                
                let action = UIAlertAction(title: "선택", style: .default)
                
                alert.addAction(action)
                self?.present(alert, animated: true)
            }).disposed(by: disposeBag)
        
        
        let moneyObservable = moneyTextField.rx.text
            .orEmpty
            .asObservable()
            .filter { $0 != "" }
        
        let input = HuhoeDetailViewModel.Input(
            changeData: textRelay.asObservable(),
            changeMoney: moneyObservable,
            viewDidAppear: Observable.empty()
        )
        
        // MARK: - Output
        
        let output = viewModel?.transform(input)
        
        output?.realTimePrice
            .bind(to: currentPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        output?.realTimePrice
            .subscribe(onNext: { [weak self] in
                let item = CoinHistoryItem(name: $0)
                self?.applySnapShot(self!.tempItems, item)
            })
            .disposed(by: disposeBag)
        
        output?.priceAndQuantity
            .debug()
            .asDriver(onErrorJustReturn: (String(), String()))
            .drive(onNext: { [weak self] price, quantity in
                self?.pastPriceLabel.text = price + " 원"
                self?.pastQuantityLabel.text = quantity 
            })
            .disposed(by: disposeBag)
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
        listConfig.headerMode = .supplementary
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
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, elementKind, indexPath in
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = Section.allCases[indexPath.section].rawValue
            configuration.textProperties.font = .preferredFont(forTextStyle: .title2).bold
            configuration.textProperties.color = .label
            headerView.contentConfiguration = configuration
        }
        
        
        dataSource?.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            } else {
                return nil
            }
        }
    }
    
    private func applySnapShot(_ items: [CoinHistoryItem], _ item: CoinHistoryItem) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, CoinHistoryItem>()
        
        snapShot.appendSections([.today])
        snapShot.appendItems([item], toSection: .today)
        
        snapShot.appendSections([.past])
        snapShot.appendItems(items, toSection: .past)
        
        dataSource?.apply(snapShot)
    }
}

// MARK: - Keyboard

extension HuhoeDetailViewController {
    private func bindTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - Private Extension

private extension UIAlertController {
    func addDatePicker(
        date: Date?,
        action: DatePickerViewController.Action?
    ) {
        let datePicker = DatePickerViewController(date: date, action: action)
        setValue(datePicker, forKey: "contentViewController")
    }
}
