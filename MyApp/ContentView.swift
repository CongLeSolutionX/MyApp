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

@main
struct YourAppApp: App {
    // Connect the AppDelegate to handle UIKit lifecycle events and protocols
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Create and manage the AccessibilityManager as a state object
    @StateObject private var accessibilityManager = AccessibilityManager()

    var body: some Scene {
        WindowGroup {
            // Inject the AccessibilityManager into the ContentView environment
            ContentView()
                .environmentObject(accessibilityManager)
                .onAppear {
                    // Pass the manager reference to the AppDelegate if needed,
                    // or use NotificationCenter for communication.
                    // Using NotificationCenter is often cleaner.
                    appDelegate.accessibilityManager = accessibilityManager
                }
        }
    }
}

import UIKit
import SwiftUI // Required for UIGuidedAccessRestrictionDelegate in recent SDKs

// Define unique identifiers for your custom restrictions
enum GuidedAccessCustomRestrictions {
    static let disableAccountSettings = "com.yourapp.disableAccountSettings"
    // Add more identifiers if needed
}

class AppDelegate: NSObject, UIApplicationDelegate, UIGuidedAccessRestrictionDelegate {
    func textForGuidedAccessRestriction(withIdentifier restrictionIdentifier: String) -> String? {
        return nil
    }
    

    // Hold a reference to the manager (can also use NotificationCenter)
    weak var accessibilityManager: AccessibilityManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("App did finish launching.")
        // Perform any initial setup
        return true
    }

    // MARK: - UIGuidedAccessRestrictionDelegate Methods

    /// Returns the identifiers for the custom restrictions your app supports.
    var guidedAccessRestrictionIdentifiers: [String]? {
        print("Providing Guided Access Restriction Identifiers")
        return [GuidedAccessCustomRestrictions.disableAccountSettings]
    }

    /// Provides the user-facing title for a given restriction identifier.
    func guidedAccessRestrictionText(forIdentifier restrictionIdentifier: String) -> String? {
        print("Providing text for restriction: \(restrictionIdentifier)")
        switch restrictionIdentifier {
        case GuidedAccessCustomRestrictions.disableAccountSettings:
            return "Disable Account Settings"
        default:
            return nil
        }
    }

    /// Provides optional detailed descriptive text for a restriction.
    func guidedAccessRestrictionDetailText(forIdentifier restrictionIdentifier: String) -> String? {
        print("Providing detail text for restriction: \(restrictionIdentifier)")
        switch restrictionIdentifier {
        case GuidedAccessCustomRestrictions.disableAccountSettings:
            return "Prevents access to the account settings screen to maintain focus."
        default:
            return nil
        }
    }

    /// Called when the state of one of your custom restrictions changes in the Guided Access settings.
    func guidedAccessRestriction(withIdentifier restrictionIdentifier: String, didChange newRestrictionState: UIAccessibility.GuidedAccessRestrictionState) {
        print("Restriction \(restrictionIdentifier) changed state to: \(newRestrictionState)")

        let isEnabled = (newRestrictionState == .allow) // Note: .allow means restriction *not* active

        switch restrictionIdentifier {
        case GuidedAccessCustomRestrictions.disableAccountSettings:
            // Update the state in the AccessibilityManager
            // Using NotificationCenter is also a good pattern here to decouple
            DispatchQueue.main.async { [weak self] in
                 // The logic seems inverted in the original API description vs common sense.
                 // UIGuidedAccessRestrictionState.allow means the *feature* is allowed (restriction OFF).
                 // UIGuidedAccessRestrictionState.deny means the *feature* is denied (restriction ON).
                 // So, we want our internal state `isCustomRestrictionEnabled` to be true when the state is .deny.
                self?.accessibilityManager?.isCustomRestrictionEnabled = (newRestrictionState == .deny)
                print("AppDelegate updated manager: isCustomRestrictionEnabled = \(self?.accessibilityManager?.isCustomRestrictionEnabled ?? false)")

                // Alternative: Post a notification
                // NotificationCenter.default.post(name: .customRestrictionDidChange, object: nil, userInfo: ["identifier": restrictionIdentifier, "isEnabled": isEnabled])
            }
        default:
            break
        }
    }
}

// Optional: Define a custom notification name
// extension Notification.Name {
//    static let customRestrictionDidChange = Notification.Name("customRestrictionDidChangeNotification")
// }

import SwiftUI // For ObservableObject & UIAccessibility
import Combine // For ObservableObject

class AccessibilityManager: ObservableObject {

    // MARK: - Published Properties for UI Updates
    @Published var isASAMActive: Bool = false // Autonomous Single App Mode status
    @Published var isCustomRestrictionEnabled: Bool = false // State of our custom Guided Access restriction
    @Published var statusMessage: String = "Ready"

    private var observers = Set<AnyCancellable>()

    init() {
        // Initial checks on launch
        checkASAMStatus()
        checkCustomRestrictionStatus() // Check initial state if app launched during Guided Access

        // Observe system notifications for ASAM state changes
        NotificationCenter.default.publisher(for: UIAccessibility.guidedAccessStatusDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Received guidedAccessStatusDidChangeNotification")
                self?.checkASAMStatus()
            }
            .store(in: &observers)

        // Optional: Observer for custom restriction changes if using NotificationCenter from AppDelegate
        // NotificationCenter.default.publisher(for: .customRestrictionDidChange)
        //    .receive(on: DispatchQueue.main)
        //    .sink { [weak self] notification in
        //        // Handle notification from AppDelegate
        //    }
        //    .store(in: &observers)
    }

    // MARK: - Status Checks

    func checkASAMStatus() {
        let isActive = UIAccessibility.isGuidedAccessEnabled
        DispatchQueue.main.async {
            self.isASAMActive = isActive
            self.statusMessage = isActive ? "Autonomous Single App Mode is ACTIVE" : "Autonomous Single App Mode is INACTIVE"
            print("Checked ASAM Status: \(isActive)")
        }
    }

    func checkCustomRestrictionStatus() {
        let state = UIAccessibility.guidedAccessRestrictionState(forIdentifier: GuidedAccessCustomRestrictions.disableAccountSettings)
        // Remember: .deny means the restriction IS enabled.
        let isEnabled = (state == .deny)
        DispatchQueue.main.async {
            // Avoid overwriting if AppDelegate update is pending/in-flight
            if self.isCustomRestrictionEnabled != isEnabled {
                 self.isCustomRestrictionEnabled = isEnabled
            }
             print("Checked Custom Restriction Status (\(GuidedAccessCustomRestrictions.disableAccountSettings)): \(isEnabled)")
        }
    }

    // MARK: - ASAM Control (Requires Supervision & Allowlisting)

    func requestASAM(enable: Bool) {
        guard UIAccessibility.isGuidedAccessEnabled != enable else {
            statusMessage = "ASAM state is already \(enable ? "enabled" : "disabled")."
            print(statusMessage)
            return
        }

        statusMessage = enable ? "Requesting ASAM Start..." : "Requesting ASAM End..."
        print(statusMessage)

        UIAccessibility.requestGuidedAccessSession(enabled: enable) { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if success {
                    self.isASAMActive = enable
                    self.statusMessage = "ASAM Session \(enable ? "Started" : "Ended") Successfully."
                    print(self.statusMessage)
                    // Perform app-specific logic after state change
                    if enable {
                        self.didEnterASAM()
                    } else {
                        self.didExitASAM()
                    }
                } else {
                    self.isASAMActive = UIAccessibility.isGuidedAccessEnabled // Re-check actual state
                    let errorDescription = error?.localizedDescription ?? "Unknown error"
                    self.statusMessage = "Failed to \(enable ? "start" : "end") ASAM session: \(errorDescription)"
                    print(self.statusMessage)
                    // Handle failure - maybe alert the user if interaction is expected
                }
            }
        }
    }

    // Placeholder for app logic when entering/exiting ASAM
    private func didEnterASAM() {
        print("App logic for entering ASAM (e.g., start new patient sheet)")
        // Update UI, start specific flows, etc.
    }

    private func didExitASAM() {
        print("App logic for exiting ASAM (e.g., save data, reset UI)")
        // Perform cleanup, bookkeeping, navigate back, etc.
    }

    // MARK: - Accessibility Feature Control (Requires Guided Access/ASAM active)

    func toggleAccessibilityFeature(feature: UIAccessibility.GuidedAccessAccessibilityFeature, enable: Bool) {
        // Note: The original documentation implied a synchronous API.
        // The actual API landscape might vary. Check current SDK documentation.
        // This implementation assumes the synchronous version mentioned.
        // Error handling might be needed if using newer async APIs.

        // Basic check: Often requires SAM to be active, though specifics might vary.
        // guard isASAMActive else {
        //     statusMessage = "Cannot toggle features: ASAM not active."
        //     print(statusMessage)
        //     return // Or handle based on specific feature requirements
        // }

        print("Attempting to \(enable ? "enable" : "disable") feature: \(feature)")
        statusMessage = "Configuring \(feature)..."

        // --- IMPORTANT ---
        // The documentation shows: UIAccessibility.configureForGuidedAccess(...)
        // However, this exact static method signature doesn't seem to exist in public SDKs
        // as of recent checks. It might have been internal, changed, or described inaccurately.
        // The closest public API might involve device management profiles or potentially
        // private APIs (which should NOT be used for App Store apps).
        //
        // **If this API *is* available in your specific context/SDK:**
        // UIAccessibility.configureForGuidedAccess(feature: feature, enabled: enable)
        // print("Configuration command sent for \(feature) to \(enable ? "enable" : "disable").")
        // statusMessage = "\(feature) configuration attempted."
        // ---> Check feature status separately if needed, as this call might not guarantee immediate change or success.

        // **Since the public API is uncertain, we simulate the intent:**
         statusMessage = "Feature toggle API (\(feature)) not directly available/verifiable in public SDK. Simulating request."
         print("Simulated request to \(enable ? "enable" : "disable") feature: \(feature). Implement using available MDM or specific framework APIs if applicable.")
         // --- End Simulation ---

        // Example of checking status *if* possible (pseudo-code, actual API depends on feature)
        // let isFeatureOn = checkSpecificFeatureStatus(feature)
        // print("Current status of \(feature): \(isFeatureOn)")
    }
}

// Helper for readability - define the features if needed elsewhere
extension UIAccessibility.GuidedAccessAccessibilityFeature {
    // Provide string representations if desired
    var name: String {
        switch self {
        case .voiceOver: return "VoiceOver"
        case .zoom: return "Zoom"
        case .assistiveTouch: return "AssistiveTouch"
        case .invertColors: return "Invert Colors"
        case .grayscale: return "Grayscale"
        @unknown default: return "Unknown Feature"
        }
    }
}

import SwiftUI

struct ContentView: View {
    // Get the AccessibilityManager from the environment
    @EnvironmentObject var accessibilityManager: AccessibilityManager

    var body: some View {
        NavigationView {
            List {
                // MARK: - ASAM Status & Control
                Section("Autonomous Single App Mode (ASAM)") {
                    Text("Status: \(accessibilityManager.isASAMActive ? "Active" : "Inactive")")
                        .foregroundColor(accessibilityManager.isASAMActive ? .green : .red)

                    HStack {
                        Button("Start ASAM Session") {
                            accessibilityManager.requestASAM(enable: true)
                        }
                        .disabled(accessibilityManager.isASAMActive)

                        Spacer()

                        Button("End ASAM Session") {
                            accessibilityManager.requestASAM(enable: false)
                        }
                        .disabled(!accessibilityManager.isASAMActive)
                    }
                    Text("Requires supervised device & allowlisted app.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // MARK: - Guided Access Custom Restriction Demo
                Section("Guided Access Custom Restriction") {
                    Text("Custom Restriction 'Disable Account Settings' is \(accessibilityManager.isCustomRestrictionEnabled ? "Enabled" : "Disabled")")
                        .foregroundColor(accessibilityManager.isCustomRestrictionEnabled ? .orange : .primary)

                    // Example Button affected by the custom restriction
                    Button {
                        print("Account Settings Tapped!")
                        // Navigate to account settings or perform action
                    } label: {
                        Label("Account Settings", systemImage: "person.crop.circle.fill")
                    }
                    // Disable the button if the custom restriction is active
                    .disabled(accessibilityManager.isCustomRestrictionEnabled)
                    .opacity(accessibilityManager.isCustomRestrictionEnabled ? 0.5 : 1.0)

                    Text("Toggle this restriction in Guided Access options (Triple-click > Options) when Guided Access is active.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // MARK: - Accessibility Feature Toggling
                Section("Accessibility Feature Control (During SAM)") {
                    Text("Use these to toggle AT features programmatically.")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Note: `configureForGuidedAccess` API availability uncertain in public SDK. Simulating request.")
                         .font(.caption2)
                         .foregroundColor(.orange)

                    HStack {
                        Button("Enable VoiceOver") {
                           accessibilityManager.toggleAccessibilityFeature(feature: .voiceOver, enable: true)
                        }
                        Spacer()
                        Button("Disable VoiceOver") {
                            accessibilityManager.toggleAccessibilityFeature(feature: .voiceOver, enable: false)
                        }
                    }
                    HStack {
                         Button("Enable Zoom") {
                            accessibilityManager.toggleAccessibilityFeature(feature: .zoom, enable: true)
                         }
                         Spacer()
                         Button("Disable Zoom") {
                             accessibilityManager.toggleAccessibilityFeature(feature: .zoom, enable: false)
                         }
                    }
                    // Add buttons for other features (InvertColors, AssistiveTouch, Grayscale) similarly
                }

                // MARK: - Status Messages
                Section("Status Log") {
                    Text(accessibilityManager.statusMessage)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

            } // End List
            .navigationTitle("Accessible SAM Demo")
            .listStyle(InsetGroupedListStyle())
            .onAppear {
                // Refresh status when the view appears
                accessibilityManager.checkASAMStatus()
                accessibilityManager.checkCustomRestrictionStatus()
            }
        } // End NavigationView
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AccessibilityManager()) // Provide a dummy manager for preview
    }
}
