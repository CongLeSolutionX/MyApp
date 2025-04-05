//
//  SettingView.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//

import SwiftUI
import AVFoundation
import Speech // Make sure Speech framework is imported

// MARK: - Settings Data Structures & Persistence

// Enum for Response Style setting
enum ResponseStyle: String, CaseIterable, Identifiable {
    case concise = "Concise"
    case detailed = "Detailed"
    case neutral = "Neutral"

    var id: String { self.rawValue }
}

// Example Voice struct (replace with actual data source if needed)
struct VoiceOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let identifier: String // e.g., "com.apple.speech.synthesis.voice.samantha"
}

// MARK: - Settings Screen View

struct SettingsScreenView: View {
    // --- Appearance Settings ---
    // Theme selection is usually handled at the app level or via Environment, placeholder here
    @AppStorage("settings_preferredColorScheme") private var preferredColorScheme: String = "system" // "system", "light", "dark"
    // Text Size is typically controlled by Dynamic Type - show info text

    // --- Voice & Language Settings ---
    @AppStorage("settings_inputLanguage") private var inputLanguage: String = Locale.current.identifier // Default to device locale
    @AppStorage("settings_outputVoiceIdentifier") private var outputVoiceIdentifier: String = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language == AVSpeechSynthesisVoice.currentLanguageCode() })?.identifier ?? ""
    @AppStorage("settings_speechSpeed") private var speechSpeed: Double = 0.5 // Range 0.0 to 1.0 (AVSpeechUtterance rate is 0.0-1.0, default 0.5)
    @AppStorage("settings_responseStyle") private var responseStyle: ResponseStyle = .neutral

    // --- Conversation History Settings ---
    @AppStorage("settings_enableHistory") private var enableHistory: Bool = true
    @State private var showingClearHistoryAlert = false

    // --- Permissions (Passed from Parent) ---
    // These bindings allow this view to *display* the status determined by the parent view
    @Binding var micPermissionStatus: AVAudioApplication.recordPermission
    @Binding var speechPermissionStatus: SFSpeechRecognizerAuthorizationStatus
    // Add bindings for Camera/Location if implementing those features
    // @Binding var cameraPermissionStatus: AVAuthorizationStatus // Example
    // @Binding var locationPermissionStatus: CLAuthorizationStatus // Example

    // --- Mock Data ---
    let availableVoices: [VoiceOption] = AVSpeechSynthesisVoice.speechVoices()
        .filter { $0.language.starts(with: "en-") } // Example: Filter English voices
        .map { VoiceOption(name: "\($0.name) (\($0.language))", identifier: $0.identifier) }
        .sorted { $0.name < $1.name } // Sort voices alphabetically

    let availableLocales: [Locale] = Locale.availableIdentifiers.map { Locale(identifier: $0) }.sorted { $0.localizedString(forIdentifier: $0.identifier) ?? "" < $1.localizedString(forIdentifier: $1.identifier) ?? "" }

    var body: some View {
        // Use a Form for standard iOS settings appearance
        Form {
            // Section: Account (Placeholder)
            Section("Account & Profile") {
                Text("Manage your profile (Placeholder)")
                    .foregroundColor(.gray)
            }

            // Section: Appearance
            Section("Appearance") {
                // Theme Picker (Simplified using AppStorage string)
                Picker("Theme", selection: $preferredColorScheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .onChange(of: preferredColorScheme) { newValue in
                     // Apply the theme change globally if needed
                    print("Theme preference changed to: \(newValue)")
                    // In a real app, this might update an @EnvironmentObject or similar
                }

                // Info about Dynamic Type
                Text("Text size respects the system Dynamic Type setting.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Section: Voice & Language
            Section("Voice & Language") {
                // Input Language Picker (Simplified)
                // A real implementation might need more robust locale handling
                 Picker("Input Language", selection: $inputLanguage) {
                     ForEach(availableLocales.prefix(20), id: \.identifier) { locale in // Limit for preview performance
                         Text(locale.localizedString(forIdentifier: locale.identifier) ?? locale.identifier).tag(locale.identifier)
                     }
                 }
                 .pickerStyle(.navigationLink) // Use navigation link for many options

                // Output Voice Picker
                Picker("Output Voice", selection: $outputVoiceIdentifier) {
                    ForEach(availableVoices) { voice in
                        Text(voice.name).tag(voice.identifier)
                    }
                }
                 .pickerStyle(.navigationLink)

                // Speech Speed Slider
                VStack(alignment: .leading) {
                    Text("Speech Speed: \(speechSpeed, specifier: "%.2f")")
                    Slider(value: $speechSpeed, in: 0.0...1.0, step: 0.1) // AVSpeechUtterance rate range
                }

                // Response Style Picker
                Picker("Response Style", selection: $responseStyle) {
                    ForEach(ResponseStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented) // Or .menu
            }

            // Section: Permissions Management
            Section("Permissions") {
                permissionRow(title: "Microphone", status: micPermissionStatus.description, systemStatus: micPermissionStatus != .denied)
                permissionRow(title: "Speech Recognition", status: speechPermissionStatus.description, systemStatus: speechPermissionStatus != .denied && speechPermissionStatus != .restricted)
                // Add rows for Camera/Location if implemented
                // permissionRow(title: "Camera", status: cameraPermissionStatus.description, systemStatus: cameraPermissionStatus != .denied)
                // permissionRow(title: "Location", status: locationPermissionStatus.description, systemStatus: locationPermissionStatus != .denied)
            }

            // Section: Conversation History
            Section("Conversation History") {
                Toggle("Save History", isOn: $enableHistory)

                Button("Clear All Conversation History", role: .destructive) {
                    showingClearHistoryAlert = true
                }
                .disabled(!enableHistory) // Disable if history saving is off
                .foregroundColor(enableHistory ? .red : .gray)
            }
            // Alert for clearing history
            .alert("Clear History?", isPresented: $showingClearHistoryAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All", role: .destructive) {
                    print("[Settings Action] Clearing all conversation history (Placeholder)")
                    // Add actual history clearing logic here
                }
            } message: {
                Text("This action cannot be undone.")
            }

            // Section: Feedback & About
            Section("Feedback & About") {
                Button("Send Feedback") {
                    print("[Settings Action] Opening feedback form (Placeholder)")
                    // Add link to feedback mechanism (e.g., mailto:, web form)
                }
                Link("Rate App in App Store", destination: URL(string: "https://apps.apple.com/app/your-app-id")!) // Replace with your App Store link URL
                NavigationLink("About") {
                    AboutView() // Navigate to a simple About view
                }
                 NavigationLink("Help / FAQ") {
                     Text("Help / FAQ Content Goes Here") // Placeholder
                 }
            }
        }
        .navigationTitle("AI Mode Settings") // Set the title for the navigation bar
        .navigationBarTitleDisplayMode(.inline) // Use inline style for settings
    }

    // Helper ViewBuilder for consistent permission rows
    @ViewBuilder
    private func permissionRow(title: String, status: String, systemStatus: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(status)
                .font(.caption)
                .foregroundColor(systemStatus ? .green : .red) // Green for granted/undetermined, Red for denied/restricted
            Button("Settings") {
                openAppSettings()
            }
            .font(.caption)
            .buttonStyle(.bordered) // Make it look more like a button
        }
    }

    // Helper function to open app settings
    private func openAppSettings() {
        print("[Settings Action] User tapped 'Settings' for a permission")
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            print("Attempting to open app settings URL...")
            UIApplication.shared.open(url)
        } else {
            print("Could not create or open settings URL.")
        }
    }
}

// Simple About View (Example)
struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("AI Mode Experiment")
                .font(.title)
            Text("Version: 1.0.0 (Build 1)") // Replace with dynamic version/build
            Text("Copyright © \(Calendar.current.component(.year, from: Date())) CongLeSolutionX. All rights reserved.") // Replace Your Company Name
            Divider()
            Text("Acknowledgements:")
                .font(.headline)
            Text("Built with SwiftUI, AVFoundation, SpeechKit.")
            Spacer()
        }
        .padding()
        .navigationTitle("About")
    }
}


// MARK: - Main View Structure (Modified for Settings Integration)
struct GoogleAIModeIntroView: View {
    // --- UI State variables ---
    @State private var isExperimentOn = true
    @State private var searchText = ""
    @State private var isListening = false {
        didSet { print("[State Change] isListening updated to: \(isListening)") }
    }
    @State private var showMicDeniedAlert = false {
        didSet { print("[State Change] showMicDeniedAlert updated to: \(showMicDeniedAlert)") }
    }
    @State private var showSpeechDeniedAlert = false {
        didSet { print("[State Change] showSpeechDeniedAlert updated to: \(showSpeechDeniedAlert)") }
    }
    @State private var interactionMessage: String? = nil

    // --- Permission State ---
    @State private var micPermissionStatus: AVAudioApplication.recordPermission = .undetermined {
         didSet { print("[State Change] micPermissionStatus updated to: \(micPermissionStatus.description)") }
     }
    @State private var speechPermissionStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined {
        didSet { print("[State Change] speechPermissionStatus updated to: \(speechPermissionStatus.description)") }
    }

    // --- Speech Recognition Objects ---
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Consider using @AppStorage locale
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // --- UI Constants ---
    let rainbowGradient = AngularGradient(
        gradient: Gradient(colors: [
            .yellow, .orange, .red, .purple, .blue, .green, .yellow
        ]),
        center: .center
    )
    let buttonBlue = Color(red: 0.6, green: 0.8, blue: 1.0)
    let darkGrayBackground = Color(white: 0.1)
    let darkerGrayElement = Color(white: 0.15)
    let veryDarkBackground = Color(white: 0.05)

    // MARK: - Body
    var body: some View {
        // Use NavigationView to enable NavigationLink to Settings
        NavigationView {
            ZStack {
                darkGrayBackground.ignoresSafeArea()

                VStack(spacing: 30) {
                    searchBarArea()
                        .padding(.top, 20) // Reduced padding as Nav Bar takes space

                    introductoryContent()

                    Spacer()
                }
                // Add Settings Navigation Item to the Navigation Bar
                .navigationBarItems(trailing:
                    NavigationLink(destination: settingsView()) { // Navigate to SettingsScreenView
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                             .foregroundColor(.white) // Set icon color
                    }
                )
                .navigationBarTitleDisplayMode(.inline) // Keep title small or hidden if preferred
                 .toolbar { // Hide the default Nav Bar title text if needed
                     ToolbarItem(placement: .principal) {
                         Text("").accessibilityHidden(true) // Empty text for principal makes Nav bar visually cleaner
                     }
                 }
            }
            .preferredColorScheme(.dark) // Keep dark mode preference
            .onAppear {
                print("[Lifecycle] GoogleAIModeIntroView appeared.")
                checkInitialPermissions()
            }
            // Alerts remain the same
            .alert("Microphone Access Denied", isPresented: $showMicDeniedAlert) {
                alertButtons()
            } message: { Text("To use voice input, please enable microphone access for this app in Settings.") }
            .alert("Speech Recognition Access Denied", isPresented: $showSpeechDeniedAlert) {
                alertButtons()
            } message: { Text("To transcribe voice, please enable Speech Recognition access for this app in Settings.") }
        }
        .accentColor(.white) // Set the accent color for Navigation Bar items (like back button)
    }

    // MARK: - ViewBuilders (Existing and New)

    // Helper to create SettingsScreenView with necessary bindings
     @ViewBuilder
     private func settingsView() -> some View {
         SettingsScreenView(
             micPermissionStatus: $micPermissionStatus,
             speechPermissionStatus: $speechPermissionStatus
             // Pass other bindings here if needed for Camera/Location
         )
     }


    // Search Bar Area (mostly unchanged, ensure layout works with Nav Bar)
    @ViewBuilder
    private func searchBarArea() -> some View {
        let isMicDisabled = micPermissionStatus == .denied
        let isSpeechDisabled = speechPermissionStatus == .denied || speechPermissionStatus == .restricted
        let isFullyDisabled = isMicDisabled || isSpeechDisabled

        ZStack {
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
                    .tint(.white)
                    .padding(.leading, 20)
                    .disabled(isListening || isFullyDisabled)

                Spacer()

                Button {
                    print("[UI Action] Microphone button tapped.")
                    handleMicTap()
                } label: {
                    Image(systemName: isFullyDisabled
                          ? "mic.slash.fill"
                          : (isListening ? "waveform.circle.fill" : "mic.fill"))
                    .font(.title2)
                    .foregroundColor(isFullyDisabled
                                     ? .gray
                                     : (isListening ? buttonBlue : .white))
                }
                .disabled(isFullyDisabled || (isListening && recognitionTask != nil))
                .padding(.trailing, 5)

                Image(systemName: "camera.viewfinder")
                    .foregroundColor(isFullyDisabled ? .gray : .white)
                    .padding(.trailing, 20)
                    .padding(.leading, 5)
                    .allowsHitTesting(!isFullyDisabled)
                    .onTapGesture {
                        print("[UI Action] Camera button tapped (if enabled).")
                        // Add camera action logic here
                    }
            }
            .frame(height: 50)
            .background(Color.black.opacity(isListening ? 0.7 : 1.0))
            .clipShape(Capsule())
            .padding(.horizontal, 45)
            .opacity(isFullyDisabled ? 0.7 : 1.0)
            .overlay(
                Text(interactionMessage ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(messageColor())
                    .padding(.bottom, 40)
                    .opacity(interactionMessage != nil ? 1 : 0)
                    .animation(.easeInOut, value: interactionMessage)
                , alignment: .bottom
            )
        }
        .frame(height: 100)
        .onChange(of: isListening) { newValue in updateInteractionMessage() }
        .onChange(of: micPermissionStatus) { newValue in updateInteractionMessage() }
        .onChange(of: speechPermissionStatus) { newValue in updateInteractionMessage() }
        .onAppear { updateInteractionMessage() }
    }

    @ViewBuilder
    private func introductoryContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 15) {
                aiIcon()
                VStack(alignment: .leading) {
                    Text("Ask Anything with AI Mode")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("New")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }

            Text("Be the first to try the new AI Mode experiment in Google Search. Get AI-powered responses and explore further with follow-up questions and links to helpful web content.")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Text("Turn this experiment on or off.")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $isExperimentOn.animation())
                    .labelsHidden()
                    .tint(buttonBlue)
                    .onChange(of: isExperimentOn) { newValue in
                        print("[State Change] isExperimentOn toggled to: \(newValue)")
                    }
            }
            .padding()
            .background(darkerGrayElement)
            .cornerRadius(15)

            Button {
                print("[UI Action] 'Try AI Mode' button tapped.")
            } label: {
                Text("Try AI Mode")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonBlue)
                    .foregroundColor(darkGrayBackground)
                    .cornerRadius(25)
            }
            
            CongLeSolutionXAnimatedView()
        }
        .padding(.horizontal, 25)
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
            Image(systemName: "sparkles")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private func alertButtons() -> some View {
        Button("Open Settings") {
            print("[Alert Action] User tapped 'Open Settings'")
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

    // MARK: - Helper Functions (Unchanged)

    private func messageColor() -> Color {
        if micPermissionStatus == .denied || speechPermissionStatus == .denied || speechPermissionStatus == .restricted {
            return .red.opacity(0.8)
        } else if isListening {
            return buttonBlue.opacity(0.8)
        } else {
            return .clear
        }
    }

    private func updateInteractionMessage() {
        if micPermissionStatus == .denied {
            interactionMessage = "Mic Access Denied"
        } else if speechPermissionStatus == .denied || speechPermissionStatus == .restricted {
            interactionMessage = "Speech Access Denied"
        } else if isListening {
            interactionMessage = "Listening..."
        } else {
            interactionMessage = nil
        }
        print("[UI Update] Interaction message set to: \(interactionMessage ?? "nil")")
    }


    // MARK: - Action & Permission Handling (Unchanged)

    private func handleMicTap() {
        print("[Function Call] handleMicTap() called.")
        print("  -> Current State: isListening=\(isListening), Mic=\(micPermissionStatus.description), Speech=\(speechPermissionStatus.description)")

        if isListening {
            print("  -> Currently listening. Calling stopListening().")
            stopListening()
        } else {
            switch micPermissionStatus {
            case .granted:
                print("  -> Mic Granted. Checking Speech permission.")
                checkAndHandleSpeechPermission()
            case .undetermined:
                print("  -> Mic Undetermined. Calling requestMicPermission().")
                requestMicPermission()
            case .denied:
                print("  -> Mic Denied. Setting showMicDeniedAlert = true.")
                showMicDeniedAlert = true
             @unknown default:
                print("  -> Mic status unknown or future case. Treating as undetermined.")
                requestMicPermission()
            }
        }
    }

    private func checkAndHandleSpeechPermission() {
        print("[Function Call] checkAndHandleSpeechPermission() called.")
        switch speechPermissionStatus {
        case .authorized:
            print("  -> Speech Authorized. Calling startListening().")
            startListening()
        case .notDetermined:
            print("  -> Speech Undetermined. Calling requestSpeechPermission().")
            requestSpeechPermission()
        case .denied, .restricted:
            print("  -> Speech Denied/Restricted. Setting showSpeechDeniedAlert = true.")
            showSpeechDeniedAlert = true
        @unknown default:
            print("  -> Unknown Speech Permission status encountered: \(speechPermissionStatus.rawValue). Treating as denied.")
            showSpeechDeniedAlert = true
        }
    }

    private func checkInitialPermissions() {
        print("[Function Call] checkInitialPermissions() called.")
        let currentMicPermission = AVAudioApplication.shared.recordPermission
        print("  -> Current AVAudioApplication.recordPermission: \(currentMicPermission.description)")
        self.micPermissionStatus = currentMicPermission

        let currentSpeechPermission = SFSpeechRecognizer.authorizationStatus()
        print("  -> Current SFSpeechRecognizer.authorizationStatus: \(currentSpeechPermission.description)")
        self.speechPermissionStatus = currentSpeechPermission

        DispatchQueue.main.async {
            self.updateInteractionMessage()
        }
    }

    private func requestMicPermission() {
        print("[Function Call] requestMicPermission() called.")
        AVAudioApplication.requestRecordPermission { granted in
            print("[Permission Callback] requestRecordPermission completed. Granted: \(granted)")
            DispatchQueue.main.async {
                print("  -> Updating mic state on main thread.")
                self.micPermissionStatus = granted ? .granted : .denied
                if granted {
                    print("    -> Mic Permission GRANTED. Now checking/requesting Speech permission.")
                    self.checkAndHandleSpeechPermission()
                } else {
                    print("    -> Mic Permission DENIED. Setting showMicDeniedAlert = true.")
                    self.showMicDeniedAlert = true
                }
                self.updateInteractionMessage()
            }
        }
    }

    private func requestSpeechPermission() {
        print("[Function Call] requestSpeechPermission() called.")
        SFSpeechRecognizer.requestAuthorization { authStatus in
            print("[Permission Callback] requestAuthorization completed. Status: \(authStatus.description)")
            DispatchQueue.main.async {
                print("  -> Updating speech state on main thread.")
                self.speechPermissionStatus = authStatus
                if authStatus == .authorized {
                     print("    -> Speech permission GRANTED. User can now tap mic to start.")
                     // Consider if auto-start is desired:
                     // self.startListening()
                } else {
                    print("    -> Speech permission DENIED/Restricted. Setting showSpeechDeniedAlert = true.")
                    self.showSpeechDeniedAlert = true
                }
                self.updateInteractionMessage()
            }
        }
    }


    // MARK: - Real-time Listening Logic (Unchanged)

    private func startListening() {
        print("[Function Call] startListening() called.")
        guard !isListening else {
            print("  -> Already listening or processing. Guarding.")
            return
        }
        guard micPermissionStatus == .granted && speechPermissionStatus == .authorized else {
            print("  -> Permissions check failed (Mic: \(micPermissionStatus), Speech: \(speechPermissionStatus)). Cannot start listening. Guarding.")
            updateInteractionMessage()
            return
        }
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("  -> Speech recognizer is not available (Recognizer: \(String(describing: speechRecognizer)), Available: \(speechRecognizer?.isAvailable ?? false)). Cannot start.")
            DispatchQueue.main.async { self.interactionMessage = "Speech engine unavailable" }
            return
        }
        print("  -> Pre-checks passed. Proceeding to start listening.")

        searchText = ""
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("  -> ERROR: Failed to create SFSpeechAudioBufferRecognitionRequest.")
            DispatchQueue.main.async { self.interactionMessage = "Recognition init error" }
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        print("  -> Recognition request created (partial results enabled).")

        let audioSession = AVAudioSession.sharedInstance()
        do {
            print("  -> Configuring Audio Session Category: Record, Mode: Measurement.")
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("  -> Audio Session configured and activated successfully.")
        } catch {
            print("  -> ERROR configuring audio session: \(error.localizedDescription)")
            cleanupListeningResources()
            DispatchQueue.main.async { self.interactionMessage = "Audio session error" }
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
            print("  -> ERROR: Invalid recording format detected (SampleRate: \(recordingFormat.sampleRate), Channels: \(recordingFormat.channelCount)). Cannot install tap.")
            cleanupListeningResources()
            DispatchQueue.main.async { self.interactionMessage = "Audio format error" }
            return
        }
        print("  -> Got Audio Engine Input Node. Format: \(recordingFormat)")

        print("  -> Starting SFSpeechRecognitionTask.")
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in // Use weak self
            

            var isFinal = false

            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                print("[Recognition Result] Partial/Final: '\(recognizedText)' (isFinal: \(result.isFinal))")
                DispatchQueue.main.async {
                    self.searchText = recognizedText
                }
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                print("  -> Recognition task ending. Error: \(error?.localizedDescription ?? "None"), isFinal: \(isFinal)")
                 DispatchQueue.main.async {
                     print("    -> Stopping listening from recognition task callback.")
                     self.stopListening()
                 }
            }
        }

        print("  -> Installing tap on input node bus 0.")
         inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {(buffer: AVAudioPCMBuffer, when: AVAudioTime) in
              // Use weak self in tap block too
             self.recognitionRequest?.append(buffer)
         }

        do {
            print("  -> Preparing Audio Engine.")
            audioEngine.prepare()
            print("  -> Starting Audio Engine.")
            try audioEngine.start()
            print("  -> Audio Engine started successfully.")
            DispatchQueue.main.async {
                 self.isListening = true
                 self.updateInteractionMessage()
             }
        } catch {
            print("  -> ERROR starting audio engine: \(error.localizedDescription)")
            cleanupListeningResources()
            DispatchQueue.main.async { self.interactionMessage = "Audio engine error" }
        }
    }

    private func stopListening() {
        print("[Function Call] stopListening() called.")
        if audioEngine.isRunning {
            print("  -> Stopping Audio Engine.")
            audioEngine.stop()
            print("  -> Audio Engine stopped.")
            print("  -> Removing tap from input node bus 0.")
            audioEngine.inputNode.removeTap(onBus: 0)
            print("  -> Removed tap from input node.")
        } else {
             print("  -> Audio engine was not running. Skipping stop/removeTap.")
        }

        if recognitionRequest != nil {
            recognitionRequest?.endAudio()
            print("  -> Called endAudio() on recognition request.")
        } else {
             print("  -> No recognition request to end audio for.")
        }
        cleanupListeningResources()
    }

    private func cleanupListeningResources() {
        print("[Function Call] cleanupListeningResources() called.")
        if let task = recognitionTask, task.state == .running || task.state == .starting || task.state == .finishing || task.state == .canceling {
            task.cancel()
            print("  -> Cancelled active recognition task (State: \(task.state.description)).")
        } else {
            print("  -> No active recognition task to cancel (State: \(recognitionTask?.state.description ?? "nil")).")
        }
        recognitionTask = nil

        if recognitionRequest != nil {
            recognitionRequest = nil
            print("  -> Released recognition request.")
        }

        do {
             if AVAudioSession.sharedInstance().category == .record || AVAudioSession.sharedInstance().category == .playAndRecord {
                 try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                 print("  -> Deactivated audio session.")
             } else {
                print("  -> Audio session already inactive or in a different state (\(AVAudioSession.sharedInstance().category)).")
             }
        } catch {
            print("  -> ERROR deactivating audio session: \(error.localizedDescription)")
        }

        DispatchQueue.main.async {
            if self.isListening {
                self.isListening = false
                print("  -> Set isListening state to false.")
                self.updateInteractionMessage()
            } else {
                 print("  -> isListening was already false. No state change needed.")
            }
        }
        print("  -> Cleanup finished.")
    }
}

// MARK: - Helper Extensions (Unchanged)

extension SFSpeechRecognizerAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown (\(rawValue))"
        }
    }
}

extension SFSpeechRecognitionTaskState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .starting: return "Starting"
        case .running: return "Running"
        case .finishing: return "Finishing"
        case .canceling: return "Canceling"
        case .completed: return "Completed"
        @unknown default: return "Unknown (\(rawValue))"
        }
    }
}

extension AVAudioApplication.recordPermission: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .undetermined: return "Undetermined"
        case .denied: return "Denied"
        case .granted: return "Granted"
        @unknown default: return "Unknown (\(rawValue))"
        }
    }
}


// MARK: - Preview Provider (Updated to include NavigationView)
struct GoogleAIModeIntroView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleAIModeIntroView()
            .onAppear {
                print("[Preview] GoogleAIModeIntroView preview appearing.")
                // Set default @AppStorage values for preview if needed
                 UserDefaults.standard.set(ResponseStyle.neutral.rawValue, forKey: "settings_responseStyle")
            }
            .preferredColorScheme(.dark)
    }
}

// Preview for Settings Screen
struct SettingsScreenView_Previews: PreviewProvider {
     // Create static states for preview bindings
     @State static var previewMicPermission: AVAudioApplication.recordPermission = .granted
     @State static var previewSpeechPermission: SFSpeechRecognizerAuthorizationStatus = .authorized

     static var previews: some View {
         NavigationView { // Add NavigationView for preview context
             SettingsScreenView(
                 micPermissionStatus: $previewMicPermission,
                 speechPermissionStatus: $previewSpeechPermission
             )
         }
          .preferredColorScheme(.dark) // Preview in dark mode
     }
}
