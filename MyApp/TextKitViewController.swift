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
        // Alternatively, you could implement coder support here.
        return nil
    }
    
    // Specify the size of the attachment.
    override func attachmentBounds(for textContainer: NSTextContainer?,
                                   proposedLineFragment lineFrag: CGRect,
                                   glyphPosition position: CGPoint,
                                   characterIndex charIndex: Int) -> CGRect {
        return CGRect(x: 0, y: 0, width: 20, height: 20)
    }
    
    // Draw the box image.
    override func image(forBounds imageBounds: CGRect,
                        textContainer: NSTextContainer?,
                        characterIndex charIndex: Int) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: imageBounds.size)
        let image = renderer.image { context in
            boxColor.setFill()
            context.fill(imageBounds)
        }
        return image
    }
}
//
//// MARK: - Custom Layout Manager
///// A custom NSTextLayoutManager that highlights the first paragraph.
//class HighlightFirstLineLayoutManager: NSTextLayoutManager {
//    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
//
//        // Ensure the textContentStorage exists.
//        guard let textContentStorage = self.textContentStorage else { return }
//        // Ensure there's at least one paragraph.
//        guard let firstParagraphRange = textContentStorage.textParagraphRanges.first else { return }
//        // Obtain the container safely.
//        guard let container = self.textContainer(forGlyphAt: firstParagraphRange.location) else { return }
//        // Get the glyph range corresponding to the first paragraph.
//        let firstGlyphRange = self.glyphRange(for: firstParagraphRange)
//        
//        let highlightRect = self.boundingRect(forGlyphRange: firstGlyphRange, in: container)
//                              .offsetBy(dx: origin.x, dy: origin.y)
//        UIColor.yellow.withAlphaComponent(0.3).setFill()
//        UIBezierPath(rect: highlightRect).fill()
//    }
//}

// MARK: - Main ViewController
class ViewController: UIViewController, NSTextContentStorageDelegate {
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var textStorage: NSTextContentStorage = {
        let textStorage = NSTextContentStorage()
        return textStorage
    }()
    
    private lazy var layoutManager: NSTextLayoutManager = {
        let layoutManager = NSTextLayoutManager()
        return layoutManager
    }()
    
    private lazy var textContainer: NSTextContainer = {
        let textContainer = NSTextContainer()
        textContainer.lineFragmentPadding = 0
        return textContainer
    }()
    
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
        // Use TextKit2's NSTextContentStorage.
        textStorage = NSTextContentStorage()
        textStorage.delegate = self
        
        // Create a custom layout manager.
//        layoutManager = HighlightFirstLineLayoutManager()
        textStorage.addTextLayoutManager(layoutManager)
        
        // Create a text container.
        textContainer = NSTextContainer()
        layoutManager.textContainer = textContainer
    }
    
    private func setupTextView() {
        // Use the textContainer from our setup.
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
    
    // MARK: - Attributed String Configuration
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
        
        // Apply bold and blue to the first four characters.
        if attributed.length >= 4 {
            attributed.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.blue
            ], range: NSRange(location: 0, length: 4))
        }
        
        // Set up a paragraph style with extra line spacing and justified alignment.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.alignment = .justified
        attributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributed.length))
        
        // Add kerning and ligatures to a portion of the text.
        if attributed.length >= 20 {
            attributed.addAttributes([
                .kern: 2.0,
                .ligature: 1
            ], range: NSRange(location: 10, length: min(10, attributed.length - 10)))
        }
        
        // Add strikethrough and underline for a sample range if available.
        if attributed.length >= 70 {
            attributed.addAttributes([
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .underlineStyle: NSUnderlineStyle.double.rawValue,
                .underlineColor: UIColor.red
            ], range: NSRange(location: 50, length: min(15, attributed.length - 50)))
        }
        
        // Add a link attribute.
        if let url = URL(string: "https://www.apple.com"), attributed.length >= 90 {
            attributed.addAttribute(.link, value: url, range: NSRange(location: 80, length: min(5, attributed.length - 80)))
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
        // Create an oval exclusion path so that the text flows around it.
        let exclusionOval = UIBezierPath(ovalIn: CGRect(x: 50, y: 150, width: 100, height: 100))
        textView.textContainer.exclusionPaths = [exclusionOval]
    }
    
    // MARK: - Dynamic Type Observation
    private func observeDynamicTypeChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dynamicTypeChanged),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    @objc private func dynamicTypeChanged() {
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    // MARK: - Accessibility
    private func configureAccessibility() {
        textView.isAccessibilityElement = true
        textView.accessibilityLabel = "Editable Text View"
    }
    
    // MARK: - NSTextContentStorageDelegate (Optional)
    func textContentStorage(_ textContentStorage: NSTextContentStorage,
                            textParagraphWith range: NSRange) -> NSTextParagraph? {
        return nil  // Custom paragraph creation can be implemented if needed.
    }
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage,
//                            didProcessEditing editedMask: NSTextContentStorageEditActions,
                            range: NSRange,
                            changeInLength delta: Int) {
        // Handle text changes for characters or attributes if required.
    }
}

// To test this code, set ViewController as the root view controller
// in your AppDelegate or SceneDelegate as appropriate.
