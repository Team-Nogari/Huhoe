//
//  HuhoeAssistViewController.swift
//  Huhoe
//
//  Created by 임지성 on 2022/05/15.
//

import UIKit

class HuhoeAssistPageViewController: UIPageViewController {
    lazy var pages = [
        self.ViewControllerInstance(name: "FirstPageVC"),
        self.ViewControllerInstance(name: "SecondPageVC"),
        self.ViewControllerInstance(name: "ThirdPageVC")
    ]

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
}

private extension HuhoeAssistPageViewController {
    func ViewControllerInstance(name: String) -> UIViewController {
        return UIStoryboard(
            name: "HuhoeAssistPageViewController",
            bundle: nil
        )
        .instantiateViewController(withIdentifier: name)
    }
}
