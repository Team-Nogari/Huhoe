//
//  ChartScrollView.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/04.
//

import UIKit
import RxRelay

class ChartScrollView: UIScrollView {
//    override func awakeFromNib() {
//        let layer = CALayer()
//        layer.frame = CGRect(x: 100, y: 0, width: 10, height: frame.height)
//        layer.backgroundColor = UIColor.red.cgColor
//        self.layer.addSublayer(layer)
//    }
    
    let touchPointRelay: BehaviorRelay<Double> = BehaviorRelay<Double>(value: 0)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        touchPointRelay.accept(point.x)
    }
}
