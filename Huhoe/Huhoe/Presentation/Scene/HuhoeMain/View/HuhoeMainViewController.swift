//
//  ViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/06.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

final class HuhoeMainViewController: UIViewController {
    
    // MARK: - Collection View
    
    private enum Section {
        case main
    }
    
    // MARK: - Hint Labels
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private var hintLabels: [UILabel]!
    @IBOutlet private weak var moneyLabel: UILabel!
    
    @IBOutlet private weak var dateChangeButton: UIButton!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var coinListCollectionView: UICollectionView!
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, CoinInfoItem>
    private var dataSource: DiffableDataSource?
    
    lazy var keyboardView = configureKeyboard()
    
    // MARK: - ViewModel
    
    private let viewModel = HuhoeMainViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Activity Indicator
    
    private let activityIndicator: AnimationView = .init(name: "indicator")
    
    // MARK: - life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDateChangeButton()
        configureLabel()
        configureCollectionView()
        configureActivityIndicator()
        
        bindViewModel()
        bindCollectionView()
        bindTapGesture()
        configureMoreButton()
        
        UserDefaults.standard.set(true, forKey: "isAssistView")
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
            $0.font = UIFont.withKOHIBaeum(dynamicFont: .headline)
            $0.adjustsFontForContentSizeCategory = true
        }
        
        moneyLabel.font = UIFont.withKOHIBaeum(dynamicFont: .body)
        moneyLabel.adjustsFontForContentSizeCategory = true
        moneyLabel.layer.masksToBounds = true
        moneyLabel.layer.cornerRadius = 6
    }
    
    private func configureMoreButton() {
        let showAssistAction = UIAction(
            title: "도움말",
            image: UIImage(systemName: "questionmark.circle")) { wee in
                let assistVC = UIStoryboard(name: "HuhoeAssistViewController", bundle: nil)
                    .instantiateViewController(withIdentifier: "HuhoeAssistViewController")
                self.modalPresentationStyle = .fullScreen
                self.present(assistVC, animated: true)
            }
        let buttonMenu = UIMenu(title: "", children: [showAssistAction])
        moreButton.menu = buttonMenu
    }
    
    private func configureCollectionView() {
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        
        coinListCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func configureActivityIndicator() {
        coinListCollectionView.addSubview(activityIndicator)
        
        let indicatorSize = view.frame.width / 2
        activityIndicator.frame = CGRect(
            x: (view.frame.width * 0.5) - (indicatorSize * 0.5),
            y: (view.frame.height * 0.5 * 0.5) - (indicatorSize * 0.5),
            width: indicatorSize,
            height: indicatorSize
        )
        activityIndicator.contentMode = .scaleAspectFit
        activityIndicator.loopMode = .loop
        activityIndicator.play()
    }
}

// MARK: - View Model Methods

extension HuhoeMainViewController {
    
    // MARK: - Bind ViewModel
    
    private func bindViewModel() {
        
        // MARK: - Input
        
        dateChangeButton.setTitle(HuhoeDateFormatter.shared.toDateString(date: Date().yesterday), for: .normal)
        let dateTextRelay = BehaviorRelay<String>(value: dateChangeButton.titleLabel?.text ?? "")
                
        dateChangeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let selectedDate = HuhoeDateFormatter.shared.toDate(str: dateTextRelay.value)
                
                let alert = UIAlertController(title: "날짜 선택", message: nil, preferredStyle: .alert)
                
                alert.addDatePicker(date: selectedDate) {
                    let dateString = HuhoeDateFormatter.shared.toDateString(date: $0)
                    self?.dateChangeButton.setTitle(dateString, for: .normal)
                    dateTextRelay.accept(dateString)
                }
                
                let action = UIAlertAction(title: "선택", style: .default)
                
                alert.addAction(action)
                self?.present(alert, animated: true)
            }).disposed(by: disposeBag)
            
        
        let moneyLabelTextRelay = BehaviorRelay<String?>(value: moneyLabel.text)
        
        let moneyLabelTextObservable = moneyLabel.rx.observe(String.self, "text")
        
        moneyLabelTextObservable
            .filterNil()
            .filter { $0 != "" && $0 != "0" && $0.count <= 10}
            .subscribe(onNext: {
                moneyLabelTextRelay.accept($0)
            })
            .disposed(by: disposeBag)
        
        let input = HuhoeMainViewModel.Input(
            changeMoney: moneyLabelTextRelay.asObservable().filterNil(),
            changeDate: dateTextRelay.asObservable()
        )
        
        // MARK: - Output
        
        var output = viewModel.transform(input)
        output.coinInfo
            .observe(on: MainScheduler.asyncInstance)
            .retry(1)
            .subscribe(onNext: { [weak self] in
                self?.applySnapShot($0)
            }, onError: { [weak self] _ in
                let alert = UIAlertController(
                    title: "네트워크 에러",
                    message: "코인 정보를 가져올 수 없습니다.",
                    preferredStyle: .alert
                )
                
                let retryAction = UIAlertAction(title: "재시도", style: .default) { _ in
                    guard let self = self else { return }
                    
                    output = self.viewModel.transform(input)
                    self.activityIndicator.play()
                    self.activityIndicator.isHidden = false
                }
                
                alert.addAction(retryAction)
                self?.present(alert, animated: false)
            })
            .disposed(by: disposeBag)
        
        output.coinInfo
            .take(1)
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] _ in
                self?.activityIndicator.stop()
                self?.activityIndicator.isHidden = true
            })
            .disposed(by: disposeBag)
    }
    
    private func bindCollectionView() {
        coinListCollectionView.rx.willBeginDragging
            .subscribe(onNext: { [weak self] in
                self?.keyboardView?.isHidden = true
            })
            .disposed(by: disposeBag)
        
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
                    coinInvestmentMoney: self.moneyLabel.text ?? ""
                )
                
                detailViewController.viewModel = HuhoeDetailViewModel(
                    selectedCoinInformation: selectedCoin,
                    useCase: detailUseCase
                )
                
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
        listConfig.backgroundColor = UIColor(named: "BackgroundColor")
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
            .subscribe(onNext: { [weak self] eee in
                print(eee)
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
    
    private func configureKeyboard() -> UIView? {
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
            keyboardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        
        return keyboardView
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
