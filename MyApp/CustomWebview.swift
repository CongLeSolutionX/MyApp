//
//  CustomWebview.swift
//  MyApp
//
//  Created by Cong Le on 3/20/25.
//

import UIKit
@preconcurrency import WebKit

class WebViewController: UIViewController {

    // MARK: - Properties
    private var webView: WKWebView!
//    @IBOutlet weak var dataTextField: UITextField! // Assuming a text field for data transfer example
    lazy var dataTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter data to send to Swift"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .green
        return textField
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadInitialContent()  // Load either remote or local, or handle both.
    }

    // MARK: - WebView Setup

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()

        // 5. Enable JavaScript (Default is true, but explicit for clarity)
        preferences.allowsContentJavaScript = true
        webConfiguration.defaultWebpagePreferences = preferences
        // OR (older API)
        // webConfiguration.preferences.javaScriptEnabled = true

        // 7. Setup JavaScript-to-Swift communication
        let contentController = WKUserContentController()
        contentController.add(self, name: "jsHandler") // "jsHandler" is the bridge name
        contentController.add(self, name: "connectWebToApp") // for data transfer example
        webConfiguration.userContentController = contentController

        // 10. WKUserScript and WKContentWorld (Security) - Example
        let userScriptSource = "document.body.style.backgroundColor = 'lightgray';" // Example script
        let userScript = WKUserScript(source: userScriptSource,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        // For more isolation:  (iOS 14+)
        // let world = WKContentWorld.pageWorld
        // let isolatedScript = WKUserScript(...)
        // contentController.addUserScript(isolatedScript, in: world)



        webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self  // 8. Handle Navigation
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }


    // MARK: - Content Loading

    private func loadInitialContent() {
        // Choose ONE of these, or implement logic to handle both:

        // 1. Basic: Load a remote URL
        loadRemoteURL(urlString: "https://www.apple.com")

        // 3. Load a local HTML file
        // loadLocalHTMLFile(filename: "index") // Assumes "index.html" in your bundle
    }


    private func loadRemoteURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func loadLocalHTMLFile(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "html") else {
            print("Local file not found: \(filename).html")
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    // MARK: - JavaScript Interaction

    // 6. Inject JavaScript (Swift to Web)
    func injectJavaScript(script: String) {
        webView.evaluateJavaScript(script) { (result, error) in
            if let error = error {
                print("JavaScript Injection Error: \(error)")
            } else {
                print("JavaScript executed successfully. Result: \(result ?? "No Result")")
            }
        }
    }

    // Example usage of injectJavaScript:
    func changeBackgroundColor(color: String) {
        injectJavaScript(script: "document.body.style.backgroundColor = '\(color)';")
    }

    // MARK: - Actions

    // Example: Button action to inject JavaScript (from the documentation example)
//    @IBAction func changeBackgroundToRed() {
//        injectJavaScript(script: "document.body.style.backgroundColor = 'red';")
//    }

    // Example: Button action to get data from text field and put into web page (Q13)
//    @IBAction func sendDataToWebApp() {
//        guard let data = dataTextField.text, !data.isEmpty else { return }
//        // Assuming your HTML has an element with id="messageInput"
//        injectJavaScript(script: "document.getElementById('messageInput').value='\(data)';")
//    }


    // MARK: - Debugging (12)

    func enableDebugging() {
        // 1. Enable Web Inspector:  Settings > Safari > Advanced > Web Inspector
        // 2. Use console.log in your JavaScript, and view it in Xcode's console.
        injectJavaScript(script: "console.log('Hello from JS');") // Example
    }
}

// MARK: - WKScriptMessageHandler (7. Web to Swift Communication)

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Handle messages from JavaScript.  The `message.name` is the "bridge" name.

        if message.name == "jsHandler" {
            print("Received message from JS (jsHandler): \(message.body)")
            // Handle the message.  message.body contains the data sent from JS.
            if let messageBody = message.body as? String {
                // Do something with the string message
                print("Message body (string): \(messageBody)")
            } else if let messageBody = message.body as? [String: Any] {
                // Handle dictionary messages
                print("Message body (dictionary): \(messageBody)")
            } // ... handle other data types as needed ...

        } else if message.name == "connectWebToApp" {
            // Data transfer example (Q13)
            dataTextField.text = message.body as? String
        }
    }
}

// MARK: - WKNavigationDelegate (8. Navigation Handling, 4. Blocking Requests, 9. Modifying Requests)

extension WebViewController: WKNavigationDelegate {

    // Decide whether to allow or cancel a navigation.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        // 8. Handle Navigation (Example: Prevent navigation to "restricted.com")
        if let host = navigationAction.request.url?.host, host.contains("restricted.com") {
            print("Navigation to restricted.com blocked.")
            decisionHandler(.cancel)
            return // IMPORTANT: Return after calling decisionHandler
        }

        // 4. Blocking Requests (Example: Block requests containing "ads.com")
        if let urlString = navigationAction.request.url?.absoluteString, urlString.contains("ads.com") {
            print("Ad request blocked: \(urlString)")
            decisionHandler(.cancel)
            return
        }

        // 9. Modifying Requests (Example:  Add a custom header)
        //    WARNING: This example modifies the *original* request.  For more complex
        //    modifications, create a *new* URLRequest and navigate to that instead.
        if var modifiedRequest = navigationAction.request.url.map({ URLRequest(url: $0) }) {
            modifiedRequest.addValue("MyCustomHeaderValue", forHTTPHeaderField: "X-Custom-Header")
            // Note: You can't directly load this modified request here.  You would need
            // to cancel the current navigation and start a new one with the modified request.
            // This is more complex, and often, the WKURLSchemeHandler (below) is better.
        }

        // Allow all other navigations
        decisionHandler(.allow)
    }


    // Handle navigation responses (optional, but often useful)
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // You can inspect the response here (e.g., check HTTP status codes)
        if let httpResponse = navigationResponse.response as? HTTPURLResponse {
            print("Navigation response status code: \(httpResponse.statusCode)")
        }
        decisionHandler(.allow) // Or .cancel if you want to block based on the response
    }

    // Handle page load progress (optional)
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Page loading started")
        // You could show a loading indicator here
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page loading finished")
        // Hide loading indicator, if you showed one
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Page loading failed: \(error)")
        // Handle the error (e.g., show an error message to the user)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Provisional navigation failed: \(error)") // Often more detailed error
    }


    // 11. Cookies and Session Management (Basic Example)
    func handleCookies() {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore

        // Get all cookies
        cookieStore.getAllCookies { cookies in
            for cookie in cookies {
                print("Cookie: \(cookie)")
            }
        }

        // Set a cookie (Example)
        if let cookie = HTTPCookie(properties: [
            .domain: "example.com",  // Replace with your domain
            .path: "/",
            .name: "MyCookie",
            .value: "CookieValue",
            .secure: "TRUE",
            .expires: Date(timeIntervalSinceNow: 3600) // Expires in 1 hour
        ]) {
            cookieStore.setCookie(cookie) {
                print("Cookie set successfully")
            }
        }
    }

    // For more advanced cookie/session management, you might use a custom URL scheme handler
    // and manage cookies manually, especially if you need to share cookies between
    // the web view and your native app's networking code.
}

// MARK: - WKURLSchemeHandler (Advanced: Custom URL Schemes and Resource Loading)
// This is a powerful, but more advanced, technique for intercepting and handling
// specific URL requests.  It's often *better* than trying to modify requests
// within `decidePolicyFor navigationAction`.

// Example:  If you want to handle requests to "myapp://custom-resource", you would:
// 1. Register the scheme in your Info.plist.
// 2. Set the scheme handler in your WKWebViewConfiguration.
// 3. Implement this protocol to handle the requests.
//  (Not fully implemented here, as it requires more context)

/*
 extension WebViewController: WKURLSchemeHandler {
 func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
 if urlSchemeTask.request.url?.scheme == "myapp" {
 // Handle the custom scheme request.  urlSchemeTask.request.url is the URL.
 // You are responsible for fetching the data and calling:
 // - urlSchemeTask.didReceive(response)
 // - urlSchemeTask.didReceive(data)
 // - urlSchemeTask.didFinish()  (or urlSchemeTask.didFailWithError())
 }
 }

 func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
 // Clean up any resources associated with the task.
 }
 }
 */

// MARK: - Preview


import SwiftUI

// Use in SwiftUI view
struct WebControllerContentView: View {
    var body: some View {
        WebViewControllerUIKitViewControllerWrapper()
            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
    }
}

// UIViewControllerRepresentable implementation
struct WebViewControllerUIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = WebViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> WebViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return WebViewController()
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
        // Update the view controller if needed
    }
}


// Before iOS 17, use this syntax for preview UIKit view controller
struct WebViewControllerUIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        WebViewControllerUIKitViewControllerWrapper()
    }
}
