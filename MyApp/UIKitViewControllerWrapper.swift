//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

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
class MyUIKitViewController: UIViewController {
    lazy var userInputTextField: UITextField = {
        let textField = UITextField()
        textField.text = "  user@example.com  "
        textField.backgroundColor = UIColor.systemRed
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter your email"
        textField.delegate = self
        return textField
    }()
    
    lazy var feedbackLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Enter an email above and press 'Sanitize'"
        return label
    }()
    
    lazy var sanitizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sanitize", for: .normal)
        button.backgroundColor = .yellow
        button.addTarget(self, action: #selector(sanitizeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        view.addSubview(userInputTextField)
        view.addSubview(feedbackLabel)
        view.addSubview(sanitizeButton)
        
        setupUserInputTextField()
        setupFeedbackLabel()
        setupSanitizeButton()
        
        // Show initial email with whitespace indicators
        updateFeedbackLabelWithWhitespaceIndication()
    }
    
    func setupUserInputTextField() {
        userInputTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userInputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userInputTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            userInputTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    func setupFeedbackLabel() {
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedbackLabel.topAnchor.constraint(equalTo: userInputTextField.bottomAnchor, constant: 20),
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    func setupSanitizeButton() {
        sanitizeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sanitizeButton.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 20),
            sanitizeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func updateFeedbackLabelWithWhitespaceIndication() {
        let originalText = userInputTextField.text ?? ""
        let indicatedText = originalText.replacingOccurrences(of: " ", with: "␣")
        feedbackLabel.text = "Original Email (Might contains white spaces as special character ␣ : \(indicatedText)"
    }
    
    @objc func sanitizeButtonTapped() {
        // Retrieve the current text from the userInputTextField, providing a default value of an empty string if nil.
        var sanitizedText = userInputTextField.text ?? ""
        
        // Call the sanitizeTextField function, passing 'sanitizedText' as an input parameter.
        // This function will modify 'sanitizedText' in place, removing any leading or trailing whitespace.
        sanitizeTextField(text: &sanitizedText)
        
        // Update the feedbackLabel to display the sanitized email address.
        feedbackLabel.text = "Sanitized Email: \(sanitizedText)"
    }

    func sanitizeTextField(text: inout String) {
        // Trim leading and trailing whitespace and newlines from the input parameter 'text'.
        // The 'inout' keyword allows this function to modify the original variable passed to it.
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)

        
        // Define a regular expression for validating email format.
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        // Create an NSPredicate with the email regular expression to evaluate the sanitized text.
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        // Check if the sanitized text matches the email format.
        if !emailPredicate.evaluate(with: text) {
            // If the email format is invalid, update the feedbackLabel to inform the user.
            feedbackLabel.text = "Invalid Email Format"
        }
    }
}

// UITextFieldDelegate method
extension MyUIKitViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentText = textField.text as NSString? {
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            updateFeedbackLabelWithWhitespaceIndication(for: updatedText)
        }
        return true
    }
    
    func updateFeedbackLabelWithWhitespaceIndication(for text: String) {
        let indicatedText = text.replacingOccurrences(of: " ", with: "␣")
        feedbackLabel.text = "Current Input: \(indicatedText)"
    }
}
