//
//  ContentView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI
@preconcurrency import AVFoundation
import Photos // Needed to save photos or check permissions later (optional for now)
import Combine // Needed for Cancellable

// MARK: - Camera Manager (ObservableObject)

@MainActor
class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate { // Conform to delegate

    // MARK: - Status Enums
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }

    enum CameraPosition {
        case front
        case back
    }

    enum FlashMode {
        case on
        case off
        case auto

        var avFlashMode: AVCaptureDevice.FlashMode {
            switch self {
            case .on: return .on
            case .off: return .off
            case .auto: return .auto
            }
        }

        var icon: String {
            switch self {
            case .on: return "bolt.fill"
            case .off: return "bolt.slash.fill"
            case .auto: return "bolt.badge.a.fill"
            }
        }
    }

    // MARK: - Published Properties
    @Published var status = Status.unconfigured
    @Published var error: CameraError? = nil
    @Published var capturedImageData: Data? = nil // To hold the captured image data
    @Published var isCapturingPhoto = false // To disable UI during capture
    @Published var currentPosition: CameraPosition = .back // Track current camera
    @Published var flashMode: FlashMode = .off // Current flash mode
    @Published var isFlashAvailable = false // If flash is available on current device

    // MARK: - Private Properties
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.yourapp.sessionQueue")
    private let photoOutput = AVCapturePhotoOutput() // Specific output for photos
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var currentDevice: AVCaptureDevice? { videoDeviceInput?.device }
    private var cancellables = Set<AnyCancellable>() // To observe position changes

    // MARK: - Initialization
    override init() {
        super.init()
        checkPermissions()
        // Observe position change to update flash availability
        $currentPosition
            .receive(on: RunLoop.main) // Ensure updates happen on main thread
            .sink { [weak self] _ in
                self?.updateFlashAvailability()
            }
            .store(in: &cancellables)
    }

    // MARK: - Permissions
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCaptureSession()
        case .notDetermined:
            status = .unconfigured
        case .denied, .restricted:
            status = .unauthorized
            setError(.permissionDenied)
        @unknown default:
            status = .unauthorized
            setError(.unknownPermissionStatus)
        }
    }

    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor [weak self] in // Dispatch back to main actor
                guard let self = self else { return }
                if granted {
                    self.configureCaptureSession()
                } else {
                    self.status = .unauthorized
                    self.setError(.permissionDenied)
                }
            }
        }
    }

    // MARK: - Session Configuration
    private func configureCaptureSession() {
        guard status != .configured else {
            print("Camera session already configured.")
            // If already configured, just ensure session starts if needed
             if !session.isRunning && AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                 startSession()
             }
            return
        }
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            status = .unauthorized
            setError(.permissionDenied)
            return
        }

        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo // Optimize for photo capture

            // --- Input Setup ---
            guard self.setupInput() else {
                self.session.commitConfiguration() // Commit even on failure
                return // Errors set within setupInput
            }

            // --- Output Setup ---
            guard self.session.canAddOutput(self.photoOutput) else {
                 // Use MainActor task to update published properties
                Task { @MainActor in
                     self.setError(.cannotAddOutput)
                     self.status = .failed
                }
                self.session.commitConfiguration()
                return
            }
            self.session.addOutput(self.photoOutput)
            self.photoOutput.isHighResolutionCaptureEnabled = true // Enable high-res photos

            // --- Finalize Configuration ---
            self.session.commitConfiguration()

            // --- Update Status & Start ---
            Task { @MainActor in
                self.status = .configured
                self.error = nil
                self.updateFlashAvailability() // Check flash after setup
                print("Camera session configured successfully for \(self.currentPosition).")
                // Start session after configuring
                 self.startSession()
            }
        }
    }

    // Helper to setup input based on currentPosition
    private func setupInput() -> Bool {
        // Find device based on currentPosition
        let desiredPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .back : .front
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: desiredPosition) else {
            Task { @MainActor in
                self.setError(.deviceUnavailable(self.currentPosition))
                self.status = .failed }
            return false
        }

        // Remove existing input
        if let currentInput = self.videoDeviceInput {
            self.session.removeInput(currentInput)
            self.videoDeviceInput = nil
        }

        // Create and add new input
        do {
            let videoInput = try AVCaptureDeviceInput(device: device)
            guard self.session.canAddInput(videoInput) else {
                Task { @MainActor in
                    self.setError(.cannotAddInput)
                    self.status = .failed
                }
                return false
            }
            self.session.addInput(videoInput)
            self.videoDeviceInput = videoInput // Store the current input
            return true
        } catch {
            Task { @MainActor in
                self.setError(.createInputFailed(error))
                self.status = .failed
            }
            return false
        }
    }

    // MARK: - Session Control
    func startSession() {
         guard status == .configured else {
             print("Cannot start session, not configured or not authorized.")
             // Attempt configuration if status is suitable
             if status == .unconfigured && AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                 configureCaptureSession()
             } else if status == .unauthorized {
                 setError(.permissionDenied)
             }
             return
         }

        sessionQueue.async { [weak self] in
            guard let self = self, !self.session.isRunning else { return }
            self.session.startRunning()
            print("Camera session explicitly started.")
        }
    }

    func stopSession() {
        // Don't stop if configuring or unconfigured
         guard session.isRunning else { return }
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
            print("Camera session stopped.")
        }
    }

    // MARK: - Camera Actions

    func switchCamera() {
        guard status == .configured else { return } // Only switch if configured

        // Toggle position
        let newPosition: CameraPosition = (currentPosition == .back) ? .front : .back
        
        // Check if the new position is available
        let desiredAVPosition: AVCaptureDevice.Position = (newPosition == .back) ? .back : .front
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: desiredAVPosition) != nil else {
             print("Camera position \(newPosition) not available.")
             // Optionally set an error or provide user feedback here
             setError(.deviceUnavailable(newPosition))
             return
        }

        // Update position and reconfigure on background queue
        sessionQueue.async { [weak self] in
             guard let self = self else { return }
            
             // Update published property on Main Thread *before* reconfiguration starts
             Task { @MainActor in
                 self.currentPosition = newPosition
                 self.isFlashAvailable = false // Temporarily set flash unavailable
             }
             
            self.session.beginConfiguration()
            
            // Re-setup input
            guard self.setupInput() else {
                // Error handled in setupInput
                self.session.commitConfiguration() // Commit even on failure
                return
            }
            
            self.session.commitConfiguration()
            
            // Update flash availability after successful reconfiguration
             Task { @MainActor in
                self.updateFlashAvailability()
                print("Switched camera to \(newPosition).")
            }
        }
    }

    func capturePhoto() {
        guard status == .configured, !isCapturingPhoto else {
            print("Cannot capture photo. Status: \(status), Capturing: \(isCapturingPhoto)")
            return
        }
        guard let photoOutputConnection = photoOutput.connection(with: .video) else {
            setError(.captureFailed(nil, reason: "Photo output connection unavailable."))
            return
        }

        Task { @MainActor in // Set capturing state on main thread
             self.isCapturingPhoto = true
             self.capturedImageData = nil // Clear previous image
             self.error = nil // Clear previous errors
         }

        sessionQueue.async { [weak self] in // Perform capture setup off main thread
            guard let self = self else { return }

            // Configure Photo Settings
            let photoSettings = AVCapturePhotoSettings()

            // Set flash mode if device supports it
           if let device = self.currentDevice, device.hasFlash, device.isFlashAvailable {
                photoSettings.flashMode = self.flashMode.avFlashMode
           } else {
                // Handle case where user wants flash but device doesn't support/isn't available
                 if self.flashMode == .on {
                     print("Warning: Flash requested but not available/supported.")
                     // Optionally set an error or ignore
                 }
                 photoSettings.flashMode = .off // Default to off if unavailable
           }

            // Set high resolution if desired and supported
            if self.photoOutput.isHighResolutionCaptureEnabled {
                photoSettings.isHighResolutionPhotoEnabled = true
            }
            
            // Set preview orientation based on current UI orientation
             Task { @MainActor in // Need UI orientation, get on main actor
                 if let videoOrientation = CameraPreviewView.currentOrientation() {
                    photoOutputConnection.videoOrientation = videoOrientation
                 }
             }

            // Capture the photo
            print("Attempting photo capture with flash: \(photoSettings.flashMode)")
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    // MARK: - Flash Control
    private func updateFlashAvailability() {
        sessionQueue.async { [weak self] in // Check device properties on session queue
            guard let self = self, let device = self.currentDevice else { return }
            let available = device.hasFlash && device.isFlashAvailable
             Task { @MainActor in // Update published property on main thread
                 self.isFlashAvailable = available
                 // If flash becomes unavailable, reset mode to off
                 if !available && self.flashMode != .off {
                    self.flashMode = .off
                 }
             }
        }
    }

    func cycleFlashMode() {
        guard isFlashAvailable else { return } // Only cycle if flash is available
        Task { @MainActor in // Update published property on main thread
            switch flashMode {
            case .off: flashMode = .on
            case .on: flashMode = .auto
            case .auto: flashMode = .off
            }
             print("Flash mode set to: \(flashMode)")
        }
    }

    // MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
         Task { @MainActor in // Ensure updates are on main thread
             self.isCapturingPhoto = false // Reset capturing state

             if let error = error {
                 print("Error capturing photo: \(error)")
                 setError(.captureFailed(error))
                 return
             }

             guard let imageData = photo.fileDataRepresentation() else {
                 print("Could not get image data representation.")
                 setError(.captureFailed(nil, reason: "Could not get image data."))
                 return
             }

             print("Photo captured successfully. Size: \(imageData.count) bytes")
             self.capturedImageData = imageData
             self.error = nil // Clear errors on success
         }
     }

     // Optional: Handle capture start/finish for feedback (e.g., shutter sound, animation)
     // func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) { ... }
     // func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) { ... }

    // MARK: - Error Handling
    private func setError(_ error: CameraError) {
        Task { @MainActor in // Ensure UI updates happen on MainActor thread
            self.error = error
            print("Camera Error: \(error.localizedDescription)")
            // Also set status to failed if it's a setup/configuration error
            switch error {
            case .cannotAddInput, .cannotAddOutput, .createInputFailed, .deviceUnavailable, .sessionFailed:
                 self.status = .failed
            case .permissionDenied, .unknownPermissionStatus:
                 self.status = .unauthorized
            case .captureFailed:
                // Keep status as configured unless it's a fatal session error
                break
            }
        }
    }
}

// MARK: - Camera Error Enum (Expanded)
enum CameraError: Error, LocalizedError, Equatable {
    static func == (lhs: CameraError, rhs: CameraError) -> Bool {
        return true
    }
    
    case permissionDenied
    case unknownPermissionStatus
    case deviceUnavailable(CameraManager.CameraPosition) // Specify which camera failed
    case cannotAddInput
    case cannotAddOutput
    case createInputFailed(Error)
    case sessionFailed(Error) // Generic session runtime error
    case captureFailed(Error?, reason: String? = nil) // Photo capture specific error

    var errorDescription: String? {
        switch self {
        case .permissionDenied, .unknownPermissionStatus:
            return "Camera permissions are required."
        case .deviceUnavailable(let position):
            return "\(position == .back ? "Back" : "Front") camera is not available."
        case .cannotAddInput:
            return "Cannot add camera input."
        case .cannotAddOutput:
            return "Cannot add camera output."
        case .createInputFailed(let error):
            return "Failed to create camera input: \(error.localizedDescription)"
        case .sessionFailed(let error):
            return "Camera session failed: \(error.localizedDescription)"
        case .captureFailed(let underlyingError, let reason):
             var baseMessage = "Failed to capture photo."
             if let reason = reason { baseMessage += " \(reason)" }
             if let underlyingError = underlyingError { baseMessage += " Error: \(underlyingError.localizedDescription)" }
             return baseMessage
        }
    }

    var recoverySuggestion: String? {
         switch self {
         case .permissionDenied, .unknownPermissionStatus:
            return "Please grant camera access in iPhone Settings > Privacy & Security > Camera."
         case .deviceUnavailable, .cannotAddInput, .cannotAddOutput, .createInputFailed, .sessionFailed:
            return "An internal camera error occurred. Please try restarting the app."
         case .captureFailed:
             return "Could not capture the photo. Please try again."
         }
     }
}

// MARK: - Camera Preview (UIViewRepresentable) - *Now Static Helper Added*

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    static func currentOrientation() -> AVCaptureVideoOrientation? {
         guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
             // Cannot get scene, fallback or return nil/default
             print("Warning: Could not get UIWindowScene for orientation.")
             return .portrait // Or return nil if you handle that case
         }
         // Access orientation directly after getting the scene
         let orientation = scene.interfaceOrientation

         switch orientation {
         case .portrait: return .portrait
         case .landscapeLeft: return .landscapeLeft // Check if these map correctly for AVCaptureVideoOrientation
         case .landscapeRight: return .landscapeRight // Check if these map correctly for AVCaptureVideoOrientation
         case .portraitUpsideDown: return .portraitUpsideDown
         case .unknown:
              print("Warning: Unknown interface orientation.")
              return nil // Handle unknown explicitly
         @unknown default:
             print("Warning: Unhandled default interface orientation.")
             return nil // Handle future cases
         }
     }


    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        if let initialOrientation = CameraPreviewView.currentOrientation() {
             previewLayer.connection?.videoOrientation = initialOrientation
        }

        view.layer.addSublayer(previewLayer)
        objc_setAssociatedObject(view, &AssociatedKeys.previewLayer, previewLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = objc_getAssociatedObject(uiView, &AssociatedKeys.previewLayer) as? AVCaptureVideoPreviewLayer {
             previewLayer.frame = uiView.bounds
            
             // Update orientation dynamically
             if let currentOrientation = CameraPreviewView.currentOrientation() {
                previewLayer.connection?.videoOrientation = currentOrientation
             }
        }
    }

    private struct AssociatedKeys {
        static var previewLayer = "previewLayer"
    }
}

// MARK: - SwiftUI Camera View (Enhanced)

struct CameraView: View {
    // Allow cameraManager to be injected OR created internally
    @StateObject private var cameraManager: CameraManager

    // Initializer for previews/dependency injection
     init(cameraManager: CameraManager? = nil) { // Make parameter optional
         // If a manager is provided, use it. Otherwise, create a default one.
         // This uses the correct way to initialize StateObject with a pre-existing value.
         _cameraManager = StateObject(wrappedValue: cameraManager ?? CameraManager())
     }
    
    @State private var showCapturedPhoto = false // State to control showing the captured photo view

    var body: some View {
        NavigationView { // Embed in NavigationView for potential title/bar usage
            ZStack {
                // --- Camera Preview Layer ---
                cameraPreview
                    .ignoresSafeArea()
                    .onAppear {
                         #if !targetEnvironment(simulator) // Don't start session on simulator
                         cameraManager.startSession()
                         #endif
                    }
                    .onDisappear {
                         #if !targetEnvironment(simulator)
                         cameraManager.stopSession()
                         #endif
                    }
                    // Lifecycle handling - Keep as before
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                         #if !targetEnvironment(simulator)
                         cameraManager.startSession()
                         #endif
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                         #if !targetEnvironment(simulator)
                         cameraManager.stopSession()
                         #endif
                    }

                // --- UI Overlay ---
                overlayView

                // --- Captured Photo Display ---
                if showCapturedPhoto, let imageData = cameraManager.capturedImageData, let uiImage = UIImage(data: imageData) {
                    CapturedPhotoView(image: uiImage) { usePhoto in
                         showCapturedPhoto = false // Dismiss the view
                         if usePhoto {
                             // Handle using the photo (e.g., save, upload, pass to next screen)
                             print("User chose to use the photo.")
                            // Example: Save to photo library
                            // savePhotoToLibrary(imageData: imageData)
                         } else {
                             print("User chose to retake.")
                         }
                          cameraManager.capturedImageData = nil // Clear image data after decision
                     }
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity)) // Nice transition
                    .zIndex(10) // Ensure it's on top
                }
            }
            .navigationTitle("Camera") // Example title
            .navigationBarHidden(true) // Hide for full screen camera feel
        }

         // --- Trigger Captured Photo View ---
         .onChange(of: cameraManager.capturedImageData) { newData in
            if newData != nil {
                 withAnimation { // Animate the appearance
                     showCapturedPhoto = true
                 }
            }
         }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var cameraPreview: some View {
        if cameraManager.status == .configured {
            CameraPreviewView(session: cameraManager.session)
        } else {
            // Keep placeholder consistent
            Color.black
                 .overlay(alignment: .center) {
                      statusOverlay // Show status even on black background
                 }
        }
    }

    private var overlayView: some View {
        VStack {
             // --- Top Controls (Flash) ---
             if cameraManager.status == .configured {
                 HStack {
                      Spacer()
                      flashButton
                 }
                 .padding(.top, 20) // Adjust for safe area if needed
                 .padding(.horizontal)
             }

            Spacer() // Pushes controls to bottom

            // --- Status/Error Overlay ---
            statusOverlay
                 .padding(.bottom, cameraManager.status == .configured ? 0 : 50) // Only pad if controls aren't showing

            // --- Bottom Controls (Capture, Switch) ---
             if cameraManager.status == .configured {
                 bottomControls
                     .padding(.bottom, 40) // More padding for home indicator area
             }
        }
    }

    @ViewBuilder
    private var statusOverlay: some View {
        Group {
             switch cameraManager.status {
             case .unconfigured:
                 permissionRequestView
             case .unauthorized:
                 permissionDeniedView
             case .failed:
                 errorView
             case .configured:
                  // Show capture error specifically if it occurred
                  if let error = cameraManager.error, case .captureFailed = error {
                     captureErrorView
                  } else {
                      EmptyView() // Normal configured state, no persistent overlay needed
                  }
             }
        }
        .padding(15)
        .frame(maxWidth: .infinity) // Allow background to span width
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(.horizontal, 20) // Padding for the overlay box itself
         // Add shadow for better separation
         .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
         .opacity(cameraManager.status == .configured && cameraManager.error == nil ? 0 : 1) // Hide if configured and no error
         .animation(.easeInOut, value: cameraManager.status)
         .animation(.easeInOut, value: cameraManager.error)

    }

    private var bottomControls: some View {
        HStack(spacing: 50) {
            // Placeholder for symmetry or future controls (e.g., gallery shortcut)
             Spacer()
//            Button { /* Gallery action */ } label: {
//                Image(systemName: "photo.on.rectangle")
//                    .font(.title)
//                    .foregroundColor(.white)
//            }
//            .opacity(0.5) // Example disabled look

            takePhotoButton

            switchCameraButton
             Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Control Buttons

    private var takePhotoButton: some View {
        Button {
            cameraManager.capturePhoto()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)

                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 80, height: 80)
            }
        }
        .disabled(cameraManager.isCapturingPhoto) // Disable while capturing
        .opacity(cameraManager.isCapturingPhoto ? 0.5 : 1.0) // Visual feedback
    }

    private var switchCameraButton: some View {
        Button {
            cameraManager.switchCamera()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                .font(.system(size: 28)) // Slightly larger icon
                .foregroundColor(.white)
                .padding(15) // Increase tap area
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
        }
    }

    private var flashButton: some View {
       Button {
           cameraManager.cycleFlashMode()
       } label: {
            Image(systemName: cameraManager.flashMode.icon)
               .font(.system(size: 20))
               .foregroundColor(cameraManager.isFlashAvailable ? .yellow : .gray) // Yellow if on/auto, Gray if off/unavailable
               .padding(10)
               .background(Color.black.opacity(0.3))
               .clipShape(Circle())
       }
       .disabled(!cameraManager.isFlashAvailable) // Disable if flash unavailable
   }

    // MARK: - Helper Views for Status (Mostly Unchanged, Added Capture Error)

    private var permissionRequestView: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.viewfinder").font(.largeTitle).padding(.bottom, 5)
            Text("Camera Access Needed")
                .font(.headline)
            Text("Grant camera access to capture photos.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("Grant Permission") {
                cameraManager.requestPermission()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 5)
        }
    }

    private var permissionDeniedView: some View {
         VStack(spacing: 12) {
             Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundColor(.orange).padding(.bottom, 5)
             Text("Camera Access Denied")
                 .font(.headline)
             Text(cameraManager.error?.recoverySuggestion ?? "Grant camera access in Settings.")
                 .font(.subheadline)
                 .multilineTextAlignment(.center)
                 .foregroundColor(.secondary)
             if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                 Button("Open Settings") {
                     UIApplication.shared.open(url)
                 }
                 .buttonStyle(.bordered)
                 .padding(.top, 5)
             }
         }
     }

    private var errorView: some View {
        VStack(spacing: 10) {
             Image(systemName: "exclamationmark.octagon.fill").font(.largeTitle).foregroundColor(.red).padding(.bottom, 5)
             Text("Camera Error")
                 .font(.headline)
             Text(cameraManager.error?.errorDescription ?? "An unknown camera error occurred.")
                 .font(.subheadline)
                 .multilineTextAlignment(.center)
                 .foregroundColor(.secondary)
            Text(cameraManager.error?.recoverySuggestion ?? "Please try again.")
                .font(.caption).foregroundColor(.gray)
         }
     }

     private var captureErrorView: some View { // Specific view for capture errors
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill").font(.title2).foregroundColor(.red)
            Text("Capture Failed")
                 .font(.headline)
            Text(cameraManager.error?.errorDescription ?? "Could not capture photo.")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
            Text(cameraManager.error?.recoverySuggestion ?? "Please try again.")
                .font(.caption).foregroundColor(.gray)
         }
          // Automatically dismiss after a delay? Optional.
         .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                  // Only clear if the error is still the same capture error
                  if case .captureFailed = cameraManager.error {
                      cameraManager.error = nil
                  }
              }
          }
     }

    // Example function to save photo (requires Info.plist key: NSPhotoLibraryAddUsageDescription)
     /*
    private func savePhotoToLibrary(imageData: Data) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: imageData, options: nil)
                }) { success, error in
                    if success {
                        print("Photo saved successfully!")
                        // Optional: Show feedback to user
                    } else if let error = error {
                        print("Error saving photo: \(error)")
                        // setError requires @MainActor, dispatch if needed
                         Task { @MainActor in
                             // Maybe set a transient error message?
                             // self.cameraManager.error = .someOtherError("Failed to save photo.")
                         }
                    }
                }
            } else {
                print("Photo library access denied (add only).")
                 Task { @MainActor in
                     // self.cameraManager.error = .someOtherError("Photo library access denied.")
                 }
            }
        }
    }
     */
}

// MARK: - Captured Photo View (New)

struct CapturedPhotoView: View {
    let image: UIImage
    let action: (Bool) -> Void // Callback: true = use photo, false = retake

    var body: some View {
         GeometryReader { geo in
             ZStack {
                 // Dimmed Background
                  Color.black.opacity(0.85).ignoresSafeArea()

                 VStack {
                     // Display the Captured Image
                     Image(uiImage: image)
                         .resizable()
                         .scaledToFit()
                         .frame(maxWidth: geo.size.width * 0.95, maxHeight: geo.size.height * 0.7)
                         .cornerRadius(10)
                         .padding(.top, 40)

                     Spacer() // Push buttons to bottom

                     // Action Buttons
                     HStack(spacing: 30) {
                         Button {
                             action(false) // Retake
                         } label: {
                             Text("Retake")
                                 .font(.headline)
                                 .foregroundColor(.white)
                                 .padding(.vertical, 15)
                                 .padding(.horizontal, 30)
                                 .background(Color.red)
                                 .cornerRadius(10)
                         }

                         Button {
                             action(true) // Use Photo
                         } label: {
                             Text("Use Photo")
                                 .font(.headline)
                                 .foregroundColor(.white)
                                 .padding(.vertical, 15)
                                 .padding(.horizontal, 30)
                                 .background(Color.blue)
                                 .cornerRadius(10)
                         }
                     }
                     .padding(.bottom, 50)
                 }
             }
         }
    }
}

// MARK: - Preview Provider (Updated)
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        // --- Default Preview (Simulates Configured State) ---
         CameraView(cameraManager: createPreviewManager(status: .configured, isFlashAvailable: true))
             .previewDisplayName("Configured")

         // --- Unconfigured State ---
         CameraView(cameraManager: createPreviewManager(status: .unconfigured))
             .previewDisplayName("Unconfigured")

         // --- Unauthorized State ---
         CameraView(cameraManager: createPreviewManager(status: .unauthorized, error: .permissionDenied))
             .previewDisplayName("Unauthorized")

        // --- Failed State ---
         CameraView(cameraManager: createPreviewManager(status: .failed, error: .deviceUnavailable(.back)))
            .previewDisplayName("Failed (Device)")

        // --- Capture Error State ---
        CameraView(cameraManager: createPreviewManager(status: .configured, error: .captureFailed(nil, reason: "Simulated Capture Error")))
            .previewDisplayName("Capture Error")

        // --- Captured Photo View Preview ---
          CapturedPhotoView(image: UIImage(systemName: "photo")!) { _ in }
             .previewDisplayName("Captured Photo")

        // --- Preview with Flash ON ---
        CameraView(cameraManager: createPreviewManager(status: .configured, flashMode: .on, isFlashAvailable: true))
            .previewDisplayName("Flash ON")
    }

    // Helper for creating preview managers
    static func createPreviewManager(status: CameraManager.Status,
                                    error: CameraError? = nil,
                                    flashMode: CameraManager.FlashMode = .off,
                                    isFlashAvailable: Bool = false) -> CameraManager {
         let manager = CameraManager()
         // Set properties *after* init to simulate states
          Task { @MainActor in // Ensure these @Published updates happen correctly for previews
             manager.status = status
             manager.error = error
             manager.flashMode = flashMode
             manager.isFlashAvailable = isFlashAvailable
         }
         return manager
     }
}
