////
////  GeminiLiveView_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//
//// MARK: - ContentView that launches GeminiLiveView full-screen
//struct ContentView: View {
//    @State private var isShowingLiveSession = false
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 40) {
//                Spacer()
//
//                Button {
//                    isShowingLiveSession = true
//                } label: {
//                    Label("Start Gemini Live Session", systemImage: "mic.fill")
//                        .font(.title2.bold())
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .accessibilityIdentifier("startLiveSessionButton")
//
//                Spacer()
//
//                Text("Tap the button above to launch a simulated Gemini AI live voice assistant session with chat history and interactive controls.")
//                    .font(.body)
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Gemini AI Demo")
//        }
//        .fullScreenCover(isPresented: $isShowingLiveSession) {
//            // Wrap GeminiLiveView in NavigationView for full screen cover to also have navigation features if needed
//            NavigationView {
//                GeminiLiveView(isPresented: $isShowingLiveSession)
//                    .navigationBarHidden(true)
//                    .preferredColorScheme(.dark)
//            }
//        }
//    }
//}
//
//// MARK: - Conversation Message Model
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
//// MARK: - Session State Enum for managing Gemini lifecycle
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
//// MARK: - Main Gemini Live View
//struct GeminiLiveView: View {
//    // Controls the presentation
//    @Binding var isPresented: Bool
//
//    // MARK: - State variables
//    @State private var sessionState: GeminiSessionState = .listening
//
//    // Chat history array
//    @State private var chatMessages: [GeminiMessage] = []
//
//    // Text input for simulated manual queries
//    @State private var userTextInput: String = ""
//
//    /// For controlling simulated async tasks (like processing and speaking)
//    @State private var simulationTask: Task<Void, Never>? = nil
//
//    /// ScrollView proxy to auto scroll chat
//    @Namespace private var bottomID
//
//    /// Mock data samples
//    private let mockAssistantResponses = [
//        "The weather is sunny with a high of 25°C today.",
//        "Swift is Apple's modern programming language introduced in 2014.",
//        "A* is a popular pathfinding algorithm used in games and robotics.",
//        "Alright, your 5-minute timer has started.",
//        "I’m here to help! What else would you like to know?",
//        "Here’s a fun fact: Honey never spoils.",
//        "I can assist you with tasks, information, and more!"
//    ]
//
//    /// MARK: - Body
//
//    var body: some View {
//        ZStack {
//            // Background Gradient
//            LinearGradient(colors: [Color(.sRGB, red: 0.05, green: 0.05, blue: 0.07, opacity: 1), Color(.sRGB, red: 0.1, green: 0.1, blue: 0.15, opacity: 1)], startPoint: .topLeading, endPoint: .bottomTrailing)
//                .ignoresSafeArea()
//
//            VStack(spacing: 16) {
//
//                // MARK: Live Indicator and Status
//                LiveStatusBar(sessionState: sessionState)
//
//                // MARK: Scrollable Chat History
//                ScrollViewReader { proxy in
//                    ScrollView {
//                        LazyVStack(alignment: .leading, spacing: 12) {
//                            ForEach(chatMessages) { message in
//                                ChatMessageRow(message: message)
//                                    .id(message.id)
//                                    .transition(.move(edge: message.sender == .user ? .trailing : .leading).combined(with: .opacity))
//                            }
//
//                            // Invisible view to scroll to bottom
//                            Color.clear
//                                .frame(height: 1)
//                                .id(bottomID)
//                        }
//                        .padding(.horizontal)
//                    }
//                    .background(Color.clear)
//                    .onChange(of: chatMessages) {
//                        withAnimation(.easeOut(duration: 0.5)) {
//                            proxy.scrollTo(bottomID, anchor: .bottom)
//                        }
//                    }
//                }
//                .frame(maxHeight: 400)
//
//                // MARK: Textfield for manual input + send
//                inputArea
//
//                Spacer(minLength: 0)
//
//                // MARK: Bottom Controls (Hold/Resume / End / Interrupt)
//                bottomControls
//                    .padding(.bottom, 30)
//            }
//            .padding(.top, 30)
//            .padding(.horizontal)
//            .onAppear {
//                startListening()
//            }
//            .onDisappear {
//                cancelSimulation()
//            }
//            // Disable interaction when busy to prevent double clicks
//            .disabled(sessionState.isBusy)
//        }
//        .interactiveDismissDisabled(true)
//    }
//
//    /// MARK: - Input area including TextField and Send Button
//    @ViewBuilder
//    private var inputArea: some View {
//        HStack(spacing: 12) {
//            // TextField
//            TextField("Type your message or tap below to speak...", text: $userTextInput)
//                .disabled(sessionState.isBusy || sessionState == .paused)
//                .textFieldStyle(.roundedBorder)
//                .accessibilityLabel("User input message")
//                .autocapitalization(.sentences)
//                .submitLabel(.send)
//                .onSubmit {
//                    sendUserMessage()
//                }
//
//            // Send Button
//            Button {
//                sendUserMessage()
//            } label: {
//                Image(systemName: "paperplane.fill")
//                    .font(.system(size: 22))
//                    .foregroundColor(userTextInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || sessionState.isBusy || sessionState == .paused ? .gray : .blue)
//            }
//            .disabled(userTextInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || sessionState.isBusy || sessionState == .paused)
//            .accessibilityLabel("Send message")
//        }
//    }
//
//    /// MARK: - Bottom controls (Hold/Resume, Interrupt [Tap on background], End)
//    @ViewBuilder
//    private var bottomControls: some View {
//        HStack(spacing: 60) {
//
//            // Hold / Resume Button
//            Button {
//                togglePauseResume()
//            } label: {
//                VStack(spacing: 10) {
//                    ZStack {
//                        Circle()
//                            .fill(sessionState == .paused ? Color.green.opacity(0.4) : Color.gray.opacity(0.6))
//                            .frame(width: 60, height: 60)
//
//                        Image(systemName: sessionState == .paused ? "play.fill" : "pause.fill")
//                            .foregroundColor(sessionState == .paused ? .green : .white)
//                            .font(.system(size: 26))
//                    }
//
//                    Text(sessionState == .paused ? "Resume" : "Hold")
//                        .font(.caption)
//                        .foregroundColor(sessionState == .paused ? .green : .white)
//                }
//            }
//            .disabled(sessionState.isBusy)
//
//            // End + Interrupt Button
//            Button {
//                // Interrupt or end depending on state
//                if sessionState.isBusy {
//                    interruptCurrentProcess()
//                } else {
//                    endSession()
//                }
//            } label: {
//                VStack(spacing: 10) {
//                    ZStack {
//                        Circle()
//                            .fill(sessionState.isBusy ? Color.yellow.opacity(0.8) : Color.red)
//                            .frame(width: 60, height: 60)
//
//                        Image(systemName: sessionState.isBusy ? "stop.fill" : "xmark")
//                            .foregroundColor(.white)
//                            .font(.system(size: 26))
//                    }
//                    Text(sessionState.isBusy ? "Interrupt" : "End")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                }
//            }
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    // MARK: - Controls Logic
//
//    /// Toggles pause and resume of listening
//    private func togglePauseResume() {
//        switch sessionState {
//        case .listening:
//            pauseListening()
//        case .paused:
//            resumeListening()
//        default:
//            // Do nothing, disabled on busy states
//            break
//        }
//    }
//
//    /// Send user message typed manually (via TextField)
//    private func sendUserMessage() {
//        let trimmed = userTextInput.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return }
//
//        userTextInput = ""
//
//        // Append user message into the chat
//        appendUserMessage(trimmed)
//
//        // Stop any processing & simulate new interaction with manual text
//        cancelSimulation()
//        simulateProcessingThenResponse(for: trimmed)
//    }
//
//    /// Called when the session starts listening
//    private func startListening() {
//        sessionState = .listening
//    }
//
//    /// Pauses listening (Hold button)
//    private func pauseListening() {
//        sessionState = .paused
//    }
//
//    /// Resumes listening (Resume button)
//    private func resumeListening() {
//        sessionState = .listening
//    }
//
//    /// Append user message to chat
//    private func appendUserMessage(_ content: String) {
//        let newMessage = GeminiMessage(sender: .user, content: content)
//        withAnimation {
//            chatMessages.append(newMessage)
//        }
//    }
//
//    /// Append assistant message to chat
//    private func appendAssistantMessage(_ content: String) {
//        let newMessage = GeminiMessage(sender: .assistant, content: content)
//        withAnimation {
//            chatMessages.append(newMessage)
//        }
//    }
//
//    /// Interrupts the current processing or speaking phase and return to listening
//    private func interruptCurrentProcess() {
//        cancelSimulation()
//        sessionState = .listening
//
//        // Optionally notify user
//        appendAssistantMessage("Interaction interrupted. Listening...")
//    }
//
//    /// Ends live session and dismisses this view
//    private func endSession() {
//        cancelSimulation()
//        isPresented = false
//    }
//
//    /// Cancel any ongoing simulations/tasks
//    private func cancelSimulation() {
//        simulationTask?.cancel()
//        simulationTask = nil
//    }
//
//    // MARK: - Simulated conversation workflow
//
//    /// Simulates assistant processing then responding to a user query string
//    private func simulateProcessingThenResponse(for query: String) {
//        // Ensure we are in processing state
//        sessionState = .processing
//
//        simulationTask = Task {
//            // Simulate delay to process (1.5 - 3 secs)
//            try? await Task.sleep(nanoseconds: UInt64.random(in: 1_500_000_000...3_000_000_000))
//
//            guard !Task.isCancelled else { return }
//
//            await MainActor.run {
//                sessionState = .speaking
//            }
//
//            // Pick a related assistant reply, at random
//            let response = generateAssistantResponse(for: query)
//
//            // Append the response during speaking state
//            await MainActor.run {
//                appendAssistantMessage(response)
//            }
//
//            // Simulate speech duration based on length (20 characters per second)
//            let speakDuration = max(2.0, Double(response.count) / 20.0)
//            try? await Task.sleep(nanoseconds: UInt64(speakDuration * 1_000_000_000))
//
//            guard !Task.isCancelled else { return }
//
//            await MainActor.run {
//                // Return to listening after speech done
//                sessionState = .listening
//            }
//        }
//    }
//
//    /// Generate an assistant response from mock data, potentially making it adaptive based on query keywords
//    private func generateAssistantResponse(for query: String) -> String {
//        let lowercasedQuery = query.lowercased()
//
//        if lowercasedQuery.contains("weather") {
//            return "It’s bright and sunny with a temperature around 25°C."
//        } else if lowercasedQuery.contains("swift") {
//            return "Swift is a powerful, easy to learn language developed by Apple."
//        } else if lowercasedQuery.contains("timer") {
//            return "Timer is set. I'll let you know when the time’s up!"
//        } else if lowercasedQuery.contains("a*") || lowercasedQuery.contains("astar") || lowercasedQuery.contains("pathfinding") {
//            return "A* search algorithm finds the shortest path efficiently by using heuristics."
//        } else if lowercasedQuery.contains("fun fact") {
//            return "Did you know? Octopuses have three hearts and blue blood."
//        }
//
//        // Default fallback to random mock
//        return mockAssistantResponses.randomElement() ?? "I’m here if you need anything else."
//    }
//}
//
//// MARK: - Live Status Bar View
//struct LiveStatusBar: View {
//    var sessionState: GeminiSessionState
//
//    var body: some View {
//        HStack(spacing: 8) {
//            // Live Indicator Icon & animation
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
//// MARK: - Pulsating Mic Icon View
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
//// MARK: - Individual Chat Message Row
//struct ChatMessageRow: View {
//    let message: GeminiMessage
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 10) {
//            if message.sender == .assistant { Spacer() } // Assistant messages aligned right
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
//            if message.sender == .user { Spacer() } // User messages aligned left
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

//// MARK: - Preview
//struct GeminiLiveView_Previews: PreviewProvider {
//    @State static var isPresented = true
//
//    static var previews: some View {
//        GeminiLiveView(isPresented: $isPresented)
//            .preferredColorScheme(.dark)
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
