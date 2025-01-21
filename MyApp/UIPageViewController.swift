//
//  UIPageViewController.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
import UIKit

class PageViewController: UIPageViewController {

    // MARK: - Properties

    private var pages: [UIViewController] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        // Create your view controllers here
        let page1 = UIViewController()
        page1.view.backgroundColor = .red
        let page2 = UIViewController()
        page2.view.backgroundColor = .green
        let page3 = UIViewController()
        page3.view.backgroundColor = .blue

        pages = [page1, page2, page3]

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
