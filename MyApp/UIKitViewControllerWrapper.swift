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
    typealias UIViewControllerType = MyUIKitViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
//class MyUIKitViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBlue
//        // Additional setup
//    }
//}

class MyUIKitViewController: UIViewController {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create configuration
        let webConfiguration = WKWebViewConfiguration()
        
        // Configure preferences
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        webConfiguration.preferences = preferences
        
        // Configure user content controller for JavaScript interaction
        let userContentController = WKUserContentController()
        webConfiguration.userContentController = userContentController
        
        // Add JavaScript message handler
        userContentController.add(self, name: "callbackHandler")
        
        // JavaScript code to be injected
        let jsCode = "window.webkit.messageHandlers.callbackHandler.postMessage('Hello from JavaScript');"
        let userScript = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(userScript)
        
        
        // Initialize WKWebView with configuration
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        // Set delegates
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // Add web view to view hierarchy
        view.addSubview(webView)
        
        // Set constraints for web view
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Load web content
        //loadHTMLWebContent()
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

extension MyUIKitViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    // MARK: - WKNavigationDelegate Methods
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Started to load")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished loading")
    }
    
    // Handle navigation actions (e.g., decide policy for navigation)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Allow navigation
        decisionHandler(.allow)
    }
    
    // MARK: - WKUIDelegate Methods
    
    // Handle JavaScript alerts
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Alert from Webpage", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - WKScriptMessageHandler Methods
    
    // Handle messages from JavaScript
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "callbackHandler", let body = message.body as? String {
            print("JavaScript is sending a message \(body)")
            // Process message as needed
        }
    }
}
