//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit
@preconcurrency import WebKit

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = WKWebViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> WKWebViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return WKWebViewController()
    }
    
    func updateUIViewController(_ uiViewController: WKWebViewController, context: Context) {
        // Update the view controller if needed
    }
}

//MARK: - MyUIKitViewController
class WKWebViewController: UIViewController {
    lazy var webView: WKWebView = {
        
        // Create web view configuration
        let webViewConfiguration = WKWebViewConfiguration()
        
        if #available(iOS 14.0, *) {
            // Set default webpage preferences
            let webpagePreferences = WKWebpagePreferences()
            webpagePreferences.allowsContentJavaScript = true // Enable JavaScript
            webViewConfiguration.defaultWebpagePreferences = webpagePreferences
        } else {
            // Fallback on iOS 13 and ealier
            webViewConfiguration.preferences.javaScriptEnabled = true
        }
        
        
        // Configure user content controller
        let userContentController = WKUserContentController()
        
        // Add script message handler
        userContentController.add(self, name: "callbackHandler")
        webViewConfiguration.userContentController = userContentController
        
        
        // Initialize webView with configuration
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        return webView
    }()
    
    override func loadView() {
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load web content
        // loadHTMLWebContent()
        loadWebContent()
    }
    
    func loadWebContent() {
        // Example URL
        if let url = URL(string: "https://www.google.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func loadHTMLWebContent() {
        let htmlString = """
        <html>
        <head>
            <title>WKWebView Test</title>
            <script type="text/javascript">
                function sendMessage() {
                    window.webkit.messageHandlers.callbackHandler.postMessage('Button clicked!');
                }
            </script>
        </head>
        <body>
            <h1>WKWebView Integration</h1>
            <button type="button" onclick="sendMessage()">Click Me!</button>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

// MARK: - WKNavigationDelegate Methods
extension WKWebViewController: WKNavigationDelegate {
    
    // MARK: - WKNavigationDelegate Methods
    
    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!
    ){
        print("Started to load")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished loading")
    }
    
    // Handle navigation actions (e.g., decide policy for navigation)
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ){
        // Allow navigation
        decisionHandler(.allow)
    }
    
    // Optional: Handle per-navigation preferences
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 preferences: WKWebpagePreferences,
                 decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ){
        // Enable JavaScript for this navigation
        preferences.allowsContentJavaScript = true
        decisionHandler(.allow, preferences)
    }
}

// MARK: - WKUIDelegate Methods
extension WKWebViewController: WKUIDelegate {
    // Handle JavaScript alerts
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void
    ){
        let alertController = UIAlertController(
            title: "Alert from Webpage",
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(
            UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - WKScriptMessageHandler Methods
extension WKWebViewController: WKScriptMessageHandler {
    // Handle messages from JavaScript
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "callbackHandler", let body = message.body as? String {
            print("JavaScript is sending a message \(body)")
            // Process message as needed
        }
    }
}
