//
//  ChartPriceAndDateView.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/04.
//

import UIKit

class ChartPriceAndDateView: UIView {
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        dateLabel.font = UIFont.withKOHIBaeum(dynamicFont: .caption2)
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.textColor = .systemGray
        
        priceLabel.font = UIFont.withKOHIBaeum(dynamicFont: .caption1)
        priceLabel.adjustsFontForContentSizeCategory = true
    }
    
    func setLabelText(price: String, date: String) {
        priceLabel.text = price + "원"
        dateLabel.text = date
    }
}
