//
//  DatePickerViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/04/19.
//

import UIKit
import RxCocoa

class DatePickerViewController: UIViewController {
    typealias Action = (Date) -> Void
    var action: Action?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        return datePicker
    }()
    
    required init(
        date: Date? = Date().yesterday,
        action: Action?
    ) {
        super.init(nibName: nil, bundle: nil)
        datePicker.date = Date().yesterday
        datePicker.setDate(date ?? Date().yesterday, animated: false)
        // 1388070000: Bithumb Public API Bitcoin Candlestick 가장 오래된 UTC 시간
        datePicker.minimumDate = Date(timeIntervalSince1970: 1388070000)
        datePicker.maximumDate = Date().yesterday
        self.action = action
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        view = datePicker
    }
    
    deinit {
        action?(datePicker.date)
    }
}


