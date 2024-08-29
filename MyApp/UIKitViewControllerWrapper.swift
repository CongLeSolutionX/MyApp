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
    
    // UI Elements
    private let firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter first name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter last name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let originalInputLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private let inoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Use Inout", for: .normal)
        button.backgroundColor = .systemOrange
        return button
    }()
    
    private let computedPropertyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Use Computed Property", for: .normal)
        button.backgroundColor = .systemGreen
        return button
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        // Setup UI
        setupUI()
        
        // Add actions
        inoutButton.addTarget(self, action: #selector(handleInoutButton), for: .touchUpInside)
        computedPropertyButton.addTarget(self, action: #selector(handleComputedPropertyButton), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTextField)
        view.addSubview(originalInputLabel)
        view.addSubview(inoutButton)
        view.addSubview(computedPropertyButton)
        view.addSubview(resultLabel)
        
        NSLayoutConstraint.activate([
            firstNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            firstNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10),
            lastNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lastNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            originalInputLabel.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 10),
            originalInputLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            originalInputLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            inoutButton.topAnchor.constraint(equalTo: originalInputLabel.bottomAnchor, constant: 20),
            inoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            computedPropertyButton.topAnchor.constraint(equalTo: inoutButton.bottomAnchor, constant: 10),
            computedPropertyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            resultLabel.topAnchor.constraint(equalTo: computedPropertyButton.bottomAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func handleInoutButton() {
        guard var firstName = firstNameTextField.text, var lastName = lastNameTextField.text else { return }
        originalInputLabel.text = "Original Input:\nFirst Name: \(firstName)\nLast Name: \(lastName)"
        makeFullName(&firstName, &lastName)
        resultLabel.text = "Inout Result:\n\(firstName) \(lastName)"
    }
    
    @objc private func handleComputedPropertyButton() {
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text else { return }
        
        // Display the original input values
        originalInputLabel.text = "Original Input:\nFirst Name: \(firstName)\nLast Name: \(lastName)"
        
        
        // Create a Person instance using the input values
        var person = Person(firstName: firstName, lastName: lastName)
        
        // Display the computed full name based on the initial input
        resultLabel.text = "Computed Property Result:\n\(person.fullName)"
        
        // Demonstrate the dynamic nature of computed properties:
        // By setting the fullName to a new value, we trigger the setter of the computed property.
        // This setter splits the new full name and updates the firstName and lastName properties.
        person.fullName = "Jane Smith"
        
        // Update the result label to show the effect of setting the computed property
        // This shows how the internal state (firstName and lastName) is modified by the computed property.
        resultLabel.text! += "\nUpdated to:\n\(person.firstName) \(person.lastName)"
    }
    
    func makeFullName(_ firstName: inout String, _ lastName: inout String) {
        firstName = firstName.capitalized
        lastName = lastName.capitalized
    }
    
    struct Person {
        var firstName: String
        var lastName: String
        var fullName: String {
            get {
                return "\(firstName) \(lastName)".capitalized
            }
            set {
                let names = newValue.split(separator: " ")
                if names.count == 2 {
                    firstName = String(names[0])
                    lastName = String(names[1])
                }
            }
        }
    }
}
