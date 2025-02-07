//
//  PageViewController.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import UIKit
import WebKit

protocol PageViewControllerNavigationDelegate: AnyObject {
    func pageViewControllerDidRequestNavigationToSafari(_ pageViewController: PageViewController)
}

class PageViewController: UIPageViewController {

    // MARK: - Properties
    
    weak var navigationDelegate: PageViewControllerNavigationDelegate?

    private var webPages: [WebPage] = []
    private var currentIndex: Int = 0

    private let urlStrings = [
        "https://conglesolutionx.github.io/MSE_CPSC-543-Software_Maintenance/",
        "https://www.fullerton.edu/campusmap/#map",
        
        "https://openai.com/policies/row-terms-of-use",
        "https://x.ai/legal/privacy-policy",
        "https://ai.google.dev/gemini-api/docs"
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        loadInitialPages()
        
        // Add a button to trigger navigation using coordinator
        let navigateButton = UIBarButtonItem(title: "Go to Safari", style: .plain, target: self, action: #selector(navigateButtonTapped))
        navigationItem.rightBarButtonItem = navigateButton
    }

    private func setupPageViewController() {
        dataSource = self
        delegate = self
    }

    private func loadInitialPages() {
        webPages = urlStrings.map { WebPage(urlString: $0) } // Use map for concise initialization
        if let firstViewController = viewControllerAtIndex(0) {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            preloadAdjacentPages(currentIndex: 0)
        }
    }

    // MARK: - Helper Methods (Navigation & Preloading)

    private func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        guard isValidIndex(index) else { return nil } // Use validation method
        let webPage = webPages[index]
        let webVC = WebViewController(webPage: webPage, pageIndex: index)
        return webVC
    }

    private func preloadAdjacentPages(currentIndex: Int) {
        preloadPage(at: currentIndex - 1)
        preloadPage(at: currentIndex + 1)
    }

    private func preloadPage(at index: Int) {
        guard isValidIndex(index) else { return }
        loadWebPage(at: index)
    }


    private func loadWebPage(at index: Int) {
        guard isValidIndex(index), !webPages[index].isLoaded else { return } // Check if already loaded
        webPages[index].loadWebContent()
    }

    private func unloadDistantPages(from index: Int) {
        for (i, webPage) in webPages.enumerated() where abs(i - index) > 1 { // Use where clause for clarity
            unloadWebPage(at: i)
            print(webPage.isLoaded)
        }
    }

    private func unloadWebPage(at index: Int) {
        guard isValidIndex(index), webPages[index].isLoaded else { return } // Check if loaded before unloading
        webPages[index].webView = nil
        webPages[index].isLoaded = false
    }

    // MARK: - Index Validation Helper

    private func isValidIndex(_ index: Int) -> Bool {
        return index >= 0 && index < webPages.count
    }
    
    // MARK: - Navigation Delegate
    @objc func navigateButtonTapped() {
        navigationDelegate?.pageViewControllerDidRequestNavigationToSafari(self)
    }
}

// MARK: - UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let webVC = viewController as? WebViewController else { return nil }
        let index = webVC.pageIndex
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        return viewControllerAtIndex(previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let webVC = viewController as? WebViewController else { return nil }
        let index = webVC.pageIndex
        let nextIndex = index + 1
        guard nextIndex < webPages.count else { return nil }
        return viewControllerAtIndex(nextIndex)
    }
}

// MARK: - UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed, let visibleViewController = viewControllers?.first as? WebViewController {
            currentIndex = visibleViewController.pageIndex
            // Preload adjacent pages
            preloadAdjacentPages(currentIndex: currentIndex)
            // Unload distant pages
            unloadDistantPages(from: currentIndex)
        }
    }
}

