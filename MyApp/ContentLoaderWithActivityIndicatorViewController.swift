//
//  ContentLoaderWithActivityIndicatorViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/21/24.
//


import UIKit
import WebKit

class ContentLoaderWithActivityIndicatorViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    let contentURL = URL(string: "https://www.medium.com")!
    var activityIndicator: UIActivityIndicatorView!
    var progressView: UIProgressView!
    var spinnerWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize WKWebView
        webView = WKWebView(frame: self.view.bounds)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(webView)
        
        // Initialize the activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        // Initialize the progress view
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0,
                                    y: self.view.safeAreaInsets.top,
                                    width: self.view.bounds.width,
                                    height: 2)
        progressView.autoresizingMask = [.flexibleWidth]
        progressView.progress = 0.0
        progressView.isHidden = true
        self.view.addSubview(progressView)
        
        // Observe estimatedProgress
        webView.addObserver(self,
                            forKeyPath: "estimatedProgress",
                            options: .new,
                            context: nil)
        
        // Fetch and load content
        fetchAndLoadContent()
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    func fetchAndLoadContent() {
        // Create a DispatchWorkItem to start the spinner after 0.5 seconds delay
        spinnerWorkItem = DispatchWorkItem { [weak self] in
            self?.activityIndicator.startAnimating()
        }
        
        // Schedule the spinner to start after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: spinnerWorkItem!)
        
        let urlRequest = URLRequest(url: contentURL)
        
        // Start the network request
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Cancel the spinner work item if it's not executed yet
            self.spinnerWorkItem?.cancel()
            self.spinnerWorkItem = nil // Avoid accidental reuse
            
            DispatchQueue.main.async {
                // Stop the activity indicator if it's animating
                if self.activityIndicator.isAnimating {
                    self.activityIndicator.stopAnimating()
                }
                
                // Handle errors
                if let error = error {
                    self.showErrorAlert(message: "Error fetching content: \(error.localizedDescription)")
                    return
                }
                
                // Handle data
                if let data = data, var htmlString = String(data: data, encoding: .utf8) {
                    htmlString = self.modifyHTMLContent(htmlString)
                    
                    // Reset progress view
                    self.progressView.progress = 0.0
                    self.progressView.isHidden = false
                    
                    // Load HTML string
                    self.webView.loadHTMLString(htmlString, baseURL: self.contentURL)
                }
            }
        }
        
        task.resume()
    }
    
    func modifyHTMLContent(_ html: String) -> String {
        var modifiedHTML = html
        // Example: Inject custom CSS
        let customCSS = """
        <style>
        body { background-color: #101010; }
        h1 { color: blue; }
        </style>
        """
        if let range = modifiedHTML.range(of: "<head>") {
            modifiedHTML.insert(contentsOf: customCSS, at: range.upperBound)
        } else {
            modifiedHTML = "<head>\(customCSS)</head>" + modifiedHTML
        }
        return modifiedHTML
    }
    
    // Observe value changes for estimatedProgress
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            progressView.isHidden = webView.estimatedProgress >= 1.0
        }
    }
    
    // Show error alert
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Load Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil))
        self.present(alert, animated: true)
    }
}
