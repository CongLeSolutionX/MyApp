//
//  VoiceInputAreaView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI
import Combine
import Speech
import AVFoundation

// MARK: - Info.plist Reminder (Keep in your project settings)
/*
 Add to Info.plist:
 <key>NSSpeechRecognitionUsageDescription</key>
 <string>Speech recognition usage description</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>Microphone usage description</string>
*/

// MARK: - Voice Mode Enum
enum VoiceMode: String, CaseIterable, Identifiable {
    case liveTranscription = "Live"
    case holdToTalk = "Hold"
    var id: String { rawValue }
}

// MARK: - Voice Error Definition
enum VoiceError: LocalizedError {
    case requestSetupFailed
    case audioSessionError(Error)
    case audioEngineError(Error)
    case invalidAudioFormat(String)
    case recognizerUnavailable
    case permissionsMissing(String)
    
    var errorDescription: String? {
        switch self {
        case .requestSetupFailed:
            return "Unable to initialize the speech recognition request."
        case .audioSessionError(let error):
            return "Audio session configuration failed: \(error.localizedDescription)"
        case .audioEngineError(let error):
            return "Audio engine setup failed: \(error.localizedDescription)"
        case .invalidAudioFormat(let details):
            return "Invalid audio format: \(details)"
        case .recognizerUnavailable:
            return "Speech recognizer is not available."
        case .permissionsMissing(let type):
            return "Missing permission: \(type). Please enable it in Settings."
        }
    }
}

// MARK: - Voice Input Manager

@MainActor
class VoiceInputManager: ObservableObject {
    
    @Published var currentMode: VoiceMode = .liveTranscription {
        didSet {
            if isListening { stopListening() }
        }
    }
    
    @Published private(set) var hasPermissions: Bool = false
    @Published private(set) var isListening = false
    @Published var transcribedText = ""
    @Published var error: String?

    // Private internal state for hold-to-talk intermediate results
    private var latestHoldTranscription = ""
    
    // Speech recognizer components
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Audio engine
    private let audioEngine = AVAudioEngine()
    private var audioSessionIsActive = false
    
    init(localeIdentifier: String = "en-US") {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        checkPermissions()
    }
    
    // MARK: Permissions
    
    func requestPermissions() async {
        // Request Speech Authorization
        let speechAuthStatus = await SFSpeechRecognizer.requestAuthorization()
        
        // Request Microphone Authorization asynchronously
        let micPermissionGranted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        // Update state on main thread (due to @MainActor)
        let speechAuthorized = speechAuthStatus == .authorized
        self.hasPermissions = (speechAuthorized && micPermissionGranted)
        
        // Set error if missing permission(s)
        if !speechAuthorized && !micPermissionGranted {
            error = VoiceError.permissionsMissing("Microphone & Speech").localizedDescription
        } else if !micPermissionGranted {
            error = VoiceError.permissionsMissing("Microphone").localizedDescription
        } else if !speechAuthorized {
            error = VoiceError.permissionsMissing("Speech Recognition (\(speechAuthStatus.description))").localizedDescription
        } else {
            error = nil
        }
    }
    
    func checkPermissions() {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        let micStatus = AVAudioSession.sharedInstance().recordPermission
        hasPermissions = (speechStatus == .authorized && micStatus == .granted)
    }
    
    // MARK: Listening Control
    
    func startListening() {
        guard hasPermissions else {
            error = VoiceError.permissionsMissing("Microphone/Speech").localizedDescription
            
            // Prompt request if undecided
            if SFSpeechRecognizer.authorizationStatus() == .notDetermined ||
                AVAudioSession.sharedInstance().recordPermission == .undetermined {
                Task {
                    await requestPermissions()
                }
            }
            return
        }
        guard !isListening else { return }
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            error = VoiceError.recognizerUnavailable.localizedDescription
            return
        }
        
        cleanupPreviousRecognition()
        error = nil
        
        if currentMode == .liveTranscription {
            transcribedText = ""
        }
        latestHoldTranscription = ""
        
        do {
            try activateAudioSession()
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            if #available(iOS 13, *), recognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = false
            }
            self.recognitionRequest = request
            
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, err in
                Task { @MainActor in
                    await self?.handleRecognitionResult(result, error: err)
                }
            }
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            guard recordingFormat.sampleRate > 0 else {
                throw VoiceError.invalidAudioFormat("Sample rate is zero")
            }
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isListening = true
        } catch {
            //error = (error as? VoiceError)?.localizedDescription ?? "Audio engine error: \(error.localizedDescription)"
            cleanupResources(deactivateSession: true)
        }
    }
    
    func stopListening() {
        guard isListening else { return }
        
        recognitionRequest?.endAudio()
        
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        isListening = false
        
        // For hold-to-talk: if final transcription not yet pushed, update here
        if currentMode == .holdToTalk, !latestHoldTranscription.isEmpty, transcribedText != latestHoldTranscription {
            transcribedText = latestHoldTranscription
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            try? self?.deactivateAudioSession()
        }
    }
    
    // MARK: Recognition Result Handling
    
    private func handleRecognitionResult(_ result: SFSpeechRecognitionResult?, error: Error?) async {
        guard isListening || result?.isFinal == true else {
            if error != nil {
                await presentRecognitionError(error)
            }
            return
        }
        
        let bestText = result?.bestTranscription.formattedString ?? ""
        let isFinalResult = result?.isFinal ?? false
        
        switch currentMode {
        case .liveTranscription:
            transcribedText = bestText
        case .holdToTalk:
            latestHoldTranscription = bestText
            if isFinalResult {
                transcribedText = bestText
            }
        }
        
        if error != nil || isFinalResult {
            if isListening { stopListening() }
            await presentRecognitionError(error)
            cleanupPreviousRecognition()
        }
    }
    
    private func presentRecognitionError(_ error: Error?) async {
        guard let error = error as NSError? else { return }
        
        // Ignore common cancellation errors
        let ignoredErrors: [(domain: String, code: Int)] = [
            ("com.apple.Speech", 203), // cancelled
            (NSOSStatusErrorDomain, 1717046381), // AudioQueue reset enqueue error
            ("kAFAssistantErrorDomain", 1107) // Asset fetch
        ]
        guard !ignoredErrors.contains(where: { $0.domain == error.domain && $0.code == error.code }) else {
            return
        }
        if self.error == nil {
            self.error = "Recognition error: \(error.localizedDescription)"
        }
    }
    
    // MARK: Audio Session Activation / Deactivation
    
    private func activateAudioSession() throws {
        guard !audioSessionIsActive else { return }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        // Optional: Adjust buffer duration for latency
        // try session.setPreferredIOBufferDuration(0.02)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        
        audioSessionIsActive = true
    }
    
    private func deactivateAudioSession() throws {
        guard audioSessionIsActive else { return }
        
        try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        audioSessionIsActive = false
    }
    
    // MARK: Cleanup
    
    private func cleanupPreviousRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
    
    private func cleanupResources(deactivateSession: Bool) {
        if isListening || audioEngine.isRunning {
            stopListening()
        } else {
            cleanupPreviousRecognition()
            if deactivateSession, audioSessionIsActive {
                try? deactivateAudioSession()
            }
        }
    }
    
    deinit {
        print("[VoiceInputManager] deinit")
        //cleanupResources(deactivateSession: true)
    }
}

// MARK: - SFSpeechRecognizer Authorization Description Helper

extension SFSpeechRecognizerAuthorizationStatus {
    var description: String {
        switch self {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Determined"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Voice Input Area SwiftUI View

struct VoiceInputAreaView: View {
    @Binding var userInput: String
    let isProcessing: Bool
    let placeholder: String
    let sendMessageAction: () -> Void
    
    @ObservedObject var voiceManager: VoiceInputManager
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var isPressingHoldButton = false
    
    var body: some View {
        HStack(spacing: 10) {
            voiceModeToggleButton
                .padding(.leading, 4)
            
            textEditorArea
            
            sendButtonArea
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 12))
        .onAppear {
            if !voiceManager.hasPermissions,
               SFSpeechRecognizer.authorizationStatus() == .notDetermined ||
               AVAudioSession.sharedInstance().recordPermission == .undetermined {
                Task {
                    await voiceManager.requestPermissions()
                }
            }
        }
    }
    
    // MARK: Subviews
    
    @ViewBuilder
    private var voiceModeToggleButton: some View {
        switch voiceManager.currentMode {
        case .liveTranscription:
            Button {
                if voiceManager.isListening {
                    voiceManager.stopListening()
                    isTextFieldFocused = true
                } else {
                    userInput = ""
                    isTextFieldFocused = false
                    voiceManager.startListening()
                }
            } label: {
                micIcon
            }
            .disabled(isProcessing)
            
        case .holdToTalk:
            micIcon
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            guard !isPressingHoldButton, !voiceManager.isListening, !isProcessing else { return }
                            isPressingHoldButton = true
                            isTextFieldFocused = false
                            userInput = ""
                            voiceManager.startListening()
                            #if os(iOS)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            #endif
                        }
                        .onEnded { _ in
                            guard isPressingHoldButton else { return }
                            voiceManager.stopListening()
                            isPressingHoldButton = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isTextFieldFocused = true
                            }
                            #if os(iOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                        }
                )
                .disabled(isProcessing)
        }
    }
    
    private var micIcon: some View {
        let active = voiceManager.isListening || isPressingHoldButton
        let micColor: Color = {
            if isProcessing { return .gray.opacity(0.6) }
            else if active { return .red }
            else { return .blue }
        }()
        
        let iconName = active ? "stop.circle.fill" : "mic.circle.fill"
        
        return Image(systemName: iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(micColor)
            .symbolEffect(.pulse.byLayer, options: .repeating, isActive: voiceManager.isListening)
            // Combine animations into one modifier to reduce overhead
            .animation(.easeInOut(duration: 0.2), value: isProcessing || voiceManager.isListening || isPressingHoldButton)
    }
    
    private var textEditorArea: some View {
        ZStack(alignment: .trailing) {
            TextEditor(text: $userInput)
                .focused($isTextFieldFocused)
                .frame(minHeight: 36, maxHeight: 120)
                .padding(.leading, 10)
                .padding(.trailing, 35)
                .background(Color(.systemBackground).opacity(isInputDisabled ? 0.6 : 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    Group {
                        if userInput.isEmpty && !isInputDisabled {
                            Text(placeholder)
                                .foregroundColor(Color(.placeholderText))
                                .padding(.leading, 14)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
                .disabled(isInputDisabled)
                .onChange(of: isTextFieldFocused) { focused in
                    if focused && voiceManager.isListening {
                        voiceManager.stopListening()
                        isPressingHoldButton = false
                    }
                }
            
            if !userInput.isEmpty && !isInputDisabled {
                Button {
                    userInput = ""
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .padding(.trailing, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: userInput.isEmpty)
        .animation(.easeInOut(duration: 0.20), value: isInputDisabled)
    }
    
    private var sendButtonArea: some View {
        Button {
            sendMessageAction()
            isTextFieldFocused = false
        } label: {
            Group {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                        .frame(width: 30, height: 30)
                } else {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(isSendButtonEnabled ? .blue : .gray.opacity(0.5)))
                }
            }
        }
        .disabled(!isSendButtonEnabled || isProcessing || isInputDisabled)
        .animation(.easeInOut(duration: 0.2), value: isProcessing || isSendButtonEnabled || isInputDisabled)
        .keyboardShortcut(.defaultAction)
        .keyboardShortcut(.return, modifiers: .command)
        .sensoryFeedback(.impact(weight: .medium), trigger: isProcessing && isSendButtonEnabled)
    }
    
    // MARK: Computed Properties
    private var isInputDisabled: Bool {
        voiceManager.isListening || isPressingHoldButton
    }
    
    private var isSendButtonEnabled: Bool {
        !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Preview with Mode Switching

struct VoiceInputAreaView_ModePreviews: PreviewProvider {
    @State static var previewUserInput = ""
    @StateObject static var previewVoiceManager = VoiceInputManager()
    @State static var previewIsProcessing = false
    @State static var previewMode = VoiceMode.liveTranscription
    
    static var previews: some View {
        VStack(spacing: 15) {
            GroupBox("Preview Controls") {
                Picker("Voice Mode", selection: $previewMode) {
                    ForEach(VoiceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: previewMode) { newValue in
                    previewVoiceManager.currentMode = newValue
                    if previewVoiceManager.isListening {
                        previewVoiceManager.stopListening()
                    }
                    previewUserInput = ""
                    previewVoiceManager.error = nil
                    previewIsProcessing = false
                }
                
                Toggle("Simulate Processing", isOn: $previewIsProcessing)
            }
            
            Divider()
            
            Text("Input Area (Mode: \(previewVoiceManager.currentMode.rawValue))")
                .font(.headline)
            
            VoiceInputAreaView(
                userInput: $previewUserInput,
                isProcessing: previewIsProcessing,
                placeholder: "Ask Gemini...",
                sendMessageAction: {
                    print("Send (\(previewMode.rawValue)): \(previewUserInput)")
                    previewUserInput = ""
                },
                voiceManager: previewVoiceManager
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.thinMaterial)
            .cornerRadius(25)
            
            Divider()
            
            GroupBox("Debug Info") {
                Text("Is Listening: \(previewVoiceManager.isListening ? "YES" : "NO")")
                Text("Has Permissions: \(previewVoiceManager.hasPermissions ? "YES" : "NO")")
                if let error = previewVoiceManager.error {
                    Text("Error: \(error)").foregroundColor(.red).lineLimit(2).font(.caption)
                } else {
                    Text("Error: None").foregroundColor(.green)
                }
                Text("User Input: \"\(previewUserInput)\"")
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .onAppear {
            previewVoiceManager.currentMode = previewMode
        }
    }
}
