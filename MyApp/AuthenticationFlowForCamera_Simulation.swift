////
////  AuthenticationFlowForCamera.swift
////  MyApp
////
////  Created by Cong Le on 4/12/25.
////
//
//import SwiftUI
//import AVFoundation // Import AVFoundation for AVAuthorizationStatus
//
///// **Simulated Authorization Manager**
///// In a real app, this would interact with AVCaptureDevice directly.
//@MainActor // Ensures UI updates are on the main thread
//class FakeAuthorizationManager: ObservableObject {
//
//    @Published var currentStatus: AVAuthorizationStatus = .notDetermined // Start as undetermined
//    let mediaType: AVMediaType // e.g., .video or .audio
//
//    // Allow simulating different initial states for testing
//    init(mediaType: AVMediaType, initialState: AVAuthorizationStatus = .notDetermined) {
//        self.mediaType = mediaType
//        self.currentStatus = initialState
//        print("FakeAuthManager Initialized for \(mediaType.rawValue) with state: \(currentStatus)")
//    }
//
//    /// Simulates checking the authorization status. In a real app, call AVCaptureDevice.authorizationStatus(for:)
//    func checkStatus() {
//        // In a real app, you'd fetch the actual status here.
//        // For simulation, we just report the current state.
//        print("Checking fake status for \(mediaType.rawValue): \(currentStatus)")
//        // No change needed for simulation, the @Published property drives the UI.
//    }
//
//    /// Simulates requesting access from the user. In a real app, call AVCaptureDevice.requestAccess(for:)
//    func requestAccess() {
//        guard currentStatus == .notDetermined else {
//            print("Access request attempted but status is not .notDetermined (\(currentStatus)). Ignoring.")
//            return
//        }
//
//        print("Simulating access request for \(mediaType.rawValue)...")
//
//        // Simulate the OS showing a prompt and the user responding after a delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            // Simulate user granting or denying permission (50/50 chance here)
//            let granted = Bool.random()
//            if granted {
//                print("Simulated user GRANTED access for \(self.mediaType.rawValue)")
//                self.currentStatus = .authorized
//            } else {
//                print("Simulated user DENIED access for \(self.mediaType.rawValue)")
//                self.currentStatus = .denied
//            }
//        }
//    }
//
//    // Helper to simulate restricted state externally
//    func setRestricted() {
//         print("Simulating setting status to RESTRICTED for \(self.mediaType.rawValue)")
//         self.currentStatus = .restricted
//    }
//     // Helper to reset for testing
//    func reset() {
//         print("Simulating resetting status to NOT DETERMINED for \(self.mediaType.rawValue)")
//         self.currentStatus = .notDetermined
//    }
//}
//
///// **Main SwiftUI View Demonstrating the Authorization Flow**
//struct AuthorizationFlowView: View {
//    // Use @StateObject to create and manage the lifetime of the manager
//    @StateObject private var authManager: FakeAuthorizationManager
//
//    // Determine which media type this view instance manages
//    private let mediaTypeDescription: String
//
//    init(mediaType: AVMediaType, initialState: AVAuthorizationStatus = .notDetermined) {
//        _authManager = StateObject(wrappedValue: FakeAuthorizationManager(mediaType: mediaType, initialState: initialState))
//        self.mediaTypeDescription = (mediaType == .video) ? "Camera" : (mediaType == .audio ? "Microphone" : "Media")
//    }
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("\(mediaTypeDescription) Access Status")
//                .font(.title)
//                .padding(.bottom)
//
//            // Display content based on the current authorization status
//            switch authManager.currentStatus {
//            case .notDetermined:
//                StatusSectionView(
//                    statusText: "Permission Not Determined",
//                    description: "Access to the \(mediaTypeDescription.lowercased()) has not yet been requested.",
//                    systemImage: "questionmark.circle",
//                    color: .orange
//                )
//                RequestPermissionButton(mediaTypeDescription: mediaTypeDescription) {
//                    authManager.requestAccess()
//                }
//
//            case .restricted:
//                StatusSectionView(
//                    statusText: "Access Restricted",
//                    description: "\(mediaTypeDescription) access is restricted, possibly due to system settings like Parental Controls. This cannot be changed by the app.",
//                    systemImage: "xmark.octagon.fill",
//                    color: .red
//                )
//
//            case .denied:
//                StatusSectionView(
//                    statusText: "Access Denied",
//                    description: "You have previously denied \(mediaTypeDescription.lowercased()) access. Please enable it in the Settings app if you wish to use this feature.",
//                    systemImage: "hand.raised.slash.fill",
//                    color: .red
//                )
//                // Optionally add a button to open Settings
//                 Button("Open Settings") {
//                     // In a real app, implement logic to open the app's settings page
//                     print("Attempting to open Settings (implementation needed)")
//                     // UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
//                 }
//                 .buttonStyle(.bordered)
//
//            case .authorized:
//                StatusSectionView(
//                    statusText: "Access Granted",
//                    description: "The app has permission to use the \(mediaTypeDescription.lowercased()).",
//                    systemImage: "checkmark.circle.fill",
//                    color: .green
//                )
//                // You can now proceed with features requiring this access
//                Text("(\(mediaTypeDescription) features can now be used)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//
//            @unknown default:
//                StatusSectionView(
//                    statusText: "Unknown Status",
//                    description: "An unexpected authorization status was encountered.",
//                    systemImage: "exclamationmark.triangle.fill",
//                    color: .gray
//                )
//            }
//
//            Spacer() // Pushes content to the top
//
//             // --- Simulation Controls (For Previews/Testing Only) ---
//             Divider().padding(.vertical)
//             Text("Simulation Controls").font(.caption).foregroundColor(.gray)
//             HStack {
//                 Button("Set Restricted") { authManager.setRestricted() }.buttonStyle(.bordered).tint(.orange)
//                 Button("Reset") { authManager.reset() }.buttonStyle(.bordered).tint(.blue)
//             }
//             // --- End Simulation Controls ---
//
//        }
//        .padding()
//        .onAppear {
//            // Check status when the view appears (optional, depends on app flow)
//            authManager.checkStatus()
//        }
//    }
//}
//
///// **Reusable View Section for Displaying Status**
//struct StatusSectionView: View {
//    let statusText: String
//    let description: String
//    let systemImage: String
//    let color: Color
//
//    var body: some View {
//        VStack(spacing: 10) {
//            Image(systemName: systemImage)
//                .font(.largeTitle)
//                .foregroundColor(color)
//            Text(statusText)
//                .font(.headline)
//            Text(description)
//                .font(.body)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//        }
//    }
//}
//
///// **Button to Request Permission**
//struct RequestPermissionButton: View {
//    let mediaTypeDescription: String
//    let action: () -> Void
//
//    var body: some View {
//        Button {
//            action()
//        } label: {
//            Label("Request \(mediaTypeDescription) Access", systemImage: "hand.point.up.left.fill")
//        }
//        .buttonStyle(.borderedProminent)
//        .padding(.top)
//    }
//}
//
//// MARK: - Previews
//struct AuthorizationFlowView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview different initial states
//        Group {
//            AuthorizationFlowView(mediaType: .video, initialState: .notDetermined)
//                .previewDisplayName("Video - Not Determined")
//
//            AuthorizationFlowView(mediaType: .audio, initialState: .authorized)
//                .previewDisplayName("Audio - Authorized")
//
//            AuthorizationFlowView(mediaType: .video, initialState: .denied)
//                .previewDisplayName("Video - Denied")
//
//            AuthorizationFlowView(mediaType: .audio, initialState: .restricted)
//                .previewDisplayName("Audio - Restricted")
//        }
//    }
//}
