//
//  ContentView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI
import UIKit // Needed for UIActivityViewController, UIImage

// MARK: - UIViewControllerRepresentable Wrapper (Optimized)

struct ActivityView: UIViewControllerRepresentable {
    // Input: The items to share
    let activityItems: [Any]
    // Input: Custom activities (optional)
    let applicationActivities: [UIActivity]? = nil
    // Input: Activities to exclude (optional)
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    // Callback: To notify the calling view about the result
    var completion: ((Result<UIActivity.ActivityType?, Error>) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self, completion: completion)
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = excludedActivityTypes

        // --- iPad Specific Anchoring (Important Consideration) ---
        // On iPad, UIActivityViewController is presented as a popover.
        // It requires anchoring to a source view or bar button item.
        // UIViewControllerRepresentable does not easily provide a direct reference
        // to the SwiftUI view that triggered the presentation for anchoring.
        //
        // Common Workarounds (Choose one or implement more complex logic):
        // 1. Anchor to the main window (less specific):
        //    controller.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
        //    controller.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0) // Center point
        //    controller.popoverPresentationController?.permittedArrowDirections = [] // No arrow
        //
        // 2. Pass anchor information (e.g., a specific CGRect or UIView reference)
        //    from the calling context, potentially requiring deeper UIKit integration
        //    or use of libraries that help bridge this gap.
        //
        // For simplicity, this example doesn't implement specific iPad anchoring,
        // resulting in a default (often full-screen modal) presentation on iPad.
        // ---------------------------------------------------------

        // Set the completion handler using the coordinator
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            context.coordinator.handleCompletion(
                activityType: activityType,
                completed: completed,
                returnedItems: returnedItems,
                error: error
            )
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No state changes need to be pushed after initial creation.
    }

    // MARK: - Coordinator Class (Optimized)
    class Coordinator: NSObject {
        let parent: ActivityView
        let completion: ((Result<UIActivity.ActivityType?, Error>) -> Void)?

        init(_ parent: ActivityView, completion: ((Result<UIActivity.ActivityType?, Error>) -> Void)?) {
            self.parent = parent
            self.completion = completion
        }

        func handleCompletion(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) {
            if let error = error {
                print("Share activity failed: \(error.localizedDescription)")
                completion?(.failure(error))
            } else if completed {
                // Action was completed successfully
                print(activityType != nil ? "Share completed with activity type: \(activityType!.rawValue)" : "Share completed.")
                completion?(.success(activityType))
            } else {
                // User cancelled the action
                print("Share cancelled.")
                completion?(.success(nil)) // Represent cancellation as success with nil type
            }
        }
    }
}

// MARK: - Content ViewModel (NEW)

class ContentViewModel: ObservableObject {
    // State for sheet presentation
    @Published var isShareSheetPresented = false
    // State for alert presentation
    @Published var isAlertPresented = false
    // State for alert content
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""

    // Holds the items to be shared *right now*
    private(set) var currentActivityItems: [Any] = []

    // --- Mock Data Examples ---
    let sampleText = "Explore the power of SwiftUI! #iOSDev"
    let sampleURL = URL(string: "https://developer.apple.com/xcode/swiftui/")!
    // Create a simple placeholder image (replace with actual image loading if needed)
    let sampleImage: UIImage = {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.systemTeal.setFill() // Use a distinct color
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }()

    // --- Share Trigger ---
    func share(items: [Any], excludedTypes: [UIActivity.ActivityType]? = nil) {
        guard !items.isEmpty else {
            print("No items provided to share.")
            return
        }
        currentActivityItems = items
        print("Preparing to share items: \(items)")
        isShareSheetPresented = true
    }

    // --- Share Completion Handler ---
    func handleShareResult(_ result: Result<UIActivity.ActivityType?, Error>) {
        DispatchQueue.main.async { // Ensure UI updates are on the main thread
            switch result {
            case .success(let completedActivityType):
                if let activityType = completedActivityType {
                    self.alertTitle = "Shared Successfully"
                    self.alertMessage = "Activity: \(activityType.rawValue)"
                } else {
                    // This case means the user cancelled the sheet
                    self.alertTitle = "Share Cancelled"
                    self.alertMessage = "" // No need for a message here
                }
                self.isAlertPresented = true // Show alert even on cancel for feedback clarity
            case .failure(let error):
                self.alertTitle = "Share Failed"
                self.alertMessage = "Error: \(error.localizedDescription)"
                self.isAlertPresented = true
            }
        }
    }
}

// MARK: - SwiftUI Content View (Using ViewModel)

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                appTitle

                Divider()

                contentExamples

                Spacer() // Pushes buttons down

                actionButtons
            }
            .padding()
            .navigationTitle("Share Sheet Demo")
            .navigationBarTitleDisplayMode(.inline)
            // --- Sheet Presentation ---
            .sheet(isPresented: $viewModel.isShareSheetPresented) {
                // Construct the ActivityView when the sheet is presented
                ActivityView(
                    activityItems: viewModel.currentActivityItems,
                    // Example: Exclude common unwanted types
                    //excludedActivityTypes: [.assignToContact, .addToReadingList, .markupAsPDF],
                    completion: viewModel.handleShareResult // Pass the handler
                )
                // Optional: Add presentation detents for iOS 16+
                // .presentationDetents([.medium, .large])
            }
            // --- Alert for Feedback ---
            .alert(isPresented: $viewModel.isAlertPresented) {
                Alert(title: Text(viewModel.alertTitle),
                      message: Text(viewModel.alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
        .navigationViewStyle(.stack) // Use stack style for consistency
    }

    // --- View Components ---

    private var appTitle: some View {
        Text("Dynamic Sharing")
            .font(.largeTitle.weight(.bold))
            .foregroundColor(.primary)
    }

    private var contentExamples: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Example Content Available:").font(.headline)
            Group {
                Label("\"\(viewModel.sampleText)\"", systemImage: "text.quote")
                Label("\(viewModel.sampleURL.absoluteString)", systemImage: "link")
                Label("A sample generated image", systemImage: "photo")
            }
            .padding(10)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 15) {
            // Button to share Text only
            Button {
                viewModel.share(items: [viewModel.sampleText])
            } label: {
                Label("Share Text", systemImage: "text.bubble")
                     .modifier(ShareButtonStyle(color: .blue))
            }

            // Button to share URL only
            Button {
                viewModel.share(items: [viewModel.sampleURL])
            } label: {
                Label("Share URL", systemImage: "link.circle")
                    .modifier(ShareButtonStyle(color: .green))
            }

            // Button to share Image only
             Button {
                 viewModel.share(items: [viewModel.sampleImage])
             } label: {
                 Label("Share Image", systemImage: "photo.on.rectangle")
                     .modifier(ShareButtonStyle(color: .purple))
             }

            // Button to share Text and URL
            Button {
                viewModel.share(items: [viewModel.sampleText, viewModel.sampleURL])
            } label: {
                Label("Share Text & URL", systemImage: "square.and.arrow.up.on.square")
                    .modifier(ShareButtonStyle(color: .orange))
            }

             // Button to share All Items
            Button {
                 viewModel.share(items: [viewModel.sampleText, viewModel.sampleURL, viewModel.sampleImage])
             } label: {
                 Label("Share All", systemImage: "square.and.arrow.up.fill")
                     .modifier(ShareButtonStyle(color: .red))
             }
        }
    }
}

// MARK: - Custom Button Style Modifier

struct ShareButtonStyle: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(10)
            .shadow(radius: 3)
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
struct ShareSheetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
