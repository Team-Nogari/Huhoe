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
    
    // MARK: - Hint Labels
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private var hintLabels: [UILabel]!
    
    @IBOutlet private weak var dateChangeButton: UIButton!
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
        configureDateChangeButton()
        configureLabel()
        configureCollectionView()
        
        bindViewModel()
        bindCollectionView()
        bindTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - Configure View

extension HuhoeMainViewController {
    private func configureDateChangeButton() {
        dateChangeButton.layer.cornerRadius = 6
        dateChangeButton.titleLabel?.font = UIFont.withKOHIBaeum(dynamicFont: .body)
        dateChangeButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
    }
    
    private func configureLabel() {
        titleLabel.font = UIFont.withKOHIBaeum(dynamicFont: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        hintLabels.forEach {
            $0.font = UIFont.withKOHIBaeum(dynamicFont: .callout)
            $0.adjustsFontForContentSizeCategory = true
        }
    }
    
    private func configureCollectionView() {
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        
        coinListCollectionView.keyboardDismissMode = .onDrag
    }
}

// MARK: - View Model Methods

extension HuhoeMainViewController {
    
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
            
        let moneyTextFieldRelay = BehaviorRelay<String?>(value: moneyTextField.text)
        moneyTextField.rx.text
            .orEmpty
            .filter { $0 != "" && $0 != "0" && $0.count <= 10}
            .subscribe(onNext: {
                moneyTextFieldRelay.accept($0)
            })
            .disposed(by: disposeBag)
        
        
        let input = HuhoeMainViewModel.Input(
            changeMoney: moneyTextFieldRelay.asObservable().filterNil(),
            changeDate: textRelay.asObservable()
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
    
    private func bindCollectionView() {
        coinListCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                // TODO: 화면 전환 시 데이터 전달 방법 개선
                let item = self.dataSource?.itemIdentifier(for: $0)
                
                let viewControllerName = "HuhoeDetailViewController"
                let storyboard = UIStoryboard(name: viewControllerName, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerName)
                
                guard let detailViewController = viewController as? HuhoeDetailViewController else {
                    return
                }
                let detailUseCase = CoinDetailUseCase(candlestickRepository: self.viewModel.useCase.candlestickRepository)
                
                let selectedCoin = SelectedCoinInformation(
                    coinSymbol: item?.coinSymbol ?? "",
                    coinCurrentPrice: item?.currentPriceString ?? "",
                    coinInvestmentDate: self.dateChangeButton.titleLabel?.text ?? "",
                    coinInvestmentMoney: self.moneyTextField.text ?? ""
                )
                
                print(selectedCoin)
                    
                detailViewController.viewModel = HuhoeDetailViewModel(
                    selectedCoinInformation: selectedCoin,
                    useCase: detailUseCase
                ) // 코인 가격, 선택 날짜, 투자금액
                
                self.navigationController?.show(detailViewController, sender: nil)
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

// MARK: - Keyboard

extension HuhoeMainViewController {
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
