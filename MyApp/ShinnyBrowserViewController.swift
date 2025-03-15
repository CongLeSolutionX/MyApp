//
//  ShinnyBrowserViewController.swift
//  MyApp
//
//  Created by Cong Le on 3/15/25.
//

import UIKit
@preconcurrency import WebKit

class ShinnyBrowserViewController: UIViewController {

    // MARK: - UI Elements

    lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6 // Light gray, similar to the screenshot
        return view
    }()

    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()

    lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .systemBlue
         button.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        return button
    }()

    lazy var urlField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.placeholder = "Enter URL"
        textField.delegate = self  // Make sure to implement UITextFieldDelegate
        textField.returnKeyType = .go
        return textField
    }()
    
    lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(refreshPage), for: .touchUpInside)
        return button
    }()


    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .systemBlue
        //  button.addTarget(self, action: #selector(showMoreOptions), for: .touchUpInside) // Implement this if needed
        return button
    }()

    lazy var divider: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()

    lazy var progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .lightGray
        progressView.progressTintColor = .systemBlue
        return progressView
    }()

    lazy var webViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white // Consistent with typical web content area
        return view
    }()

     lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self // Set the navigation delegate
        return webView
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadInitialPage() // Added to load a default page
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white  // Main view background
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(forwardButton)
        headerView.addSubview(urlField)
        headerView.addSubview(refreshButton)
        headerView.addSubview(moreButton)
        headerView.addSubview(progressBar)
        headerView.addSubview(divider)
        view.addSubview(webViewContainer)
        webViewContainer.addSubview(webView)
    }
    
     // MARK: - Constraints Setup
    private func setupConstraints() {
       NSLayoutConstraint.activate([

            // Header View
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50), // Adjust as needed

            // Back Button
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            // Forward Button
            forwardButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            forwardButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            forwardButton.widthAnchor.constraint(equalToConstant: 44),
            forwardButton.heightAnchor.constraint(equalToConstant: 44),

           // URL Field
            urlField.leadingAnchor.constraint(equalTo: forwardButton.trailingAnchor, constant: 8),
            urlField.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            urlField.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -8),
           

            // Refresh Button
            refreshButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8),
            refreshButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 44),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),

            // More Button
            moreButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
            moreButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            moreButton.widthAnchor.constraint(equalToConstant: 44),
            moreButton.heightAnchor.constraint(equalToConstant: 44),
           
           //Progress Bar
           progressBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
           progressBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
           progressBar.topAnchor.constraint(equalTo: headerView.bottomAnchor),
           progressBar.heightAnchor.constraint(equalToConstant: 2),  // Thin progress bar

           //Divider
           divider.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
           divider.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
           divider.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
           divider.heightAnchor.constraint(equalToConstant: 1),


            // Web View Container
            webViewContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 1), // Right below the header
            webViewContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webViewContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Web View (inside container)
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc func refreshPage() {
        webView.reload()
    }

    // MARK: - Initial Page Load

    private func loadInitialPage() {
         if let url = URL(string: "https://www.apple.com") { // Load a default URL
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

// MARK: - UITextFieldDelegate

extension ShinnyBrowserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, let url = URL(string: text) {
            // URL validation and formatting
            var validURL = url
            if validURL.scheme == nil {
                if let correctedURL = URL(string: "https://" + text) {
                    validURL = correctedURL
                }
            }
            
            let request = URLRequest(url: validURL)
            webView.load(request)
        }
        textField.resignFirstResponder() // Hide keyboard
        return true
    }
}

// MARK: - WKNavigationDelegate

extension ShinnyBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressBar.progress = 0.0
        progressBar.isHidden = false // Show progress bar
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Update the UI (e.g., enable/disable back/forward buttons)
       backButton.isEnabled = webView.canGoBack
       forwardButton.isEnabled = webView.canGoForward

       // Update the URL field.  Use a better check for valid URLs in production
       urlField.text = webView.url?.absoluteString
    }


    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       progressBar.isHidden = true // Hide progress bar when loading is complete

        // Update the UI (e.g., enable/disable back/forward buttons)
       backButton.isEnabled = webView.canGoBack
       forwardButton.isEnabled = webView.canGoForward

        // Update the URL field.
       urlField.text = webView.url?.absoluteString
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressBar.isHidden = true // Hide progress bar on error
        // Handle errors appropriately.  Show an alert, perhaps.
        print("Failed to load: \(error.localizedDescription)")

        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled { // -999 = cancelled, don't show an error
             showError(message: error.localizedDescription)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Handle provisional navigation errors (e.g., server unavailable)
         progressBar.isHidden = true
        print("Failed provisional navigation: \(error.localizedDescription)")
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
             showError(message: error.localizedDescription)
        }
    }
    
    //Progress bar update
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        //This is a good place to potentially check for certain types of URLs, like PDFs, and handle them specially
        if let url = navigationAction.request.url, url.pathExtension == "pdf" {
            //Handle PDF, perhaps open in a separate view.
            // presentPDF(with: url)
            decisionHandler(.cancel) //Don't load in this WebView
            return
        }
        
        // Estimate progress. This is simplified; you'll likely want to observe the estimatedProgress property of the webView
        let progress = (webView.estimatedProgress > 0.1) ? webView.estimatedProgress : 0.1
        progressBar.setProgress(Float(progress), animated: true)
        decisionHandler(.allow)
    }

    // Helper function to show an error message
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
