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
//import SwiftUI
//import UIKit // Needed for UIActivityViewController
//
//// MARK: - UIViewControllerRepresentable Wrapper for UIActivityViewController
//
//struct ActivityView: UIViewControllerRepresentable {
//
//    // Input: The items to share (e.g., text, URLs, images)
//    let activityItems: [Any]
//    // Input: Custom activities (optional, often nil)
//    let applicationActivities: [UIActivity]? = nil
//    // Input: Activities to exclude (optional)
//    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
//
//    // Coordinator to handle completion callback
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // Creates the UIActivityViewController instance
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let controller = UIActivityViewController(
//            activityItems: activityItems,
//            applicationActivities: applicationActivities
//        )
//        controller.excludedActivityTypes = excludedActivityTypes
//
//        // Set the completion handler using the coordinator
//        // This is crucial for knowing when the share sheet is dismissed or an action is completed
//        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
//            context.coordinator.handleCompletion(
//                activityType: activityType,
//                completed: completed,
//                returnedItems: returnedItems,
//                error: error
//            )
//            // Note: Dismissal is handled automatically by the system for the sheet presentation
//        }
//        return controller
//    }
//
//    // Updates the view controller (rarely needed for UIActivityViewController)
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // No state changes typically need to be pushed to UIActivityViewController after creation
//    }
//
//    // MARK: - Coordinator Class
//    // Needs to be a class and often inherits from NSObject if using delegate patterns,
//    // though not strictly required just for the completion handler.
//    class Coordinator: NSObject {
//        var parent: ActivityView // Reference to the SwiftUI struct
//
//        init(_ parent: ActivityView) {
//            self.parent = parent
//        }
//
//        // The completion handler logic
//        func handleCompletion(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) {
//            if let error = error {
//                print("Share activity failed: \(error.localizedDescription)")
//            } else if completed {
//                // Action was completed successfully
//                if let type = activityType {
//                    print("Share completed with activity type: \(type.rawValue)")
//                } else {
//                    print("Share completed.") // May happen if action doesn't have a specific type (e.g., Copy)
//                }
//            } else {
//                // User cancelled the action
//                print("Share cancelled.")
//            }
//
//            // You could add more logic here, like:
//            // - Calling a callback closure defined in the parent ActivityView
//            // - Updating some state via a Binding passed to the parent ActivityView
//            // For this example, we just print to the console.
//        }
//    }
//}
//
//// MARK: - SwiftUI Content View (Example Usage)
//
//struct ContentView: View {
//    // State to control the presentation of the share sheet
//    @State private var showShareSheet = false
//
//    // Example data to share
//    let textToShare = "Check out this cool article about SwiftUI!"
//    let urlToShare = URL(string: "https://developer.apple.com/xcode/swiftui/")! // Ensure valid URL
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Text("Sharing Example")
//                    .font(.largeTitle)
//
//                Divider()
//
//                VStack(alignment: .leading) {
//                    Text("Content to Share:").font(.headline)
//                    Text("- Text: \"\(textToShare)\"")
//                    Text("- URL: \(urlToShare.absoluteString)")
//                }
//                .padding()
//                .background(Color.secondary.opacity(0.1))
//                .cornerRadius(8)
//
//                Spacer() // Pushes button down
//
//                // Button to trigger the share sheet
//                Button {
//                    // Set the state variable to true to present the sheet
//                    self.showShareSheet = true
//                } label: {
//                    HStack {
//                        Image(systemName: "square.and.arrow.up")
//                        Text("Share Now")
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//                // Disable button if url isn't valid (unlikely here, but good practice)
//                .disabled(urlToShare == nil)
//
//            }
//            .padding()
//            .navigationTitle("Share Sheet Demo")
//            .navigationBarTitleDisplayMode(.inline)
//            // The .sheet modifier presents our ActivityView when showShareSheet is true
//            .sheet(isPresented: $showShareSheet) {
//                // Construct the ActivityView with the items to share
//                ActivityView(activityItems: [textToShare, urlToShare] as [Any]
//                             // Example: Exclude printing and assigning to contact
//                             //excludedActivityTypes: [.print]
//                )
//                // Optional: Add presentation detents for iOS 16+
//                // .presentationDetents([.medium, .large])
//            }
//        }
//        .navigationViewStyle(.stack) // Use stack style for consistency
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
//// MARK: - App Entry Point (Required if this is the main app file)
///*
//@main
//struct ShareSheetApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//*/
