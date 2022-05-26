//
//  UIView+extension.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/18.
//

import UIKit

extension UIView {
    func dropShadow(
        shadowColor: CGColor,
        shadowOffset: CGSize,
        shadowOpacity: Float,
        shadowRadius: CGFloat
    ) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
    }
}
