//
//  DemoAutoLayoutViewController.swift
//  MyApp
//
//  Created by Cong Le on 8/20/24.
//

import UIKit

class DemoAutoLayoutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupHorizontalStackLayout()
        // self.setupVerticalStackLayout()
    }
    
   
    /// Sets up a horizontal stack view containing two buttons and demonstrates how content hugging and content compression resistance priorities affect their layout.
    ///
    /// This function creates two buttons, adds them to a horizontal stack view, and sets up the stack view's layout constraints.
    /// It shows how to control the layout behavior of the buttons by setting their content hugging and content compression resistance priorities.
    func setupHorizontalStackLayout() {
        // Create two buttons
        let button1 = UIButton(type: .system)
        button1.setTitle("Button 1", for: .normal)
        button1.backgroundColor = .lightGray
        
        let button2 = UIButton(type: .system)
        button2.setTitle("Button 2", for: .normal)
        button2.backgroundColor = .lightGray
        
        // Create a horizontal stack view
        let stackView = UIStackView(arrangedSubviews: [button1, button2])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the stack view to the main view
        view.addSubview(stackView)
        
        // Set up constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        
        // Demonstrate content hugging and content compression resistance
        self.setHighPriorityHuggingAndCompression(button1: button1, button2: button2)
        // self.setLowPriorityHuggingAndCompression(button1: button1, button2: button2)
    }
    
    /// Sets low content hugging and low content compression resistance priorities for the buttons in the horizontal stack view.
    ///
    /// This configuration allows the first button (firstButton) to stretch horizontally if needed and allows the second button (secondButton) to compress horizontally if needed.
    ///
    /// - Parameters:
    ///   - firstButton: The first button in the horizontal stack view. It can stretch horizontally if needed.
    ///   - secondButton: The second button in the horizontal stack view. It can compress horizontally if needed.
    func setLowPriorityHuggingAndCompression(button1: UIButton, button2: UIButton) {
        button1.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        button2.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
    }
    
 
    /// Sets high content hugging and high content compression resistance priorities for the buttons in the horizontal stack view.
    ///
    /// This configuration makes the first button (firstButton) resist stretching horizontally and the second button (secondButton) resist compressing horizontally.
    ///
    /// - Parameters:
    ///   - firstButton: The first button in the horizontal stack view. It resists stretching horizontally.
    ///   - secondButton: The second button in the horizontal stack view. It resists compressing horizontally.
    func setHighPriorityHuggingAndCompression(button1: UIButton, button2: UIButton) {
        button1.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        button2.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        }
    
    
    
    /// Sets up a vertical stack view containing two labels and demonstrates how content hugging and content compression resistance priorities affect their layout.
    /// 
    /// This function creates two labels, adds them to a vertical stack view, and sets up the stack view's layout constraints.
    /// It shows how to control the layout behavior of the labels by setting their content hugging and content compression resistance priorities.
    func setupVerticalStackLayout() {
            // Create two labels
            let label1 = UILabel()
            label1.text = "Label 1"
            label1.backgroundColor = .lightGray
            label1.textAlignment = .center
            
            let label2 = UILabel()
            label2.text = "Label 2"
            label2.backgroundColor = .lightGray
            label2.textAlignment = .center
            
            // Create a vertical stack view
            let stackView = UIStackView(arrangedSubviews: [label1, label2])
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add the stack view to the main view
            self.view.addSubview(stackView)
            
            // Set up constraints for the stack view
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                stackView.heightAnchor.constraint(equalToConstant: 200)
            ])
        
        // Demonstrate content hugging and content compression resistance
        self.setStretchAndPreventCompression(label1: label1, label2: label2)
        //self.setPreventStretchAndAllowCompression(label1: label1, label2: label2)
        }
    
    /// Sets low content hugging and high content compression resistance priorities for the labels in the vertical stack view.
    ///
    /// This configuration allows the first label (firstLabel) to stretch vertically if needed and ensures the second label (secondLabel) resists compressing vertically.
    ///
    /// - Parameters:
    ///   - firstLabel: The first label in the vertical stack view. It can stretch vertically if needed.
    ///   - secondLabel: The second label in the vertical stack view. It resists compressing vertically.
    func setStretchAndPreventCompression(label1: UILabel, label2: UILabel) {
        label1.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        label2.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
    }
    
    
    /// Sets high content hugging and low content compression resistance priorities for the labels in the vertical stack view.
    ///
    /// This configuration ensures the first label (firstLabel) resists stretching vertically and allows the second label (secondLabel) to compress vertically if needed.
    ///
    /// - Parameters:
    ///   - firstLabel: The first label in the vertical stack view. It resists stretching vertically.
    ///   - secondLabel: The second label in the vertical stack view. It can compress vertically if needed.
    func setPreventStretchAndAllowCompression(label1: UILabel, label2: UILabel) {
        label1.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        label2.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
    }
}
