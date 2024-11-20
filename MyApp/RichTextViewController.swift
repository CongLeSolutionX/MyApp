//
//  RichTextViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/19/24.
//

import UIKit

class RichTextViewController: UIViewController {

    let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the UITextView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false  // Disable editing
        textView.isScrollEnabled = true  // Enable scrolling
        textView.dataDetectorTypes = [.link]  // Enable link detection
        textView.backgroundColor = UIColor.systemBackground

        // Add the textView to the view hierarchy
        view.addSubview(textView)

        // Set up constraints
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        // Set the attributed text
        textView.attributedText = createAttributedText()
    }

    func createAttributedText() -> NSAttributedString {
        // Create mutable attributed string
        let attributedText = NSMutableAttributedString()

        // Define attributes
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.systemBlue
        ]

        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.systemGray
        ]

        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]

        let bulletPointAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]

        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: URL(string: "https://developer.apple.com")!
        ]

        // Create strings with attributes
        let titleString = NSAttributedString(string: "Welcome to Rich Text Rendering\n\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: "Here's what you can do:\n\n", attributes: subtitleAttributes)
        let bodyString = NSAttributedString(string: "This text view demonstrates how to display formatted text using NSAttributedString. You can apply various styles such as:\n\n", attributes: bodyAttributes)

        // Bullet points
        let bulletPointList = NSMutableAttributedString()
        let bullet = "•  "

        let bulletPoints = [
            "Bold and Italic Text",
            "Colored Text",
            "Underlined Text",
            "Different Fonts and Sizes",
            "Links"
        ]

        for point in bulletPoints {
            let attributedBullet = NSMutableAttributedString(string: bullet, attributes: bulletPointAttributes)
            let attributedText = NSMutableAttributedString(string: point + "\n", attributes: bodyAttributes)
            attributedBullet.append(attributedText)
            bulletPointList.append(attributedBullet)
        }

        // Example of bold and italic text
        let boldItalicAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(descriptor:
                            UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withSymbolicTraits([.traitBold, .traitItalic])!,
                          size: 16),
            .foregroundColor: UIColor.label
        ]
        let boldItalicString = NSAttributedString(string: "\nThis is bold and italic text.\n", attributes: boldItalicAttributes)

        // Example of underlined text
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.systemRed
        ]
        let underlineString = NSAttributedString(string: "\nThis text is underlined and red.\n", attributes: underlineAttributes)

        // Example of a link
        let linkString = NSAttributedString(string: "\nVisit Apple's Developer Site.\n", attributes: linkAttributes)

        // Combine all parts into the attributed text
        attributedText.append(titleString)
        attributedText.append(subtitleString)
        attributedText.append(bodyString)
        attributedText.append(bulletPointList)
        attributedText.append(boldItalicString)
        attributedText.append(underlineString)
        attributedText.append(linkString)

        return attributedText
    }
}
