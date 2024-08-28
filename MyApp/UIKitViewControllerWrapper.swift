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
struct CharacterAttributes {
    var health: Int
    var strength: Int
}

struct PowerUp {
    var healthBoost: Int
    var strengthBoost: Int
}

class MyUIKitViewController: UIViewController {
    var heroAttributes = CharacterAttributes(health: 100, strength: 50)
    let dragonHeart = PowerUp(healthBoost: 20, strengthBoost: 10)

    lazy var healthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Health: \(heroAttributes.health)"
        return label
    }()
    
    lazy var strengthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Strength: \(heroAttributes.strength)"
        return label
    }()
    
    lazy var powerUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Power-Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.red, for: .highlighted)
        button.backgroundColor = .systemGreen
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(applyPowerUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        // Add UI elements to the view
        view.addSubview(healthLabel)
        view.addSubview(strengthLabel)
        view.addSubview(powerUpButton)
        
        // Set up constraints
        setupConstraints()
    }
    
    func setupConstraints() {
        healthLabel.translatesAutoresizingMaskIntoConstraints = false
        strengthLabel.translatesAutoresizingMaskIntoConstraints = false
        powerUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            healthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            healthLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            strengthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            strengthLabel.topAnchor.constraint(equalTo: healthLabel.bottomAnchor, constant: 20),
            
            powerUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            powerUpButton.topAnchor.constraint(equalTo: strengthLabel.bottomAnchor, constant: 40)
        ])
    }
    
    @objc func applyPowerUpButtonTapped() {
        // Apply the power-up to the hero's attributes by calling the applyPowerUp function.
        // The 'applyPowerUp' function takes 'attributes' as an inout parameter and 'powerUp' as an input parameter.
        // The 'inout' keyword allows the function to modify the 'heroAttributes' directly.
        applyPowerUp(attributes: &heroAttributes, powerUp: dragonHeart)
        
        // Update the labels to reflect the new attribute values after applying the power-up.
        healthLabel.text = "Health: \(heroAttributes.health)"
        strengthLabel.text = "Strength: \(heroAttributes.strength)"
    }

    func applyPowerUp(attributes: inout CharacterAttributes, powerUp: PowerUp) {
        // The 'attributes' parameter is marked as 'inout', allowing this function to modify the original variable.
        // 'powerUp' is a regular input parameter, providing the boost values for health and strength.
        
        // Increase the character's health and strength by the amounts specified in the powerUp.
        attributes.health += powerUp.healthBoost
        attributes.strength += powerUp.strengthBoost
    }
}

