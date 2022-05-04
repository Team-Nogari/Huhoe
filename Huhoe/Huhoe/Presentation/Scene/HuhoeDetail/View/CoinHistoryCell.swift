//
//  CoinHistoryCell.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/23.
//

import UIKit

final class CoinHistoryCell: UICollectionViewCell {
    static let identifier = String(describing: CoinHistoryCell.self)
    
    @IBOutlet private weak var roundedBackgroundView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var calculatedPriceLabel: UILabel!
    @IBOutlet private weak var profitAndLossLabel: UILabel!
    @IBOutlet private weak var profitAndLossRateLabel: UILabel!
    
    override func awakeFromNib() {
        self.roundedBackgroundView.layer.cornerRadius = 8
        configureLabels()
    }
    
    private func configureLabels() {
        calculatedPriceLabel.font = .preferredFont(forTextStyle: .title2).bold
        dateLabel.font = .preferredFont(forTextStyle: .title3).bold
        profitAndLossLabel.font = .preferredFont(forTextStyle: .subheadline).bold
        profitAndLossRateLabel.font = .preferredFont(forTextStyle: .subheadline).bold
    }
    
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
