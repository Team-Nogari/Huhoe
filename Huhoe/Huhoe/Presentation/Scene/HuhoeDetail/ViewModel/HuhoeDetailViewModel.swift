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
        
        init(
            realTimePrice: Observable<String>,
            priceAndQuantity: Observable<PriceAndQuantity>
        ) {
            self.realTimePrice = realTimePrice
            self.priceAndQuantity = priceAndQuantity
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
        
        return Output(
            realTimePrice: realTimePriceStringObservalbe,
            priceAndQuantity: priceAndQuantityObservable
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
                   let money = Double(money),
                   let symbol = self?.selectedCoinSymbol
                {
                    let quantity = money / price
                    
                    return (price.toString(), quantity.toString(digit: 4) + " \(symbol)")
                }
                
                return (String(), String())
            }
    }
}
