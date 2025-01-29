//
//  WKWebView.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.

import Foundation
import WebKit

class WebPage {
    let urlString: String
    var webView: WKWebView?
    var isLoaded: Bool = false

    init(urlString: String) {
        self.urlString = urlString
    }

    func loadWebContent() {
        if webView == nil {
            let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
        }

        guard let webView = webView,
              let url = URL(string: urlString)
        else { return }

        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad, /// e.g. the `WKWebView` will use cached data if available; otherwise, it will load the data from the network.
            timeoutInterval: 30.0
        )

        webView.load(request)
        isLoaded = true
    }
}
