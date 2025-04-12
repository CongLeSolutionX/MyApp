////
////  TheNextLogoicalScreen.swift
////  MyApp
////
////  Created by Cong Le on 4/11/25.
////
//
//import SwiftUI
//import SafariServices // Import the SafariServices framework
//
//
//// MARK: - Data Model
//
//// Represents a link to be displayed and opened.
//// Conforms to Identifiable for use in .sheet(item:) and List.
//// Conforms to Hashable for potential use in Sets or as Dictionary keys if needed.
//struct LinkItem: Identifiable, Hashable {
//    let id = UUID() // Unique identifier for each item
//    let title: String
//    let urlString: String
//    let tintColor: Color? // Optional tint color for this specific link's Safari view
//    
//    // Computed property to safely create a URL object.
//    // Returns nil if the urlString is invalid.
//    var url: URL? {
//        URL(string: urlString)
//    }
//}
//
//// MARK: - SFSafariViewController Wrapper (UIViewControllerRepresentable)
//
//struct SafariView: UIViewControllerRepresentable {
//    
//    // The URL to display
//    let url: URL
//    // Optional tint color for the Safari controls (Done button, etc.)
//    var preferredControlTintColor: UIColor? = nil
//    // Optional: Callback closure when the user dismisses the Safari view
//    var onDismiss: (() -> Void)? = nil
//    
//    // Creates the Coordinator instance which acts as the delegate.
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self, onDismiss: onDismiss)
//    }
//    
//    // Creates the SFSafariViewController instance.
//    func makeUIViewController(context: Context) -> SFSafariViewController {
//        // Create the Safari View Controller with the URL
//        let safariVC = SFSafariViewController(url: url)
//        
//        // Set the coordinator as the delegate
//        safariVC.delegate = context.coordinator
//        
//        // Apply tint color if provided
//        safariVC.preferredControlTintColor = preferredControlTintColor
//        
//        // Example: Apply other configurations if needed
//        // safariVC.dismissButtonStyle = .close // Change the 'Done' button style
//        
//        print("SafariView: SFSafariViewController created for URL: \(url.absoluteString)")
//        return safariVC
//    }
//    
//    // Updates the presented SFSafariViewController. Usually not needed for SFSafariViewController
//    // unless configuration or callbacks need dynamic updates.
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
//        // You *could* update the tint color dynamically if needed, but it's uncommon.
//        // uiViewController.preferredControlTintColor = preferredControlTintColor
//        
//        // Ensure the coordinator's onDismiss closure stays in sync if the parent view's changes
//        context.coordinator.onDismiss = onDismiss
//        print("SafariView: updateUIViewController called.")
//    }
//    
//    // MARK: - Coordinator Class
//    
//    // Acts as the bridge for SFSafariViewControllerDelegate methods.
//    class Coordinator: NSObject, SFSafariViewControllerDelegate {
//        let parent: SafariView
//        var onDismiss: (() -> Void)?
//        
//        init(parent: SafariView, onDismiss: (() -> Void)?) {
//            self.parent = parent
//            self.onDismiss = onDismiss
//            print("SafariView Coordinator: Initialized.")
//        }
//        
//        // Called when the user taps the "Done" button or swipes down to dismiss.
//        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
//            print("SafariView Coordinator: safariViewControllerDidFinish called.")
//            // Execute the dismissal closure provided by the parent SwiftUI view.
//            // This is crucial for resetting the state that controls the sheet presentation.
//            onDismiss?()
//        }
//        
//        // Optional: Called when the initial URL load finishes.
//        func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
//            if didLoadSuccessfully {
//                print("SafariView Coordinator: Initial load successful for URL: \(parent.url.absoluteString)")
//            } else {
//                print("SafariView Coordinator: Initial load FAILED for URL: \(parent.url.absoluteString)")
//                // Consider showing an alert or fallback UI if loading fails critically
//            }
//        }
//        
//        // --- Other Optional Delegate Methods ---
//        func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
//            print("SafariView Coordinator: Checking excluded activities.")
//            return [] // Example: return [.postToFacebook]
//        }
//        
//        func safariViewControllerWillOpenInBrowser(_ controller: SFSafariViewController) {
//            print("SafariView Coordinator: Will open in external Safari browser.")
//            // This happens if the content triggers an external app link that Safari handles.
//        }
//    }
//}
//
//// Enum for Appearance Setting - RawRepresentable for AppStorage
//enum AppearanceSetting: String, CaseIterable, Identifiable {
//    case system = "System"
//    case light = "Light"
//    case dark = "Dark"
//
//    var id: String { self.rawValue }
//
//    // Helper to convert enum case to SwiftUI ColorScheme
//    var colorScheme: ColorScheme? {
//        switch self {
//        case .light:
//            return .light
//        case .dark:
//            return .dark
//        case .system:
//            return nil // nil defaults to system
//        }
//    }
//}
//
//struct SettingsView: View {
//    // MARK: - AppStorage Properties (Persistent Settings)
//
//    // Use keys with a prefix for better organization in UserDefaults
//    @AppStorage("settings.appearance") private var appearanceSetting: AppearanceSetting = .system
//    @AppStorage("settings.useInAppBrowser") private var useInAppBrowser: Bool = true
//    @AppStorage("settings.username") private var username: String = ""
//
//    // State for showing confirmation alerts for actions
//    @State private var showingClearCacheAlert = false
//
//    // MARK: - Body
//
//    var body: some View {
//        // Forms are standard for Settings screens
//        Form {
//            // MARK: - Appearance Section
//            Section("Appearance") {
//                Picker("Theme", selection: $appearanceSetting) {
//                    ForEach(AppearanceSetting.allCases) { setting in
//                        Text(setting.rawValue).tag(setting)
//                    }
//                }
//                // This modifier directly applies the change app-wide if needed
//                // Alternatively, read this value in the root App struct
//                .onChange(of: appearanceSetting) {
//                    print("SettingsView: Appearance changed to \(appearanceSetting.rawValue)")
//                    // Apply the theme immediately (more robust way is in the App struct)
//                    UIApplication.shared.connectedScenes
//                        .compactMap { $0 as? UIWindowScene }
//                        .forEach { windowScene in
//                             windowScene.windows.forEach { window in
//                                 window.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: appearanceSetting.colorScheme?.toInt() ?? 0) ?? .unspecified
//                             }
//                        }
//                }
//            }
//
//            // MARK: - Browsing Section
//            Section("Browsing") {
//                Toggle("Use In-App Browser for Links", isOn: $useInAppBrowser)
//                Text("When disabled, links will open in your default external browser.")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//
//            // MARK: - User Profile Section
//            Section("Profile") {
//                TextField("Username", text: $username)
//                    .textContentType(.username) // Helps with autofill
//                    .autocorrectionDisabled()
//                    .textInputAutocapitalization(.never)
//            }
//
//            // MARK: - Data Management Section
//             Section("Data Management") {
//                 Button("Clear Cache", role: .destructive) {
//                     print("SettingsView: 'Clear Cache' button tapped.")
//                     // Trigger the confirmation alert
//                     showingClearCacheAlert = true
//                 }
//                 .alert("Clear Cache?", isPresented: $showingClearCacheAlert) {
//                     Button("Cancel", role: .cancel) { }
//                     Button("Clear", role: .destructive) {
//                         // --- Placeholder for Actual Clear Cache Logic ---
//                         print("SettingsView: Executing clear cache action...")
//                         // Example: Call a function like CacheManager.shared.clear()
//                         // --- End Placeholder ---
//                     }
//                 } message: {
//                     Text("This action cannot be undone.")
//                 }
//             }
//
//            // MARK: - About Section
//            Section("About") {
//                HStack {
//                    Text("App Version")
//                    Spacer()
//                    // Fetch dynamically in a real app
//                    Text(appVersion())
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//        .navigationTitle("Settings")
//        // Ensure it fits within the navigation stack correctly
//        .navigationBarTitleDisplayMode(.inline)
//
//    }
//
//    // MARK: - Helper Functions
//
//    // Helper to get app version (common utility)
//    private func appVersion() -> String {
//        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
//    }
//}
//
//// Helper extension to convert ColorScheme to UIUserInterfaceStyle raw value
//// This is needed for applying the theme directly via overrideUserInterfaceStyle.
//// A more robust approach involves setting .preferredColorScheme in the main App struct.
//extension ColorScheme {
//    func toInt() -> Int {
//        switch self {
//        case .light: return 1 // UIUserInterfaceStyle.light.rawValue
//        case .dark: return 2  // UIUserInterfaceStyle.dark.rawValue
//        @unknown default: return 0 // UIUserInterfaceStyle.unspecified.rawValue
//        }
//    }
//}
//
//// MARK: - Preview Provider
//#Preview {
//    // Embed in NavigationStack for preview context
//    NavigationStack {
//        SettingsView()
//    }
//}
//
//
//import SwiftUI
//import SafariServices
//// Import UIKit to use UIApplication.shared.open
//import UIKit
//
//// --- LinkItem struct and SafariView remain the same as before ---
//// (Keep the LinkItem struct and SafariView UIViewControllerRepresentable here)
//// ... (Previous LinkItem struct code) ...
//// ... (Previous SafariView struct code) ...
//
//struct ContentView: View {
//    @State private var linkToPresent: LinkItem? = nil
//
//    // --- Mock Data Source ---
//    let linkItems: [LinkItem] = [
//        // ... (Keep the same linkItems array as before) ...
//        LinkItem(title: "Apple Developer", urlString: "https://developer.apple.com", tintColor: .blue),
//        LinkItem(title: "Swift Language Guide", urlString: "https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html", tintColor: .orange),
//        LinkItem(title: "SwiftUI Tutorials", urlString: "https://developer.apple.com/tutorials/swiftui/", tintColor: .indigo),
//        LinkItem(title: "Invalid URL Example", urlString: "not a valid url string", tintColor: .red), // Intentionally invalid
//        LinkItem(title: "Ray Wenderlich / Kodeco", urlString: "https://www.kodeco.com", tintColor: .green),
//        LinkItem(title: "Hacking with Swift", urlString: "https://www.hackingwithswift.com", tintColor: nil) // Default tint
//    ]
//
//    // MARK: - Read Setting from AppStorage
//    @AppStorage("settings.useInAppBrowser") private var useInAppBrowser: Bool = true
//
//    var body: some View {
//        NavigationStack { // Ensure NavigationStack is present
//            List {
//                ForEach(linkItems) { item in
//                    Button {
//                        // Attempt to create the URL when the button is tapped
//                        guard let validUrl = item.url else {
//                            print("ContentView: Button tapped for INVALID URL: \(item.title) - URLString: '\(item.urlString)'")
//                            // Optionally show an alert
//                            return
//                        }
//
//                        // --- Use the Setting ---
//                        if useInAppBrowser {
//                            print("ContentView: Opening '\(item.title)' in SFSafariViewController (Setting is ON)")
//                            self.linkToPresent = item // Trigger the sheet
//                        } else {
//                            print("ContentView: Opening '\(item.title)' in external browser (Setting is OFF)")
//                            // Open url in the default external browser
//                            UIApplication.shared.open(validUrl)
//                        }
//                        // ----------------------
//
//                    } label: {
//                        // ... (Keep the HStack label from the previous ContentView) ...
//                        HStack {
//                           Text(item.title)
//                           Spacer()
//                           if item.url != nil {
//                               Image(systemName: "chevron.right")
//                                   .font(.caption)
//                                   .foregroundColor(.secondary)
//                           } else {
//                               Image(systemName: "exclamationmark.triangle.fill")
//                                   .foregroundColor(.red)
//                           }
//                       }
//                       .contentShape(Rectangle())
//                    }
//                    .disabled(item.url == nil)
//                    .foregroundColor(item.url == nil ? .secondary : .primary)
//                }
//            }
//            .navigationTitle("Useful Links")
//            // MARK: - Add Toolbar for Settings Navigation
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink {
//                        // Destination View
//                        SettingsView()
//                    } label: {
//                        // Button Appearance
//                        Label("Settings", systemImage: "gearshape.fill")
//                    }
//                }
//            }
//            // --- Sheet Presentation (remains the same) ---
//            .sheet(item: $linkToPresent) { itemToPresent in
//                if let url = itemToPresent.url {
//                    SafariView(
//                        url: url,
//                        preferredControlTintColor: itemToPresent.tintColor?.toUIColor(),
//                        onDismiss: {
//                             print("ContentView: SafariView onDismiss called. Sheet will close.")
//                        }
//                    )
//                    .ignoresSafeArea()
//                } else {
//                    Text("Error: Could not load URL.")
//                        .padding()
//                }
//            }
//        }
//    }
//}
//
//// --- Helper Extension (Keep the Color extension as before) ---
//// MARK: - Helper Extension
//
//// Helper to convert SwiftUI Color to UIKit UIColor
//extension Color {
//    func toUIColor() -> UIColor? {
//        UIColor(self)
//    }
//}
//
//
//// --- Preview Provider (Keep as before) ---
//#Preview {
//    ContentView()
//}
//
//
//import SwiftUI
//
//@main
//struct SafariDemoAppEnhanced: App { // Use your actual App name
//    // Read the appearance setting here
//    @AppStorage("settings.appearance") private var appearanceSetting: AppearanceSetting = .system
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                // Apply the preferred color scheme based on the stored setting
//                .preferredColorScheme(appearanceSetting.colorScheme)
//        }
//    }
//}
//
//// Make sure the AppearanceSetting Enum is accessible here,
//// either by being in this file or marked public if in another file/module.
