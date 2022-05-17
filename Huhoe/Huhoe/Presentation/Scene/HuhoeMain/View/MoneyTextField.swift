//
//  MoneyTextField.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/18.
//

import UIKit
import RxSwift
import RxRelay

final class MoneyTextField: UITextField {
    private let disposeBag = DisposeBag()
    
    private let moneyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.withKOHIBaeum(dynamicFont: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10,000"
        return label
    }()
    
    // MARK: - Override Methods
 
    override var text: String? {
        get {
            guard let text = super.text,
                  let number = Double(text)
            else {
                return super.text
            }
            
            moneyLabel.text = number.toString() + " 원"
            
            return super.text
        }
        set {
            super.text = newValue
        }
    }
    
    override func awakeFromNib() {
        configureLayout()
        filterTextBind()
    }
    
    // MARK: - Private Methods
    
    private func filterTextBind() {
        self.rx.text
            .scan("") { previous, new in
                if previous.count == 1 && new == "" {
                    return "0"
                }
                
                if previous == "0" && new != "0" {
                    return new?.deletingPrefix("0") ?? ""
                }
                
                return new ?? ""
            }
            .map { text in
                if text.count > 9 {
                    return String(text.prefix(9))
                } else {
                    return text
                }
            }
            .bind(to: self.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    
    private func configureLayout() {
        addSubview(moneyLabel)
        
        NSLayoutConstraint.activate([
            moneyLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            moneyLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            moneyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            moneyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

// MARK: - Private Extension

private extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
