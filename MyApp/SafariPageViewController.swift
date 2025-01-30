//
//  SafariPageViewController.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.
//


import UIKit

class SafariPageViewController: UIPageViewController {

    // MARK: - Properties

    private var safariViewControllers: [SafariViewController] = []
    private var currentIndex: Int = 0

    private let urlStrings = [
        "https://www.apple.com",
        "https://www.google.com",
        "https://www.github.com"
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        loadInitialPages()
    }

    private func setupPageViewController() {
        dataSource = self
        delegate = self
    }

    private func loadInitialPages() {
        safariViewControllers = urlStrings.enumerated().map { index, urlString in // Using enumerated map
            let safariWebVC = SafariViewController(urlString: urlString)
            safariWebVC.pageIndex = index
            return safariWebVC
        }
        if let firstViewController = safariViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPageViewControllerDataSourceS
extension SafariPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let webVC = viewController as? SafariViewController else { return nil }
        let index = webVC.pageIndex
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        return safariViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let webVC = viewController as? SafariViewController else { return nil }
        let index = webVC.pageIndex
        let nextIndex = index + 1
        guard nextIndex < safariViewControllers.count else { return nil }
        return safariViewControllers[nextIndex]
    }
}

// MARK: - UIPageViewControllerDataSource
extension SafariPageViewController: UIPageViewControllerDelegate {
    // Implement delegate methods if needed
}
