//
//  CandlestickRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/09.
//

import Foundation

protocol CandlestickRepository {
    func fetchCandlestick(coinSymbol: [String])
}

