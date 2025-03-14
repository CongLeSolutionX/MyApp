//
//  TextKitViewController.swift
//  MyApp
//
//  Created by Cong Le on 3/14/25.
//

import UIKit

// MARK: - Custom Text Attachment

/// A custom text attachment that draws a colored box.
class BoxAttachment: NSTextAttachment {
    let boxColor: UIColor

    init(color: UIColor) {
        self.boxColor = color
        super.init(data: nil, ofType: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Define the size of the attachment.
    override func attachmentBounds(for textContainer: NSTextContainer?,
                                   proposedLineFragment lineFrag: CGRect,
                                   glyphPosition position: CGPoint,
                                   characterIndex charIndex: Int) -> CGRect {
        return CGRect(x: 0, y: 0, width: 20, height: 20)
    }
    
    // Draw the colored box.
    override func image(forBounds imageBounds: CGRect,
                        textContainer: NSTextContainer?,
                        characterIndex charIndex: Int) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: imageBounds.size)
        return renderer.image { context in
            boxColor.setFill()
            context.fill(imageBounds)
        }
    }
}

// MARK: - Custom Layout Manager

/// A custom NSTextLayoutManager that highlights the first paragraph.
//class HighlightFirstLineLayoutManager: NSTextLayoutManager {
//    func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
////        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
//        
//        // Safely obtain the first paragraph range from NSTextContentStorage
//        guard let textContentStorage = self.textContentStorage,
//              let firstParagraphRange = textContentStorage.textParagraphRanges.first,
//              let container = textContainer(forGlyphAt: firstParagraphRange.location),
//              let firstGlyphRange = glyphRange(for: firstParagraphRange)
//        else { return }
//        
//        let highlightRect = boundingRect(forGlyphRange: firstGlyphRange, in: container)
//                            .offsetBy(dx: origin.x, dy: origin.y)
//        UIColor.yellow.withAlphaComponent(0.3).setFill()
//        UIBezierPath(rect: highlightRect).fill()
//    }
//}

// MARK: - Main ViewController

class TextKitViewController: UIViewController, NSTextContentStorageDelegate {
    
    private var textView: UITextView!
    private var textStorage: NSTextContentStorage!
    private var layoutManager: NSTextLayoutManager!
    private var textContainer: NSTextContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTextKit()
        setupTextView()
        configureAttributedText()
        configureExclusionPath()
        observeDynamicTypeChanges()
        configureAccessibility()
    }
    
    // MARK: - TextKit Setup
    
    private func setupTextKit() {
        textStorage = NSTextContentStorage()
        textStorage.delegate = self
//        layoutManager = HighlightFirstLineLayoutManager()
        textStorage.addTextLayoutManager(layoutManager)
        textContainer = NSTextContainer()
        layoutManager.textContainer = textContainer
    }
    
    private func setupTextView() {
        textView = UITextView(frame: .zero, textContainer: textContainer)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configure Attributed String
    
    private func configureAttributedText() {
        let baseString = """
        TextKit2 Demo:
        
        Highlighted first line.
        
        Sample text attributes: bold, blue, kerning, ligatures, strikethrough, underline, and a link.
        """
        let attributed = NSMutableAttributedString(
            string: baseString,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]
        )
        
        // Bold and blue for first four characters.
        attributed.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.blue
        ], range: NSRange(location: 0, length: 4))
        
        // Paragraph style with extra line spacing and justified alignment.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.alignment = .justified
        attributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributed.length))
        
        // Add kerning and ligatures to part of the text.
        if attributed.length >= 30 {
            attributed.addAttributes([
                .kern: 2.0,
                .ligature: 1
            ], range: NSRange(location: 10, length: 10))
        }
        
        // Apply strikethrough and double underline for a sample range.
        if attributed.length >= 70 {
            attributed.addAttributes([
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .underlineStyle: NSUnderlineStyle.double.rawValue,
                .underlineColor: UIColor.red
            ], range: NSRange(location: 50, length: 15))
        }
        
        // Add a link attribute.
        if let url = URL(string: "https://www.apple.com"), attributed.length >= 90 {
            attributed.addAttribute(.link, value: url, range: NSRange(location: 80, length: 5))
        }
        
        // Append custom text attachments.
        let greenAttachment = BoxAttachment(color: .green)
        let pinkAttachment = BoxAttachment(color: .systemPink)
        
        attributed.append(NSAttributedString(string: "\n "))
        attributed.append(NSAttributedString(attachment: greenAttachment))
        attributed.append(NSAttributedString(string: " Custom green box attachment.\n"))
        attributed.append(NSAttributedString(string: "\n "))
        attributed.append(NSAttributedString(attachment: pinkAttachment))
        attributed.append(NSAttributedString(string: " Custom pink box attachment.\n"))
        
        textStorage.attributedString = attributed
    }
    
    // MARK: - Exclusion Path Setup
    
    private func configureExclusionPath() {
        // Create an oval exclusion path to force text to flow around it.
        let exclusionOval = UIBezierPath(ovalIn: CGRect(x: 50, y: 150, width: 100, height: 100))
        textView.textContainer.exclusionPaths = [exclusionOval]
    }
    
    // MARK: - Dynamic Type
    
    private func observeDynamicTypeChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dynamicTypeChanged),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    @objc private func dynamicTypeChanged() {
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    // MARK: - Accessibility Configuration
    
    private func configureAccessibility() {
        textView.isAccessibilityElement = true
        textView.accessibilityLabel = "Editable Text View"
    }
    
    // MARK: - NSTextContentStorageDelegate (optional)
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage,
                            textParagraphWith range: NSRange) -> NSTextParagraph? {
        // Customize paragraph creation if needed.
        return nil
    }
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage,
//                            didProcessEditing editedMask: NSTextContentStorageEditActions,
                            range: NSRange,
                            changeInLength delta: Int) {
        // Optional: Handle character or attribute changes.
    }
}

/// To run this code, set` TextKitViewController` as the rootViewController in your AppDelegate or SceneDelegate.
