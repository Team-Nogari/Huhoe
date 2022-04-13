//
//  CoinListCell.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/12.
//

import UIKit

class CoinListCell: UICollectionViewCell {
    @IBOutlet weak var view: UIView! // naming
    static let identifier = String(describing: CoinListCell.self)
    
    override func awakeFromNib() {
        self.view.layer.cornerRadius = 8
        self.contentView.bounds.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
