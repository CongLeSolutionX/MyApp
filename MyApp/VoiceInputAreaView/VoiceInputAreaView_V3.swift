//
//  VoiceInputAreaView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//


import SwiftUI
import Combine
import Speech        // For SFSpeechRecognizer
import AVFoundation  // For AVAudioEngine & AVAudioSession

// MARK: - Info.plist Requirements (CRUCIAL!)
/*
 Add the following keys and descriptive strings to your project's Info.plist file:
 
 <key>NSSpeechRecognitionUsageDescription</key>
 <string>This app uses speech recognition to transcribe your voice into text for chat prompts.</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>This app needs access to the microphone to capture your voice for transcription.</string>
 */

// MARK: - Voice Mode Enum
enum VoiceMode: String, CaseIterable, Identifiable {
    case liveTranscription = "Live" // Tap mic to start/stop, text updates live
    case holdToTalk = "Hold"        // Press and hold mic, release to stop/transcribe
    
    var id: String { rawValue }
}

// MARK: - Custom Error Enum
enum VoiceError: Error, LocalizedError {
    case requestSetupFailed
    case audioSessionError(Error)
    case audioEngineError(Error)
    case invalidAudioFormat(String)
    case recognizerUnavailable
    case permissionsMissing(String)
    
    var errorDescription: String? {
        switch self {
        case .requestSetupFailed:
            return "Failed to initialize the speech recognition request."
        case .audioSessionError(let error):
            return "Audio session error: \(error.localizedDescription)"
        case .audioEngineError(let error):
            return "Audio engine error: \(error.localizedDescription)"
        case .invalidAudioFormat(let details):
            return "Invalid audio format: \(details)"
        case .recognizerUnavailable:
            return "Speech recognizer is not available for the selected locale or device."
        case .permissionsMissing(let type):
            return "Missing permission: \(type). Please grant access in Settings."
        }
    }
}

// MARK: - Voice Input Manager (ObservableObject)
@MainActor
final class VoiceInputManager: ObservableObject {
    // Published properties for binding with UI
    @Published var currentMode: VoiceMode = .liveTranscription {
        didSet { if isListening { stopListening() } }
    }
    @Published var isListening: Bool = false
    @Published var transcribedText: String = ""
    @Published var error: String? = nil
    @Published private(set) var hasPermissions: Bool = false
    
    // Internal state for hold mode transcription
    private var latestHoldTranscription: String = ""
    
    // Speech recognition components
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Audio Engine components
    private let audioEngine = AVAudioEngine()
    private var audioSessionActive = false
    
    init(localeIdentifier: String = "en-US") {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        updatePermissionStatus()
    }
    
    // MARK: Permissions
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            guard let self = self else { return }
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    let micGranted = granted
                    let speechGranted = (authStatus == .authorized)
                    self.hasPermissions = micGranted && speechGranted
                    
                    if !micGranted && !speechGranted {
                        self.error = VoiceError.permissionsMissing("Microphone & Speech Recognition").localizedDescription
                    } else if !micGranted {
                        self.error = VoiceError.permissionsMissing("Microphone").localizedDescription
                    } else if !speechGranted {
                        self.error = VoiceError.permissionsMissing("Speech Recognition (\(authStatus.description))").localizedDescription
                    } else {
                        self.error = nil
                    }
                }
            }
        }
    }
    
    private func updatePermissionStatus() {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        let micStatus = AVAudioSession.sharedInstance().recordPermission
        self.hasPermissions = (speechStatus == .authorized && micStatus == .granted)
    }
    
    // MARK: - Listening Control
    func startListening() {
        guard hasPermissions else {
            error = VoiceError.permissionsMissing("Microphone/Speech").localizedDescription
            if SFSpeechRecognizer.authorizationStatus() == .notDetermined ||
                AVAudioSession.sharedInstance().recordPermission == .undetermined {
                requestPermissions()
            }
            return
        }
        
        guard !isListening else { return }
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            error = VoiceError.recognizerUnavailable.localizedDescription
            return
        }
        
        cleanupPreviousTask()
        error = nil
        if currentMode == .liveTranscription { transcribedText = "" }
        latestHoldTranscription = ""
        
        do {
            try setupAudioSession(activate: true)
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let req = recognitionRequest else { throw VoiceError.requestSetupFailed }
            
            req.shouldReportPartialResults = true
            if #available(iOS 13, *), recognizer.supportsOnDeviceRecognition {
                req.requiresOnDeviceRecognition = false
            }
            
            recognitionTask = recognizer.recognitionTask(with: req) { [weak self] result, err in
                self?.handleResult(result, error: err)
            }
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            guard recordingFormat.sampleRate > 0 else {
                throw VoiceError.invalidAudioFormat("Sample rate is zero.")
            }
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
            
        } catch let voiceErr as VoiceError {
            error = voiceErr.localizedDescription
            cleanupResources(deactivateSession: true)
        } catch {
            //error = "Audio setup error: \(error.localizedDescription)"
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
        
        if currentMode == .holdToTalk, !latestHoldTranscription.isEmpty, transcribedText != latestHoldTranscription {
            DispatchQueue.main.async { self.transcribedText = self.latestHoldTranscription }
        }
        
        // Delay session deactivation slightly so the system processes the endAudio signal.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            try? self?.setupAudioSession(activate: false)
        }
    }
    
    // MARK: - Recognition Result Handler
    private func handleResult(_ result: SFSpeechRecognitionResult?, error recogError: Error?) {
        let bestText = result?.bestTranscription.formattedString ?? ""
        let finalResult = result?.isFinal ?? false
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isListening || finalResult else { return }
            if self.currentMode == .liveTranscription {
                self.transcribedText = bestText
            } else {
                self.latestHoldTranscription = bestText
                if finalResult { self.transcribedText = bestText }
            }
            
            if recogError != nil || finalResult {
                if self.isListening { self.stopListening() }
                if let error = recogError as NSError? {
                    let skipDomains: [(String, Int)] = [
                        ("com.apple.Speech", 203),
                        (NSOSStatusErrorDomain, 1717046381),
                        ("kAFAssistantErrorDomain", 1107)
                    ]
                    if !skipDomains.contains(where: { $0.0 == error.domain && $0.1 == error.code }) && self.error == nil {
                        self.error = "Recognition Error: \(error.localizedDescription)"
                    }
                }
                self.cleanupPreviousTask()
            }
        }
    }
    
    // MARK: - Audio Session Handling
    private func setupAudioSession(activate: Bool) throws {
        guard audioSessionActive != activate else { return }
        let session = AVAudioSession.sharedInstance()
        if activate {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            audioSessionActive = true
        } else {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
            audioSessionActive = false
        }
    }
    
    // MARK: - Cleanup
    private func cleanupPreviousTask() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
    
    private func cleanupResources(deactivateSession: Bool) {
        if isListening || audioEngine.isRunning {
            stopListening()
        } else {
            cleanupPreviousTask()
            if deactivateSession && audioSessionActive {
                try? setupAudioSession(activate: false)
            }
        }
    }
    
    deinit {
        print("VoiceInputManager deinit")
    }
}

// MARK: - SFSpeechRecognizerAuthorizationStatus Extension
extension SFSpeechRecognizerAuthorizationStatus {
    var description: String {
        switch self {
        case .authorized:   return "Authorized"
        case .denied:       return "Denied"
        case .restricted:   return "Restricted"
        case .notDetermined:return "Not Determined"
        @unknown default:   return "Unknown"
        }
    }
}

// MARK: - Voice Input Area View

struct VoiceInputAreaView: View {
    @Binding var userInput: String
    let isProcessing: Bool
    let placeholder: String
    let sendMessageAction: () -> Void
    
    @ObservedObject var voiceManager: VoiceInputManager
    @FocusState private var isTextFieldFocused: Bool
    @State private var isPressingHoldButton: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            voiceModeButton
                .padding(.leading, 4)
            textEditorArea
            sendButtonArea
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 12))
        .onAppear {
            if !voiceManager.hasPermissions &&
                (SFSpeechRecognizer.authorizationStatus() == .notDetermined ||
                 AVAudioSession.sharedInstance().recordPermission == .undetermined) {
                voiceManager.requestPermissions()
            }
        }
    }
    
    @ViewBuilder
    private var voiceModeButton: some View {
        Group {
            if voiceManager.currentMode == .liveTranscription {
                Button {
                    if voiceManager.isListening {
                        voiceManager.stopListening()
                        isTextFieldFocused = true
                    } else {
                        userInput = ""
                        isTextFieldFocused = false
                        voiceManager.startListening()
                    }
                } label: { micIcon }
                    .disabled(isProcessing)
            } else {
                micIcon
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isPressingHoldButton && !voiceManager.isListening && !isProcessing {
                                    isPressingHoldButton = true
                                    isTextFieldFocused = false
                                    userInput = ""
                                    voiceManager.startListening()
#if os(iOS)
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                                }
                            }
                            .onEnded { _ in
                                if isPressingHoldButton {
                                    voiceManager.stopListening()
                                    isPressingHoldButton = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isTextFieldFocused = true
                                    }
#if os(iOS)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                                }
                            }
                    )
                    .disabled(isProcessing)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: voiceManager.isListening)
    }
    
    private var micIcon: some View {
        let micColor: Color = {
            if isProcessing { return Color.gray.opacity(0.6) }
            if voiceManager.isListening || isPressingHoldButton { return Color.red }
            return Color.blue
        }()
        let iconName = (voiceManager.isListening || isPressingHoldButton) ? "stop.circle.fill" : "mic.circle.fill"
        
        return Image(systemName: iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(micColor)
            .symbolEffect(.pulse.byLayer, options: .repeating, isActive: voiceManager.isListening)
            .animation(.easeInOut(duration: 0.2), value: isProcessing)
            .animation(.easeInOut(duration: 0.2), value: voiceManager.isListening)
            .animation(.easeInOut(duration: 0.2), value: isPressingHoldButton)
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
                    userInput.isEmpty && !isInputDisabled ?
                    Text(placeholder)
                        .foregroundColor(Color(.placeholderText))
                        .padding(.leading, 14)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                    : nil,
                    alignment: .topLeading
                )
                .disabled(isInputDisabled)
                .onChange(of: isTextFieldFocused) {
                    if isTextFieldFocused && voiceManager.isListening {
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
                        .background(Circle().fill(isSendButtonEnabled ? Color.blue : Color.gray.opacity(0.5)))
                }
            }
        }
        .disabled(!isSendButtonEnabled || isProcessing || isInputDisabled)
        .animation(.easeInOut(duration: 0.2), value: isProcessing)
        .animation(.easeInOut(duration: 0.2), value: isSendButtonEnabled)
        .animation(.easeInOut, value: isInputDisabled)
        .keyboardShortcut(.defaultAction)
        .keyboardShortcut(.return, modifiers: .command)
        .sensoryFeedback(.impact(weight: .medium), trigger: isProcessing && isSendButtonEnabled)
    }
    
    private var isInputDisabled: Bool {
        voiceManager.isListening || isPressingHoldButton
    }
    
    private var isSendButtonEnabled: Bool {
        !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Preview Provider

struct VoiceInputAreaView_Previews: PreviewProvider {
    @State static var previewUserInput: String = ""
    @StateObject static var previewVoiceManager = VoiceInputManager()
    @State static var previewIsProcessing: Bool = false
    @State static var previewMode: VoiceMode = .liveTranscription
    
    static var previews: some View {
        VStack(spacing: 15) {
            GroupBox("Preview Controls") {
                Picker("Voice Mode", selection: $previewMode) {
                    ForEach(VoiceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: previewMode) {
                    previewVoiceManager.currentMode = previewMode
                    if previewVoiceManager.isListening { previewVoiceManager.stopListening() }
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
                Text("Listening: \(previewVoiceManager.isListening ? "YES" : "NO")")
                Text("Permissions: \(previewVoiceManager.hasPermissions ? "YES" : "NO")")
                if let err = previewVoiceManager.error {
                    Text("Error: \(err)").foregroundColor(.red).lineLimit(2).font(.caption)
                } else {
                    Text("Error: None").foregroundColor(.green)
                }
                Text("User Binding: \"\(previewUserInput)\"")
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
