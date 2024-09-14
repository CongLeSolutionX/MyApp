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
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        return button
    }()
    
    private let subtractButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Subtract", for: .normal)
        return button
    }()
    
    private var result: Int = 0 {
        didSet {
            resultLabel.text = "Result: \(result)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        // Setup UI
        setupUI()
        
        // Setup Actions
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        subtractButton.addTarget(self, action: #selector(subtractTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(resultLabel)
        view.addSubview(addButton)
        view.addSubview(subtractButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            addButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtractButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20),
            subtractButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // Arithmetic Operations
    @objc private func addTapped() {
        result += 1
    }
    
    @objc private func subtractTapped() {
        result -= 1
    }
}
