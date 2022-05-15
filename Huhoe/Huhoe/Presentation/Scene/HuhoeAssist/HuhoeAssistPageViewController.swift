//
//  HuhoeAssistViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/15.
//

import UIKit
import RxSwift
import RxCocoa

class HuhoeAssistPageViewController: UIPageViewController {
    private let disposeBag = DisposeBag()
    
    lazy var pages = [
        self.ViewControllerInstance(name: "FirstPageVC"),
        self.ViewControllerInstance(name: "SecondPageVC"),
        self.ViewControllerInstance(name: "ThirdPageVC")
    ]
    
    private var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.withKOHIBaeum(dynamicFont: .title3)
        button.setTitleColor(UIColor(named: "ButtonColor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = UIFont.withKOHIBaeum(dynamicFont: .title3)
        button.setTitleColor(UIColor(named: "ButtonColor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        configureFirstPage()
        configureButton()
    }

    private func configureFirstPage() {
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true)
        }
    }
    
    private func configureButton() {
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            skipButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            nextButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5)
        ])
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let currentPage = self.viewControllers?.first,
                      let nextPage = self.dataSource?.pageViewController(self, viewControllerAfter: currentPage) else {
                    self?.presentMainViewController()
                    return
                }
                
                self.setViewControllers([nextPage], direction: .forward, animated: true)
            })
            .disposed(by: disposeBag)
        
        skipButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentMainViewController()
            })
            .disposed(by: disposeBag)
    }
}

extension HuhoeAssistPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = pageIndex - 1
        
        if previousIndex < 0 {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = pageIndex + 1
        
        
        if nextIndex == pages.count {
            return nil
        } else if nextIndex == pages.count - 1 {
            skipButton.isHidden = true
        }
        
        return pages[nextIndex]
    }
}

extension HuhoeAssistPageViewController: UIPageViewControllerDelegate {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstPage = pages.first,
              let firstPageIndex = pages.firstIndex(of: firstPage) else {
            return 0
        }
        
        return firstPageIndex
    }
}

private extension HuhoeAssistPageViewController {
    func ViewControllerInstance(name: String) -> UIViewController {
        return UIStoryboard(
            name: "HuhoeAssistPageViewController",
            bundle: nil
        )
        .instantiateViewController(withIdentifier: name)
    }
    
    func presentMainViewController() {
        let storyboard = UIStoryboard(name: "HuhoeMainViewController", bundle: nil)
        let vc = UINavigationController(rootViewController: storyboard.instantiateViewController(withIdentifier: "HuhoeMainViewController"))
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
}
