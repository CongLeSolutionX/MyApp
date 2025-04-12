//
//  AuthenticationFlowForHardware_Comprehensive.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI
import AVFoundation
import Combine // Needed for Timer in AudioLevelMonitor

// MARK: - Authorization Managing Protocol (Unchanged)
@MainActor
protocol AuthorizationManaging: ObservableObject {
    var currentStatus: AVAuthorizationStatus { get }
    var mediaType: AVMediaType { get }
    func checkStatus()
    func requestAccess() async -> Bool
}

// MARK: - Real/Fake Authorization Managers (Unchanged from previous)
@MainActor
class RealAuthorizationManager: AuthorizationManaging {
    @Published private(set) var currentStatus: AVAuthorizationStatus
    let mediaType: AVMediaType

    init(mediaType: AVMediaType) {
        self.mediaType = mediaType
        self.currentStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        print("RealAuthManager Initialized for \(mediaType.rawValue) with actual state: \(currentStatus)")
    }

    func checkStatus() {
        let newStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        if newStatus != currentStatus {
            currentStatus = newStatus
            print("RealAuthManager: Status for \(mediaType.rawValue) updated to: \(currentStatus)")
        } else {
             print("RealAuthManager: Status for \(mediaType.rawValue) remains: \(currentStatus)")
        }
    }

    func requestAccess() async -> Bool {
        guard currentStatus == .notDetermined else {
            print("RealAuthManager: Access request attempted but status is not .notDetermined (\(currentStatus)). Ignoring.")
            return currentStatus == .authorized
        }
        print("RealAuthManager: Requesting real access for \(mediaType.rawValue)...")
        let granted = await AVCaptureDevice.requestAccess(for: mediaType)
        self.currentStatus = granted ? .authorized : .denied
        print("RealAuthManager: Access request completed for \(mediaType.rawValue). Granted: \(granted). New status: \(self.currentStatus)")
        return granted
    }
}

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
    }

    func requestAccess() async -> Bool {
        guard currentStatus == .notDetermined else {
            print("FakeAuthManager: Access request attempted but status is not .notDetermined (\(currentStatus)). Ignoring.")
            return currentStatus == .authorized
        }
        print("FakeAuthManager: Simulating access request for \(mediaType.rawValue)...")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        let granted = Bool.random()
        self.currentStatus = granted ? .authorized : .denied
        print("FakeAuthManager: Simulated access request result for \(mediaType.rawValue). Granted: \(granted). New status: \(self.currentStatus)")
        return granted
    }

    func setStatus(_ status: AVAuthorizationStatus) {
         print("FakeAuthManager: Manually setting fake status to \(status) for \(self.mediaType.rawValue)")
         self.currentStatus = status
    }
}

// MARK: - Camera Feature Components
// Service to manage AVCaptureSession
@MainActor
class CameraService: ObservableObject {
    @Published var error: Error?
    @Published var isSessionRunning = false // Track session state

    let session = AVCaptureSession()
    private var sessionQueue = DispatchQueue(label: "com.example.sessionQueue")
    private var captureDevice: AVCaptureDevice?
    private(set) var previewLayer: AVCaptureVideoPreviewLayer! // Use implicitly unwrapped optional for convenience after setup

    init() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill // Fill the layer bounds
         print("CameraService Initialized")
    }

    func setupSession() {
         print("CameraService: Setting up session...")
         guard captureDevice == nil else {
             print("CameraService: Session already set up.")
             return // Already configured
         }
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            self.error = CameraError.deviceUnavailable
             print("CameraService Error: Default video device unavailable.")
            return
        }
        self.captureDevice = videoDevice

        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo // Standard preset

             // Setup Input
             guard let device = self.captureDevice else { return }
            do {
                 // Ensure previous inputs are removed before adding new ones.
                 self.session.inputs.forEach { self.session.removeInput($0) }

                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    print("CameraService: Input device added.")
                } else {
                    self.error = CameraError.cannotAddInput
                     print("CameraService Error: Cannot add input device.")
                }
            } catch {
                self.error = error
                 print("CameraService Error: Failed to create device input - \(error.localizedDescription)")
            }

            // Setup Output (optional, not needed for just preview, but good practice)
            /*
             let output = AVCaptureVideoDataOutput() // Or AVCapturePhotoOutput
             if self.session.canAddOutput(output) {
                self.session.addOutput(output)
                print("CameraService: Output added (optional).")
             }
             */

            self.session.commitConfiguration()
             print("CameraService: Session configuration committed.")
        }
    }

    func startSession() {
        guard !isSessionRunning else {
             print("CameraService: Attempted to start already running session.")
             return
         }
         // Always check if authorized before starting
         guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
             print("CameraService Error: Authorization denied/not determined, cannot start session.")
             self.error = CameraError.notAuthorized
             return
         }

        sessionQueue.async { [weak self] in
            guard let self = self else { return }
             print("CameraService: Starting session...")
            self.session.startRunning()
            DispatchQueue.main.async { // Publish changes on main thread
                self.isSessionRunning = self.session.isRunning
                 if self.isSessionRunning { print("CameraService: Session started successfully.") }
                  else { print("CameraService: Failed to start session.") }
            }
        }
    }

    func stopSession() {
         guard isSessionRunning else {
             print("CameraService: Attempted to stop already stopped session.")
             return
         }
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
             print("CameraService: Stopping session...")
            self.session.stopRunning()
             DispatchQueue.main.async { // Publish changes on main thread
                 self.isSessionRunning = self.session.isRunning
                 print("CameraService: Session stopped. Running: \(self.isSessionRunning)")
             }
        }
    }

     deinit {
         // Ensure session is stopped when service is deallocated
         if session.isRunning {
             //stopSession()
         }
         print("CameraService Deinitialized")
     }
}

enum CameraError: LocalizedError {
    case deviceUnavailable
    case cannotAddInput
     case notAuthorized
     case setupFailed

    var errorDescription: String? {
        switch self {
        case .deviceUnavailable: return "Camera device is unavailable."
        case .cannotAddInput: return "Cannot add camera input to the session."
         case .notAuthorized: return "Camera access is not authorized."
         case .setupFailed: return "Camera setup failed."
        }
    }
}

// UIViewRepresentable for the Camera Preview Layer
struct CameraPreviewView: UIViewRepresentable {
    let service: CameraService

    func makeUIView(context: Context) -> UIView {
         print("CameraPreviewView: makeUIView")
        let view = UIView()
        view.backgroundColor = .black // Background while session starts
        service.previewLayer.frame = view.bounds // Initial frame
         service.previewLayer.connection?.videoOrientation = .portrait // Adjust if needed
        view.layer.addSublayer(service.previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
         print("CameraPreviewView: updateUIView - Updating layer frame")
        service.previewLayer.frame = uiView.bounds // Keep layer frame synced with view bounds
    }
}

// MARK: - Audio Feature Components
@MainActor
class AudioLevelMonitor: ObservableObject {
    @Published var audioLevel: Float = 0.0 // Normalized 0.0 to 1.0
    @Published var error: Error?
    @Published var isMonitoring = false

    private var audioRecorder: AVAudioRecorder?
    private var timer: AnyCancellable? // Use Combine Timer

     private let audioSession = AVAudioSession.sharedInstance()

    init() {
         print("AudioLevelMonitor initialized")
    }

    func setupAudioSession() {
         print("AudioLevelMonitor: Setting up audio session...")
         do {
             // Set category for recording; duck others; allow Bluetooth if needed
             try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .allowBluetoothA2DP])
             try audioSession.setActive(true)
             print("AudioLevelMonitor: Audio session activated.")
         } catch {
             self.error = error
             print("AudioLevelMonitor Error: Failed to set up audio session - \(error.localizedDescription)")
             isMonitoring = false
         }
     }

    func startMonitoring() {
         guard !isMonitoring else {
             print("AudioLevelMonitor: Already monitoring.")
             return
         }
         print("AudioLevelMonitor: Starting monitoring...")

         // Always check authorization first
         guard AVAudioSession.sharedInstance().recordPermission == .granted else {
             print("AudioLevelMonitor Error: Microphone access not granted.")
             self.error = AudioMonitorError.notAuthorized
             isMonitoring = false
             return
         }

         setupAudioSession() // Ensure session is active
         guard self.error == nil else { return } // Don't proceed if session setup failed

        let url = URL(fileURLWithPath: "/dev/null") // Record to nowhere
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // Standard format
            AVSampleRateKey: 44100.0,                // Standard sample rate
            AVNumberOfChannelsKey: 1,                // Mono
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record() // Start recording (to /dev/null)
            isMonitoring = audioRecorder?.isRecording ?? false
            if isMonitoring {
                 print("AudioLevelMonitor: Recording started successfully.")
                 startTimer()
            } else {
                 print("AudioLevelMonitor Error: Failed to start recording.")
                 self.error = AudioMonitorError.recorderSetupFailed
            }

        } catch {
            self.error = error
             print("AudioLevelMonitor Error: Failed to initialize AVAudioRecorder - \(error.localizedDescription)")
            isMonitoring = false
        }
    }

    func stopMonitoring() {
         guard isMonitoring else {
             print("AudioLevelMonitor: Not monitoring, cannot stop.")
             return
         }
         print("AudioLevelMonitor: Stopping monitoring...")
        timer?.cancel()
        timer = nil
        audioRecorder?.stop()
        audioRecorder = nil // Release recorder
        isMonitoring = false
        audioLevel = 0 // Reset level

         // Deactivate session (optional - good practice if done with audio)
         do {
             try audioSession.setActive(false)
             print("AudioLevelMonitor: Audio session deactivated.")
         } catch {
             print("AudioLevelMonitor Warning: Failed to deactivate audio session - \(error.localizedDescription)")
             // Don't necessarily set self.error here unless it's critical
         }
    }

    private func startTimer() {
        // Update level 10 times per second (adjust as needed)
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateLevel()
            }
         print("AudioLevelMonitor: Metering timer started.")
    }

    private func updateLevel() {
        guard let recorder = audioRecorder, recorder.isRecording else {
            audioLevel = 0
            return
        }
        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0) // dBFS value (usually -160 to 0)

        // Simple normalization: Map a useful range (e.g., -60dB to 0dB) to 0.0 - 1.0
        let normalizedLevel = mapValue(value: averagePower, fromMin: -60.0, fromMax: 0.0, toMin: 0.0, toMax: 1.0)
        self.audioLevel = normalizedLevel
        // print("AudioLevelMonitor: Average Power: \(averagePower) dB, Normalized: \(normalizedLevel)") // Debugging
    }

     // Helper to map dBFS to 0-1 range, clamping the result
     private func mapValue(value: Float, fromMin: Float, fromMax: Float, toMin: Float, toMax: Float) -> Float {
         // Clamp input value to the source range
         let clampedValue = max(fromMin, min(value, fromMax))
         // Calculate the proportion within the source range
         let proportion = (clampedValue - fromMin) / (fromMax - fromMin)
         // Map the proportion to the target range
         let mappedValue = toMin + proportion * (toMax - toMin)
         return mappedValue
     }

     deinit {
         // Ensure monitoring is stopped when monitor is deallocated
         print("AudioLevelMonitor Deinitialized")
         //stopMonitoring()
     }
}

enum AudioMonitorError: LocalizedError {
     case notAuthorized
     case sessionSetupFailed
    case recorderSetupFailed

    var errorDescription: String? {
        switch self {
         case .notAuthorized: return "Microphone access is not authorized."
         case .sessionSetupFailed: return "Failed to configure the audio session."
        case .recorderSetupFailed: return "Failed to set up the audio recorder."
        }
    }
}

// Simple visualizer view
struct AudioLevelMeterView: View {
    let level: Float // Normalized 0.0 to 1.0
    let numberOfSegments: Int = 20

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<numberOfSegments, id: \.self) { index in
                Capsule()
                    .fill(colorForSegment(index: index))
                    .frame(height: 30) // Adjust size as needed
            }
        }
        .frame(minWidth: 150) // Ensure it has some width
        .padding(.vertical)
         .drawingGroup() // Improves performance for rapid redraws
    }

    private func colorForSegment(index: Int) -> Color {
        let levelThreshold = Float(index + 1) / Float(numberOfSegments)
        let isActive = level >= levelThreshold
        let hue = Double(index) / Double(numberOfSegments) * 0.3 // Green to Yellow/Orange
        return isActive ? Color(hue: hue, saturation: 0.8, brightness: 0.9) : Color.gray.opacity(0.3)
    }
}

// MARK: - Enhanced Authorization Flow View
struct AuthorizationFlowView: View {
    @State var authManager: any AuthorizationManaging
    @State private var useRealAPI: Bool = false

    // State objects for features when authorized
    @StateObject private var cameraService = CameraService()
    @StateObject private var audioMonitor = AudioLevelMonitor()

    private let mediaType: AVMediaType
    private let mediaTypeDescription: String

    init(mediaType: AVMediaType) {
        self.mediaType = mediaType
        self.mediaTypeDescription = (mediaType == .video) ? "Camera" : (mediaType == .audio ? "Microphone" : "Media")
        self._authManager = State(initialValue: FakeAuthorizationManager(mediaType: mediaType))
        print("AuthorizationFlowView Initialized for \(mediaType.rawValue)")
    }

    var body: some View {
        NavigationView { // Added for Title Display
            VStack(spacing: 10) {
                // --- API Mode Toggle ---
                HStack {
                    Toggle("Use REAL \(mediaTypeDescription) Permissions", isOn: $useRealAPI)
                        .tint(.purple)

                    // Button to force status change in Fake mode (for testing)
                    if !useRealAPI, let fakeMgr = authManager as? FakeAuthorizationManager {
                        Menu {
                            Button(".authorized") { fakeMgr.setStatus(.authorized) }
                            Button(".denied") { fakeMgr.setStatus(.denied) }
                            Button(".restricted") { fakeMgr.setStatus(.restricted) }
                            Button(".notDetermined") { fakeMgr.setStatus(.notDetermined) }
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)

                Divider()

                // --- Dynamic Content Area ---
                Group { // Group to apply modifiers once
                    switch authManager.currentStatus {
                    case .authorized:
                        AuthorizedContentView(
                            mediaType: mediaType,
                            cameraService: cameraService,
                            audioMonitor: audioMonitor
                        )
                    case .notDetermined:
                        NotDeterminedView(
                            mediaTypeDescription: mediaTypeDescription,
                            requestAction: requestPermission // Pass action
                        )
                    case .denied:
                        DeniedView(mediaTypeDescription: mediaTypeDescription)
                    case .restricted:
                        RestrictedView(mediaTypeDescription: mediaTypeDescription)
                    @unknown default:
                        UnknownStatusView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow content to expand

                // --- Footer Info ---
                StatusFooterView(useRealAPI: useRealAPI, mediaType: mediaType)

            } // End Main VStack
            .navigationTitle("\(mediaTypeDescription) Access")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                 print("AuthorizationFlowView: onAppear - Checking status...")
                authManager.checkStatus() // Check status when view appears
            }
            .onChange(of: useRealAPI) { newValue in
                switchManager(useReal: newValue)
            }
            // Ensure resources are cleaned up if the manager *instance* changes
            // or status changes *away* from authorized
            .onChange(of: authManager.currentStatus) { newStatus in
                 print("AuthorizationFlowView: Status changed to \(newStatus).")
                 /*
                if newStatus != .authorized {
                     // No longer need explicit stop here if using onDisappear in AuthorizedContentView
                     // cameraService.stopSession()
                     // audioMonitor.stopMonitoring()
                }
                 */
            }
        } // End NavigationView
    }

    // MARK: - Helper Functions
    private func switchManager(useReal: Bool) {
         print("AuthorizationFlowView: Switching manager. Use Real: \(useReal)")
         // Stop monitoring/session BEFORE switching manager instance
        if cameraService.isSessionRunning { cameraService.stopSession() }
        if audioMonitor.isMonitoring { audioMonitor.stopMonitoring() }

        if useReal {
            authManager = RealAuthorizationManager(mediaType: mediaType)
        } else {
             // Provide initial state based on current *real* status if available?
             // For simplicity, always start Fake as .notDetermined unless specified.
            authManager = FakeAuthorizationManager(mediaType: mediaType)
        }
        authManager.checkStatus() // Check status of the new manager
    }

    private func requestPermission() {
        Task {
             print("AuthorizationFlowView: Requesting permission via manager...")
            _ = await authManager.requestAccess()
            // Status updates automatically via the manager's @Published property
            print("AuthorizationFlowView: Request finished. New status: \(authManager.currentStatus)")
        }
    }
}

// MARK: - Content Views for Different States

// View shown when permission IS granted
struct AuthorizedContentView: View {
    let mediaType: AVMediaType
    @ObservedObject var cameraService: CameraService // Use ObservedObject as owned by parent
    @ObservedObject var audioMonitor: AudioLevelMonitor

    var body: some View {
        VStack {
            if mediaType == .video {
                CameraFeatureView(service: cameraService)
            } else if mediaType == .audio {
                AudioFeatureView(monitor: audioMonitor)
            } else {
                Text("✅ Access Granted for \(mediaType.rawValue)") // Fallback
                    .foregroundColor(.green)
            }
        }
         // Start/Stop resources specific to this authorized view's lifecycle
        .onAppear {
             print("AuthorizedContentView: onAppear")
             if mediaType == .video {
                 cameraService.setupSession() // Setup only if needed
                 cameraService.startSession()
             } else if mediaType == .audio {
                 audioMonitor.startMonitoring()
             }
        }
        .onDisappear {
             print("AuthorizedContentView: onDisappear")
             if mediaType == .video && cameraService.isSessionRunning {
                 cameraService.stopSession()
             } else if mediaType == .audio && audioMonitor.isMonitoring {
                 audioMonitor.stopMonitoring()
             }
        }
    }
}

// Camera specific content
struct CameraFeatureView: View {
    @ObservedObject var service: CameraService

    var body: some View {
        ZStack { // Use ZStack to overlay error message
            if let error = service.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red).font(.largeTitle)
                    Text("Camera Error")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                // Only show the preview if the session is running and no error
                if service.isSessionRunning {
                     GeometryReader { geometry in
                         CameraPreviewView(service: service)
                           // Consider aspect ratio if needed, e.g.:
                           // .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fill)
                           // .frame(width: geometry.size.width, height: geometry.size.height)
                           // .clipped() // Ensure preview doesn't go outside bounds
                     }
                } else {
                     VStack {
                         ProgressView() // Show loading indicator while session starts
                             .padding(.bottom)
                         Text("Starting Camera...")
                             .font(.caption)
                             .foregroundColor(.gray)
                     }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9)) // Background for the camera area
        .cornerRadius(10)
        .padding()
    }
}

// Audio specific content
struct AudioFeatureView: View {
    @ObservedObject var monitor: AudioLevelMonitor

    var body: some View {
        VStack {
             Text("Live Microphone Level")
                 .font(.headline).padding(.bottom)

             if let error = monitor.error {
                 VStack {
                     Image(systemName: "exclamationmark.triangle.fill")
                         .foregroundColor(.red).font(.largeTitle)
                     Text("Audio Error")
                         .font(.headline)
                     Text(error.localizedDescription)
                         .font(.caption)
                         .multilineTextAlignment(.center)
                         .padding()
                 }
             } else if monitor.isMonitoring {
                 AudioLevelMeterView(level: monitor.audioLevel)
                     .padding(.horizontal)
                 Text(String(format: "Level: %.2f", monitor.audioLevel)) // Display numeric value
                     .font(.caption)
                     .foregroundColor(.gray)
             } else {
                 ProgressView() // Show loading indicator while recorder starts
                     .padding(.bottom)
                 Text("Starting Microphone...")
                     .font(.caption)
                     .foregroundColor(.gray)
             }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// View shown when permission is NOT determined
struct NotDeterminedView: View {
    let mediaTypeDescription: String
    let requestAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            StatusSectionView(
                statusText: "Permission Needed",
                description: "To use the \(mediaTypeDescription.lowercased()) feature, the app needs your permission.",
                systemImage: "hand.point.up.left",
                color: .blue
            )
            RequestPermissionButton(
                mediaTypeDescription: mediaTypeDescription,
                action: requestAction // Use passed-in action
            )
        }
    }
}

// View shown when permission is DENIED
struct DeniedView: View {
    let mediaTypeDescription: String

    var body: some View {
        VStack(spacing: 20) {
            StatusSectionView(
                statusText: "Access Denied",
                description: "You have previously denied \(mediaTypeDescription.lowercased()) access. Please enable it in the Settings app if you wish to use this feature.",
                systemImage: "hand.raised.slash.fill",
                color: .red
            )
            Button("Open Settings") {
                openSettings()
            }
            .buttonStyle(.bordered)
        }
    }
}

// View shown when permission is RESTRICTED
struct RestrictedView: View {
    let mediaTypeDescription: String

    var body: some View {
        StatusSectionView(
            statusText: "Access Restricted",
            description: "\(mediaTypeDescription) access is restricted, possibly due to system settings like Screen Time or Parental Controls. This cannot be changed by the app.",
            systemImage: "xmark.octagon.fill",
            color: .red
        )
    }
}

// View shown for unknown statussaf
struct UnknownStatusView: View {
     var body: some View {
         StatusSectionView(
             statusText: "Unknown Status",
             description: "An unexpected authorization status was encountered.",
             systemImage: "exclamationmark.triangle.fill",
             color: .gray
         )
     }
 }

// MARK: - Reusable UI Components (Status/Button/Footer)

struct StatusSectionView: View {
    let statusText: String
    let description: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 40)) // Slightly larger icon
                .foregroundColor(color)
            Text(statusText)
                .font(.title2)
                .fontWeight(.semibold)
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical) // Add some vertical padding
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
                .padding(.horizontal)
        }
        .buttonStyle(.borderedProminent)
         .controlSize(.large) // Make button slightly larger
        .padding(.top)
    }
}

// Helper Function to Open Settings App
func openSettings() {
    print("Attempting to open Settings...")
    guard let url = URL(string: UIApplication.openSettingsURLString),
          UIApplication.shared.canOpenURL(url) else {
        print("Failed to create settings URL or cannot open it.")
        // Optionally show an alert to the user here
        return
    }
    UIApplication.shared.open(url)
}

struct StatusFooterView: View {
    let useRealAPI: Bool
    let mediaType: AVMediaType

    var body: some View {
         VStack(spacing: 4) {
            Text(useRealAPI ? "Using REAL device permissions." : "Using FAKE simulated permissions.")
                .font(.caption)
                .foregroundColor(useRealAPI ? .purple : .orange)

            if useRealAPI {
                let requiredKey = (mediaType == .video) ? "NSCameraUsageDescription" : "NSMicrophoneUsageDescription"
                Text("Ensure `\(requiredKey)` is set in Info.plist")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.bottom, 5) // Add slight padding at the very bottom
    }
}

// MARK: - Previews

struct AuthorizationFlowView_Previews: PreviewProvider {
    static var previews: some View {
        // --- Camera Previews ---
        Group {
            AuthorizationFlowView(mediaType: .video) // Default Fake .notDetermined
                .previewDisplayName("Video (Fake - Not Determined)")

             // Preview specific states using FakeManager
            AuthorizationFlowView(mediaType: .video)
                 .onAppear { // Simulate state change for preview
                     // Access internal state for preview purposes (only works with @State)
                     // A better approach for complex preview state might involve a custom initializer or setup function.
                     // For simplicity here, we assume the default FakeAuthorizationManager starts as .notDetermined
                     // and we can manually change it *after* the view appears for previewing.
                     if let fakeMgr = (AuthorizationFlowView(mediaType: .video).authManager as? FakeAuthorizationManager) {
                          fakeMgr.setStatus(.authorized) // Need to find a way to set this on the *preview instance*
                     }
                 }
                .previewDisplayName("Video (Fake - Authorized)") // This preview setup needs refinement

             AuthorizationFlowView(mediaType: .video)
                 .environment(\.colorScheme, .dark)
                .previewDisplayName("Video (Fake - Dark)")

        }

        // --- Audio Previews ---
         Group {
             AuthorizationFlowView(mediaType: .audio) // Default Fake .notDetermined
                 .previewDisplayName("Audio (Fake - Not Determined)")

             // Simulate Audio Authorized (needs refinement like video preview)
             AuthorizationFlowView(mediaType: .audio)
                 .previewDisplayName("Audio (Fake - Authorized)")

             AuthorizationFlowView(mediaType: .audio)
                 .previewDisplayName("Audio (Fake - Denied)") // Simulate Denied

         }
    }
}

/*
 ========================================
 !! IMPORTANT INFO.PLIST REQUIREMENTS !!
 ========================================
 For the REAL API mode to function correctly when running on a device or simulator:

 1. CAMERA ACCESS:
    - Add the key `Privacy - Camera Usage Description` (`NSCameraUsageDescription`) to your `Info.plist`.
    - Provide a *clear and concise* string value explaining exactly why your app needs access to the camera (e.g., "To take photos and record videos for your profile.").

 2. MICROPHONE ACCESS:
    - Add the key `Privacy - Microphone Usage Description` (`NSMicrophoneUsageDescription`) to your `Info.plist`.
    - Provide a string value explaining why your app needs microphone access (e.g., "To record audio messages and capture sound during video recording.").

FAILURE TO ADD THESE KEYS AND DESCRIPTIONS WILL CAUSE YOUR APP TO CRASH WHEN REQUESTING PERMISSION USING THE REAL API.
 ========================================
 */
