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
        dateLabel.font = .preferredFont(forTextStyle: .caption1).bold
        dateLabel.textColor = .systemGray
        priceLabel.font = .preferredFont(forTextStyle: .subheadline).bold
    }
    
    func setLabelText(price: String, date: String) {
        priceLabel.text = price + "원"
        dateLabel.text = date
    }
}
