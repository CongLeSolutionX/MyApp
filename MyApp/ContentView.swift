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
import SafariServices // Import the SafariServices framework

// MARK: - Data Model (Make URL Identifiable)

// Extend URL to conform to Identifiable so it can be used with .sheet(item:)
// The absoluteString is a natural unique identifier for a URL.
extension URL: @retroactive Identifiable {
    public var id: String { self.absoluteString }
}

// MARK: - SFSafariViewController Wrapper (UIViewControllerRepresentable)

struct SafariView: UIViewControllerRepresentable {

    // The URL to display in the Safari View Controller
    let url: URL

    // Optional: Configuration for SFSafariViewController appearance and behavior
    let configuration: SFSafariViewController.Configuration? = nil
    // Optional: Callback closure when the user dismisses the Safari view (taps "Done")
    var onDismiss: (() -> Void)? = nil

    // Creates the Coordinator instance.
    // This coordinator will act as the SFSafariViewControllerDelegate.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onDismiss: onDismiss)
    }

    // Creates the SFSafariViewController instance.
    // This is called only once when the view is initially created.
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC: SFSafariViewController
        if let config = configuration {
            safariVC = SFSafariViewController(url: url, configuration: config)
        } else {
            safariVC = SFSafariViewController(url: url)
        }

        // Set the coordinator as the delegate to receive callbacks.
        safariVC.delegate = context.coordinator

        // Optional: Customize appearance further if needed
        // safariVC.preferredControlTintColor = .systemRed // Example: Change button colors

        return safariVC
    }

    // Updates the presented SFSafariViewController.
    // This is called when the state changes in the SwiftUI view.
    // For SFSafariViewController, updates are rarely needed after initial presentation.
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No specific updates needed for the URL or configuration in this simple example.
        // SFSafariViewController handles its own state internally.
        // If you needed to update the 'onDismiss' closure dynamically, you could do:
        // context.coordinator.onDismiss = onDismiss
    }

    // MARK: - Coordinator Class

    // The Coordinator acts as the bridge between the UIKit world (SFSafariViewControllerDelegate)
    // and the SwiftUI world.
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariView
        var onDismiss: (() -> Void)?

        init(parent: SafariView, onDismiss: (() -> Void)? = nil) {
            self.parent = parent
            self.onDismiss = onDismiss
            print("SafariView Coordinator initialized.")
        }

        // Delegate method called when the user taps the "Done" button.
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            print("SafariViewController did finish.")
            // Execute the dismissal closure provided by the parent SwiftUI view.
            // This is often used to set the state variable controlling the sheet presentation back to nil.
            onDismiss?()

            // Note: If presented using .sheet(item:), the system might automatically handle
            // setting the bound item to nil when the Done button is tapped,
            // making the explicit call to onDismiss?() potentially redundant for *just* dismissal,
            // but it's crucial if you need to perform other actions upon dismissal.
        }

        // Optional: Other SFSafariViewControllerDelegate methods you might implement:

        // Called when the initial URL load is complete.
        func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
            print("SafariViewController initial load completed. Success: \(didLoadSuccessfully)")
            if !didLoadSuccessfully {
                // Handle load failure if necessary
            }
        }

         // Called when the browser is redirected to an external app (e.g., App Store).
         func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
             print("SafariViewController checking excluded activities for URL: \(URL)")
             // Optionally exclude certain share activities
             // return [.postToFacebook]
             return []
         }

         // Called when the user taps an action button. Requires configuring `activityButton` on the controller.
        /*
         func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
             print("SafariViewController providing activity items for URL: \(URL)")
             // Return custom UIActivity items if needed
             return [MyCustomActivity()]
         }
         */
    }
}

// MARK: - Content View (Example Usage)

struct ContentView: View {
    // State variable to hold the URL that should be presented.
    // When this is non-nil, the .sheet(item:) modifier will present the SafariView.
    @State private var urlToPresent: URL? = nil

    let sampleURL1 = URL(string: "https://developer.apple.com/xcode/")!
    let sampleURL2 = URL(string: "https://www.swift.org/documentation/")!

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Present SFSafariViewController")
                    .font(.title2)

                Button("Open Apple Developer") {
                    print("Button tapped: Opening Apple Developer")
                    self.urlToPresent = sampleURL1
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Open Swift Documentation") {
                    print("Button tapped: Opening Swift Docs")
                    self.urlToPresent = sampleURL2
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer() // Push buttons to the top
            }
            .padding()
            .navigationTitle("Safari Services Demo")
            // This modifier listens to changes in `urlToPresent`.
            // When `urlToPresent` gets a URL value, it presents the sheet.
            // When `urlToPresent` is set back to `nil`, the sheet dismisses.
            // The `url` parameter in the closure is the non-nil value from `urlToPresent`.
            .sheet(item: $urlToPresent) { url in
                // Create the SafariView wrapper, passing the URL
                SafariView(url: url, onDismiss: {
                    print("Dismiss callback executed in ContentView. Setting urlToPresent to nil.")
                    // While .sheet(item:) often handles nil-setting on 'Done',
                    // explicitly doing it here ensures correctness and handles
                    // potential future dismissal scenarios or logging needs.
                    // self.urlToPresent = nil // This is often redundant but safe.
                })
                // Optional: Allow the Safari view to ignore safe areas for a more immersive feel
                .ignoresSafeArea()

            }
           /*
            // --- Alternative using .sheet(isPresented:) ---
            // @State private var showingSafari: Bool = false
            // @State private var urlForSafari: URL? = nil
             .sheet(isPresented: $showingSafari) {
                 // Must safely unwrap the URL here
                 if let url = urlForSafari {
                     SafariView(url: url, onDismiss: {
                         print("Dismiss callback: Setting showingSafari = false")
                         self.showingSafari = false // Manually handle dismissal state
                     })
                     .ignoresSafeArea()
                 } else {
                     // Optional: Show an error or placeholder if URL is unexpectedly nil
                     Text("Error: URL is missing.")
                 }
             }
             // In Button action for isPresented:
             // self.urlForSafari = sampleURL1
             // self.showingSafari = true
           */
        }
        // Use stack style for consistent behavior across devices
        .navigationViewStyle(.stack)
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
struct SafariDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
