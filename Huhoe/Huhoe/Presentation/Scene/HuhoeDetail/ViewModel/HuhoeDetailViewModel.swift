//
//  HuhoeDetailViewModel.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/27.
//

import Foundation
import RxSwift

final class HuhoeDetailViewModel: ViewModel {
    typealias PriceAndQuantity = (price: String, quantity: String)
    
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
        
        let todayCoinInfoObservable = Observable.combineLatest(realTimePriceObservable, priceAndQuantityObservable, input.changeMoney)
            .map { realTimePrice, pastPriceAndQuantity, money -> CoinHistoryItem in
                let calculatedPrice = realTimePrice * pastPriceAndQuantity.quantity.removeComma.toDouble
                let profitAndLoss = calculatedPrice - money.toDouble
                let rate = profitAndLoss / money.toDouble * 100
                
                return CoinHistoryItem(date: "오늘", calculatedPrice: calculatedPrice, rate: rate, profitAndLoss: profitAndLoss)
            }
        
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
            .map { [weak self] dateString, money, priceHistory -> PriceAndQuantity in
                if let dateIndex = priceHistory.date.firstIndex(of: dateString.toTimeInterval),
                   let price = priceHistory.price[safe: dateIndex],
                   let money = Double(money)
                {
                    let quantity = money / price
                    
                    return (price.toString(), quantity.toString(digit: 4))
                }
                
                return (String(), String())
            }
    }
}
