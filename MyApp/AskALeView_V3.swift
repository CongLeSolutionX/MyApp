//
//  V3.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//


import SwiftUI
import AVFoundation
import Speech

// MARK: - Data Models & Mock Data

enum ResponseStyle: String, CaseIterable, Identifiable {
    case concise = "Concise"
    case detailed = "Detailed"
    case neutral = "Neutral"
    
    var id: String { self.rawValue }
}

struct VoiceOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let identifier: String
}

// A simple conversation history model for demo purposes.
class ConversationHistory: ObservableObject {
    @Published var messages: [String] = [
        "Hi, how can I help you?",
        "What is the weather today?",
        "Remember to clear your history!"
    ]
    
    func clearAll() {
        messages.removeAll()
    }
}

// A simple feedback service that simulates opening a feedback URL.
struct FeedbackService {
    static func openFeedbackForm() {
        // In a real implementation, you might open Mail compose view or a web URL.
        print("[FeedbackService] Feedback form opened (mock).")
    }
}

// MARK: - Settings Screen View

struct SettingsScreenView: View {
    // MARK: Appearance Settings
    @AppStorage("settings_preferredColorScheme") private var preferredColorScheme: String = "system"
    
    // MARK: Voice & Language Settings
    @AppStorage("settings_inputLanguage") private var inputLanguage: String = Locale.current.identifier
    @AppStorage("settings_outputVoiceIdentifier") private var outputVoiceIdentifier: String =
        AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language == AVSpeechSynthesisVoice.currentLanguageCode() })?.identifier ?? ""
    @AppStorage("settings_speechSpeed") private var speechSpeed: Double = 0.5
    @AppStorage("settings_responseStyle") private var responseStyle: ResponseStyle = .neutral
    
    // MARK: Conversation History Settings
    @AppStorage("settings_enableHistory") private var enableHistory: Bool = true
    @State private var showingClearHistoryAlert = false
    @EnvironmentObject var conversationHistory: ConversationHistory

    // MARK: Permissions (Passed from Parent)
    @Binding var micPermissionStatus: AVAudioApplication.recordPermission
    @Binding var speechPermissionStatus: SFSpeechRecognizerAuthorizationStatus
    
    // MARK: Mock Data for Voices and Locales
    let availableVoices: [VoiceOption] = AVSpeechSynthesisVoice.speechVoices()
        .filter { $0.language.starts(with: "en-") }
        .map { VoiceOption(name: "\($0.name) (\($0.language))", identifier: $0.identifier) }
        .sorted { $0.name < $1.name }
    
    let availableLocales: [Locale] = Locale.availableIdentifiers
        .map { Locale(identifier: $0) }
        .sorted {
            ($0.localizedString(forIdentifier: $0.identifier) ?? "") < ($1.localizedString(forIdentifier: $1.identifier) ?? "")
        }
    
    var body: some View {
        Form {
            // MARK: Account Section
            Section(header: Text("Account & Profile")) {
                Text("Manage your profile (Placeholder)")
                    .foregroundColor(.gray)
            }
            
            // MARK: Appearance Section
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $preferredColorScheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .onChange(of: preferredColorScheme) {
                    print("[Settings] Theme changed to: \(preferredColorScheme)")
                    // In a real app, update a theme manager or environment object.
                }
                Text("Text size respects the system Dynamic Type setting.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // MARK: Voice & Language Section
            Section(header: Text("Voice & Language")) {
                Picker("Input Language", selection: $inputLanguage) {
                    ForEach(availableLocales.prefix(20), id: \.identifier) { locale in
                        Text(locale.localizedString(forIdentifier: locale.identifier) ?? locale.identifier)
                            .tag(locale.identifier)
                    }
                }
                .pickerStyle(.navigationLink)
                
                Picker("Output Voice", selection: $outputVoiceIdentifier) {
                    ForEach(availableVoices) { voice in
                        Text(voice.name)
                            .tag(voice.identifier)
                    }
                }
                .pickerStyle(.navigationLink)
                
                VStack(alignment: .leading) {
                    Text("Speech Speed: \(speechSpeed, specifier: "%.2f")")
                    Slider(value: $speechSpeed, in: 0.0...1.0, step: 0.1)
                }
                
                Picker("Response Style", selection: $responseStyle) {
                    ForEach(ResponseStyle.allCases) { style in
                        Text(style.rawValue)
                            .tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // MARK: Permissions Section
            Section(header: Text("Permissions")) {
                permissionRow(title: "Microphone", status: micPermissionStatus.description, systemStatus: micPermissionStatus != .denied)
                permissionRow(title: "Speech Recognition", status: speechPermissionStatus.description, systemStatus: speechPermissionStatus != .denied && speechPermissionStatus != .restricted)
            }
            
            // MARK: Conversation History Section
            Section(header: Text("Conversation History")) {
                Toggle("Save History", isOn: $enableHistory)
                
                Button("Clear All Conversation History", role: .destructive) {
                    showingClearHistoryAlert = true
                }
                .disabled(!enableHistory)
                .foregroundColor(enableHistory ? .red : .gray)
            }
            .alert("Clear History?", isPresented: $showingClearHistoryAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    print("[Settings] Clearing conversation history...")
                    conversationHistory.clearAll()
                }
            } message: {
                Text("This action cannot be undone.")
            }
            
            // MARK: Feedback & About Section
            Section(header: Text("Feedback & About")) {
                Button("Send Feedback") {
                    FeedbackService.openFeedbackForm()
                }
                Link("Rate App in App Store", destination: URL(string: "https://apps.apple.com/app/your-app-id")!)
                NavigationLink("About", destination: AboutView())
                NavigationLink("Help / FAQ", destination: Text("Help / FAQ Content Goes Here").font(.body))
            }
        }
        .navigationTitle("AI Mode Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper ViewBuilder for Permission Row
    @ViewBuilder
    private func permissionRow(title: String, status: String, systemStatus: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(status)
                .font(.caption)
                .foregroundColor(systemStatus ? .green : .red)
            Button("Settings") {
                openAppSettings()
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
    }
    
    // Open device settings
    private func openAppSettings() {
        print("[Settings] Opening app settings...")
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("[Settings] Could not open settings URL.")
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("AI Mode Experiment")
                    .font(.title)
                Text("Version: 1.0.0 (Build 1)")
                Text("Copyright © \(Calendar.current.component(.year, from: Date())) CongLeSolutionX. All rights reserved.")
                Divider()
                Text("Acknowledgements:")
                    .font(.headline)
                Text("Built with SwiftUI, AVFoundation, and SpeechKit. This demo uses mock data for illustrative purposes.")
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

// MARK: - Main Intro View

struct GoogleAIModeIntroView: View {
    // UI state
    @State private var isExperimentOn = true
    @State private var searchText = ""
    @State private var isListening = false {
        didSet { print("[Main] isListening changed to: \(isListening)") }
    }
    @State private var showMicDeniedAlert = false {
        didSet { print("[Main] showMicDeniedAlert changed to: \(showMicDeniedAlert)") }
    }
    @State private var showSpeechDeniedAlert = false {
        didSet { print("[Main] showSpeechDeniedAlert changed to: \(showSpeechDeniedAlert)") }
    }
    @State private var interactionMessage: String? = nil
    
    // Permission state
    @State private var micPermissionStatus: AVAudioApplication.recordPermission = .undetermined {
        didSet { print("[Main] micPermissionStatus: \(micPermissionStatus.description)") }
    }
    @State private var speechPermissionStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined {
        didSet { print("[Main] speechPermissionStatus: \(speechPermissionStatus.description)") }
    }
    
    // Speech Recognition Objects
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Conversation History (injecting as EnvironmentObject)
    @StateObject private var conversationHistory = ConversationHistory()
    
    // UI Colors & Gradients
    let rainbowGradient = AngularGradient(
        gradient: Gradient(colors: [.yellow, .orange, .red, .purple, .blue, .green, .yellow]),
        center: .center
    )
    let buttonBlue = Color(red: 0.6, green: 0.8, blue: 1.0)
    let darkGrayBackground = Color(white: 0.1)
    let darkerGrayElement = Color(white: 0.15)
    let veryDarkBackground = Color(white: 0.05)
    
    var body: some View {
        NavigationView {
            ZStack {
                darkGrayBackground.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    searchBarArea()
                        .padding(.top, 20)
                    
                    introductoryContent()
                    
                    // For demonstration, show conversation history
                    conversationHistoryView()
                        .padding(.horizontal, 25)
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsScreenView(
                            micPermissionStatus: $micPermissionStatus,
                            speechPermissionStatus: $speechPermissionStatus)
                            .environmentObject(conversationHistory)
                        ) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("AI Mode")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .onAppear { checkInitialPermissions() }
            .alert("Microphone Access Denied", isPresented: $showMicDeniedAlert) {
                alertButtons()
            } message: {
                Text("Please enable microphone access in Settings.")
            }
            .alert("Speech Recognition Access Denied", isPresented: $showSpeechDeniedAlert) {
                alertButtons()
            } message: {
                Text("Please enable speech recognition access in Settings.")
            }
        }
        .accentColor(.white)
    }
    
    // MARK: - Search Bar Area
    
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
                    print("[Main] Microphone button tapped.")
                    handleMicTap()
                } label: {
                    Image(systemName: isFullyDisabled ? "mic.slash.fill" : (isListening ? "waveform.circle.fill" : "mic.fill"))
                        .font(.title2)
                        .foregroundColor(isFullyDisabled ? .gray : (isListening ? buttonBlue : .white))
                }
                .disabled(isFullyDisabled || (isListening && recognitionTask != nil))
                .padding(.trailing, 5)
                
                Image(systemName: "camera.viewfinder")
                    .foregroundColor(isFullyDisabled ? .gray : .white)
                    .padding(.trailing, 20)
                    .padding(.leading, 5)
                    .onTapGesture {
                        print("[Main] Camera button tapped (mock action).")
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
                    .animation(.easeInOut, value: interactionMessage),
                alignment: .bottom
            )
        }
        .frame(height: 100)
        .onChange(of: isListening) { updateInteractionMessage() }
        .onChange(of: micPermissionStatus) { updateInteractionMessage() }
        .onChange(of: speechPermissionStatus) { updateInteractionMessage() }
        .onAppear { updateInteractionMessage() }
    }
    
    // MARK: - Introductory Content
    
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
            
            Text("Experience our new AI Mode experiment. Use voice input, see instant transcription, and explore follow-up options using built-in settings. (This demo uses mock data.)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text("Experiment On/Off")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $isExperimentOn.animation())
                    .labelsHidden()
                    .tint(buttonBlue)
                    .onChange(of: isExperimentOn) {
                        print("[Main] isExperimentOn toggled: \(isExperimentOn)")
                    }
            }
            .padding()
            .background(darkerGrayElement)
            .cornerRadius(15)
            
            Button {
                print("[Main] 'Try AI Mode' tapped (mock action).")
            } label: {
                Text("Try AI Mode")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonBlue)
                    .foregroundColor(darkGrayBackground)
                    .cornerRadius(25)
            }
        }
        .padding(.horizontal, 25)
    }
    
    // MARK: - Conversation History List (Demo)
    
    @ViewBuilder
    private func conversationHistoryView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Conversation History")
                .font(.headline)
                .foregroundColor(.white)
            if conversationHistory.messages.isEmpty {
                Text("No conversation history available.")
                    .foregroundColor(.gray)
                    .font(.caption)
            } else {
                ForEach(conversationHistory.messages.indices, id: \.self) { index in
                    Text("• \(conversationHistory.messages[index])")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(darkerGrayElement)
        .cornerRadius(10)
    }
    
    // MARK: - AI Icon
    
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
    
    // MARK: - Alert Buttons
    
    @ViewBuilder
    private func alertButtons() -> some View {
        Button("Open Settings") {
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        Button("Cancel", role: .cancel) { }
    }
    
    // MARK: - Helper Functions
    
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
        print("[Main] Interaction message: \(interactionMessage ?? "nil")")
    }
    
    // MARK: - Permission & Listening Handling
    
    private func handleMicTap() {
        print("[Main] handleMicTap() called.")
        if isListening {
            stopListening()
        } else {
            switch micPermissionStatus {
            case .granted:
                print("[Main] Mic granted, checking speech permission...")
                checkAndHandleSpeechPermission()
            case .undetermined:
                requestMicPermission()
            case .denied:
                showMicDeniedAlert = true
            @unknown default:
                requestMicPermission()
            }
        }
    }
    
    private func checkAndHandleSpeechPermission() {
        switch speechPermissionStatus {
        case .authorized:
            startListening()
        case .notDetermined:
            requestSpeechPermission()
        case .denied, .restricted:
            showSpeechDeniedAlert = true
        @unknown default:
            showSpeechDeniedAlert = true
        }
    }
    
    private func checkInitialPermissions() {
        print("[Main] checkInitialPermissions() invoked.")
        let currentMicPermission = AVAudioApplication.shared.recordPermission
        micPermissionStatus = currentMicPermission
        
        let currentSpeechPermission = SFSpeechRecognizer.authorizationStatus()
        speechPermissionStatus = currentSpeechPermission
        
        DispatchQueue.main.async {
            updateInteractionMessage()
        }
    }
    
    private func requestMicPermission() {
        print("[Main] Requesting mic permission...")
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.micPermissionStatus = granted ? .granted : .denied
                if granted {
                    self.checkAndHandleSpeechPermission()
                } else {
                    self.showMicDeniedAlert = true
                }
                self.updateInteractionMessage()
            }
        }
    }
    
    private func requestSpeechPermission() {
        print("[Main] Requesting speech permission...")
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.speechPermissionStatus = authStatus
                if authStatus != .authorized {
                    self.showSpeechDeniedAlert = true
                }
                self.updateInteractionMessage()
            }
        }
    }
    
    private func startListening() {
        print("[Main] Starting listening...")
        guard !isListening,
              micPermissionStatus == .granted,
              speechPermissionStatus == .authorized,
              let recognizer = speechRecognizer, recognizer.isAvailable else {
            updateInteractionMessage()
            return
        }
        
        searchText = ""
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            DispatchQueue.main.async { self.interactionMessage = "Recognition error" }
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            cleanupListeningResources()
            DispatchQueue.main.async { self.interactionMessage = "Audio session error" }
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.sampleRate > 0, recordingFormat.channelCount > 0 else {
            cleanupListeningResources()
            DispatchQueue.main.async { self.interactionMessage = "Audio format error" }
            return
        }
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.searchText = recognizedText
                }
                isFinal = result.isFinal
            }
            if error != nil || isFinal {
                DispatchQueue.main.async { self.stopListening() }
            }
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isListening = true
                self.updateInteractionMessage()
            }
        } catch {
            cleanupListeningResources()
            DispatchQueue.main.async { self.interactionMessage = "Audio engine error" }
        }
    }
    
    private func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        cleanupListeningResources()
    }
    
    private func cleanupListeningResources() {
        if let task = recognitionTask, (task.state == .running || task.state == .starting || task.state == .finishing || task.state == .canceling) {
            task.cancel()
        }
        recognitionTask = nil
        recognitionRequest = nil
        do {
            if AVAudioSession.sharedInstance().category == .record || AVAudioSession.sharedInstance().category == .playAndRecord {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            }
        } catch {
            print("[Main] Error deactivating audio session: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.isListening = false
            self.updateInteractionMessage()
        }
    }
}

// MARK: - Helper Extensions

extension SFSpeechRecognizerAuthorizationStatus: @retroactive CustomStringConvertible {
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

// MARK: - Preview Providers

struct GoogleAIModeIntroView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleAIModeIntroView()
            .preferredColorScheme(.dark)
    }
}

struct SettingsScreenView_Previews: PreviewProvider {
    @State static var previewMicPermission: AVAudioApplication.recordPermission = .granted
    @State static var previewSpeechPermission: SFSpeechRecognizerAuthorizationStatus = .authorized
    
    static var previews: some View {
        NavigationView {
            SettingsScreenView(
                micPermissionStatus: $previewMicPermission,
                speechPermissionStatus: $previewSpeechPermission
            )
            .environmentObject(ConversationHistory())
        }
        .preferredColorScheme(.dark)
    }
}
