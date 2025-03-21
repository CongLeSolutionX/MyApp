//
//  AnotherCustomWebView.swift
//  MyApp
//
//  Created by Cong Le on 3/20/25.
//

import UIKit
@preconcurrency import WebKit

class AnotherCustomWebViewController: UIViewController {

    // MARK: - Properties
    private var webView: WKWebView!
    private var progressView: UIProgressView! // For loading progress
    private var toolbar: UIToolbar!
    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    private var reloadButton: UIBarButtonItem!
    private var shareButton: UIBarButtonItem! // Added share button
    private var openInSafariButton: UIBarButtonItem! // Added open in Safari
    // No text field in this UI, removed.

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Combined setup for clarity
        loadInitialContent()
        setupObservers() // Observe for progress updates
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           // Adjust the frame of the webView to account for the toolbar and navigation bar
           webView.frame = CGRect(x: 0,
                                  y: view.safeAreaInsets.top,
                                  width: view.bounds.width,
                                  height: view.bounds.height - view.safeAreaInsets.top - toolbar.frame.size.height)
       }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white // Set a background color

        setupNavigationBar()
        setupWebView()
        setupToolbar()
        setupProgressView()
    }

    private func setupNavigationBar() {
        // 1. Close Button (Top Left)
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = closeButton

        // 2. Title (Center) -  Dynamically updated, see KVO section
        //    We set a placeholder initially; it will update via KVO.
        navigationItem.title = "Loading..."

        // 3. Menu Button (Top Right)
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(menuTapped))
        navigationItem.rightBarButtonItem = menuButton
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        webConfiguration.defaultWebpagePreferences = preferences

        let contentController = WKUserContentController()
        contentController.add(self, name: "jsHandler")
        webConfiguration.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: webConfiguration) // Frame set in viewDidLayoutSubviews
        webView.navigationDelegate = self
        view.addSubview(webView)
    }

    private func setupToolbar() {
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) // Use safe area
        ])

        // 1. Back Button
        backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(goBack))
        backButton.isEnabled = false // Initially disabled

        // 2. Forward Button
        forwardButton = UIBarButtonItem(image: UIImage(systemName: "arrow.right"), style: .plain, target: self, action: #selector(goForward))
        forwardButton.isEnabled = false // Initially disabled

        // 3. Reload Button
        reloadButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(reloadPage))

        // 4. Share Button
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        //5. Open In Safari
        openInSafariButton = UIBarButtonItem(image: UIImage(systemName: "safari"), style: .plain, target: self, action: #selector(openInSafariTapped))

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [backButton, flexibleSpace, forwardButton, flexibleSpace, reloadButton, flexibleSpace, shareButton, flexibleSpace, openInSafariButton]
    }


    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1)
        ])

        progressView.isHidden = true // Initially hidden
        progressView.progress = 0.0
    }

    // MARK: - Content Loading
      private func loadInitialContent() {
          // Load a remote URL, as per the screenshot.  Could be made configurable.
          loadRemoteURL(urlString: "https://arxiv.org/") // Use arXiv as shown in screenshot.
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


    // MARK: - Button Actions
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func menuTapped() {
        // Example: Present an action sheet with options.  Add more actions as needed.
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { _ in
            self.openInSafari()
        }))

        actionSheet.addAction(UIAlertAction(title: "Copy URL", style: .default, handler: { _ in
            UIPasteboard.general.string = self.webView.url?.absoluteString
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // For iPad support, you need to present from a source view/rect:
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(actionSheet, animated: true, completion: nil)
    }

    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc private func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc private func reloadPage() {
        webView.reload()
    }
    
    @objc private func openInSafariTapped() {
        openInSafari()
    }

    @objc private func shareTapped() {
           guard let url = webView.url else { return }

           let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)

           // For iPad, present from the share button
           if let popover = activityViewController.popoverPresentationController {
               popover.barButtonItem = shareButton
           }

           present(activityViewController, animated: true)
       }
    
    private func openInSafari() {
        if let url = webView.url {
            UIApplication.shared.open(url)
        }
    }


    // MARK: - JavaScript Interaction (Same as before, but included for completeness)
      func injectJavaScript(script: String) {
          webView.evaluateJavaScript(script) { (result, error) in
              if let error = error {
                  print("JavaScript Injection Error: \(error)")
              } else {
                  print("JavaScript executed. Result: \(result ?? "No Result")")
              }
          }
      }

    // MARK: - Key-Value Observing (KVO) for Web View Updates
    private func setupObservers() {
        // Observe loading progress
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        // Observe title changes
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        // Observe canGoBack and canGoForward for button enabling/disabling
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
    }

    // KVO Observation Handling
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            progressView.progress = Float(webView.estimatedProgress)
            progressView.isHidden = (webView.estimatedProgress >= 1.0) // Hide when loaded
        } else if keyPath == #keyPath(WKWebView.title) {
            navigationItem.title = webView.title // Update navigation bar title
        } else if keyPath == #keyPath(WKWebView.canGoBack) {
            backButton.isEnabled = webView.canGoBack
        } else if keyPath == #keyPath(WKWebView.canGoForward) {
            forwardButton.isEnabled = webView.canGoForward
        }
    }


    // IMPORTANT: Remove observers when the view controller is deallocated.
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
    }
}

// MARK: - WKScriptMessageHandler
extension AnotherCustomWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsHandler" {
            print("Received message from JS: \(message.body)")
            // Handle the message
        }
    }
}

// MARK: - WKNavigationDelegate
extension AnotherCustomWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // Example:  Block navigations to a specific host.
        if let host = navigationAction.request.url?.host, host.contains("example.com") {
             print("Navigation to example.com blocked.")
             decisionHandler(.cancel)
             return
         }
        
        // Allow all other navigations
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
          print("Page loading started")
          progressView.isHidden = false // Show progress view
      }

      func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
          print("Page loading finished")
          // Progress view is hidden via KVO
      }

      func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
          print("Page loading failed: \(error)")
          progressView.isHidden = true // Hide progress view on error
          // Consider showing an error message to the user.
      }

      func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
          print("Provisional navigation failed: \(error)") // More detailed
          progressView.isHidden = true
          // Consider showing an error message to the user.
      }
}



// MARK: - Preview


import SwiftUI

// Use in SwiftUI view
struct AnotherCustomWebViewControllerContentView: View {
   var body: some View {
       WebViewControllerUIKitViewControllerWrapper()
           .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
   }
}

// UIViewControllerRepresentable implementation
struct AnotherCustomWebViewControllerUIKitViewControllerWrapper: UIViewControllerRepresentable {
   typealias UIViewControllerType = AnotherCustomWebViewController
   
   // Step 1b: Required methods implementation
   func makeUIViewController(context: Context) -> AnotherCustomWebViewController {
       // Step 1c: Instantiate and return the UIKit view controller
       return AnotherCustomWebViewController()
   }
   
   func updateUIViewController(_ uiViewController: AnotherCustomWebViewController, context: Context) {
       // Update the view controller if needed
   }
}


// Before iOS 17, use this syntax for preview UIKit view controller
struct AnotherCustomWebViewControllerUIKitViewControllerWrapper_Previews: PreviewProvider {
   static var previews: some View {
       AnotherCustomWebViewControllerUIKitViewControllerWrapper()
   }
}
