//
//  WebViewController.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.
//
//
//  WebViewController.swift

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    // MARK: - Properties
    
    var webPage: WebPage
    var pageIndex: Int = 0
    
    // MARK: - Initializer
    
    init(webPage: WebPage) {
        self.webPage = webPage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func loadView() {
        if let webView = webPage.webView {
            self.view = webView
        } else {
            // Initialize WKWebView if not preloaded
            let webView = WKWebView()
            self.view = webView
            if let url = URL(string: webPage.urlString) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
            webPage.webView = webView
            webPage.isLoaded = true
        }
    }
}
