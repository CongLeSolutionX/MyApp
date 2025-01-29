//
//  UIPageViewController.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//  PageViewController.swift

import UIKit
import WebKit

class PageViewController: UIPageViewController {

    // MARK: - Properties

    private var pages: [UIViewController] = []

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

        // Create WebViewControllers for each URL
        for urlString in urlStrings {
            let webVC = WebViewController(urlString: urlString)
            pages.append(webVC)
        }

        // Set initial view controller
        if let firstViewController = pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 else { return nil }
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = currentIndex + 1
        guard nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension PageViewController: UIPageViewControllerDelegate {
    // Optional delegate methods for handling page transitions, etc.
}
