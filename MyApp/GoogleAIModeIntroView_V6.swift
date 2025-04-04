////
////  GoogleAIModeIntroView_V6_With_Voice_search.swift
////  MyApp
////
////  Created by Cong Le on 4/4/25.
////
//
//import SwiftUI
//import AVFoundation
//import Speech // <-- Import the Speech framework
//
//struct GoogleAIModeIntroView: View {
//    // --- UI State variables ---
//    @State private var isExperimentOn = true
//    @State private var searchText = ""
//    @State private var isListening = false { // Overall listening state
//        didSet { print("[State Change] isListening updated to: \(isListening)") }
//    }
//    @State private var showMicDeniedAlert = false {
//        didSet { print("[State Change] showMicDeniedAlert updated to: \(showMicDeniedAlert)") }
//    }
//    @State private var showSpeechDeniedAlert = false { // New alert
//        didSet { print("[State Change] showSpeechDeniedAlert updated to: \(showSpeechDeniedAlert)") }
//    }
//    @State private var interactionMessage: String? = nil // For messages like "Listening...", "Denied"
//
//    // --- Permission State ---
//    enum PermissionStatus: String { case undetermined, granted, denied }
//    @State private var micPermissionStatus: PermissionStatus = .undetermined {
//        didSet { print("[State Change] micPermissionStatus updated to: \(micPermissionStatus.rawValue)") }
//    }
//    @State private var speechPermissionStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined {
//        didSet { print("[State Change] speechPermissionStatus updated to: \(speechPermissionStatus.description)") }
//    }
//
//    // --- Speech Recognition Objects ---
//    // Make these properties of the View struct
//    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Or device locale
//    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    @State private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine() // Keep this private let
//
//    // --- Mock data and UI Constants remain the same ---
//        let rainbowGradient = AngularGradient(
//            gradient: Gradient(colors: [
//                .yellow, .orange, .red, .purple, .blue, .green, .yellow
//            ]),
//            center: .center
//        )
//        let buttonBlue = Color(red: 0.6, green: 0.8, blue: 1.0)
//        let darkGrayBackground = Color(white: 0.1)
//        let darkerGrayElement = Color(white: 0.15)
//        let veryDarkBackground = Color(white: 0.05)
//    
//
//    var body: some View {
//        ZStack {
//            darkGrayBackground.ignoresSafeArea()
//
//            VStack(spacing: 30) {
//                searchBarArea()
//                    .padding(.top, 50)
//
//                introductoryContent()
//
//                Spacer()
//            }
//        }
//        .preferredColorScheme(.dark)
//        .onAppear {
//            print("[Lifecycle] GoogleAIModeIntroView appeared.")
//            checkInitialPermissions() // Check both permissions now
//        }
//        // Alerts
//        .alert("Microphone Access Denied", isPresented: $showMicDeniedAlert) { // Mic Alert
//            alertButtons()
//        } message: { Text("To use voice input, please enable microphone access for this app in Settings.") }
//        .alert("Speech Recognition Access Denied", isPresented: $showSpeechDeniedAlert) { // Speech Alert
//             alertButtons()
//        } message: { Text("To transcribe voice, please enable Speech Recognition access for this app in Settings.") }
//    }
//
//    // --- ViewBuilders remain largely the same, but update UI based on new states ---
//
//    @ViewBuilder
//    private func searchBarArea() -> some View {
//        let isMicDisabled = micPermissionStatus == .denied
//        let isSpeechDisabled = speechPermissionStatus == .denied
//        let isFullyDisabled = isMicDisabled || isSpeechDisabled
//        let canListen = !isFullyDisabled && !isListening
//
//        ZStack {
//            // Backgrounds / Decorations (keep as before)
////             veryDarkBackground...
//             Capsule().strokeBorder(rainbowGradient, ...)...
//
//
//            HStack {
//                TextField("Ask anything...", text: $searchText)
//                    .foregroundColor(.white)
//                    .tint(.white)
//                    .padding(.leading, 20)
//                    .disabled(isListening || isFullyDisabled) // Disable text field if listening or permissions denied
//
//                Spacer()
//
//                Button {
//                    print("[UI Action] Microphone button tapped.")
//                    handleMicTap()
//                } label: {
//                    Image(systemName: isFullyDisabled
//                          ? "mic.slash.fill"
//                          : (isListening ? "waveform.circle.fill" : "mic.fill"))
//                        .font(.title2)
//                        .foregroundColor(isFullyDisabled
//                                         ? .gray
//                                         : (isListening ? buttonBlue : .white))
//                }
//                 // Disable button if permissions denied OR if actively listening/processing
//                 .disabled(isFullyDisabled || isListening && recognitionTask != nil)
//                 .padding(.trailing, 5)
//
//                // Camera Button (logic unchanged, update disabled state if needed)
//                Image(systemName: "camera.viewfinder")
//                    .foregroundColor(isFullyDisabled ? .gray : .white)
//                    ...
//                    .allowsHitTesting(!isFullyDisabled)
////                    .onTapGesture { ... }
//            }
//            .frame(height: 50)
//            .background(Color.black.opacity(isListening ? 0.7 : 1.0))
//            .clipShape(Capsule())
//            .padding(.horizontal, 45)
//            .opacity(isFullyDisabled ? 0.7 : 1.0)
//
//            // Overlay message for Listening/Denied status
//            .overlay(
//                Text(interactionMessage ?? "") // Use the interactionMessage state
//                    .font(.caption)
//                    .foregroundColor( messageColor() ) // Dynamic color
//                    .padding(.bottom, 40)
//                    .opacity(interactionMessage != nil ? 1 : 0)
//                    .animation(.easeInOut, value: interactionMessage)
//                , alignment: .bottom
//            )
//        }
//        .frame(height: 100)
//        // Update interaction message whenever relevant states change
//        .onChange(of: isListening) { updateInteractionMessage() }
//        .onChange(of: micPermissionStatus) { updateInteractionMessage() }
//        .onChange(of: speechPermissionStatus) { updateInteractionMessage() }
//        .onAppear { updateInteractionMessage() } // Set initial message
//    }
//
//    // --- introductoryContent unchanged ---
////     @ViewBuilder
////    private func introductoryContent() -> some View { ... } // Keep as before
//
//    // --- aiIcon unchanged ---
////     @ViewBuilder
////    private func aiIcon() -> some View { ... } // Keep as before
//
//     // --- Helper for Alert Buttons ---
//     @ViewBuilder
//    private func alertButtons() -> some View {
//        Button("Open Settings") {
//            print("[Alert Action] User tapped 'Open Settings'")
//            if let url = URL(string: UIApplication.openSettingsURLString),
//               UIApplication.shared.canOpenURL(url) {
//                print("Attempting to open settings URL...")
//                UIApplication.shared.open(url)
//            } else {
//                print("Could not open settings URL.")
//            }
//        }
//        Button("Cancel", role: .cancel) {
//             print("[Alert Action] User tapped 'Cancel'")
//        }
//    }
//
//    // --- Helper for Message Color ---
//    private func messageColor() -> Color {
//        if micPermissionStatus == .denied || speechPermissionStatus == .denied {
//            return .red.opacity(0.8)
//        } else if isListening {
//            return buttonBlue.opacity(0.8)
//        } else {
//            return .clear // No message color if not denied and not listening
//        }
//    }
//
//     // --- Helper to update the on-screen message ---
//     private func updateInteractionMessage() {
//         if micPermissionStatus == .denied {
//             interactionMessage = "Mic Access Denied"
//         } else if speechPermissionStatus == .denied {
//             interactionMessage = "Speech Access Denied"
//         } else if isListening {
//             interactionMessage = "Listening..."
//         } else {
//             interactionMessage = nil // Clear message if all permissions okay and not listening
//         }
//         print("[UI Update] Interaction message set to: \(interactionMessage ?? "nil")")
//     }
//
//    // --- Action & Permission Handling Functions (UPDATED) ---
//
//    private func handleMicTap() {
//        print("[Function Call] handleMicTap() called.")
//        print("  -> Mic Status: \(micPermissionStatus.rawValue), Speech Status: \(speechPermissionStatus.description)")
//
//        if isListening {
//            print("  -> Currently listening. Calling stopListening().")
//            stopListening()
//        } else {
//            // Check permissions sequentially
//            switch micPermissionStatus {
//            case .granted:
//                print("  -> Mic Granted. Checking Speech permission.")
//                checkAndHandleSpeechPermission() // Check speech status
//            case .undetermined:
//                print("  -> Mic Undetermined. Calling requestMicPermission().")
//                requestMicPermission() // Request mic first, will check speech on success
//            case .denied:
//                print("  -> Mic Denied. Setting showMicDeniedAlert = true.")
//                showMicDeniedAlert = true
//            }
//        }
//    }
//
//    private func checkAndHandleSpeechPermission() {
//        switch speechPermissionStatus {
//        case .authorized:
//            print("  -> Speech Authorized. Calling startListening().")
//             startListening() // Both permissions granted, start listening
//        case .notDetermined:
//             print("  -> Speech Undetermined. Calling requestSpeechPermission().")
//            requestSpeechPermission() // Request speech permission
//        case .denied, .restricted:
//             print("  -> Speech Denied/Restricted. Setting showSpeechDeniedAlert = true.")
//            showSpeechDeniedAlert = true
//        @unknown default:
//            print("  -> Unknown Speech Permission status encountered.")
//            showSpeechDeniedAlert = true// Treat unknown as denied for safety
//        }
//    }
//
//
//    private func checkInitialPermissions() {
//        print("[Function Call] checkInitialPermissions() called.")
//
//        // 1. Check Mic Permission (Synchronous)
//        let currentMicPermission = AVAudioApplication.shared.recordPermission
//        print("  -> Current AVAudioApplication.recordPermission: \(currentMicPermission.description)")
//        switch currentMicPermission {
//        case .granted: self.micPermissionStatus = .granted
//        case .denied: self.micPermissionStatus = .denied
//        case .undetermined: self.micPermissionStatus = .undetermined
//        @unknown default: self.micPermissionStatus = .undetermined
//        }
//
//        // 2. Check Speech Permission (Synchronous)
//        let currentSpeechPermission = SFSpeechRecognizer.authorizationStatus()
//        print("  -> Current SFSpeechRecognizer.authorizationStatus: \(currentSpeechPermission.description)")
//        self.speechPermissionStatus = currentSpeechPermission
//
//        // Initial UI message update based on permissions
//        updateInteractionMessage()
//    }
//
//    private func requestMicPermission() {
//        print("[Function Call] requestMicPermission() called.")
//        AVAudioApplication.requestRecordPermission { granted in
//            print("[Permission Callback] requestRecordPermission completed. Granted: \(granted)")
//            DispatchQueue.main.async {
//                print("  -> Updating state on main thread.")
//                self.micPermissionStatus = granted ? .granted : .denied
//                if granted {
//                    print("    -> Mic Permission granted. Now checking/requesting Speech permission.")
//                    // Important: After getting mic, check/request speech
//                    self.checkAndHandleSpeechPermission()
//                } else {
//                    print("    -> Mic Permission denied. Setting showMicDeniedAlert = true.")
//                    self.showMicDeniedAlert = true
//                }
//                self.updateInteractionMessage() // Update message after permission change
//            }
//        }
//    }
//
//    private func requestSpeechPermission() {
//        print("[Function Call] requestSpeechPermission() called.")
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            print("[Permission Callback] requestAuthorization completed. Status: \(authStatus.description)")
//            DispatchQueue.main.async {
//                 print("  -> Updating state on main thread.")
//                self.speechPermissionStatus = authStatus
//                if authStatus == .authorized {
//                    // Now that speech is authorized (and mic presumably already is),
//                    // the user needs to tap the mic button again to start listening.
//                     print("    -> Speech permission granted. User can now tap mic to start.")
//                     // Optionally, you could auto-start listening here if desired,
//                     // but requiring another tap might be better UX.
//                     // self.startListening() // <-- Uncomment to auto-start
//                } else {
//                    print("    -> Speech permission denied/restricted. Setting showSpeechDeniedAlert = true.")
//                    self.showSpeechDeniedAlert = true
//                }
//                 self.updateInteractionMessage() // Update message after permission change
//            }
//        }
//    }
//
//
//    // --- Real-time Listening Functions ---
//
//    private func startListening() {
//        print("[Function Call] startListening() called.")
//        guard !isListening else {
//            print("  -> Already listening or processing. Guarding.")
//            return
//        }
//        guard micPermissionStatus == .granted && speechPermissionStatus == .authorized else {
//            print("  -> Permissions not granted. Cannot start listening. Guarding.")
//            // This case should ideally be prevented by the handleMicTap logic
//            return
//        }
//        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
//            print("  -> Speech recognizer is not available. Cannot start.")
//            // TODO: Show an error message to the user
//             interactionMessage = "Speech engine unavailable"
//            return
//        }
//
//        // 1. Reset state
//        searchText = "" // Clear previous text
//         print("  -> Search text cleared.")
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            print("  -> Failed to create SFSpeechAudioBufferRecognitionRequest.")
//            return
//        }
//        recognitionRequest.shouldReportPartialResults = true // Get live results
//        // recognitionRequest.requiresOnDeviceRecognition = false // Use server-based by default (often more accurate, requires network)
//
//
//        // 2. Configure Audio Session
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            print("  -> Configuring Audio Session.")
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//             print("  -> Audio Session configured and activated.")
//        } catch {
//            print("  -> ERROR configuring audio session: \(error.localizedDescription)")
//            cleanupListeningResources()
//            return
//        }
//
//        // 3. Setup Audio Engine Input
//        let inputNode = audioEngine.inputNode
//         print("  -> Got Audio Engine Input Node.")
//
//        // 4. Start Recognition Task
//        print("  -> Starting SFSpeechRecognitionTask.")
//        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//            guard let self = self else { return } // Avoid retain cycles
//            var isFinal = false
//
//            if let result = result {
//                 let recognizedText = result.bestTranscription.formattedString
//                print("[Recognition Result] Partial/Final: '\(recognizedText)' (isFinal: \(result.isFinal))")
//                DispatchQueue.main.async {
//                     self.searchText = recognizedText // Update UI on main thread
//                }
//                isFinal = result.isFinal
//            }
//
//            if error != nil || isFinal {
//                print("  -> Recognition task ending. Error: \(error?.localizedDescription ?? "None"), isFinal: \(isFinal)")
//                // Stop audio engine and clean up *even if there's an error*
//                DispatchQueue.main.async { // Ensure cleanup is on main thread
//                     self.stopListening()
//                }
//            }
//        }
//
//        // 5. Setup Audio Tap
//         print("  -> Installing tap on input node.")
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        // Check if format is valid before installing tap
//        guard recordingFormat.sampleRate > 0 else {
//             print("  -> ERROR: Invalid recording format sample rate (\(recordingFormat.sampleRate)). Cannot install tap.")
//             cleanupListeningResources()
//            // Optionally show an error to the user
//            interactionMessage = "Audio format error"
//            return
//         }
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//            // Append buffer to the recognition request
//            self.recognitionRequest?.append(buffer)
//        }
//
//        // 6. Prepare and Start Engine
//        do {
//            print("  -> Preparing and starting Audio Engine.")
//            audioEngine.prepare()
//            try audioEngine.start()
//             print("  -> Audio Engine started successfully.")
//            // Successfully started
//            DispatchQueue.main.async {
//                 self.isListening = true // Update UI state ONLY after engine starts
//                 self.updateInteractionMessage()
//            }
//        } catch {
//            print("  -> ERROR starting audio engine: \(error.localizedDescription)")
//             cleanupListeningResources() // Clean up if engine fails to start
//        }
//    }
//
//    private func stopListening() {
//        print("[Function Call] stopListening() called.")
//        // Only proceed if the engine is actually running
//        guard audioEngine.isRunning else {
//            print("  -> Audio engine not running. Cleaning up potentially dangling resources.")
//             cleanupListeningResources() // Ensure cleanup even if called unexpectedly
//            return
//        }
//
//         print("  -> Stopping Audio Engine, removing tap, ending/cancelling tasks.")
//         audioEngine.stop()
//         audioEngine.inputNode.removeTap(onBus: 0)
//
//        // End the recognition request audio feed
//         recognitionRequest?.endAudio()
//         print("  -> Ended audio on recognition request.")
//
//
//        // It's important to cancel the task *after* ending audio if you want final results.
//        // If you don't care about the final result after stopping manually, you can cancel earlier.
//        // recognitionTask?.cancel() // Moved to cleanup
//
//         cleanupListeningResources()
//    }
//
//    private func cleanupListeningResources() {
//         // This function should be safe to call multiple times
//         print("[Function Call] cleanupListeningResources() called.")
//
//         // Check if task exists and finish/cancel it
//         if let task = recognitionTask, task.state == .running || task.state == .starting {
//             // task.finish() // Use finish if you need the final result processing to complete
//             task.cancel() // Use cancel for immediate termination
//             print("  -> Cancelled recognition task.")
//         }
//         recognitionTask = nil
//         recognitionRequest = nil // Release the request object
//
//        // Deactivate audio session (optional but good practice)
//        do {
//            try AVAudioSession.sharedInstance().setActive(false)
//             print("  -> Deactivated audio session.")
//        } catch {
//             print("  -> ERROR deactivating audio session: \(error.localizedDescription)")
//         }
//
//
//        // Ensure state is updated on main thread
//         DispatchQueue.main.async {
//             if self.isListening {
//                 self.isListening = false
//                 self.updateInteractionMessage() // Update message after stopping
//             }
//         }
//    }
//}
//
//// Add CustomStringConvertible conformance for SFSpeechRecognizerAuthorizationStatus
//extension SFSpeechRecognizerAuthorizationStatus: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .notDetermined: return "notDetermined"
//        case .denied: return "denied"
//        case .restricted: return "restricted"
//        case .authorized: return "authorized"
//        @unknown default: return "unknown"
//        }
//    }
//}
//
//// AVAudioSession.RecordPermission extension (from previous response, still useful)
//extension AVAudioSession.RecordPermission: CustomStringConvertible { ... }
//
//
//// Preview Provider
//struct GoogleAIModeIntroView_Previews: PreviewProvider { ... }
