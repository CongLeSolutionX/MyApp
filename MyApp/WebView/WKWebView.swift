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
}
