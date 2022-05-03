//
//  ChartImageView.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/03.
//

import UIKit

class ChartImageView: UIImageView {
    // MARK: - Method
    
    func drawChart(price: [Double]) {
        let xUnit: Double = 10
        let yUnit: Double = setYUnit(with: price)
        
        let price = price.map {
            $0 - price.min()!
        }
        
        guard let context = pathContext() else {
            return
        }
        
        var previoudPoint = CGPoint(x: 0, y: frame.size.height - (price[0] * yUnit))
        
        price.enumerated().forEach { index, price in
            let nextPoint = CGPoint(x: xUnit * Double(index), y: frame.size.height - (price * yUnit))
            
            context.move(to: previoudPoint)
            context.addLine(to: nextPoint)
            
            previoudPoint = nextPoint
        }
        context.strokePath()
        
        setImage(with: context)
    }
    
    // MARK: - Privete Method
    
    private func getSize(numberOfData: Int, xUnit: Double) {
        frame.size.width = CGFloat(numberOfData * Int(xUnit))
    }
    
    private func pathContext() -> CGContext? {
        UIGraphicsBeginImageContext(layer.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        context?.setLineWidth(CGFloat(3))
        context?.setStrokeColor(UIColor.red.cgColor)
        
        return context
    }
    
    private func setYUnit(with price: [Double]) -> Double {
        guard let min = price.min(),
              let max = price.max()
        else {
            return CGFloat.zero
        }
        
        let yUnit = layer.frame.height / (max - min)
        
        return yUnit
    }
    
    private func setImage(with context: CGContext) {
        context.closePath()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
