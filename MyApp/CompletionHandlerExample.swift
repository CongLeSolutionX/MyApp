//
//  CompletionHandlerExample.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//

import Foundation
import WebKit // Required if you intend to load HTML into WKWebView

class CompletionHandlerExample {
    var webView: WKWebView? // Assuming a WKWebView is used for display, optional for console example

    init(webView: WKWebView? = nil) {
        self.webView = webView
        
        webView?.uiDelegate = self
        webView?.allowsBackForwardNavigationGestures = true
        webView?.allowsLinkPreview = true
        webView?.navigationDelegate = self
    }

    func startDataTaskWithCompletionHandler() {
        guard let url = URL(string: "https://example.com") else {
            print("Error: Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.handleClientError(error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response)
                return
            }

            if let mimeType = httpResponse.mimeType, mimeType == "text/html", let safeData = data, let string = String(data: safeData, encoding: .utf8) {
                DispatchQueue.main.async {
                    // Assuming self.webView is available and valid for WKWebView example
                    self.webView?.loadHTMLString(string, baseURL: url)
                    // For a console-only example, you could simply print the string:
                     print("Received HTML content:\n\(string)")
                }
            } else {
                print("Response was not HTML or encoding failed.")
            }
        }
        task.resume()
    }

    private func handleClientError(_ error: Error) {
        print("Client error: \(error.localizedDescription)")
        // Handle client-side errors (e.g., network issues, URL problems)
    }

    private func handleServerError(_ response: URLResponse?) {
        if let httpResponse = response as? HTTPURLResponse {
            print("Server error with status code: \(httpResponse.statusCode)")
            // Handle server-side errors based on status code
        } else {
            print("Server error with invalid response.")
        }
    }
}

// MARK: - WKUIDelegate
extension CompletionHandlerExample: WKUIDelegate {
    func isEqual(_ object: Any?) -> Bool {
        true
    }
    
    var hash: Int {
        return 1
    }
    
    var superclass: AnyClass? {
        return nil
    }
    
    func `self`() -> Self {
     return self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func isProxy() -> Bool {
        return false
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        return false
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        return false
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        return false
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        return false
    }
    
    var description: String {
        return ""
    }
    
    
}

// MARK: - WKNavigationDelegate
extension CompletionHandlerExample: WKNavigationDelegate {
    
}

// Usage example (if you have a WKWebView instance):
// let webViewInstance = WKWebView()
// let example = CompletionHandlerExample(webView: webViewInstance)
// example.startDataTaskWithCompletionHandler()

//// Console-only usage example:
//let example = CompletionHandlerExample()
//example.startDataTaskWithCompletionHandler()
