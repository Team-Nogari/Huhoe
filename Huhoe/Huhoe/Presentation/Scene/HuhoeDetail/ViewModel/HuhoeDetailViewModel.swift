//
//  HuhoeDetailViewModel.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/27.
//

import Foundation
import RxSwift

final class HuhoeDetailViewModel: ViewModel {
    typealias PriceAndQuantity = (price: Double, quantity: Double)
    
    final class Input {
        let changeDate: Observable<String>
        let changeMoney: Observable<String>
        let viewDidAppear: Observable<String>
        let scrollViewDidAppear: Observable<(Double, Double)>
        let didTapScrollView: Observable<(Double, Double)>
        
        init(
            changeDate: Observable<String>,
            changeMoney: Observable<String>,
            viewDidAppear: Observable<String>,
            scrollViewDidAppear: Observable<(Double, Double)>,
            didTapScrollView: Observable<(Double, Double)>
        ) {
            self.changeDate = changeDate
            self.changeMoney = changeMoney
            self.viewDidAppear = viewDidAppear
            self.scrollViewDidAppear = scrollViewDidAppear
            self.didTapScrollView = didTapScrollView
        }
    }
    
    final class Output {
        let realTimePrice: Observable<String>
        let priceAndQuantity: Observable<PriceAndQuantity>
        let currentCoinHistoryInformation: Observable<CoinHistoryItem>
        let todayCoinHistoryInformation: Observable<CoinHistoryItem>
        let pastCoinHistoryInformation: Observable<[CoinHistoryItem]>
        let coinHistory: Observable<CoinPriceHistory>
        let chartInformation: Observable<ChartInformation>
        let chartPriceAndDateViewInformation: Observable<ChartPriceAndDateViewInformation>
        let symbol: String
        
        init(
            realTimePrice: Observable<String>,
            priceAndQuantity: Observable<PriceAndQuantity>,
            currentCoinHistoryInformation: Observable<CoinHistoryItem>,
            todayCoinHistoryInformation: Observable<CoinHistoryItem>,
            pastCoinHistoryInformation: Observable<[CoinHistoryItem]>,
            coinHistory: Observable<CoinPriceHistory>,
            chartInformation: Observable<ChartInformation>,
            chartPriceAndDateViewInformation: Observable<ChartPriceAndDateViewInformation>,
            symbol: String
        ) {
            self.realTimePrice = realTimePrice
            self.priceAndQuantity = priceAndQuantity
            self.currentCoinHistoryInformation = currentCoinHistoryInformation
            self.todayCoinHistoryInformation = todayCoinHistoryInformation
            self.pastCoinHistoryInformation = pastCoinHistoryInformation
            self.coinHistory = coinHistory
            self.chartInformation = chartInformation
            self.chartPriceAndDateViewInformation = chartPriceAndDateViewInformation
            self.symbol = symbol
        }
    }
    
    let useCase: CoinDetailUseCase
    var disposeBag: DisposeBag = DisposeBag()
    
    let selectedCoinInformation: SelectedCoinInformation
    
    init(selectedCoinInformation: SelectedCoinInformation, useCase: CoinDetailUseCase = CoinDetailUseCase()) {
        self.selectedCoinInformation = selectedCoinInformation
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let realTimePriceObservable = useCase.fetchTransactionWebSocket(with: [selectedCoinInformation.coinSymbol + "_KRW"])
            .map {
                $0.price
            }
        let coinPriceHistoryObservable = useCase.fetchCoinPriceHistory(with: selectedCoinInformation.coinSymbol)
        
        let realTimePriceStringObservalbe = realTimePriceObservable
            .map {
                $0.toString(digit: 4) + " 원"
            }
        
        let priceAndQuantityObservable = makePriceAndQuantityObservable(
            input: input,
            priceHistoryObservable: coinPriceHistoryObservable
        )
        
        let currentCoinHistoryInformationObservable = makeCurrentCoinInfoObservable(
            input: input,
            priceHistoryObservable: coinPriceHistoryObservable
        )
        
        let todayCoinHistoryInformationObservable = makeTodayCoinInfoObservable(
            realTimePriceObservable: realTimePriceObservable,
            input: input,
            priceHistoryObservable: coinPriceHistoryObservable
        )
        
        let pastCoinHistoryInformationObservable = makePastCoinInfoObservable(
            input: input,
            quantity: priceAndQuantityObservable,
            priceHistoryObservable: coinPriceHistoryObservable
        )
        
        let chartInformationObservable = makeChartInformationObservable(
            coinPriceHistoryObservable: coinPriceHistoryObservable,
            input: input
        )
        
        let chartPriceAndDateViewInformationObservable = makeChartPriceAndDateViewInformationObservable(
            coinPriceHistoryObservable: coinPriceHistoryObservable,
            input: input
        )
        
        return Output(
            realTimePrice: realTimePriceStringObservalbe,
            priceAndQuantity: priceAndQuantityObservable,
            currentCoinHistoryInformation: currentCoinHistoryInformationObservable,
            todayCoinHistoryInformation: todayCoinHistoryInformationObservable,
            pastCoinHistoryInformation: pastCoinHistoryInformationObservable,
            coinHistory: coinPriceHistoryObservable,
            chartInformation: chartInformationObservable,
            chartPriceAndDateViewInformation: chartPriceAndDateViewInformationObservable,
            symbol: selectedCoinInformation.coinSymbol
        )
    }
}

extension HuhoeDetailViewModel {
    private func makePriceAndQuantityObservable(
        input: Input,
        priceHistoryObservable: Observable<CoinPriceHistory>
    ) -> Observable<PriceAndQuantity> {
        return Observable.combineLatest(
            input.changeDate,
            input.changeMoney,
            priceHistoryObservable
        )
        .map { dateString, money, priceHistory -> PriceAndQuantity in
            if let dateIndex = priceHistory.date.firstIndex(of: HuhoeDateFormatter.shared.toTimeInterval(str: dateString)),
                let price = priceHistory.price[safe: dateIndex],
                let money = Double(money)
            {
                let quantity = money / price
                return (price, quantity)
            }
                
            return (.zero, .zero)
        }
    }
    
    private func makeTodayCoinInfoObservable(
        realTimePriceObservable: Observable<Double>,
        input: Input,
        priceHistoryObservable: Observable<CoinPriceHistory>
    ) -> Observable<CoinHistoryItem> {
        return Observable.combineLatest(
                   realTimePriceObservable,
                   input.changeDate,
                   input.changeMoney,
                   priceHistoryObservable
        )
        .map { realTimePrice, dateString, money, priceHistory -> CoinHistoryItem in
            if let dateIndex = priceHistory.date.firstIndex(of: HuhoeDateFormatter.shared.toTimeInterval(str: dateString)),
                let price = priceHistory.price[safe: dateIndex],
                let money = Double(money)
            {
                let quantity = money / price
                       
                let calculatedPrice = realTimePrice * quantity
                let profitAndLoss = calculatedPrice - money
                let rate = profitAndLoss / money * 100
                       
                return CoinHistoryItem(date: "오늘", calculatedPrice: calculatedPrice, rate: rate, profitAndLoss: profitAndLoss)
            }
                   
            return CoinHistoryItem(date: "", calculatedPrice: 0, rate: 0, profitAndLoss: 0)
        }
    }
    
    private func makePastCoinInfoObservable(
        input: Input,
        quantity: Observable<PriceAndQuantity>,
        priceHistoryObservable: Observable<CoinPriceHistory>
    ) -> Observable<[CoinHistoryItem]> {
        return Observable.combineLatest(
                   input.changeDate,
                   input.changeMoney,
                   quantity,
                   priceHistoryObservable
        )
        .map { dateString, money, quantity, priceHistory -> [CoinHistoryItem] in
            let filteredDates = priceHistory.date
                .filter { $0 > HuhoeDateFormatter.shared.toTimeInterval(str: dateString) }
                .map { HuhoeDateFormatter.shared.toDateString(timeInterval: $0) }
                .filter { $0.hasSuffix(".01") }
            
            var coinHistoryItems = [CoinHistoryItem]()
            
            filteredDates.forEach { filterDate in
                if let dateIndex = priceHistory.date.firstIndex(of: HuhoeDateFormatter.shared.toTimeInterval(str: filterDate)),
                   let price = priceHistory.price[safe: dateIndex],
                   let money = Double(money)
                {
                    let calculatedPrice = price * quantity.quantity
                    let profitAndLoss = calculatedPrice - money
                    let rate = profitAndLoss / money * 100
                    
                    let item = CoinHistoryItem(date: filterDate, calculatedPrice: calculatedPrice, rate: rate, profitAndLoss: profitAndLoss)
                    coinHistoryItems.append(item)
                }
            }
                   
            return coinHistoryItems
        }
    }
    
    private func makeCurrentCoinInfoObservable(
        input: Input,
        priceHistoryObservable: Observable<CoinPriceHistory>
    ) -> Observable<CoinHistoryItem> {
        return Observable.combineLatest(
                   input.changeDate,
                   input.changeMoney,
                   priceHistoryObservable
        )
        .map { dateString, money, priceHistory -> CoinHistoryItem in
            if let dateIndex = priceHistory.date.firstIndex(of: HuhoeDateFormatter.shared.toTimeInterval(str: dateString)),
                let price = priceHistory.price[safe: dateIndex],
                let money = Double(money)
            {
                let quantity = money / price
                       
                let calculatedPrice = self.selectedCoinInformation.coinCurrentPrice.removeComma.toDouble * quantity
                let profitAndLoss = calculatedPrice - money
                let rate = profitAndLoss / money * 100
                       
                return CoinHistoryItem(date: "오늘", calculatedPrice: calculatedPrice, rate: rate, profitAndLoss: profitAndLoss)
            }
                   
            return CoinHistoryItem(date: "", calculatedPrice: 0, rate: 0, profitAndLoss: 0)
        }
    }
    
    private func makeChartInformationObservable(
        coinPriceHistoryObservable: Observable<CoinPriceHistory>,
        input: Input
    ) -> Observable<ChartInformation> {
        return Observable.combineLatest(
            coinPriceHistoryObservable,
            input.scrollViewDidAppear
        )
        .map { coinHistory, contentSizeInformation -> ChartInformation in
            let contentWidth = contentSizeInformation.0
            let contentOffsetX = contentSizeInformation.1
            
            let pointX = contentOffsetX == 0.0 ? 1 : contentOffsetX
            
            let startRate = pointX / contentWidth
            
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
            
            return ChartInformation(
                price: Array(price),
                oldestDate: HuhoeDateFormatter.shared.toDateString(timeInterval: reversedDate[dateRange.max()!]),
                latestDate: HuhoeDateFormatter.shared.toDateString(timeInterval: reversedDate[dateRange.min()!]),
                pointX: pointX
            )
        }
    }
    
    private func makeChartPriceAndDateViewInformationObservable(
        coinPriceHistoryObservable: Observable<CoinPriceHistory>,
        input: Input
    ) -> Observable<ChartPriceAndDateViewInformation> {
        return Observable.combineLatest(
            coinPriceHistoryObservable,
            input.didTapScrollView
        )
        .map { coinHistory, scrollViewInformation -> ChartPriceAndDateViewInformation in
            let contentWidth = scrollViewInformation.0
            let touchPoint = scrollViewInformation.1
            
            let startRate = touchPoint / contentWidth
            let dataIndex = Double(coinHistory.price.count) * startRate
            
            let reversedPrice = Array(coinHistory.price.reversed())
            let reversedDate = Array(coinHistory.date.reversed())
            let price = reversedPrice[Int(dataIndex)].toString()
            let date = HuhoeDateFormatter.shared.toDateString(timeInterval: reversedDate[Int(dataIndex)])
            
            return ChartPriceAndDateViewInformation(
                price: price,
                date: date,
                pointX: touchPoint
            )
        }
    }
}

