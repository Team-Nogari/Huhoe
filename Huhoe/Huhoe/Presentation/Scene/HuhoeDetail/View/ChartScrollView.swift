//
//  ChartScrollView.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/04.
//

import UIKit
import RxRelay

final class ChartScrollView: UIScrollView {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var priceAndDateView: ChartPriceAndDateView!
    
    // MARK: - Property
    let touchPointRelay: BehaviorRelay<Double> = BehaviorRelay<Double>(value: 0)
    
    let lineLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.red.cgColor
        return layer
    }()
    
    // MARK: - Method
    
    override func awakeFromNib() {
        self.layer.addSublayer(lineLayer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        touchPointRelay.accept(point.x)
    }
        
    func moveFloatingPriceAndDateView(offsetX: Double, price: String, date: String) {
        priceAndDateView.isHidden = false
        priceAndDateView.setLabelText(price: price, date: date)
        UIView.animate(withDuration: 0.2) {
            self.priceAndDateView.transform = CGAffineTransform(
                translationX: offsetX - 50, y: self.frame.height - CGFloat(38.0)
            ).rotated(by: .pi)
        }
        
        lineLayer.frame = CGRect(x: offsetX, y: 0, width: 1, height: frame.height - CGFloat(40.0))
    }
}