//
//  TickerRepository.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/08.
//

import Foundation

protocol TickerRepository {
    func fetchTicker(coinSymbol: String)
}
