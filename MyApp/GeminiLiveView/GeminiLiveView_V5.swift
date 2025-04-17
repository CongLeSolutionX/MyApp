//
//  GeminiLiveView_V5.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

import SwiftUI
import Speech
import AVFoundation

// MARK: - GeminiLiveView with Speech to Text Integration

struct GeminiLiveView: View {
    // Controls the presentation
    @Binding var isPresented: Bool

    // MARK: - Speech Recognition Properties
    @StateObject private var speechRecognizer = SpeechRecognizer()

    @State private var sessionState: GeminiSessionState = .paused // Start paused, waiting for user to tap Hold/Resume

    // Chat Messages
    @State private var chatMessages: [GeminiMessage] = []

    // Optional fallback manual input text
    @State private var userTextInput: String = ""

    /// Simulation task for AI response
    @State private var aiTask: Task<Void, Never>? = nil

    @Namespace private var bottomID

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black.opacity(0.95), Color.black.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                LiveStatusBar(sessionState: sessionState)

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(chatMessages) { message in
                                ChatMessageRow(message: message)
                            }

                            if !speechRecognizer.transcribedText.isEmpty && sessionState == .listening {
                                // Show live partial recognized text with indicator
                                ChatMessageRow(message: GeminiMessage(id: UUID(), sender: .user, content: speechRecognizer.transcribedText + "…"))
                                    .italic()
                                    .foregroundColor(.gray)
                            }

                            Color.clear.frame(height: 1).id(bottomID)
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: chatMessages) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo(bottomID, anchor: .bottom)
                        }
                    }
                }
                .frame(maxHeight: 400)

                // Optional: Display recognized text and allow manual sending
                VStack {
                    if !speechRecognizer.transcribedText.isEmpty && sessionState == .listening {
                        Text("Recognizing: \"\(speechRecognizer.transcribedText)\"")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .padding(.bottom, 4)
                    }

                    HStack(spacing: 12) {
                        TextField("Type or wait for voice input...", text: $userTextInput)
                            .textFieldStyle(.roundedBorder)
                            .disabled(sessionState != .paused)
                            .autocapitalization(.sentences)
                            .submitLabel(.send)
                            .onSubmit {
                                sendUserMessage()
                            }
                            .accessibilityLabel("User input text field")

                        Button {
                            sendUserMessage()
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 22))
                                .foregroundColor(userTextInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || sessionState != .paused
                                                 ? .gray : .blue)
                        }
                        .disabled(userTextInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || sessionState != .paused)
                        .accessibilityLabel("Send user message")
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal)

                Spacer(minLength: 0)

                // Bottom Controls for mic, interrupt, end session
                bottomControls
                    .padding(.bottom, 30)

            }
            .padding(.top, 30)
            .onAppear {
                speechRecognizer.reset()
                sessionState = .paused
                requestSpeechAuthorization()
            }
            .onDisappear {
                stopListening()
            }
            .disabled(aiTask != nil) // Disable interaction during AI response speaking
        }
        .interactiveDismissDisabled(true)
    }

    // MARK: Bottom controls view

    private var bottomControls: some View {
        HStack(spacing: 60) {
            // Hold / Resume Button
            Button {
                if sessionState == .paused {
                    startListening()
                } else if sessionState == .listening {
                    pauseListening()
                }
            } label: {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(sessionState == .paused ? Color.green.opacity(0.4) : Color.gray.opacity(0.6))
                            .frame(width: 60, height: 60)
                        Image(systemName: sessionState == .paused ? "play.fill" : "pause.fill")
                            .foregroundColor(sessionState == .paused ? .green : .white)
                            .font(.system(size: 26))
                    }
                    Text(sessionState == .paused ? "Resume" : "Hold")
                        .font(.caption)
                        .foregroundColor(sessionState == .paused ? .green : .white)
                }
            }.accessibilityLabel(sessionState == .paused ? "Resume listening" : "Pause listening")

            // Interrupt / End button
            Button {
                if aiTask != nil {
                    interruptAI()
                } else {
                    endSession()
                }
            } label: {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(aiTask != nil ? Color.yellow.opacity(0.8) : Color.red)
                            .frame(width: 60, height: 60)
                        Image(systemName: aiTask != nil ? "stop.fill" : "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 26))
                    }
                    Text(aiTask != nil ? "Interrupt" : "End")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .accessibilityLabel(aiTask != nil ? "Interrupt current response" : "End session")
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    // MARK: - Speech recognition control methods

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Speech recognition authorized.")
            case .denied:
                print("Speech recognition authorization denied.")
            case .restricted:
                print("Speech recognition restricted.")
            case .notDetermined:
                print("Speech recognition not determined.")
            @unknown default:
                break
            }
        }
    }

    private func startListening() {
        guard SpeechRecognizer.isAvailable else {
            print("Speech recognition not available")
            return
        }

        sessionState = .listening

        speechRecognizer.startRecognition(
            onFinalResult: { recognizedText in
                // Only act when we got final recognized speech
                if !recognizedText.isEmpty {
                    appendUserMessage(recognizedText)
                    userTextInput = "" // Clear manual input in case

                    // Stop listening while AI processes
                    pauseListening()

                    simulateAIResponse(for: recognizedText)
                }
            },
            onError: { error in
                // Handle errors gracefully
                print("Speech recognition error: \(error.localizedDescription)")
                sessionState = .paused
            }
        )
    }

    private func stopListening() {
        sessionState = .paused
        speechRecognizer.stopRecognition()
    }

    private func pauseListening() {
        sessionState = .paused
        speechRecognizer.stopRecognition()
    }

    private func interruptAI() {
        aiTask?.cancel()
        aiTask = nil
        startListening()
        appendAssistantMessage("Interrupted. Ready for new input.")
    }

    private func endSession() {
        aiTask?.cancel()
        speechRecognizer.stopRecognition()
        isPresented = false
    }

    // MARK: - Chat updates

    private func appendUserMessage(_ text: String) {
        withAnimation {
            chatMessages.append(GeminiMessage(sender: .user, content: text))
        }
    }

    private func appendAssistantMessage(_ text: String) {
        withAnimation {
            chatMessages.append(GeminiMessage(sender: .assistant, content: text))
        }
    }

    // MARK: - AI response simulation

    private func simulateAIResponse(for query: String) {
        sessionState = .processing

        // Simulate async AI processing and speaking response
        aiTask = Task {
            // Simulate processing delay (1.5 - 3 seconds)
            try await Task.sleep(nanoseconds: UInt64.random(in: 1_500_000_000...3_000_000_000))

            guard !Task.isCancelled else { return }

            let response = generateAssistantResponse(for: query)

            await MainActor.run {
                sessionState = .speaking
                appendAssistantMessage(response)
            }

            // Simulate speaking duration (based on text length)
            let speakDuration = max(2.0, Double(response.count) / 20.0)
            try await Task.sleep(nanoseconds: UInt64(speakDuration * 1_000_000_000))

            guard !Task.isCancelled else { return }

            await MainActor.run {
                aiTask = nil
                sessionState = .paused // Pause after finishing so user can choose to resume listening
            }
        }
    }

    private func generateAssistantResponse(for query: String) -> String {
        let lowercasedQuery = query.lowercased()

        if lowercasedQuery.contains("weather") {
            return "It’s bright and sunny with a temperature around 25°C."
        } else if lowercasedQuery.contains("swift") {
            return "Swift is a powerful, easy to learn language developed by Apple."
        } else if lowercasedQuery.contains("timer") {
            return "Timer is set. I'll let you know when the time’s up!"
        } else if lowercasedQuery.contains("a*") || lowercasedQuery.contains("astar") || lowercasedQuery.contains("pathfinding") {
            return "A* search algorithm finds the shortest path efficiently by using heuristics."
        } else if lowercasedQuery.contains("fun fact") {
            return "Did you know? Octopuses have three hearts and blue blood."
        }

        // Default fallback
        return "I'm ready to help with anything else!"
    }

    // MARK: Manual text send (from TextField)

    private func sendUserMessage() {
        let trimmed = userTextInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        appendUserMessage(trimmed)
        userTextInput = ""

        pauseListening()
        simulateAIResponse(for: trimmed)
    }
}

// MARK: - SpeechRecognizer class using ObservableObject

final class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {

    @Published var transcribedText: String = ""

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    static var isAvailable: Bool {
        return SFSpeechRecognizer.supportsOnDeviceRecognition
    }

    override init() {
        super.init()
        speechRecognizer.delegate = self
    }

    func reset() {
        transcribedText = ""
        stopRecognition()
    }

    func startRecognition(onFinalResult: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        if audioEngine.isRunning {
            stopRecognition()
        }

        // Reset published text
        transcribedText = ""

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            onError(error)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            onError(NSError(domain: "SpeechRecognizer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"]))
            return
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false

        do {
            let inputNode = audioEngine.inputNode
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }

                if let result = result {
                    DispatchQueue.main.async {
                        self.transcribedText = result.bestTranscription.formattedString
                    }

                    if result.isFinal {
                        onFinalResult(result.bestTranscription.formattedString)
                        self.stopRecognition()
                    }
                } else if let error = error {
                    onError(error)
                    self.stopRecognition()
                }
            }

            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                recognitionRequest.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

        } catch {
            print("Audio engine start error: \(error.localizedDescription)")
            onError(error)
        }
    }

    func stopRecognition() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }

    // MARK: SFSpeechRecognizerDelegate

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Speech recognizer availability changed: \(available)")
    }
}

// MARK: - GeminiMessage & GeminiSessionState remain unchanged
struct GeminiMessage: Identifiable, Equatable {
    enum Sender {
        case user, assistant
    }

    let id = UUID()
    let sender: Sender
    let content: String
    let timestamp = Date()
}

enum GeminiSessionState: Equatable {
    case listening
    case processing
    case speaking
    case paused
    case error(message: String)

    var isActive: Bool {
        switch self {
        case .listening, .processing, .speaking: return true
        default: return false
        }
    }

    var isBusy: Bool {
        switch self {
        case .processing, .speaking: return true
        default: return false
        }
    }
}

// MARK: - Live Status Bar View
struct LiveStatusBar: View {
    var sessionState: GeminiSessionState

    var body: some View {
        HStack(spacing: 8) {
            // Live Indicator Icon & animation
            Group {
                switch sessionState {
                case .listening:
                    PulsatingMicIcon(animationColor: .green)
                case .processing:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                case .speaking:
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .transition(.opacity)
                case .paused:
                    Image(systemName: "mic.slash.fill")
                        .foregroundColor(.yellow)
                case .error:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
            }
            .frame(width: 30, height: 30)
            .animation(.easeInOut, value: sessionState)

            Text(statusText)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .animation(.easeInOut, value: sessionState)

            Spacer()
        }
        .padding(.horizontal)
    }

    private var statusText: String {
        switch sessionState {
        case .listening: return "Listening..."
        case .processing: return "Processing..."
        case .speaking: return "Gemini is speaking"
        case .paused: return "Paused"
        case .error(let msg): return "Error: \(msg)"
        }
    }
}

// MARK: - Pulsating Mic Icon View
struct PulsatingMicIcon: View {
    @State private var pulse = false
    let animationColor: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(animationColor.opacity(0.3))
                .scaleEffect(pulse ? 1.3 : 1)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)

            Image(systemName: "mic.fill")
                .foregroundColor(animationColor)
                .font(.system(size: 22))
                .shadow(radius: 1)
        }
        .onAppear {
            pulse = true
        }
    }
}

// MARK: - Individual Chat Message Row
struct ChatMessageRow: View {
    let message: GeminiMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.sender == .assistant { Spacer() } // Assistant messages aligned right

            Text(message.content)
                .padding(12)
                .foregroundColor(message.sender == .user ? .white : .black)
                .background(message.sender == .user ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(15)
                .font(.body)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.sender == .user ? .leading : .trailing)
                .fixedSize(horizontal: false, vertical: true)

            if message.sender == .user { Spacer() } // User messages aligned left
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: message.sender == .user ? .leading : .trailing)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(messageAccessibilityLabel)
    }

    private var messageAccessibilityLabel: String {
        switch message.sender {
        case .user: return "You said, \(message.content)"
        case .assistant: return "Gemini replied, \(message.content)"
        }
    }
}
