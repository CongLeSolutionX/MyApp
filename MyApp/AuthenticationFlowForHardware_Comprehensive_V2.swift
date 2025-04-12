////
////  AuthenticationFlowForHardware_Comprehensive_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/12/25.
////
//import SwiftUI
//@preconcurrency import AVFoundation
//import Combine
//
//// MARK: - Authorization Managing Protocol (Unchanged)
//@MainActor
//protocol AuthorizationManaging: ObservableObject {
//    var currentStatus: AVAuthorizationStatus { get }
//    var mediaType: AVMediaType { get }
//    func checkStatus()
//    func requestAccess() async -> Bool
//}
//
//// MARK: - Real/Fake Authorization Managers (Unchanged)
//@MainActor
//class RealAuthorizationManager: AuthorizationManaging {
//    @Published private(set) var currentStatus: AVAuthorizationStatus
//    let mediaType: AVMediaType
//
//    init(mediaType: AVMediaType) {
//        self.mediaType = mediaType
//        self.currentStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
//        print("RealAuthManager Initialized for \(mediaType.rawValue) with actual state: \(currentStatus)")
//    }
//
//    func checkStatus() {
//        let newStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
//        if newStatus != currentStatus {
//            currentStatus = newStatus
//            print("RealAuthManager: Status for \(mediaType.rawValue) updated to: \(currentStatus)")
//        } else {
//             print("RealAuthManager: Status for \(mediaType.rawValue) remains: \(currentStatus)")
//        }
//    }
//
//    func requestAccess() async -> Bool {
//        guard currentStatus == .notDetermined else {
//            print("RealAuthManager: Access request attempted but status is not .notDetermined (\(currentStatus)). Ignoring.")
//            return currentStatus == .authorized
//        }
//        print("RealAuthManager: Requesting real access for \(mediaType.rawValue)...")
//        let granted = await AVCaptureDevice.requestAccess(for: mediaType)
//        // Status update MUST happen on the MainActor as currentStatus is @Published
//        self.currentStatus = granted ? .authorized : .denied
//        print("RealAuthManager: Access request completed for \(mediaType.rawValue). Granted: \(granted). New status: \(self.currentStatus)")
//        return granted
//    }
//}
//
//@MainActor
//class FakeAuthorizationManager: AuthorizationManaging {
//    @Published private(set) var currentStatus: AVAuthorizationStatus
//    let mediaType: AVMediaType
//
//    init(mediaType: AVMediaType, initialState: AVAuthorizationStatus = .notDetermined) {
//        self.mediaType = mediaType
//        self.currentStatus = initialState
//        print("FakeAuthManager Initialized for \(mediaType.rawValue) with initial fake state: \(currentStatus)")
//    }
//
//    func checkStatus() {
//        print("FakeAuthManager: Checking fake status for \(mediaType.rawValue): \(currentStatus)")
//        // No actual work needed
//    }
//
//    func requestAccess() async -> Bool {
//        guard currentStatus == .notDetermined else {
//            print("FakeAuthManager: Access request attempted but status is not .notDetermined (\(currentStatus)). Ignoring.")
//            return currentStatus == .authorized
//        }
//        print("FakeAuthManager: Simulating access request for \(mediaType.rawValue)...")
//        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
//        let granted = Bool.random()
//        // Status update MUST happen on MainActor
//        self.currentStatus = granted ? .authorized : .denied
//        print("FakeAuthManager: Simulated access request result for \(mediaType.rawValue). Granted: \(granted). New status: \(self.currentStatus)")
//        return granted
//    }
//
//    // This method is already @MainActor isolated, so direct mutation is fine.
//    func setStatus(_ status: AVAuthorizationStatus) {
//         print("FakeAuthManager: Manually setting fake status to \(status) for \(self.mediaType.rawValue)")
//         self.currentStatus = status
//    }
//}
//
//// MARK: - Camera Feature Components
//@MainActor
//class CameraService: ObservableObject {
//    @Published var error: Error?
//    @Published var isSessionRunning = false
//
//    // AVCaptureSession is thread-safe *enough* for configuration and start/stop
//    // It's okay to keep this property, but be careful how it's accessed.
//    let session = AVCaptureSession()
//    private let sessionQueue = DispatchQueue(label: "com.example.sessionQueue")
//    private var captureDevice: AVCaptureDevice? // Okay to keep as MainActor-isolated for setup phase
//
//    let previewLayer: AVCaptureVideoPreviewLayer // No change needed here
//
//    init() {
//        previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        print("CameraService Initialized")
//    }
//
//    // --- Setup Session ---
//    // This part usually runs before the sessionQueue starts intense work.
//    // Keep it synchronous @MainActor for simplicity during setup.
//    func setupSession() {
//        print("CameraService: Setting up session (on MainActor)...")
//        guard captureDevice == nil else {
//            print("CameraService: Session already set up.")
//            return // Prevent redundant setup
//        }
//        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
//            self.error = CameraError.deviceUnavailable // Mutating @Published on MainActor is fine
//            print("CameraService Error: Default video device unavailable.")
//            return
//        }
//        self.captureDevice = videoDevice // Mutating on MainActor is fine
//
//        // Perform potentially blocking configuration asynchronously
//        // Capture needed values *before* the async block
//        let session = self.session // Capture session instance
//        let device = self.captureDevice // Capture device instance
//
//        sessionQueue.async { // Switch to background queue
//            print("CameraService: Configuring session on background queue...")
//             guard let device = device else {
//                 // Error setting should be dispatched back
//                 DispatchQueue.main.async { self.error = CameraError.setupFailed }
//                 print("CameraService Error: Device became nil before configuration.")
//                 return
//             }
//            session.beginConfiguration()
//            session.sessionPreset = .photo // Set preset on background
//
//            // Remove existing inputs before adding new ones (important!)
//            session.inputs.forEach { session.removeInput($0) }
//
//            do {
//                let input = try AVCaptureDeviceInput(device: device)
//                if session.canAddInput(input) {
//                    session.addInput(input)
//                    print("CameraService: Input device added on background queue.")
//                } else {
//                    // Dispatch error update back to main actor
//                    DispatchQueue.main.async { self.error = CameraError.cannotAddInput }
//                    print("CameraService Error: Cannot add input device (background).")
//                }
//            } catch let configError {
//                // Dispatch error update back to main actor
//                DispatchQueue.main.async { self.error = configError }
//                print("CameraService Error: Failed to create device input - \(configError.localizedDescription) (background)")
//            }
//
//            session.commitConfiguration()
//            print("CameraService: Session configuration committed on background queue.")
//        }
//    }
//
//    // --- Start Session ---
//    func startSession() {
//        // Checks happen on MainActor
//        print("CameraService: startSession requested (on MainActor)...")
//        guard !isSessionRunning else {
//            print("CameraService: Attempted to start already running session.")
//            return
//        }
//        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
//            print("CameraService Error: Authorization denied/not determined, cannot start session.")
//            self.error = CameraError.notAuthorized // Okay on MainActor
//            return
//        }
//
//        // Capture session before going to background
//        let session = self.session
//
//        sessionQueue.async { // Switch to background queue for potential blocking call
//            print("CameraService: Starting session on background queue...")
//            session.startRunning() // Call startRunning on the background queue
//
//            // Capture the running state *on the background queue* after calling startRunning
//            let running = session.isRunning
//
//            // Dispatch the state update back to the main actor
//            DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                self.isSessionRunning = running // Update @Published property on MainActor
//                if running {
//                    print("CameraService: Session started successfully (MainActor update).")
//                    self.error = nil // Clear previous errors if successful
//                } else {
//                    print("CameraService: Failed to start session (MainActor update).")
//                    // Optionally set an error if startRunning failed silently
//                    if self.error == nil { self.error = CameraError.setupFailed }
//                }
//            }
//        }
//    }
//
//    // --- Stop Session ---
//    func stopSession() {
//        // Checks happen on MainActor
//         print("CameraService: stopSession requested (on MainActor)...")
//        guard isSessionRunning else {
//            print("CameraService: Attempted to stop already stopped session.")
//            return
//        }
//
//        // Capture session before going to background
//        let session = self.session
//
//        // Immediately update state on MainActor for responsiveness (optional but good UI practice)
//        // self.isSessionRunning = false // Or wait for the background confirmation
//
//        sessionQueue.async { // Switch to background queue for potential blocking call
//            print("CameraService: Stopping session on background queue...")
//            session.stopRunning() // Call stopRunning on the background queue
//
//            // Capture the running state *on the background queue* after calling stopRunning
//            let running = session.isRunning
//
//            // Dispatch the state update back to the main actor
//            DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                self.isSessionRunning = running // Update @Published property on MainActor
//                print("CameraService: Session stopped. Running: \(running) (MainActor update)")
//            }
//        }
//    }
//
//     deinit {
//         // Deinit might be called on any thread, ensure stop is safe or dispatched
//         // For simplicity, if session is running, dispatch the stop call
//         if session.isRunning {
//             print("CameraService Deinit: Session still running, attempting to stop.")
//             // Call the existing stopSession which handles threading correctly
//             // Dispatching this ensures it doesn't block the deinit thread if called from background
//              DispatchQueue.main.async { // Ensure call originates from main actor context if needed
//                  self.stopSession()
//              }
//              // Or directly dispatch to session queue if stopSession logic allows:
//              /*
//              sessionQueue.async { [weak session] in
//                  session?.stopRunning()
//              }
//              */
//         } else {
//              print("CameraService Deinitialized")
//         }
//     }
//}
//
//enum CameraError: LocalizedError {
//    case deviceUnavailable
//    case cannotAddInput
//    case notAuthorized
//    case setupFailed
//
//    var errorDescription: String? {
//        switch self {
//        case .deviceUnavailable: return "Camera device is unavailable."
//        case .cannotAddInput: return "Cannot add camera input to the session."
//        case .notAuthorized: return "Camera access is not authorized."
//        case .setupFailed: return "Camera setup or start failed."
//        }
//    }
//}
//
//// UIViewRepresentable for the Camera Preview Layer
//struct CameraPreviewView: UIViewRepresentable {
//    @ObservedObject var service: CameraService
//
//    func makeUIView(context: Context) -> UIView {
//        print("CameraPreviewView: makeUIView")
//        let view = UIView()
//        view.backgroundColor = .black
//        service.previewLayer.frame = view.bounds // Configure frame
//
//        DispatchQueue.main.async {
//            if let connection = service.previewLayer.connection { // First, unwrap the connection
//                // *** CORRECT USAGE: Call the function with the desired angle ***
//                if connection.isVideoRotationAngleSupported(90.0) { // <-- CALL the function
//                    connection.videoRotationAngle = 90 // Set the angle (Portrait)
//                    print("CameraPreviewView: Set videoRotationAngle to 90.")
//                } else {
//                    // Handle case where the 90-degree angle is specifically not supported
//                    print("CameraPreviewView: Warning - Rotation angle of 90 degrees is not supported on this connection.")
//                }
//
//                // Add the sublayer *after* configuration checks
//                if view.window != nil {
//                     view.layer.addSublayer(service.previewLayer)
//                     print("CameraPreviewView: Preview layer added.")
//                } else {
//                     print("CameraPreviewView: Warning - View was potentially removed before layer could be added.")
//                }
//
//            } else {
//                // Handle case where the connection doesn't exist yet
//                print("CameraPreviewView: Warning - Connection not available at makeUIView time.")
//            }
//        }
//
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        print("CameraPreviewView: updateUIView - Updating layer frame")
//        DispatchQueue.main.async {
//            service.previewLayer.frame = uiView.bounds
//            // Optional rotation update logic here...
//            // Remember to call isVideoRotationAngleSupported(angle) here too if updating
//        }
//    }
//}
//
//// MARK: - Audio Feature Components
//@MainActor
//class AudioLevelMonitor: ObservableObject {
//    @Published var audioLevel: Float = 0.0
//    @Published var error: Error?
//    @Published var isMonitoring = false
//
//    private var audioRecorder: AVAudioRecorder?
//    private var timer: AnyCancellable? // Combine Timer is fine
//
//    // AVAudioSession is typically interacted with from the main thread
//    private let audioSession = AVAudioSession.sharedInstance()
//
//    init() {
//        print("AudioLevelMonitor initialized")
//    }
//
//     // Setup usually okay on MainActor before background work
//    private func setupAudioSession() -> Bool {
//         print("AudioLevelMonitor: Setting up audio session (on MainActor)...")
//         do {
//             // Use recommended modern category options if applicable
//             try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .allowBluetoothA2DP])
//             try audioSession.setActive(true)
//             print("AudioLevelMonitor: Audio session activated.")
//             return true
//         } catch let sessionError {
//             self.error = sessionError // Mutating @Published on MainActor is fine
//             print("AudioLevelMonitor Error: Failed to set up audio session - \(sessionError.localizedDescription)")
//             self.isMonitoring = false // Update state on MainActor
//             return false
//         }
//     }
//
//    // --- Start Monitoring ---
//    func startMonitoring() {
//         print("AudioLevelMonitor: Start monitoring requested (on MainActor)...")
//        guard !isMonitoring else {
//            print("AudioLevelMonitor: Already monitoring.")
//            return
//        }
//
//        // Use deprecated property fix: AVAudioApplication (iOS 17+)
//        let permission = AVAudioApplication.shared.recordPermission
//        print("AudioLevelMonitor: Current microphone permission: \(permission)")
//
//        guard permission == .granted else {
//            print("AudioLevelMonitor Error: Microphone access not granted (\(permission)).")
//            self.error = AudioMonitorError.notAuthorized // Okay on MainActor
//            self.isMonitoring = false // Okay on MainActor
//            return
//        }
//
//        // Ensure session is active
//        guard setupAudioSession() else { return } // setupAudioSession handles error state
//
//        // Prepare recorder setup (can happen on MainActor)
//        let url = URL(fileURLWithPath: "/dev/null")
//        let settings: [String: Any] = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 44100.0,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        do {
//             // Recorder initialization can potentially block, though often fast.
//             // For robustness, consider moving this setup to a background thread
//             // if experiencing hitches, but starting simple here.
//             let recorder = try AVAudioRecorder(url: url, settings: settings)
//             recorder.isMeteringEnabled = true
//             self.audioRecorder = recorder // Okay on MainActor
//
//             // Start recording (can block) - move to background
//             DispatchQueue.global(qos: .userInitiated).async { [weak self, weak recorder] in
//                 print("AudioLevelMonitor: Starting recorder on background thread...")
//                 guard let self = self, let recorder = recorder else { return }
//
//                 let success = recorder.record()
//
//                 // Capture meter state from background
//                 let isMeteringEnabled = recorder.isMeteringEnabled
//                 let isRecording = recorder.isRecording
//
//                 // Dispatch updates back to MainActor
//                 DispatchQueue.main.async {
//                      if success && isRecording {
//                         self.isMonitoring = true // Update @Published on MainActor
//                         self.error = nil // Clear previous errors
//                         print("AudioLevelMonitor: Recording started successfully (MainActor update).")
//                         if isMeteringEnabled {
//                             self.startTimer() // Timer needs to be started on MainActor
//                         } else {
//                             print("AudioLevelMonitor: Warning - Metering not enabled after starting.")
//                         }
//                     } else {
//                         self.isMonitoring = false // Update @Published on MainActor
//                         self.error = AudioMonitorError.recorderSetupFailed // Update @Published on MainActor
//                         print("AudioLevelMonitor Error: Failed to start recording (MainActor update). Success: \(success), IsRecording: \(isRecording)")
//                         self.audioRecorder = nil // Clear recorder if failed
//                     }
//                 }
//             }
//
//        } catch let recorderError {
//            self.error = recorderError // Okay on MainActor
//            print("AudioLevelMonitor Error: Failed to initialize AVAudioRecorder - \(recorderError.localizedDescription) (MainActor)")
//            self.isMonitoring = false // Okay on MainActor
//            self.audioRecorder = nil
//        }
//    }
//
//    // --- Stop Monitoring ---
//    func stopMonitoring() {
//         print("AudioLevelMonitor: Stop monitoring requested (on MainActor)...")
//        guard isMonitoring else {
//            print("AudioLevelMonitor: Not monitoring, cannot stop.")
//            return
//        }
//
//        // Stop timer immediately on MainActor
//        timer?.cancel()
//        timer = nil
//        print("AudioLevelMonitor: Metering timer stopped (MainActor).")
//
//        // Capture recorder before going to background
//        let recorder = self.audioRecorder
//        self.audioRecorder = nil // Clear reference on MainActor
//
//        // Update state optimistically on MainActor
//        self.isMonitoring = false
//        self.audioLevel = 0
//
//        // Stop recorder on background thread
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//             print("AudioLevelMonitor: Stopping recorder on background thread...")
//             recorder?.stop() // Stop recording in the background
//
//             // Deactivate session in the background (can also block potentially)
//            do {
//                try AVAudioSession.sharedInstance().setActive(false) // Use the captured instance or recreate if necessary
//                print("AudioLevelMonitor: Audio session deactivated (background).")
//            } catch let sessionError {
//                print("AudioLevelMonitor Warning: Failed to deactivate audio session - \(sessionError.localizedDescription) (background)")
//                // Optionally dispatch error update back to main if needed
//                // DispatchQueue.main.async { self?.error = sessionError }
//            }
//        }
//    }
//
//    // Timer callback should be on MainActor as it updates @Published property
//    private func startTimer() {
//         print("AudioLevelMonitor: Starting metering timer (on MainActor)...")
//        timer = Timer.publish(every: 0.1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                // updateLevel accesses audioRecorder, which *should* be safe here
//                // if start/stop correctly manage its lifecycle. But accessing it directly
//                // is still technically accessing MainActor state.
//                // For purity, capture recorder safely or dispatch the updateLevel call.
//                // Simple approach: Assume recorder is valid while timer is running.
//                self?.updateLevel() // Keep updateLevel @MainActor too
//            }
//    }
//
//     // Keep this @MainActor because it mutates self.audioLevel (@Published)
//     // and accesses self.audioRecorder (MainActor isolated)
//    private func updateLevel() {
//        guard let recorder = audioRecorder, recorder.isRecording else {
//            // If recorder is nil or not recording, ensure level is 0.
//            // This check should happen on MainActor since isMonitoring is @Published.
//            if self.audioLevel != 0.0 {
//                 self.audioLevel = 0.0
//            }
//            return
//        }
//
//        // Metering calls can be quick, often okay on MainActor,
//        // but could be moved to background with dispatch back if needed for heavy load.
//        recorder.updateMeters()
//        let averagePower = recorder.averagePower(forChannel: 0)
//
//        let normalizedLevel = mapValue(value: averagePower, fromMin: -60.0, fromMax: 0.0, toMin: 0.0, toMax: 1.0)
//
//        // Check if the level actually changed to avoid unnecessary UI updates
//        if abs(self.audioLevel - normalizedLevel) > 0.01 { // Add tolerance
//            self.audioLevel = normalizedLevel // Update @Published property on MainActor
//        }
//        // print("AudioLevelMonitor: Avg Power: \(averagePower) dB, Norm: \(normalizedLevel) (MainActor)")
//    }
//
//    // Helper mapValue doesn't need actor isolation
//    private func mapValue(value: Float, fromMin: Float, fromMax: Float, toMin: Float, toMax: Float) -> Float {
//         let clampedValue = max(fromMin, min(value, fromMax))
//         let proportion = (clampedValue - fromMin) / (fromMax - fromMin)
//         let mappedValue = toMin + proportion * (toMax - toMin)
//         return mappedValue
//     }
//
//    deinit {
//            // Ensure monitoring is stopped. The check AND the stop call must happen on MainActor.
//            // Schedule a task on the main queue to perform the check and potential cleanup.
//            DispatchQueue.main.async { [weak self] in // Use weak self to avoid retain cycles
//                 guard let self = self else { return } // Ensure self hasn't been deallocated by the time this runs
//
//                 if self.isMonitoring { // Check is now performed safely on the main actor
//                     print("AudioLevelMonitor Deinit: Still monitoring, dispatching stop.")
//                     self.stopMonitoring() // Call the @MainActor isolated stop function
//                 } else {
//                     // Optional logging if needed
//                     print("AudioLevelMonitor Deinit: Check on MainActor confirmed it was not monitoring.")
//                 }
//            }
//            // This print indicates when deinit was *called*, not necessarily when cleanup finished.
//            print("AudioLevelMonitor Deinitialized (Cleanup dispatched to main queue if needed)")
//        }
//}
//
//enum AudioMonitorError: LocalizedError {
//    case notAuthorized
//    case sessionSetupFailed
//    case recorderSetupFailed
//
//    var errorDescription: String? {
//        switch self {
//        case .notAuthorized: return "Microphone access is not authorized."
//        case .sessionSetupFailed: return "Failed to configure the audio session."
//        case .recorderSetupFailed: return "Failed to set up or start the audio recorder."
//        }
//    }
//}
//
//// Simple visualizer view (Unchanged)
//struct AudioLevelMeterView: View {
//    let level: Float // Normalized 0.0 to 1.0
//    let numberOfSegments: Int = 20
//
//    var body: some View {
//        HStack(spacing: 2) {
//            ForEach(0..<numberOfSegments, id: \.self) { index in
//                Capsule()
//                    .fill(colorForSegment(index: index))
//                    .frame(height: 30)
//            }
//        }
//        .frame(minWidth: 150)
//        .padding(.vertical)
//        .drawingGroup()
//    }
//
//    private func colorForSegment(index: Int) -> Color {
//        let levelThreshold = Float(index + 1) / Float(numberOfSegments)
//        let isActive = level >= levelThreshold
//        let hue = Double(index) / Double(numberOfSegments) * 0.3 // Green to Yellow/Org
//        return isActive ? Color(hue: hue, saturation: 0.8, brightness: 0.9) : Color.gray.opacity(0.3)
//    }
//}
//
//// MARK: - Enhanced Authorization Flow View
//struct AuthorizationFlowView: View {
//     // Use @State for the manager instance itself, as it can be replaced
//    @State var authManager: any AuthorizationManaging // Use existential 'any'
//
//    // Services should be @StateObject as this view owns them
//    @StateObject private var cameraService = CameraService()
//    @StateObject private var audioMonitor = AudioLevelMonitor()
//
//    // State for the toggle
//    @State private var useRealAPI: Bool = false
//
//    private let mediaType: AVMediaType
//    private let mediaTypeDescription: String
//
//    // Initialize with a default manager (Fake is safer for previews)
//    init(mediaType: AVMediaType) {
//        self.mediaType = mediaType
//        self.mediaTypeDescription = (mediaType == .video) ? "Camera" : (mediaType == .audio ? "Microphone" : "Media")
//        // Initialize the State variable directly
//        self._authManager = State(initialValue: FakeAuthorizationManager(mediaType: mediaType))
//        print("AuthorizationFlowView Initialized for \(mediaType.rawValue)")
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 10) {
//                // --- API Mode Toggle ---
//                HStack {
//                    Toggle("Use REAL \(mediaTypeDescription) Permissions", isOn: $useRealAPI)
//                        .tint(.purple)
//
//                    if !useRealAPI, let fakeMgr = authManager as? FakeAuthorizationManager {
//                        Menu {
//                            Button(".authorized") { Task { @MainActor in fakeMgr.setStatus(.authorized) } }
//                            Button(".denied") { Task { @MainActor in fakeMgr.setStatus(.denied) } }
//                            Button(".restricted") { Task { @MainActor in fakeMgr.setStatus(.restricted) } }
//                            Button(".notDetermined") { Task { @MainActor in fakeMgr.setStatus(.notDetermined) } }
//                        } label: { Image(systemName: "gearshape.fill").foregroundColor(.gray) }
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 5)
//
//                Divider()
//
//                // --- Dynamic Content Area ---
//                Group {
//                    switch authManager.currentStatus {
//                    case .authorized:
//                        AuthorizedContentView(
//                            mediaType: mediaType,
//                            cameraService: cameraService, // Pass the @StateObject instances
//                            audioMonitor: audioMonitor
//                        )
//                    case .notDetermined:
//                        NotDeterminedView(
//                            mediaTypeDescription: mediaTypeDescription,
//                            requestAction: requestPermission
//                        )
//                    case .denied:
//                        DeniedView(mediaTypeDescription: mediaTypeDescription)
//                    case .restricted:
//                        RestrictedView(mediaTypeDescription: mediaTypeDescription)
//                    @unknown default:
//                        UnknownStatusView()
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow content to expand
//
//                // --- Footer Info ---
//                StatusFooterView(useRealAPI: useRealAPI, mediaType: mediaType)
//
//            } // End Main VStack
//            .navigationTitle("\(mediaTypeDescription) Access")
//            .navigationBarTitleDisplayMode(.inline)
//            .onAppear {
//                Task { @MainActor in // Ensure checkStatus is called on MainActor
//                     print("AuthorizationFlowView: onAppear - Checking status...")
//                    authManager.checkStatus()
//                }
//            }
//             // Use new onChange syntax (zero or two parameters)
//            .onChange(of: useRealAPI) { // Zero parameter version
//                 switchManager(useReal: useRealAPI) // Access the state variable directly
//             }
//            .onChange(of: authManager.currentStatus) { // Zero parameter version
//                 print("AuthorizationFlowView: Status changed to \(authManager.currentStatus).")
//                 // Cleanup logic is now primarily handled within AuthorizedContentView's onDisappear
//            }
//
//        } // End NavigationView
//        // Apply the MainActor context to the whole view hierarchy if necessary,
//        // although individual components handle their needs.
//        // .environment(\.mainActor, MainActor.shared) // Usually not needed explicitly
//    }
//
//    // Make helper funcs private and ensure MainActor context if they mutate state
//    @MainActor
//    private func switchManager(useReal: Bool) {
//         print("AuthorizationFlowView: Switching manager. Use Real: \(useReal)")
//         // Stop monitoring/session BEFORE switching manager instance
//         // Ensure these calls are made correctly respecting actor boundaries
//        if cameraService.isSessionRunning { cameraService.stopSession() }
//        if audioMonitor.isMonitoring { audioMonitor.stopMonitoring() }
//
//        if useReal {
//            authManager = RealAuthorizationManager(mediaType: mediaType)
//        } else {
//            authManager = FakeAuthorizationManager(mediaType: mediaType)
//        }
//        authManager.checkStatus() // Check status of the new manager
//    }
//
//    @MainActor
//    private func requestPermission() {
//        Task { // Task inherits MainActor context here
//             print("AuthorizationFlowView: Requesting permission via manager...")
//            _ = await authManager.requestAccess() // requestAccess is MainActor isolated
//            print("AuthorizationFlowView: Request finished. New status: \(authManager.currentStatus)")
//        }
//    }
//}
//
//// MARK: - Content Views for Different States (Structure largely unchanged)
//
//struct AuthorizedContentView: View {
//    let mediaType: AVMediaType
//    // Use @ObservedObject here as the parent view owns the service instances
//    @ObservedObject var cameraService: CameraService
//    @ObservedObject var audioMonitor: AudioLevelMonitor
//
//    var body: some View {
//        VStack {
//            if mediaType == .video {
//                CameraFeatureView(service: cameraService)
//            } else if mediaType == .audio {
//                AudioFeatureView(monitor: audioMonitor)
//            } else {
//                Text("✅ Access Granted for \(mediaType.rawValue)")
//                    .foregroundColor(.green)
//            }
//        }
//        .onAppear {
//             print("AuthorizedContentView: onAppear")
//              // Ensure service calls respect MainActor
//              Task { @MainActor in
//                 if mediaType == .video {
//                     cameraService.setupSession() // Setup first
//                     cameraService.startSession()
//                 } else if mediaType == .audio {
//                     audioMonitor.startMonitoring()
//                 }
//             }
//        }
//        .onDisappear {
//             print("AuthorizedContentView: onDisappear")
//             // Ensure service calls respect MainActor
//             Task { @MainActor in
//                 if mediaType == .video && cameraService.isSessionRunning {
//                     cameraService.stopSession()
//                 } else if mediaType == .audio && audioMonitor.isMonitoring {
//                     audioMonitor.stopMonitoring()
//                 }
//             }
//        }
//    }
//}
//
//struct CameraFeatureView: View {
//    @ObservedObject var service: CameraService
//
//    var body: some View {
//        ZStack {
//            // Show preview layer first if no error and running
//            if service.error == nil && service.isSessionRunning {
//                CameraPreviewView(service: service)
//            } else if service.error == nil && !service.isSessionRunning {
//                // Show loading indicator while session starts/restarts if no error
//                VStack {
//                    ProgressView()
//                        .padding(.bottom)
//                    Text("Starting Camera...")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//            }
//
//            // Overlay error message if present
//            if let error = service.error {
//                VStack {
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .foregroundColor(.red).font(.largeTitle)
//                    Text("Camera Error")
//                        .font(.headline)
//                    Text(error.localizedDescription)
//                        .font(.caption)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(.ultraThinMaterial) // Make error more visible
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.black.opacity(0.9))
//        .cornerRadius(10)
//        .padding()
//        // Animate changes between states
//        .animation(.easeInOut, value: service.isSessionRunning)
//        .animation(.easeInOut, value: service.error != nil)
//
//    }
//}
//
//struct AudioFeatureView: View {
//    @ObservedObject var monitor: AudioLevelMonitor
//
//    var body: some View {
//        VStack {
//             Text("Live Microphone Level")
//                 .font(.headline).padding(.bottom)
//
//            if monitor.error == nil && monitor.isMonitoring {
//                 AudioLevelMeterView(level: monitor.audioLevel)
//                     .padding(.horizontal)
//                 Text(String(format: "Level: %.2f", monitor.audioLevel))
//                     .font(.caption)
//                     .foregroundColor(.gray)
//             } else if monitor.error == nil && !monitor.isMonitoring {
//                  // Show loading indicator while recorder starts if no error
//                  ProgressView()
//                      .padding(.bottom)
//                  Text("Starting Microphone...")
//                      .font(.caption)
//                     .foregroundColor(.gray)
//             }
//
//             // Display error if present
//             if let error = monitor.error {
//                 VStack {
//                     Image(systemName: "exclamationmark.triangle.fill")
//                         .foregroundColor(.red).font(.largeTitle)
//                     Text("Audio Error")
//                         .font(.headline)
//                     Text(error.localizedDescription)
//                         .font(.caption)
//                         .multilineTextAlignment(.center)
//                         .padding()
//                 }
//                 .padding(.top) // Add space above error
//             }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding()
//         // Animate changes between states
//         .animation(.easeInOut, value: monitor.isMonitoring)
//         .animation(.easeInOut, value: monitor.error != nil)
//    }
//}
//
//// NotDeterminedView (Unchanged structure, action passed correctly)
//struct NotDeterminedView: View {
//    let mediaTypeDescription: String
//    let requestAction: () -> Void // Action closure
//
//    var body: some View {
//        VStack(spacing: 20) {
//            StatusSectionView(
//                statusText: "Permission Needed",
//                description: "To use the \(mediaTypeDescription.lowercased()) feature, the app needs your permission.",
//                systemImage: "hand.point.up.left",
//                color: .blue
//            )
//            RequestPermissionButton(
//                mediaTypeDescription: mediaTypeDescription,
//                action: requestAction // Pass the action closure
//            )
//        }
//         .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills space
//    }
//}
//
//// DeniedView (Unchanged structure)
//struct DeniedView: View {
//    let mediaTypeDescription: String
//
//    var body: some View {
//        VStack(spacing: 20) {
//            StatusSectionView(
//                statusText: "Access Denied",
//                description: "You have previously denied \(mediaTypeDescription.lowercased()) access. Please enable it in the Settings app if you wish to use this feature.",
//                systemImage: "hand.raised.slash.fill",
//                color: .red
//            )
//            Button("Open Settings") { openSettings() }
//            .buttonStyle(.bordered)
//        }
//         .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//// RestrictedView (Unchanged structure)
//struct RestrictedView: View {
//    let mediaTypeDescription: String
//
//    var body: some View {
//         VStack { // Wrap in VStack for alignment if needed
//            StatusSectionView(
//                statusText: "Access Restricted",
//                description: "\(mediaTypeDescription) access is restricted, possibly due to system settings like Screen Time or Parental Controls. This cannot be changed by the app.",
//                systemImage: "xmark.octagon.fill",
//                color: .orange // Maybe orange is better than red?
//            )
//         }
//         .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//// UnknownStatusView (Unchanged structure)
//struct UnknownStatusView: View {
//     var body: some View {
//         VStack {
//             StatusSectionView(
//                 statusText: "Unknown Status",
//                 description: "An unexpected authorization status was encountered.",
//                 systemImage: "exclamationmark.triangle.fill",
//                 color: .gray
//             )
//         }
//         .frame(maxWidth: .infinity, maxHeight: .infinity)
//     }
// }
//
//// MARK: - Reusable UI Components (Unchanged)
//
//struct StatusSectionView: View { /* Unchanged */
//    let statusText: String
//    let description: String
//    let systemImage: String
//    let color: Color
//
//    var body: some View {
//        VStack(spacing: 10) {
//            Image(systemName: systemImage)
//                .font(.system(size: 40))
//                .foregroundColor(color)
//                 .padding(.bottom, 5) // Add space below icon
//            Text(statusText)
//                .font(.title2)
//                .fontWeight(.semibold)
//            Text(description)
//                .font(.body)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//        }
//        .padding(.vertical)
//    }
//}
//struct RequestPermissionButton: View { /* Unchanged */
//    let mediaTypeDescription: String
//    let action: () -> Void
//
//    var body: some View {
//        Button {
//            action()
//        } label: {
//            Label("Request \(mediaTypeDescription) Access", systemImage: "hand.point.up.left.fill")
//                .padding(.horizontal)
//        }
//        .buttonStyle(.borderedProminent)
//         .controlSize(.large)
//        .padding(.top)
//    }
//}
//
//// Open Settings Helper (Unchanged)
// func openSettings() { /* Unchanged */
//     print("Attempting to open Settings...")
//     guard let url = URL(string: UIApplication.openSettingsURLString),
//           UIApplication.shared.canOpenURL(url) else {
//         print("Failed to create settings URL or cannot open it.")
//         return
//     }
//     UIApplication.shared.open(url)
// }
//
//struct StatusFooterView: View { /* Unchanged */
//     let useRealAPI: Bool
//     let mediaType: AVMediaType
//
//     var body: some View {
//          VStack(spacing: 4) {
//             Text(useRealAPI ? "Using REAL device permissions." : "Using FAKE simulated permissions.")
//                 .font(.caption)
//                 .foregroundColor(useRealAPI ? .purple : .orange)
//             if useRealAPI {
//                 let requiredKey = (mediaType == .video) ? "NSCameraUsageDescription" : "NSMicrophoneUsageDescription"
//                 Text("Ensure `\(requiredKey)` is set in Info.plist")
//                     .font(.caption2)
//                     .foregroundColor(.gray)
//                     .multilineTextAlignment(.center)
//                     .padding(.horizontal)
//             }
//         }
//         .padding(.bottom, 5)
//     }
// }
//
//// MARK: - Previews (May need adjustment based on how @MainActor affects preview initialization)
//
// #Preview("Video (Fake - Not Determined)") { // New #Preview Macro
//     AuthorizationFlowView(mediaType: .video)
// }
//
// #Preview("Video (Fake - Authorized)") {
//     let view = AuthorizationFlowView(mediaType: .video)
//     if let fakeMgr = view.authManager as? FakeAuthorizationManager {
//         // This direct mutation might not work reliably in previews.
//         // Consider passing initial state for previews.
//         fakeMgr.setStatus(.authorized)
//     }
//     return view
// }
//
//// #Preview("Audio (Fake - Authorized)") {
////     let view = AuthorizationFlowView(mediaType: .audio)
////      if let fakeMgr = view.authManager as? FakeAuthorizationManager {
////           fakeMgr.setStatus(.authorized)
////      }
////     view
//// }
//
// // Add more previews for Denied, Restricted etc. as needed
//
///*
// ========================================
// !! IMPORTANT INFO.PLIST REQUIREMENTS !! (Unchanged)
// ========================================
// ... (Keep the Info.plist reminder) ...
// ========================================
// */
