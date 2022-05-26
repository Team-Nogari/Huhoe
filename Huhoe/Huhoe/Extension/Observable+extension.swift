//
//  Observable+extension.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/28.
//

import Foundation
import RxSwift

extension Observable {
    func filterNil<U>() -> Observable<U> where Element == U? {
        return filter { $0 != nil }.map { $0! }
    }
}
