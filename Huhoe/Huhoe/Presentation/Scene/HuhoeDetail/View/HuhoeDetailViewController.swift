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
   
    // MARK: - Hint Labels
    
    @IBOutlet private var hintLabels: [UILabel]!
    @IBOutlet private weak var collectionViewHintLabel: UILabel!
        
    // MARK: - IBOutlet
    
    @IBOutlet private weak var currentPriceLabel: UILabel!
    @IBOutlet private weak var dateChangeButton: UIButton!
    @IBOutlet private weak var moneyLabel: UILabel!
    @IBOutlet private weak var pastPriceLabel: UILabel!
    @IBOutlet private weak var pastQuantityLabel: UILabel!
    @IBOutlet private weak var coinHistoryCollectionView: UICollectionView!
    @IBOutlet private weak var chartScrollView: ChartScrollView!
    @IBOutlet private weak var chartImageView: ChartImageView!
    @IBOutlet private weak var chartOldDateLabel: UILabel!
    @IBOutlet private weak var chartLatestDateLabel: UILabel!
    
    // MARK: - Keyboard
    
    lazy var keyboardView = configureKeyboard()
    
    // MARK: - ViewModel
    
    var viewModel: HuhoeDetailViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle()
        configureBackButton()
        configureLabel()
        configureDateChangeButton()
        configureCollectionView()
        configureChartView()
        
        bindViewModel()
        bindTapGesture()
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
        
        guard let viewModel = viewModel else {
            return
        }
        
        keyboardView?.input = viewModel.selectedCoinInformation.coinInvestmentMoney.removeComma.replacingOccurrences(of: " 원", with: "")
        currentPriceLabel.text = viewModel.selectedCoinInformation.coinCurrentPrice + " 원"
        
        dateChangeButton.setTitle(viewModel.selectedCoinInformation.coinInvestmentDate, for: .normal)
        let dateTextRelay = BehaviorRelay<String>(value: dateChangeButton.titleLabel?.text ?? "")
        
        var datePickerMinimumDate: Date?
        
        dateChangeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let selectedDate = HuhoeDateFormatter.shared.toDate(str: dateTextRelay.value)
                
                let alert = UIAlertController(title: "날짜 선택", message: nil, preferredStyle: .alert)
                
                alert.addDatePicker(date: selectedDate, minimumDate: datePickerMinimumDate) {
                    let dateString = HuhoeDateFormatter.shared.toDateString(date: $0)
                    self?.dateChangeButton.setTitle(dateString, for: .normal)
                    dateTextRelay.accept(dateString)
                }
                
                let action = UIAlertAction(title: "선택", style: .default)
                
                alert.addAction(action)
                self?.present(alert, animated: true)
            }).disposed(by: disposeBag)
        
        keyboardView?.inputRelay
            .asDriver()
            .drive(onNext: { [weak self] moneyText in
                self?.moneyLabel.text = moneyText.toString() + " 원"
            })
            .disposed(by: disposeBag)
        
        let moneyLabelTextRelay = BehaviorRelay<String?>(value: moneyLabel.text)
        let moneyLabelTextObservable = moneyLabel.rx.observe(String.self, "text")
        
        moneyLabelTextObservable
            .filterNil()
            .map { $0.removeComma.replacingOccurrences(of: " 원", with: "") }
            .filter { $0 != "" && $0 != "0" && $0.count <= 10}
            .subscribe(onNext: {
                moneyLabelTextRelay.accept($0)
            })
            .disposed(by: disposeBag)
        
        let scrollViewContentSize = chartScrollView.rx.observe(CGSize.self, "contentSize")
        
        let scrollViewDidAppear = Observable.combineLatest(scrollViewContentSize, chartScrollView.rx.contentOffset)
            .skip(1)
            .map { contentSize, offset -> (Double, Double) in
                guard let contentWidth = contentSize?.width else {
                    return (0, Double(offset.x))
                }
                
                return (Double(contentWidth), Double(offset.x))
            }
        
        let didTapScrollView = Observable.combineLatest(scrollViewContentSize, chartScrollView.touchPointRelay) 
            .map { contentSize, touchPointX -> (Double, Double) in
                guard let contentWidth = contentSize?.width else {
                    return (0, touchPointX)
                }
                
                return (Double(contentWidth), touchPointX)
            }
        
        let input = HuhoeDetailViewModel.Input(
            changeDate: dateTextRelay.asObservable(),
            changeMoney: moneyLabelTextRelay.asObservable().filterNil(),
            viewDidAppear: Observable.empty(),
            scrollViewDidAppear: scrollViewDidAppear,
            didTapScrollView: didTapScrollView.asObservable()
        )
        
        // MARK: - Output
        
        let output = viewModel.transform(input)
        
        output.realTimePrice
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: currentPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.priceAndQuantity
            .asDriver(onErrorJustReturn: (Double.zero, Double.zero))
            .drive(onNext: { [weak self] price, quantity in
                self?.pastPriceLabel.text = price.toString(digit: 4) + " 원"
                
                var quntity = String(format: "%.4f", quantity)
                if  quntity.count > 8 {
                    quntity = quntity.removedSuffix(from: 5)
                }
                self?.pastQuantityLabel.text = quntity + (" \(output.symbol)")
            })
            .disposed(by: disposeBag)
        
        Observable.zip(output.currentCoinHistoryInformation, output.pastCoinHistoryInformation)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] current, past in
                self?.applySnapShot(current, past)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(output.todayCoinHistoryInformation, output.pastCoinHistoryInformation)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] today, past in
                self?.applySnapShot(today, past)
            })
            .disposed(by: disposeBag)
        
        output.coinHistory
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] coinHistory in
                let xUnit: Double = UIScreen.main.bounds.width / CGFloat(30)
                let minimumDate = HuhoeDateFormatter.shared.toTimeInterval(str: coinHistory.date.first ?? "0")
                self?.chartImageView.getSize(numberOfData: coinHistory.price.count, xUnit: xUnit.rounded(.down))
                datePickerMinimumDate = Date(timeIntervalSince1970: minimumDate)
            })
            .disposed(by: disposeBag)
        
        output.chartInformation
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] chartInformation in
                self?.chartOldDateLabel.text = chartInformation.oldestDate
                self?.chartLatestDateLabel.text = chartInformation.latestDate
                
                self?.chartImageView.drawChart(
                    price: chartInformation.price,
                    offsetX: chartInformation.pointX
                )
            })
            .disposed(by: disposeBag)
        
        output.chartPriceAndDateViewInformation
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] chartPriceAndDateViewInformation in
                let price = chartPriceAndDateViewInformation.price
                let date = chartPriceAndDateViewInformation.date
                let pointX = chartPriceAndDateViewInformation.pointX
                
                self?.chartScrollView.moveFloatingPriceAndDateView(offsetX: pointX, price: price, date: date)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Configure

private extension HuhoeDetailViewController {
    func configureTitle() {
        let titleView: UILabel = {
            let label = UILabel()
            label.attributedText = NSMutableAttributedString()
                .text(viewModel?.selectedCoinInformation.coinSymbol.localized ?? "")
                .text(" ")
                .colorText(viewModel?.selectedCoinInformation.coinSymbol ?? "", color: .gray)
            
            return label
        }()
        
        navigationItem.titleView = titleView
    }
    
    func configureBackButton() {
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.topItem?.title = String()
    }
    
    func configureDateChangeButton() {
        dateChangeButton.titleLabel?.font = UIFont.withKOHIBaeum(dynamicFont: .body)
        dateChangeButton.titleLabel?.adjustsFontForContentSizeCategory = true
        dateChangeButton.layer.cornerRadius = 6
    }
    
    func configureCollectionView() {
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        
        coinHistoryCollectionView.keyboardDismissMode = .onDrag
    }
    
    func configureLabel() {
        currentPriceLabel.font = UIFont.withKOHIBaeum(dynamicFont: .title1)
        currentPriceLabel.adjustsFontForContentSizeCategory = true
        
        chartOldDateLabel.font = UIFont.withKOHIBaeum(dynamicFont: .callout)
        chartOldDateLabel.adjustsFontForContentSizeCategory = true
        
        chartLatestDateLabel.font = UIFont.withKOHIBaeum(dynamicFont: .callout)
        chartLatestDateLabel.adjustsFontForContentSizeCategory = true
        
        pastPriceLabel.font = UIFont.withKOHIBaeum(dynamicFont: .subhead)
        pastPriceLabel.adjustsFontForContentSizeCategory = true
        
        pastQuantityLabel.font = UIFont.withKOHIBaeum(dynamicFont: .subhead)
        pastQuantityLabel.adjustsFontSizeToFitWidth = true
        pastQuantityLabel.adjustsFontForContentSizeCategory = true
        
        hintLabels.forEach {
            $0.font = UIFont.withKOHIBaeum(dynamicFont: .caption1)
            $0.adjustsFontForContentSizeCategory = true
        }
        
        collectionViewHintLabel.font = UIFont.withKOHIBaeum(dynamicFont: .headline)
        collectionViewHintLabel.adjustsFontForContentSizeCategory = true
        
        moneyLabel.font = UIFont.withKOHIBaeum(dynamicFont: .body)
        moneyLabel.adjustsFontForContentSizeCategory = true
        moneyLabel.layer.masksToBounds = true
        moneyLabel.layer.cornerRadius = 6
    }
    
    func configureChartView() {
        UIView.animate(withDuration: 0.0, animations: {
            self.chartScrollView.transform = CGAffineTransform(rotationAngle: .pi)
            self.chartImageView.transform = CGAffineTransform(rotationAngle: .pi)
        })
    }
}

// MARK: - Collecion View Methods

extension HuhoeDetailViewController {
    private func configureCollectionViewLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = false
        listConfig.backgroundColor = UIColor(named: "BackgroundColor")

        coinHistoryCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: listConfig)
    }
    
    private func configureCollectionViewDataSource() {
        typealias CellRegistration = UICollectionView.CellRegistration<CoinHistoryCell, CoinHistoryItem>
        
        let cellNib = UINib(nibName: CoinHistoryCell.identifier, bundle: nil)
        
        let coinListRegistration = CellRegistration(cellNib: cellNib) { cell, indexPath, item in
            cell.configureCell(item: item)
        }
        
        dataSource = DiffableDataSource(collectionView: coinHistoryCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: coinListRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func applySnapShot(_ today: CoinHistoryItem, _ past: [CoinHistoryItem]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, CoinHistoryItem>()
        
        snapShot.appendSections([.today])
        snapShot.appendItems([today], toSection: .today)
        
        snapShot.appendSections([.past])
        snapShot.appendItems(past, toSection: .past)
        
        dataSource?.apply(snapShot)
    }
}

// MARK: - Keyboard

private extension HuhoeDetailViewController {
    func bindTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.keyboardView?.isHidden = true
            })
            .disposed(by: disposeBag)
        
        let moneyLabelTapGesture = UITapGestureRecognizer(target: self, action: nil)
        moneyLabel.addGestureRecognizer(moneyLabelTapGesture)
        
        moneyLabelTapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.keyboardView?.isHidden = false
            })
            .disposed(by: disposeBag)
    }
    
    func configureKeyboard() -> HuhoeKeyboardView? {
        guard let keyboardView = Bundle.main.loadNibNamed("HuhoeKeyboardView", owner: nil, options: nil)?.first as? HuhoeKeyboardView else {
            return nil
        }
        let tapGesture = UITapGestureRecognizer(target: nil, action: nil)
        tapGesture.cancelsTouchesInView = false
        keyboardView.addGestureRecognizer(tapGesture)
        
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(keyboardView)
        keyboardView.isHidden = true
        
        NSLayoutConstraint.activate([
            keyboardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            keyboardView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            keyboardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.375)
        ])
        
        return keyboardView
    }
}


// MARK: - Private Extension

private extension UIAlertController {
    func addDatePicker(
        date: Date?,
        minimumDate: Date?,
        action: DatePickerViewController.Action?
    ) {
        let datePicker = DatePickerViewController(date: date, minimumDate: minimumDate, action: action)
        setValue(datePicker, forKey: "contentViewController")
    }
}
