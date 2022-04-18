//
//  CoinListCell.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/12.
//

import UIKit

class CoinListCell: UICollectionViewCell {
    static let identifier = String(describing: CoinListCell.self)
    
    @IBOutlet weak var roundedBackgroundView: UIView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinSymbolLabel: UILabel!
    @IBOutlet weak var calculatedPriceLabel: UILabel!
    @IBOutlet weak var profitAndLossLabel: UILabel!
    @IBOutlet weak var profitAndLossRateLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    override func awakeFromNib() {
        self.roundedBackgroundView.layer.cornerRadius = 8
        self.contentView.bounds.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}

extension CoinListCell {
    func configureCell(item: CoinInfoItem) {
        coinNameLabel.text = item.coinName
        coinSymbolLabel.text = item.coinSymbol
        calculatedPriceLabel.text = item.calculatedPriceString + "원"
        profitAndLossLabel.text = item.profitAndLossString + "원"
        profitAndLossRateLabel.text = item.rateString + "%"
        currentPriceLabel.text = item.currentPriceString + "원"
        
        configureLabelColor(rate: item.rate)
    }
    
    private func configureLabelColor(rate: Double) {
        if rate < 0 {
            calculatedPriceLabel.textColor = .systemBlue
            profitAndLossLabel.textColor = .systemBlue
            profitAndLossRateLabel.textColor = .systemBlue
        } else {
            calculatedPriceLabel.textColor = .systemRed
            profitAndLossLabel.textColor = .systemRed
            profitAndLossRateLabel.textColor = .systemRed
        }
    }
}
