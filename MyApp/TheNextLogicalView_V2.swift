//
//  TheNextLogicalView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//
import SwiftUI
import PhotosUI
import UIKit
import SafariServices         // For SFSafariViewController
import PhotosUI             // Needed for PHPickerViewController
import LinkPresentation     // For richer Share Sheet previews
import Photos               // For Saving to Library

// MARK: - Error Handling Enum
enum AppError: LocalizedError {
    case pickerLoadingFailed(Error?)
    case safariURLError(String)
    case sourceUnavailable(String)
    case generic(String)
    case saveFailed(Error?) // Specific error for saving

    var errorDescription: String? {
        switch self {
        case .pickerLoadingFailed:
            return "Failed to load the selected image."
        case .safariURLError(let url):
            return "Cannot open invalid URL: \(url)"
        case .sourceUnavailable(let source):
            return "The source '\(source)' is not available on this device."
        case .generic(let message):
            return message
        case .saveFailed:
            return "Failed to save image to Photo Library."
        }
    }

    // Optional: Provide recovery suggestions
    var recoverySuggestion: String? {
         switch self {
         case .pickerLoadingFailed:
             return "Please try selecting the image again."
         case .safariURLError:
             return "Please check the URL and try again."
         case .sourceUnavailable:
             return "Please ensure the source exists and permissions are granted (e.g., camera access)."
         case .generic:
             return "Please try the action again later or contact support if the issue persists."
         case .saveFailed(let underlyingError):
             var message = "Please ensure the app has permission to add photos in Settings."
             if let error = underlyingError {
                message += "\nDetails: \(error.localizedDescription)"
             }
             return message
         }
     }
}

// MARK: - 1. Master View Model (Refined State & Asynchronous Handling)

@MainActor // Ensure UI updates happen on the main actor
class MasterViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var lastSafariUrlFinished: URL?
    @Published var drawingStrokeCount: Int = 0
    @Published var statusMessage: String = "App Ready"
    @Published var currentError: AppError? = nil // Use specific error type
    @Published var isLoading: Bool = false // For showing loading indicators

    // -- State for Export Functionality --
    @Published var drawingImageForExport: UIImage? = nil // Store the retrieved drawing for export
    @Published var isPreparingExport: Bool = false // Indicate loading for export prep
    // Keep track of the drawing coordinator to request the image
    // We'll set this from the Representable's makeCoordinator
    weak var drawingCoordinator: DrawingPadRepresentable.Coordinator?

    // --- Methods called by Specialized Coordinators or Actions ---

    // PHPicker Callbacks
    func imagePickerDidFinish(image: UIImage?) {
        if let img = image {
            self.selectedImage = img
            self.statusMessage = "Image selected."
            self.currentError = nil
        } else {
            self.selectedImage = nil
            if !isLoading {
                self.statusMessage = "Image selection cancelled or failed."
            }
        }
        print("MasterViewModel: Image picker finished.")
    }

    func imagePickerDidCancel() {
        self.isLoading = false
        self.selectedImage = nil
        self.statusMessage = "Image selection cancelled."
        self.currentError = nil
        print("MasterViewModel: Image picker cancelled.")
    }

    // Safari View Controller Callbacks
    func safariViewControllerDidFinish(url: URL?) {
        self.lastSafariUrlFinished = url
        self.statusMessage = "Safari view dismissed for: \(url?.host ?? "N/A")"
        print("MasterViewModel: Safari VC finished for URL: \(url?.absoluteString ?? "N/A")")
    }

    // Custom Drawing Pad Callbacks
    func drawingPadDidChange(strokeCount: Int) {
        if self.drawingStrokeCount != strokeCount {
            self.drawingStrokeCount = strokeCount
            self.statusMessage = "Drawing updated: \(strokeCount) strokes."
        }
    }

    // Error Handling
    func handleAppError(_ error: AppError) {
         self.isLoading = false
         self.isPreparingExport = false // Ensure export loading also stops
         self.currentError = error
         self.statusMessage = "Error occurred."
         print("MasterViewModel: Error - \(error.localizedDescription)")
    }

    func clearError() {
        self.currentError = nil
    }

    // --- Export Related Methods ---
    func prepareDrawingForExport() {
        guard drawingCoordinator != nil else {
            print("MasterViewModel: Drawing coordinator not available for export request.")
             // If there's no drawing pad, just use the selected image (if any)
             self.drawingImageForExport = nil // Ensure it's cleared if coordinator gone
             self.statusMessage = "Ready for export (no drawing pad)."
            return
        }
        print("MasterViewModel: Requesting drawing for export...")
        self.isPreparingExport = true
        // Ask the coordinator (if it exists) to capture the image
        let capturedImage = drawingCoordinator?.captureDrawingImage()

        // Update the published property on the main thread
        Task { @MainActor in
            self.drawingImageForExport = capturedImage
            self.isPreparingExport = false
            if capturedImage != nil {
                self.statusMessage = "Drawing prepared for export."
                 print("MasterViewModel: Drawing image captured.")
            } else {
                 self.statusMessage = "No drawing content captured." // More neutral message if empty
                 print("MasterViewModel: No drawing content to capture.")
                 // Don't trigger an error if the pad was just empty
                 // self.handleAppError(.generic("Failed to capture drawing."))
            }
        }
    }

    func clearExportDrawing() {
         self.drawingImageForExport = nil
         print("MasterViewModel: Cleared export drawing.")
    }
}

// MARK: - 2. Specialized Representables and their Coordinators

// --- PHPicker Representable ---
struct PHPickerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var masterViewModel: MasterViewModel
    @Binding var isPresented: Bool
    let selectionLimit: Int
    let filter: PHPickerFilter?

    func makeCoordinator() -> Coordinator {
        Coordinator(self, masterViewModel: masterViewModel)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        print("PHPickerRepresentable: makeUIViewController created")
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = filter
        config.selectionLimit = selectionLimit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
         print("PHPickerRepresentable: updateUIViewController called")
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PHPickerRepresentable
        var masterViewModel: MasterViewModel

        init(_ parent: PHPickerRepresentable, masterViewModel: MasterViewModel) {
            self.parent = parent
            self.masterViewModel = masterViewModel
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false

            guard let result = results.first else {
                Task { await masterViewModel.imagePickerDidCancel() }
                return
            }

            let itemProvider = result.itemProvider
            guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
                Task {
                    await masterViewModel.handleAppError(.generic("Cannot load selected item as image."))
                    await masterViewModel.imagePickerDidFinish(image: nil)
                }
                return
            }

            Task { await masterViewModel.isLoading = true }

            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                 Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    await self.masterViewModel.isLoading = false

                    if let error = error {
                        print("Error loading image: \(error)")
                        await self.masterViewModel.handleAppError(.pickerLoadingFailed(error))
                        await self.masterViewModel.imagePickerDidFinish(image: nil)
                    } else if let uiImage = image as? UIImage {
                        print("Coordinator: Image loaded successfully")
                        await self.masterViewModel.imagePickerDidFinish(image: uiImage)
                    } else {
                         await self.masterViewModel.handleAppError(.generic("Loaded object was not a UIImage."))
                         await self.masterViewModel.imagePickerDidFinish(image: nil)
                    }
                }
            }
        }
    }
}

// --- Safari View Controller Representable ---
struct SafariViewRepresentable: UIViewControllerRepresentable {
    let url: URL
    @ObservedObject var masterViewModel: MasterViewModel
    var preferredBarTintColor: UIColor? = nil
    var preferredControlTintColor: UIColor? = .systemBlue

    func makeCoordinator() -> Coordinator {
        Coordinator(self, masterViewModel: masterViewModel)
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        print("SafariViewRepresentable: makeUIViewController created for URL: \(url)")
        let config = SFSafariViewController.Configuration()
        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.delegate = context.coordinator
        safariVC.preferredBarTintColor = preferredBarTintColor
        safariVC.preferredControlTintColor = preferredControlTintColor
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        print("SafariViewRepresentable: updateUIViewController called")
    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariViewRepresentable
        var masterViewModel: MasterViewModel

        init(_ parent: SafariViewRepresentable, masterViewModel: MasterViewModel) {
            self.parent = parent
            self.masterViewModel = masterViewModel
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            print("Coordinator: Safari VC Did finish")
            Task { @MainActor in
                masterViewModel.safariViewControllerDidFinish(url: parent.url)
            }
        }
         func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
             print("Safari redirected to: \(URL)")
         }
    }
}

// --- Custom Drawing Pad (View and Delegate) ---
protocol DrawingPadViewDelegate: AnyObject {
    func drawingPadDidChange(strokeCount: Int)
    func drawingPadDidEndStroke()
}

class DrawingPadView: UIView {
    private var paths: [UIBezierPath] = []
    private var currentPath: UIBezierPath?
    private var pathColor: UIColor = .black
    private var lineWidth: CGFloat = 3.0
    weak var delegate: DrawingPadViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    private func setupView() {
        backgroundColor = .clear // Make background transparent for potential overlaying/export
        isMultipleTouchEnabled = false
        clearsContextBeforeDrawing = true
    }

    func setStrokeColor(_ color: UIColor) { self.pathColor = color }
    func setStrokeWidth(_ width: CGFloat) { self.lineWidth = max(1.0, width)}

    func clearDrawing() {
        paths.removeAll()
        currentPath = nil
        setNeedsDisplay()
        delegate?.drawingPadDidChange(strokeCount: paths.count)
        print("DrawingPadView: Cleared")
    }

    func getDrawingImage() -> UIImage? {
        // Return nil if no paths have been drawn to avoid creating an empty image
        guard !paths.isEmpty else { return nil }

        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { context in
            // Important: If background was .clear, don't fill it here
             // If a non-clear background is sometimes needed, handle it conditionally
            // Draw existing paths
            pathColor.setStroke()
            for path in paths {
                path.lineWidth = self.lineWidth  // Ensure consistent width during render
                path.stroke()
            }
        }
        // Only return the image if it actually contains content (check for non-empty paths)
        return image
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        currentPath = UIBezierPath()
        currentPath?.lineWidth = lineWidth
        currentPath?.lineCapStyle = .round
        currentPath?.lineJoinStyle = .round
        currentPath?.move(to: touch.location(in: self))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let path = currentPath else { return }
        path.addLine(to: touch.location(in: self))
        setNeedsDisplay()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let path = currentPath else { return }
        // Only add non-empty paths (e.g., if user just taps)
        if !path.isEmpty {
             paths.append(path)
             delegate?.drawingPadDidChange(strokeCount: paths.count)
        }
        currentPath = nil
        setNeedsDisplay()
        delegate?.drawingPadDidEndStroke()
        print("DrawingPadView: Stroke ended, total paths: \(paths.count)")
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPath = nil
        setNeedsDisplay()
        print("DrawingPadView: Touch cancelled")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        pathColor.setStroke()
        for path in paths {
            path.lineWidth = lineWidth
            path.stroke()
        }
        currentPath?.lineWidth = lineWidth
        currentPath?.stroke()
    }
}

// --- Drawing Pad Representable ---
struct DrawingPadRepresentable: UIViewRepresentable {
    @ObservedObject var masterViewModel: MasterViewModel
    @Binding var strokeColor: Color
    @Binding var strokeWidth: CGFloat
    @Binding var needsClear: Bool

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self, masterViewModel: masterViewModel)
        // Set the coordinator reference in the ViewModel
        Task { @MainActor in
            masterViewModel.drawingCoordinator = coordinator
            print("DrawingPadRepresentable: Coordinator reference set in ViewModel.")
        }
        return coordinator
    }

    func makeUIView(context: Context) -> DrawingPadView {
        print("DrawingPadRepresentable: makeUIView created")
        let drawingView = DrawingPadView()
        drawingView.delegate = context.coordinator
        drawingView.setStrokeColor(UIColor(strokeColor))
        drawingView.setStrokeWidth(strokeWidth)
        context.coordinator.drawingPadView = drawingView // Give coordinator access
        return drawingView
    }

    func updateUIView(_ uiView: DrawingPadView, context: Context) {
        print("DrawingPadRepresentable: updateUIView called")
        uiView.setStrokeColor(UIColor(strokeColor))
        uiView.setStrokeWidth(strokeWidth)
        if needsClear {
            print("DrawingPadRepresentable: Clearing drawing")
            uiView.clearDrawing()
            DispatchQueue.main.async {
                self.needsClear = false
            }
        }
    }

    class Coordinator: NSObject, DrawingPadViewDelegate {
        var parent: DrawingPadRepresentable
        var masterViewModel: MasterViewModel
        weak var drawingPadView: DrawingPadView?

        init(_ parent: DrawingPadRepresentable, masterViewModel: MasterViewModel) {
            self.parent = parent
            self.masterViewModel = masterViewModel
        }

        func drawingPadDidChange(strokeCount: Int) {
            Task { @MainActor in
                 masterViewModel.drawingPadDidChange(strokeCount: strokeCount)
            }
        }
        func drawingPadDidEndStroke() {
            print("Coordinator: Drawing stroke ended.")
        }
        // Method called by ViewModel to capture the drawing
        func captureDrawingImage() -> UIImage? {
            return drawingPadView?.getDrawingImage()
        }
    }
}

// --- UIActivityViewController Representable (Share Sheet) ---
struct ActivityViewRepresentable: UIViewControllerRepresentable {

    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    @Binding var isPresented: Bool
    var completion: UIActivityViewController.CompletionWithItemsHandler? = nil

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController() // Dummy VC for presentation host
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            print("ActivityViewRepresentable: Presenting Share Sheet")
            let controller = UIActivityViewController(
                activityItems: mapActivityItems(activityItems),
                applicationActivities: applicationActivities
            )

            if let popoverController = controller.popoverPresentationController {
                popoverController.sourceView = uiViewController.view
                popoverController.sourceRect = CGRect(x: uiViewController.view.bounds.midX, y: uiViewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                print("ActivityViewRepresentable: Share sheet completed. Activity: \(activityType?.rawValue ?? "None"), Completed: \(completed), Error: \(error?.localizedDescription ?? "None")")
                DispatchQueue.main.async {
                    self.completion?(activityType, completed, returnedItems, error)
                    self.isPresented = false
                }
            }

            DispatchQueue.main.async {
                uiViewController.present(controller, animated: true, completion: nil)
            }
        } else if !isPresented && uiViewController.presentedViewController is UIActivityViewController {
            print("ActivityViewRepresentable: Dismissing Share Sheet via binding")
            uiViewController.dismiss(animated: true, completion: nil)
        }
    }

    private func mapActivityItems(_ items: [Any]) -> [Any] {
        return items.map { item in
            if let image = item as? UIImage {
                return ImageActivityItemSource(image: image, title: "My Creation") // Use custom source
            }
            return item
        }
    }
}

// --- Custom Item Source for Share Sheet Preview ---
class ImageActivityItemSource: NSObject, UIActivityItemSource {
    let image: UIImage
    let title: String

    init(image: UIImage, title: String) {
        self.image = image
        self.title = title
        super.init()
    }

    // Placeholder
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }

    // Actual item
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }

    // Subject
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    // LinkPresentation Metadata (Optional but recommended for better previews)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.iconProvider = NSItemProvider(object: image)
        metadata.imageProvider = NSItemProvider(object: image)
        return metadata
    }
}

// --- Subview for Image Picker Section ---
struct ImagePickerSectionView: View {
    @ObservedObject var masterViewModel: MasterViewModel
    @Binding var showingImagePicker: Bool

    var body: some View {
        Section(header: Text("Image Picker (PHPicker)")) {
            if let image = masterViewModel.selectedImage {
                Image(uiImage: image)
                    .resizable().scaledToFit().frame(maxHeight: 200)
                    .padding(.vertical, 5).accessibilityLabel("Selected image")
            } else {
                Label("No image selected.", systemImage: "photo")
                    .foregroundColor(.secondary)
                    .accessibilityHint("Use button below to select an image.")
            }
            Button { showingImagePicker = true } label: {
                Label("Select from Library", systemImage: "photo.on.rectangle")
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .center) // Center button text
        }
    }
}


// --- Subview for Safari Section ---
struct SafariSectionView: View {
    @ObservedObject var masterViewModel: MasterViewModel
    // Accept the action as a closure
    let openSafariAction: (String) -> Void

    var body: some View {
        Section(header: Text("Safari View Controller")) {
             HStack {
                 // Call the closure passed from the parent
                 Button("Apple Dev Site") { openSafariAction("https://developer.apple.com/swiftui/") }
                 Spacer()
                 Button("Example.com") { openSafariAction("https://www.example.com") }
             }.buttonStyle(.bordered)
             if let lastURL = masterViewModel.lastSafariUrlFinished {
                 Text("Last viewed: \(lastURL.host ?? "N/A")")
                     .font(.caption).foregroundColor(.secondary)
             }
        }
    }
}

// --- Subview for Drawing Pad Section ---
struct DrawingPadSectionView: View {
    @ObservedObject var masterViewModel: MasterViewModel
    @Binding var strokeColor: Color
    @Binding var strokeWidth: CGFloat
    @Binding var needsClear: Bool // Renamed from clearDrawingPad for clarity

    var body: some View {
        Section(header: Text("Drawing Pad")) {
             // Keep status inline for simplicity or move if needed
             HStack {
                 Spacer() // Push to the right
                 Text("Strokes: \(masterViewModel.drawingStrokeCount)")
                      .font(.caption).foregroundColor(.secondary)
             }
            ColorPicker("Stroke Color", selection: $strokeColor, supportsOpacity: false)
            HStack {
                Text("Width: \(Int(strokeWidth))pt")
                Slider(value: $strokeWidth, in: 1...20, step: 1)
            }
            DrawingPadRepresentable(
                masterViewModel: masterViewModel,
                strokeColor: $strokeColor,
                strokeWidth: $strokeWidth,
                needsClear: $needsClear // Pass the binding
            )
                .frame(minHeight: 250, idealHeight: 300)
                .border(Color.gray.opacity(0.5), width: 1)
                .accessibilityLabel("Drawing Canvas")

            Button("Clear Drawing", role: .destructive) {
                needsClear = true // Set the binding to true
            }
             .buttonStyle(.bordered)
             .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// --- Subview for Export Button Section ---
struct ExportButtonSection: View {
    @ObservedObject var masterViewModel: MasterViewModel
    @Binding var showingExportView: Bool

    var body: some View {
        Section {
             Button { showingExportView = true } label: {
                 Label("Preview & Export Content", systemImage: "arrow.turn.up.right")
                     .frame(maxWidth: .infinity) // Ensures label fills width
             }
             .buttonStyle(.borderedProminent)
             .disabled(masterViewModel.selectedImage == nil && masterViewModel.drawingStrokeCount == 0)
             .accessibilityHint("Opens a screen to share or save the image or drawing.")
             .frame(maxWidth: .infinity, alignment: .center) // Center button
         }
    }
}

// --- ContentView (Modified Body) ---
struct ContentView: View {
    @StateObject private var masterViewModel = MasterViewModel()

    // Presentation State (remains here)
    @State private var showingImagePicker = false
    @State private var showingSafariView = false
    @State private var showingErrorAlert = false
    @State private var showingExportView = false // For ExportView modal

    // Configuration State (remains here or passed down)
    @State private var safariURL: URL? = nil
    @State private var drawingStrokeColor: Color = .blue
    @State private var drawingStrokeWidth: CGFloat = 4.0
    // Needs state for clearing, used by DrawingPadSectionView
    @State private var needsClearDrawing = false

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        NavigationView {
            List {
                // --- Status Section (kept simple, could also be extracted) ---
                Section(header: Text("Status")) {
                    Text(masterViewModel.statusMessage)
                        .foregroundColor(masterViewModel.currentError != nil ? .orange : .primary)
                    if masterViewModel.isLoading || masterViewModel.isPreparingExport {
                        HStack { ProgressView(); Text("Loading...") }
                            .font(.caption).foregroundColor(.secondary)
                    }
                }

                // --- Use Extracted Views ---
                ImagePickerSectionView(
                    masterViewModel: masterViewModel,
                    showingImagePicker: $showingImagePicker
                )

                SafariSectionView(
                    masterViewModel: masterViewModel,
                    openSafariAction: openSafari // Pass the helper function
                )

                DrawingPadSectionView(
                    masterViewModel: masterViewModel,
                    strokeColor: $drawingStrokeColor,
                    strokeWidth: $drawingStrokeWidth,
                    needsClear: $needsClearDrawing // Pass the new state binding
                )

                ExportButtonSection(
                    masterViewModel: masterViewModel,
                    showingExportView: $showingExportView
                )
            }
            .navigationTitle("Mixed UIKit Coordinators")
            .listStyle(.insetGrouped)

            // --- Modal Presentations (remain attached here) ---
            .sheet(isPresented: $showingImagePicker) {
                PHPickerRepresentable(
                    masterViewModel: masterViewModel,
                    isPresented: $showingImagePicker,
                    selectionLimit: 1, filter: .images
                )
            }
            .fullScreenCover(isPresented: $showingSafariView) {
                 if let url = safariURL {
                     SafariViewRepresentable(url: url, masterViewModel: masterViewModel, preferredControlTintColor: .systemPink)
                    .ignoresSafeArea()
                 } else {
                    // Optional: Add a fallback view or just don't present
                    // if url is nil, though the logic should prevent this.
                    EmptyView()
                 }
            }
            .sheet(isPresented: $showingExportView) {
                 ExportView(masterViewModel: masterViewModel)
            }

            // --- Alert for Errors (remains attached here) ---
//           .onChange(of: masterViewModel.currentError) {
//               showingErrorAlert = (masterViewModel.currentError != nil)
//           }
           .alert(
               masterViewModel.currentError?.localizedDescription ?? "An error occurred",
               isPresented: $showingErrorAlert,
               presenting: masterViewModel.currentError
           ) { errorData in
               Button("Dismiss", role: .cancel) { masterViewModel.clearError() }
           } message: { errorData in
                if let suggestion = errorData.recoverySuggestion { Text(suggestion) }
           }
        }
        .navigationViewStyle(.stack) // Good practice for consistency
    }

    // Helper function remains in ContentView as it modifies ContentView's state
    private func openSafari(with urlString: String) {
        if let url = URL(string: urlString) {
            self.safariURL = url
            self.showingSafariView = true
            masterViewModel.clearError() // Clear previous errors when attempting to open
        } else {
            masterViewModel.handleAppError(.safariURLError(urlString))
        }
    }
}


// --- Subview for Export Preview ---
struct ExportPreviewView: View {
    @ObservedObject var masterViewModel: MasterViewModel

    private var imageToExport: UIImage? {
         masterViewModel.drawingImageForExport ?? masterViewModel.selectedImage
    }

    var body: some View {
        if let previewImage = imageToExport {
             Image(uiImage: previewImage)
                 .resizable()
                 .scaledToFit()
                 .frame(maxHeight: 300)
                 .background(Color.gray.opacity(0.2))
                 .border(Color.gray)
                 .accessibilityLabel("Preview of the image or drawing to be exported")
         } else if masterViewModel.isPreparingExport {
              ProgressView("Preparing Preview...")
             .frame(minHeight: 300) // Use minHeight to ensure space
         } else {
             VStack {
                 Image(systemName: "photo.fill.on.rectangle.fill")
                     .font(.largeTitle)
                     .foregroundColor(.secondary)
                 Text("No Content to Export")
                     .foregroundColor(.secondary)
                     .padding(.top, 5)
             }
              .frame(minHeight: 300) // Use minHeight
              .accessibilityLabel("No content available for export")
         }
    }
}

// --- Subview for Export Actions ---
struct ExportActionsView: View {
    @ObservedObject var masterViewModel: MasterViewModel
    @Binding var isShareSheetPresented: Bool
    let saveAction: () -> Void // Closure for the save action

    private var imageToExport: UIImage? {
         masterViewModel.drawingImageForExport ?? masterViewModel.selectedImage
    }

    var body: some View {
        Group {
            Button {
                if imageToExport != nil { isShareSheetPresented = true }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(imageToExport == nil || masterViewModel.isPreparingExport)

            Button {
                saveAction() // Call the passed-in save action
            } label: {
                Label("Save to Photos", systemImage: "photo.on.rectangle.angled")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(imageToExport == nil || masterViewModel.isPreparingExport)
        }
        .padding(.horizontal)
    }
}

// --- ExportView (Modified Body) ---
struct ExportView: View {
    @ObservedObject var masterViewModel: MasterViewModel
    @Environment(\.dismiss) var dismiss

    @State private var isShareSheetPresented = false
    @State private var showSaveAlert = false
    @State private var saveStatusMessage = ""
    @State private var saveDidFail = false

    var body: some View {
        NavigationView {
           VStack(spacing: 20) {
                 Text("Preview").font(.headline)

                 ExportPreviewView(masterViewModel: masterViewModel) // Use extracted view

                 Spacer()

                 ExportActionsView( // Use extracted view
                    masterViewModel: masterViewModel,
                    isShareSheetPresented: $isShareSheetPresented,
                    saveAction: saveImageToLibrary // Pass the method reference
                 )

             }
             .padding(.vertical) // Keep padding on the VStack
             .navigationTitle("Export & Share")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
             }
             .onAppear { masterViewModel.prepareDrawingForExport() }
             .onDisappear { masterViewModel.clearExportDrawing() }
             .background(
                 ActivityViewRepresentable(
                      activityItems: [ // Provide image or placeholder safely
                          (masterViewModel.drawingImageForExport ?? masterViewModel.selectedImage) ?? UIImage()
                      ],
                       isPresented: $isShareSheetPresented,
                      completion: { activityType, completed, returnedItems, error in
                            // Completion handler remains here
                          if completed { masterViewModel.statusMessage = "Shared successfully." }
                          else if error == nil { masterViewModel.statusMessage = "Share cancelled." }
                          else { masterViewModel.handleAppError(.generic("Sharing failed: \(error!.localizedDescription)")) }
                       }
                 )
                 .frame(width: 0, height: 0) // Keep background modifier setup
             )
             .alert(isPresented: $showSaveAlert) { // Alert remains here
                  Alert(
                      title: Text(saveDidFail ? "Error Saving" : "Image Saved"),
                      message: Text(saveStatusMessage),
                      dismissButton: .default(Text("OK"))
                  )
              }
         }
         .navigationViewStyle(.stack)
         .interactiveDismissDisabled(masterViewModel.isPreparingExport)
     }

    // Save logic remains within ExportView as it manages state for the alert
    private func saveImageToLibrary() {
        guard let image = masterViewModel.drawingImageForExport ?? masterViewModel.selectedImage else {
             saveStatusMessage = "No image available to save."
             saveDidFail = true
             showSaveAlert = true
             return
        }
        // ... (rest of the saveImageToLibrary logic is unchanged)
         let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
         switch status {
         case .authorized, .limited: performSave(image: image)
         case .denied, .restricted:
              saveStatusMessage = "Photo Library access denied or restricted. Please update permissions in Settings."
              saveDidFail = true
              showSaveAlert = true
         case .notDetermined:
             PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                  DispatchQueue.main.async {
                      if newStatus == .authorized || newStatus == .limited {
                          self.performSave(image: image)
                      } else {
                          self.saveStatusMessage = "Photo Library permission denied. Please grant permission in Settings to save."
                          self.saveDidFail = true
                          self.showSaveAlert = true
                      }
                  }
             }
         @unknown default:
             saveStatusMessage = "Unknown Photo Library authorization status."
             saveDidFail = true
             showSaveAlert = true
         }
    }

    // performSave remains unchanged
    private func performSave(image: UIImage) {
         PHPhotoLibrary.shared().performChanges({
             PHAssetChangeRequest.creationRequestForAsset(from: image)
         }) { success, error in
             DispatchQueue.main.async {
                 if success {
                     self.saveStatusMessage = "Successfully saved to photos."
                     self.saveDidFail = false
                     self.masterViewModel.statusMessage = "Image saved to Photos."
                 } else {
                     self.saveStatusMessage = "Failed to save image."
                     self.saveDidFail = true
                     self.masterViewModel.handleAppError(.saveFailed(error))
                     if let err = error {
                         self.saveStatusMessage += "\n\(err.localizedDescription)"
                     }
                 }
                 self.showSaveAlert = true
             }
         }
     }
}
