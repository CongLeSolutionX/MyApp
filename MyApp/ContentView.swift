//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}



import SwiftUI
import UIKit // Needed for UIColor, UIView, UIGraphicsGetCurrentContext

// MARK: - 1. The Custom UIView for Core Graphics Drawing

class DrawingView: UIView {

    // Properties to control the drawing, settable from the representable
    var drawingColor: UIColor = .systemBlue {
        didSet {
            // Trigger a redraw when the color changes
            setNeedsDisplay()
            print("DrawingView: Color changed, requesting redraw.")
        }
    }

    var lineWidth: CGFloat = 5.0 {
        didSet {
            // Trigger a redraw when the line width changes
            setNeedsDisplay()
            print("DrawingView: Line width changed, requesting redraw.")
        }
    }

    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Make the background clear so the SwiftUI background can show through if needed
        backgroundColor = .clear
        // Enable content clipping if drawing might go outside bounds temporarily
        // clipsToBounds = true
        print("DrawingView: Initialized.")
    }

    // The core drawing method ****
    override func draw(_ rect: CGRect) {
        super.draw(rect) // Good practice, though often empty for custom views

        print("DrawingView: draw(_:) called with rect: \(rect)")

        // 1. Get the current Core Graphics context
        guard let context = UIGraphicsGetCurrentContext() else {
            print("DrawingView: Could not get graphics context.")
            return
        }

        // --- Example Drawing ---
        // Draw something dynamic based on the view's bounds (rect)
        // and the properties (drawingColor, lineWidth)

        let insetRect = rect.insetBy(dx: lineWidth / 2 + 10, dy: lineWidth / 2 + 10) // Inset by half line width + padding
        let centerX = rect.midX
        let centerY = rect.midY

        // --- Draw a filled circle ---
        context.setFillColor(drawingColor.withAlphaComponent(0.5).cgColor) // Use semi-transparent fill
        let circleRect = CGRect(x: centerX - 50, y: centerY - 100, width: 100, height: 100)
        context.fillEllipse(in: circleRect)
        print("DrawingView: Drew filled circle.")

        // --- Draw a stroked rectangle ---
        context.setStrokeColor(drawingColor.cgColor) // Use the selected color for stroke
        context.setLineWidth(lineWidth)     // Use the selected line width
        context.stroke(insetRect)           // Draw the outline of the inset rectangle
        print("DrawingView: Drew stroked rectangle.")

        // --- Draw some lines ---
        context.move(to: CGPoint(x: insetRect.minX, y: insetRect.minY)) // Top-left
        context.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY)) // Bottom-right
        context.move(to: CGPoint(x: insetRect.maxX, y: insetRect.minY)) // Top-right
        context.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.maxY)) // Bottom-left

        context.strokePath() // Actually draw the lines defined above
        print("DrawingView: Drew lines.")

        // --- Draw Text (Example) ---
        // Note: Core Graphics text is lower-level than UILabel/Text
        let text = "Core Graphics"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: drawingColor
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textRect = CGRect(x: centerX - textSize.width / 2,
                              y: rect.maxY - textSize.height - 15, // Position near bottom
                              width: textSize.width,
                              height: textSize.height)
        attributedString.draw(in: textRect)
        print("DrawingView: Drew text.")
    }

    // Optional: Handle layout changes if needed (e.g., if sublayers depend on bounds)
    override func layoutSubviews() {
        super.layoutSubviews()
        // If you were using CALayers added manually, you might update their frames here.
        // For direct draw(_:), changing bounds automatically triggers a redraw.
         print("DrawingView: layoutSubviews called.")
         // Usually redraw needed if bounds change significantly
         // setNeedsDisplay() // Can be redundant if bounds change always triggers draw, but sometimes explicit is safer
    }
}

// MARK: - 2. The UIViewRepresentable Wrapper

struct CoreGraphicsDrawingView: UIViewRepresentable {

    // Bindings or properties to pass data from SwiftUI to the UIKit View
    @Binding var drawingColor: Color
    @Binding var lineWidth: CGFloat

    // Creates the initial UIView instance
    func makeUIView(context: Context) -> DrawingView {
        print("CoreGraphicsDrawingView: makeUIView called.")
        let drawingView = DrawingView()
        // Set initial values
        drawingView.drawingColor = UIColor(drawingColor) // Convert SwiftUI Color to UIColor
        drawingView.lineWidth = lineWidth
        return drawingView
    }

    // Updates the existing UIView instance when SwiftUI state changes
    func updateUIView(_ uiView: DrawingView, context: Context) {
        print("CoreGraphicsDrawingView: updateUIView called. Color: \(drawingColor), Width: \(lineWidth)")
        // Update the UIView's properties from the SwiftUI state
        // The didSet observers in DrawingView will trigger setNeedsDisplay()
        uiView.drawingColor = UIColor(drawingColor)
        uiView.lineWidth = lineWidth

        // Note: Explicitly calling setNeedsDisplay() here is usually redundant
        // IF the UIView's property observers already call it. If they didn't,
        // you would uncomment the line below.
        // uiView.setNeedsDisplay()
    }

    // Optional: Coordinator for handling delegates or callbacks (not needed for this simple example)
    /*
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CoreGraphicsDrawingView
        init(_ parent: CoreGraphicsDrawingView) {
            self.parent = parent
            print("CoreGraphicsDrawingView.Coordinator: Initialized.")
        }
        // Add delegate methods or action handlers here if needed
    }
    */

     // Optional: Implement sizeThatFits if you want SwiftUI to suggest a size
    /*
     func sizeThatFits(_ proposal: ProposedViewSize, uiView: DrawingView, context: Context) -> CGSize? {
         // Return a fixed size, or calculate based on content if possible
         return CGSize(width: 300, height: 200)
     }
     */
}

// MARK: - 3. The SwiftUI Content View

struct ContentView: View {
    @State private var selectedColor: Color = .blue
    @State private var selectedLineWidth: CGFloat = 3.0

    var body: some View {
        VStack {
            Text("Core Graphics in SwiftUI")
                .font(.headline)
                .padding(.top)

            // The Core Graphics drawing view, bound to the state variables
            CoreGraphicsDrawingView(drawingColor: $selectedColor, lineWidth: $selectedLineWidth)
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 400) // Give it flexible frame
                .border(Color.gray.opacity(0.5)) // Border to see the frame
                .padding()

            // Controls to modify the drawing parameters
            VStack {
                ColorPicker("Drawing Color", selection: $selectedColor)

                HStack {
                    Text("Line Width: \(selectedLineWidth, specifier: "%.1f")")
                    Slider(value: $selectedLineWidth, in: 1.0...20.0, step: 0.5)
                }
            }
            .padding() // Padding for the controls section

            Spacer() // Pushes controls and view up
        }
        .navigationTitle("Core Graphics Demo") // Example if embedded in NavigationView
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - App Entry Point (Required if this is the main app file)
/*
@main
struct CoreGraphicsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
