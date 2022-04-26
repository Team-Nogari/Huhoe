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
        let test: Observable<RealTimeCoinPrice>
        
        init(coinInfo: Observable<[CoinInfoItem]>, test: Observable<RealTimeCoinPrice>) {
            self.coinInfo = coinInfo
            self.test = test
        }
    }
    
    let useCase: CoinListUseCase
    var disposeBag: DisposeBag = DisposeBag()
    
    init(useCase: CoinListUseCase = CoinListUseCase()) {
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let coinInfo = Observable.combineLatest(useCase.fetch(), input.changeDate, input.changeMoney)
            .map { coinInfo, dateString, money -> [CoinInfoItem] in
                var coinInfoItems = [CoinInfoItem]()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd"
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.timeZone = TimeZone(abbreviation: "KST")
                let timeInterval = formatter.date(from: dateString)?.timeIntervalSince1970
                
                for index in coinInfo.0.indices {
                    if let timeInterval = timeInterval,
                       let dateIndex = coinInfo.2[index].date.firstIndex(of: timeInterval),
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
        
        let test = input.viewWillAppear.flatMap {
            return self.useCase.fetchTransactionWebSocket(with: ["BTC_KRW", "ETH_KRW"])
        }
        
        return Output(coinInfo: coinInfo, test: test)
    }
}

private extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
