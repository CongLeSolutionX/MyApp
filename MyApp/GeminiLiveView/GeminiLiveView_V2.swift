//
//  GeminiLiveView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

import SwiftUI

// Example Parent View to demonstrate presentation and dismissal
struct ContentView: View {
    @State private var showGeminiLive = false

    var body: some View {
        ZStack {
            // Your main app background or content
            Color.gray.opacity(0.2).ignoresSafeArea()
            VStack {
                Button("Start Live Session") {
                    showGeminiLive = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .fullScreenCover(isPresented: $showGeminiLive) {
            GeminiLiveView(isPresented: $showGeminiLive) // Pass the binding
        }
    }
}

// Enhanced Gemini Live View
struct GeminiLiveView: View {
    // Binding to control presentation (passed from parent)
    @Binding var isPresented: Bool

    // State Variables for Functionality
    @State private var isPaused: Bool = false // Tracks if the session is paused
    @State private var statusText: String = "Listening..." // Dynamic status/instruction
    // Add state for potential "Assistant is speaking" scenario if needed
    // @State private var isAssistantSpeaking: Bool = false

    // Constants
    private let buttonSize: CGFloat = 60

    // Computed properties for dynamic UI elements
    private var liveIndicatorIcon: String {
        isPaused ? "mic.slash.fill" : "waveform.path.ecg" // Change icon when paused potentially
    }

    private var liveIndicatorOpacity: Double {
        isPaused ? 0.5 : 0.9 // Dim indicator when paused
    }

    private var holdButtonIcon: String {
        isPaused ? "play.fill" : "pause.fill" // Toggle icon
    }

    private var holdButtonText: String {
        isPaused ? "Resume" : "Hold" // Toggle text
    }

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        // Set initial status text when the view appears
        _statusText = State(initialValue: determineInitialStatusText())
    }

    var body: some View {
        ZStack {
            // 1. Background Color
            Color(red: 0.1, green: 0.1, blue: 0.12)
                .ignoresSafeArea()
                // 5. Tap to Interrupt Gesture Recognizer
                .onTapGesture {
                    interruptAssistant()
                }

            // 2. Bottom Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.5),
                    Color.purple.opacity(0.5)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 350)
            .blur(radius: 100)
            .blendMode(.softLight)
            .opacity(0.7)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .allowsHitTesting(false)
            .ignoresSafeArea()

            // 3. Main Content VStack
            VStack {
                // 4. "Live" Indicator
                HStack(spacing: 4) {
                    Image(systemName: liveIndicatorIcon)
                    Text("Live")
                }
                .font(.headline)
                .foregroundColor(.white.opacity(liveIndicatorOpacity)) // Use dynamic opacity
                .padding(.top, 10)
                .animation(.easeInOut, value: liveIndicatorIcon) // Animate icon change
                .animation(.easeInOut, value: liveIndicatorOpacity) // Animate opacity change

                Spacer()

                // 5. Status/Instruction Text (Dynamic)
                Text(statusText)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .id(statusText) // Use .id to help SwiftUI trigger transitions on text change
                    .transition(.opacity.combined(with: .scale(scale: 0.95))) // Subtle transition
                    .animation(.easeInOut, value: statusText) // Animate text changes

                Spacer()
                Spacer()

                // 6. Bottom Controls HStack
                HStack(spacing: 60) {
                    Spacer()

                    // Hold/Resume Button (Dynamic)
                    VStack(spacing: 8) {
                        Button(action: togglePauseResume) { // Use specific action
                            ZStack {
                                Circle()
                                    .fill(.gray.opacity(0.4))
                                    .frame(width: buttonSize, height: buttonSize)

                                Image(systemName: holdButtonIcon) // Use dynamic icon
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .animation(.easeInOut, value: holdButtonIcon) // Animate icon change

                        Text(holdButtonText) // Use dynamic text
                            .font(.caption)
                            .foregroundColor(.white)
                            .animation(.easeInOut, value: holdButtonText) // Animate text change
                    }

                    // End Button
                    VStack(spacing: 8) {
                        Button(action: endSession) { // Use specific action
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
            .padding(.horizontal)
            // Apply tap gesture to VStack instead of ZStack background
            // to potentially avoid interfering with gradient hit testing if it were enabled
            .contentShape(Rectangle()) // Make sure the whole VStack area is tappable
            .onTapGesture {
                 interruptAssistant()
            }

        }
        .statusBar(hidden: false)
        .preferredColorScheme(.dark) // Generally keep UI dark
    }

    // MARK: - Actions

    private func determineInitialStatusText() -> String {
        // Could add logic here based on initial state if needed
        return "Listening..." // Default starting state
    }

    /// Toggles the paused/resumed state of the session.
    private func togglePauseResume() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPaused.toggle()
            if isPaused {
                statusText = "Paused. Tap Resume to continue."
                // Add any logic needed for pausing (e.g., stop audio engine)
                print("Session Paused")
            } else {
                statusText = "Listening..." // Or revert to previous state
                // Add any logic needed for resuming (e.g., start audio engine)
                print("Session Resumed")
            }
        }
    }

    /// Ends the current live session and dismisses the view.
    private func endSession() {
        print("Ending Session")
        // Add cleanup logic if needed (e.g., disconnect, save state)
        isPresented = false // Trigger dismissal via the binding
    }

    /// Handles tapping the main screen area to interrupt.
    private func interruptAssistant() {
        // Only interrupt if not already paused
        guard !isPaused else {
            print("Tap ignored (already paused)")
            return
        }

        print("Interrupting Assistant...")
        // Add logic here:
        // - Stop any text-to-speech output
        // - Cancel current processing/request
        // - Reset state to "Listening"

        // Provide visual feedback (optional)
        withAnimation(.easeInOut(duration: 0.1)) {
            statusText = "Listening..." // Ensure status reflects interruption
            // Could briefly change background or add overlay?
        }
        // Example: Temporarily flash text
        let originalText = statusText
        statusText = "Interrupted!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
             withAnimation(.easeInOut(duration: 0.2)) {
                 // Only revert if still in interrupted state
                 if statusText == "Interrupted!" {
                     statusText = originalText
                 }
             }
        }
    }
}

// Preview Provider
struct GeminiLiveView_Previews: PreviewProvider {
    // Create a dummy binding for the preview
    struct PreviewWrapper: View {
        @State var isPresented = true
        var body: some View {
            GeminiLiveView(isPresented: $isPresented)
        }
    }
    static var previews: some View {
        PreviewWrapper()
          // .preferredColorScheme(.dark) // Already set inside GeminiLiveView
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
