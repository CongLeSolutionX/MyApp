//
//  AuthenticationFlowForCamera_withToggleOption.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI
import AVFoundation // Import AVFoundation for AVAuthorizationStatus, AVMediaType

// MARK: - Authorization Managing Protocol
/// Defines the interface for managing authorization status checks and requests.
@MainActor // Ensure conformance requires MainActor for UI updates
protocol AuthorizationManaging: ObservableObject {
    var currentStatus: AVAuthorizationStatus { get }
    var mediaType: AVMediaType { get }

    func checkStatus()
    func requestAccess() async -> Bool // Make request async to align with modern API
}


// MARK: - Real Authorization Manager
/// Interacts directly with AVCaptureDevice for authorization.
@MainActor
class RealAuthorizationManager: AuthorizationManaging {
    @Published private(set) var currentStatus: AVAuthorizationStatus
    let mediaType: AVMediaType

    init(mediaType: AVMediaType) {
        self.mediaType = mediaType
        // Fetch initial status synchronously (safe on MainActor)
        self.currentStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        print("RealAuthManager Initialized for \(mediaType.rawValue) with actual state: \(currentStatus)")
    }

    /// Checks the current authorization status using AVCaptureDevice.
    func checkStatus() {
        let newStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        if newStatus != currentStatus {
            currentStatus = newStatus
            print("RealAuthManager: Status for \(mediaType.rawValue) updated to: \(currentStatus)")
        } else {
             print("RealAuthManager: Status for \(mediaType.rawValue) remains: \(currentStatus)")
        }
    }

    /// Requests user access using the async version of AVCaptureDevice.requestAccess.
    func requestAccess() async -> Bool {
        guard currentStatus == .notDetermined else {
            print("RealAuthManager: Access request attempted but status is not .notDetermined (\(currentStatus)). Ignoring.")
            return currentStatus == .authorized // Return true only if already authorized
        }

        print("RealAuthManager: Requesting real access for \(mediaType.rawValue)...")
        let granted = await AVCaptureDevice.requestAccess(for: mediaType)
        // Update status after the request completes
        // Use Task to ensure update happens even if requestAccess doesn't immediately yield back to MainActor context
         await MainActor.run { // Explicitly run on MainActor
            self.currentStatus = granted ? .authorized : .denied
            print("RealAuthManager: Access request completed for \(mediaType.rawValue). Granted: \(granted). New status: \(self.currentStatus)")
        }
        return granted
    }
}


// MARK: - Fake Authorization Manager (Updated)
/// Simulates authorization interactions for testing/previews.
@MainActor
class FakeAuthorizationManager: AuthorizationManaging {
    @Published private(set) var currentStatus: AVAuthorizationStatus
    let mediaType: AVMediaType

    init(mediaType: AVMediaType, initialState: AVAuthorizationStatus = .notDetermined) {
        self.mediaType = mediaType
        self.currentStatus = initialState
        print("FakeAuthManager Initialized for \(mediaType.rawValue) with initial fake state: \(currentStatus)")
    }

    func checkStatus() {
        print("FakeAuthManager: Checking fake status for \(mediaType.rawValue): \(currentStatus)")
        // No change needed for simulation, the @Published property drives the UI.
    }

    func requestAccess() async -> Bool {
        guard currentStatus == .notDetermined else {
            print("FakeAuthManager: Access request attempted but status is not .notDetermined (\(currentStatus)). Ignoring.")
            return currentStatus == .authorized
        }

        print("FakeAuthManager: Simulating access request for \(mediaType.rawValue)...")

        // Simulate the OS showing a prompt and the user responding after a delay
        try? await Task.sleep(nanoseconds: 1_500_000_000) // Simulate 1.5 second delay

        // Simulate user granting or denying permission (50/50 chance here)
        let granted = Bool.random()
        if granted {
            print("FakeAuthManager: Simulated user GRANTED access for \(self.mediaType.rawValue)")
            self.currentStatus = .authorized
        } else {
            print("FakeAuthManager: Simulated user DENIED access for \(self.mediaType.rawValue)")
            self.currentStatus = .denied
        }
        return granted
    }

    // Helper to simulate restricted state externally (for testing)
    func setRestricted() {
         print("FakeAuthManager: Simulating setting status to RESTRICTED for \(self.mediaType.rawValue)")
         self.currentStatus = .restricted
    }
     // Helper to reset for testing
    func reset() {
         print("FakeAuthManager: Simulating resetting status to NOT DETERMINED for \(self.mediaType.rawValue)")
         self.currentStatus = .notDetermined
    }
}


// MARK: - Authorization Flow View (Updated)
/// SwiftUI View demonstrating the Authorization Flow with real/fake API toggle.
struct AuthorizationFlowView: View {
    // Use the protocol type for the manager state object
    @StateObject private var authManager: any AuthorizationManaging
    @State private var useRealAPI: Bool = false // State to track which API to use

    // Hold the chosen media type
    private let mediaType: AVMediaType
    private let mediaTypeDescription: String

    // Initialize with media type, default to fake manager initially
    init(mediaType: AVMediaType) {
        self.mediaType = mediaType
        self.mediaTypeDescription = (mediaType == .video) ? "Camera" : (mediaType == .audio ? "Microphone" : "Media")
        // Initial state MUST be set here before body access. Start with Fake.
         _authManager = StateObject(wrappedValue: FakeAuthorizationManager(mediaType: mediaType))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("\(mediaTypeDescription) Access Status")
                .font(.title)
                .padding(.bottom)

            // -- API Mode Toggle --
            Toggle("Use REAL \(mediaTypeDescription) Permissions", isOn: $useRealAPI)
                .padding(.horizontal)
                 .tint(.purple)

            // Display content based on the current authorization status from the manager
            StatusDisplayView(status: authManager.currentStatus, mediaTypeDescription: mediaTypeDescription)
                .onAppear {
                    // Re-check status whenever the view appears, useful if user backgrounds app and changes settings
                    authManager.checkStatus()
                }

            // Conditional button for requesting permission
            if authManager.currentStatus == .notDetermined {
                RequestPermissionButton(mediaTypeDescription: mediaTypeDescription) {
                    // Use Task for async request
                    Task {
                         await authManager.requestAccess()
                         // Status will update via @Published property
                    }
                }
            } else if authManager.currentStatus == .denied {
                 // Optionally add a button to open Settings
                 Button("Open Settings") {
                     // In a real app, implement logic to open the app's settings page
                     print("Attempting to open Settings (implementation needed)")
                     guard let url = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(url) else { return }
                     UIApplication.shared.open(url)
                 }
                 .buttonStyle(.bordered)
            }

            Spacer() // Pushes content to the top

            // --- Simulation Controls (Only relevant for Fake API mode) ---
            if !useRealAPI, let fakeMgr = authManager as? FakeAuthorizationManager {
                 Divider().padding(.vertical)
                 Text("Fake Simulation Controls").font(.caption).foregroundColor(.gray)
                 HStack {
                     Button("Set Fake Restricted") { fakeMgr.setRestricted() }
                        .buttonStyle(.bordered).tint(.orange)
                     Button("Reset Fake") { fakeMgr.reset() }
                        .buttonStyle(.bordered).tint(.blue)
                 }
            } else if useRealAPI {
                Text("Using real device permissions.")
                    .font(.caption)
                    .foregroundColor(.purple)

                 // Reminder for Info.plist setup for real mode
                 Text("Ensure \(mediaType == .video ? "NSCameraUsageDescription" : "NSMicrophoneUsageDescription") is set in Info.plist")
                     .font(.caption2)
                     .foregroundColor(.gray)
                     .multilineTextAlignment(.center)
                     .padding(.horizontal)
            }
            // --- End Simulation Controls ---
        }
        .padding()
        .onChange(of: useRealAPI) { newValue in
            // When the toggle changes, instantiate the correct manager type
            if newValue {
                // Create and assign the real manager
                 _authManager.wrappedValue = RealAuthorizationManager(mediaType: mediaType)
                 print("Switched to REAL Authorization Manager for \(mediaType.rawValue)")
            } else {
                // Create and assign the fake manager
                 _authManager.wrappedValue = FakeAuthorizationManager(mediaType: mediaType)
                 print("Switched to FAKE Authorization Manager for \(mediaType.rawValue)")
            }
            // Check status immediately after switching manager
             authManager.checkStatus()
        }
    }
}

// MARK: - Extracted Status Display View
/// Displays the status section based purely on the status value.
struct StatusDisplayView: View {
    let status: AVAuthorizationStatus
    let mediaTypeDescription: String

    var body: some View {
        switch status {
        case .notDetermined:
            StatusSectionView(
                statusText: "Permission Not Determined",
                description: "Access to the \(mediaTypeDescription.lowercased()) has not yet been requested.",
                systemImage: "questionmark.circle",
                color: .orange
            )
        case .restricted:
            StatusSectionView(
                statusText: "Access Restricted",
                description: "\(mediaTypeDescription) access is restricted, possibly due to system settings like Parental Controls. This cannot be changed by the app.",
                systemImage: "xmark.octagon.fill",
                color: .red
            )
        case .denied:
            StatusSectionView(
                statusText: "Access Denied",
                description: "You have previously denied \(mediaTypeDescription.lowercased()) access. Please enable it in the Settings app if you wish to use this feature.",
                systemImage: "hand.raised.slash.fill",
                color: .red
            )
        case .authorized:
            StatusSectionView(
                statusText: "Access Granted",
                description: "The app has permission to use the \(mediaTypeDescription.lowercased()).",
                systemImage: "checkmark.circle.fill",
                color: .green
            )
        @unknown default:
            StatusSectionView(
                statusText: "Unknown Status",
                description: "An unexpected authorization status was encountered.",
                systemImage: "exclamationmark.triangle.fill",
                color: .gray
            )
        }
    }
}

// MARK: - Reusable UI Components (Unchanged)
struct StatusSectionView: View {
    let statusText: String
    let description: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundColor(color)
            Text(statusText)
                .font(.headline)
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct RequestPermissionButton: View {
    let mediaTypeDescription: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Label("Request \(mediaTypeDescription) Access", systemImage: "hand.point.up.left.fill")
        }
        .buttonStyle(.borderedProminent)
        .padding(.top)
    }
}

// MARK: - Previews
struct AuthorizationFlowView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview different initial states often useful with Fake Manager
        Group {
            // Start with Fake Manager (default)
            AuthorizationFlowView(mediaType: .video)
                .previewDisplayName("Video Flow (Default Fake)")

            AuthorizationFlowView(mediaType: .audio)
                .previewDisplayName("Audio Flow (Default Fake)")

             // Example showing how to force Real Manager in preview if needed,
             // though interaction limited w/o real device/prompt.
//             AuthorizationFlowView(mediaType: .video)
//                 .onAppear { /* Logic to maybe force real API if needed */ }
//                 .previewDisplayName("Video Flow (Real API - Limited)")
        }
    }
}

/*
 !! IMPORTANT !!
 For the REAL API mode to function correctly when running on a device or simulator:
 1. Add `NSCameraUsageDescription` to your `Info.plist` file with a description explaining why you need camera access.
 2. Add `NSMicrophoneUsageDescription` to your `Info.plist` file with a description explaining why you need microphone access.
 Failure to add these keys will cause your app to crash when requesting permission.
 */
