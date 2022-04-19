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
    
    override func awakeFromNib() {
        configureLabels()
        self.roundedBackgroundView.layer.cornerRadius = 8
        self.contentView.bounds.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}

extension CoinListCell {
    private func configureLabels() {
        calculatedPriceLabel.font = .preferredFont(forTextStyle: .title2).bold
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

private extension NSMutableAttributedString {
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

private extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        
        return self
    }
    
    var bold: UIFont {
        return withTraits(traits: .traitBold)
    }
}
