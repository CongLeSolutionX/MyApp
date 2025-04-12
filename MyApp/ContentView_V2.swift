////
////  ContentView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/11/25.
////
//
//import SwiftUI
//import UIKit
//import SafariServices // For SFSafariViewController
//import PhotosUI // Needed for PHPickerViewController
//
//// MARK: - Error Handling Enum
//enum AppError: LocalizedError, Equatable {
//    static func == (lhs: AppError, rhs: AppError) -> Bool {
//        return true
//    }
//    
//    case pickerLoadingFailed(Error?)
//    case safariURLError(String)
//    case sourceUnavailable(String)
//    case generic(String)
//
//    var errorDescription: String? {
//        switch self {
//        case .pickerLoadingFailed:
//            return "Failed to load the selected image."
//        case .safariURLError(let url):
//            return "Cannot open invalid URL: \(url)"
//        case .sourceUnavailable(let source):
//            return "The source '\(source)' is not available on this device."
//        case .generic(let message):
//            return message
//        }
//    }
//
//    // Optional: Provide recovery suggestions
//    var recoverySuggestion: String? {
//         switch self {
//         case .pickerLoadingFailed:
//             return "Please try selecting the image again."
//         case .safariURLError:
//             return "Please check the URL and try again."
//         case .sourceUnavailable:
//             return "Please ensure the source exists and permissions are granted (e.g., camera access)."
//         case .generic:
//             return "Please try the action again later."
//         }
//     }
//}
//
//// MARK: - 1. Master View Model (Refined State & Asynchronous Handling)
//
//@MainActor // Ensure UI updates happen on the main actor
//class MasterViewModel: ObservableObject {
//    @Published var selectedImage: UIImage?
//    @Published var lastSafariUrlFinished: URL?
//    @Published var drawingStrokeCount: Int = 0
//    @Published var statusMessage: String = "App Ready"
//    @Published var currentError: AppError? = nil // Use specific error type
//    @Published var isLoading: Bool = false // For showing loading indicators
//
//    // --- Methods called by Specialized Coordinators or Actions ---
//
//    // PHPicker Callbacks (Modernized)
//    func imagePickerDidFinish(image: UIImage?) {
//        // isLoading = false // Already handled in the task
//        if let img = image {
//            self.selectedImage = img
//            self.statusMessage = "Image selected."
//            self.currentError = nil
//        } else {
//            // This case might occur if loading fails or is cancelled mid-load
//            self.selectedImage = nil
//            if !isLoading { // Don't overwrite cancellation message if loading failed
//                self.statusMessage = "Image selection cancelled or failed."
//            }
//        }
//        print("MasterViewModel: Image picker finished.")
//    }
//
//    func imagePickerDidCancel() {
//        self.isLoading = false // Ensure loading stops on cancellation
//        self.selectedImage = nil
//        self.statusMessage = "Image selection cancelled."
//        self.currentError = nil
//        print("MasterViewModel: Image picker cancelled.")
//    }
//
//    // Safari View Controller Callbacks
//    func safariViewControllerDidFinish(url: URL?) {
//        self.lastSafariUrlFinished = url
//        self.statusMessage = "Safari view dismissed for: \(url?.host ?? "N/A")"
//        print("MasterViewModel: Safari VC finished for URL: \(url?.absoluteString ?? "N/A")")
//    }
//
//    // Custom Drawing Pad Callbacks
//    func drawingPadDidChange(strokeCount: Int) {
//        // Avoid excessive updates if count is same
//        if self.drawingStrokeCount != strokeCount {
//            self.drawingStrokeCount = strokeCount
//            self.statusMessage = "Drawing updated: \(strokeCount) strokes."
//        }
//        // print("MasterViewModel: Drawing pad has \(strokeCount) strokes.") // Still noisy
//    }
//
//    func handleAppError(_ error: AppError) {
//         self.isLoading = false // Stop loading on any error
//         self.currentError = error
//         self.statusMessage = "Error occurred."
//         print("MasterViewModel: Error - \(error.localizedDescription)")
//    }
//
//    // Helper to reset error state
//    func clearError() {
//        self.currentError = nil
//    }
//}
//
//// MARK: - 2. Specialized Representables and their Coordinators (PHPicker Refactor)
//
//// --- PHPicker Representable (Modern Replacement for ImagePicker) ---
//struct PHPickerRepresentable: UIViewControllerRepresentable {
//    @ObservedObject var masterViewModel: MasterViewModel
//    @Binding var isPresented: Bool
//    // Configuration for the picker
//    let selectionLimit: Int // e.g., 1 for single image
//    let filter: PHPickerFilter? // e.g., .images, .videos, .livePhotos
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, masterViewModel: masterViewModel)
//    }
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        print("PHPickerRepresentable: makeUIViewController created")
//        var config = PHPickerConfiguration(photoLibrary: .shared()) // Use shared() for stability
//        config.filter = filter
//        config.selectionLimit = selectionLimit
//        // config.preferredAssetRepresentationMode = .automatic // Or .current, .compatible
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
//        // Configuration is set at init, usually no updates needed here
//         print("PHPickerRepresentable: updateUIViewController called")
//    }
//
//    // Specialized Coordinator for PHPickerViewController
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        var parent: PHPickerRepresentable
//        var masterViewModel: MasterViewModel
//
//        init(_ parent: PHPickerRepresentable, masterViewModel: MasterViewModel) {
//            self.parent = parent
//            self.masterViewModel = masterViewModel
//        }
//
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            parent.isPresented = false // Dismiss the picker FIRST
//
//            guard !results.isEmpty else {
//                // User cancelled implicitly by selecting nothing
//                Task { await masterViewModel.imagePickerDidCancel() }
//                return
//            }
//
//            // Handle potential multiple selections if selectionLimit > 1,
//            // but for this example, we just take the first one.
//            guard let result = results.first else {
//                 Task { masterViewModel.imagePickerDidCancel() } // Or handle error
//                 return
//            }
//
//            let itemProvider = result.itemProvider
//
//            guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
//                Task {
//                    masterViewModel.handleAppError(.generic("Cannot load selected item as image."))
//                    masterViewModel.imagePickerDidFinish(image: nil) // Clear potential previous image
//                }
//                return
//            }
//
//            // Set loading state BEFORE starting async load
//            Task { await masterViewModel.isLoading = true }
//
//            // Load the image asynchronously
//            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//                 // Ensure we are back on the main thread for UI state updates
//                 Task { @MainActor [weak self] in
//                    guard let self = self else { return }
//                    self.masterViewModel.isLoading = false // Stop loading
//
//                    if let error = error {
//                        print("Error loading image: \(error)")
//                        self.masterViewModel.handleAppError(.pickerLoadingFailed(error))
//                        self.masterViewModel.imagePickerDidFinish(image: nil) // Clear potential previous image
//                    } else if let uiImage = image as? UIImage {
//                        print("Coordinator: Image loaded successfully")
//                        self.masterViewModel.imagePickerDidFinish(image: uiImage)
//                    } else {
//                         // Should not happen if canLoadObject check passed, but handle defensively
//                         await self.masterViewModel.handleAppError(.generic("Loaded object was not a UIImage."))
//                        self.masterViewModel.imagePickerDidFinish(image: nil)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// --- Safari View Controller Representable (Added Configuration) ---
//struct SafariViewRepresentable: UIViewControllerRepresentable {
//    let url: URL // Expect a valid URL here - check *before* presenting
//    @ObservedObject var masterViewModel: MasterViewModel
//    var preferredBarTintColor: UIColor? = nil
//    var preferredControlTintColor: UIColor? = .systemBlue // Default tint color
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, masterViewModel: masterViewModel)
//    }
//
//    func makeUIViewController(context: Context) -> SFSafariViewController {
//        print("SafariViewRepresentable: makeUIViewController created for URL: \(url)")
//        let config = SFSafariViewController.Configuration()
//        // config.entersReaderIfAvailable = true // Example config
//        // config.barCollapsingEnabled = true   // Example config
//
//        let safariVC = SFSafariViewController(url: url, configuration: config)
//        safariVC.delegate = context.coordinator
//        safariVC.preferredBarTintColor = preferredBarTintColor
//        safariVC.preferredControlTintColor = preferredControlTintColor
//        // safariVC.dismissButtonStyle = .close // Example .done, .cancel
//        return safariVC
//    }
//
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
//        // URL and configuration cannot be changed after init.
//        // If tint colors *could* change dynamically (passed via @State), update them here:
//        // uiViewController.preferredBarTintColor = preferredBarTintColor
//        // uiViewController.preferredControlTintColor = preferredControlTintColor
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
//            // Use Task block for main actor safety if doing more complex things later
//            Task { @MainActor in
//                masterViewModel.safariViewControllerDidFinish(url: parent.url)
//            }
//            // Dismissal handled by system for .sheet/.fullScreenCover
//        }
//
//        // Optional: Handle other delegate methods like initial load finished
//         func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
//             print("Safari redirected to: \(URL)")
//         }
//    }
//}
//
//// --- Custom Drawing Pad (View and Delegate) ---
//// Protocol stays the same
//protocol DrawingPadViewDelegate: AnyObject {
//    func drawingPadDidChange(strokeCount: Int)
//    func drawingPadDidEndStroke()
//}
//
//// View stays mostly the same, ensure delegate calls are made
//class DrawingPadView: UIView {
//    private var paths: [UIBezierPath] = []
//    private var currentPath: UIBezierPath?
//    private var pathColor: UIColor = .black
//    private var lineWidth: CGFloat = 3.0
//    weak var delegate: DrawingPadViewDelegate?
//
//    // --- Initializers ---
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//        // fatalError("init(coder:) has not been implemented - unless using Storyboards")
//    }
//    private func setupView() {
//        backgroundColor = .systemBackground // Adapts to light/dark mode
//        isMultipleTouchEnabled = false
//        clearsContextBeforeDrawing = true // Good practice for drawing views
//    }
//
//    // --- Configuration ---
//    func setStrokeColor(_ color: UIColor) {
//        self.pathColor = color
//        // No need to redraw immediately, color is used in draw()
//    }
//    func setStrokeWidth(_ width: CGFloat) {
//        self.lineWidth = max(1.0, width)
//        // No need to redraw immediately, width is used in touchesBegan
//    }
//
//    // --- Drawing Management ---
//    func clearDrawing() {
//        paths.removeAll()
//        currentPath = nil
//        setNeedsDisplay()
//        delegate?.drawingPadDidChange(strokeCount: paths.count)
//         print("DrawingPadView: Cleared")
//    }
//
//    // Function to get the drawing as an image
//    func getDrawingImage() -> UIImage? {
//        // Use UIGraphicsImageRenderer for efficient image creation
//        let renderer = UIGraphicsImageRenderer(bounds: bounds)
//        let image = renderer.image { context in
//            // Ensure background color is drawn if it's not opaque/clear
//            if let bgColor = backgroundColor?.cgColor {
//                 context.cgContext.setFillColor(bgColor)
//                 context.cgContext.fill(bounds)
//            }
//
//            // Draw existing paths
//            pathColor.setStroke()
//            for path in paths {
//                path.stroke()
//            }
//            // Note: Doesn't include the 'currentPath' being drawn
//        }
//        return image
//    }
//
//    // --- Touch Handling ---
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        currentPath = UIBezierPath()
//        currentPath?.lineWidth = lineWidth
//        currentPath?.lineCapStyle = .round
//        currentPath?.lineJoinStyle = .round
//        currentPath?.move(to: touch.location(in: self))
//    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let path = currentPath else { return }
//        path.addLine(to: touch.location(in: self))
//        setNeedsDisplay() // Request redraw for moved path
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let path = currentPath else { return }
//        paths.append(path)
//        currentPath = nil
//        setNeedsDisplay() // Final redraw with completed path
//        delegate?.drawingPadDidChange(strokeCount: paths.count)
//        delegate?.drawingPadDidEndStroke()
//        print("DrawingPadView: Stroke ended, total paths: \(paths.count)")
//    }
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        currentPath = nil
//        setNeedsDisplay()
//        print("DrawingPadView: Touch cancelled")
//    }
//
//    // --- Drawing Logic ---
//    override func draw(_ rect: CGRect) {
//        super.draw(rect) // Good practice (though often no-op for custom UIView)
//
//        pathColor.setStroke()
//
//        for path in paths {
//            path.lineWidth = lineWidth // Apply current width to prevent issues if width changed mid-draw
//            path.stroke()
//        }
//        currentPath?.lineWidth = lineWidth
//        currentPath?.stroke()
//    }
//}
//
//// --- Drawing Pad Representable (Handles Configuration and Clear) ---
//struct DrawingPadRepresentable: UIViewRepresentable {
//    @ObservedObject var masterViewModel: MasterViewModel
//    @Binding var strokeColor: Color
//    @Binding var strokeWidth: CGFloat
//    @Binding var needsClear: Bool
//    // Optional: Closure to get the image back
//    var onSaveRequest: ((UIImage?) -> Void)? = nil // Example: add a save button later
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, masterViewModel: masterViewModel)
//    }
//
//    func makeUIView(context: Context) -> DrawingPadView {
//        print("DrawingPadRepresentable: makeUIView created")
//        let drawingView = DrawingPadView()
//        drawingView.delegate = context.coordinator
//        // Set initial values
//        drawingView.setStrokeColor(UIColor(strokeColor))
//        drawingView.setStrokeWidth(strokeWidth)
//        context.coordinator.drawingPadView = drawingView // Give coordinator access if needed (e.g., for save)
//        return drawingView
//    }
//
//    func updateUIView(_ uiView: DrawingPadView, context: Context) {
//        print("DrawingPadRepresentable: updateUIView called")
//        uiView.setStrokeColor(UIColor(strokeColor))
//        uiView.setStrokeWidth(strokeWidth)
//
//        if needsClear {
//            print("DrawingPadRepresentable: Clearing drawing")
//            uiView.clearDrawing()
//            // Reset the flag immediately using main async to avoid race conditions/infinite loops
//            DispatchQueue.main.async {
//                self.needsClear = false
//            }
//        }
//
//         // Example: Trigger save if a mechanism exists
//         // if needsSave {
//         //     let image = uiView.getDrawingImage()
//         //     onSaveRequest?(image)
//         //     DispatchQueue.main.async { self.needsSave = false }
//         // }
//    }
//
//    // Coordinator acts as Delegate and can hold reference to the UIView
//    class Coordinator: NSObject, DrawingPadViewDelegate {
//        var parent: DrawingPadRepresentable
//        var masterViewModel: MasterViewModel
//        weak var drawingPadView: DrawingPadView? // Hold weak ref for potential actions
//
//        init(_ parent: DrawingPadRepresentable, masterViewModel: MasterViewModel) {
//            self.parent = parent
//            self.masterViewModel = masterViewModel
//        }
//
//        func drawingPadDidChange(strokeCount: Int) {
//            Task { @MainActor in // Ensure correct thread
//                 masterViewModel.drawingPadDidChange(strokeCount: strokeCount)
//            }
//        }
//
//        func drawingPadDidEndStroke() {
//            print("Coordinator: Drawing stroke ended.")
//            // Could trigger other actions if needed
//        }
//
//        // Example: Method coordinator could call if needed
//        func requestSaveDrawing() {
//           let image = drawingPadView?.getDrawingImage()
//           parent.onSaveRequest?(image)
//        }
//    }
//}
//
//// MARK: - 3. SwiftUI Main View (Improved Layout, Controls, Error Handling)
//
//struct ContentView: View {
//    @StateObject private var masterViewModel = MasterViewModel()
//
//    // Presentation State
//    @State private var showingImagePicker = false
//    @State private var showingSafariView = false
//    @State private var showingErrorAlert = false
//
//    // Configuration State
//    @State private var selectedSourceForPicker: UIImagePickerController.SourceType? = nil // For UIImagePicker check
//    @State private var safariURL: URL? = nil
//    @State private var drawingStrokeColor: Color = .blue
//    @State private var drawingStrokeWidth: CGFloat = 4.0
//    @State private var clearDrawingPad = false
//
//    // Computed Booleans for Button States
//    private var isCameraAvailable: Bool {
//        UIImagePickerController.isSourceTypeAvailable(.camera)
//    }
//
//    var body: some View {
//        NavigationView {
//            List { // Use List for better structure and appearance
//                // --- Status Section ---
//                Section(header: Text("Status")) {
//                    Text(masterViewModel.statusMessage)
//                        .foregroundColor(masterViewModel.currentError != nil ? .orange : .primary)
//                     if masterViewModel.isLoading {
//                        HStack {
//                            ProgressView()
//                            Text("Loading...")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//
//                // --- Image Picker Section ---
//                Section(header: Text("Image Picker (PHPicker)")) {
//                    if let image = masterViewModel.selectedImage {
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxHeight: 200)
//                            .padding(.vertical, 5)
//                            .accessibilityLabel("Selected image")
//                    } else {
//                        Label("No image selected.", systemImage: "photo")
//                            .foregroundColor(.secondary)
//                            .accessibilityHint("Use buttons below to select an image.")
//                    }
//
//                    HStack {
//                        Button {
//                            // PHPicker doesn't need source type selection before presenting
//                            // It accesses the library directly.
//                            showingImagePicker = true
//                        } label: {
//                            Label("Select from Library", systemImage: "photo.on.rectangle")
//                        }
//
//                        Spacer() // Add space if camera is available
//
//                        if isCameraAvailable {
//                            // We can't use PHPicker for *direct* camera capture easily.
//                            // Stick to the old ImagePicker for camera ONLY if needed,
//                            // or use a more complex custom camera solution.
//                            // For this example, we'll *disable* camera via PHPicker route
//                            // and add a note. If camera REQUIRED, need UIImagePickerController back for that specific case.
//                            // --- OR --- just keep the library button
//                            /*
//                            Button {
//                                selectedSourceForPicker = .camera
//                                showingImagePicker = true // Re-use picker sheet bool, but logic inside .sheet will adapt
//                            } label: {
//                                Label("Use Camera", systemImage: "camera")
//                            }
//                            .disabled(!isCameraAvailable) // Keep disabled check
//                            */
//                        }
//                    }
//                    .buttonStyle(.bordered)
//                     Text("Note: PHPicker primarily accesses the Photo Library. Direct camera capture requires separate handling (e.g., legacy UIImagePickerController or custom camera view).")
//                         .font(.caption2)
//                         .foregroundColor(.secondary)
//                }
//
//                // --- Safari View Section ---
//                Section(header: Text("Safari View Controller")) {
//                     HStack {
//                         Button("Apple Dev Site") {
//                             openSafari(with: "https://developer.apple.com/swiftui/")
//                         }
//                         Spacer()
//                         Button("Example.com") {
//                             openSafari(with: "https://www.example.com")
//                         }
//                     }.buttonStyle(.bordered)
//
//                     if let lastURL = masterViewModel.lastSafariUrlFinished {
//                         Text("Last viewed: \(lastURL.host ?? "N/A")")
//                             .font(.caption)
//                             .foregroundColor(.secondary)
//                     }
//                }
//
//                // --- Drawing Pad Section ---
//                Section(header: Text("Drawing Pad")) {
//                    Text("Strokes: \(masterViewModel.drawingStrokeCount)")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                         .frame(maxWidth: .infinity, alignment: .trailing) // Align to right
//
//                    // Configuration Controls
//                    ColorPicker("Stroke Color", selection: $drawingStrokeColor, supportsOpacity: false)
//                    HStack {
//                        Text("Width: \(Int(drawingStrokeWidth))pt")
//                        Slider(value: $drawingStrokeWidth, in: 1...20, step: 1) // Min/Max width
//                    }
//
//                    DrawingPadRepresentable(
//                        masterViewModel: masterViewModel,
//                        strokeColor: $drawingStrokeColor,
//                        strokeWidth: $drawingStrokeWidth,
//                        needsClear: $clearDrawingPad
//                        // onSaveRequest: { image in /* Handle saved image */ }
//                    )
//                        .frame(minHeight: 250, idealHeight: 300) // Give it space
//                        .border(Color.gray.opacity(0.5), width: 1)
//                        .accessibilityLabel("Drawing Canvas")
//
//                     Button("Clear Drawing", role: .destructive) { // Use destructive role
//                         clearDrawingPad = true
//                     }
//                     .buttonStyle(.bordered)
//                     .frame(maxWidth: .infinity, alignment: .center) // Center button
//                }
//            }
//            .navigationTitle("Mixed UIKit Coordinators")
//            .listStyle(.insetGrouped) // Nicer list style
//
//            // --- Modal Presentations ---
//            .sheet(isPresented: $showingImagePicker) {
//                 // Using PHPicker - doesn't need source type here
//                PHPickerRepresentable(
//                    masterViewModel: masterViewModel,
//                    isPresented: $showingImagePicker,
//                    selectionLimit: 1, // Only allow one image
//                    filter: .images // Only allow images
//                )
//            }
//            .fullScreenCover(isPresented: $showingSafariView) {
//                 // Ensure URL is valid *before* presenting the sheet
//                 // The check is now in the openSafari function
//                 if let url = safariURL {
//                    SafariViewRepresentable(
//                        url: url,
//                        masterViewModel: masterViewModel,
//                        preferredControlTintColor: .systemPink // Example config
//                    )
//                    .ignoresSafeArea() // Often desired for SafariVC
//                 }
//                 // No need for else clause here if check is done *before* setting showingSafariView = true
//            }
//            // --- Alert for Errors ---
//           .onChange(of: masterViewModel.currentError) {
//               if let error = masterViewModel.currentError {
//                   // Trigger alert presentation when a new error arrives
//                   showingErrorAlert = (error != nil)
//               } else {
//                   return
//               }
//              
//           }
//           .alert(
//               masterViewModel.currentError?.localizedDescription ?? "An error occurred",
//               isPresented: $showingErrorAlert,
//               presenting: masterViewModel.currentError // Pass error data to alert closure
//           ) { errorData in
//               // Actions for the alert
//               Button("Dismiss", role: .cancel) {
//                    masterViewModel.clearError() // Clear error when dismissed
//               }
//               // Optionally add more buttons based on error type or recovery suggestions
//           } message: { errorData in
//                // Show recovery suggestion if available
//                if let suggestion = errorData.recoverySuggestion {
//                     Text(suggestion)
//                }
//           }
//        }
//        .navigationViewStyle(.stack) // Consistent style
//    }
//
//    // Helper function to handle Safari opening safely
//    private func openSafari(with urlString: String) {
//        if let url = URL(string: urlString) {
//            self.safariURL = url
//            self.showingSafariView = true
//            masterViewModel.clearError() // Clear previous errors if successfully opening
//        } else {
//            // Handle the error case *before* trying to present
//            masterViewModel.handleAppError(.safariURLError(urlString))
//        }
//    }
//}
//
//// MARK: - Preview Provider
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//// MARK: - App Entry Point (Uncomment if needed)
///*
//@main
//struct MixedCoordinationApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                // Inject Environment Objects if necessary
//                // .environmentObject(SomeGlobalService())
//        }
//    }
//}
//*/
