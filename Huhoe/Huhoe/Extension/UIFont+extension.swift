//
//  UIFont+extension.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/28.
//

import UIKit

extension UIFont {
    static func withKOHIBaeum(dynamicFont: CustomDynamicFont) -> UIFont {
        guard let font = UIFont(
            name: "KOHIBaeum",
            size: dynamicFont.size
        ) else {
            return UIFont()
        }
        
        return UIFontMetrics(forTextStyle: dynamicFont.style).scaledFont(for: font)
    }
}
