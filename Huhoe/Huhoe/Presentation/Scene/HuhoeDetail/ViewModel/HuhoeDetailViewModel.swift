//
//  HuhoeDetailViewModel.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/27.
//

import Foundation
import RxSwift

final class HuhoeDetailViewModel: ViewModel {
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
        
        init(realTimePrice: Observable<String>) {
            self.realTimePrice = realTimePrice
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
        let realTimePriceObservable = useCase.fetchTransactionWebSocket(with: [selectedCoinSymbol])
            .map {
                $0.price
            }
        let coinPriceHistoryObservable = useCase.fetchCoinPriceHistory(with: selectedCoinSymbol)
        
        let realTimePriceStringObservalbe = realTimePriceObservable
            .map {
                $0.toString(digit: 4) + "원"
            }
        
        return Output(realTimePrice: realTimePriceStringObservalbe)
    }
}
