//
//  ViewModel.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/26.
//

import Foundation
import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(_ input: Input) -> Output
}
