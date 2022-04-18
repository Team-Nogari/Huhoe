//
//  MoneyTextField.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/18.
//

import UIKit
import RxSwift
import RxCocoa

final class MoneyTextField: UITextField {
    private let disposeBag = DisposeBag()
    
    private let moneyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1,000"
        return label
    }()
    
    override func awakeFromNib() {
        configureLayout()
        configureBind()
    }
    
    private func configureLayout() {
        addSubview(moneyLabel)
        
        NSLayoutConstraint.activate([
            moneyLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            moneyLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            moneyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            moneyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func configureBind() {
        self.rx.text.asObservable()
            .subscribe(onNext: { [weak self] in
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                self?.moneyLabel.text = (numberFormatter.string(for: Double($0!)!) ?? "") + " 원"
            }).disposed(by: disposeBag)
    }
}
