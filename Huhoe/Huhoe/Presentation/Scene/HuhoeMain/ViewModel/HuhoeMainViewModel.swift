//
//  HuhoeMainViewModel.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/15.
//

import Foundation
import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(_ input: Input) -> Output
}

final class HuhoeMainViewModel: ViewModel {
    final class Input {
        let changeMoney: Observable<String>
        let changeDate: Observable<String>
        let viewWillAppear: Observable<Void>
        
        init(viewWillAppear: Observable<Void>, changeMoney: Observable<String>, changeDate: Observable<String>) {
            self.viewWillAppear = viewWillAppear
            self.changeMoney = changeMoney
            self.changeDate = changeDate
        }
    }
    
    final class Output {
        let coinInfo: Observable<[CoinInfoItem]>
        
        init(coinInfo: Observable<[CoinInfoItem]>) {
            self.coinInfo = coinInfo
        }
    }
    
    let useCase: CoinListUseCase
    var disposeBag: DisposeBag = DisposeBag()
    
    init(useCase: CoinListUseCase = CoinListUseCase()) {
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let coinInfo = Observable.zip(useCase.fetch(), input.changeDate, input.changeMoney)
            .map { coinInfo, dateString, money -> [CoinInfoItem] in
                var coinInfoItems = [CoinInfoItem]()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH"
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.timeZone = TimeZone(abbreviation: "KST")
                let date2 = formatter.date(from: dateString)
                let asdf: TimeInterval = date2!.timeIntervalSince1970
                
                for index in coinInfo.0.indices {
                    let dateIndex = coinInfo.2[index].date.firstIndex(of: asdf)!
                    let price = coinInfo.2[index].price[dateIndex]
                    let quantity = Double(money)! / price
                    let calculatedPrice = coinInfo.1[index].price * quantity
                    let profitAndLoss = (calculatedPrice - Double(money)!)
                    let rate = profitAndLoss / Double(money)! * 100
                    
                    let cellItem = CoinInfoItem(
                        coinName: coinInfo.0[index].coinSymbol,
                        coinSymbol: coinInfo.0[index].coinSymbol,
                        calculatedPrice: calculatedPrice,
                        rate: rate,
                        profitAndLoss: profitAndLoss,
                        currentPrice: coinInfo.1[index].price
                    )
                    
                    coinInfoItems.append(cellItem)
                }
                
                return coinInfoItems
            }
        
        return Output(coinInfo: coinInfo)
    }
}


