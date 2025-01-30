//
//  SafariViewController.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.
//


import UIKit
import SafariServices

class SafariViewController: UIViewController {
    
    // MARK: - Properties
    
    let urlString: String // Made let as urlString is set once at init
    let pageIndex: Int
    private var safariViewController: SFSafariViewController?
    
    // MARK: - Initializer
    
    init(urlString: String) {
        self.urlString = urlString
        self.pageIndex = 0 // Default value - consider if this should always be passed in
        super.init(nibName: nil, bundle: nil)
    }
    
    // Designated initializer to require pageIndex
    init(urlString: String, pageIndex: Int) {
        self.urlString = urlString
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebContent()
    }
    
    // MARK: - Helper Methods
    
    private func loadWebContent() {
        guard let url = URL(string: urlString) else {
            printLog("[SafariViewController] Error: Invalid URL string - \(urlString)") // Error logging
            return
        }
        
        let safariConfig = SFSafariViewController.Configuration()
        safariConfig.entersReaderIfAvailable = false
        
        let safariVC = SFSafariViewController(url: url, configuration: safariConfig)
        safariVC.delegate = self
        
        safariVC.preferredControlTintColor = .yellow
        safariVC.preferredBarTintColor = .black
        
        addChild(safariVC)
        view.addSubview(safariVC.view)
        safariVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            safariVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            safariVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            safariVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safariVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        safariVC.didMove(toParent: self)
        
        self.safariViewController = safariVC
    }
}

// MARK: - SFSafariViewControllerDelegate
extension SafariViewController: SFSafariViewControllerDelegate {
    // Implement delegate methods if needed
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Handle when the user taps 'Done'
    }
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        // Called when the initial URL load completes
    }
}
