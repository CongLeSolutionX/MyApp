////
////  GeminiLiveView_V7.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//import Speech
//import AVFoundation
//
//// MARK: - Haptic Feedback Generator
//// Simple helper for haptic feedback
//struct HapticFeedback {
//    static let generator = UIImpactFeedbackGenerator(style: .medium)
//    static let notificationGenerator = UINotificationFeedbackGenerator()
//
//    static func impact() {
//        generator.prepare()
//        generator.impactOccurred()
//    }
//
//    static func success() {
//        notificationGenerator.prepare()
//        notificationGenerator.notificationOccurred(.success)
//    }
//
//    static func error() {
//        notificationGenerator.prepare()
//        notificationGenerator.notificationOccurred(.error)
//    }
//}
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
//    @State private var sessionState: GeminiSessionState = .initializing // Start in initializing
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
//    // --- Enhancements ---
//    @State private var speechPermissionGranted: Bool? = nil // Track permission status
//
//    var body: some View {
//        ZStack {
//            // Background Gradient
//            LinearGradient(colors: [Color.black.opacity(0.98), Color.black.opacity(0.90)], startPoint: .topLeading, endPoint: .bottomTrailing)
//                .ignoresSafeArea()
//
//            VStack(spacing: 0) { // Reduced spacing
//
//                // Status Bar
//                LiveStatusBar(sessionState: sessionState, permissionGranted: speechPermissionGranted)
//                    .padding(.top, 40) // Adjust top padding
//                    .padding(.bottom, 10)
//
//                // Chat Area
//                ScrollViewReader { proxy in
//                    ScrollView {
//                        LazyVStack(alignment: .leading, spacing: 12) {
//                            ForEach(chatMessages) { message in
//                                ChatMessageRow(message: message)
//                                    .id(message.id) // Ensure each row has a unique ID for the ScrollViewReader
//                            }
//
//                            // Show live partial text during listening
//                            if speechRecognizer.isRecognizing && !speechRecognizer.transcribedText.isEmpty && sessionState == .listening {
//                                ChatMessageRow(message: GeminiMessage(id: UUID(), sender: .user, content: speechRecognizer.transcribedText + "…"))
//                                    .italic()
//                                    .foregroundColor(.gray.opacity(0.8))
//                                    .transition(.opacity.animation(.easeIn))
//                            }
//
//                            Color.clear
//                                .frame(height: 1)
//                                .id(bottomID)
//                        }
//                        .padding(.horizontal)
//                        .padding(.top, 10) // Add some padding at the top of messages
//                    }
//                    .onChange(of: chatMessages.count) { _ in // Trigger on count change for reliability
//                         scrollToBottom(proxy: proxy)
//                    }
//                    .onChange(of: speechRecognizer.transcribedText) { _ in // Scroll when partial text updates
//                         if sessionState == .listening {
//                             scrollToBottom(proxy: proxy)
//                         }
//                    }
//                    .onAppear { // Scroll on initial appear if messages exist
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Small delay to ensure layout
//                            scrollToBottom(proxy: proxy, animated: false)
//                        }
//                    }
//                }
//                // Give chat area more space
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//                // Manual Input Area
//                VStack(spacing: 8) {
//                    // Display final recognized text briefly after listening stops
//                    if !speechRecognizer.transcribedText.isEmpty && sessionState == .paused && speechRecognizer.lastRecognizedText != "" {
//                        Text("Recognized: \"\(speechRecognizer.lastRecognizedText)\"")
//                            .foregroundColor(.gray)
//                            .font(.footnote)
//                            .padding(.top, 5)
//                            .transition(.opacity.animation(.easeOut))
//                            .onAppear {
//                                // Clear this indicator after a delay
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                                    speechRecognizer.clearLastRecognizedText()
//                                }
//                            }
//                    }
//
//                    HStack(spacing: 12) {
//                        TextField(textFieldPlaceholder, text: $userTextInput)
//                            .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle for better control
//                            .padding(10)
//                            .background(Color.gray.opacity(0.2))
//                            .cornerRadius(10)
//                            .foregroundColor(.white)
//                            .disabled(!canUseTextInput) // Check permission and state
//                            .autocapitalization(.sentences)
//                            .submitLabel(.send)
//                            .onSubmit(sendUserMessage) // Use direct reference
//                            .accessibilityLabel("User input text field")
//
//                        Button {
//                            HapticFeedback.impact()
//                            sendUserMessage()
//                        } label: {
//                            Image(systemName: "paperplane.fill")
//                                .font(.system(size: 20)) // Slightly smaller icon
//                                .foregroundColor(canSendMessage ? .blue : .gray)
//                                .padding(10) // Make tap target larger
//                                .contentShape(Rectangle()) // Ensure padding is part of tap area
//                        }
//                        .disabled(!canSendMessage)
//                        .accessibilityLabel("Send user message button")
//                        .accessibilityHint(canSendMessage ? "" : "Enter text or wait until paused to send")
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 10) // Add vertical padding
//                .background(Color.black.opacity(0.3)) // Subtle background for input area
//
//                Spacer(minLength: 10) // Minimum space before controls
//
//                // Bottom Controls
//                bottomControls
//                    .padding(.bottom, 30) // Ensure controls visible above safe area
//            }
//            .onAppear(perform: initializeSession)
//            .onDisappear(perform: cleanupSession)
//            .disabled(sessionState == .thinking || sessionState == .processing) // Disable whole view slightly during processing
//            .animation(.easeInOut, value: sessionState) // Animate view based on state changes
//        }
//        .interactiveDismissDisabled(aiTask != nil || sessionState != .paused) // Allow dismiss only when truly idle
//        .preferredColorScheme(.dark) // Ensure dark mode
//    }
//
//    // MARK: - Computed Properties for UI State
//
//    private var canUseTextInput: Bool {
//        sessionState == .paused && speechPermissionGranted == true
//    }
//
//    private var canSendMessage: Bool {
//        !userTextInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && canUseTextInput
//    }
//
//    private var textFieldPlaceholder: String {
//        switch sessionState {
//        case .listening: return "Listening for voice..."
//        case .paused: return speechPermissionGranted == true ? "Type or resume voice input..." : "Enable microphone access..."
//        case .speaking, .processing, .thinking: return "Waiting for response..."
//        case .error(let message): return "Error: \(message)"
//        case .initializing: return "Initializing..."
//        case .authorizationDenied: return "Microphone access denied"
//        }
//    }
//
//    // MARK: - UI Components
//
//    private var bottomControls: some View {
//        HStack(spacing: 60) {
//            // Hold / Resume Button
//            Button {
//                HapticFeedback.impact()
//                toggleListeningState()
//            } label: {
//                controlButtonLabel(
//                    systemName: sessionState == .paused || sessionState == .authorizationDenied ? "play.fill" : "pause.fill",
//                    text: sessionState == .paused || sessionState == .authorizationDenied ? "Resume" : "Hold",
//                    color: (sessionState == .paused || sessionState == .authorizationDenied) && speechPermissionGranted == true ? .green : .gray,
//                    enabled: speechPermissionGranted == true
//                )
//            }
//            .disabled(speechPermissionGranted != true) // Disable if no permission
//            .accessibilityLabel(sessionState == .paused ? "Resume listening" : "Pause listening")
//            .accessibilityHint(speechPermissionGranted != true ? "Requires microphone access" : "")
//
//            // Interrupt / End button
//            Button {
//                HapticFeedback.impact()
//                handleInterruptOrEnd()
//            } label: {
//                let isInterruptable = sessionState.isInterruptable || speechSynthesizer.isSpeaking
//                controlButtonLabel(
//                    systemName: isInterruptable ? "stop.fill" : "xmark",
//                    text: isInterruptable ? "Interrupt" : "End",
//                    color: isInterruptable ? .orange : .red, // Use Orange for interrupt
//                    enabled: true // Always enabled
//                )
//            }
//            .accessibilityLabel(sessionState.isInterruptable || speechSynthesizer.isSpeaking ? "Interrupt current response" : "End session and close")
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.horizontal)
//    }
//
//    // Helper for consistent button styling
//    private func controlButtonLabel(systemName: String, text: String, color: Color, enabled: Bool) -> some View {
//        VStack(spacing: 10) {
//            ZStack {
//                Circle()
//                    .fill(enabled ? color.opacity(0.6) : Color.gray.opacity(0.3))
//                    .frame(width: 65, height: 65) // Slightly larger circles
//                Image(systemName: systemName)
//                    .foregroundColor(enabled ? color : .gray)
//                    .font(.system(size: 28)) // Slightly larger icons
//            }
//            Text(text)
//                .font(.caption)
//                .foregroundColor(enabled ? color : .gray)
//        }
//    }
//
//    // MARK: - Session Lifecycle Methods
//
//    private mutating func initializeSession() {
//        print("Initializing GeminiLiveView...")
//        chatMessages = [GeminiMessage(sender: .assistant, content: "Hi there! Press 'Resume' or type a message to start.")] // Initial welcome message
//        requestSpeechAuthorization()
//        speechSynthesizer.delegate = speechSynthesizerDelegate
//        sessionState = .paused // Move to paused after setup
//    }
//
//    private func cleanupSession() {
//        print("Cleaning up GeminiLiveView...")
//        aiTask?.cancel()
//        aiTask = nil
//        speechRecognizer.stopRecognition() // Ensure recognition is stopped
//        if speechSynthesizer.isSpeaking {
//           speechSynthesizer.stopSpeaking(at: .immediate)
//        }
//        // Optionally reset audio session category if needed elsewhere
//        // try? AVAudioSession.sharedInstance().setCategory(.playback)
//    }
//
//    private func endSession() {
//        print("Ending session.")
//        HapticFeedback.success()
//        cleanupSession()
//        isPresented = false // Dismiss the view
//    }
//
//    // MARK: - UI Interaction Methods
//
//     private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
//         DispatchQueue.main.async {
//             if animated {
//                 withAnimation(.easeOut(duration: 0.3)) {
//                     proxy.scrollTo(bottomID, anchor: .bottom)
//                 }
//             } else {
//                 proxy.scrollTo(bottomID, anchor: .bottom)
//             }
//         }
//     }
//
//    private func toggleListeningState() {
//         guard speechPermissionGranted == true else {
//             print("Cannot toggle listening: Permission denied.")
//             // Optionally guide user to settings
//             appendSystemMessage("Microphone access is needed. Please enable it in Settings.")
//             return
//         }
//
//         if sessionState == .paused {
//             startListening()
//         } else if sessionState == .listening {
//             pauseListening()
//         }
//     }
//
//    private func handleInterruptOrEnd() {
//        if sessionState.isInterruptable || speechSynthesizer.isSpeaking {
//            interruptAI()
//        } else {
//            endSession()
//        }
//    }
//
//    // MARK: - Speech Recognition Control Methods
//
//    private func requestSpeechAuthorization() {
//        SFSpeechRecognizer.requestAuthorization { status in
//            DispatchQueue.main.async { // Ensure UI updates on main thread
//                switch status {
//                case .authorized:
//                    print("Speech recognition authorized")
//                    self.speechPermissionGranted = true
//                    if self.sessionState == .initializing { // If initial setup, move to paused
//                        self.sessionState = .paused
//                    }
//                case .denied:
//                    print("Speech recognition denied")
//                    self.speechPermissionGranted = false
//                    self.sessionState = .authorizationDenied
//                    HapticFeedback.error()
//                case .restricted:
//                    print("Speech recognition restricted")
//                    self.speechPermissionGranted = false
//                    self.sessionState = .error(message: "Speech restricted")
//                    HapticFeedback.error()
//                case .notDetermined:
//                    print("Speech recognition not determined")
//                    self.speechPermissionGranted = false
//                    // Stay initializing or paused, wait for user action
//                    self.sessionState = .paused
//                @unknown default:
//                     print("Unknown speech recognition status")
//                     self.speechPermissionGranted = false
//                     self.sessionState = .error(message: "Unknown auth status")
//                     HapticFeedback.error()
//                }
//            }
//        }
//    }
//
//    private func startListening() {
//        guard speechPermissionGranted == true else {
//            print("Cannot start listening: Permission denied.")
//            sessionState = .authorizationDenied // Update state
//            return
//        }
//
//        guard SpeechRecognizer.isRecognizerAvailable else { // Use the static check
//            print("Speech recognition not available on this device.")
//            sessionState = .error(message: "Recognition unavailable")
//            HapticFeedback.error()
//            appendSystemMessage("Sorry, speech recognition isn't available right now.")
//            return
//        }
//
//        // Ensure synthesizer isn't speaking
//        if speechSynthesizer.isSpeaking {
//            speechSynthesizer.stopSpeaking(at: .immediate)
//        }
//        aiTask?.cancel() // Cancel any pending AI task
//        aiTask = nil
//
//        sessionState = .listening
//
//        // Start recognition via the observable object
//        speechRecognizer.startRecognition(
//            onFinalResult: { [weak self] recognizedText in
//                guard let self = self, !recognizedText.isEmpty else { return }
//                 // Prevent processing if we were manually paused/interrupted during recognition
//                guard self.sessionState == .listening else {
//                    print("Recognition finished but session state changed. Ignoring result.")
//                    self.speechRecognizer.clearLastRecognizedText() // Clear dangling text
//                    return
//                }
//                self.appendUserMessage(recognizedText)
//                self.userTextInput = "" // Clear manual input
//                self.pauseListening() // Pause after getting result
//                self.triggerAIResponse(for: recognizedText) // Trigger AI
//            },
//            onError: { [weak self] error in
//                guard let self = self else { return }
//                print("Speech recognition error: \(error.localizedDescription)")
//                HapticFeedback.error()
//                self.sessionState = .error(message: "Listening Error")
//                self.appendSystemMessage("There was an issue with listening. Please try again.")
//                self.pauseListening() // Go back to paused on error
//            }
//        )
//    }
//
//    // Explicit pause function
//    private func pauseListening() {
//        if sessionState == .listening { // Only stop if actually listening
//            print("Pausing listening.")
//            speechRecognizer.stopRecognition() // Stop the engine
//            sessionState = .paused
//        }
//    }
//
//    // Stop recognition completely (e.g., on disappear)
//    private func stopListeningCompletely() {
//        print("Stopping listening completely.")
//        speechRecognizer.stopRecognition()
//        sessionState = .paused
//    }
//
//    // MARK: - AI Interaction (Simulation)
//
//    private func interruptAI() {
//        print("Interrupting AI...")
//        HapticFeedback.impact()
//        aiTask?.cancel()
//        aiTask = nil
//        if speechSynthesizer.isSpeaking {
//            speechSynthesizer.stopSpeaking(at: .word) // Stop more naturally
//        }
//        // Decide next state: either go directly to listening or paused
//        // Let's go to paused for explicit user action to resume.
//        sessionState = .paused
//        appendSystemMessage("Interrupted. Ready for input.")
//    }
//
//    private func triggerAIResponse(for query: String) {
//        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedQuery.isEmpty else { return }
//
//        sessionState = .thinking // Enter thinking state first
//        aiTask = Task {
//            do {
//                // 1. Simulate "Thinking" delay
//                try await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_200_000_000)) // Shorter thinking delay
//                guard !Task.isCancelled else {
//                    print("AI Task cancelled during thinking.")
//                    await MainActor.run { if sessionState == .thinking { sessionState = .paused } } // Reset state if still thinking
//                    return
//                }
//
//                 // 2. Update state to Processing (optional, or keep thinking?)
//                 // Let's skip explicit processing state visually and go straight to speaking prep
//                 // await MainActor.run { sessionState = .processing }
//                 // try await Task.sleep(nanoseconds: 100_000_000) // Tiny delay if needed
//
//                 // 3. Generate Response
//                let response = generateAssistantResponse(for: trimmedQuery)
//                guard !Task.isCancelled else {
//                    print("AI Task cancelled before speaking.")
//                    await MainActor.run { sessionState = .paused }
//                    return
//                }
//
//                // 4. Prepare for Speaking
//                await MainActor.run {
//                    appendAssistantMessage(response)
//                    speakText(response) // This will set state to .speaking internally
//                }
//            } catch is CancellationError {
//                 print("AI Task explicitly cancelled.")
//                 await MainActor.run { if sessionState == .thinking || sessionState == .processing { sessionState = .paused } } // Reset if cancelled during processing
//            } catch {
//                print("Error during AI simulation: \(error)")
//                HapticFeedback.error()
//                await MainActor.run {
//                    sessionState = .error(message: "Response failed")
//                    appendSystemMessage("Sorry, I couldn't generate a response.")
//                }
//            }
//            // Task finishes naturally after speaking completes via delegate
//        }
//    }
//
//    // Expanded mock responses
//    private func generateAssistantResponse(for query: String) -> String {
//        let lowercasedQuery = query.lowercased()
//
//        // More specific triggers
//        if lowercasedQuery.contains("hello") || lowercasedQuery.contains("hi") {
//            return "Hello there! How can I assist you today?"
//        } else if lowercasedQuery.contains("how are you") {
//            return "I'm functioning optimally, ready to help!"
//        } else if lowercasedQuery.contains("your name") {
//            return "You can call me Gemini Live. I'm a conversational assistant."
//        } else if lowercasedQuery.contains("weather") {
//            let cities = ["San Francisco", "London", "Tokyo", "Sydney"]
//            let conditions = ["sunny", "cloudy", "rainy", "windy"]
//            let temps = ["18°C", "12°C", "22°C", "28°C"]
//            return "The weather in \(cities.randomElement()!) is currently \(conditions.randomElement()!) with a temperature around \(temps.randomElement()!)."
//        } else if lowercasedQuery.contains("swiftui") {
//             return "SwiftUI is Apple's modern declarative framework for building UIs across all Apple platforms. It emphasizes state-driven views and composition."
//        } else if lowercasedQuery.contains("swift") && !lowercasedQuery.contains("swiftui") {
//            return "Swift is a powerful and intuitive programming language created by Apple for building apps for iOS, Mac, Apple TV, and Apple Watch. It's known for safety, speed, and modern features."
//        } else if lowercasedQuery.contains("set timer") || lowercasedQuery.contains("start timer") {
//             let times = ["5 minutes", "10 minutes", "1 minute"]
//            return "Okay, I've set a timer for \(times.randomElement()!). I'll notify you."
//        } else if lowercasedQuery.contains("a*") || lowercasedQuery.contains("astar") || lowercasedQuery.contains("pathfinding") {
//            return "A* (pronounced A-star) is a popular pathfinding algorithm used in games and navigation. It efficiently finds the shortest path by using a heuristic function to estimate the cost to the goal."
//        } else if lowercasedQuery.contains("fun fact") || lowercasedQuery.contains("tell me something interesting") {
//             let facts = [
//                 "Did you know? Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still perfectly edible.",
//                 "AInteresting fact: A group of flamingos is called a 'flamboyance'.",
//                 "Here's one: Octopuses have three hearts – two pump blood through the gills, and one circulates blood to the rest of the body. They also have blue blood!",
//                 "Random fact: Bananas are berries, but strawberries aren't!"
//             ]
//            return facts.randomElement()!
//        } else if lowercasedQuery.contains("ios development trends") {
//             return "Current iOS trends include the increasing adoption of SwiftUI and Combine, advancements in ARKit and Core ML, focus on privacy features, widgets, App Clips, and enhanced concurrency with async/await."
//        } else if lowercasedQuery.contains("joke") {
//             let jokes = [
//                "Why don't scientists trust atoms? Because they make up everything!",
//                "What do you call fake spaghetti? An impasta!",
//                "Why did the scarecrow win an award? Because he was outstanding in his field!"
//             ]
//             return jokes.randomElement()!
//        }
//
//        // Default fallback
//        let fallbacks = [
//            "That's an interesting question. Could you tell me more?",
//            "I'm still learning. Can you rephrase that?",
//            "I understand you said: '\(query)'. I'm ready for your next command.",
//            "Got it. What else can I help you with?",
//            "Acknowledged."
//        ]
//        return fallbacks.randomElement()!
//    }
//
//    // MARK: - Chat Message Helpers
//
//    private func appendUserMessage(_ text: String) {
//        let message = GeminiMessage(sender: .user, content: text)
//        appendMessage(message)
//    }
//
//    private func appendAssistantMessage(_ text: String) {
//        let message = GeminiMessage(sender: .assistant, content: text)
//        appendMessage(message)
//    }
//
//    // Added for system messages (errors, status updates)
//    private func appendSystemMessage(_ text: String) {
//         let message = GeminiMessage(sender: .system, content: text) // Assume .system sender added
//         appendMessage(message)
//     }
//
//    private func appendMessage(_ message: GeminiMessage) {
//        // Run on main thread for UI updates
//         Task { @MainActor in
//            chatMessages.append(message)
//            // Optional: Limit chat history length
//            let maxMessages = 100
//            if chatMessages.count > maxMessages {
//                chatMessages.removeFirst(chatMessages.count - maxMessages)
//            }
//         }
//    }
//
//    // MARK: - Text-To-Speech
//
//    private func speakText(_ text: String) {
//         guard !text.isEmpty else { return }
//
//         // Ensure audio session is appropriate for playback
//         do {
//             try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: .duckOthers)
//             try AVAudioSession.sharedInstance().setActive(true)
//         } catch {
//             print("Failed to set audio session for TTS: \(error)")
//             // Decide how to handle: maybe show an error, or just proceed without ducking
//             appendSystemMessage("Couldn't configure audio for speaking.")
//             sessionState = .paused // Fallback state
//             return
//         }
//
//        // Check if currently speaking - queueing is complex, let's just replace/stop
//        if speechSynthesizer.isSpeaking {
//            print("TTS already speaking, stopping previous utterance.")
//            speechSynthesizer.stopSpeaking(at: .word) // Stop smoothly
//        }
//
//        let utterance = AVSpeechUtterance(string: text)
//        // Try finding a better default voice
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice(language: "en-GB") ?? AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language.starts(with: "en")})
//
//        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95 // Slightly faster default
//        utterance.pitchMultiplier = 1.0
//        utterance.volume = 1.0
//
//        // Set state *before* speaking starts
//        sessionState = .speaking
//        speechSynthesizer.speak(utterance)
//    }
//
//    // MARK: - Manual Text Input Handling
//
//    private func sendUserMessage() {
//        let trimmed = userTextInput.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty, canUseTextInput else { // Also check if input is allowed
//            if !canUseTextInput {
//                HapticFeedback.error() // Give feedback if disabled
//                print("Cannot send message: Input not allowed in current state or permissions.")
//            }
//            return
//        }
//
//        appendUserMessage(trimmed)
//
//        // Clear input AFTER appending message
//        Task { @MainActor in
//             self.userTextInput = ""
//         }
//
//        pauseListening() // Ensure listening is paused before triggering AI
//        triggerAIResponse(for: trimmed)
//    }
//
//    // MARK: - AVSpeechSynthesizer Delegate Wrapper
//
//    private lazy var speechSynthesizerDelegate = SpeechSynthesizerDelegateWrapper { event in
//        // Ensure updates run on the main thread
//        DispatchQueue.main.async {
//             //guard let self = self else { return }
//
//             switch event {
//             case .didFinish:
//                 print("TTS finished successfully.")
//                 self.aiTask = nil // Clear task reference
//                 // Decide next state: go back to paused or auto-listen? Paused is safer.
//                 self.sessionState = .paused
//                 // Optionally, reactivate listening automatically:
//                 // if self.speechPermissionGranted == true { self.startListening() }
//             case .didCancel:
//                 print("TTS cancelled.")
//                 // Task might already be nil if cancelled manually via interruptAI
//                 if self.aiTask != nil { self.aiTask = nil }
//                 // If cancelled, we usually end up in paused state via interruptAI or error handling
//                 if self.sessionState == .speaking { self.sessionState = .paused }
//             case .didStart:
//                print("TTS started.")
//                 // Already set to .speaking before calling speak()
//             }
//        }
//    }
//
//}
//
//// MARK: - Delegate wrapper for AVSpeechSynthesizerDelegate (Enhanced)
//enum SpeechSynthesizerEvent {
//    case didStart
//    case didFinish
//    case didCancel
//}
//
//class SpeechSynthesizerDelegateWrapper: NSObject, AVSpeechSynthesizerDelegate {
//     let eventHandler: (SpeechSynthesizerEvent) -> Void
//
//     init(eventHandler: @escaping (SpeechSynthesizerEvent) -> Void) {
//         self.eventHandler = eventHandler
//     }
//
//     func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//         eventHandler(.didStart)
//     }
//
//     func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//         eventHandler(.didFinish)
//     }
//
//     func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
//         eventHandler(.didCancel)
//     }
// }
//
//// MARK: - Speech Recognizer ObservableObject (Enhanced)
//
//final class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
//
//    @Published var transcribedText: String = ""
//    @Published var isRecognizing: Bool = false
//    @Published var lastRecognizedText: String = "" // Store the final recognized text briefly
//
//    // Use device's current locale if supported, fallback to en-US
//    private static var supportedLocale: Locale {
//        let currentLocale = Locale.current
//        guard let recognizer = SFSpeechRecognizer(locale: currentLocale), recognizer.isAvailable else {
//            return Locale(identifier: "en-US") // Fallback
//        }
//        return currentLocale
//    }
//    private let speechRecognizer = SFSpeechRecognizer(locale: SpeechRecognizer.supportedLocale)!
//
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine()
//
//    // Improved availability check
//    static var isRecognizerAvailable: Bool {
//        return SFSpeechRecognizer.authorizationStatus() == .authorized && SFSpeechRecognizer(locale: supportedLocale)?.isAvailable ?? false
//    }
//
//    override init() {
//        super.init()
//        speechRecognizer.delegate = self
//        print("Speech Recognizer initialized with locale: \(speechRecognizer.locale.identifier)")
//    }
//
//    func reset() {
//        stopRecognition() // Ensure everything stops
//        DispatchQueue.main.async {
//            self.transcribedText = ""
//            self.lastRecognizedText = ""
//            self.isRecognizing = false
//        }
//    }
//
//    func clearLastRecognizedText() {
//        DispatchQueue.main.async {
//             self.lastRecognizedText = ""
//         }
//    }
//
//    func startRecognition(onFinalResult: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
//        if audioEngine.isRunning {
//            print("Audio engine already running. Stopping first.")
//            stopRecognition() // Stop cleanly before starting again
//        }
//
//        // Reset state variables
//        DispatchQueue.main.async {
//            self.transcribedText = ""
//            self.isRecognizing = true
//             self.lastRecognizedText = "" // Clear previous final text
//        }
//
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            // Use a category suitable for voice interaction
//            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.duckOthers, .defaultToSpeaker])
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//            print("Audio session configured for recording.")
//        } catch {
//            print("Audio session setup error: \(error)")
//            DispatchQueue.main.async { self.isRecognizing = false }
//            onError(error)
//            return
//        }
//
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            print("Failed to create SFSpeechAudioBufferRecognitionRequest")
//            DispatchQueue.main.async { self.isRecognizing = false }
//            onError(NSError(domain: "SpeechRecognizer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create audio request"]))
//            return
//        }
//
//        // Configure request
//        recognitionRequest.shouldReportPartialResults = true
//        // Prefer on-device if available and locale supports it, but allow network fallback
//        if speechRecognizer.supportsOnDeviceRecognition {
//             print("On-device recognition supported.")
//             recognitionRequest.requiresOnDeviceRecognition = true // Try on-device first
//         } else {
//            print("On-device recognition NOT supported for locale \(speechRecognizer.locale.identifier). Using network.")
//             recognitionRequest.requiresOnDeviceRecognition = false
//         }
//
//        let inputNode = audioEngine.inputNode
//        print("Audio engine input node format: \(inputNode.outputFormat(forBus: 0))")
//
//        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//            guard let self = self else { return }
//            var isFinal = false
//
//            DispatchQueue.main.async { // Ensure UI updates happen on main thread
//                if let result = result {
//                    self.transcribedText = result.bestTranscription.formattedString
//                    isFinal = result.isFinal
//                    // print("Partial result: \(self.transcribedText)") // Debugging: Can be spammy
//                }
//
//                if error != nil || isFinal {
//                    print("Recognition task finished. Error: \(error?.localizedDescription ?? "None"), IsFinal: \(isFinal)")
//                    self.stopRecognitionInternal() // Stop engine and cleanup task
//
//                    if isFinal, let finalResult = result?.bestTranscription.formattedString, !finalResult.isEmpty {
//                         print("Final recognized text: \(finalResult)")
//                         self.lastRecognizedText = finalResult // Store final text
//                         onFinalResult(finalResult)
//                    } else if let error = error {
//                        // Don't call onError for cancellation errors if stopRecognition was called
//                        let nsError = error as NSError
//                        if !(nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1107) && // Not a background noise rejection
//                           !(nsError.domain == NSCocoaErrorDomain && nsError.code == NSUserCancelledError) { // Not manual cancellation
//                            print("Recognition error reported: \(error)")
//                            onError(error)
//                        } else {
//                            print("Recognized cancellation or benign error, not reporting as failure.")
//                             // Ensure state is reset correctly even on cancellation
//                             if !self.lastRecognizedText.isEmpty {
//                                 onFinalResult(self.lastRecognizedText) // Send last good text if cancelled but had result
//                             }
//                        }
//                         self.lastRecognizedText = "" // Clear on error
//                    }
//                    self.isRecognizing = false // Update state after processing result/error
//                }
//            }
//        }
//
//        // Setup audio tap
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//         // Check if format is valid
//         guard recordingFormat.channelCount > 0 else {
//             print("Audio node has invalid format (0 channels).")
//             DispatchQueue.main.async { self.isRecognizing = false }
//             onError(NSError(domain: "SpeechRecognizer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid audio recording format"]))
//             stopRecognitionInternal() // Clean up task
//             return
//         }
//
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            recognitionRequest.append(buffer)
//        }
//
//        audioEngine.prepare()
//        do {
//            try audioEngine.start()
//            print("Audio engine started successfully.")
//        } catch {
//            print("Audio engine start error: \(error)")
//            DispatchQueue.main.async { self.isRecognizing = false }
//            stopRecognitionInternal() // Clean up task
//            onError(error)
//        }
//    }
//
//    // Public function to stop
//    func stopRecognition() {
//        print("Public stopRecognition called.")
//         // Store the last good partial result before stopping everything
//         let lastPartial = self.transcribedText
//         DispatchQueue.main.async {
//             self.lastRecognizedText = lastPartial
//         }
//        stopRecognitionInternal()
//        DispatchQueue.main.async {
//            self.isRecognizing = false // Ensure state is updated
//        }
//    }
//
//    // Internal cleanup function
//    private func stopRecognitionInternal() {
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            audioEngine.inputNode.removeTap(onBus: 0)
//            print("Audio engine stopped and tap removed.")
//        } else {
//             print("Audio engine was not running.")
//         }
//        // Only end audio if the request exists - prevents crashes if called multiple times
//         if recognitionRequest != nil {
//            recognitionRequest?.endAudio()
//             recognitionRequest = nil
//             print("Recognition request audio ended.")
//         } else {
//            print("Recognition request was already nil.")
//         }
//
//        // Cancel the task if it's running. Prevents completion handlers firing after stop.
//         if recognitionTask != nil {
//            recognitionTask?.cancel()
//             recognitionTask = nil
//             print("Recognition task cancelled.")
//         } else {
//             print("Recognition task was already nil.")
//         }
//
//         // Deactivate audio session (optional, depends on app needs)
//         // DispatchQueue.global(qos: .background).async { // Avoid blocking main thread
//         //     do {
//         //         try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//         //         print("Audio session deactivated.")
//         //     } catch {
//         //         print("Failed to deactivate audio session: \(error)")
//         //     }
//         // }
//    }
//
//    // Delegate method
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        // This informs about the recognizer service availability, not permissions
//        print("Speech recognizer SERVICE availability changed: \(available)")
//         // We might want to update UI or state if the service goes down globally
//        Task { @MainActor in
//             if !available {
//                 // Handle service unavailability - maybe show a persistent error?
//             }
//         }
//    }
//}
//
//// MARK: - GeminiMessage model & Session State (Enhanced)
//
//struct GeminiMessage: Identifiable, Equatable {
//    enum Sender: Equatable { // Make Sender equatable for state diffing
//        case user, assistant, system // Added system sender
//    }
//
//    let id = UUID()
//    let sender: Sender
//    let content: String
//    let timestamp = Date()
//}
//
//enum GeminiSessionState: Equatable {
//    case initializing
//    case listening
//    case thinking         // Added intermediate state
//    case processing       // Kept for potential future use (e.g., longer tasks)
//    case speaking
//    case paused
//    case authorizationDenied // Specific state for permissions issue
//    case error(message: String)
//
//    var isIdle: Bool {
//        switch self {
//        case .paused, .authorizationDenied, .error, .initializing: return true
//        default: return false
//        }
//    }
//
//    // Can the user interrupt this state?
//    var isInterruptable: Bool {
//        switch self {
//        case .thinking, .processing, .speaking: return true
//        default: return false
//        }
//    }
//
//    // Is the system busy processing/speaking? (Used for disabling UI)
//    var isBusy: Bool {
//         switch self {
//         case .thinking, .processing, .speaking: return true
//         default: return false
//         }
//     }
//}
//
//// MARK: - UI Components (Enhanced)
//
//struct LiveStatusBar: View {
//    var sessionState: GeminiSessionState
//    var permissionGranted: Bool? // Pass permission status
//
//    var body: some View {
//        HStack(spacing: 10) { // Increased spacing
//            Group {
//                switch sessionState {
//                case .initializing:
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
//                case .listening:
//                    PulsatingMicIcon(animationColor: .green)
//                case .thinking:
//                     Image(systemName: "ellipsis.bubble.fill") // Thinking icon
//                        .font(.system(size: 24))
//                        .foregroundColor(.cyan)
//                        .transition(.opacity.combined(with: .scale))
//                case .processing: // Keep distinct, maybe for longer waits
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                case .speaking:
//                    Image(systemName: "speaker.wave.2.fill")
//                        .font(.system(size: 24))
//                        .foregroundColor(.blue)
//                        .transition(.opacity.combined(with: .scale))
//                case .paused:
//                    // Show slash only if permission IS granted but paused
//                    Image(systemName: permissionGranted == true ? "mic.slash.fill" : "mic.fill")
//                        .foregroundColor(permissionGranted == true ? .yellow : .gray)
//                case .authorizationDenied:
//                    Image(systemName: "mic.badge.xmark") // Specific icon for denied
//                         .foregroundColor(.red)
//                         .font(.system(size: 24))
//                case .error:
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .foregroundColor(.red)
//                }
//            }
//            .frame(width: 30, height: 30)
//
//            Text(statusText)
//                .font(.headline)
//                .foregroundColor(.white.opacity(0.9))
//                .lineLimit(1)
//                .minimumScaleFactor(0.8) // Allow text to shrink slightly
//
//            Spacer() // Push status to the left
//        }
//        .padding(.horizontal)
//        .animation(.easeInOut, value: sessionState) // Animate changes
//        .animation(.easeInOut, value: permissionGranted) // Also animate based on permission
//    }
//
//    private var statusText: String {
//        switch sessionState {
//        case .initializing: return "Initializing..."
//        case .listening: return "Listening..."
//        case .thinking: return "Thinking..."
//        case .processing: return "Processing..." // Could be used for longer tasks later
//        case .speaking: return "Replying..."
//        case .paused: return permissionGranted == true ? "Paused" : "Mic Access?"
//        case .authorizationDenied: return "Mic Permission Denied"
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
//            // Outer pulse
//            Circle()
//                .stroke(animationColor.opacity(0.5), lineWidth: 2)
//                .scaleEffect(pulse ? 1.8 : 1.0)
//                .opacity(pulse ? 0 : 1)
//                .animation(
//                    .easeOut(duration: 1.2).repeatForever(autoreverses: false),
//                    value: pulse
//                 )
//
//            // Inner pulse (subtler)
//            Circle()
//                .fill(animationColor.opacity(0.2))
//                .scaleEffect(pulse ? 1.3 : 1)
//                 .animation(
//                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
//                    value: pulse
//                 )
//
//            Image(systemName: "mic.fill")
//                .foregroundColor(animationColor)
//                .font(.system(size: 20)) // Adjust size as needed
//        }
//        .onAppear {
//            // Delay start slightly to avoid animation jump on appear
//             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                 pulse = true
//             }
//        }
//         .onDisappear {
//             pulse = false // Stop animation on disappear
//         }
//    }
//}
//
//struct ChatMessageRow: View {
//    let message: GeminiMessage
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) { // Reduced spacing
//            // Align based on sender
//            if message.sender == .assistant || message.sender == .system { Spacer() }
//
//            VStack(alignment: message.sender == .user ? .leading : .trailing) {
//                Text(message.content)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8) // Slightly less vertical padding
//                    .foregroundColor(foregroundColor)
//                    .background(backgroundColor)
//                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) // Use continuous corner radius
//                    .font(.body)
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.sender == .user ? .leading : .trailing) // Slightly wider max
//                    .fixedSize(horizontal: false, vertical: true) // Ensure text wraps
//
//                // Optionally add timestamp (subtle)
//                 Text(message.timestamp, style: .time)
//                     .font(.caption2)
//                     .foregroundColor(.gray)
//                     .padding(.top, 2)
//            }
//
//            if message.sender == .user { Spacer() }
//        }
//        .padding(.horizontal, 10)
//        .padding(.vertical, 4) // Vertical space between rows
//        .frame(maxWidth: .infinity, alignment: message.sender == .user ? .leading : .trailing)
//        .transition(.move(edge: message.sender == .user ? .leading : .trailing).combined(with: .opacity)) // Add transition
//        .id(message.id) // Ensure view has ID for transitions/scrolling
//        .accessibilityElement(children: .combine)
//        .accessibilityLabel(messageAccessibilityLabel)
//    }
//
//    // Determine styling based on sender
//    private var backgroundColor: Color {
//        switch message.sender {
//        case .user: return Color.blue.opacity(0.8)
//        case .assistant: return Color.gray.opacity(0.25)
//        case .system: return Color.yellow.opacity(0.2) // Distinct style for system messages
//        }
//    }
//
//    private var foregroundColor: Color {
//        switch message.sender {
//        case .user: return .white
//        case .assistant: return .white.opacity(0.9)
//        case .system: return .yellow.opacity(0.9)
//        }
//    }
//
//    private var messageAccessibilityLabel: String {
//        let time = message.timestamp.formatted(date: .omitted, time: .shortened)
//        switch message.sender {
//        case .user: return "You said at \(time), \(massageContentForAccessibility(message.content))"
//        case .assistant: return "Reply at \(time), \(massageContentForAccessibility(message.content))"
//        case .system: return "System message at \(time), \(massageContentForAccessibility(message.content))"
//        }
//    }
//
//     // Helper to clean up content for VoiceOver (e.g., replace symbols)
//     private func massageContentForAccessibility(_ content: String) -> String {
//         // Example: Replace "*" with "star" if needed for clarity
//         return content.replacingOccurrences(of: "*", with: " star ")
//     }
//}
//
//// MARK: - Preview
//
//struct GeminiLiveView_Previews: PreviewProvider {
//    @State static var isPresented = true
//
//    static var previews: some View {
//        // Simulate different states for preview
//        let pausedStateView = GeminiLiveView(isPresented: .constant(true))
//            // .onAppear { pausedStateView.mockState(.paused) } // Helper needed
//
//        let listeningStateView = GeminiLiveView(isPresented: .constant(true))
//            // .onAppear { listeningStateView.mockState(.listening) }
//
//        let speakingStateView = GeminiLiveView(isPresented: .constant(true))
//             //.onAppear { speakingStateView.mockState(.speaking) }
//        
//        let deniedStateView = GeminiLiveView(isPresented: .constant(true))
//            // .onAppear { deniedStateView.mockState(.authorizationDenied) }
//
//        Group {
//            GeminiLiveView(isPresented: $isPresented)
//                 .previewDisplayName("Default (Paused)")
//
////            listeningStateView
////                .previewDisplayName("Listening")
////
////             speakingStateView
////                 .previewDisplayName("Speaking")
////
////            deniedStateView
////                .previewDisplayName("Permission Denied")
//        }
//        .preferredColorScheme(.dark)
//    }
//
//    // Add helper for preview state setting if needed
//    // func mockState(_ state: GeminiSessionState) { ... }
//}
//
//// MARK: - App Entry Point
//@main
//struct GeminiLiveApp: App {
////! @State private var showGeminiLive = false // Should be true to show initially
//    @State private var showGeminiLive = true
//
//    var body: some Scene {
//        WindowGroup {
//            // Use a simple button to launch the modal view for testing presentation
//            NavigationView {
//                 VStack {
//                     Text("Gemini Live Demo")
//                         .font(.largeTitle)
//                     Button("Start Live Session") {
//                            showGeminiLive = true
//                     }
//                     .padding()
//                     .buttonStyle(.borderedProminent)
//                }
//                .sheet(isPresented: $showGeminiLive) {
//                    // Content of the sheet IS the GeminiLiveView
//                    GeminiLiveView(isPresented: $showGeminiLive)
//                 }
//                 .preferredColorScheme(.dark) // Apply dark scheme to the container too
//            }
//
////            // Original direct presentation (less flexible for testing dismissal)
////            if showGeminiLive {
////                GeminiLiveView(isPresented: $showGeminiLive)
////                    .preferredColorScheme(.dark)
////            } else {
////                // Fallback UI when not presented
////                VStack {
////                     Text("Tap below to start")
////                     Button("Start Gemini Live") {
////                         showGeminiLive = true
////                     }
////                 }
////                 .preferredColorScheme(.dark)
////            }
//        }
//    }
//}
