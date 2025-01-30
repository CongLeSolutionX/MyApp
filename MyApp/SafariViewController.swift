//
//  SafariViewController.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.
//

//
//  WebViewController.swift

import UIKit
import SafariServices

class SafariViewController: UIViewController {
    
    // MARK: - Properties
    
    var urlString: String
    var pageIndex: Int = 0
    
    // Reference to SFSafariViewController
    private var safariViewController: SFSafariViewController?
    
    // MARK: - Initializer
    
    init(urlString: String) {
        self.urlString = urlString
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
        guard let url = URL(string: urlString) else { return }
        
        let safariConfig = SFSafariViewController.Configuration()
        safariConfig.entersReaderIfAvailable = false // Set to true if you want to enter Reader mode when available
        
        let safariVC = SFSafariViewController(url: url, configuration: safariConfig)
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .fullScreen
        
        safariVC.preferredControlTintColor = .yellow
        safariVC.preferredBarTintColor = .black // Changes the background color of the navigation bar and toolbar
        
        // Add the Safari view controller as a child view controller
        addChild(safariVC)
        safariVC.view.frame = view.bounds
        view.addSubview(safariVC.view)
        safariVC.didMove(toParent: self)
        
        safariViewController = safariVC
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
