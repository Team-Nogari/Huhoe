//
//  NSMutableAttributedString+extension.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/09.
//

import UIKit

extension NSMutableAttributedString {
    func text(
        _ string: String,
        fontStyle: UIFont.TextStyle = .title3
    ) -> NSMutableAttributedString {
        let font = UIFont.preferredFont(forTextStyle: fontStyle).bold
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        self.append(NSAttributedString(string: string, attributes: attributes))
        
        return self
    }

    func colorText(
        _ string: String,
        color: UIColor,
        fontStyle: UIFont.TextStyle = .title3
    ) -> NSMutableAttributedString {
        let font = UIFont.preferredFont(forTextStyle: fontStyle).bold
        let attributes:[NSAttributedString.Key : Any] = [
            .font: font,
            .foregroundColor: color
        ]

        self.append(NSAttributedString(string: string, attributes:attributes))
        
        return self
    }
}
