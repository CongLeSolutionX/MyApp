////
////  ContenView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/11/25.
////
//
//import SwiftUI
//import AVFoundation
//import Photos
//import Combine
//
//// MARK: - Camera Manager (ObservableObject)
//
//@MainActor
//class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//
//    // MARK: - Status Enums
//    enum Status {
//        case unconfigured
//        case configured
//        case unauthorized
//        case failed
//    }
//
//    enum CameraPosition {
//        case front
//        case back
//    }
//
//    enum FlashMode {
//        case on
//        case off
//        case auto
//
//        var avFlashMode: AVCaptureDevice.FlashMode {
//            switch self {
//            case .on: return .on
//            case .off: return .off
//            case .auto: return .auto
//            }
//        }
//
//        var icon: String {
//            switch self {
//            case .on: return "bolt.fill"
//            case .off: return "bolt.slash.fill"
//            case .auto: return "bolt.badge.a.fill"
//            }
//        }
//    }
//
//    // MARK: - Published Properties
//    @Published var status = Status.unconfigured
//    @Published var error: CameraError? = nil
//    @Published var capturedImageData: Data? = nil
//    @Published var isCapturingPhoto = false
//    @Published var currentPosition: CameraPosition = .back
//    @Published var flashMode: FlashMode = .off
//    @Published var isFlashAvailable = false
//
//    // MARK: - Private Properties
//    // Session and Output MUST be accessed only from the session queue OR MainActor after setup
//    // Making them private ensures controlled access via methods.
//    private let session = AVCaptureSession()
//    private let photoOutput = AVCapturePhotoOutput()
//
//    // This queue handles all AVFoundation setup/teardown/capture calls
//    private let sessionQueue = DispatchQueue(label: "com.yourapp.sessionQueue", qos: .userInitiated)
//
//    // Keep track of the device input for easy removal/access
//    private var videoDeviceInput: AVCaptureDeviceInput?
//    private var currentDevice: AVCaptureDevice? { videoDeviceInput?.device } // Computed property remains MainActor isolated
//
//    private var cancellables = Set<AnyCancellable>()
//
//    // MARK: - Initialization
//    override init() {
//        super.init()
//        // Initialize status immediately
//        checkPermissionsSync() // Sync check for initial status
//        observePositionChange()
//        // Defer configuration until permission is confirmed and view appears
//    }
//
//    private func observePositionChange() {
//         // Observing @Published properties should happen on the MainActor context implicitly
//        $currentPosition
//            .sink { [weak self] _ in
//                // Update flash availability whenever position changes
//                 // Dispatch check to session queue, update UI back on MainActor
//                self?.updateFlashAvailability()
//            }
//            .store(in: &cancellables)
//    }
//
//    // MARK: - Permissions (Synchronous Check for Initial State)
//    private func checkPermissionsSync() {
//         switch AVCaptureDevice.authorizationStatus(for: .video) {
//         case .authorized:
//             // Don't configure yet, wait for view appearance or explicit call
//             status = .unconfigured // Treat as unconfigured until startConfigure is called
//         case .notDetermined:
//             status = .unconfigured
//         case .denied, .restricted:
//             status = .unauthorized
//             setError(.permissionDenied) // OK to set error here, MainActor property access
//         @unknown default:
//             status = .unauthorized
//             setError(.unknownPermissionStatus) // OK here
//         }
//     }
//
//    // MARK: - Permissions (Asynchronous Request)
//    func requestPermission() async -> Bool {
//          // Already authorized
//          if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
//              return true
//          }
//
//          // Check if undetermined, otherwise it's denied/restricted
//          guard AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined else {
//               await MainActor.run { // Ensure status update is on MainActor
//                  self.status = .unauthorized
//                  self.setError(.permissionDenied)
//              }
//              return false
//          }
//
//          // Request access
//          let granted = await AVCaptureDevice.requestAccess(for: .video)
//
//          await MainActor.run { // Switch back to MainActor to update published properties
//              if granted {
//                  // Don't configure immediately, let startConfigure handle it
//                  // Do we need to update status here? Maybe not, let configure handle it.
//                  // self.status = .unconfigured // Ready to be configured
//                  print("Permission granted.")
//              } else {
//                  self.status = .unauthorized
//                  self.setError(.permissionDenied)
//                  print("Permission denied.")
//              }
//          }
//          return granted
//      }
//
//    // MARK: - Session Configuration
//
//    // Public method to initiate configuration (call from onAppear or after permission grant)
//    func startConfiguration() {
//        guard status == .unconfigured || status == .configured else { // Allow re-configuration if already configured but maybe stopped
//             print("Cannot configure. Status: \(status). Checking permissions...")
//             checkPermissionsSync() // Re-check permissions if in wrong state
//             if status == .unauthorized { return } // Still not authorized
//             if status == .failed { return } // Don't retry if failed previously without reset
//             // If it became authorized, we can proceed now
//             guard status == .unconfigured else { return }
//             return
//        }
//
//        // Ensure permissions one last time
//        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
//            Task { @MainActor in // Ensure main thread update
//                self.status = .unauthorized
//                self.setError(.permissionDenied)
//                print("Configuration aborted: Permission not authorized.")
//            }
//            return
//        }
//
//        // Start configuration on the background queue
//        sessionQueue.async { [weak self] in
//            self?.performConfiguration()
//        }
//    }
//
//    // Private method performing actual configuration on sessionQueue
//    private func performConfiguration() {
//        // Make sure weak self is valid
//        // guard let self = self else { return }
//
//        // --- PRE-CONFIGURATION CHECK ---
//        // Check if session is already running; potentially stop it before reconfiguring?
//         // This depends on desired behavior. For simplicity, we assume it's not running or ok to configure while running.
//
//         // --- BEGIN CONFIGURATION ---
//         print("Session Queue: Starting configuration...")
//         self.session.beginConfiguration()
//         defer {
//             self.session.commitConfiguration()
//             print("Session Queue: Committed configuration.")
//         }
//
//        // --- SESSION PRESET ---
//        self.session.sessionPreset = .photo // Optimize for photo capture
//
//        // --- INPUT SETUP ---
//        guard self.setupInputDevice() else {
//             // Error is set within setupInputDevice
//             // Configuration is committed via defer
//             print("Session Queue: Input setup failed.")
//             return
//         }
//
//        // --- OUTPUT SETUP ---
//        guard self.session.canAddOutput(self.photoOutput) else {
//             Task { @MainActor in // Dispatch error setting back to main actor
//                self.setError(.cannotAddOutput)
//                self.status = .failed
//                print("Configuration failed: Cannot add photo output.")
//             }
//             return
//        }
//        self.session.addOutput(self.photoOutput)
//
//        // --- PHOTO OUTPUT SETTINGS (Modern Approach) ---
//         // 'isHighResolutionCaptureEnabled' is deprecated. Instead, rely on maxPhotoDimensions in settings.
//         // We don't set properties on photoOutput itself here anymore regarding resolution.
//
//        // --- FINALIZE & UPDATE STATUS ---
//         Task { @MainActor in // Dispatch status updates back to main actor
//            self.status = .configured
//            self.error = nil // Clear previous errors on successful configuration
//            print("Camera session configured successfully for \(self.currentPosition).")
//            // Start session after configuration ONLY if it's not already running
//            if !self.session.isRunning {
//                self.startSessionInternal() // Call internal start on session queue
//            }
//            // Update flash availability after configuration completes on main actor
//            self.updateFlashAvailability()
//         }
//    }
//
//    // Helper to setup input device (MUST be called from sessionQueue)
//    private func setupInputDevice() -> Bool {
//         let desiredPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .back : .front
//         guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: desiredPosition) else {
//              Task { @MainActor in // Dispatch error setting back to main actor
//                 self.setError(.deviceUnavailable(self.currentPosition))
//                 self.status = .failed
//                 print("Input setup failed: Device unavailable.")
//             }
//             return false
//         }
//
//         // Remove existing input if present
//          // Accessing videoDeviceInput here IS accessing a MainActor property from nonisolated.
//          // BUT we are just reading it here to pass to session.removeInput, which is likely okay IF
//          // videoDeviceInput is only ever mutated on the sessionQueue during config.
//          // Let's ensure videoDeviceInput assignment happens correctly.
//          // For safety, grab the current input BEFORE potentially updating self.videoDeviceInput.
//          let currentInput = self.videoDeviceInput
//          if let inputToRemove = currentInput {
//              self.session.removeInput(inputToRemove)
//              print("Session Queue: Removed existing video input.")
//          }
//
//         // Create and add new input
//         do {
//             let videoInput = try AVCaptureDeviceInput(device: device)
//             guard self.session.canAddInput(videoInput) else {
//                 Task { @MainActor in // Dispatch error setting back to main actor
//                     self.setError(.cannotAddInput)
//                     self.status = .failed
//                     print("Input setup failed: Cannot add new video input.")
//                 }
//                 return false
//             }
//             self.session.addInput(videoInput)
//             print("Session Queue: Added new video input for \(desiredPosition).")
//
//             // Update the stored input property *synchronously* on the session queue
//             // This is safe because we only access/mutate it during configuration on this queue
//             // OR read it from main actor where needed.
//             self.videoDeviceInput = videoInput // *Correction:* This is still mutating MainActor property
//             // Safest: Dispatch assignment back.
//             Task { @MainActor in
//                self.videoDeviceInput = videoInput
//             }
//
//             return true
//         } catch {
//              Task { @MainActor in // Dispatch error setting back to main actor
//                 self.setError(.createInputFailed(error))
//                 self.status = .failed
//                 print("Input setup failed: Error creating AVCaptureDeviceInput - \(error)")
//             }
//             return false
//         }
//     }
//
//    // MARK: - Session Control
//
//    func startSession() {
//        // Public facing start - ensures configuration happens first if needed
//        if status != .configured {
//             print("Start requested but not configured. Attempting configuration...")
//             startConfiguration() // Attempt config; it will start session if successful
//             return
//        }
//        // If already configured, ensure start happens on the session queue
//        startSessionInternal()
//    }
//
//    private func startSessionInternal() {
//         // Internal start, assumes already configured and called from appropriate context
//          // (either after config on sessionQueue, or dispatched TO sessionQueue)
//         sessionQueue.async { [weak self] in
//              guard let self = self else { return }
//              guard self.status == .configured else { // Double check status on session queue
//                 print("Session Queue: Cannot start session, status is \(self.status).")
//                 return
//             }
//              guard !self.session.isRunning else {
//                 print("Session Queue: Session already running.")
//                 return
//             }
//             print("Session Queue: Starting session...")
//             self.session.startRunning()
//             print("Session Queue: Session started.")
//         }
//     }
//
//    func stopSession() {
//        // Stop session only if it's actually configured and running
//        guard status == .configured && session.isRunning else {
//             print("Stop requested but session not running or not configured.")
//             return
//         }
//        sessionQueue.async { [weak self] in
//            guard let self = self else { return }
//            if self.session.isRunning { // Check again on the queue
//                 print("Session Queue: Stopping session...")
//                 self.session.stopRunning()
//                 print("Session Queue: Session stopped.")
//             }
//        }
//    }
//
//    // MARK: - Camera Actions
//
//    func switchCamera() {
//        guard status == .configured else {
//            print("Cannot switch camera, not configured.")
//            return
//        }
//
//        // Determine the new position optimistically
//         let newPosition: CameraPosition = (currentPosition == .back) ? .front : .back
//         let desiredAVPosition: AVCaptureDevice.Position = (newPosition == .back) ? .back : .front
//
//        // Pre-check availability on the main thread (quick check)
//         guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: desiredAVPosition) != nil else {
//             print("Camera position \(newPosition) not available.")
//             setError(.deviceUnavailable(newPosition)) // Already on MainActor
//             return
//         }
//
//        // Dispatch the actual switching logic to the session queue
//        sessionQueue.async { [weak self] in
//            guard let self = self else { return }
//
//            // Update published position optimistically on MainActor BEFORE reconfiguration
//             Task { @MainActor in
//                 self.currentPosition = newPosition
//                 self.isFlashAvailable = false // Temporarily disable/reset flash UI
//             }
//
//            // --- Perform reconfiguration on session queue ---
//            self.session.beginConfiguration()
//             defer { self.session.commitConfiguration() }
//
//            // Re-setup input device
//             guard self.setupInputDevice() else {
//                 // Error handling is done within setupInputDevice
//                 print("Session Queue: Failed to setup input during camera switch.")
//                 // We might need to revert the optimistic UI update if setup fails?
//                 // For now, assume setupInput handles setting error status.
//                 Task { @MainActor in
//                     // Re-check flash availability even on fail, might have reverted
//                     self.updateFlashAvailability()
//                 }
//                 return
//             }
//
//            // --- Post-switch updates ---
//             Task { @MainActor in // Dispatch UI updates back to main actor
//                 print("Switched camera to \(newPosition).")
//                 self.updateFlashAvailability() // Update flash status based on the new device
//             }
//        }
//    }
//
//    func capturePhoto() {
//        guard status == .configured else {
//             print("Cannot capture photo. Status: \(status)")
//             return
//         }
//         // Check if already capturing (MainActor check is fine here)
//          guard !isCapturingPhoto else {
//             print("Already capturing photo.")
//             return
//         }
//
//        // --- Prepare for Capture (MainActor first) ---
//         self.isCapturingPhoto = true // Update published property on MainActor
//         self.capturedImageData = nil
//         self.error = nil
//
//        // --- Perform Capture Setup & Execution on Session Queue ---
//        sessionQueue.async { [weak self] in
//             guard let self = self else {
//                  // Reset capturing state if self is nil? Needed?
//                   Task { @MainActor in self?.isCapturingPhoto = false }
//                  return
//             }
//
//            // Double check status and connection on session queue
//             guard self.status == .configured, let photoOutputConnection = self.photoOutput.connection(with: .video) else {
//                 Task { @MainActor in // Dispatch error and reset state
//                    self.setError(.captureFailed(nil, reason: "Photo output connection unavailable or not configured."))
//                    self.isCapturingPhoto = false
//                 }
//                 return
//             }
//
//            // --- CONFIGURE PHOTO SETTINGS ---
//            let photoSettings = AVCapturePhotoSettings()
//
//            // Set flash mode (check device on session queue)
//             if let device = self.currentDevice, device.hasFlash { // Check hasFlash first
//                 // Check isFlashAvailable inside flashMode check
//                 if device.isFlashAvailable {
//                     // Use the selected flash mode
//                     photoSettings.flashMode = self.flashMode.avFlashMode
//                     print("Session Queue: Using flash mode: \(self.flashMode)")
//                 } else if self.flashMode != .off {
//                      print("Session Queue: Warning - Flash requested (\(self.flashMode)) but not available on device.")
//                      photoSettings.flashMode = .off // Default to off
//                  } else {
//                      photoSettings.flashMode = .off // Explicitly off
//                  }
//             } else {
//                 // Device doesn't have flash
//                  if self.flashMode != .off { print("Session Queue: Warning - Flash requested (\(self.flashMode)) but device has no flash.") }
//                 photoSettings.flashMode = .off // Default to off
//             }
//
//            // Set Max Resolution (Modern Way) iOS 16+
//             if #available(iOS 16.0, *) {
//                 // Use the maximum available photo dimensions
//                 photoSettings.maxPhotoDimensions = self.photoOutput.maxPhotoDimensions
//                 if photoSettings.maxPhotoDimensions.width > 0 {
//                     print("Session Queue: Setting max photo dimensions: \(photoSettings.maxPhotoDimensions)")
//                 }
//             } else {
//                 // Fallback for < iOS 16: isHighResolutionCaptureEnabled is deprecated but might work
//                 // Note: The original deprecation warning was for isHighResolutionCaptureEnabled on the *output*,
//                 // not the settings. We check the output's property here.
//                 // Need to read photoOutput.isHighResolutionCaptureEnabled from Main Actor? Let's assume it's safe here for read.
//                  photoSettings.isHighResolutionPhotoEnabled = self.photoOutput.isHighResolutionCaptureEnabled
//                  if photoSettings.isHighResolutionPhotoEnabled {
//                       print("Session Queue: Enabling high resolution photo (legacy).")
//                    }
//             }
//
//            // Get current interface orientation for rotation/metadata
//            // Need to dispatch to MainActor to get UI state
//            Task { @MainActor in
//                if let rotationAngle = CameraPreviewView.currentRotationAngle() {
//                    // Apply rotation to the connection BEFORE capture
//                     // IMPORTANT: Applying rotation might be better done *after* capture
//                     // using image processing, as connection orientation is complex.
//                     // For simplicity in capture, let's OMIT setting connection orientation here
//                     // and rely on image metadata or post-processing.
//                     // photoOutputConnection.videoRotationAngle = rotationAngle <- Removed for now
//                     print("Main Actor: Determined rotation angle: \(rotationAngle) (Not applied to connection)")
//                 }
//
//                 // --- EXECUTE CAPTURE ---
//                 print("Session Queue: Capturing photo...")
//                  // Delegate methods will be called on the main thread (by default, can be changed)
//                 // We conform to delegate, so `self` is passed.
//                 self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
//            }
//        }
//    }
//
//    // MARK: - AVCapturePhotoCaptureDelegate
//    // Note: These delegate methods can be called on a specified queue. Ensure UI updates happen on MainActor.
//    // By default, they seem to often arrive on the main thread, but guaranteeing with @MainActor is safer.
//
//      // Called when capture begins (optional, good for UI feedback)
//    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
//         print("Delegate (MainActor?): Capture will begin.")
//         // Can add UI feedback here, e.g., shutter flash/sound
//    }
//
//    // Called when photo processing is complete
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//         print("Delegate (MainActor?): Finished processing photo.")
//         // Explicitly ensure we're on the MainActor for state updates
//         Task { @MainActor in
//             defer {
//                 self.isCapturingPhoto = false // Always reset capturing state
//                 print("Main Actor: Reset isCapturingPhoto to false.")
//             }
//
//             if let error = error {
//                 print("Main Actor: Error capturing photo: \(error)")
//                 setError(.captureFailed(error))
//                 return
//             }
//
//             guard let imageData = photo.fileDataRepresentation() else {
//                 print("Main Actor: Could not get image data representation.")
//                 setError(.captureFailed(nil, reason: "Could not get image data."))
//                 return
//             }
//
//             print("Main Actor: Photo captured successfully. Size: \(imageData.count) bytes")
//             self.capturedImageData = imageData // Update the published property
//             self.error = nil // Clear previous errors on success
//         }
//     }
//
//     // Called when the entire capture request finishes (optional)
//      func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
//          print("Delegate (MainActor?): Capture sequence finished.")
//          if let error = error {
//              // This error might indicate a more fundamental issue than processing error
//              // We already handle processing error, maybe just log this one?
//              print("Delegate (MainActor?): Capture sequence finished with error: \(error)")
//          }
//          // We reset isCapturingPhoto in didFinishProcessingPhoto
//      }
//
//    // MARK: - Flash Control
//    func cycleFlashMode() {
//         // Cycle flash mode on main thread is fine, but check availability first
//         guard isFlashAvailable else { return }
//
//         switch flashMode {
//         case .off: flashMode = .on
//         case .on: flashMode = .auto
//         case .auto: flashMode = .off
//         }
//         print("Flash mode set to: \(flashMode)") // MainActor context implicitly
//    }
//
//   private func updateFlashAvailability() {
//        // Check flash availability on the session queue, update UI on Main Actor
//        sessionQueue.async { [weak self] in
//            guard let self = self else { return }
//
//            // Check device availability and flash properties on the session queue
//            guard let device = self.currentDevice else {
//                Task { @MainActor in // Dispatch UI update back
//                     if self.isFlashAvailable { // Only update if changed
//                        self.isFlashAvailable = false
//                        if self.flashMode != .off { self.flashMode = .off }
//                    }
//                 }
//                return
//            }
//
//            let available = device.hasFlash && device.isFlashAvailable
//
//            // Dispatch the UI update back to the Main Actor
//            Task { @MainActor in
//                 if self.isFlashAvailable != available { // Only update if changed
//                     self.isFlashAvailable = available
//                     print("Main Actor: Flash availability updated: \(available)")
//                     // If flash became unavailable, reset mode to off
//                     if !available && self.flashMode != .off {
//                         self.flashMode = .off
//                         print("Main Actor: Reset flash mode to OFF due to unavailability.")
//                     }
//                 }
//             }
//         }
//     }
//
//    // MARK: - Error Handling
//    private func setError(_ error: CameraError) {
//        // Always set errors on the MainActor thread
//        Task { @MainActor in
//            // Avoid overriding a more specific error with a general one if occurs rapidly
//            // This basic check might need refinement depending on error flow
//            if self.error == nil || shouldOverrideError(current: self.error, new: error) {
//                 self.error = error
//                 print("Camera Error Set: \(error.localizedDescription)")
//            }
//
//            // Update status based on the error type
//            switch error {
//            case .permissionDenied, .unknownPermissionStatus:
//                 if status != .unauthorized { status = .unauthorized }
//            case .cannotAddInput, .cannotAddOutput, .createInputFailed, .deviceUnavailable, .sessionFailed:
//                 if status != .failed { status = .failed }
//            case .captureFailed:
//                // Capture failures usually don't mean the session is dead.
//                 // Keep status as .configured unless underlying error suggests otherwise.
//                 print("Capture failed, but keeping status as \(status)")
//            }
//        }
//    }
//
//     // Helper to decide if a new error should replace an existing one (optional)
//    private func shouldOverrideError(current: CameraError?, new: CameraError) -> Bool {
//        guard current != nil else { return true } // No current error, always set new one
//        // Example: Don't let a transient capture error override a fatal session error
//        switch (current, new) {
//             case (.sessionFailed, .captureFailed): return false // Keep session failed
//             case (.deviceUnavailable, .captureFailed): return false // Keep device unavailable
//            // Add more rules as needed
//        default: return true // Default behavior: override
//        }
//    }
//}
//
//// MARK: - Camera Preview (UIViewRepresentable) - *Updated for iOS 17+ Rotation*
//
//struct CameraPreviewView: UIViewRepresentable {
//    let session: AVCaptureSession
//
//    // --- Static Helper to get current rotation angle (iOS 17+) ---
////    static func currentRotationAngle() -> CGFloat? {
////         guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
////               let orientation = scene.interfaceOrientation else {
////             return 90.0 // Default to Portrait angle if undetermined
////         }
////         switch orientation {
////         case .portrait: return 90.0
////         case .landscapeLeft: return 180.0 // Angle relative to sensor's natural orientation
////         case .landscapeRight: return 0.0
////         case .portraitUpsideDown: return 270.0
////         default: return nil // Unknown or flat orientation
////         }
////     }
//    
//    static func currentOrientation() -> AVCaptureDevice.RotationCoordinator? {
//             guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
//                 // Cannot get scene, fallback or return nil/default
//                 print("Warning: Could not get UIWindowScene for orientation.")
//                 return .portrait // Or return nil if you handle that case
//             }
//             // Access orientation directly after getting the scene
//             let orientation = scene.interfaceOrientation
//    
//             switch orientation {
//             case .portrait: return .portrait
//             case .landscapeLeft: return .landscapeLeft // Check if these map correctly for AVCaptureVideoOrientation
//             case .landscapeRight: return .landscapeRight // Check if these map correctly for AVCaptureVideoOrientation
//             case .portraitUpsideDown: return .portraitUpsideDown
//             case .unknown:
//                  print("Warning: Unknown interface orientation.")
//                  return nil // Handle unknown explicitly
//             @unknown default:
//                 print("Warning: Unhandled default interface orientation.")
//                 return nil // Handle future cases
//             }
//         }
//    
//
//     // --- Static Helper for legacy orientation (Fallback < iOS 17) ---
//     static func currentVideoOrientation() -> AVCaptureVideoOrientation? {
//        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let orientation = scene.interfaceOrientation else {
//             return .portrait // Default
//         }
//         switch orientation {
//         case .portrait: return .portrait
//         case .landscapeLeft: return .landscapeLeft
//         case .landscapeRight: return .landscapeRight
//         case .portraitUpsideDown: return .portraitUpsideDown
//         default: return nil
//         }
//     }
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        view.backgroundColor = .black
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//
//        // Set initial orientation/rotation
//         if #available(iOS 17.0, *) {
//             if let initialRotation = CameraPreviewView.currentRotationAngle() {
//                 previewLayer.connection?.videoRotationAngle = initialRotation
//             }
//         } else {
//              if let initialOrientation = CameraPreviewView.currentVideoOrientation() {
//                 previewLayer.connection?.videoOrientation = initialOrientation // Deprecated, but use as fallback
//             }
//         }
//
//        view.layer.addSublayer(previewLayer)
//        // Use weak reference for associated object if possible, or manage cleanup if view cycles
//        objc_setAssociatedObject(view, &AssociatedKeys.previewLayer, previewLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        // Retrieve the layer using associated object
//        guard let previewLayer = objc_getAssociatedObject(uiView, &AssociatedKeys.previewLayer) as? AVCaptureVideoPreviewLayer else {
//            return
//        }
//
//        // Update frame
//        previewLayer.frame = uiView.bounds
//
//        // Update orientation/rotation dynamically
//         if #available(iOS 17.0, *) {
//            if let currentRotation = CameraPreviewView.currentRotationAngle() {
//                 // Only update if the connection exists and angle changes (optional optimization)
//                 if previewLayer.connection?.videoRotationAngle != currentRotation {
//                      previewLayer.connection?.videoRotationAngle = currentRotation
//                  }
//             }
//         } else {
//            if let currentOrientation = CameraPreviewView.currentVideoOrientation() {
//                if previewLayer.connection?.videoOrientation != currentOrientation {
//                     previewLayer.connection?.videoOrientation = currentOrientation
//                 }
//             }
//         }
//    }
//
//    // Optional: Implement static func dismantleUIView if needed for complex cleanup
//    // static func dismantleUIView(_ uiView: UIView, coordinator: ()) {}
//
//    private struct AssociatedKeys {
//        static var previewLayer = "previewLayer" // Use a unique key
//    }
//}
//
//// MARK: - SwiftUI Camera View (ContentView_V2)
//
//struct ContentView_V2: View { // Renamed to match file if needed
//    @StateObject private var cameraManager = CameraManager()
//    @State private var showCapturedPhoto = false
//    @State private var didRequestPermission = false // Track if initial permission req finished
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                cameraPreview
//                    .ignoresSafeArea()
//                     // Trigger configuration attempt when view appears AND permission granted
//                    .onAppear {
//                        #if !targetEnvironment(simulator)
//                        Task {
//                             print("CameraView onAppear: Requesting permission...")
//                             let granted = await cameraManager.requestPermission()
//                             didRequestPermission = true // Mark that request attempt happened
//                             if granted {
//                                 print("CameraView onAppear: Permission granted, starting configuration...")
//                                 cameraManager.startConfiguration() // Starts session if successful
//                             } else {
//                                 print("CameraView onAppear: Permission not granted.")
//                                 // UI should update based on cameraManager.status
//                             }
//                         }
//                        #else
//                         // Simulate configured state for simulator preview if needed
//                         // Or show a placeholder indicating simulator limitation
//                         print("Running on Simulator - Camera Feed Unavailable")
//                         Task { @MainActor in cameraManager.status = .failed; cameraManager.error = .deviceUnavailable(.back) } // Example simulator state
//                         didRequestPermission = true // Simulate permission check done
//                        #endif
//                    }
//                    .onDisappear {
//                        #if !targetEnvironment(simulator)
//                        cameraManager.stopSession()
//                        #endif
//                    }
//                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//                        #if !targetEnvironment(simulator)
//                         // Re-check permissions and maybe re-start configuration/session
//                         // if the app was backgrounded and permissions changed or session stopped.
//                          print("App entering foreground...")
//                          Task {
//                             // Give a slight delay for app to settle? Optional.
//                              // await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
//                              if await cameraManager.requestPermission() { // Re-verify permission
//                                 cameraManager.startSession() // Attempt to start (will configure if needed)
//                              }
//                          }
//                         #endif
//                    }
//                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
//                        #if !targetEnvironment(simulator)
//                        print("App entering background...")
//                        cameraManager.stopSession()
//                        #endif
//                    }
//
//                 // --- UI Overlay ---
//                 // Show overlay only after permission request has been attempted
//                 if didRequestPermission {
//                      overlayView
//                  } else {
//                      // Optional: Show a brief loading indicator while permission is checked initially
//                       ProgressView().controlSize(.large).padding(50).background(.thinMaterial).cornerRadius(10)
//                  }
//
//                // --- Captured Photo Display ---
//                if showCapturedPhoto, let imageData = cameraManager.capturedImageData, let uiImage = UIImage(data: imageData) {
//                    CapturedPhotoView(image: uiImage) { usePhoto in
//                         showCapturedPhoto = false
//                         if usePhoto {
//                             print("User chose to use the photo.")
//                             // savePhotoToLibrary(imageData: imageData) // Uncomment to enable saving
//                         } else {
//                             print("User chose to retake.")
//                         }
//                         // Clear data AFTER view is dismissed
//                         DispatchQueue.main.async { // Ensure runs after state change
//                            cameraManager.capturedImageData = nil
//                         }
//                     }
//                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
//                    .zIndex(10)
//                }
//            }
//            .navigationTitle("Camera")
//            .navigationBarHidden(true)
//            .animation(.easeInOut, value: cameraManager.status) // Animate changes based on status
//            .animation(.easeInOut, value: cameraManager.error) // Animate changes based on error
//            .animation(.easeInOut, value: showCapturedPhoto) // Animate photo presentation
//        }
//         .onChange(of: cameraManager.capturedImageData) { newData in
//            showCapturedPhoto = (newData != nil) // Show/hide based on data presence
//         }
//    }
//
//    // Rest of the CameraView subviews (cameraPreview, overlayView, statusOverlay, etc.)
//    // remain largely the same as the previous version, but ensure they correctly
//    // reference the `cameraManager` instance.
//
//     // MARK: - Subviews (Minor adjustments maybe needed)
//
//    @ViewBuilder
//    private var cameraPreview: some View {
//        #if targetEnvironment(simulator)
//         // Specific Simulator Preview
//          Rectangle()
//              .fill(Color.gray)
//              .overlay(Text("Camera Preview\n(Simulator)").multilineTextAlignment(.center).foregroundColor(.white))
//        #else
//         // Real Device Preview
//          if cameraManager.status == .configured || cameraManager.status == .unconfigured /* Show black BG while configuring */ {
//               // Show preview OR black background while configuring after permission
//              CameraPreviewView(session: cameraManager.session)
//                  .transition(.opacity.animation(.easeInOut(duration: 0.3))) // Fade in preview
//          } else {
//              // Handles unauthorized, failed states (shows black BG before overlay appears)
//              Color.black
//                  .transition(.opacity.animation(.easeInOut(duration: 0.3)))
//          }
//         #endif
//    }
//
//    private var overlayView: some View {
//         VStack {
//             // Top Controls (Flash)
//              HStack {
//                   Spacer()
//                   if cameraManager.status == .configured { flashButton }
//              }
//              .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 5) // Adjust for safe area
//              .padding(.horizontal)
//
//             Spacer() // Pushes controls/status to bottom/middle
//
//             // Status/Error Overlay
//             statusOverlay
//                 // Adjust padding based on whether bottom controls are visible
//                  .padding(.bottom, cameraManager.status == .configured ? 80 : 50) // More space needed for controls below
//
//             // Bottom Controls (Capture, Switch)
//              if cameraManager.status == .configured {
//                  bottomControls
//                      .padding(.bottom, (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 20) // Adjust for safe area
//              }
//         }
//         .transition(.opacity.animation(.easeInOut)) // Fade in overlay
//     }
//
//    @ViewBuilder
//    private var statusOverlay: some View {
//        // Ensure overlay only shows when appropriate status exists
//        if cameraManager.status != .configured || cameraManager.error != nil {
//             Group { // Use Group to apply modifiers conditionally
//                  switch cameraManager.status {
//                  case .unconfigured:
//                      // Show only if permission not determined yet, otherwise request view handles it
//                       if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
//                           permissionRequestView // Shows Grant Permission button
//                       } else {
//                            // If unconfigured but permission WAS denied, show denied view
//                            // This might happen if status is reset somehow
//                            if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
//                                permissionDeniedView
//                            } else {
//                                // Potentially show a loading/configuring state if needed
//                                 ProgressView().padding() // Simple indicator
//                            }
//                       }
//                  case .unauthorized:
//                      permissionDeniedView
//                  case .failed:
//                      errorView
//                  case .configured:
//                      // Show capture error specifically IF it occurred
//                      if let error = cameraManager.error, case .captureFailed = error {
//                          captureErrorView
//                      } else {
//                          EmptyView() // Normal configured state, error is nil
//                      }
//                  }
//              }
//             .padding(15)
//             .frame(maxWidth: 400) // Limit width for larger screens
//             .background(.ultraThinMaterial)
//             .cornerRadius(15)
//             .padding(.horizontal, 20)
//             .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
//         }
//    }
//
//    // bottomControls, takePhotoButton, switchCameraButton, flashButton as before
//
//     private var bottomControls: some View {
//         HStack(spacing: 50) {
//              Spacer() // Keep spacer for centering
//             takePhotoButton
//             switchCameraButton
//              Spacer() // Keep spacer for centering
//         }
//         .frame(maxWidth: .infinity)
//     }
//
//     private var takePhotoButton: some View {
//         Button {
//             cameraManager.capturePhoto()
//         } label: {
//              ZStack {
//                  Circle()
//                      .fill(Color.white)
//                      .frame(width: 70, height: 70)
//
//                  Circle()
//                      .stroke(Color.white, lineWidth: 4)
//                      .frame(width: 80, height: 80)
//              }
//         }
//         .disabled(cameraManager.isCapturingPhoto || cameraManager.status != .configured) // Also disable if not configured
//         .opacity(cameraManager.isCapturingPhoto || cameraManager.status != .configured ? 0.5 : 1.0)
//     }
//
//     private var switchCameraButton: some View {
//         Button {
//             cameraManager.switchCamera()
//         } label: {
//              Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
//                 .font(.system(size: 28))
//                 .foregroundColor(.white)
//                 .padding(15)
//                 .background(Color.black.opacity(0.3))
//                 .clipShape(Circle())
//         }
//          .disabled(cameraManager.status != .configured) // Disable if not configured
//          .opacity(cameraManager.status != .configured ? 0.5 : 1.0)
//     }
//
//     private var flashButton: some View {
//        Button {
//            cameraManager.cycleFlashMode()
//        } label: {
//             Image(systemName: cameraManager.flashMode.icon)
//                .font(.system(size: 20))
//                .foregroundColor(cameraManager.isFlashAvailable ? .yellow : .gray)
//                .padding(10)
//                .background(Color.black.opacity(0.3))
//                .clipShape(Circle())
//        }
//        .disabled(!cameraManager.isFlashAvailable || cameraManager.status != .configured) // Disable if not configured
//        .opacity(!cameraManager.isFlashAvailable || cameraManager.status != .configured ? 0.5 : 1.0)
//    }
//
//    // permissionRequestView, permissionDeniedView, errorView, captureErrorView (mostly unchanged)
//    // Add explicit Request Permission button action in permissionRequestView
//
//     private var permissionRequestView: some View {
//         VStack(spacing: 12) {
//             Image(systemName: "camera.viewfinder").font(.largeTitle).padding(.bottom, 5)
//             Text("Camera Access Needed")
//                 .font(.headline)
//             Text("Grant camera access to capture photos.")
//                 .font(.subheadline)
//                 .multilineTextAlignment(.center)
//                 .foregroundColor(.secondary)
//             Button("Grant Permission") {
//                  // Request permission directly when button tapped
//                  Task {
//                      await cameraManager.requestPermission()
//                      // After request, the status should update and UI will change
//                       // If granted, configuring should start via onAppear logic
//                  }
//             }
//             .buttonStyle(.borderedProminent)
//             .padding(.top, 5)
//         }
//     }
//
//    // permissionDeniedView, errorView, captureErrorView mostly unchanged from previous example
//     private var permissionDeniedView: some View { /* As before */
//          VStack(spacing: 12) {
//              Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundColor(.orange).padding(.bottom, 5)
//              Text("Camera Access Denied")
//                  .font(.headline)
//              Text(cameraManager.error?.recoverySuggestion ?? "Grant camera access in Settings.")
//                  .font(.subheadline)
//                  .multilineTextAlignment(.center)
//                  .foregroundColor(.secondary)
//              if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
//                  Button("Open Settings") {
//                      UIApplication.shared.open(url)
//                  }
//                  .buttonStyle(.bordered)
//                  .padding(.top, 5)
//              }
//          }
//      }
//
//     private var errorView: some View { /* As before */
//         VStack(spacing: 10) {
//              Image(systemName: "exclamationmark.octagon.fill").font(.largeTitle).foregroundColor(.red).padding(.bottom, 5)
//              Text("Camera Error")
//                  .font(.headline)
//              Text(cameraManager.error?.errorDescription ?? "An unknown camera error occurred.")
//                  .font(.subheadline)
//                  .multilineTextAlignment(.center)
//                  .foregroundColor(.secondary)
//             Text(cameraManager.error?.recoverySuggestion ?? "Please try again.")
//                 .font(.caption).foregroundColor(.gray)
//          }
//      }
//
//      private var captureErrorView: some View { /* As before, maybe remove auto-dismiss */
//         VStack(spacing: 10) {
//             Image(systemName: "exclamationmark.circle.fill").font(.title2).foregroundColor(.red)
//             Text("Capture Failed")
//                  .font(.headline)
//             Text(cameraManager.error?.errorDescription ?? "Could not capture photo.")
//                 .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
//             Text(cameraManager.error?.recoverySuggestion ?? "Please try again.")
//                 .font(.caption).foregroundColor(.gray)
//          }
//       }
//
//    // Example save function (requires Info.plist key)
//    /*
//    private func savePhotoToLibrary(imageData: Data) {
//        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
//             // Ensure switching back to main thread if UI updates needed
//             DispatchQueue.main.async {
//                 guard status == .authorized else {
//                    print("Photo library access denied (add only).")
//                    // Optionally set an error: self.cameraManager.setError(...)
//                    return
//                 }
//
//                PHPhotoLibrary.shared().performChanges({
//                    let creationRequest = PHAssetCreationRequest.forAsset()
//                    creationRequest.addResource(with: .photo, data: imageData, options: nil)
//                }) { success, error in
//                    DispatchQueue.main.async { // Back to main for feedback
//                        if success {
//                            print("Photo saved successfully!")
//                            // Show success feedback UI?
//                        } else if let error = error {
//                            print("Error saving photo: \(error)")
//                             // Set error: self.cameraManager.setError(...)
//                         }
//                    }
//                 }
//             }
//        }
//    }
//     */
//}
//
//// MARK: - Captured Photo View (Unchanged)
// struct CapturedPhotoView: View { /* As before */
//     let image: UIImage
//     let action: (Bool) -> Void // Callback: true = use photo, false = retake
//
//     var body: some View {
//          GeometryReader { geo in
//              ZStack {
//                  // Dimmed Background
//                   Color.black.opacity(0.85).ignoresSafeArea()
//
//                  VStack {
//                      // Display the Captured Image
//                      Image(uiImage: image)
//                          .resizable()
//                          .scaledToFit()
//                          .frame(maxWidth: geo.size.width * 0.95, maxHeight: geo.size.height * 0.7)
//                          .cornerRadius(10)
//                           // Use safe area top inset for padding
//                          .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 20)
//
//                      Spacer() // Push buttons to bottom
//
//                      // Action Buttons
//                      HStack(spacing: 30) {
//                          Button {
//                              action(false) // Retake
//                          } label: {
//                              Text("Retake")
//                                  .font(.headline)
//                                  .foregroundColor(.white)
//                                  .padding(.vertical, 15)
//                                  .padding(.horizontal, 30)
//                                  .background(Color.red)
//                                  .cornerRadius(10)
//                          }
//
//                          Button {
//                              action(true) // Use Photo
//                          } label: {
//                              Text("Use Photo")
//                                  .font(.headline)
//                                  .foregroundColor(.white)
//                                  .padding(.vertical, 15)
//                                  .padding(.horizontal, 30)
//                                  .background(Color.blue)
//                                  .cornerRadius(10)
//                          }
//                      }
//                       // Use safe area bottom inset for padding
//                       .padding(.bottom, (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 20)
//                  }
//              }
//          }
//     }
// }
//
//// MARK: - Camera Error Enum (Unchanged)
//enum CameraError: Error, LocalizedError { /* As before */
//     case permissionDenied
//     case unknownPermissionStatus
//     case deviceUnavailable(CameraManager.CameraPosition)
//     case cannotAddInput
//     case cannotAddOutput
//     case createInputFailed(Error)
//     case sessionFailed(Error)
//     case captureFailed(Error?, reason: String? = nil)
//
//     var errorDescription: String? {
//         switch self {
//         case .permissionDenied: return "Camera Permission Denied"
//         case .unknownPermissionStatus: return "Unknown Camera Permission Status"
//         case .deviceUnavailable(let pos): return "\(pos == .back ? "Back" : "Front") Camera Unavailable"
//         case .cannotAddInput: return "Cannot Add Camera Input"
//         case .cannotAddOutput: return "Cannot Add Camera Output"
//         case .createInputFailed(let err): return "Failed to Create Input: \(err.localizedDescription)"
//         case .sessionFailed(let err): return "Camera Session Failed: \(err.localizedDescription)"
//         case .captureFailed(let err, let reason):
//             var msg = "Photo Capture Failed"
//             if let r = reason { msg += ": \(r)" }
//             if let e = err { msg += " (\(e.localizedDescription))" }
//             return msg
//         }
//     }
//
//     var recoverySuggestion: String? {
//         switch self {
//         case .permissionDenied, .unknownPermissionStatus:
//             return "Please grant camera access in iPhone Settings > Privacy & Security > Camera > [Your App Name]."
//         case .deviceUnavailable, .cannotAddInput, .cannotAddOutput, .createInputFailed, .sessionFailed:
//             return "An internal camera error occurred. Please try restarting the app or your device."
//         case .captureFailed:
//             return "Could not capture the photo. Please try again."
//         }
//     }
// }
//
//// MARK: - Preview Provider (Updated)
//struct ContentView_V2_Previews: PreviewProvider { // Renamed if needed
//    static var previews: some View {
//
//        // --- Default Preview (Simulates Configured State) ---
//        ContentView_V2(cameraManager: createPreviewManager(status: .configured, isFlashAvailable: true), didRequestPermission: true)
//             .previewDisplayName("Configured")
//
//         // --- Unconfigured (Awaiting Permission) ---
//         ContentView_V2(cameraManager: createPreviewManager(status: .unconfigured), didRequestPermission: false)
//             .previewDisplayName("Unconfigured (Pre-Perm)")
//
//         // --- Unconfigured (Permission Denied) ---
//         ContentView_V2(cameraManager: createPreviewManager(status: .unauthorized, error: .permissionDenied), didRequestPermission: true)
//             .previewDisplayName("Unauthorized")
//
//        // --- Failed State ---
//         ContentView_V2(cameraManager: createPreviewManager(status: .failed, error: .deviceUnavailable(.back)), didRequestPermission: true)
//            .previewDisplayName("Failed (Device)")
//
//        // --- Capture Error State ---
//        ContentView_V2(cameraManager: createPreviewManager(status: .configured, error: .captureFailed(nil, reason: "Simulated Capture Error")), didRequestPermission: true)
//            .previewDisplayName("Capture Error")
//
//        // --- Captured Photo Displayed ---
//         let capturedMgr = createPreviewManager(status: .configured, capturedImageData: UIImage(systemName: "photo")?.pngData())
//         ContentView_V2(cameraManager: capturedMgr, showCapturedPhoto: true, didRequestPermission: true)
//            .previewDisplayName("Showing Photo")
//
//        // --- Preview with Flash ON ---
//        ContentView_V2(cameraManager: createPreviewManager(status: .configured, flashMode: .on, isFlashAvailable: true), didRequestPermission: true)
//            .previewDisplayName("Flash ON")
//    }
//
//    // Helper for creating preview managers
//    @MainActor // Ensure manager creation is on main actor for previews
//    static func createPreviewManager(status: CameraManager.Status,
//                                    error: CameraError? = nil,
//                                    flashMode: CameraManager.FlashMode = .off,
//                                    isFlashAvailable: Bool = false,
//                                     capturedImageData: Data? = nil) -> CameraManager {
//         let manager = CameraManager()
//         // Set properties directly SINCE we are already @MainActor
//         manager.status = status
//         manager.error = error
//         manager.flashMode = flashMode
//         manager.isFlashAvailable = isFlashAvailable
//         manager.capturedImageData = capturedImageData
//         // Simulate authorization based on status for preview logic
//         if status == .unauthorized || error == .permissionDenied {
//             // Need a way to simulate the underlying system status for preview checks
//             // This is hard, typically previews assume permission or show denied UI directly
//         }
//         return manager
//     }
//}
