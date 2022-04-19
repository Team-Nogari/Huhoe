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
    
    required init(mode: UIDatePicker.Mode, date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        datePicker.datePickerMode = mode
        datePicker.date = date ?? Date()
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
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


