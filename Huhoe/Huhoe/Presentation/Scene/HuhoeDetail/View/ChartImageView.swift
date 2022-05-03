//
//  ChartImageView.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/03.
//

import UIKit

class ChartImageView: UIImageView {
    private let xUnit = 10
    
    // MARK: - Method
    
    func drawChart(coinHistory: CoinPriceHistory) {
        getSize(numberOfData: coinHistory.price.count)
        
        guard let context = pathContext() else {
            return
        }
        
        context.move(to: CGPoint(x: 100, y: 100))
        context.addLine(to: CGPoint(x: 200, y: 200))
        context.setLineWidth(CGFloat(5))
        context.setStrokeColor(UIColor.red.cgColor)
        context.strokePath()
        
        print(setYUnit(with: coinHistory.price))

        setImage(with: context)
    }
    
    // MARK: - Privete Method
    
    private func getSize(numberOfData: Int) {
        frame.size.width = CGFloat(numberOfData * xUnit)
    }
    
    private func pathContext() -> CGContext? {
        UIGraphicsBeginImageContext(layer.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        
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
