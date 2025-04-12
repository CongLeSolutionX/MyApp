////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
////
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//
//import SwiftUI
//import UIKit
//import SafariServices // For SFSafariViewController
//import PhotosUI // Often useful with ImagePicker, though delegate is UIKit
//
//// MARK: - 1. Master View Model (Central State & Callback Handling)
//
//class MasterViewModel: ObservableObject {
//    @Published var selectedImage: UIImage?
//    @Published var lastSafariUrlFinished: URL?
//    @Published var drawingStrokeCount: Int = 0
//    @Published var statusMessage: String = "App Ready"
//    @Published var lastErrorMessage: String?
//
//    // --- Methods called by Specialized Coordinators ---
//
//    // Image Picker Callbacks
//    func imagePickerDidFinish(image: UIImage?) {
//        DispatchQueue.main.async {
//            if let img = image {
//                self.selectedImage = img
//                self.statusMessage = "Image selected."
//                self.lastErrorMessage = nil
//            } else {
//                self.selectedImage = nil // Handle cancellation
//                self.statusMessage = "Image selection cancelled."
//            }
//        }
//        print("MasterViewModel: Image picker finished.")
//    }
//
//    // Safari View Controller Callbacks
//    func safariViewControllerDidFinish(url: URL?) {
//        DispatchQueue.main.async {
//            self.lastSafariUrlFinished = url
//            self.statusMessage = "Safari view dismissed."
//        }
//        print("MasterViewModel: Safari VC finished for URL: \(url?.absoluteString ?? "N/A")")
//    }
//
//    // Custom Drawing Pad Callbacks
//    func drawingPadDidChange(strokeCount: Int) {
//        DispatchQueue.main.async {
//             // Avoid excessive updates if count is same
//            if self.drawingStrokeCount != strokeCount {
//                self.drawingStrokeCount = strokeCount
//                self.statusMessage = "Drawing updated: \(strokeCount) strokes."
//            }
//        }
//        // Don't print excessively here, can be noisy
//        // print("MasterViewModel: Drawing pad has \(strokeCount) strokes.")
//    }
//
//    func handleGenericError(message: String) {
//         DispatchQueue.main.async {
//            self.lastErrorMessage = message
//            self.statusMessage = "Error occurred."
//         }
//         print("MasterViewModel: Error - \(message)")
//    }
//}
//
//// MARK: - 2. Specialized Representables and their Coordinators
//
//// --- Image Picker ---
//struct ImagePickerRepresentable: UIViewControllerRepresentable {
//    // Reference to the MasterViewModel
//    @ObservedObject var masterViewModel: MasterViewModel
//    @Binding var isPresented: Bool
//    var sourceType: UIImagePickerController.SourceType = .photoLibrary
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, masterViewModel: masterViewModel)
//    }
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        print("ImagePickerRepresentable: makeUIViewController created")
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator // Use the specialized coordinator
//        // Basic check if source type is available
//        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
//            picker.sourceType = sourceType
//        } else {
//            // Handle error - source type not available (e.g., no camera)
//            // In a real app, disable the button or show an alert *before* presenting
//            print("Error: Source type \(sourceType) not available.")
//            masterViewModel.handleGenericError(message: "Selected source type (\(sourceType)) is not available.")
//            // We still return a picker, but it might be empty or behave unexpectedly
//            // Best practice is to check availability *before* deciding to present this representable.
//        }
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
//        // Maybe update sourceType if it changes? Usually not needed after creation.
//         print("ImagePickerRepresentable: updateUIViewController called")
//    }
//
//    // Specialized Coordinator for UIImagePickerController
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        var parent: ImagePickerRepresentable
//        var masterViewModel: MasterViewModel
//
//        init(_ parent: ImagePickerRepresentable, masterViewModel: MasterViewModel) {
//            self.parent = parent
//            self.masterViewModel = masterViewModel
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            print("Coordinator: Image picked")
//            let uiImage = info[.originalImage] as? UIImage
//            masterViewModel.imagePickerDidFinish(image: uiImage) // Notify MasterViewModel
//            parent.isPresented = false // Dismiss the picker
//        }
//
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            print("Coordinator: Image picker cancelled")
//            masterViewModel.imagePickerDidFinish(image: nil) // Notify MasterViewModel of cancellation
//            parent.isPresented = false // Dismiss the picker
//        }
//    }
//}
//
//// --- Safari View Controller ---
//struct SafariViewRepresentable: UIViewControllerRepresentable {
//    let url: URL? // Allow nil URL initially or if error
//    // Reference to the MasterViewModel
//    @ObservedObject var masterViewModel: MasterViewModel
//    // No need for @Binding isPresented IF presented via .sheet/.fullScreenCover
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, masterViewModel: masterViewModel)
//    }
//
//    func makeUIViewController(context: Context) -> SFSafariViewController {
//        print("SafariViewRepresentable: makeUIViewController created")
//        // Provide a default URL or handle nil case gracefully
//        let effectiveURL = url ?? URL(string: "https://www.example.com")! // Fallback URL
//        let safariVC = SFSafariViewController(url: effectiveURL)
//        safariVC.delegate = context.coordinator // Use the specialized coordinator
//        // Configure appearance if needed (e.g., bar tint color)
//        // safariVC.preferredControlTintColor = UIColor.systemBlue
//        return safariVC
//    }
//
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
//        // SFSafariViewController doesn't allow changing the URL after creation.
//        // If the URL binding changes, the view should be reconstructed (which .sheet/.fullScreenCover handles).
//        print("SafariViewRepresentable: updateUIViewController called")
//    }
//
//    // Specialized Coordinator for SFSafariViewController
//    class Coordinator: NSObject, SFSafariViewControllerDelegate {
//        var parent: SafariViewRepresentable
//        var masterViewModel: MasterViewModel
//
//        init(_ parent: SafariViewRepresentable, masterViewModel: MasterViewModel) {
//            self.parent = parent
//            self.masterViewModel = masterViewModel
//        }
//
//        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
//            print("Coordinator: Safari VC Did finish")
//            // controller.url isn't available here
//            masterViewModel.safariViewControllerDidFinish(url: parent.url) // Notify MasterViewModel
//            // Dismissal is handled by the system when using .sheet/.fullScreenCover
//        }
//    }
//}
//
//// --- Custom Drawing Pad ---
//
//// 1. Define a Delegate Protocol for the custom view
//protocol DrawingPadViewDelegate: AnyObject {
//    func drawingPadDidChange(strokeCount: Int)
//    func drawingPadDidEndStroke() // Optional: Notify when a stroke finishes
//}
//
//// 2. Create the custom UIView subclass
//class DrawingPadView: UIView {
//    private var paths: [UIBezierPath] = []
//    private var currentPath: UIBezierPath?
//    private var pathColor: UIColor = .black // Exposed property for customization
//    private var lineWidth: CGFloat = 3.0   // Exposed property
//
//    // Weak delegate reference to avoid retain cycles
//    weak var delegate: DrawingPadViewDelegate?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .white // Or any desired background
//        isMultipleTouchEnabled = false // Simple drawing: one touch at a time
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // Configuration methods (called from Representable or Coordinator)
//    func setStrokeColor(_ color: UIColor) {
//        self.pathColor = color
//    }
//
//    func setStrokeWidth(_ width: CGFloat) {
//        self.lineWidth = max(1.0, width) // Ensure minimum width
//    }
//
//    // Public method to clear the drawing
//    func clearDrawing() {
//        paths.removeAll()
//        currentPath = nil
//        setNeedsDisplay() // Trigger redraw
//        delegate?.drawingPadDidChange(strokeCount: paths.count) // Notify delegate
//    }
//
//    // Touch Handling
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let point = touch.location(in: self)
//        currentPath = UIBezierPath()
//        currentPath?.lineWidth = lineWidth
//        currentPath?.lineCapStyle = .round
//        currentPath?.lineJoinStyle = .round
//        currentPath?.move(to: point)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let path = currentPath else { return }
//        let point = touch.location(in: self)
//        path.addLine(to: point)
//        setNeedsDisplay() // Request redraw
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let path = currentPath else { return }
//        paths.append(path)
//        currentPath = nil // Finish current path
//        setNeedsDisplay() // Redraw with completed path added
//        delegate?.drawingPadDidChange(strokeCount: paths.count) // Notify delegate
//        delegate?.drawingPadDidEndStroke() // Notify stroke end
//         print("DrawingPadView: Stroke ended, total paths: \(paths.count)")
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        currentPath = nil // Discard if cancelled
//        setNeedsDisplay()
//        print("DrawingPadView: Touch cancelled")
//    }
//
//    // Drawing Logic
//    override func draw(_ rect: CGRect) {
//        pathColor.setStroke() // Use the configured color
//
//        // Draw previously completed paths
//        for path in paths {
//            path.stroke()
//        }
//
//        // Draw the currently active path (if any)
//        currentPath?.stroke()
//    }
//}
//
//// 3. Create the UIViewRepresentable Wrapper
//struct DrawingPadRepresentable: UIViewRepresentable {
//    // Reference to the MasterViewModel
//    @ObservedObject var masterViewModel: MasterViewModel
//    // Pass configuration values from SwiftUI if needed
//    var strokeColor: Color = .black
//    var strokeWidth: CGFloat = 3.0
//
//    // Add a way to trigger clear externally (via binding or coordinator)
//    @Binding var needsClear: Bool
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, masterViewModel: masterViewModel)
//    }
//
//    func makeUIView(context: Context) -> DrawingPadView {
//        print("DrawingPadRepresentable: makeUIView created")
//        let drawingView = DrawingPadView()
//        drawingView.delegate = context.coordinator // Set the specialized coordinator as delegate
//        drawingView.setStrokeColor(UIColor(strokeColor)) // Initial config
//        drawingView.setStrokeWidth(strokeWidth)          // Initial config
//        return drawingView
//    }
//
//    func updateUIView(_ uiView: DrawingPadView, context: Context) {
//        print("DrawingPadRepresentable: updateUIView called")
//        // Update drawing view properties if SwiftUI state changes
//        uiView.setStrokeColor(UIColor(strokeColor))
//        uiView.setStrokeWidth(strokeWidth)
//
//        // Handle external clear request
//        if needsClear {
//            print("DrawingPadRepresentable: Clearing drawing")
//            uiView.clearDrawing()
//            // Reset the flag immediately after processing
//            DispatchQueue.main.async {
//                self.needsClear = false
//            }
//        }
//    }
//
//    // Specialized Coordinator acts as the DrawingPadViewDelegate
//    class Coordinator: NSObject, DrawingPadViewDelegate {
//        var parent: DrawingPadRepresentable
//        var masterViewModel: MasterViewModel
//
//        init(_ parent: DrawingPadRepresentable, masterViewModel: MasterViewModel) {
//            self.parent = parent
//            self.masterViewModel = masterViewModel
//        }
//
//        // Implement the delegate methods
//        func drawingPadDidChange(strokeCount: Int) {
//            masterViewModel.drawingPadDidChange(strokeCount: strokeCount) // Notify MasterViewModel
//        }
//
//        func drawingPadDidEndStroke() {
//            // Could trigger other actions in MasterViewModel if needed
//            print("Coordinator: Drawing stroke ended.")
//        }
//    }
//}
//
//// MARK: - 3. SwiftUI Main View
//
//struct ContentView: View {
//    // Instantiate the MasterViewModel
//    @StateObject private var masterViewModel = MasterViewModel()
//
//    // State for modal presentation
//    @State private var showingImagePicker = false
//    @State private var showingSafariView = false
//
//    // State for Safari URL and Drawing Pad Clear
//    @State private var safariURL: URL? = URL(string: "https://developer.apple.com/swiftui/")
//    @State private var clearDrawingPad = false
//
//    var body: some View {
//        NavigationView {
//            ScrollView { // Use ScrollView if content might exceed screen height
//                VStack(alignment: .leading, spacing: 15) {
//
//                    // Status Area
//                    Text("Status: \(masterViewModel.statusMessage)")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    if let error = masterViewModel.lastErrorMessage {
//                        Text("Error: \(error)")
//                            .foregroundColor(.red)
//                            .font(.caption)
//                            .padding(.horizontal)
//                    }
//
//                    Divider()
//
//                    // --- Image Picker Section ---
//                    Group {
//                        Text("Image Picker").font(.title2).padding(.horizontal)
//                        if let image = masterViewModel.selectedImage {
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(maxHeight: 150)
//                                .padding(.horizontal)
//                        } else {
//                            Text("No image selected.")
//                                .font(.caption)
//                                .padding(.horizontal)
//                        }
//                        Button("Select Image") {
//                            showingImagePicker = true
//                        }
//                        .padding(.horizontal)
//                    }
//
//                    Divider()
//
//                    // --- Safari View Section ---
//                    Group {
//                        Text("Safari View Controller").font(.title2).padding(.horizontal)
//                        Button("Show Apple Dev Site") {
//                            safariURL = URL(string: "https://developer.apple.com/swiftui/")
//                            showingSafariView = true
//                        }
//                        .padding(.horizontal)
//                        Button("Show Example.com") {
//                             safariURL = URL(string: "https://www.example.com")
//                             showingSafariView = true
//                        }
//                        .padding(.horizontal)
//                        if let lastURL = masterViewModel.lastSafariUrlFinished {
//                             Text("Last viewed: \(lastURL.host ?? "N/A")")
//                                 .font(.caption)
//                                 .padding(.horizontal)
//                        }
//
//                    }
//
//                    Divider()
//
//                    // --- Drawing Pad Section ---
//                    Group {
//                        Text("Drawing Pad").font(.title2).padding(.horizontal)
//                        Text("Stroke Count: \(masterViewModel.drawingStrokeCount)")
//                            .font(.caption)
//                            .padding(.horizontal)
//
//                        DrawingPadRepresentable(
//                            masterViewModel: masterViewModel,
//                            strokeColor: .blue, // Example configuration
//                            strokeWidth: 4.0,   // Example configuration
//                            needsClear: $clearDrawingPad // Pass binding
//                        )
//                            .frame(height: 250)
//                            .border(Color.green.opacity(0.7))
//                            .padding(.horizontal)
//
//                         Button("Clear Drawing") {
//                             clearDrawingPad = true // Trigger clear via binding
//                         }
//                         .padding(.horizontal)
//                    }
//
//                    Spacer() // Push content up if needed
//                }
//                .padding(.vertical) // Add vertical padding to ScrollView content
//            }
//            .navigationTitle("Mixed Coordinators")
//            // Modal presentation sheets
//            .sheet(isPresented: $showingImagePicker) {
//                ImagePickerRepresentable(masterViewModel: masterViewModel, isPresented: $showingImagePicker)
//            }
//            .fullScreenCover(isPresented: $showingSafariView) { // Use fullScreenCover for SafariVC
//                 // Guard against nil URL before presenting
//                 if let url = safariURL {
//                    SafariViewRepresentable(url: url, masterViewModel: masterViewModel)
//                 } else {
//                    // Optional: Show an alert or fallback if URL is unexpectedly nil
//                    Text("Error: Invalid URL for Safari View")
//                        .onAppear {
//                             // Ensure the sheet dismisses if URL is bad
//                             showingSafariView = false
//                             masterViewModel.handleGenericError(message: "Attempted to open Safari with invalid URL.")
//                         }
//                 }
//            }
//        }
//         // Consistent navigation style
//         .navigationViewStyle(.stack)
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//// Standard App entry point
///*
//@main
//struct MixedCoordinationApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//*/
