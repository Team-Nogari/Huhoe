//
//  HuhoeKeyboardView.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/19.
//

import UIKit

final class HuhoeKeyboardView: UIView {

    var input: String = ""
    
    @IBAction func touchUpNumberButton(_ sender: UIButton) {
        input += sender.tag.description
        
        print(input)
    }
    
    @IBAction func touchUpRemoveButton(_ sender: UIButton) {
        input = input.removedSuffix(from: 1)
        
        print(input)
    }
    
    @IBAction func touchUpDoneButton(_ sender: UIButton) {
        
    }
}
