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
    
    // Constants for UI Configuration
    private enum UIConfig {
        static let labelFontSize: CGFloat = 24
        static let labelBackgroundColor: UIColor = .lightGray
        static let buttonBackgroundColor: UIColor = .green
        static let subtractButtonBackgroundColor: UIColor = .red
        static let buttonTitleColor: UIColor = .black
        static let buttonSpacing: CGFloat = 20
    }
    
    // UI Elements
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: UIConfig.labelFontSize)
        label.backgroundColor = UIConfig.labelBackgroundColor
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.setTitleColor(UIConfig.buttonTitleColor, for: .normal)
        button.backgroundColor = UIConfig.buttonBackgroundColor
        button.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var subtractButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Subtract", for: .normal)
        button.setTitleColor(UIConfig.buttonTitleColor, for: .normal)
        button.backgroundColor = UIConfig.subtractButtonBackgroundColor
        button.addTarget(self, action: #selector(subtractTapped), for: .touchUpInside)
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
        performOperation(.add)
    }
    
    @objc private func subtractTapped() {
        performOperation(.subtract)
    }
    
    private func performOperation(_ operation: ArithmeticOperation) {
        switch operation {
        case .add:
            result += 1
        case .subtract:
            result -= 1
        }
    }
}

// Arithmetic Operation Enum
private enum ArithmeticOperation {
    case add
    case subtract
}
