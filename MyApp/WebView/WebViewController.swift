//
//  WebViewController.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.
//


import UIKit
import WebKit

class WebViewController: UIViewController {

    // MARK: - Properties

    let webPage: WebPage // Made let as webPage is set once
    let pageIndex: Int
    private var hasViewLoadedOnce: Bool = false // Track initial view load

    // MARK: - Initializer

    init(webPage: WebPage) {
        self.webPage = webPage
        self.pageIndex = 0 // Default value - consider if this should always be passed in
        super.init(nibName: nil, bundle: nil)
    }

    // Designated initializer to require pageIndex as well
     init(webPage: WebPage, pageIndex: Int) {
        self.webPage = webPage
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        if webPage.webView == nil {
            webPage.loadWebContent() // Ensure webView is loaded if not already
        }
        self.view = webPage.webView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         if !hasViewLoadedOnce {
            printLog("[WebViewController] viewWillAppear (Initial Load) - Page Index: \(pageIndex), URL: \(webPage.urlString)")
            hasViewLoadedOnce = true
        } else {
            printLog("[WebViewController] viewWillAppear (Subsequent Load) - Page Index: \(pageIndex), URL: \(webPage.urlString)")
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        printLog("[WebViewController] viewDidDisappear - Page Index: \(pageIndex), URL: \(webPage.urlString)")
        // Consider: webPage.prepareForReuse() // Optional: Explicitly unload distant pages from here
    }
}
