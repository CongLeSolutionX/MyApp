//
//  ComponentPreviews.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

// Functional Previews for the reusable subviews using mock/default data.

import SwiftUI
import PhotosUI // Needed for MasterViewModel properties
// MARK: - Helper: Mock MasterViewModel (Corrected for Concurrency)

@MainActor // Ensure mock updates happen on main actor if needed
class MockMasterViewModel: MasterViewModel {

    // --- Add a strong holder for the mock coordinator ---
    private var strongMockCoordinatorHolder: MockDrawingCoordinator?
    // ---

    // Convenience initializer for previews
    convenience init(
        selectedImage: UIImage? = nil,
        lastSafariUrlFinished: URL? = nil,
        drawingStrokeCount: Int = 0,
        statusMessage: String = "Preview Ready",
        currentError: AppError? = nil,
        isLoading: Bool = false,
        drawingImageForExport: UIImage? = nil,
        isPreparingExport: Bool = false
    ) {
        self.init() // Call the designated initializer of the superclass
        self.selectedImage = selectedImage
        self.lastSafariUrlFinished = lastSafariUrlFinished
        self.drawingStrokeCount = drawingStrokeCount
        self.statusMessage = statusMessage
        self.currentError = currentError
        self.isLoading = isLoading
        self.drawingImageForExport = drawingImageForExport
        self.isPreparingExport = isPreparingExport

        // Simulate drawing coordinator being available if needed for export previews
        if drawingImageForExport != nil || drawingStrokeCount > 0 {
            // Create and hold the mock coordinator strongly
            let mockCoord = MockDrawingCoordinator(mockImage: drawingImageForExport)
            self.drawingCoordinator = mockCoord        // Assign to the weak property
            self.strongMockCoordinatorHolder = mockCoord // Assign to the strong holder
        }
    }

    // --- Mark MockDrawingCoordinator as @MainActor ---
    @MainActor
    class MockDrawingCoordinator: DrawingPadRepresentable.Coordinator {
        private let mockImage: UIImage?
        init(mockImage: UIImage?) {
            self.mockImage = mockImage
            // Now calling MockMasterViewModel() is okay because both inits are @MainActor
            super.init(
                // Provide minimal representable - consider making a static instance?
                DrawingPadRepresentable(masterViewModel: MockMasterViewModel(),
                                        strokeColor: .constant(.black),
                                        strokeWidth: .constant(1),
                                        needsClear: .constant(false)),
                masterViewModel: MockMasterViewModel() // Dummy VM still fine here
            )
        }
        override func captureDrawingImage() -> UIImage? {
            print("MockDrawingCoordinator: Providing mock image for export.")
            return mockImage
        }
    }
    // --- End of MockDrawingCoordinator ---
}

// Rest of the preview code (helpers, wrappers, preview providers) remains the same...

// Helper to create a simple placeholder image (Reused)
func createPlaceholderImage(systemName: String = "photo", pointSize: CGFloat = 50, bgColor: UIColor = .systemGray5) -> UIImage? {
    let config = UIImage.SymbolConfiguration(pointSize: pointSize)
    guard let symbolImage = UIImage(systemName: systemName, withConfiguration: config) else { return nil }

    let format = UIGraphicsImageRendererFormat()
    format.scale = 1 // Ensure scale is 1 for consistent size
    let size = CGSize(width: pointSize * 1.5, height: pointSize * 1.5) // Slightly larger canvas
    let renderer = UIGraphicsImageRenderer(size: size, format: format)

    let image = renderer.image { ctx in
        // Fill background
        let uiColor = bgColor
        uiColor.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))

        // Center the symbol
        let symbolRect = CGRect(
            x: (size.width - symbolImage.size.width) / 2,
            y: (size.height - symbolImage.size.height) / 2,
            width: symbolImage.size.width,
            height: symbolImage.size.height
        )
        // Use a contrasting tint color
        (bgColor.isLight ? UIColor.black : UIColor.white).set()
        symbolImage.withRenderingMode(.alwaysTemplate).draw(in: symbolRect)

    }
    return image
}

// Helper extension for color brightness check (Reused)
extension UIColor {
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }
}

// MARK: - ImagePickerSectionView Functional Previews (No Changes Needed Here)

struct ImagePickerSectionFunctionalPreviewWrapper: View {
    // Use StateObject for the VM within the preview wrapper
    @StateObject var viewModel: MockMasterViewModel
    // Use State for the binding needed by the view
    @State private var showingImagePicker = false

    var body: some View {
        List { // Embed in List for realistic section context
            ImagePickerSectionView(
                masterViewModel: viewModel,
                showingImagePicker: $showingImagePicker // Pass the state binding
            )
            // Add text to show the state change
            Text("Image Picker Presented: \(showingImagePicker ? "Yes" : "No")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onChange(of: showingImagePicker) {
            // Simulate dismissing the picker after a delay in preview
            if showingImagePicker {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showingImagePicker = false
                    // Optionally simulate selecting an image
                    // viewModel.selectedImage = createPlaceholderImage(systemName: "checkmark.circle.fill")
                    print("Preview: Simulated image picker dismissal.")
                }
            }
        }
    }
}

struct ImagePickerSectionView_FunctionalPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            ImagePickerSectionFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: nil)
            )
            .previewDisplayName("No Image Selected (Interactive)")

            ImagePickerSectionFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: createPlaceholderImage(systemName: "swift", pointSize: 60, bgColor: .systemOrange))
            )
            .previewDisplayName("Image Selected (Interactive)")
        }
        .previewLayout(.sizeThatFits) // Fit section content
        .padding() // Add padding for visual separation
    }
}

// MARK: - SafariSectionView Functional Previews (No Changes Needed Here)

struct SafariSectionFunctionalPreviewWrapper: View {
    @StateObject var viewModel: MockMasterViewModel
    // State to track which URL was requested
    @State private var requestedURL: String? = nil

    // Action updates local state for feedback
    private func mockOpenAction(urlString: String) {
        print("Preview: Button tapped for \(urlString)")
        requestedURL = urlString
        // Simulate Safari finishing after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let url = URL(string: urlString) {
                viewModel.safariViewControllerDidFinish(url: url) // Update VM state
            }
            requestedURL = nil // Reset request state
        }
    }

    var body: some View {
        List {
            SafariSectionView(masterViewModel: viewModel, openSafariAction: mockOpenAction)
            if let reqURL = requestedURL {
                Text("Requesting: \(reqURL)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct SafariSectionView_FunctionalPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            SafariSectionFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel()
            )
            .previewDisplayName("No Last URL (Interactive)")

            SafariSectionFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel(lastSafariUrlFinished: URL(string: "https://www.example.com")!)
            )
            .previewDisplayName("Last URL Viewed (Interactive)")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

// MARK: - DrawingPadSectionView Functional Previews (No Changes Needed Here)

struct DrawingPadSectionFunctionalPreviewWrapper: View {
    @StateObject var viewModel: MockMasterViewModel = MockMasterViewModel(drawingStrokeCount: 0)
    // Use State for interactive controls
    @State private var strokeColor: Color = .cyan
    @State private var strokeWidth: CGFloat = 5.0
    @State private var needsClear = false

    var body: some View {
        List {
            DrawingPadSectionView(
                masterViewModel: viewModel,
                strokeColor: $strokeColor,
                strokeWidth: $strokeWidth,
                needsClear: $needsClear
            )
                // The DrawingPadRepresentable itself won't be interactive,
                // but controls around it will be.
                 .frame(height: 250) // Reduced height for preview focus

            // Display current state values for feedback
            Text("Current Color: \(strokeColor.description)")
            Text("Current Width: \(Int(strokeWidth))")
            Text("Needs Clear: \(needsClear ? "Yes" : "No")")
            Text("Simulated Strokes: \(viewModel.drawingStrokeCount)") // Show VM state

            // Add buttons to simulate drawing changes in preview
            HStack {
                Button("Simulate Stroke") {
                     // Update view model state directly for preview
                     viewModel.drawingPadDidChange(strokeCount: viewModel.drawingStrokeCount + 1)
                }
                Spacer()
                Button("Simulate Clear Confirm") {
                     // Simulate the representable setting needsClear back to false
                     if needsClear {
                         needsClear = false
                         viewModel.drawingPadDidChange(strokeCount: 0) // Reset stroke count
                         print("Preview: Simulated drawing clear confirmation.")
                     }
                }
                .disabled(!needsClear) // Only enable if needsClear is true
            }.buttonStyle(.bordered)

        }
    }
}

struct DrawingPadSectionView_FunctionalPreviews: PreviewProvider {
    static var previews: some View {
        DrawingPadSectionFunctionalPreviewWrapper()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Drawing Pad Section (Interactive Controls)")
            .padding()
    }
}

// MARK: - ExportButtonSection Functional Previews (No Changes Needed Here)

struct ExportButtonSectionFunctionalPreviewWrapper: View {
    @StateObject var viewModel: MockMasterViewModel
    @State private var showingExportView = false // Required Binding

    var body: some View {
        List {
            ExportButtonSection(
                masterViewModel: viewModel,
                showingExportView: $showingExportView
            )
            Text("Showing Export View: \(showingExportView ? "Yes" : "No")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        // Simulate dismissal of the sheet
         .onChange(of: showingExportView) {
             if showingExportView {
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                     showingExportView = false
                     print("Preview: Simulated export sheet dismissal.")
                 }
             }
         }
    }
}

struct ExportButtonSection_FunctionalPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            ExportButtonSectionFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: nil, drawingStrokeCount: 0)
            )
            .previewDisplayName("Disabled (No Content)")

            ExportButtonSectionFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: createPlaceholderImage(), drawingStrokeCount: 0)
            )
            .previewDisplayName("Enabled (Image) [Interactive]")

            ExportButtonSectionFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: nil, drawingStrokeCount: 10)
            )
            .previewDisplayName("Enabled (Drawing) [Interactive]")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

// MARK: - ExportPreviewView Functional Previews (No Changes Needed Here)

struct ExportPreviewView_FunctionalPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            // No special interaction here, just showing different VM states
            ExportPreviewView(masterViewModel: MockMasterViewModel())
                .previewDisplayName("No Content")

             ExportPreviewView(masterViewModel: MockMasterViewModel(selectedImage: createPlaceholderImage(systemName: "camera.macro.circle.fill", bgColor: .systemGreen)))
                 .previewDisplayName("Selected Image Preview")

            // Ensure mock coordinator provides the image
             ExportPreviewView(masterViewModel: MockMasterViewModel(drawingImageForExport: createPlaceholderImage(systemName: "pencil.and.scribble", bgColor: .systemYellow)))
                 .previewDisplayName("Drawing Preview")

            // Simulate export preparation
             ExportPreviewView(masterViewModel: MockMasterViewModel(isPreparingExport: true))
                 .previewDisplayName("Preparing Export")
         }
         .padding()
         .previewLayout(.sizeThatFits)
         .background(Color(UIColor.secondarySystemBackground))
    }
}

// MARK: - ExportActionsView Functional Previews (No Changes Needed Here)

struct ExportActionsFunctionalPreviewWrapper: View {
    @StateObject var viewModel: MockMasterViewModel
    @State private var isShareSheetPresented = false // Required Binding
    @State private var saveActionMessage = ""

    // Mock action updates local state
    private func mockSaveAction() {
        print("Preview: Save Action Triggered")
        saveActionMessage = "Save Action Triggered at \(Date().formatted(date: .omitted, time: .standard))"
        // Clear message after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            saveActionMessage = ""
        }
    }

    var body: some View {
        VStack(spacing: 15) {
            ExportActionsView(
                masterViewModel: viewModel,
                isShareSheetPresented: $isShareSheetPresented,
                saveAction: mockSaveAction // Pass the mock action
            )

            // Feedback text
            Text("Share Sheet Presented: \(isShareSheetPresented ? "Yes" : "No")")
                .font(.caption)
            if !saveActionMessage.isEmpty {
                 Text(saveActionMessage)
                     .font(.caption)
                     .foregroundColor(.green)
            }
        }
        // Simulate share sheet dismissal
        .onChange(of: isShareSheetPresented) {
             if isShareSheetPresented {
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                     isShareSheetPresented = false
                     print("Preview: Simulated share sheet dismissal.")
                 }
             }
         }
    }
}

struct ExportActionsView_FunctionalPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            ExportActionsFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel() // No content -> Disabled
            )
            .previewDisplayName("Disabled (No content)")

            ExportActionsFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: createPlaceholderImage()) // Image -> Enabled
            )
             .previewDisplayName("Enabled (Has Image) [Interactive]")

            ExportActionsFunctionalPreviewWrapper(
                // Simulate VM providing the drawing for export via the mock coord
                viewModel: MockMasterViewModel(drawingImageForExport: createPlaceholderImage())
            )
             .previewDisplayName("Enabled (Has Drawing) [Interactive]")

            ExportActionsFunctionalPreviewWrapper(
                viewModel: MockMasterViewModel(isPreparingExport: true) // Preparing -> Disabled
            )
             .previewDisplayName("Disabled (Preparing Export)")
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color(UIColor.secondarySystemBackground))
    }
}
