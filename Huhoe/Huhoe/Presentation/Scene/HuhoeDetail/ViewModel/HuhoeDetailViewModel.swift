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
        let changeData: Observable<String>
        let changeMoney: Observable<String>
        let viewDidAppear: Observable<String>
        
        init(changeData: Observable<String>, changeMoney: Observable<String>, viewDidAppear: Observable<String>) {
            self.changeData = changeData
            self.changeMoney = changeMoney
            self.viewDidAppear = viewDidAppear
        }
    }
    
    final class Output {
        let realTimePrice: Observable<String>
        let priceAndQuantity: Observable<PriceAndQuantity>
        let todayCoinInfo: Observable<CoinHistoryItem>
        let symbol: String
        
        init(
            realTimePrice: Observable<String>,
            priceAndQuantity: Observable<PriceAndQuantity>,
            todayCoinInfo: Observable<CoinHistoryItem>,
            symbol: String
        ) {
            self.realTimePrice = realTimePrice
            self.priceAndQuantity = priceAndQuantity
            self.todayCoinInfo = todayCoinInfo
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
        
        return Output(
            realTimePrice: realTimePriceStringObservalbe,
            priceAndQuantity: priceAndQuantityObservable,
            todayCoinInfo: todayCoinInfoObservable,
            symbol: selectedCoinSymbol
        )
    }
}

extension HuhoeDetailViewModel {
    private func makePriceAndQuantityObservable(
        input: Input,
        priceHistoryObservable: Observable<CoinPriceHistory>
    ) -> Observable<PriceAndQuantity> {
        return Observable.combineLatest(input.changeData, input.changeMoney, priceHistoryObservable)
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
                   input.changeData,
                   input.changeMoney,
                   priceHistoryObservable
               )
               .map { realTimePrice, dateString, money, priceHistory -> CoinHistoryItem in
                   if let dateIndex = priceHistory.date.firstIndex(of: dateString.toTimeInterval),
                      let price = priceHistory.price[safe: dateIndex],
                      let money = Double(money)
                   {
                       print("previous Money: ", money)
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
