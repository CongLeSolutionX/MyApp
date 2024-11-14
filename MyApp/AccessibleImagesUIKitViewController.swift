//
//  AccessibleImagesUIKitViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/14/24.
//

import UIKit

class AccessibleImagesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white // Set background for clarity

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading // Left alignment
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)


        // Constraints for ScrollView and StackView (important for scrolling)
                NSLayoutConstraint.activate([
                    scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                    stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20), // Add padding
                    stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20), // Add padding
                    stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                    stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40) // Important: Width constraint relative to ScrollView
        ])


        // 1. Simple Descriptive Text
        let appleImageView = createImageView(named: "Round_logo", accessibilityLabel: "A round logo for my channel.")
        stackView.addArrangedSubview(appleImageView)


        // 2. Functional Image (Button)
        let addToCartButton = UIButton(type: .system)
        addToCartButton.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
        addToCartButton.accessibilityLabel = "Add to cart"
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        stackView.addArrangedSubview(addToCartButton)


        // 3. Image with Text
        let saleBannerView = createCombinedImageView(
            imageName: "My-meme-heineken",
            text: "Sale: 50% off",
            accessibilityLabel: "Sale: 50% off all items"
        )
        
        stackView.addArrangedSubview(saleBannerView)
        
        let imageWithLabelView = createImageWithLabelView(
            imageName: "My-meme-cordyceps",
            labelText: "For free",
            accessibilityLabel: "My meme is free"
        )
        
        stackView.addArrangedSubview(imageWithLabelView)


        // ... Other examples from SwiftUI version can be implemented similarly using UIImageView, UIButton, UILabel, etc. combined inside the stackView
        
        // 4. Group of related images:
        let imageGroupView = createImageGroupView(
            imageNames: ["My-meme-microphone", "My-meme-heineken", "My-meme-cordyceps"],
            accessibilityLabel: "A selection of fresh fruits including oranges, bananas, and grapes."
        )
        
        stackView.addArrangedSubview(imageGroupView)


    }

// MARK: - Helper functions
    // Helper functions to create image views (reusable components)
    func createImageView(named imageName: String, accessibilityLabel: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit // Maintain aspect ratio
        imageView.translatesAutoresizingMaskIntoConstraints = false
         imageView.accessibilityLabel = accessibilityLabel

        // Optional: Set a specific size if needed
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return imageView
    }
    
    func createImageWithLabelView(imageName: String, labelText: String, accessibilityLabel: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let imageView = createImageView(named: imageName, accessibilityLabel: "") // Empty label for individual image

        let label = UILabel()
        label.text = labelText
        label.translatesAutoresizingMaskIntoConstraints = false


        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .vertical  // Vertical arrangement for image and label
        stackView.spacing = 8      // Spacing between image and label
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        containerView.accessibilityLabel = accessibilityLabel   // Label for the entire view
        return containerView
    }


    func createCombinedImageView(imageName: String, text: String, accessibilityLabel: String) -> UIView {
        let containerView = UIView() /* Container for image and text */
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFill // Fill container, clipping if necessary
        imageView.translatesAutoresizingMaskIntoConstraints = false


        containerView.addSubview(imageView)
        containerView.addSubview(label)

        NSLayoutConstraint.activate([
               imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
               imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
           ])


        containerView.accessibilityLabel = accessibilityLabel

            containerView.widthAnchor.constraint(equalToConstant: 200).isActive = true // Set width
             containerView.heightAnchor.constraint(equalToConstant: 100).isActive = true// Set height
           return containerView
    }

    func createImageGroupView(imageNames: [String], accessibilityLabel: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false


        let stackView = UIStackView()
        stackView.axis = .horizontal // Arrange images horizontally
        stackView.spacing = 8 // Set spacing between images
        stackView.alignment = .center // Center align images vertically
        stackView.distribution = .equalSpacing // Ensure even distribution across the container
        stackView.translatesAutoresizingMaskIntoConstraints = false


        for imageName in imageNames {
            let imageView = createImageView(named: imageName, accessibilityLabel: "") // Individual images don't need labels inside group
            stackView.addArrangedSubview(imageView)
        }

        containerView.addSubview(stackView)

           NSLayoutConstraint.activate([
               stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
               stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
               stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
               stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)

           ])


        containerView.accessibilityLabel = accessibilityLabel
        return containerView
    }


    @objc func addToCartTapped() {
        print("Add to Cart button tapped")
    }
}
