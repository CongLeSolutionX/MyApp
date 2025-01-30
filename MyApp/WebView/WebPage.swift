//
//  WebPage.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.


import Foundation
import WebKit

class WebPage {
    let urlString: String
    var webView: WKWebView?     /// Consider to use private(set) for controlled mutation from outside
    var isLoaded: Bool = false  /// Consider to use private(set) for controlled mutation from outside

    init(urlString: String) {
        self.urlString = urlString
    }

    func loadWebContent() {
        if webView == nil {
            let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
        }

        guard let webView = webView, let url = URL(string: urlString) else {
            printLog("[WebPage] Error: Invalid URL string - \(urlString)") // Error logging
            return // Early exit for invalid URL
        }

        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 30.0
        )

        webView.load(request)
        isLoaded = true
    }

    func prepareForReuse() { // Method to explicitly reset for reuse/memory management
        webView?.stopLoading()
        webView?.removeFromSuperview() // Optional - remove from hierarchy if needed
        webView = nil // Deallocate WKWebView
        isLoaded = false
    }

    deinit {
        printLog("[WebPage] Deinit - WebPage for \(urlString)") // Deinit logging for debugging
        prepareForReuse() // Clean up resources in deinit
    }
}
