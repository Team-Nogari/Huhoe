//
//  ChartImageView.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/03.
//

import UIKit

final class ChartImageView: UIImageView {
    
    // MARK: - Method
    
    func drawChart(price: [Double], offsetX: Double) {
        let xUnit: Double = (UIScreen.main.bounds.width / CGFloat(price.count)).rounded(.down)
        let yUnit: Double = setYUnit(with: price)
        
        let simplifiedPrice = price.map {
            $0 - price.min()!
        }
        
        guard let context = pathContext() else {
            return
        }
        
        var previousPoint = CGPoint(
            x: offsetX + xUnit,
            y: frame.size.height - (simplifiedPrice[0] * yUnit) - 15
        )
        
        let firstPoint = CGPoint(
            x: offsetX + (xUnit * 2),
            y: frame.size.height - (simplifiedPrice[1] * yUnit) - 15
        )
        
        context.move(to: previousPoint)
        context.addLine(to: firstPoint)
        context.closePath()
        
        previousPoint = firstPoint
        
        for index in 2..<simplifiedPrice.count {
            let nextPoint = CGPoint(
                x: xUnit * Double(index + 1) + offsetX,
                y: frame.size.height - (simplifiedPrice[index] * yUnit) - 15
            )
            
            context.move(to: previousPoint)
            context.addLine(to: nextPoint)
            context.closePath()
            
            previousPoint = nextPoint
        }
        context.strokePath()
        
        setImage()
    }
    
    func getSize(numberOfData: Int, xUnit: Double) {
        frame.size.width = CGFloat(numberOfData * Int(xUnit))
    }
    
    // MARK: - Privete Method
    
    private func pathContext() -> CGContext? {
        UIGraphicsBeginImageContext(layer.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setLineWidth(CGFloat(5))
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setShadow(offset: CGSize(width: -2, height: 2), blur: 0, color: UIColor.black.cgColor)
        
        return context
    }
    
    private func setYUnit(with price: [Double]) -> Double {
        guard let min = price.min(),
              let max = price.max()
        else {
            return CGFloat.zero
        }
        
        let yUnit = (layer.frame.height - 75) / (max - min)
        
        return yUnit
    }
    
    private func setImage() {
        image = UIGraphicsGetImageFromCurrentImageContext()?.withHorizontallyFlippedOrientation()
        UIGraphicsEndImageContext()
    }
}
