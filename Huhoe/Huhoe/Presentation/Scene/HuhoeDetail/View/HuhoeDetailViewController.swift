//
//  HuhoeDetailViewController.swift
//  Huhoe
//
//  Created by 황제하 on 2022/04/23.
//

import UIKit

final class HuhoeDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
}

// MARK: - Configure Navigation Bar

extension HuhoeDetailViewController {
    private func configureBackButton() {
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.topItem?.title = String()
    }
}
