//
//  SafariPageViewController.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.
//

//
import UIKit

class SafariPageViewController: UIPageViewController {

    // MARK: - Properties

    private var pages: [SafariViewController] = []
    private var currentIndex: Int = 0

    // List of URLs to load
    private let urlStrings = [
        "https://www.apple.com",
        "https://www.google.com",
        "https://www.github.com"
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        // Initialize SafariViewController instances
        for (index, urlString) in urlStrings.enumerated() {
            let safariWebVC = SafariViewController(urlString: urlString)
            safariWebVC.pageIndex = index
            pages.append(safariWebVC)
        }

        // Set initial view controller
        if let firstViewController = pages.last {
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
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let webVC = viewController as? SafariViewController else { return nil }
        let index = webVC.pageIndex
        let nextIndex = index + 1
        guard nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDataSource
extension SafariPageViewController: UIPageViewControllerDelegate {
    // Implement delegate methods if needed
}
