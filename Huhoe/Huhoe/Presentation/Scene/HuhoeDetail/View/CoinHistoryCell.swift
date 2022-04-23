//
//  CoinHistoryCell.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/23.
//

import UIKit

final class CoinHistoryCell: UICollectionViewCell {
    static let identifier = String(describing: CoinListCell.self)
    
    @IBOutlet private weak var roundedBackgroundView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var calculatedPriceLabel: UILabel!
    @IBOutlet private weak var profitAndLossLabel: UILabel!
    @IBOutlet private weak var profitAndLossRateLabel: UILabel!
    
    override func awakeFromNib() {
        self.roundedBackgroundView.layer.cornerRadius = 8
        self.contentView.bounds.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
