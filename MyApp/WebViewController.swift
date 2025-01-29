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

    var urlString: String
    var webView: WKWebView!

    // MARK: - Initializer

    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        // Initialize WKWebView
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the URL
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    // Implement WKNavigationDelegate methods if needed
}
