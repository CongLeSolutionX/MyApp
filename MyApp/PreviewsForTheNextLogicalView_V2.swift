//
//  PreviewsForTheNextLogicalView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

// ComponentPreviews.swift
// Previews for the reusable subviews used in ContentView and ExportView.

import SwiftUI
import PhotosUI // Needed for MasterViewModel properties that might involve Photos types indirectly

// MARK: - Helper: Mock MasterViewModel for Previews

@MainActor // Ensure mock updates happen on main actor if needed
class MockMasterViewModel: MasterViewModel {
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
    }
}

// Helper to create a simple placeholder image
func createPlaceholderImage(systemName: String = "photo", pointSize: CGFloat = 50, bgColor: Color = .gray) -> UIImage? {
    let config = UIImage.SymbolConfiguration(pointSize: pointSize)
    guard let symbolImage = UIImage(systemName: systemName, withConfiguration: config) else { return nil }

    let format = UIGraphicsImageRendererFormat()
    format.scale = 1 // Ensure scale is 1 for consistent size
    let size = CGSize(width: pointSize * 1.5, height: pointSize * 1.5) // Slightly larger canvas
    let renderer = UIGraphicsImageRenderer(size: size, format: format)

    let image = renderer.image { ctx in
        // Fill background
        //bgColor.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))

        // Center the symbol
        let symbolRect = CGRect(
            x: (size.width - symbolImage.size.width) / 2,
            y: (size.height - symbolImage.size.height) / 2,
            width: symbolImage.size.width,
            height: symbolImage.size.height
        )
        symbolImage.draw(in: symbolRect)
    }
    return image
}

// MARK: - ImagePickerSectionView Previews

struct ImagePickerSectionPreviewWrapper: View {
    @StateObject var viewModel: MockMasterViewModel
    @State private var showingImagePicker = false // Required binding

    var body: some View {
        List { // Embed in List for realistic section context
            ImagePickerSectionView(
                masterViewModel: viewModel,
                showingImagePicker: $showingImagePicker
            )
        }
    }
}

struct ImagePickerSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ImagePickerSectionPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: nil)
            )
            .previewDisplayName("No Image Selected")

            ImagePickerSectionPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: createPlaceholderImage(systemName: "swift", pointSize: 100))
            )
            .previewDisplayName("Image Selected")
        }
        .previewLayout(.sizeThatFits) // Fit section content
        .padding() // Add padding for visual separation
    }
}

// MARK: - SafariSectionView Previews

struct SafariSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModelNoURL = MockMasterViewModel()
        let viewModelWithURL = MockMasterViewModel(lastSafariUrlFinished: URL(string: "https://www.example.com")!)

        // Simple mock action for preview
        let mockOpenAction: (String) -> Void = { urlString in
            print("Preview: Attempting to open Safari for \(urlString)")
        }

        Group {
            List {
                SafariSectionView(masterViewModel: viewModelNoURL, openSafariAction: mockOpenAction)
            }
            .previewDisplayName("No Last URL")

            List {
                SafariSectionView(masterViewModel: viewModelWithURL, openSafariAction: mockOpenAction)
            }
            .previewDisplayName("Last URL Viewed")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

// MARK: - DrawingPadSectionView Previews

struct DrawingPadSectionPreviewWrapper: View {
    @StateObject var viewModel: MockMasterViewModel = MockMasterViewModel(drawingStrokeCount: 5) // Example stroke count
    @State private var strokeColor: Color = .cyan
    @State private var strokeWidth: CGFloat = 8.0
    @State private var needsClear = false // Required binding

    var body: some View {
        List {
            DrawingPadSectionView(
                masterViewModel: viewModel,
                strokeColor: $strokeColor,
                strokeWidth: $strokeWidth,
                needsClear: $needsClear
            )
            // Give it a fixed height for the non-interactive preview
             .frame(height: 350)
        }
    }
}

struct DrawingPadSectionView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingPadSectionPreviewWrapper()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Drawing Pad Section")
            .padding()
    }
}

// MARK: - ExportButtonSection Previews

struct ExportButtonSectionPreviewWrapper: View {
    @StateObject var viewModel: MockMasterViewModel
    @State private var showingExportView = false // Required binding

    var body: some View {
        List {
            ExportButtonSection(
                masterViewModel: viewModel,
                showingExportView: $showingExportView
            )
        }
    }
}

struct ExportButtonSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExportButtonSectionPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: nil, drawingStrokeCount: 0)
            )
            .previewDisplayName("Disabled (No Content)")

            ExportButtonSectionPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: createPlaceholderImage(), drawingStrokeCount: 0)
            )
            .previewDisplayName("Enabled (Image Only)")

            ExportButtonSectionPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: nil, drawingStrokeCount: 10)
            )
            .previewDisplayName("Enabled (Drawing Only)")

            ExportButtonSectionPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: createPlaceholderImage(), drawingStrokeCount: 10)
            )
            .previewDisplayName("Enabled (Both)")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

// MARK: - ExportPreviewView Previews

struct ExportPreviewView_Previews: PreviewProvider {
    static var previews: some View {
//        Group {
            ExportPreviewView(masterViewModel: MockMasterViewModel())
                .previewDisplayName("No Content")

        ExportPreviewView(masterViewModel: MockMasterViewModel(selectedImage: createPlaceholderImage(systemName: "camera.macro.circle.fill", bgColor: .green)))
                 .previewDisplayName("Selected Image Preview")

        ExportPreviewView(masterViewModel: MockMasterViewModel(drawingImageForExport: createPlaceholderImage(systemName: "pencil.and.scribble", bgColor: .yellow)))
                 .previewDisplayName("Drawing Preview")

             ExportPreviewView(masterViewModel: MockMasterViewModel(selectedImage: nil, drawingImageForExport: nil, isPreparingExport: true))
                 .previewDisplayName("Preparing Export")
//         }
//         .padding()
//         .previewLayout(.sizeThatFits)
//         .background(Color(UIColor.secondarySystemBackground)) // Add background for context
    }
}

// MARK: - ExportActionsView Previews

struct ExportActionsViewPreviewWrapper: View {
    @StateObject var viewModel: MockMasterViewModel
    @State private var isShareSheetPresented = false // Required binding

    // Simple mock action
    let mockSaveAction: () -> Void = { print("Preview: Save Action Triggered") }

    var body: some View {
        VStack { // Use VStack for layout, similar to ExportView use
            ExportActionsView(
                masterViewModel: viewModel,
                isShareSheetPresented: $isShareSheetPresented,
                saveAction: mockSaveAction
            )
        }
    }
}

struct ExportActionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExportActionsViewPreviewWrapper(
                viewModel: MockMasterViewModel() // No content -> Disabled
            )
            .previewDisplayName("Disabled (No content)")

            ExportActionsViewPreviewWrapper(
                viewModel: MockMasterViewModel(selectedImage: createPlaceholderImage()) // Image -> Enabled
            )
             .previewDisplayName("Enabled (Has Image)")

            ExportActionsViewPreviewWrapper(
                viewModel: MockMasterViewModel(drawingImageForExport: createPlaceholderImage()) // Drawing -> Enabled
            )
             .previewDisplayName("Enabled (Has Drawing)")

            ExportActionsViewPreviewWrapper(
                viewModel: MockMasterViewModel(isPreparingExport: true) // Preparing -> Disabled
            )
             .previewDisplayName("Disabled (Preparing Export)")
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color(UIColor.secondarySystemBackground))
    }
}
