//
//  ChartPriceAndDateView.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/04.
//

import UIKit

class ChartPriceAndDateView: UIView {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        dateLabel.font = UIFont.withKOHIBaeum(dynamicFont: .caption1)
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.textColor = .systemGray
        
        priceLabel.font = UIFont.withKOHIBaeum(dynamicFont: .footnote)
        priceLabel.adjustsFontForContentSizeCategory = true
    }
    
    // MARK: - Methods
    
    func setLabelText(price: String, date: String) {
        priceLabel.text = price + "원"
        dateLabel.text = date
    }
}
