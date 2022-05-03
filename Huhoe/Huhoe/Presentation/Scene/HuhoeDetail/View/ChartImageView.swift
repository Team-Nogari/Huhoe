//
//  ChartImageView.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/03.
//

import UIKit

class ChartImageView: UIImageView {
    private let xUnit = 10
    
    private func getSize(numberOfData: Int) {
        frame.size.width = CGFloat(numberOfData * xUnit)
    }
    
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

        setImage(with: context)
    }
    
    private func pathContext() -> CGContext? {
        UIGraphicsBeginImageContext(layer.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        
        return context
    }
    
    private func setImage(with context: CGContext) {
        context.closePath()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
