//
//  SFViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/19/24.
//

import UIKit
import SafariServices

class SFViewController: UIViewController {

    // MARK: - Properties

    // Replace with the URL you want to load
    let urlString = "https://www.apple.com"

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup your UI components here
        setupOpenWebPageButton()
    }

    // MARK: - UI Setup

    func setupOpenWebPageButton() {
        let button = UIButton(type: .system)
        button.setTitle("Open Web Page", for: .normal)
        button.addTarget(self, action: #selector(openWebPage), for: .touchUpInside)

        // Add button to the view and set constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Actions

    @objc func openWebPage() {
        // Validate and create the URL
        guard let url = URL(string: urlString) else {
            // Handle invalid URL
            showAlert(title: "Invalid URL", message: "The URL provided is invalid.")
            return
        }

        // Create an instance of SFSafariViewController
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self

        // Customize appearance (optional)
        safariViewController.preferredControlTintColor = .white
        safariViewController.preferredBarTintColor = .darkGray

        // Present the Safari view controller
        present(safariViewController, animated: true, completion: nil)
    }

    // MARK: - Helper Methods

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        present(alertController, animated: true)
    }
}

// MARK: - SFSafariViewControllerDelegate

extension SFViewController: SFSafariViewControllerDelegate {

    // Called when the user taps the 'Done' button
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Dismiss the Safari view controller
        controller.dismiss(animated: true, completion: nil)
    }

    // Called when the initial page load completes
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            // Handle the load failure
            showAlert(title: "Load Failed", message: "The web page failed to load.")
        }
    }
}
