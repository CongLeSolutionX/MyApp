//
//  GoogleAIModeIntroView_V7_With_Voice_search.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//

import SwiftUI
import AVFoundation
import Speech // Import the Speech framework

// MARK: - Main View Structure
struct GoogleAIModeIntroView: View {
    // --- UI State variables ---
    @State private var isExperimentOn = true
    @State private var searchText = ""
    @State private var isListening = false { // Overall listening state
        didSet { print("[State Change] isListening updated to: \(isListening)") }
    }
    @State private var showMicDeniedAlert = false {
        didSet { print("[State Change] showMicDeniedAlert updated to: \(showMicDeniedAlert)") }
    }
    @State private var showSpeechDeniedAlert = false { // New alert for speech permission
        didSet { print("[State Change] showSpeechDeniedAlert updated to: \(showSpeechDeniedAlert)") }
    }
    @State private var interactionMessage: String? = nil // For messages like "Listening...", "Denied"
    
    // --- Permission State ---
    // Using an internal enum for clearer state management if preferred, or stick to Apple's enums
    enum PermissionStatusInternal: String { case undetermined, granted, denied }
    @State private var micPermissionStatus: PermissionStatusInternal = .undetermined {
        didSet { print("[State Change] micPermissionStatus updated to: \(micPermissionStatus.rawValue)") }
    }
    // Keep using the official SFSpeechRecognizerAuthorizationStatus for speech
    @State private var speechPermissionStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined {
        didSet { print("[State Change] speechPermissionStatus updated to: \(speechPermissionStatus.description)") }
    }
    
    // --- Speech Recognition Objects ---
    // Use @StateObject for objects managing external events or requiring stable identity
    // Note: SFSpeechRecognizer is lightweight, @State might be fine, but @StateObject is safer practice for complex objects.
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Or device locale: Locale.current
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    // audioEngine manages audio hardware state, keep as private let
    private let audioEngine = AVAudioEngine()
    
    // --- UI Constants ---
    let rainbowGradient = AngularGradient(
        gradient: Gradient(colors: [
            .yellow, .orange, .red, .purple, .blue, .green, .yellow
        ]),
        center: .center
    )
    let buttonBlue = Color(red: 0.6, green: 0.8, blue: 1.0) // Example color
    let darkGrayBackground = Color(white: 0.1)
    let darkerGrayElement = Color(white: 0.15)
    let veryDarkBackground = Color(white: 0.05)
    
    // MARK: - Body
    var body: some View {
        ZStack {
            darkGrayBackground.ignoresSafeArea()
            
            VStack(spacing: 30) {
                searchBarArea()
                    .padding(.top, 50)
                
                introductoryContent()
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            print("[Lifecycle] GoogleAIModeIntroView appeared.")
            checkInitialPermissions() // Check both permissions
        }
        // Alerts
        .alert("Microphone Access Denied", isPresented: $showMicDeniedAlert) {
            alertButtons()
        } message: { Text("To use voice input, please enable microphone access for this app in Settings.") }
            .alert("Speech Recognition Access Denied", isPresented: $showSpeechDeniedAlert) {
                alertButtons()
            } message: { Text("To transcribe voice, please enable Speech Recognition access for this app in Settings.") }
    }
    
    // MARK: - ViewBuilders
    @ViewBuilder
    private func searchBarArea() -> some View {
        let isMicDisabled = micPermissionStatus == .denied
        let isSpeechDisabled = speechPermissionStatus == .denied || speechPermissionStatus == .restricted
        let isFullyDisabled = isMicDisabled || isSpeechDisabled
        //        let canListen = !isFullyDisabled && !isListening // Can activate listening if permissions OK and not already listening
        
        ZStack {
            // Background & Decoration
            veryDarkBackground
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
            
            Capsule()
                .strokeBorder(rainbowGradient, lineWidth: 4)
                .blur(radius: 8)
                .opacity(0.8)
                .frame(height: 55)
                .padding(.horizontal, 40)
            
            
            HStack {
                TextField("Ask anything...", text: $searchText)
                    .foregroundColor(.white)
                    .tint(.white) // Cursor color
                    .padding(.leading, 20)
                    .disabled(isListening || isFullyDisabled) // Disable text field if listening or permissions denied
                
                Spacer()
                
                // --- Microphone Button ---
                Button {
                    print("[UI Action] Microphone button tapped.")
                    handleMicTap()
                } label: {
                    Image(systemName: isFullyDisabled
                          ? "mic.slash.fill" // Disabled icon
                          : (isListening ? "waveform.circle.fill" : "mic.fill")) // Listening / Ready icons
                    .font(.title2)
                    .foregroundColor(isFullyDisabled
                                     ? .gray // Disabled color
                                     : (isListening ? buttonBlue : .white)) // Listening / Ready colors
                }
                // Disable button if permissions denied OR if actively listening/processing
                .disabled(isFullyDisabled || (isListening && recognitionTask != nil))
                .padding(.trailing, 5)
                
                // --- Camera Button ---
                Image(systemName: "camera.viewfinder")
                    .foregroundColor(isFullyDisabled ? .gray : .white)
                    .padding(.trailing, 20)
                    .padding(.leading, 5)
                    .allowsHitTesting(!isFullyDisabled)
                    .onTapGesture {
                        print("[UI Action] Camera button tapped (if enabled).")
                        // Add camera action logic here if needed
                    }
            }
            .frame(height: 50)
            .background(Color.black.opacity(isListening ? 0.7 : 1.0)) // Slightly transparent when listening
            .clipShape(Capsule())
            .padding(.horizontal, 45)
            .opacity(isFullyDisabled ? 0.7 : 1.0) // Dim if disabled
            
            // --- Overlay message for Listening/Denied status ---
            .overlay(
                Text(interactionMessage ?? "") // Use the interactionMessage state
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor( messageColor() ) // Dynamic color based on state
                    .padding(.bottom, 40) // Position below the capsule
                    .opacity(interactionMessage != nil ? 1 : 0) // Show only if message exists
                    .animation(.easeInOut, value: interactionMessage) // Animate appearance
                , alignment: .bottom
            )
        }
        .frame(height: 100) // Give space for the interaction message
        .onChange(of: isListening) { // Automatically gets the new value if needed, but you ignore it here
            updateInteractionMessage()
        }
        .onChange(of: micPermissionStatus){
            updateInteractionMessage()
        }
        .onChange(of: speechPermissionStatus) {
            updateInteractionMessage()
        }
        .onAppear { updateInteractionMessage() } // Set initial message on appear
    }
    
    @ViewBuilder
    private func introductoryContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Icon and Title Row
            HStack(alignment: .center, spacing: 15) {
                aiIcon() // Custom AI icon view
                VStack(alignment: .leading) {
                    Text("Ask Anything with AI Mode")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("New") // Or "Beta", "Experiment"
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer() // Pushes content to the left
            }
            
            // Description Text
            Text("Be the first to try the new AI Mode experiment in Google Search. Get AI-powered responses and explore further with follow-up questions and links to helpful web content.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Toggle Section
            HStack {
                Text("Turn this experiment on or off.")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $isExperimentOn.animation()) // Animate the toggle switch
                    .labelsHidden() // Hide the default toggle label
                    .tint(buttonBlue) // Use custom color for the 'on' state
                    .onChange(of: isExperimentOn) {
                        print("[State Change] isExperimentOn toggled to: \(isExperimentOn)")
                        // Add logic here if toggling the experiment should affect other things
                    }
            }
            .padding() // Add padding inside the background
            .background(darkerGrayElement) // Use a slightly different background
            .cornerRadius(15)
            
            // Try AI Mode Button
            Button {
                print("[UI Action] 'Try AI Mode' button tapped.")
                // Add action for this button if needed (e.g., navigate to a different view)
            } label: {
                Text("Try AI Mode")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity) // Make button stretch horizontally
                    .padding()
                    .background(buttonBlue) // Use custom button color
                    .foregroundColor(darkGrayBackground) // Text color for contrast
                    .cornerRadius(25) // Round the corners
            }
        }
        .padding(.horizontal, 25) // Padding for the entire intro section
    }
    
    @ViewBuilder
    private func aiIcon() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .frame(width: 55, height: 55)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            Circle()
                .fill(rainbowGradient)
                .frame(width: 45, height: 45)
            Image(systemName: "sparkles") // Using sparkles instead of magnifying glass
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // Helper for standard Alert Buttons
    @ViewBuilder
    private func alertButtons() -> some View {
        Button("Open Settings") {
            print("[Alert Action] User tapped 'Open Settings'")
            // Attempt to open the app's settings screen
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                print("Attempting to open settings URL...")
                UIApplication.shared.open(url)
            } else {
                print("Could not create or open settings URL.")
            }
        }
        Button("Cancel", role: .cancel) {
            print("[Alert Action] User tapped 'Cancel' on permission alert")
        }
    }
    
    // MARK: - Helper Functions
    
    // Determines the color for the interaction message below the search bar
    private func messageColor() -> Color {
        if micPermissionStatus == .denied || speechPermissionStatus == .denied || speechPermissionStatus == .restricted {
            return .red.opacity(0.8) // Use red if any permission is denied/restricted
        } else if isListening {
            return buttonBlue.opacity(0.8) // Use blue when actively listening
        } else {
            return .clear // Effectively hides the text color when no message should be shown prominantly
        }
    }
    
    // Updates the interaction message text based on current state
    private func updateInteractionMessage() {
        if micPermissionStatus == .denied {
            interactionMessage = "Mic Access Denied"
        } else if speechPermissionStatus == .denied || speechPermissionStatus == .restricted {
            // Handle both denied and restricted states for speech
            interactionMessage = "Speech Access Denied"
        } else if isListening {
            interactionMessage = "Listening..."
        } else {
            interactionMessage = nil // Clear message if all permissions okay and not listening
        }
        print("[UI Update] Interaction message set to: \(interactionMessage ?? "nil")")
    }
    
    
    // MARK: - Action & Permission Handling
    
    // Called when the microphone button is tapped
    private func handleMicTap() {
        print("[Function Call] handleMicTap() called.")
        print("  -> Current State: isListening=\(isListening), Mic=\(micPermissionStatus.rawValue), Speech=\(speechPermissionStatus.description)")
        
        // If currently listening, stop.
        if isListening {
            print("  -> Currently listening. Calling stopListening().")
            stopListening()
        } else {
            // If not listening, check permissions sequentially before starting.
            switch micPermissionStatus {
            case .granted:
                print("  -> Mic Granted. Checking Speech permission.")
                checkAndHandleSpeechPermission() // Proceed to check speech status
            case .undetermined:
                print("  -> Mic Undetermined. Calling requestMicPermission().")
                requestMicPermission() // Request mic first; speech check follows if granted
            case .denied:
                print("  -> Mic Denied. Setting showMicDeniedAlert = true.")
                showMicDeniedAlert = true // Show alert for mic denial
            }
        }
    }
    
    // Checks speech permission status AFTER mic permission is confirmed granted
    private func checkAndHandleSpeechPermission() {
        switch speechPermissionStatus {
        case .authorized:
            print("  -> Speech Authorized. Calling startListening().")
            startListening() // Both permissions granted, start processing audio
        case .notDetermined:
            print("  -> Speech Undetermined. Calling requestSpeechPermission().")
            requestSpeechPermission() // Request speech permission
        case .denied, .restricted:
            print("  -> Speech Denied/Restricted. Setting showSpeechDeniedAlert = true.")
            showSpeechDeniedAlert = true // Show alert for speech denial/restriction
        @unknown default:
            // Handle potential future cases gracefully
            print("  -> Unknown Speech Permission status encountered: \(speechPermissionStatus.rawValue). Treating as denied.")
            showSpeechDeniedAlert = true
        }
    }
    
    // Checks initial status of both Mic and Speech permissions on view appear
    private func checkInitialPermissions() {
        print("[Function Call] checkInitialPermissions() called.")
        
        // 1. Check Mic Permission (Synchronous)
        let currentMicPermission = AVAudioApplication.shared.recordPermission
        print("  -> Current AVAudioApplication.recordPermission: \(currentMicPermission.description)")
        switch currentMicPermission {
        case .granted: self.micPermissionStatus = .granted
        case .denied: self.micPermissionStatus = .denied
        case .undetermined: self.micPermissionStatus = .undetermined
        @unknown default:
            print("  -> Encountered @unknown default case for mic recordPermission.")
            self.micPermissionStatus = .undetermined
        }
        
        // 2. Check Speech Permission (Synchronous)
        let currentSpeechPermission = SFSpeechRecognizer.authorizationStatus()
        print("  -> Current SFSpeechRecognizer.authorizationStatus: \(currentSpeechPermission.description)")
        self.speechPermissionStatus = currentSpeechPermission
        
        // Update UI message based on initial permissions
        DispatchQueue.main.async { // Ensure UI update runs on main thread
            self.updateInteractionMessage()
        }
    }
    
    // Requests microphone access from the user
    private func requestMicPermission() {
        print("[Function Call] requestMicPermission() called.")
        AVAudioApplication.requestRecordPermission { granted in // Use weak self
            //            guard let self = self else { return }
            print("[Permission Callback] requestRecordPermission completed. Granted: \(granted)")
            // Ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                print("  -> Updating mic state on main thread.")
                self.micPermissionStatus = granted ? .granted : .denied
                if granted {
                    print("    -> Mic Permission GRANTED. Now checking/requesting Speech permission.")
                    // If mic granted, immediately proceed to check/request speech permission
                    self.checkAndHandleSpeechPermission()
                } else {
                    print("    -> Mic Permission DENIED. Setting showMicDeniedAlert = true.")
                    self.showMicDeniedAlert = true
                }
                self.updateInteractionMessage() // Update message after permission state change
            }
        }
    }
    
    // Requests speech recognition access from the user
    private func requestSpeechPermission() {
        print("[Function Call] requestSpeechPermission() called.")
        SFSpeechRecognizer.requestAuthorization { authStatus in // Use weak self
            //            guard let self = self else { return }
            print("[Permission Callback] requestAuthorization completed. Status: \(authStatus.description)")
            // Ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                print("  -> Updating speech state on main thread.")
                self.speechPermissionStatus = authStatus
                if authStatus == .authorized {
                    // Now that speech is authorized (and mic presumably already is),
                    // the user needs to tap the mic button again to initiate listening.
                    print("    -> Speech permission GRANTED. User can now tap mic to start.")
                    // Optional: Auto-start listening here if desired for smoother flow,
                    // but requiring another tap might be clearer UX after permission grants.
                    // self.startListening() // <-- Uncomment to auto-start immediately after speech grant
                } else {
                    print("    -> Speech permission DENIED/Restricted. Setting showSpeechDeniedAlert = true.")
                    self.showSpeechDeniedAlert = true
                }
                self.updateInteractionMessage() // Update message after permission state change
            }
        }
    }
    
    
    // MARK: - Real-time Listening Logic
    
    // Starts the audio engine and speech recognition process
    private func startListening() {
        print("[Function Call] startListening() called.")
        
        // --- Pre-checks ---
        guard !isListening else { // Prevent starting if already listening
            print("  -> Already listening or processing. Guarding.")
            return
        }
        guard micPermissionStatus == .granted && speechPermissionStatus == .authorized else { // Ensure permissions are still granted
            print("  -> Permissions check failed (Mic: \(micPermissionStatus), Speech: \(speechPermissionStatus)). Cannot start listening. Guarding.")
            // This case should ideally be prevented by the handleMicTap logic, but it's a safety check.
            updateInteractionMessage() // Ensure message reflects denial if somehow reached here
            return
        }
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { // Check if recognizer is available on the device/locale
            print("  -> Speech recognizer is not available (Recognizer: \(String(describing: speechRecognizer)), Available: \(speechRecognizer?.isAvailable ?? false)). Cannot start.")
            // Inform the user if the recognizer isn't working
            DispatchQueue.main.async {
                self.interactionMessage = "Speech engine unavailable"
            }
            return
        }
        print("  -> Pre-checks passed. Proceeding to start listening.")
        
        // --- 1. Reset State & Create Request ---
        searchText = "" // Clear previous text
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest() // Create a new request
        guard let recognitionRequest = recognitionRequest else {
            print("  -> ERROR: Failed to create SFSpeechAudioBufferRecognitionRequest.")
            // Handle error appropriately, maybe show message to user
            return
        }
        recognitionRequest.shouldReportPartialResults = true // Enable real-time results
        // Set context for potentially better accuracy (optional)
        // recognitionRequest.taskHint = .search
        // Use on-device recognition if needed (iOS 13+, requires model download, less accurate but private)
        // if #available(iOS 13, *) {
        //     recognitionRequest.requiresOnDeviceRecognition = false // Set to true for on-device
        // }
        print("  -> Recognition request created (partial results enabled).")
        
        
        // --- 2. Configure Audio Session ---
        let audioSession = AVAudioSession.sharedInstance()
        do {
            print("  -> Configuring Audio Session Category: PlayAndRecord, Mode: Measurement.")
            // Use .playAndRecord if you need to play audio prompts simultaneously
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("  -> Audio Session configured and activated successfully.")
        } catch {
            print("  -> ERROR configuring audio session: \(error.localizedDescription)")
            cleanupListeningResources() // Clean up if session fails
            // Inform user
            DispatchQueue.main.async {
                self.interactionMessage = "Audio session error"
            }
            return
        }
        
        // --- 3. Setup Audio Engine Input Node ---
        let inputNode = audioEngine.inputNode
        // Get the recording format *before* installing the tap
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        // Validate format (essential check to prevent crashes)
        guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
            print("  -> ERROR: Invalid recording format detected (SampleRate: \(recordingFormat.sampleRate), Channels: \(recordingFormat.channelCount)). Cannot install tap.")
            cleanupListeningResources()
            DispatchQueue.main.async {
                self.interactionMessage = "Audio format error"
            }
            return
        }
        print("  -> Got Audio Engine Input Node. Format: \(recordingFormat)")
        
        
        // --- 4. Start Recognition Task ---
        print("  -> Starting SFSpeechRecognitionTask.")
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
//            guard let self = self else { // Ensure self is available
//                print("[Recognition Task Callback] Self is nil, returning.")
//                return
//            }
            var isFinal = false // Flag to check if this is the final result
            
            // --- Handle Result ---
            if let result = result {
                // Update the search text on the main thread
                let recognizedText = result.bestTranscription.formattedString
                print("[Recognition Result] Partial/Final: '\(recognizedText)' (isFinal: \(result.isFinal))")
                DispatchQueue.main.async {
                    self.searchText = recognizedText
                }
                isFinal = result.isFinal // Check if the speech recognizer considers this the final transcript
            }
            
            // --- Handle Error or Final Result ---
            if error != nil || isFinal {
                print("  -> Recognition task ending. Error: \(error?.localizedDescription ?? "None"), isFinal: \(isFinal)")
                // Stop audio engine and clean up resources regardless of error or finality
                // Ensure cleanup happens on the main thread for UI updates
                DispatchQueue.main.async {
                    print("    -> Stopping listening from recognition task callback.")
                    self.stopListening() // Call the main stop function
                }
            }
        }
        
        // --- 5. Install Audio Tap ---
        print("  -> Installing tap on input node bus 0.")
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            // Append the captured audio buffer to the recognition request
            // This is called frequently on an audio processing thread
            self.recognitionRequest?.append(buffer)
        }
        
        // --- 6. Prepare and Start Audio Engine ---
        do {
            print("  -> Preparing Audio Engine.")
            audioEngine.prepare()
            print("  -> Starting Audio Engine.")
            try audioEngine.start()
            print("  -> Audio Engine started successfully.")
            // --- Success: Update UI State ---
            DispatchQueue.main.async { // Update UI on main thread
                self.isListening = true // Set the listening state flag
                self.updateInteractionMessage() // Update the "Listening..." message
            }
        } catch {
            print("  -> ERROR starting audio engine: \(error.localizedDescription)")
            cleanupListeningResources() // Clean up thoroughly if engine fails to start
            // Inform user
            DispatchQueue.main.async {
                self.interactionMessage = "Audio engine error"
            }
        }
    }
    
    // Stops the audio engine and recognition process cleanly
    private func stopListening() {
        print("[Function Call] stopListening() called.")
        // Check if the engine is actually running before trying to stop
        guard audioEngine.isRunning else {
            print("  -> Audio engine is not running. Performing cleanup just in case.")
            cleanupListeningResources() // Ensure cleanup even if called unexpectedly
            return
        }
        
        print("  -> Stopping Audio Engine and removing tap.")
        // Use a do-catch block for potential errors during stop/removeTap
        do {
            audioEngine.stop()
            print("  -> Audio Engine stopped.")
            //inputNode.removeTap(onBus: 0)
            do {
                audioEngine.stop()
                print("  -> Audio Engine stopped.")
                audioEngine.inputNode.removeTap(onBus: 0) // CORRECT: Access via audioEngine
                print("  -> Removed tap from input node.")
            } catch {
                print("  -> ERROR stopping engine or removing tap: \(error.localizedDescription)")
            }
            
            print("  -> Removed tap from input node.")
        } catch {
            print("  -> ERROR stopping engine or removing tap: \(error.localizedDescription)")
            // Continue with cleanup even if there's an error here
        }
        
        
        // Signal that no more audio is coming for the request
        recognitionRequest?.endAudio()
        print("  -> Called endAudio() on recognition request.")
        
        
        // Cancel the task and perform remaining cleanup
        cleanupListeningResources()
    }
    
    // Central function to reset all listening-related resources and state
    private func cleanupListeningResources() {
        print("[Function Call] cleanupListeningResources() called.")
        
        // --- Safely Cancel Recognition Task ---
        // Check if task exists and is in a state that can be cancelled
        if let task = recognitionTask, task.state == .running || task.state == .starting {
            task.cancel() // Immediately terminate the task
            print("  -> Cancelled active recognition task.")
        } else {
            print("  -> No active recognition task to cancel (State: \(recognitionTask?.state.description ?? "nil")).")
        }
        recognitionTask = nil // Release reference to the task
        
        // --- Release Recognition Request ---
        if recognitionRequest != nil {
            recognitionRequest = nil
            print("  -> Released recognition request.")
        }
        
        // --- Deactivate Audio Session ---
        // This is important to release audio hardware resources
        do {
            // Check if session is active before trying to deactivate
            if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint { // Or another check if needed
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                print("  -> Deactivated audio session.")
            } else {
                print("  -> Audio session already inactive.")
            }
        } catch {
            print("  -> ERROR deactivating audio session: \(error.localizedDescription)")
        }
        
        // --- Update UI State (MUST be on Main Thread) ---
        DispatchQueue.main.async {
            // Only update state if it was previously 'listening'
            if self.isListening {
                self.isListening = false
                print("  -> Set isListening state to false.")
                self.updateInteractionMessage() // Update message after stopping
            }
        }
        print("  -> Cleanup finished.")
    }
}

// MARK: - Helper Extensions

// Provides descriptive strings for SFSpeechRecognizerAuthorizationStatus, useful for logging
extension SFSpeechRecognizerAuthorizationStatus: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .denied: return "denied"
        case .restricted: return "restricted"
        case .authorized: return "authorized"
        @unknown default: return "unknown (\(rawValue))" // Include rawValue for future cases
        }
    }
}

// Provides descriptive strings for AVAudioSession.RecordPermission, useful for logging
extension AVAudioSession.RecordPermission: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .undetermined: return "undetermined"
        case .denied: return "denied"
        case .granted: return "granted"
        @unknown default: return "unknown (\(rawValue))" // Include rawValue for future cases
        }
    }
}

// Provides descriptive strings for SFSpeechRecognitionTaskState, useful for debugging task lifecycle
extension SFSpeechRecognitionTaskState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .starting: return "starting"
        case .running: return "running"
        case .finishing: return "finishing"
        case .canceling: return "canceling"
        case .completed: return "completed"
        @unknown default: return "unknown (\(rawValue))"
        }
    }
}
// Provides descriptive strings for AVAudioApplication.RecordPermission
extension AVAudioApplication.recordPermission: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .undetermined: return "undetermined"
        case .denied: return "denied"
        case .granted: return "granted"
        @unknown default: return "unknown (\(rawValue))" // Use rawValue for future cases
        }
    }
}


// MARK: - Preview Provider
struct GoogleAIModeIntroView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleAIModeIntroView()
            .onAppear {
                print("[Preview] GoogleAIModeIntroView preview appearing.")
            }
    }
}
