//
//  UIPageViewController.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import UIKit
import WebKit

class PageViewController: UIPageViewController {
    
    // MARK: - Properties
    
    private var pages: [WebPage] = []
    private var currentIndex: Int = 0
    
    // List of URLs to load
    private let urlStrings = [
        "https://openai.com/policies/row-terms-of-use",
        "https://x.ai/legal/privacy-policy",
        "https://ai.google.dev/gemini-api/docs"
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        // Initialize WebPage models
        for urlString in urlStrings {
            let webPage = WebPage(urlString: urlString)
            pages.append(webPage)
        }
        
        // Set initial view controller
        if let firstViewController = viewControllerAtIndex(0) {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            // Preload adjacent pages
            preloadAdjacentPages(currentIndex: 0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        guard index >= 0 && index < pages.count else { return nil }
        
        let webPage = pages[index]
        let webVC = WebViewController(webPage: webPage)
        webVC.pageIndex = index
        return webVC
    }
    
    private func preloadAdjacentPages(currentIndex: Int) {
        // Preload previous page
        let previousIndex = currentIndex - 1
        if previousIndex >= 0 {
            loadWebPage(at: previousIndex)
        }
        
        // Preload next page
        let nextIndex = currentIndex + 1
        if nextIndex < pages.count {
            loadWebPage(at: nextIndex)
        }
    }
    
    private func loadWebPage(at index: Int) {
        let webPage = pages[index]
        if !webPage.isLoaded {
            webPage.loadWebContent()
        }
    }
    
    /// Frees up memory by unloading pages that are not adjacent to the current page
    private func unloadDistantPages(from index: Int) {
        for (i, webPage) in pages.enumerated() {
            if abs(i - index) > 1 {
                // Unload web views that are not adjacent to the current page
                webPage.webView = nil
                webPage.isLoaded = false
            }
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let webVC = viewController as? WebViewController else { return nil }
        let index = webVC.pageIndex
        let previousIndex = index - 1
        return viewControllerAtIndex(previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let webVC = viewController as? WebViewController else { return nil }
        let index = webVC.pageIndex
        let nextIndex = index + 1
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

