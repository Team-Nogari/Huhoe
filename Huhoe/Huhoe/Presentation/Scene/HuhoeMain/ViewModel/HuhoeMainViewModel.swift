//
//  HuhoeMainViewModel.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/15.
//

import Foundation
import RxSwift

final class HuhoeMainViewModel: ViewModel {
    
    // MARK: - Input
    
    final class Input {
        let changeMoney: Observable<String>
        let changeDate: Observable<String>
        
        init(changeMoney: Observable<String>, changeDate: Observable<String>) {
            self.changeMoney = changeMoney
            self.changeDate = changeDate
        }
    }
    
    // MARK: - Output
    
    final class Output {
        let coinInfo: Observable<[CoinInfoItem]>
        
        init(coinInfo: Observable<[CoinInfoItem]>) {
            self.coinInfo = coinInfo
        }
    }
    
    // MARK: - Properties
    
    let useCase: CoinListUseCase
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(useCase: CoinListUseCase = CoinListUseCase()) {
        self.useCase = useCase
    }
    
    // MARK: - Methods
    
    func transform(_ input: Input) -> Output {
        let coinInfo = Observable.combineLatest(useCase.fetch(), input.changeDate, input.changeMoney)
            .map { coinInfo, dateString, money -> [CoinInfoItem] in
                var coinInfoItems = [CoinInfoItem]()
                
                for index in coinInfo.0.indices {
                    if let dateIndex = coinInfo.2[index].date.firstIndex(of: dateString),
                       let price = coinInfo.2[index].price[safe: dateIndex],
                       let money = Double(money)
                    {
                        let quantity = money / price
                        let calculatedPrice = coinInfo.1[index].price * quantity
                        let profitAndLoss = calculatedPrice - money
                        let rate = profitAndLoss / money * 100
                        
                        let cellItem = CoinInfoItem(
                            coinName: coinInfo.0[index].coinSymbol.localized,
                            coinSymbol: coinInfo.0[index].coinSymbol,
                            calculatedPrice: calculatedPrice,
                            rate: rate,
                            profitAndLoss: profitAndLoss,
                            currentPrice: coinInfo.1[index].price,
                            oldPrice: price
                        )
                        
                        coinInfoItems.append(cellItem)
                    }
                }
                
                return coinInfoItems
            }
        
        return Output(coinInfo: coinInfo)
    }
}
