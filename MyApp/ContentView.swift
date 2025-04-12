//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
import SwiftUI

// Step 2: Use in SwiftUI view
struct ContentView: View {
    var body: some View {
        UIKitViewControllerWrapper()
            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
    }
}

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}

// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}

//import SwiftUI
//@preconcurrency import AVFoundation // Required for Camera functionalities
//
//// MARK: - Camera Manager (ObservableObject)
//
//@MainActor // Ensure UI updates are on the main thread
//class CameraManager: ObservableObject {
//
//    enum Status {
//        case unconfigured
//        case configured
//        case unauthorized
//        case failed
//    }
//
//    // AVCapture Session
//    let session = AVCaptureSession()
//
//    // Published properties to update SwiftUI views
//    @Published var error: CameraError? = nil
//    @Published var status = Status.unconfigured
//
//    private let sessionQueue = DispatchQueue(label: "com.yourapp.sessionQueue") // Background queue for session work
//    private let videoOutput = AVCaptureVideoDataOutput() // If you wanted to process frames, otherwise optional
//    private var videoDeviceInput: AVCaptureDeviceInput?
//
//    // Camera device (defaults to back camera)
//    // You could add logic here to select front/back or specific cameras
//    private var cameraDevice: AVCaptureDevice? {
//        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
//    }
//
//    // MARK: - Initialization
//    init() {
//        // Check initial permissions
//        checkPermissions()
//    }
//
//    // MARK: - Permissions
//    private func checkPermissions() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            // Permission previously granted, proceed with configuration
//            configureCaptureSession()
//        case .notDetermined:
//            // Permission not yet requested
//            // Wait for the user to trigger the request via UI
//            status = .unconfigured // Or a specific "needsPermission" state
//        case .denied, .restricted:
//            // Permission denied or restricted
//            status = .unauthorized
//            setError(.permissionDenied)
//        @unknown default:
//            // Future cases
//            status = .unauthorized
//            setError(.unknownPermissionStatus)
//        }
//    }
//
//    func requestPermission() {
//        // Runs on the main thread due to @MainActor
//        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//            guard let self = self else { return }
//            if granted {
//                // Permission granted, configure the session
//                self.configureCaptureSession()
//            } else {
//                // Permission denied
//                self.status = .unauthorized
//                self.setError(.permissionDenied)
//            }
//        }
//    }
//
//    // MARK: - Session Configuration
//    private func configureCaptureSession() {
//        guard status != .configured else { // Avoid re-configuration
//            print("Camera session already configured.")
//            return
//        }
//        
//        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
//            print("Attempted to configure session without authorization.")
//            status = .unauthorized
//            setError(.permissionDenied)
//            return
//        }
//
//        guard let device = cameraDevice else {
//            setError(.deviceUnavailable)
//            status = .failed
//            return
//        }
//
//        sessionQueue.async { [weak self] in // Perform setup on the background queue
//            guard let self = self else { return }
//
//            self.session.beginConfiguration()
//
//            // --- Input Setup ---
//             // Remove existing input if switching cameras later
//             if let currentInput = self.videoDeviceInput {
//                 self.session.removeInput(currentInput)
//                 self.videoDeviceInput = nil
//             }
//             
//            do {
//                let videoInput = try AVCaptureDeviceInput(device: device)
//                if self.session.canAddInput(videoInput) {
//                    self.session.addInput(videoInput)
//                    self.videoDeviceInput = videoInput // Store the input
//                } else {
//                    self.setError(.cannotAddInput)
//                    self.status = .failed
//                    self.session.commitConfiguration()
//                    return
//                }
//            } catch {
//                self.setError(.createInputFailed(error))
//                self.status = .failed
//                self.session.commitConfiguration()
//                return
//            }
//
//            // --- Output Setup (Optional: if you need to process frames) ---
//            // if session.canAddOutput(videoOutput) {
//            //     session.addOutput(videoOutput)
//            //     // Configure videoOutput settings (pixel format, delegate, etc.) here
//            //     // videoOutput.setSampleBufferDelegate(self, queue: ...)
//            // } else {
//            //     setError(.cannotAddOutput)
//            //     status = .failed
//            //     session.commitConfiguration()
//            //     return
//            // }
//
//            // --- Finalize Configuration ---
//            self.session.sessionPreset = .photo // Choose preset (photo, high, medium, etc.)
//
//            self.session.commitConfiguration()
//
//            // --- Start Session (Only if not already running) ---
//            if !self.session.isRunning {
//                 self.session.startRunning()
//                 print("Camera session started.")
//            }
//            
//             // --- Update Status on Main Thread ---
//            Task { @MainActor in // Ensure status update happens on main thread
//                self.status = .configured
//                self.error = nil // Clear previous errors on successful config
//                print("Camera session configured successfully.")
//            }
//        }
//    }
//    
//    // MARK: - Session Control
//    func startSession() {
//         guard status == .configured else {
//             print("Cannot start session, not configured or not authorized.")
//             // Optionally attempt configuration again if authorized but not configured
//             if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
//                 configureCaptureSession()
//             }
//             return
//         }
//         
//        sessionQueue.async { [weak self] in
//             guard let self = self, !self.session.isRunning else { return }
//             self.session.startRunning()
//             print("Camera session explicitly started.")
//         }
//    }
//
//    func stopSession() {
//        guard session.isRunning else { return }
//        sessionQueue.async { [weak self] in
//            self?.session.stopRunning()
//            print("Camera session stopped.")
//        }
//    }
//
//    // MARK: - Error Handling
//    private func setError(_ error: CameraError) {
//        // Use Task to ensure UI updates happen on MainActor thread
//        Task { @MainActor in
//            self.error = error
//            print("Camera Error: \(error.localizedDescription)")
//        }
//    }
//}
//
//// MARK: - Camera Error Enum
//enum CameraError: Error, LocalizedError {
//    case permissionDenied
//    case unknownPermissionStatus
//    case deviceUnavailable
//    case cannotAddInput
//    case cannotAddOutput
//    case createInputFailed(Error)
//    case sessionFailed(Error)
//
//    var errorDescription: String? {
//        switch self {
//        case .permissionDenied, .unknownPermissionStatus:
//            return "Camera access is required."
//        case .deviceUnavailable:
//            return "Camera device is not available."
//        case .cannotAddInput:
//            return "Cannot add camera input to the session."
//        case .cannotAddOutput:
//            return "Cannot add video output to the session."
//        case .createInputFailed(let error):
//            return "Failed to create camera input: \(error.localizedDescription)"
//        case .sessionFailed(let error):
//            return "Camera session failed: \(error.localizedDescription)"
//        }
//    }
//
//    var recoverySuggestion: String? {
//         switch self {
//         case .permissionDenied, .unknownPermissionStatus:
//            return "Please grant camera access in Settings."
//         default:
//            return "Please try again or restart the app."
//         }
//     }
//}
//
//// MARK: - Camera Preview (UIViewRepresentable)
//
//struct CameraPreviewView: UIViewRepresentable {
//    // Pass the session from the CameraManager
//    let session: AVCaptureSession
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        view.backgroundColor = .black // Background while camera initializes
//
//        // --- Create and Configure Preview Layer ---
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill // Or .resizeAspect
//        previewLayer.connection?.videoOrientation = .portrait // Adjust if needed for device orientation
//
//        // --- Add Layer to View ---
//        view.layer.addSublayer(previewLayer)
//
//        // Store layer reference for easy access in updateUIView
//        // Using associated objects or a custom UIView subclass are alternatives
//        // This is a simpler approach for this example:
//        objc_setAssociatedObject(view, &AssociatedKeys.previewLayer, previewLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        // --- Update Layer Frame ---
//        // Retrieve the stored layer
//        if let previewLayer = objc_getAssociatedObject(uiView, &AssociatedKeys.previewLayer) as? AVCaptureVideoPreviewLayer {
//             previewLayer.frame = uiView.bounds // Update frame on rotation or layout changes
//            
//             // --- Update Orientation (If needed) ---
//             // You might want to observe device orientation changes and update this
//             previewLayer.connection?.videoOrientation = currentOrientation()
//        }
//    }
//    
//     // Helper to get current orientation
//     private func currentOrientation() -> AVCaptureVideoOrientation {
//         guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let orientation = scene.interfaceOrientation else {
//             return .portrait
//         }
//         switch orientation {
//         case .portrait: return .portrait
//         case .landscapeLeft: return .landscapeLeft
//         case .landscapeRight: return .landscapeRight
//         case .portraitUpsideDown: return .portraitUpsideDown
//         default: return .portrait
//         }
//     }
//
//    // Private struct for associated object key
//    private struct AssociatedKeys {
//        static var previewLayer = "previewLayer"
//    }
//}
//
//// MARK: - SwiftUI Camera View
//
//struct CameraView: View {
//    @StateObject private var cameraManager = CameraManager()
//
//    var body: some View {
//        ZStack {
//            // --- Camera Preview Layer ---
//            // Only show if authorized and configured
//            if cameraManager.status == .configured {
//                 CameraPreviewView(session: cameraManager.session)
//                    .ignoresSafeArea() // Let preview fill the screen edges
//            } else {
//                 // Placeholder or background while configuring or if permissions are denied
//                 Color.black.ignoresSafeArea() // Default background
//            }
//
//            // --- UI Overlay ---
//            VStack {
//                Spacer() // Pushes content to bottom or use ZStack alignment
//
//                // --- Status / Error / Permission Handling ---
//                 Group {
//                    switch cameraManager.status {
//                    case .unconfigured:
//                        permissionRequestView
//                    case .unauthorized:
//                        permissionDeniedView
//                    case .failed:
//                        errorView
//                    case .configured:
//                         // Show controls or nothing if preview fills screen
//                         EmptyView()
//                    }
//                 }
//                .padding()
//                .background(.ultraThinMaterial) // Semi-transparent background for text
//                .cornerRadius(10)
//                .padding(.horizontal) // Padding for the overlay box
//                .padding(.bottom, 50) // Position above bottom edge
//            }
//        }
//        // Start session only when view appears *and* configured
//        .onAppear {
//             // Attempt to start only if already configured (permission granted previously)
//             // requestPermission or configure will handle starting if needed later
//             if cameraManager.status == .configured {
//                 cameraManager.startSession()
//             }
//         }
//        .onDisappear {
//            cameraManager.stopSession()
//        }
//        // Handle foreground/background
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//             if cameraManager.status == .configured {
//                 cameraManager.startSession()
//             }
//         }
//         .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
//             cameraManager.stopSession()
//         }
//    }
//
//    // MARK: - Helper Views for Status
//    
//    private var permissionRequestView: some View {
//        VStack(spacing: 10) {
//            Text("Camera Access Needed")
//                .font(.headline)
//            Text("This app needs access to your camera to display a live feed.")
//                .multilineTextAlignment(.center)
//            Button("Grant Permission") {
//                cameraManager.requestPermission()
//            }
//            .buttonStyle(.borderedProminent)
//        }
//    }
//    
//    private var permissionDeniedView: some View {
//         VStack(spacing: 10) {
//             Text("Camera Access Denied")
//                 .font(.headline).foregroundColor(.red)
//             Text(cameraManager.error?.recoverySuggestion ?? "Please grant camera access in Settings.")
//                 .multilineTextAlignment(.center)
//             // Optional: Button to open app settings
//             if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
//                 Button("Open Settings") {
//                     UIApplication.shared.open(url)
//                 }
//                 .buttonStyle(.bordered)
//             }
//         }
//     }
//     
//    private var errorView: some View {
//        VStack(spacing: 10) {
//             Text("Camera Error")
//                 .font(.headline).foregroundColor(.red)
//             Text(cameraManager.error?.errorDescription ?? "An unknown camera error occurred.")
//                 .multilineTextAlignment(.center)
//            Text(cameraManager.error?.recoverySuggestion ?? "Please try again.")
//                .font(.caption).foregroundColor(.secondary)
//         }
//     }
//}
//
//// MARK: - App Entry Point (Example)
///*
//@main
//struct CameraApp: App {
//    var body: some Scene {
//        WindowGroup {
//            CameraView()
//        }
//    }
//}
//*/
//
//// MARK: - Preview Provider
//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview doesn't show live camera, but tests UI states
//        CameraView()
//            // Example injecting a manager in a specific state for preview:
//            // CameraView(cameraManager: createPreviewManager(status: .unauthorized))
//            // CameraView(cameraManager: createPreviewManager(status: .failed, error: .deviceUnavailable))
//    }
//
//     // Helper for creating preview managers (optional)
//     static func createPreviewManager(status: CameraManager.Status, error: CameraError? = nil) -> CameraManager {
//         let manager = CameraManager()
//         manager.status = status
//         manager.error = error
//         return manager
//     }
//}
