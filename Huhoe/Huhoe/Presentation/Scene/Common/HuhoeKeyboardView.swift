//
//  HuhoeKeyboardView.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/19.
//

import UIKit
import RxSwift
import RxRelay

final class HuhoeKeyboardView: UIView {

    var input: String = "10000"
    
    private(set) lazy var inputRelay = BehaviorRelay<Double>(value: input.toDouble)
    
    @IBAction func touchUpNumberButton(_ sender: UIButton) {
        guard input != "" || sender.tag != 0 else {
            return
        }
        
        if input.count < 9 {
            input += sender.tag.description
            inputRelay.accept(input.toDouble)
        }
    }
    
    @IBAction func touchUpRemoveButton(_ sender: UIButton) {
        if input.count > 0 {
            input.removeLast()
            inputRelay.accept(input.toDouble)
        }
    }
    
    @IBAction func touchUpClearButton(_ sender: UIButton) {
        input = ""
        
        inputRelay.accept(input.toDouble)
    }
    
    @IBAction func touchUpDoneButton(_ sender: UIButton) {
        isHidden = true
    }
}
