//
//  HuhoeAssistViewController.swift
//  Huhoe
//
//  Created by 황제하 on 2022/05/15.
//

import UIKit
import RxSwift
import RxCocoa

final class HuhoeAssistViewController: UIViewController {

    @IBOutlet private weak var pageControl: UIPageControl!
    private var pageViewController : HuhoeAssistPageViewController?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
    }
    
    private var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.titleLabel?.font = UIFont.withKOHIBaeum(dynamicFont: .title3)
        button.setTitleColor(UIColor(named: "ButtonColor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("건너뛰기", for: .normal)
        button.titleLabel?.font = UIFont.withKOHIBaeum(dynamicFont: .title3)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func configureButton() {
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            skipButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nextButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let pageViewController = self.pageViewController,
                      let currentPage = pageViewController.viewControllers?.first,
                      let nextPage = pageViewController.dataSource?.pageViewController(pageViewController, viewControllerAfter: currentPage)
                       else {
                          self?.presentMainViewController()
                    return
                }
                
                pageViewController.setViewControllers([nextPage], direction: .forward, animated: true)
                self.pageControl.currentPage = pageViewController.pages.firstIndex(of: nextPage)!
                
                let isLastPage = pageViewController.pages.firstIndex(of: nextPage) == pageViewController.pages.count - 1
                
                if isLastPage == true {
                    self.skipButton.isHidden = true
                    self.nextButton.setTitle("시작하기", for: .normal)
                } else {
                    self.skipButton.isHidden = false
                    self.nextButton.setTitle("다음", for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        skipButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentMainViewController()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Override Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageViewController" {
            guard let pageViewController = segue.destination as? HuhoeAssistPageViewController else {
                return
            }
            
            self.pageViewController = pageViewController
            self.pageViewController?.action = { [weak self] pageIndex in
                guard let pageCount = self?.pageViewController?.pages.count else {
                    return
                }
                
                self?.pageControl.currentPage = pageIndex
                
                let isLastPage = pageIndex == pageCount - 1
                
                if isLastPage == true {
                    self?.skipButton.isHidden = true
                    self?.nextButton.setTitle("시작하기", for: .normal)
                } else {
                    self?.skipButton.isHidden = false
                    self?.nextButton.setTitle("다음", for: .normal)
                }
            }
        }
    }
}

private extension HuhoeAssistViewController {
    func presentMainViewController() {
        let isAssistView = UserDefaults.standard.bool(forKey: "isAssistView")
        
        if isAssistView == true {
            self.dismiss(animated: true)
        } else {
            let storyboard = UIStoryboard(name: "HuhoeMainViewController", bundle: nil)
            let vc = UINavigationController(rootViewController: storyboard.instantiateViewController(withIdentifier: "HuhoeMainViewController"))

            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = vc
        }
    }
}
