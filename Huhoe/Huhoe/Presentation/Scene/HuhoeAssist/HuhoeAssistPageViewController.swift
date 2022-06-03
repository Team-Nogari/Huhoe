//
//  HuhoeAssistViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/15.
//

import UIKit
import RxSwift
import RxCocoa

final class HuhoeAssistPageViewController: UIPageViewController {
    
    // MARK: - Properties
    
    lazy var pages = [
        self.viewControllerInstance(name: "FirstPageVC"),
        self.viewControllerInstance(name: "SecondPageVC"),
        self.viewControllerInstance(name: "ThirdPageVC")
    ]
    
    var action: ((Int) -> Void)?
    
    var currentIndex : Int {
        guard let viewController = viewControllers?.first else {
            return Int.zero
        }
        
        return pages.firstIndex(of: viewController) ?? Int.zero
    }
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        configureFirstPage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl, let pageControl = view as? UIPageControl {
                pageControl.isHidden = true
            }
        }
    }
    
// MARK: - Configure
    
    private func configureFirstPage() {
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true)
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension HuhoeAssistPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let pageIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = pageIndex - 1
        
        if previousIndex < 0 {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let pageIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = pageIndex + 1
        
        if nextIndex == pages.count {
            return nil
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

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
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            action?(currentIndex)
        }
    }
}

// MARK: - Private Extension

private extension HuhoeAssistPageViewController {
    func viewControllerInstance(name: String) -> UIViewController {
        return UIStoryboard(
            name: "HuhoeAssistViewController",
            bundle: nil
        )
        .instantiateViewController(withIdentifier: name)
    }
}
