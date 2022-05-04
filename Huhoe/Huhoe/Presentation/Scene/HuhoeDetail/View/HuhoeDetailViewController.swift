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
    
    private let tempItems: [CoinHistoryItem] = [
        CoinHistoryItem(date: "1", calculatedPrice: 1, rate: 1, profitAndLoss: 1),
        CoinHistoryItem(date: "2", calculatedPrice: 2, rate: 2, profitAndLoss: 2),
        CoinHistoryItem(date: "3", calculatedPrice: 3, rate: 3, profitAndLoss: 3),
        CoinHistoryItem(date: "3", calculatedPrice: 3, rate: 3, profitAndLoss: 4),
        CoinHistoryItem(date: "3", calculatedPrice: 3, rate: 3, profitAndLoss: 5),
        CoinHistoryItem(date: "3", calculatedPrice: 3, rate: 3, profitAndLoss: 6),
        CoinHistoryItem(date: "3", calculatedPrice: 3, rate: 3, profitAndLoss: 7)
    ]
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var currentPriceLabel: UILabel!
    @IBOutlet private weak var dateChangeButton: UIButton!
    @IBOutlet private weak var moneyTextField: UITextField!
    @IBOutlet private weak var pastPriceLabel: UILabel!
    @IBOutlet private weak var pastQuantityLabel: UILabel!
    @IBOutlet private weak var coinHistoryCollectionView: UICollectionView!
    @IBOutlet private weak var chartScrollView: ChartScrollView!
    @IBOutlet private weak var chartImageView: ChartImageView!
    
    @IBOutlet private weak var chartOldDateLabel: UILabel!
    @IBOutlet private weak var chartLatestDateLabel: UILabel!
    // MARK: - ViewModel
    var viewModel: HuhoeDetailViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        let input = HuhoeDetailViewModel.Input(
            changeDate: textRelay.asObservable(),
            changeMoney: moneyTextFieldRelay.asObservable().filterNil(),
            viewDidAppear: Observable.empty()
        )
        
        // MARK: - Output
        
        guard let output = viewModel?.transform(input) else {
            return
        }
        
        output.realTimePrice
            .bind(to: currentPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.priceAndQuantity
            .asDriver(onErrorJustReturn: (Double.zero, Double.zero))
            .drive(onNext: { [weak self] price, quantity in
                self?.pastPriceLabel.text = price.toString(digit: 4) + " 원"
                self?.pastQuantityLabel.text = String(format: "%.4f", quantity) + (" \(output.symbol)")
            })
            .disposed(by: disposeBag)
        
        output.todayCoinInfo
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                self?.applySnapShot(self!.tempItems, $0) // 강제 언래핑 수정
            })
            .disposed(by: disposeBag)
        
        output.coinHistory
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] coinHistory in
                let xUnit: Double = UIScreen.main.bounds.width / CGFloat(30)
                self?.chartImageView.getSize(numberOfData: coinHistory.price.count, xUnit: xUnit)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(output.coinHistory, chartScrollView.rx.contentOffset)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] coinHistory, offset in
                let pointX = offset.x == 0.0 ? 1 : offset.x
                
                let startRate = pointX / self!.chartScrollView.contentSize.width
                let dataFirstIndex = Double(coinHistory.price.count) * startRate
                
                var dateRange: ClosedRange = 0...1
                
                if Int(dataFirstIndex.rounded()) + 29 >= coinHistory.price.count {
                    dateRange = Int(dataFirstIndex.rounded())...coinHistory.price.count - 1
                } else {
                    dateRange = Int(dataFirstIndex.rounded())...Int(dataFirstIndex.rounded()) + 29
                }
                
                let reversedPrice = Array(coinHistory.price.reversed())
                let reversedDate = Array(coinHistory.date.reversed())
                let price = reversedPrice[dateRange]
            
                self?.chartOldDateLabel.text = reversedDate[dateRange.max()!].toDateString()
                self?.chartLatestDateLabel.text = reversedDate[dateRange.min()!].toDateString()
                
                self?.chartImageView.drawChart(price: Array(price), offsetX: offset.x)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(output.coinHistory, chartScrollView.touchPointRelay)
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] coinHistory, pointX in
                let startRate = pointX / self!.chartScrollView.contentSize.width
                let dataIndex = Double(coinHistory.price.count) * startRate
                
                let reversedPrice = Array(coinHistory.price.reversed())
                let reversedDate = Array(coinHistory.date.reversed())
                let price = reversedPrice[Int(dataIndex)]
                let date = reversedDate[Int(dataIndex)].toDateString()
                
                self?.chartScrollView.moveFloatingPriceAndDateView(offsetX: pointX, price: price.toString(), date: date)
                print("price", price, "date", date)
            })
            .disposed(by: disposeBag)
    }
}

private extension Double {
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let date = Date(timeIntervalSince1970: self)
        
        return formatter.string(from: date)
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
    
    private func configureLabel() {
        currentPriceLabel.font = .preferredFont(forTextStyle: .title1).bold
    }
    
    private func configureChartView() {
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
