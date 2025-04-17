//
//  GeminiLiveView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

import SwiftUI
import Combine // Needed for ActivityIndicator workaround if needed

// Example Parent View
struct ContentView: View {
    @State private var showGeminiLive = false

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            VStack {
                Button("Start Live Session") {
                    showGeminiLive = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .fullScreenCover(isPresented: $showGeminiLive) {
            NavigationView { // Wrap in NavigationView for potential title/bar items later
                GeminiLiveView(isPresented: $showGeminiLive)
                    .navigationBarHidden(true) // Hide the nav bar for this specific view
            }
            .preferredColorScheme(.dark) // Apply dark mode to the whole presented view hierarchy
        }
    }
}

// MARK: - Session State Enum
enum GeminiSessionState: Equatable {
    case listening
    case processing(userQuery: String)
    case speaking(assistantResponse: String)
    case paused
    case error(message: String)

    // Convenience computed properties for UI logic
    var isProcessing: Bool {
        if case .processing = self { return true }
        return false
    }
    var isSpeaking: Bool {
        if case .speaking = self { return true }
        return false
    }
    var isPaused: Bool {
        if case .paused = self { return true }
        return false
    }
}

// MARK: - Gemini Live View
struct GeminiLiveView: View {
    // Binding to control presentation
    @Binding var isPresented: Bool

    // State Management
    @State private var sessionState: GeminiSessionState = .listening
    @State private var currentSimulationTask: Task<Void, Never>? = nil // To manage cancellable tasks

    // Constants
    private let buttonSize: CGFloat = 60
    private let mockQueries = ["What's the weather like?", "Tell me a fun fact about Swift.", "How does A* pathfinding work?", "Set a timer for 5 minutes."]
    private let mockResponses = ["The weather is sunny with a high of 25°C.", "Swift was created by Apple and introduced at WWDC 2014!", "A* is a graph traversal and path search algorithm, which finds the shortest path between nodes using a heuristic.", "Okay, 5-minute timer started!"]

    // MARK: - Computed UI Properties (Driven by State)

    private var statusText: String {
        switch sessionState {
        case .listening: return "Listening... (Tap screen to simulate query)"
        case .processing: return "Thinking..."
        case .speaking: return "Gemini:"
        case .paused: return "Paused. Tap Resume to continue."
        case .error(let message): return "Error: \(message)"
        }
    }

    private var mainContentText: String? {
        switch sessionState {
        case .processing(let query): return "You asked: \"\(query)\""
        case .speaking(let response): return response
        default: return nil // No specific content for listening, paused, error in this area
        }
    }

    private var liveIndicatorIcon: String {
        switch sessionState {
        case .listening: return "waveform.path.ecg"
        case .processing: return "ellipsis" // Represents thinking
        case .speaking: return "speaker.wave.2.fill" // Represents speaking
        case .paused: return "mic.slash.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }

    private var liveIndicatorOpacity: Double {
        sessionState.isPaused ? 0.5 : 0.9
    }

    private var holdButtonIcon: String {
        sessionState.isPaused ? "play.fill" : "pause.fill"
    }

    private var holdButtonText: String {
        sessionState.isPaused ? "Resume" : "Hold"
    }

    // Disable hold/resume during processing/speaking/error for simplicity
    private var holdButtonDisabled: Bool {
        sessionState.isProcessing || sessionState.isSpeaking || sessionState == .error(message: "") // Simplified error check
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1, green: 0.1, blue: 0.12)
                .ignoresSafeArea()
                // Main tap gesture recognizer
                .onTapGesture {
                    handleMainTap()
                }

            // Gradient Overlay
            createGradientOverlay()

            // Main Content VStack
            VStack {
                // Live Indicator
                createLiveIndicator()

                Spacer()

                // Dynamic Content Area
                createDynamicContentArea()

                Spacer()
                Spacer()

                // Bottom Controls HStack
                createBottomControls()
            }
            .padding(.horizontal)
            .contentShape(Rectangle()) // Ensure VStack area catches taps
            .onTapGesture { // Redundant due to ZStack tap, but ensures it's caught here
                handleMainTap()
            }
        }
        .statusBar(hidden: false)
        // Preferred color scheme moved to Navigation View in ContentView for wider effect
        .onAppear(perform: startSession)
        .onDisappear(perform: cleanupSession) // Clean up tasks when view disappears

    }

    // MARK: - UI Builder Functions

    @ViewBuilder
    private func createGradientOverlay() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 350)
        .blur(radius: 100)
        .blendMode(.softLight)
        .opacity(sessionState.isProcessing ? 0.9 : 0.7) // Slightly enhance during processing
        .frame(maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: sessionState.isProcessing)
    }

    @ViewBuilder
    private func createLiveIndicator() -> some View {
        HStack(spacing: 4) {
            Image(systemName: liveIndicatorIcon)
            Text(sessionState.isPaused || sessionState == .error(message:"") ? "" : "Live") // Show "Live" text appropriately
        }
        .font(.headline)
        .foregroundColor(sessionState == .error(message:"") ? .red : .white.opacity(liveIndicatorOpacity))
        .padding(.vertical, 5).padding(.horizontal, 10)
        .background(sessionState.isProcessing ? .gray.opacity(0.3) : .clear) // Subtle background when processing
        .clipShape(Capsule())
        .padding(.top, 10)
        .animation(.easeInOut, value: sessionState)
    }

    @ViewBuilder
    private func createDynamicContentArea() -> some View {
        VStack {
             // Processing Indicator (Spinner)
            if sessionState.isProcessing {
                ProgressView() // Built-in spinner
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.bottom, 20)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }

            // Status Text (Always Visible)
            Text(statusText)
                .font(sessionState.isSpeaking ? .caption : .title3) // Smaller when showing response
                .fontWeight(.medium)
                .foregroundColor(sessionState == .error(message:"") ? .red : .gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, mainContentText != nil ? 5 : 20) // Adjust padding
                .id("status_\(statusText)") // Use ID for transitions
                .transition(.opacity) // Simple opacity transition

            // Main Content Text (User Query or Assistant Response)
            if let content = mainContentText {
                Text(content)
                    .font(.title2)
                    .fontWeight(.regular)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .id("content_\(content)") // Use ID for transitions
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: sessionState) // Animate changes within this area
    }

    @ViewBuilder
    private func createBottomControls() -> some View {
        HStack(spacing: 60) {
            Spacer()

            // Hold/Resume Button
            VStack(spacing: 8) {
                Button(action: togglePauseResume) {
                    ZStack {
                        Circle()
                            .fill(.gray.opacity(holdButtonDisabled ? 0.2 : 0.4))
                            .frame(width: buttonSize, height: buttonSize)
                        Image(systemName: holdButtonIcon)
                            .font(.title2)
                            .foregroundColor(.white.opacity(holdButtonDisabled ? 0.5 : 1.0))
                    }
                }
                .disabled(holdButtonDisabled) // Disable button based on state
                .animation(.easeInOut, value: holdButtonIcon)
                .animation(.easeInOut, value: holdButtonDisabled)

                Text(holdButtonText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(holdButtonDisabled ? 0.5 : 1.0))
                    .animation(.easeInOut, value: holdButtonText)
                    .animation(.easeInOut, value: holdButtonDisabled)
            }

            // End Button
            VStack(spacing: 8) {
                Button(action: endSession) {
                    ZStack {
                        Circle()
                            .fill(.red)
                            .frame(width: buttonSize, height: buttonSize)
                        Image(systemName: "xmark")
                            .font(Font.title2.weight(.semibold))
                            .foregroundColor(.white)
                    }
                }
                Text("End")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.bottom, 50)
    }

    // MARK: - Actions & State Transitions

    private func startSession() {
        print("GeminiLiveView Appeared - Starting Session")
        sessionState = .listening // Ensure starting state
    }

    private func cleanupSession() {
        print("GeminiLiveView Disappeared - Cleaning Up")
        currentSimulationTask?.cancel() // Cancel any ongoing task
        currentSimulationTask = nil
    }

    /// Handles taps on the main screen area.
    private func handleMainTap() {
        switch sessionState {
        case .listening:
            // Simulate user finishing their speech/query
            simulateUserQuery()
        case .processing, .speaking:
            // Interrupt the assistant
            interruptAssistant()
        case .paused, .error:
            // Ignore taps in these states
            print("Main tap ignored in state: \(sessionState)")
            break
        }
    }

    /// Simulates the user providing a query.
    private func simulateUserQuery() {
        currentSimulationTask?.cancel() // Cancel previous task just in case

        let mockQuery = mockQueries.randomElement() ?? "Tell me something interesting."
        print("Simulating user query: \(mockQuery)")

        // Use Task for async work and cancellation
        currentSimulationTask = Task {
            await MainActor.run { // Ensure state changes happen on the main thread
                 withAnimation(.easeInOut(duration: 0.3)) {
                     sessionState = .processing(userQuery: mockQuery)
                 }
            }

            // Simulate network/processing delay
            try? await Task.sleep(nanoseconds: UInt64.random(in: 1...3) * 1_000_000_000) // 1-3 seconds

            // Check if cancelled before proceeding
            guard !Task.isCancelled else {
                print("Processing task cancelled.")
                // Optionally reset state here if needed upon cancellation
                // await MainActor.run { sessionState = .listening }
                return
            }

            // Simulate getting a response
            let mockResponse = mockResponses.randomElement() ?? "I'm not sure about that, but I can look it up."
            await simulateAssistantResponse(response: mockResponse)
        }
    }

    /// Simulates the assistant speaking/displaying the response.
    @MainActor // Ensure this function runs on the main actor
    private func simulateAssistantResponse(response: String) async {
        // No need to cancel here as it's called sequentially by simulateUserQuery Task

        print("Simulating assistant response: \(response)")
         withAnimation(.easeInOut(duration: 0.3)) {
            sessionState = .speaking(assistantResponse: response)
         }

        // Simulate speech duration (longer for longer responses)
        let responseDuration = max(1.0, Double(response.count) / 20.0) // Crude duration estimate
        try? await Task.sleep(nanoseconds: UInt64(responseDuration * 1_000_000_000))

        // Check if cancelled before returning to listening
         guard !Task.isCancelled else {
             print("Speaking task cancelled.")
             // Optionally reset state here if needed upon cancellation
             // await MainActor.run { sessionState = .listening }
             return
         }

        // Return to listening state
         withAnimation(.easeInOut(duration: 0.2)) {
             if case .speaking = sessionState { // Only transition if still speaking
                 sessionState = .listening
             }
         }
    }

    /// Toggles the paused/resumed state.
    private func togglePauseResume() {
        guard !holdButtonDisabled else { return } // Prevent action if disabled

         withAnimation(.easeInOut(duration: 0.2)) {
             if sessionState.isPaused {
                 sessionState = .listening // Resume to listening state
                 print("Session Resumed")
                 // Add logic to restart audio capture/engine if applicable
             } else if case .listening = sessionState { // Only allow pausing from listening state
                 sessionState = .paused
                 print("Session Paused")
                  // Add logic to pause audio capture/engine if applicable
             }
         }
    }

    /// Ends the current live session and dismisses the view.
    private func endSession() {
        print("Ending Session")
        currentSimulationTask?.cancel() // Cancel any ongoing simulation
        currentSimulationTask = nil
        // Add other cleanup if necessary
        isPresented = false // Trigger dismissal
    }

    /// Interrupts the assistant during processing or speaking.
    private func interruptAssistant() {
        guard sessionState.isProcessing || sessionState.isSpeaking else {
            print("Interrupt ignored (not processing or speaking)")
            return
        }

        print("Interrupting Assistant...")
        currentSimulationTask?.cancel()
        currentSimulationTask = nil

        withAnimation(.easeInOut(duration: 0.1)) {
            sessionState = .listening // Immediately return to listening state
        }
        // Could add brief visual feedback like a flash
    }

    // Example function to trigger an error state
    private func simulateError() {
         withAnimation {
             sessionState = .error(message: "Network connection lost.")
         }
    }
}

// MARK: - Preview Provider
struct GeminiLiveView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var isPresented = true
        var body: some View {
            NavigationView {
                GeminiLiveView(isPresented: $isPresented)
                 .navigationBarHidden(true)
            }
             .preferredColorScheme(.dark)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
           // .preferredColorScheme(.dark) // Apply dark mode to the root view if desired
    }
}
