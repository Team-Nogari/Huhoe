//
//  CoinListCell.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/12.
//

import UIKit

class CoinListCell: UICollectionViewCell {
    static let identifier = String(describing: CoinListCell.self)
    
    @IBOutlet private weak var roundedBackgroundView: UIView!
    @IBOutlet private weak var coinNameLabel: UILabel!
    @IBOutlet private weak var calculatedPriceLabel: UILabel!
    @IBOutlet private weak var profitAndLossLabel: UILabel!
    @IBOutlet private weak var profitAndLossRateLabel: UILabel!
    @IBOutlet private weak var currentPriceLabel: UILabel!
    @IBOutlet private weak var oldPriceLabel: UILabel!
    
    @IBOutlet private var hintLabels: [UILabel]!
    
    override func awakeFromNib() {
        configureLabels()
        self.roundedBackgroundView.layer.cornerRadius = 8
    }
}

extension CoinListCell {
    private func configureLabels() {
        calculatedPriceLabel.font = UIFont.withKOHIBaeum(dynamicFont: .title2)
        calculatedPriceLabel.adjustsFontForContentSizeCategory = true
        
        profitAndLossLabel.font = UIFont.withKOHIBaeum(dynamicFont: .callout)
        profitAndLossLabel.adjustsFontForContentSizeCategory = true
        
        profitAndLossRateLabel.font = UIFont.withKOHIBaeum(dynamicFont: .callout)
        profitAndLossRateLabel.adjustsFontForContentSizeCategory = true
        
        currentPriceLabel.font = UIFont.withKOHIBaeum(dynamicFont: .subhead)
        currentPriceLabel.adjustsFontForContentSizeCategory = true
        
        oldPriceLabel.font = UIFont.withKOHIBaeum(dynamicFont: .subhead)
        oldPriceLabel.adjustsFontForContentSizeCategory = true
        
        hintLabels.forEach {
            $0.font = UIFont.withKOHIBaeum(dynamicFont: .subhead)
            $0.adjustsFontForContentSizeCategory = true
        }
    }
    
    func configureCell(item: CoinInfoItem) {
        coinNameLabel.attributedText = NSMutableAttributedString()
            .text(item.coinName)
            .text("  ")
            .colorText(item.coinSymbol, color: .systemGray)
        
        calculatedPriceLabel.text = item.calculatedPriceString + "원"
        profitAndLossRateLabel.text = item.rateString + "%"
        currentPriceLabel.text = item.currentPriceString + "원"
        oldPriceLabel.text = item.oldPriceString + "원"
        
        configureProfitAndLossLabel(
            profitAndLossString: item.profitAndLossString,
            rate: item.rate
        )
        
        configureLabelColor(rate: item.rate)
    }
    
    private func configureProfitAndLossLabel(profitAndLossString: String, rate: Double) {
        if rate > 0 {
            profitAndLossLabel.text = "+" + profitAndLossString + "원"
        } else {
            profitAndLossLabel.text = profitAndLossString + "원"
        }
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
