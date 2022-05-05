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
//    typealias ChartInformation = (coinPriceHistory: [Double], offsetX: Double)
//    typealias ChartScrollViewInformation = (contentWidth: Double, offsetX: Double)
    
    final class Input {
        let changeDate: Observable<String>
        let changeMoney: Observable<String>
        let viewDidAppear: Observable<String>
        let scrollViewDidAppear: Observable<(Double, Double)>
        
        init(
            changeDate: Observable<String>,
            changeMoney: Observable<String>,
            viewDidAppear: Observable<String>,
            scrollViewDidAppear: Observable<(Double, Double)>
        ) {
            self.changeDate = changeDate
            self.changeMoney = changeMoney
            self.viewDidAppear = viewDidAppear
            self.scrollViewDidAppear = scrollViewDidAppear
        }
    }
    
    final class Output {
        let realTimePrice: Observable<String>
        let priceAndQuantity: Observable<PriceAndQuantity>
        let todayCoinInfo: Observable<CoinHistoryItem>
        let coinHistory: Observable<CoinPriceHistory>
        let chartInformation: Observable<ChartInformation>
        let symbol: String
        
        init(
            realTimePrice: Observable<String>,
            priceAndQuantity: Observable<PriceAndQuantity>,
            todayCoinInfo: Observable<CoinHistoryItem>,
            coinHistory: Observable<CoinPriceHistory>,
            chartInformation: Observable<ChartInformation>,
            symbol: String
        ) {
            self.realTimePrice = realTimePrice
            self.priceAndQuantity = priceAndQuantity
            self.todayCoinInfo = todayCoinInfo
            self.coinHistory = coinHistory
            self.chartInformation = chartInformation
            self.symbol = symbol
        }
    }
    
    let useCase: CoinDetailUseCase
    var disposeBag: DisposeBag = DisposeBag()
    
    private let selectedCoinSymbol: String
    
    init(selectedCoinSymbol: String, useCase: CoinDetailUseCase = CoinDetailUseCase()) {
        self.selectedCoinSymbol = selectedCoinSymbol
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let realTimePriceObservable = useCase.fetchTransactionWebSocket(with: [selectedCoinSymbol + "_KRW"])
            .map {
                $0.price
            }
        let coinPriceHistoryObservable = useCase.fetchCoinPriceHistory(with: selectedCoinSymbol)
        
        let realTimePriceStringObservalbe = realTimePriceObservable
            .map {
                $0.toString(digit: 4) + " 원"
            }
        
        let priceAndQuantityObservable = makePriceAndQuantityObservable(
            input: input,
            priceHistoryObservable: coinPriceHistoryObservable
        )
        
        let todayCoinInfoObservable = makeTodayCoinInfoObservable(
            realTimePriceObservable: realTimePriceObservable,
            input: input,
            priceHistoryObservable: coinPriceHistoryObservable
        )
        
        let chartInformationObservable = Observable.combineLatest(
            coinPriceHistoryObservable,
            input.scrollViewDidAppear
        ).map { coinHistory, contentSizeInformation -> ChartInformation in
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
                oldestDate: reversedDate[dateRange.max()!].toDateString(),
                latestDate: reversedDate[dateRange.min()!].toDateString(),
                pointX: pointX
            )
        }
        
        return Output(
            realTimePrice: realTimePriceStringObservalbe,
            priceAndQuantity: priceAndQuantityObservable,
            todayCoinInfo: todayCoinInfoObservable,
            coinHistory: coinPriceHistoryObservable,
            chartInformation: chartInformationObservable,
            symbol: selectedCoinSymbol
        )
    }
}

extension HuhoeDetailViewModel {
    private func makePriceAndQuantityObservable(
        input: Input,
        priceHistoryObservable: Observable<CoinPriceHistory>
    ) -> Observable<PriceAndQuantity> {
        return Observable.combineLatest(input.changeDate, input.changeMoney, priceHistoryObservable)
            .map { dateString, money, priceHistory -> PriceAndQuantity in
                if let dateIndex = priceHistory.date.firstIndex(of: dateString.toTimeInterval),
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
                   if let dateIndex = priceHistory.date.firstIndex(of: dateString.toTimeInterval),
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
}
