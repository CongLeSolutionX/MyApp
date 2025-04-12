//
//  ContentView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI
import SafariServices // Import the SafariServices framework

// MARK: - Data Model

// Represents a link to be displayed and opened.
// Conforms to Identifiable for use in .sheet(item:) and List.
// Conforms to Hashable for potential use in Sets or as Dictionary keys if needed.
struct LinkItem: Identifiable, Hashable {
    let id = UUID() // Unique identifier for each item
    let title: String
    let urlString: String
    let tintColor: Color? // Optional tint color for this specific link's Safari view
    
    // Computed property to safely create a URL object.
    // Returns nil if the urlString is invalid.
    var url: URL? {
        URL(string: urlString)
    }
}

// MARK: - SFSafariViewController Wrapper (UIViewControllerRepresentable)

struct SafariView: UIViewControllerRepresentable {
    
    // The URL to display
    let url: URL
    // Optional tint color for the Safari controls (Done button, etc.)
    var preferredControlTintColor: UIColor? = nil
    // Optional: Callback closure when the user dismisses the Safari view
    var onDismiss: (() -> Void)? = nil
    
    // Creates the Coordinator instance which acts as the delegate.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onDismiss: onDismiss)
    }
    
    // Creates the SFSafariViewController instance.
    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Create the Safari View Controller with the URL
        let safariVC = SFSafariViewController(url: url)
        
        // Set the coordinator as the delegate
        safariVC.delegate = context.coordinator
        
        // Apply tint color if provided
        safariVC.preferredControlTintColor = preferredControlTintColor
        
        // Example: Apply other configurations if needed
        // safariVC.dismissButtonStyle = .close // Change the 'Done' button style
        
        print("SafariView: SFSafariViewController created for URL: \(url.absoluteString)")
        return safariVC
    }
    
    // Updates the presented SFSafariViewController. Usually not needed for SFSafariViewController
    // unless configuration or callbacks need dynamic updates.
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // You *could* update the tint color dynamically if needed, but it's uncommon.
        // uiViewController.preferredControlTintColor = preferredControlTintColor
        
        // Ensure the coordinator's onDismiss closure stays in sync if the parent view's changes
        context.coordinator.onDismiss = onDismiss
        print("SafariView: updateUIViewController called.")
    }
    
    // MARK: - Coordinator Class
    
    // Acts as the bridge for SFSafariViewControllerDelegate methods.
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView
        var onDismiss: (() -> Void)?
        
        init(parent: SafariView, onDismiss: (() -> Void)?) {
            self.parent = parent
            self.onDismiss = onDismiss
            print("SafariView Coordinator: Initialized.")
        }
        
        // Called when the user taps the "Done" button or swipes down to dismiss.
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            print("SafariView Coordinator: safariViewControllerDidFinish called.")
            // Execute the dismissal closure provided by the parent SwiftUI view.
            // This is crucial for resetting the state that controls the sheet presentation.
            onDismiss?()
        }
        
        // Optional: Called when the initial URL load finishes.
        func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
            if didLoadSuccessfully {
                print("SafariView Coordinator: Initial load successful for URL: \(parent.url.absoluteString)")
            } else {
                print("SafariView Coordinator: Initial load FAILED for URL: \(parent.url.absoluteString)")
                // Consider showing an alert or fallback UI if loading fails critically
            }
        }
        
        // --- Other Optional Delegate Methods ---
        func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
            print("SafariView Coordinator: Checking excluded activities.")
            return [] // Example: return [.postToFacebook]
        }
        
        func safariViewControllerWillOpenInBrowser(_ controller: SFSafariViewController) {
            print("SafariView Coordinator: Will open in external Safari browser.")
            // This happens if the content triggers an external app link that Safari handles.
        }
    }
}

// MARK: - Content View (Example Usage)

struct ContentView: View {
    // State variable to hold the LinkItem that should be presented.
    // When this is non-nil, the .sheet(item:) modifier presents the SafariView.
    @State private var linkToPresent: LinkItem? = nil
    
    // --- Mock Data Source ---
    // Define the list of links to display. Includes a potentially invalid URL string.
    let linkItems: [LinkItem] = [
        LinkItem(title: "Apple Developer", urlString: "https://developer.apple.com", tintColor: .blue),
        LinkItem(title: "Swift Language Guide", urlString: "https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html", tintColor: .orange),
        LinkItem(title: "SwiftUI Tutorials", urlString: "https://developer.apple.com/tutorials/swiftui/", tintColor: .indigo),
        LinkItem(title: "Invalid URL Example", urlString: "not a valid url string", tintColor: .red), // Intentionally invalid
        LinkItem(title: "Ray Wenderlich / Kodeco", urlString: "https://www.kodeco.com", tintColor: .green),
        LinkItem(title: "Hacking with Swift", urlString: "https://www.hackingwithswift.com", tintColor: nil) // Default tint
    ]
    
    var body: some View {
        // Use NavigationStack for modern navigation (iOS 16+)
        NavigationStack {
            List {
                ForEach(linkItems) { item in
                    // Use a Button for clear interaction indication and accessibility
                    Button {
                        // Attempt to create the URL when the button is tapped
                        if let _ = item.url {
                            print("ContentView: Button tapped for valid URL: \(item.title)")
                            self.linkToPresent = item // Set the state to trigger the sheet
                        } else {
                            // Handle the case where the URL string is invalid
                            print("ContentView: Button tapped for INVALID URL: \(item.title) - URLString: '\(item.urlString)'")
                            // Optionally, show an alert here
                        }
                    } label: {
                        HStack {
                            Text(item.title)
                            Spacer()
                            if item.url != nil {
                                Image(systemName: "chevron.right") // Indicate tappable row
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill") // Indicate error
                                    .foregroundColor(.red)
                            }
                        }
                        .contentShape(Rectangle()) // Make the whole row tappable
                    }
                    // Disable the button visually if the URL is invalid
                    .disabled(item.url == nil)
                    // Apply foreground color to the whole button content
                    .foregroundColor(item.url == nil ? .secondary : .primary)
                }
            }
            .navigationTitle("Useful Links")
            // Use .sheet(item:) which is ideal for presenting content based on identifiable data.
            .sheet(item: $linkToPresent) { itemToPresent in
                // Safely unwrap the URL from the LinkItem.
                // This check is slightly redundant if we already checked in the button action,
                // but it's good defensive programming.
                if let url = itemToPresent.url {
                    SafariView(
                        url: url,
                        // Convert SwiftUI Color to UIColor if a tint is provided
                        preferredControlTintColor: itemToPresent.tintColor?.toUIColor(),
                        onDismiss: {
                            print("ContentView: SafariView onDismiss called. Sheet will close.")
                            // No need to manually set linkToPresent = nil here,
                            // .sheet(item:) handles it when the sheet is dismissed.
                        }
                    )
                    // Allow the Safari view to extend into safe areas for a more immersive look
                    .ignoresSafeArea()
                } else {
                    // Fallback in case the URL became invalid unexpectedly (shouldn't happen here)
                    Text("Error: Could not load URL.")
                        .padding()
                }
            }
        }
    }
}

// MARK: - Helper Extension

// Helper to convert SwiftUI Color to UIKit UIColor
extension Color {
    func toUIColor() -> UIColor? {
        UIColor(self)
    }
}

// MARK: - Preview Provider

#Preview { // Uses the modern #Preview macro
    ContentView()
}

// MARK: - App Entry Point (If this is the main app file)

/*
 @main
 struct SafariDemoAppEnhanced: App {
 var body: some Scene {
 WindowGroup {
 ContentView()
 }
 }
 }
 */
