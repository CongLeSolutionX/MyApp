
import SwiftUI
import Speech
import AVFoundation

// MARK: - Core Data Models & Enums

/// Represents the sender of a message.
enum Sender {
    case user
    case assistant
}

/// Represents a single message in the chat.
struct GeminiMessage: Identifiable, Equatable {
    let id = UUID()
    let sender: Sender
    var content: String
}

/// Represents the current state of the voice interaction session.
enum GeminiSessionState: String, CaseIterable {
    case paused = "Paused"
    case listening = "Listening"
    case processing = "Processing" // AI thinking or Speaking
}

// MARK: - Helper Classes

/// Handles speech recognition using SFSpeechRecognizer.
class SpeechRecognizer: ObservableObject {
    @Published var transcribedText: String = ""
    @Published var error: String? = nil
    @Published var isAvailable: Bool = false // Check if recognition is possible

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init() {
        // Configure the recognizer (assuming US English for this example)
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        isAvailable = speechRecognizer?.isAvailable ?? false
        speechRecognizer?.delegate = self // Optional: Conform if you need delegate methods
    }

    /// Request authorization for speech recognition.
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.isAvailable = true
                    self.error = nil
                case .denied, .restricted, .notDetermined:
                    self.isAvailable = false
                    self.error = "Speech recognition authorization denied or restricted."
                @unknown default:
                    self.isAvailable = false
                    self.error = "Unknown speech recognition authorization status."
                }
            }
        }
    }

    /// Start transcribing audio input.
    func startTranscribing() {
        guard isAvailable else {
            error = "Speech recognition not available."
            requestAuthorization() // Prompt again if possible
            return
        }

        guard !audioEngine.isRunning else {
            print("Audio engine already running.")
            return
        }

        // Clear previous results
        transcribedText = ""
        error = nil

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true // Get live results

        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            guard let result = result else {
                // Handle errors or end of recognition
                if let error = error {
                    print("Recognition error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                       // Only show specific errors, e.g., network issues, not simple cancellations
                       if (error as NSError).code != 203 { // Ignore "Retry" error on pause
                           self.error = "Recognition Error: \(error.localizedDescription)"
                       }
                       self.stopTranscribing() // Stop if there's a significant error
                    }
                }
                return
            }

            // Update transcribed text
            if result.isFinal {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                    // Optionally stop audio engine here if final result means user stopped talking
                    // self.stopTranscribing() // Example: Remove if continuous listening is desired
                }
            } else {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
        }

        // Configure audio session
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        // Prepare and start the audio engine
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            audioEngine.prepare()
            try audioEngine.start()
            print("Audio engine started successfully.")
        } catch {
            self.error = "Audio engine setup failed: \(error.localizedDescription)"
            stopTranscribing()
        }
    }

    /// Stop transcribing audio input.
    func stopTranscribing() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            // Important: Deactivate audio session *after* stopping engine and request
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
            print("Audio engine stopped.")
        }

        recognitionRequest?.endAudio() // Mark end of audio stream
        recognitionRequest = nil

        recognitionTask?.cancel() // Cancel the task
        recognitionTask = nil
    }

    /// Reset the state (e.g., text, error).
    func reset() {
        stopTranscribing() // Ensure everything is stopped
        transcribedText = ""
        error = nil
    }
}

// Extension for SpeechRecognizer Delegate (Optional)
extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    func isEqual(_ object: Any?) -> Bool {
        return true
    }
    
    var hash: Int {
        return 0
    }
    
    var superclass: AnyClass? {
        return nil
    }
    
    func `self`() -> Self {
        return self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func isProxy() -> Bool {
        return true
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        return true
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        return true
    }
    
    var description: String {
        return ""
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            self.isAvailable = available
            if !available {
                self.error = "Speech recognition became unavailable."
            }
        }
    }
}

/// Wraps AVSpeechSynthesizerDelegate to use closures.
// Inside SpeechSynthesizerDelegateWrapper class
class SpeechSynthesizerDelegateWrapper: NSObject, AVSpeechSynthesizerDelegate {
    var onDidFinishSpeaking: (() -> Void)? // <-- Change 'let' to 'var' if it was let

    // Provide a simple initializer if you removed the one taking a closure
    override init() { } // Or ensure it has a default initializer

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onDidFinishSpeaking?()
    }
}

// MARK: - Supporting UI Components

/// Displays the current session status (Listening, Paused, Processing).
struct LiveStatusBar: View {
    let sessionState: GeminiSessionState

    var body: some View {
        HStack(spacing: 8) {
            if sessionState == .listening {
                PulsatingMicIcon()
            }
            Text(sessionState.rawValue)
                .font(.headline)
                .foregroundColor(.white)
                .transition(.opacity.animation(.easeIn))
                .id(sessionState) // Ensure text updates with state transition
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
    }
}

/// A simple pulsating microphone icon effect.
struct PulsatingMicIcon: View {
    @State private var isAnimating = false

    var body: some View {
        Image(systemName: "mic.fill")
            .font(.system(size: 18))
            .foregroundColor(.red)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .opacity(isAnimating ? 0.8 : 1.0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

/// Displays a single chat message bubble.
struct ChatMessageRow: View {
    let message: GeminiMessage

    var body: some View {
        HStack(spacing: 0) {
            if message.sender == .user {
                Spacer() // Push user messages to the right
            }

            VStack(alignment: message.sender == .user ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .foregroundColor(message.sender == .user ? .white : .black)
                    .background(message.sender == .user ? Color.blue : Color(UIColor.systemGray5))
                    .cornerRadius(16)
                    .frame(maxWidth: 300, alignment: message.sender == .user ? .trailing : .leading)

//                Text(message.sender == .user ? "You" : "Assistant")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 6)
            }

            if message.sender == .assistant {
                Spacer() // Push assistant messages to the left
            }
        }
    }
}

// MARK: - Main View: GeminiLiveView

struct GeminiLiveView: View {
    @Binding var isPresented: Bool // To allow dismissing this view

    // MARK: - State Properties
    @StateObject private var speechRecognizer = SpeechRecognizer()
    private let speechSynthesizer = AVSpeechSynthesizer()
    @State private var sessionState: GeminiSessionState = .paused
    @State private var chatMessages: [GeminiMessage] = [
        GeminiMessage(sender: .assistant, content: "Hello! How can I help you today? Hold the button or type to speak.")
    ]
    @State private var userTextInput: String = ""
    @State private var aiTask: Task<Void, Never>? = nil // Track ongoing AI generation/TTS task
    @Namespace private var bottomID // For scrolling chat view
    
    // Initialize the delegate object WITHOUT the logic closure here
       private var speechSynthesizerDelegate = SpeechSynthesizerDelegateWrapper()
    
    // --- ADD THIS INITIALIZER ---
       init(isPresented: Binding<Bool>) {
           self._isPresented = isPresented // Initialize the binding
           // Other properties like speechRecognizer, speechSynthesizer, etc.,
           // will use their default initializations defined above.
           // Make sure the delegate is assigned *after* self is available if needed,
           // but the lazy var handles this correctly here.
           // speechSynthesizer.delegate = speechSynthesizerDelegate // This line can stay in onAppear or be moved here if needed immediately.
       }


    // Synthesizer Delegate
//    var speechSynthesizerDelegate = SpeechSynthesizerDelegateWrapper {
//        DispatchQueue.main.async {
//            // When TTS finishes, return to paused state if not interrupted
////            if sessionState == .processing {
////                sessionState = .paused
////            }
//            print("TTS Finished, state back to paused.")
//        }
//    }

    // MARK: - Main Body (Refactored)
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color.black.opacity(0.95), Color.black.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 10) { // Reduced spacing
                // --- Status Bar ---
                LiveStatusBar(sessionState: sessionState)

                // --- Chat Area (Extracted) ---
                chatArea
                    .padding(.top, 5) // Add some space above chat

                // --- Manual Input Area (Extracted) ---
                manualInputArea

                Spacer(minLength: 0) // Push controls to bottom

                // --- Bottom Controls (Extracted) ---
                bottomControlsArea
                    .padding(.bottom, 30) // More padding at the very bottom
            }
            .padding(.top, 30) // Top padding for the whole VStack
            .onAppear {
                speechRecognizer.reset()
                sessionState = .paused
                speechRecognizer.requestAuthorization() // Request immediately
                speechSynthesizer.delegate = speechSynthesizerDelegate
                
                // NOW create and assign the closure that uses 'self.sessionState'
                            speechSynthesizerDelegate.onDidFinishSpeaking = {
                                DispatchQueue.main.async { // Use weak self capture
                                    //guard let self = self else { return } // Safely unwrap
                                    // Now you can safely access self.sessionState
                                    if self.sessionState == .processing {
                                        self.sessionState = .paused
                                    }
                                    print("TTS Finished, state back to paused.")
                                }
                            }
            }
            .onDisappear {
                interruptAI() // Stop everything on disappear
                endSession()
            }
            .disabled(aiTask != nil && sessionState == .processing) // Disable input areas during processing/TTS
            .alert("Speech Error", isPresented: .constant(speechRecognizer.error != nil), actions: {
                Button("OK") { speechRecognizer.error = nil } // Allow dismissing error
            }, message: {
                Text(speechRecognizer.error ?? "An unknown error occurred.")
            })
        }
        .interactiveDismissDisabled(true) // Prevent swipe down to dismiss
        .preferredColorScheme(.dark) // Force dark mode for this view
    }

    // MARK: - @ViewBuilder Subview Functions

    /// Displays the chat messages in a scrollable view.
    @ViewBuilder
    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(chatMessages) { message in
                        ChatMessageRow(message: message)
                    }

                    // Show live partial text during listening
                    if sessionState == .listening && !speechRecognizer.transcribedText.isEmpty {
                        ChatMessageRow(message: GeminiMessage(sender: .user, content: speechRecognizer.transcribedText + "…"))
                            .italic()
                            .foregroundColor(.gray)
                            .transition(.opacity.animation(.easeIn))
                    }
                    Color.clear.frame(height: 1).id(bottomID) // Scroll anchor
                }
                .padding(.horizontal)
                .padding(.top, 10) // Padding inside scroll view
            }
            .onChange(of: chatMessages.count) { scrollToBottom(proxy: proxy) }
            .onChange(of: speechRecognizer.transcribedText) {
                if sessionState == .listening { scrollToBottom(proxy: proxy) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow chat area to grow
    }

    /// Provides the text field for manual input and the send button.
    @ViewBuilder
    private var manualInputArea: some View {
        VStack(spacing: 4) {
            // Conditionally display the "Recognizing..." text with a placeholder
            if sessionState == .listening && !speechRecognizer.transcribedText.isEmpty {
                 Text("Recognizing: \"\(speechRecognizer.transcribedText)\"")
                     .foregroundColor(.gray)
                     .font(.footnote)
                     .padding(.horizontal)
                     .padding(.bottom, 4)
                     .transition(.opacity.animation(.easeIn))
                     .frame(height: 18) // Explicit height for placeholder matching
            } else {
                // Placeholder to prevent layout jump
                 Color.clear
                     .frame(height: 18)
                     .padding(.bottom, 4)
            }

            HStack(spacing: 12) {
                TextField("Type message...", text: $userTextInput)
                    .textFieldStyle(.roundedBorder)
                    .disabled(sessionState != .paused) // Only enable when paused
                    .submitLabel(.send)
                    .onSubmit(sendUserMessage) // Send on return key
                    .accessibilityLabel("User input text field")

                Button(action: sendUserMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(isSendButtonEnabled ? .blue : .gray)
                }
                .disabled(!isSendButtonEnabled)
                .accessibilityLabel("Send user message")
            }
            .padding(.bottom, 8) // Padding below text field
        }
        .padding(.horizontal) // Padding for the HStack and VStack
    }

    /// Displays the main control buttons: Hold/Resume and Interrupt/End.
    @ViewBuilder
    private var bottomControlsArea: some View {
        HStack(spacing: 60) {
            // Hold / Resume Button
            Button(action: toggleListeningState) {
                buttonContentView(
                    systemName: sessionState == .paused ? "mic.fill" : "pause.fill", // Mic when paused
                    label: sessionState == .paused ? "Hold to Speak" : "Pause",
                    foregroundColor: sessionState == .paused ? .white : .white, // Consistent white
                    backgroundColor: sessionState == .paused ? Color.blue            : Color.gray.opacity(0.6) // Blue when ready
                )
            }
            .accessibilityLabel(sessionState == .paused ? "Hold to speak" : "Pause listening")

            // Interrupt / End button
            Button(action: handleInterruptOrEnd) {
                buttonContentView(
                    systemName: isInterrupting ? "stop.fill" : "xmark.circle.fill", // Different icon for end
                    label: isInterrupting ? "Interrupt" : "End",
                    foregroundColor: .white,
                    backgroundColor: isInterrupting ? Color.orange : Color.red // Orange for interrupt
                )
            }
            .accessibilityLabel(isInterrupting ? "Interrupt current response" : "End session")
        }
        .frame(maxWidth: .infinity)
    }

    /// Reusable view for the content of the circular bottom buttons.
    @ViewBuilder
    private func buttonContentView(systemName: String, label: String, foregroundColor: Color, backgroundColor: Color) -> some View {
        VStack(spacing: 8) { // Reduced spacing
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 70, height: 70) // Slightly larger buttons
                    .shadow(radius: 5)
                Image(systemName: systemName)
                    .foregroundColor(foregroundColor)
                    .font(.system(size: 30)) // Larger icon
            }
            Text(label)
                .font(.caption)
                .foregroundColor(foregroundColor.opacity(0.8)) // Slightly dimmer label
        }
    }

    // MARK: - Helper Computed Properties

    private var isSendButtonEnabled: Bool {
        !userTextInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && sessionState == .paused
    }

    private var isInterrupting: Bool {
        sessionState == .processing // Simpler check: Interrupt if processing/speaking
    }

    // MARK: - Helper Action Functions

    private func toggleListeningState() {
        if sessionState == .paused {
            startListening()
        } else if sessionState == .listening {
            pauseListeningAndProcess() // Process recognized text on pause
        }
    }

    private func handleInterruptOrEnd() {
         if isInterrupting {
            interruptAI()
        } else {
            endSession() // Close the view
        }
    }

    // MARK: - Speech Recognition Control

    private func startListening() {
        guard speechRecognizer.isAvailable else {
             speechRecognizer.requestAuthorization()
             return
        }
         // Clear manual input when starting voice
        userTextInput = ""
        sessionState = .listening
        speechRecognizer.startTranscribing()
    }

    private func pauseListeningAndProcess() {
        guard sessionState == .listening else { return }
        speechRecognizer.stopTranscribing() // Stop mic input

        let capturedText = speechRecognizer.transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
        speechRecognizer.transcribedText = "" // Clear partial text view

        if !capturedText.isEmpty {
            appendUserMessage(text: capturedText)
            generateAssistantResponse(for: capturedText)
        } else {
            // If nothing was captured, just return to paused
            sessionState = .paused
        }
     }

     // Function just to pause listening without processing (e.g., if needed elsewhere)
     private func pauseListeningOnly() {
         guard sessionState == .listening else { return }
         speechRecognizer.stopTranscribing()
         sessionState = .paused
     }

    // MARK: - Interrupt AI / End Session

    private func interruptAI() {
        aiTask?.cancel() // Cancel the Task
        aiTask = nil
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate) // Stop TTS immediately
        }
        // Reset state only if interrupted during processing
        if sessionState == .processing {
            sessionState = .paused
            print("AI Task / TTS Interrupted.")
        }
        // If interrupted during listening, just pause
        if sessionState == .listening {
             pauseListeningOnly()
        }
    }

    private func endSession() {
        print("Ending session.")
        interruptAI() // Ensure everything is stopped
        speechRecognizer.reset()
        isPresented = false // Trigger dismissal
    }

    // MARK: - Chat Helpers

    private func appendUserMessage(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        chatMessages.append(GeminiMessage(sender: .user, content: trimmedText))
    }

    private func appendAssistantMessage(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        chatMessages.append(GeminiMessage(sender: .assistant, content: trimmedText))
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
         DispatchQueue.main.async { // Ensure UI updates happen on main thread
             withAnimation(.easeOut(duration: 0.3)) {
                  proxy.scrollTo(bottomID, anchor: .bottom)
              }
         }
    }

    // MARK: - AI response simulation & TTS

    /// Simulates fetching a response from an AI model. Replace with actual API calls.
    private func simulateAIResponse(for query: String) async -> String {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000)) // 0.5 to 1.5 seconds

        // Check for cancellation after delay, before generating response
        guard !Task.isCancelled else {
             print("AI Task cancelled during delay.")
             return "" // Return empty if cancelled
         }

        // Basic canned responses (Replace with actual Gemini API call)
        let lowerQuery = query.lowercased()
        if lowerQuery.contains("hello") || lowerQuery.contains("hi") {
            return "Hello there! How can I assist you further?"
        } else if lowerQuery.contains("weather") {
            return "I'm not connected to live weather data right now, but it often feels sunny in the world of code!"
        } else if lowerQuery.contains("time") {
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            return "The current time is \(formatter.string(from: Date()))."
        } else if lowerQuery.count < 5 {
             return "Could you please elaborate a bit more?"
        } else {
            // Generic response
            return "That's an interesting point about '\(query)'. I need more data to give a detailed answer."
        }
    }

    /// Gets response from AI and handles TTS.
    private func generateAssistantResponse(for query: String) {
        sessionState = .processing // Mark as thinking
        aiTask = Task {
            let responseText = await simulateAIResponse(for: query)

            // Check for cancellation *after* getting the response
            guard !Task.isCancelled else {
                print("AI Task cancelled before appending/speaking.")
                // Ensure state is reset even if task completes but was cancelled
                if self.sessionState == .processing { self.sessionState = .paused }
                return
            }

            guard !responseText.isEmpty else {
                // If response is empty (e.g., cancelled during simulation), go back to paused
                sessionState = .paused
                return
            }

            appendAssistantMessage(text: responseText)
            speakText(responseText)
            // State becomes .paused *after* TTS finishes (handled by delegate)
        }
    }

    /// Use AVSpeechSynthesizer to speak the provided text.
    private func speakText(_ text: String) {
        guard !text.isEmpty else {
             sessionState = .paused // Nothing to speak, return to paused
             return
         }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Or choose a specific voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate // Adjust rate if needed
        utterance.pitchMultiplier = 1.0 // Adjust pitch if needed

        // Ensure audio session is appropriate for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set audio session for playback: \(error)")
            sessionState = .paused // Go back to paused if we can't setup audio
            return
        }

        speechSynthesizer.speak(utterance)
        // State remains .processing while speaking
    }

    // MARK: - Manual text send

    private func sendUserMessage() {
        let textToSend = userTextInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }

        appendUserMessage(text: textToSend)
        userTextInput = "" // Clear input field
        generateAssistantResponse(for: textToSend)
    }
}
#Preview(){
    GeminiLiveView(isPresented: .constant(true))
}
//
//// MARK: - Preview
//struct GeminiLiveView_Previews: PreviewProvider {
//    // Dummy binding for preview
//    @State static var isPresented = true
//
//    static var previews: some View {
//        // You can embed this in a simple container for preview if needed,
//        // but direct preview should also work.
//        GeminiLiveView(isPresented: $isPresented)
//            // Dark mode is applied inside the view itself now
//            // .preferredColorScheme(.dark)
//    }
//}
