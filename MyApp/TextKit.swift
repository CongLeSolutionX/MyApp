//
//  TextKit.swift
//  MyApp
//
//  Created by Cong Le on 3/14/25.
//

import UIKit

// MARK: - Custom Text Attachment

/// A custom text attachment that displays a colored box.
class BoxAttachment: NSTextAttachment {
    var boxColor: UIColor

    init(color: UIColor) {
        self.boxColor = color
        super.init(data: nil, ofType: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return CGRect(x: 0, y: 0, width: 20, height: 20)
    }

    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: imageBounds.size)
        let image = renderer.image { context in
            boxColor.setFill()
            context.fill(imageBounds)
        }
        return image
    }
}

// MARK: - Custom Text Layout Manager (TextKit 2)

/// A custom layout manager that highlights the first line of text.
class HighlightFirstLineLayoutManager: NSTextLayoutManager {
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

        guard let textContentStorage = textContentStorage else { return }

        // Get the first paragraph range.  NSTextContentStorage can manage paragraphs.
        let firstParagraphRange = textContentStorage.textParagraphRanges[0]

        // Convert the paragraph range (character range) to a glyph range.
        guard let firstParagraphGlyphRange = glyphRange(for: firstParagraphRange) else { return }

        // Get the bounding rect for the first paragraph's glyphs.
        let firstParagraphRect = boundingRect(forGlyphRange: firstParagraphGlyphRange, in: textContainer(forGlyphAt: firstParagraphGlyphRange.location)!)

        // Draw a highlight behind the first paragraph.
        UIColor.yellow.withAlphaComponent(0.3).setFill()
        UIBezierPath(rect: firstParagraphRect.offsetBy(dx: origin.x, dy: origin.y)).fill()
    }
}

// MARK: - View Controller

class ViewController: UIViewController, NSTextContentStorageDelegate {

    private var textView: UITextView!
    private var textStorage: NSTextContentStorage!
    private var layoutManager: NSTextLayoutManager!
    private var textContainer: NSTextContainer!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextKitComponents()
        setupTextView()
        setupAttributedString()
        setupExclusionPath()
        applyDynamicType()
        setupAccessibility()
    }


    // MARK: - TextKit Setup

    private func setupTextKitComponents() {
        // 1.  NSTextContentStorage (TextKit 2)
        textStorage = NSTextContentStorage()
        textStorage.delegate = self  // Set the delegate

        // 2. NSTextLayoutManager (TextKit 2)
        layoutManager = HighlightFirstLineLayoutManager()
        textStorage.addTextLayoutManager(layoutManager)

        // 3. NSTextContainer
        textContainer = NSTextContainer()
        layoutManager.textContainer = textContainer // One-to-one relationship in this case
    }

    private func setupTextView() {
        textView = UITextView(frame: .zero, textContainer: textContainer) // Associate with TextKit stack
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])

        textView.isEditable = true
        textView.isSelectable = true
        textView.font = UIFont.preferredFont(forTextStyle: .body) // For Dynamic Type
    }


    // MARK: - Attributed String Setup

    private func setupAttributedString() {
        let attributedString = NSMutableAttributedString(string: "This is an example of TextKit 2 in iOS.\n\nThe first line is highlighted using a custom NSTextLayoutManager.\n\nThis paragraph demonstrates various text attributes, including:\n\n", attributes: [.font: UIFont.preferredFont(forTextStyle: .body)])

        // Font and Color
        attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 24), .foregroundColor: UIColor.blue], range: NSRange(location: 0, length: 4))

        // Paragraph Style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.alignment = .justified
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        // Kern and Ligature
        attributedString.addAttributes([.kern: 2.0, .ligature: 1], range: NSRange(location: 10, length: 10)) // Example range

        // Strikethrough and Underline
        attributedString.addAttributes([.strikethroughStyle: NSUnderlineStyle.single.rawValue, .underlineStyle: NSUnderlineStyle.double.rawValue, .underlineColor: UIColor.red], range: NSRange(location: 50, length: 15)) // Example range

        // Link
        if let url = URL(string: "https://www.apple.com") {
            attributedString.addAttribute(.link, value: url, range: NSRange(location: 80, length: 5)) // Add a link
        }


        // Text Attachment (Custom Box)
        let boxAttachment = BoxAttachment(color: .green)
        let attachmentString = NSAttributedString(attachment: boxAttachment)
        attributedString.append(NSAttributedString(string: "  ")) // Add some space
        attributedString.append(attachmentString)
        attributedString.append(NSAttributedString(string: "  This is a custom attachment.\n\n"))
        
        // Another custom text attachment:
        let boxAttachment2 = BoxAttachment(color: .systemPink)
        let attachmentString2 = NSAttributedString(attachment: boxAttachment2)
        attributedString.append(NSAttributedString(string: "  ")) // Add some space
        attributedString.append(attachmentString2)
        attributedString.append(NSAttributedString(string: "  This is another custom attachment.\n"))


        // Apply the attributed string
        textStorage.attributedString = attributedString
    }

    // MARK: - Exclusion Path

    private func setupExclusionPath() {
        let exclusionPath = UIBezierPath(ovalIn: CGRect(x: 50, y: 150, width: 100, height: 100))
        textView.textContainer.exclusionPaths = [exclusionPath]
    }

    // MARK: - Dynamic Type

    private func applyDynamicType() {
        // Already set the font to a preferred font in setupTextView().  Just need to observe changes.
        NotificationCenter.default.addObserver(self, selector: #selector(preferredContentSizeChanged(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    @objc private func preferredContentSizeChanged(_ notification: Notification) {
        textView.font = UIFont.preferredFont(forTextStyle: .body)  // Re-apply the font
        // Because we're using NSTextContentStorage, we don't need to manually set the attributed string again
        // to update attributes, just setting the base font on the UITextView is sufficient.
    }


    // MARK: - Accessibility
    private func setupAccessibility() {
        textView.isAccessibilityElement = true
        textView.accessibilityLabel = "Editable Text View" // Set a basic label
        // NSTextContentStorage and NSTextLayoutManager handle much of the accessibility automatically.
    }
    
    // MARK: - NSTextContentStorageDelegate
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        //You can create paragraphs on the fly here.
        return nil
    }
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage, didProcessEditing editedMask: NSTextContentStorageEditActions, range: NSRange, changeInLength delta: Int) {
           if editedMask.contains(.editedAttributes) {
               //Respond to attribute changes if any.
           }
           
           if editedMask.contains(.editedCharacters) {
              //Respond to character changes if any.
           }
        }
}
