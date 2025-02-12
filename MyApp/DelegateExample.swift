//
//  DelegateExample.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//

import Foundation
import WebKit

class DelegateExample: NSObject, URLSessionDataDelegate {
    var webView: WKWebView? // Optional WKWebView for display
    private lazy var session: URLSession = { // As per Listing 2, lazy instantiation
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true // Good practice as per documentation
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    var receivedData: Data? // Buffer to accumulate received data chunks, as in Listing 3
    var loadButtonEnabledStateChanged: ((Bool) -> Void)? // Closure to update UI state (e.g., button enabled/disabled) - optional for console demo

    init(webView: WKWebView? = nil) {
        self.webView = webView
        super.init()
    }

    func startDataTaskWithDelegate() {
        loadButtonEnabledStateChanged?(false) // Disable load button if UI state is being managed externally
        guard let url = URL(string: "https://www.example.com/") else {
            print("Error: Invalid URL")
            return
        }
        receivedData = Data() // Initialize receivedData for each new task
        let task = session.dataTask(with: url)
        task.resume() // Start the task
    }

    // MARK: - URLSessionDataDelegate methods

    // Delegate method to validate response before proceeding (as in Listing 3)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              let mimeType = httpResponse.mimeType,
              mimeType == "text/html" else {
            completionHandler(.cancel) // Cancel task if conditions not met
            return
        }
        completionHandler(.allow) // Allow task to proceed if response is valid
    }

    // Delegate method to receive data chunks as they arrive (as in Listing 3)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.receivedData?.append(data) // Append new data chunk to the buffer
    }

    // MARK: - URLSessionTaskDelegate method

    // Delegate method called when task completes (success or failure) - as in Listing 3 & Diagram 4
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { // Update UI on the main thread
            self.loadButtonEnabledStateChanged?(true) // Re-enable load button
            if let error = error {
                self.handleClientError(error) // Handle any transport-level errors
            } else if let safeReceivedData = self.receivedData, let string = String(data: safeReceivedData, encoding: .utf8) {
                // Process and use the complete data (e.g., load in WKWebView)
                self.webView?.loadHTMLString(string, baseURL: task.currentRequest?.url)
                // For console-only, print the string:
                // print("Delegate received HTML content:\n\(string)")
            }
        }
    }

    private func handleClientError(_ error: Error) {
        print("Delegate Client error: \(error.localizedDescription)")
        // Handle client-side errors received via delegate
    }
}

// Usage example (with optional WKWebView and button state update):
// let webViewInstance = WKWebView()
// let delegateExample = DelegateExample(webView: webViewInstance)
// delegateExample.loadButtonEnabledStateChanged = { isEnabled in
//     // Update button enabled state on UI, e.g., myButton.isEnabled = isEnabled
// }
// delegateExample.startDataTaskWithDelegate()
//
//// Console-only usage:
//let delegateExample = DelegateExample()
//delegateExample.startDataTaskWithDelegate()
