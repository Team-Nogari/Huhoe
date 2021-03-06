//
//  CoinHistoryCell.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/23.
//

import UIKit

final class CoinHistoryCell: UICollectionViewCell {
    
    // MARK: - Type Properties
    
    static let identifier = String(describing: CoinHistoryCell.self)
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var roundedBackgroundView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var calculatedPriceLabel: UILabel!
    @IBOutlet private weak var profitAndLossLabel: UILabel!
    @IBOutlet private weak var profitAndLossRateLabel: UILabel!
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        self.roundedBackgroundView.layer.cornerRadius = 8
        self.roundedBackgroundView.dropShadow(
            shadowColor: UIColor.black.cgColor,
            shadowOffset: CGSize(width: 3, height: 3),
            shadowOpacity: 0.7,
            shadowRadius: 2
        )
        configureLabels()
    }
}
    
// MARK: - Private Configure

private extension CoinHistoryCell {
    func configureLabels() {
        calculatedPriceLabel.font = UIFont.withKOHIBaeum(dynamicFont: .title2)
        calculatedPriceLabel.adjustsFontForContentSizeCategory = true
        
        dateLabel.font = UIFont.withKOHIBaeum(dynamicFont: .title3)
        dateLabel.adjustsFontForContentSizeCategory = true
        
        profitAndLossLabel.font = UIFont.withKOHIBaeum(dynamicFont: .subhead)
        profitAndLossLabel.adjustsFontForContentSizeCategory = true
        
        profitAndLossRateLabel.font = UIFont.withKOHIBaeum(dynamicFont: .subhead)
        profitAndLossRateLabel.adjustsFontForContentSizeCategory = true
    }
    
    func configureProfitAndLossLabel(
        profitAndLossString: String,
        rate: Double
    ) {
        if rate > 0 {
            profitAndLossLabel.text = "+" + profitAndLossString + "원"
        } else {
            profitAndLossLabel.text = profitAndLossString + "원"
        }
    }
    
    func configureLabelColor(rate: Double) {
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

// MARK: - Configure

extension CoinHistoryCell {
    func configureCell(item: CoinHistoryItem) {
        calculatedPriceLabel.text = item.calculatedPriceString + "원"
        profitAndLossRateLabel.text = item.rateString + "%"
        dateLabel.text = item.date
        
        configureProfitAndLossLabel(
            profitAndLossString: item.profitAndLossString,
            rate: item.rate
        )
        
        configureLabelColor(rate: item.rate)
    }
}
