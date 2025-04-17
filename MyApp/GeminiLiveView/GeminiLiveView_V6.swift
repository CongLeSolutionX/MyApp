////
////  GeminiLiveView_V6.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//import Speech
//import AVFoundation
//
//// MARK: - Complete GeminiLiveView with Speech-to-Text and Text-to-Speech
//
//struct GeminiLiveView: View {
//    @Binding var isPresented: Bool
//
//    // Speech Recognition properties
//    @StateObject private var speechRecognizer = SpeechRecognizer()
//
//    // Text-to-Speech Synthesizer
//    private let speechSynthesizer = AVSpeechSynthesizer()
//
//    // Session state
//    @State private var sessionState: GeminiSessionState = .paused
//
//    // Chat messages
//    @State private var chatMessages: [GeminiMessage] = []
//
//    // Optional manual text input (enabled when paused)
//    @State private var userTextInput: String = ""
//
//    // Task for AI processing & speech simulation
//    @State private var aiTask: Task<Void, Never>? = nil
//
//    // Namespace for scrolling
//    @Namespace private var bottomID
//
//    var body: some View {
//        ZStack {
//            LinearGradient(colors: [Color.black.opacity(0.95), Color.black.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
//                .ignoresSafeArea()
//
//            VStack(spacing: 16) {
//
//                LiveStatusBar(sessionState: sessionState)
//
//                ScrollViewReader { proxy in
//                    ScrollView {
//                        LazyVStack(alignment: .leading, spacing: 12) {
//                            ForEach(chatMessages) { message in
//                                ChatMessageRow(message: message)
//                            }
//
//                            // Show live partial text during listening
//                            if !speechRecognizer.transcribedText.isEmpty && sessionState == .listening {
//                                ChatMessageRow(message: GeminiMessage(id: UUID(), sender: .user, content: speechRecognizer.transcribedText + "…"))
//                                    .italic()
//                                    .foregroundColor(.gray)
//                            }
//
//                            Color.clear.frame(height: 1).id(bottomID)
//                        }
//                        .padding(.horizontal)
//                    }
//                    .onChange(of: chatMessages) { _ in
//                        withAnimation(.easeOut(duration: 0.5)) {
//                            proxy.scrollTo(bottomID, anchor: .bottom)
//                        }
//                    }
//                }
//                .frame(maxHeight: 400)
//
//                // Manual input area (editable only when paused)
//                VStack {
//                    if !speechRecognizer.transcribedText.isEmpty && sessionState == .listening {
//                        Text("Recognizing: \"\(speechRecognizer.transcribedText)\"")
//                            .foregroundColor(.gray)
//                            .font(.footnote)
//                            .padding(.bottom, 4)
//                    }
//
//                    HStack(spacing: 12) {
//                        TextField("Type or wait for voice input...", text: $userTextInput)
//                            .textFieldStyle(.roundedBorder)
//                            .disabled(sessionState != .paused)
//                            .autocapitalization(.sentences)
//                            .submitLabel(.send)
//                            .onSubmit {
//                                sendUserMessage()
//                            }
//                            .accessibilityLabel("User input text field")
//
//                        Button {
//                            sendUserMessage()
//                        } label: {
//                            Image(systemName: "paperplane.fill")
//                                .font(.system(size: 22))
//                                .foregroundColor(userTextInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || sessionState != .paused
//                                                 ? .gray : .blue)
//                        }
//                        .disabled(userTextInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || sessionState != .paused)
//                        .accessibilityLabel("Send user message")
//                    }
//                    .padding(.bottom, 8)
//                }
//                .padding(.horizontal)
//
//                Spacer(minLength: 0)
//
//                bottomControls
//                    .padding(.bottom, 30)
//            }
//            .padding(.top, 30)
//            .onAppear {
//                speechRecognizer.reset()
//                sessionState = .paused
//                requestSpeechAuthorization()
//                speechSynthesizer.delegate = speechSynthesizerDelegate
//            }
//            .onDisappear {
//                stopListening()
//                speechSynthesizer.stopSpeaking(at: .immediate)
//            }
//            .disabled(aiTask != nil)
//        }
//        .interactiveDismissDisabled(true)
//    }
//
//    // MARK: Bottom controls: Hold/Resume and Interrupt/End
//
//    private var bottomControls: some View {
//        HStack(spacing: 60) {
//            // Hold / Resume Button
//            Button {
//                if sessionState == .paused {
//                    startListening()
//                } else if sessionState == .listening {
//                    pauseListening()
//                }
//            } label: {
//                VStack(spacing: 10) {
//                    ZStack {
//                        Circle()
//                            .fill(sessionState == .paused ? Color.green.opacity(0.4) : Color.gray.opacity(0.6))
//                            .frame(width: 60, height: 60)
//                        Image(systemName: sessionState == .paused ? "play.fill" : "pause.fill")
//                            .foregroundColor(sessionState == .paused ? .green : .white)
//                            .font(.system(size: 26))
//                    }
//                    Text(sessionState == .paused ? "Resume" : "Hold")
//                        .font(.caption)
//                        .foregroundColor(sessionState == .paused ? .green : .white)
//                }
//            }
//            .accessibilityLabel(sessionState == .paused ? "Resume listening" : "Pause listening")
//
//            // Interrupt / End button
//            Button {
//                if aiTask != nil || speechSynthesizer.isSpeaking {
//                    interruptAI()
//                } else {
//                    endSession()
//                }
//            } label: {
//                VStack(spacing: 10) {
//                    ZStack {
//                        Circle()
//                            .fill((aiTask != nil || speechSynthesizer.isSpeaking) ? Color.yellow.opacity(0.8) : Color.red)
//                            .frame(width: 60, height: 60)
//                        Image(systemName: (aiTask != nil || speechSynthesizer.isSpeaking) ? "stop.fill" : "xmark")
//                            .foregroundColor(.white)
//                            .font(.system(size: 26))
//                    }
//                    Text((aiTask != nil || speechSynthesizer.isSpeaking) ? "Interrupt" : "End")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                }
//            }
//            .accessibilityLabel((aiTask != nil || speechSynthesizer.isSpeaking) ? "Interrupt current response" : "End session")
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.horizontal)
//    }
//
//    // MARK: - Speech Recognition Control Methods
//
//    private func requestSpeechAuthorization() {
//        SFSpeechRecognizer.requestAuthorization { status in
//            switch status {
//            case .authorized:
//                print("Speech recognition authorized")
//            case .denied:
//                print("Speech recognition denied")
//            case .restricted:
//                print("Speech recognition restricted")
//            case .notDetermined:
//                print("Speech recognition not determined")
//            @unknown default:
//                break
//            }
//        }
//    }
//
//    private func startListening() {
//        guard SpeechRecognizer.isAvailable else {
//            print("Speech recognition not available")
//            sessionState = .error(message: "Speech recognition not available")
//            return
//        }
//        sessionState = .listening
//
//        speechRecognizer.startRecognition(
//            onFinalResult: { recognizedText in
//                guard !recognizedText.isEmpty else { return }
//                appendUserMessage(recognizedText)
//                userTextInput = ""
//
//                pauseListening()
//                simulateAIResponse(for: recognizedText)
//            },
//            onError: { error in
//                print("Speech recognition error: \(error.localizedDescription)")
//                sessionState = .paused
//            }
//        )
//    }
//
//    private func stopListening() {
//        sessionState = .paused
//        speechRecognizer.stopRecognition()
//    }
//
//    private func pauseListening() {
//        sessionState = .paused
//        speechRecognizer.stopRecognition()
//    }
//
//    // MARK: - Interrupt AI speaking or processing
//    private func interruptAI() {
//        aiTask?.cancel()
//        aiTask = nil
//        if speechSynthesizer.isSpeaking {
//            speechSynthesizer.stopSpeaking(at: .immediate)
//        }
//        startListening()
//        appendAssistantMessage("Interrupted. Ready for new input.")
//    }
//
//    private func endSession() {
//        aiTask?.cancel()
//        speechRecognizer.stopRecognition()
//        speechSynthesizer.stopSpeaking(at: .immediate)
//        isPresented = false
//    }
//
//    // MARK: - Chat Helpers
//
//    private func appendUserMessage(_ text: String) {
//        withAnimation {
//            chatMessages.append(GeminiMessage(sender: .user, content: text))
//        }
//    }
//
//    private func appendAssistantMessage(_ text: String) {
//        withAnimation {
//            chatMessages.append(GeminiMessage(sender: .assistant, content: text))
//        }
//    }
//
//    // MARK: - AI response simulation (with TTS)
//
//    private func simulateAIResponse(for query: String) {
//        sessionState = .processing
//        aiTask = Task {
//            // Simulate processing delay
//            try await Task.sleep(nanoseconds: UInt64.random(in: 1_500_000_000...3_000_000_000))
//
//            guard !Task.isCancelled else { return }
//
//            let response = generateAssistantResponse(for: query)
//
//            await MainActor.run {
//                sessionState = .speaking
//                appendAssistantMessage(response)
//                speakText(response)
//            }
//        }
//    }
//
//    private func generateAssistantResponse(for query: String) -> String {
//        let lowercasedQuery = query.lowercased()
//
//        if lowercasedQuery.contains("weather") {
//            return "It’s bright and sunny with a temperature around 25 degrees Celsius."
//        } else if lowercasedQuery.contains("swift") {
//            return "Swift is a powerful, easy-to-learn programming language developed by Apple."
//        } else if lowercasedQuery.contains("timer") {
//            return "Timer is set. I will let you know when the time’s up."
//        } else if lowercasedQuery.contains("a*") || lowercasedQuery.contains("astar") || lowercasedQuery.contains("pathfinding") {
//            return "A star search algorithm finds the shortest path efficiently by using heuristics."
//        } else if lowercasedQuery.contains("fun fact") {
//            return "Did you know? Octopuses have three hearts and blue blood."
//        }
//
//        return "I'm here to help you with anything else you want to know."
//    }
//
//    // MARK: Text-To-Speech
//
//    private func speakText(_ text: String) {
//        guard !speechSynthesizer.isSpeaking else {
//            print("Already speaking")
//            return
//        }
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
//
//        speechSynthesizer.speak(utterance)
//    }
//
//    // MARK: Manual text send
//
//    private func sendUserMessage() {
//        let trimmed = userTextInput.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return }
//
//        appendUserMessage(trimmed)
//        userTextInput = ""
//
//        pauseListening()
//        simulateAIResponse(for: trimmed)
//    }
//
//    // MARK: AVSpeechSynthesizer Delegate Wrapper
//
//    private lazy var speechSynthesizerDelegate = SpeechSynthesizerDelegateWrapper { finishedSuccessfully in
//
//        DispatchQueue.main.async {
//            self.aiTask = nil
//            self.sessionState = .paused
//        }
//    }
//}
//
//// MARK: - Delegate wrapper for AVSpeechSynthesizerDelegate
//
//class SpeechSynthesizerDelegateWrapper: NSObject, AVSpeechSynthesizerDelegate {
//    let completion: (_ finishedSuccessfully: Bool) -> Void
//
//    init(completion: @escaping (_ finishedSuccessfully: Bool) -> Void) {
//        self.completion = completion
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        completion(true)
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
//        completion(false)
//    }
//}
//
//// MARK: - Speech Recognizer ObservableObject
//
//final class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
//
//    @Published var transcribedText: String = ""
//
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine()
//
//    static var isAvailable: Bool {
//        return SFSpeechRecognizer.supportsOnDeviceRecognition
//    }
//
//    override init() {
//        super.init()
//        speechRecognizer.delegate = self
//    }
//
//    func reset() {
//        transcribedText = ""
//        stopRecognition()
//    }
//
//    func startRecognition(onFinalResult: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
//        if audioEngine.isRunning {
//            stopRecognition()
//        }
//
//        transcribedText = ""
//
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        } catch {
//            onError(error)
//            return
//        }
//
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            onError(NSError(domain: "SpeechRecognizer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create request"]))
//            return
//        }
//
//        recognitionRequest.shouldReportPartialResults = true
//        recognitionRequest.requiresOnDeviceRecognition = false
//
//        do {
//            let inputNode = audioEngine.inputNode
//            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//                guard let self = self else { return }
//
//                if let result = result {
//                    DispatchQueue.main.async {
//                        self.transcribedText = result.bestTranscription.formattedString
//                    }
//                    if result.isFinal {
//                        onFinalResult(result.bestTranscription.formattedString)
//                        self.stopRecognition()
//                    }
//                } else if let error = error {
//                    onError(error)
//                    self.stopRecognition()
//                }
//            }
//
//            let recordingFormat = inputNode.outputFormat(forBus: 0)
//            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//                recognitionRequest.append(buffer)
//            }
//
//            audioEngine.prepare()
//            try audioEngine.start()
//        } catch {
//            onError(error)
//        }
//    }
//
//    func stopRecognition() {
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            audioEngine.inputNode.removeTap(onBus: 0)
//        }
//        recognitionRequest?.endAudio()
//        recognitionTask?.cancel()
//        recognitionTask = nil
//        recognitionRequest = nil
//    }
//
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        print("Speech recognizer availability changed: \(available)")
//    }
//}
//
//// MARK: - GeminiMessage model & session state
//
//struct GeminiMessage: Identifiable, Equatable {
//    enum Sender {
//        case user, assistant
//    }
//
//    let id = UUID()
//    let sender: Sender
//    let content: String
//    let timestamp = Date()
//}
//
//enum GeminiSessionState: Equatable {
//    case listening
//    case processing
//    case speaking
//    case paused
//    case error(message: String)
//
//    var isActive: Bool {
//        switch self {
//        case .listening, .processing, .speaking: return true
//        default: return false
//        }
//    }
//
//    var isBusy: Bool {
//        switch self {
//        case .processing, .speaking: return true
//        default: return false
//        }
//    }
//}
//
//// MARK: - UI Components
//
//struct LiveStatusBar: View {
//    var sessionState: GeminiSessionState
//
//    var body: some View {
//        HStack(spacing: 8) {
//            Group {
//                switch sessionState {
//                case .listening:
//                    PulsatingMicIcon(animationColor: .green)
//                case .processing:
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                case .speaking:
//                    Image(systemName: "speaker.wave.2.fill")
//                        .font(.system(size: 24))
//                        .foregroundColor(.blue)
//                        .transition(.opacity)
//                case .paused:
//                    Image(systemName: "mic.slash.fill")
//                        .foregroundColor(.yellow)
//                case .error:
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .foregroundColor(.red)
//                }
//            }
//            .frame(width: 30, height: 30)
//            .animation(.easeInOut, value: sessionState)
//
//            Text(statusText)
//                .font(.headline)
//                .foregroundColor(.white.opacity(0.8))
//                .animation(.easeInOut, value: sessionState)
//
//            Spacer()
//        }
//        .padding(.horizontal)
//    }
//
//    private var statusText: String {
//        switch sessionState {
//        case .listening: return "Listening..."
//        case .processing: return "Processing..."
//        case .speaking: return "Gemini is speaking"
//        case .paused: return "Paused"
//        case .error(let msg): return "Error: \(msg)"
//        }
//    }
//}
//
//struct PulsatingMicIcon: View {
//    @State private var pulse = false
//    let animationColor: Color
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(animationColor.opacity(0.3))
//                .scaleEffect(pulse ? 1.3 : 1)
//                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
//
//            Image(systemName: "mic.fill")
//                .foregroundColor(animationColor)
//                .font(.system(size: 22))
//                .shadow(radius: 1)
//        }
//        .onAppear {
//            pulse = true
//        }
//    }
//}
//
//struct ChatMessageRow: View {
//    let message: GeminiMessage
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 10) {
//            if message.sender == .assistant { Spacer() }
//
//            Text(message.content)
//                .padding(12)
//                .foregroundColor(message.sender == .user ? .white : .black)
//                .background(message.sender == .user ? Color.blue : Color.gray.opacity(0.2))
//                .cornerRadius(15)
//                .font(.body)
//                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.sender == .user ? .leading : .trailing)
//                .fixedSize(horizontal: false, vertical: true)
//
//            if message.sender == .user { Spacer() }
//        }
//        .padding(.horizontal, 10)
//        .padding(.vertical, 2)
//        .frame(maxWidth: .infinity, alignment: message.sender == .user ? .leading : .trailing)
//        .accessibilityElement(children: .combine)
//        .accessibilityLabel(messageAccessibilityLabel)
//    }
//
//    private var messageAccessibilityLabel: String {
//        switch message.sender {
//        case .user: return "You said, \(message.content)"
//        case .assistant: return "Gemini replied, \(message.content)"
//        }
//    }
//}
//
//// MARK: - Preview
//
//struct GeminiLiveView_Previews: PreviewProvider {
//    @State static var isPresented = true
//
//    static var previews: some View {
//        GeminiLiveView(isPresented: $isPresented)
//            .preferredColorScheme(.dark)
//    }
//}
//
//@main
//struct GeminiLiveApp: App {
//    @State private var showGeminiLive = true
//
//    var body: some Scene {
//        WindowGroup {
//            if showGeminiLive {
//                GeminiLiveView(isPresented: $showGeminiLive)
//                    .preferredColorScheme(.dark)
//            } else {
//                // Optionally fallback UI
//                Text("Gemini session ended")
//            }
//        }
//    }
//}
