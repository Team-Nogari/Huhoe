//
//  HuhoeAssistViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/15.
//

import UIKit

final class HuhoeAssistPageViewController: UIPageViewController {
    lazy var pages = [
        self.ViewControllerInstance(name: "FirstPageVC"),
        self.ViewControllerInstance(name: "SecondPageVC"),
        self.ViewControllerInstance(name: "ThirdPageVC")
    ]
    
    var action: ((Int) -> Void)?
    var currentIndex : Int {
        guard let viewController = viewControllers?.first else {
            return Int.zero
        }
        
        return pages.firstIndex(of: viewController) ?? Int.zero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        configureFirstPage()
    }

    private func configureFirstPage() {
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true)
        }
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

extension HuhoeAssistPageViewController {
    func ViewControllerInstance(name: String) -> UIViewController {
        return UIStoryboard(
            name: "HuhoeAssistViewController",
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
