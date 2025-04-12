//
//  BasicCameraWorkflowView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI
import AVFoundation // Essential framework for capture operations
import Combine     // For using @Published and handling asynchronous operations

// MARK: - Error Handling Enum
enum CameraError: Error, LocalizedError {
    case setupFailed(reason: String)
    case permissionDenied
    case permissionRestricted
    case unknown

    var errorDescription: String? {
        switch self {
        case .setupFailed(let reason):
            return "Camera setup failed: \(reason)"
        case .permissionDenied:
            return "Camera access denied by user."
        case .permissionRestricted:
            return "Camera access restricted (e.g., parental controls)."
        case .unknown:
            return "An unknown camera error occurred."
        }
    }
}

// MARK: - Camera View Model (Handles AVFoundation Logic)
@MainActor // Ensures @Published properties are updated on the main thread
class CameraViewModel: ObservableObject {

    // 1. Core AVFoundation Components
    let session = AVCaptureSession() // Step 3: Obtain/Create AVCaptureSession
    private var videoDeviceInput: AVCaptureDeviceInput?
    var setupResult: SetupResult = .pending

    // 2. Published Properties for SwiftUI View Updates
    @Published var isSessionRunning = false
    @Published var preview: Preview? // Will hold the UIViewRepresentable's layer
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var setupError: CameraError? = nil // Publish errors for the view

    private var cancellables = Set<AnyCancellable>()
    private let sessionQueue = DispatchQueue(label: "com.example.sessionQueue", qos: .userInitiated)

    enum SetupResult: Equatable {
        static func == (lhs: CameraViewModel.SetupResult, rhs: CameraViewModel.SetupResult) -> Bool {
            return true
        }
        
        case pending
        case success
        case failure(CameraError)
    }

    // MARK: - Initialization and Setup Flow
    init() {
        // Initial check for permissions
        self.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    // Main setup function coordinating the Basic Usage Flow
    func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            // Check permissions before proceeding
            guard self.authorizationStatus == .authorized else {
                Task { @MainActor in // Update UI related state on main thread
                    self.setupResult = .failure(.permissionDenied)
                    self.setupError = .permissionDenied
                }
                return // Stop setup if not authorized
            }

            self.session.beginConfiguration() // Step 4 (Part 1): Begin Configuration

            // Configure Session Preset (Optional but common) - Step 5 (Part 1)
            // Adjust preset based on needs (photo, high-res video, etc.)
            self.session.sessionPreset = .photo // A common default

            // Step 1: Obtain AVCaptureDevice
            guard let videoDevice = self.findDefaultVideoDevice() else {
                self.completeSetup(result: .failure(.setupFailed(reason: "Could not find default video device.")))
                return
            }

            // Step 2: Create AVCaptureDeviceInput
            do {
                let input = try AVCaptureDeviceInput(device: videoDevice)

                // Step 4 (Part 2): Add Input to Session
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.videoDeviceInput = input // Keep a reference if needed later
                } else {
                    self.completeSetup(result: .failure(.setupFailed(reason: "Could not add video device input to session.")))
                    return
                }
            } catch let error {
                self.completeSetup(result: .failure(.setupFailed(reason: "Could not create video device input: \(error.localizedDescription)")))
                return
            }

            // Step 5 (Part 2): Configure Outputs (Preview is implicitly handled via UIViewRepresentable)
            // If you needed photo output, video data output, etc., you'd add them here:
            // Example:
            // let photoOutput = AVCapturePhotoOutput()
            // if session.canAddOutput(photoOutput) {
            //     session.addOutput(photoOutput)
            //     // Configure photoOutput further...
            // } else { ... handle error ... }

            self.session.commitConfiguration() // Step 4 (Part 3): Commit Configuration

            self.completeSetup(result: .success)
        }
    }

    private func completeSetup(result: SetupResult) {
        Task { @MainActor in // Update UI related state on main thread
            self.setupResult = result
            if case .failure(let error) = result {
                self.setupError = error
                self.isSessionRunning = false // Ensure state reflects failure
                self.session.stopRunning() // Stop if it somehow started
            } else if case .success = result {
                // Setup successful, preview can now be created
                 self.setupError = nil
                // Create the preview representation AFTER successful setup
                 self.preview = Preview(session: self.session)
                 self.startSession() // Automatically start after successful setup
            }
        }
    }

    // Helper for Step 1
    private func findDefaultVideoDevice() -> AVCaptureDevice? {
        // Prefer back wide angle camera first
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        // Fallback to front wide angle camera
        else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
             return device
        }
        // Fallback to any default video device
        else {
            return AVCaptureDevice.default(for: .video)
        }
    }

    // MARK: - Session Control

    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.session.isRunning, self.setupResult == SetupResult.success else { return }
            self.session.startRunning() // Step 6: Start Session Running
            Task { @MainActor [weak self] in self?.isSessionRunning = self?.session.isRunning ?? false }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.session.isRunning else { return }
            self.session.stopRunning()
            Task { @MainActor [weak self] in self?.isSessionRunning = self?.session.isRunning ?? false }
        }
    }

    // MARK: - Permissions Handling

    func checkPermissions() {
         let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)
         Task { @MainActor in self.authorizationStatus = currentStatus } // Update published property

         switch currentStatus {
         case .authorized:
//              if setupResult != .success { // Avoid redundant configuration
                  configureSession()
//              }
         case .notDetermined:
              requestPermission()
         case .denied:
              Task { @MainActor in
                   self.setupError = .permissionDenied
                   self.setupResult = .failure(.permissionDenied)
              }
         case .restricted:
              Task { @MainActor in
                   self.setupError = .permissionRestricted
                   self.setupResult = .failure(.permissionRestricted)
              }
         @unknown default:
             Task { @MainActor in
                  self.setupError = .unknown
                  self.setupResult = .failure(.unknown)
             }
         }
    }

    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor [weak self] in // Ensure UI updates are on main
                 guard let self = self else { return }
                 self.authorizationStatus = granted ? .authorized : .denied
                 if granted {
                     self.configureSession()
                 } else {
                     self.setupError = .permissionDenied
                     self.setupResult = .failure(.permissionDenied)
                 }
             }
        }
    }
}

// MARK: - SwiftUI Preview View (UIViewRepresentable)
// This wraps the UIKit AVCaptureVideoPreviewLayer for use in SwiftUI
struct Preview: UIViewRepresentable {
    let session: AVCaptureSession
    private let view = PreviewUIView() // Use a helper UIView subclass

    func makeUIView(context: Context) -> PreviewUIView {
        view.session = session // Assign session here
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        // This might be needed if layout changes drastically, but PreviewUIView handles basic frame sync
        // Ensure the session assigned here matches if it could potentially change
        if uiView.session !== session {
             uiView.session = session
        }
    }

    // Inner UIView subclass to manage the layer's frame
    class PreviewUIView: UIView {
        private var previewLayer: AVCaptureVideoPreviewLayer?

        // Use 'didSet' to configure the layer when the session is assigned
        var session: AVCaptureSession? {
            didSet {
                guard let session = session else {
                    previewLayer?.removeFromSuperlayer()
                    previewLayer = nil
                    return
                }

                // Create layer only if it doesn't exist or session changed
                if previewLayer == nil || previewLayer?.session !== session {
                    let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                    newPreviewLayer.videoGravity = .resizeAspectFill // Or .resizeAspect
                    newPreviewLayer.connection?.videoOrientation = .portrait // Set initial orientation

                    // Remove old layer if it exists
                    previewLayer?.removeFromSuperlayer()

                    // Add new layer
                    layer.addSublayer(newPreviewLayer)
                    previewLayer = newPreviewLayer

                    // Update frame immediately
                    setNeedsLayout()
                }
            }
        }

        // Ensure the previewLayer fills the view bounds
        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer?.frame = bounds
        }
    }
}

// MARK: - Main SwiftUI Content View
struct CameraContentView: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        NavigationView { // Add navigation for title
            ZStack {
                // Display Camera Preview if available
                if let preview = viewModel.preview {
                    preview
                        .ignoresSafeArea() // Make preview fill the screen edges
                } else {
                    // Placeholder or loading state while preview is setting up
                    Color.black.ignoresSafeArea()
                    VStack {
                         ProgressView()
                              .progressViewStyle(CircularProgressViewStyle(tint: .white))
                         Text("Initializing Camera...")
                              .foregroundColor(.white)
                              .padding(.top)
                    }
                }

                VStack {
                    Spacer() // Push controls to the bottom

                    // Display Error Messages
                    if let error = viewModel.setupError {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                            .padding(.bottom)
                    }

                    // Start/Stop Button (Example Control)
                    Button {
                        if viewModel.isSessionRunning {
                            viewModel.stopSession()
                        } else {
                            viewModel.startSession()
                        }
                    } label: {
                        Image(systemName: viewModel.isSessionRunning ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(viewModel.isSessionRunning ? .red : .green)
                    }
                    .padding(.bottom)
                  //  .disabled(viewModel.setupResult != .success) // Disable if setup failed or pending

                } // End VStack for Controls

                // Permission Handling Overlay
                permissionOverlay()

            } // End ZStack
            .navigationTitle("AVFoundation Demo")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.checkPermissions() // Initiate permission check and setup on appear
            }
            .onDisappear {
                viewModel.stopSession() // Stop session when view disappears
            }
        } // End NavigationView
    }

    // Helper view for permission status overlay
    @ViewBuilder
    private func permissionOverlay() -> some View {
        switch viewModel.authorizationStatus {
        case .notDetermined:
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack {
                Text("Camera access is required.")
                    .foregroundColor(.white)
                Button("Grant Permission") {
                     //checkPermissions will call requestPermission if needed
                     viewModel.checkPermissions()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        case .denied, .restricted:
             if viewModel.setupError != nil { // Only show if setup failed due to permissions
                  Color.black.opacity(0.7).ignoresSafeArea()
                  VStack(spacing: 10) {
                       Text("Camera Access Required")
                            .font(.title2)
                            .foregroundColor(.white)
                       Text(viewModel.setupError?.localizedDescription ?? "Permission issue")
                           .foregroundColor(.white.opacity(0.8))
                           .multilineTextAlignment(.center)
                       Button("Open Settings") {
                           // Direct user to settings
                           if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                               UIApplication.shared.open(url)
                           }
                       }
                       .buttonStyle(.bordered)
                       .padding()
                  }
                  .padding()
             } else {
                 EmptyView() // Don't show overlay if error isn't permissions related
             }
        case .authorized:
            EmptyView() // No overlay needed
        @unknown default:
            EmptyView()
        }
    }
}

// MARK: - Preview Provider
#Preview {
    CameraContentView()
}
