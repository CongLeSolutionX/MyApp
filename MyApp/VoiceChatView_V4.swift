//
//  VoiceChatView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI
// Import necessary frameworks
import GoogleGenerativeAI // Make sure this package is added to your project
import Speech // For Speech Recognition
import AVFoundation // For Audio Session & Application Permissions

// MARK: - Configuration (API Key - DO NOT HARDCODE IN PRODUCTION)
struct AIConfig {
    // --- IMPORTANT ---
    // Replace "YOUR_API_KEY" with your actual Google Gemini API Key.
    // For production apps, use environment variables, a configuration file,
    // or a secure vault service instead of hardcoding the key.
    // Get your key from Google AI Studio: https://makersuite.google.com/app/apikey
    // --- IMPORTANT ---
    static let geminiApiKey = "YOUR_API_KEY" // <<< PASTE YOUR KEY HERE
    // static let geminiApiKey = "" // Simulate missing key for testing
}

// MARK: - Custom Error Type
enum AIError: Error, LocalizedError {
    case apiKeyMissing
    case apiError(String)
    case responseParsingFailed(String)
    case speechRecognizerError(String)
    case audioSessionError(String)
    case permissionDenied(String) // Parameter describes which permission
    case chatInitializationFailed(String)
    case unknownError(String?) // Catch-all

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "Gemini API Key is missing. Please configure it."
        case .apiError(let message):
            return "Gemini API Error: \(message)"
        case .responseParsingFailed(let reason):
            return "Failed to parse Gemini response: \(reason)"
        case .speechRecognizerError(let reason):
            return "Speech Recognition Error: \(reason)"
        case .audioSessionError(let reason):
            return "Audio Session Error: \(reason)"
        case .permissionDenied(let permission):
            return "\(permission) permission denied. Please enable it in Settings."
        case .chatInitializationFailed(let reason):
            return "Failed to initialize Gemini chat: \(reason)"
        case .unknownError(let message):
            return "An unexpected error occurred: \(message ?? "No details available.")"
        }
    }
}

// MARK: - Data Models
enum SenderRole {
    case user
    case model
}

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    var role: SenderRole
    var text: String
    var isError: Bool = false
}

// MARK: - Speech Recognizer Class (Manages Speech Recognition Logic)
@MainActor // Ensure updates happen on the main thread
class SpeechRecognizer: ObservableObject {

    // --- State ---
    // More granular permission status
    enum PermissionStatus {
        case unknown      // Initial state before checking
        case undetermined // Checked, needs request
        case granted      // Checked, granted
        case denied       // Checked, denied/restricted
    }
    @Published var permissionStatus: PermissionStatus = .unknown
    @Published var hasPermissions: Bool = false // Convenience bool derived from permissionStatus
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String? = nil // For speech/permission specific errors

    // --- Private Properties ---
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?

    // --- Initialization ---
    init() {
        recognizer = SFSpeechRecognizer() // Use default locale

        // --- Initial Permission Status Check (DOES NOT REQUEST) ---
        // This check is generally safe for previews as it doesn't trigger UI/hardware directly
        updatePermissionStatus()
        print("SpeechRecognizer initialized. Initial Permission Status: \(permissionStatus)")
        // --- End Initial Check ---
    }

    // --- Deinitialization ---
   deinit {
       print("SpeechRecognizer deinit starting.")
       Task {
           // See previous explanation about Swift 6 warning and need for MainActor dispatch
           await MainActor.run { [weak self] in
               guard let strongSelf = self else { return }
               strongSelf.resetAudio()
               strongSelf.resetRecognition(cancelTask: true)
               print("Deinit Task: Cleanup finished on Main Actor.")
           }
       }
       print("SpeechRecognizer deinit finished scheduling cleanup.")
   }

    // --- Permission Management ---

    // Updates the internal permission status based on current system state
    // Does NOT request permissions. Safe to call anytime.
    func updatePermissionStatus() {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        let micStatus = AVAudioApplication.shared.recordPermission // Use new API

        let speechGranted = (speechStatus == .authorized)
        let micGranted = (micStatus == .granted)

        let oldStatus = self.permissionStatus // Track if status changes

        if speechGranted && micGranted {
            self.permissionStatus = .granted
            self.hasPermissions = true
            // Clear error message only if it was a permission denial error
            if let currentError = self.errorMessage, currentError.contains("permission denied") {
                 self.errorMessage = nil
            }
        } else if speechStatus == .denied || speechStatus == .restricted || micStatus == .denied {
            self.permissionStatus = .denied
            self.hasPermissions = false
            let deniedPerm = !speechGranted ? "Speech Recognition" : "Microphone"
            self.errorMessage = AIError.permissionDenied(deniedPerm).localizedDescription
        } else { // At least one is .notDetermined
            self.permissionStatus = .undetermined
            self.hasPermissions = false
             // Clear error message if status becomes undetermined (e.g., after settings reset)
            if let currentError = self.errorMessage, currentError.contains("permission denied") {
                 self.errorMessage = nil
            }
        }

        if oldStatus != self.permissionStatus { // Log only if status changed
             print("Permission Status Updated: \(self.permissionStatus), hasPermissions: \(self.hasPermissions)")
        }
    }

    // Requests permissions from the user if they are undetermined.
    // Updates permissionStatus based on the outcome.
    func requestPermissions() async {
        print("requestPermissions: Entered function. Current status: \(self.permissionStatus)")
         // Only proceed if currently undetermined
         guard self.permissionStatus == .undetermined else {
              print("requestPermissions called but status is \(self.permissionStatus). No request needed.")
              // Ensure status is up-to-date in case it changed outside the app
              updatePermissionStatus()
              return
         }

         print("Requesting permissions from user...")

        // Check which specific permissions need requesting
        let speechAuthStatus = SFSpeechRecognizer.authorizationStatus()
        let micAuthStatus = AVAudioApplication.shared.recordPermission

        let speechNeedsRequest = (speechAuthStatus == .notDetermined)
        let micNeedsRequest = (micAuthStatus == .undetermined)

        var speechGranted = (speechAuthStatus == .authorized)
        var micGranted = (micAuthStatus == .granted)

        // Request Speech Recognition permission if needed
        if speechNeedsRequest {
            speechGranted = await requestSpeechPermission()
        }

        // Request Microphone permission only if needed AND speech is granted (or was already)
        // Avoids asking for mic if speech was denied during this request sequence
        if micNeedsRequest && speechGranted {
            micGranted = await requestMicPermission()
        }

        // --- Update State Based on Results ---
        let finalPermissionsGranted = speechGranted && micGranted
        self.hasPermissions = finalPermissionsGranted

        if finalPermissionsGranted {
            self.permissionStatus = .granted
            self.errorMessage = nil // Clear any potential error message
            print("Permissions Granted by user.")
        } else {
            // If not granted after explicit request, it implies denial
            self.permissionStatus = .denied
            print("Permissions Denied by user after request.")
            // Set specific error message based on which one failed (if not already set)
            if self.errorMessage == nil || !self.errorMessage!.contains("permission denied"){
                 let deniedPermission = !speechGranted ? "Speech Recognition" : "Microphone"
                 self.errorMessage = AIError.permissionDenied(deniedPermission).localizedDescription
                 print("Set permission denied error message: \(self.errorMessage!)")
            }
        }
        
        print("requestPermissions: Finished. Final status set to: \(self.permissionStatus)") // <-- Add this print
    }

    private func requestSpeechPermission() async -> Bool {
        print("Requesting Speech permission...")
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                print("Speech permission result: \(status.rawValue)")
                DispatchQueue.main.async {
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    private func requestMicPermission() async -> Bool {
        print("Requesting Mic permission...")
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in // Use new API
                 print("Mic permission result: \(granted)")
                 DispatchQueue.main.async {
                    continuation.resume(returning: granted)
                 }
             }
         }
    }

    // --- Recording Control ---
    func startRecording() {
        // Double-check permissions before starting (should be granted if this is called)
         guard permissionStatus == .granted else {
             print("startRecording called but permissions are not granted (\(permissionStatus)). Aborting.")
             // Update status just in case something changed externally
             updatePermissionStatus()
             return
         }

        // Check recognizer availability
        guard let recognizer = recognizer, recognizer.isAvailable else {
            self.errorMessage = AIError.speechRecognizerError("Recognizer not available.").localizedDescription
            print("Error: Recognizer not available.")
            return
        }

        print("Starting audio engine and recognition task...")
        // Reset previous state just in case
        resetAudio()
        resetRecognition()
        transcript = "" // Clear previous transcript

        do {
            audioEngine = AVAudioEngine()
            guard let audioEngine = audioEngine else { throw AIError.audioSessionError("Failed to create audio engine.") }

            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = audioEngine.inputNode
            request = SFSpeechAudioBufferRecognitionRequest()
            guard let request = request else { throw AIError.speechRecognizerError("Failed to create recognition request.") }
            request.shouldReportPartialResults = true

            task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                var isFinal = false
                if let result = result {
                    self.transcript = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                }
                if error != nil || isFinal {
                     // Important: This block can be entered *before* stopRecording is manually called
                     // if the user stops talking for a while or if there's a recognition error.
                      print("Recognition task finished or errored (Error: \(error?.localizedDescription ?? "None"), isFinal: \(isFinal)). Cleaning up.")
                     self.stopRecordingInternal() // Ensure cleanup happens
                }
            }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            guard recordingFormat.sampleRate > 0 else {
                 throw AIError.audioSessionError("Invalid audio format (Sample Rate: \(recordingFormat.sampleRate)).")
             }
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.request?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            self.isRecording = true
            // Do not clear errorMessage here, as it might contain non-permission related info
            print("Recording started successfully.")

        } catch let error as AIError {
             print("Specific AIError starting recording: \(error.localizedDescription)")
             self.errorMessage = error.localizedDescription // Show specific error
             resetAudio()
             resetRecognition()
             self.isRecording = false // Ensure state is reset
        } catch {
            print("Generic Error starting recording: \(error.localizedDescription)")
            self.errorMessage = AIError.audioSessionError("Setup failed: \(error.localizedDescription)").localizedDescription
            resetAudio()
            resetRecognition()
            self.isRecording = false // Ensure state is reset
       }
    }

    // Public stop function
    func stopRecording() {
         print("stopRecording() called publicly.")
         stopRecordingInternal()
    }

    // Internal stop function to prevent state issues and handle cleanup consistently
    private func stopRecordingInternal() {
         // Prevent stopping multiple times or if not actually recording
         guard isRecording else {
              // print("stopRecordingInternal called but not recording. Ignoring.")
              return
         }

         print("Executing stopRecordingInternal...")

         // Stop engine and remove tap FIRST
         if let engine = audioEngine {
             if engine.isRunning {
                 engine.stop()
                  print("Audio engine stopped.")
             }
           engine.inputNode.removeTap(onBus: 0)
            print("Audio tap removed.")
         }

          // End the speech request AFTER stopping audio input
          if let req = request, task?.isCancelled == false && task?.isFinishing == false {
              req.endAudio()
              print("Recognition request endAudio() signaled.")
          } else {
               print("Recognition request already ended or task cancelled.")
          }

          // --- Crucially, set isRecording false AFTER cleanup operations ---
          self.isRecording = false
          print("isRecording set to false.")

         // Reset resources (task cancellation/finalization is handled by the task callback or deinit)
         // Don't reset transcript here, let the caller handle it.
         resetAudio()
         resetRecognition(cancelTask: false) // Don't cancel task here, let it finish naturally or via its handler

         print("stopRecordingInternal finished.")
     }

    // Resets recognition task and request
    private func resetRecognition(cancelTask: Bool = true) {
         // print("Resetting recognition (Cancel Task: \(cancelTask))...")
         if cancelTask, let task = task, !task.isCancelled && !task.isFinishing {
             task.cancel()
              print("Recognition task explicitly cancelled.")
         }
         self.task = nil
         self.request = nil
         // print("Recognition reset.")
    }

    // Resets audio engine and session
    private func resetAudio() {
         // print("Resetting audio...")
         if let engine = audioEngine {
             if engine.isRunning { engine.stop() }
             // Tap is removed in stopRecordingInternal
             engine.reset()
             self.audioEngine = nil
              print("Audio engine reset and released.")
         }
         // Deactivate session only if it's currently active
         do {
             if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint { // Check if session is active-ish
                 try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                 print("Audio session deactivated.")
             }
         } catch {
             print("Error deactivating audio session: \(error.localizedDescription)")
         }
         // print("Audio reset complete.")
    }
}

// MARK: - Main SwiftUI View
struct VoiceChatView: View {
    // --- State Objects and State ---
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var messages: [ChatMessage] = []
    @State private var geminiChat: Chat? = nil
    @State private var isLoading: Bool = false
    @State private var viewErrorMessage: String? = nil // Errors specific to this view (API key, Gemini)

    // Combined error prioritizes view errors, then speech/permission errors
    private var combinedErrorMessage: String? {
        viewErrorMessage ?? speechRecognizer.errorMessage
    }

    // --- Initialization ---
    init() {
        let apiKey = AIConfig.geminiApiKey
        if apiKey.isEmpty || apiKey == "YOUR_API_KEY" {
             _viewErrorMessage = State(initialValue: AIError.apiKeyMissing.localizedDescription)
             _messages = State(initialValue: [
                ChatMessage(role: .model, text: "API Key needed. Please configure.", isError: true)
             ])
        } else {
            let generativeModel = GenerativeModel(
                name: "gemini-1.5-flash-latest", // Or "gemini-pro"
                apiKey: apiKey
            )
            geminiChat = generativeModel.startChat()
             _messages = State(initialValue: [
                ChatMessage(role: .model, text: "Hello! Tap the mic when ready.")
             ])
        }
    }

    // --- Body ---
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                 // Error Display Area
                 if let errorMsg = combinedErrorMessage {
                     ErrorBanner(message: errorMsg)
                 }

                 // Chat Messages Area
                 ScrollViewReader { scrollViewProxy in
                     ScrollView {
                         LazyVStack(alignment: .leading, spacing: 5) {
                             ForEach(messages) { message in ChatMessageRow(message: message).id(message.id) }
                             if speechRecognizer.isRecording && !speechRecognizer.transcript.isEmpty { UserTranscriptRow(text: speechRecognizer.transcript + "...").id("transcript") }
                             if isLoading { LoadingIndicatorRow().id("loading") }
                         }
                         .padding(.vertical, 5)
                     }
                     .padding(.horizontal)
                     .padding(.top, 5)
                     .scrollDismissesKeyboard(.interactively)
                     .onChange(of: messages.last?.id) { _, newLastId in scrollMessages(proxy: scrollViewProxy, targetId: newLastId) }
                     .onChange(of: speechRecognizer.transcript) { _, newTranscript in if speechRecognizer.isRecording && !newTranscript.isEmpty { scrollMessages(proxy: scrollViewProxy, targetId: "transcript") } }
                     .onChange(of: isLoading) { _, newValue in if newValue { scrollMessages(proxy: scrollViewProxy, targetId: "loading") } else { scrollMessages(proxy: scrollViewProxy, targetId: messages.last?.id) } }
                     .onAppear { scrollMessages(proxy: scrollViewProxy, targetId: messages.last?.id) }
                 } // End ScrollViewReader

                 Divider()

                 // Recording Control Area
                 recordingControlArea
            }
            .navigationTitle("Gemini Voice Chat")
            .navigationBarTitleDisplayMode(.inline)
             // Alert for non-permission view errors
             .alert("Chat Error", isPresented: Binding(get: { viewErrorMessage != nil }, set: { if !$0 { viewErrorMessage = nil } })) {
                 Button("OK", role: .cancel) { }
             } message: { Text(viewErrorMessage ?? "An unknown error occurred.") }
             // Refresh permission status when the app becomes active again
             .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                 print("App became active, updating permission status.")
                 speechRecognizer.updatePermissionStatus()
             }
        }
         .navigationViewStyle(.stack)
    }

    // --- Computed View for Recording Control ---
    @ViewBuilder
    private var recordingControlArea: some View {
        HStack {
            Spacer()
            Button {
                toggleRecording()
            } label: {
                RecordButtonView(isRecording: speechRecognizer.isRecording)
            }
            .padding(.vertical, 10)
            // --- Updated Disabled Logic ---
            // Disable only if:
            // 1. API key is missing AND not currently recording (allow stopping)
            // 2. Permissions are explicitly DENIED AND not currently recording
             .disabled(
                  (geminiChat == nil && !speechRecognizer.isRecording) ||
                  (speechRecognizer.permissionStatus == .denied && !speechRecognizer.isRecording)
             )
             // --- End Updated Disabled Logic ---
            Spacer()
        }
        .background(.thinMaterial)
    }

    // --- Methods ---

    private func toggleRecording() {
        print("Mic button tapped! Current status: \(speechRecognizer.permissionStatus)") 
        // --- Stopping Logic ---
        if speechRecognizer.isRecording {
            print("Toggle: Stopping recording...")
            // Grab transcript *before* calling stop, as stop resets state internally
             let transcriptToSend = speechRecognizer.transcript
             speechRecognizer.stopRecording() // Signal recognizer to stop & cleanup

             print("Toggle: Transcript obtained just before stop: '\(transcriptToSend)'")
             if !transcriptToSend.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                 Task {
                     await sendMessageToGemini(message: transcriptToSend)
                     // Transcript state is managed internally by SpeechRecognizer now
                 }
             } else {
                 print("Toggle: Transcript was empty, not sending.")
                  // Transcript state is managed internally
             }
        }
        // --- Starting Logic ---
        else {
            print("Toggle: Attempting to start recording...")
            // Clear *view-specific* errors when user tries to record
            if viewErrorMessage != nil { viewErrorMessage = nil }
            // *Do not* clear speechRecognizer.errorMessage here, it might be a persistent denial

            switch speechRecognizer.permissionStatus {
            case .granted:
                 print("Toggle: Permissions are granted. Starting recording.")
                 speechRecognizer.startRecording() // Start capturing audio

            case .undetermined:
//                 print("Toggle: Permissions undetermined. Requesting now...")
//                 Task {
//                      await speechRecognizer.requestPermissions() // Show system pop-up
//                      // After request, check status again
//                      if speechRecognizer.permissionStatus == .granted {
//                           print("Toggle: Permissions granted after request. Starting recording.")
//                           speechRecognizer.startRecording()
//                      } else {
//                           print("Toggle: Permissions denied after request. Recording not started.")
//                           // Error message should now be set within speechRecognizer
//                      }
//                 }
                print("Status is undetermined. Preparing to request permissions Task...") // <-- Add this print
                      Task {
                           print("Permission request Task launched.") // <-- Add this print
                           await speechRecognizer.requestPermissions() // Show system pop-up
                           print("Permissions request finished. New status: \(speechRecognizer.permissionStatus)") // <-- Add this print
                           // After request, check status again
                           if speechRecognizer.permissionStatus == .granted {
                                print("Permissions granted after request. Starting recording.")
                                speechRecognizer.startRecording()
                           } else {
                                print("Permissions denied or still undetermined after request. Recording not started.")
                           }
                      }

            case .denied:
                 print("Toggle: Permissions previously denied. Cannot start recording.")
                 // Ensure the error message is visible (it should be set already)
                 speechRecognizer.updatePermissionStatus() // Refresh status just in case

             case .unknown: // Should not happen after init, treat as undetermined
                  print("Toggle: Permission status unknown. Attempting request...")
                  Task {
                       await speechRecognizer.requestPermissions()
                       if speechRecognizer.permissionStatus == .granted {
                            speechRecognizer.startRecording()
                       }
                  }
            }
        }
    }

    @MainActor
    private func sendMessageToGemini(message: String) async {
         guard geminiChat != nil else {
            self.viewErrorMessage = AIError.apiKeyMissing.localizedDescription
             print("Error: sendMessageToGemini called but geminiChat is nil.")
            return
        }
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
             print("Attempted to send empty message.")
            return
        }

        print("Sending to Gemini: \(message)")
        isLoading = true
        viewErrorMessage = nil // Clear previous view errors before sending
        let userMessage = ChatMessage(role: .user, text: message)
        messages.append(userMessage)

        do {
            // Force unwrap safe here due to guard check above
            let response = try await geminiChat!.sendMessage(message)
            isLoading = false

            if let modelText = response.text {
                print("Gemini Response: \(modelText)")
                let modelMessage = ChatMessage(role: .model, text: modelText.trimmingCharacters(in: .whitespacesAndNewlines))
                messages.append(modelMessage)
            } else {
                 print("Gemini response text was nil.")
                 throw AIError.responseParsingFailed("Response content was empty.")
            }
        } catch let error { // Catch all errors here
             isLoading = false
             let processedError: AIError // Convert to AIError for consistent handling

            if let specificError = error as? GoogleGenerativeAI.GenerateContentError {
                 print("Gemini API GenerateContentError: \(specificError)")
                 processedError = AIError.apiError(specificError.localizedDescription)
             } else if let aiError = error as? AIError {
                 processedError = aiError // Already our custom type
             } else {
                 processedError = AIError.unknownError(error.localizedDescription)
             }

            print("Error sending message: \(processedError.localizedDescription)")
             // Show error in the view's error banner
             self.viewErrorMessage = processedError.localizedDescription
             // Also add error message to chat history
            messages.append(ChatMessage(role: .model, text: processedError.localizedDescription, isError: true))
        }
    }

    // Simplified scroll helper
    private func scrollMessages(proxy: ScrollViewProxy, targetId: AnyHashable?) {
        guard let id = targetId else { return }
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo(id, anchor: .bottom)
        }
    }

} // End VoiceChatView

// MARK: - Reusable Subviews

struct ErrorBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.9))
            .textSelection(.enabled)
            .transition(.opacity.animation(.easeInOut))
            .lineLimit(2)
    }
}

struct LoadingIndicatorRow: View {
     var body: some View {
         HStack {
             ProgressView().padding(.leading, 10)
             Text("Thinking...").foregroundColor(.secondary).padding(.leading, 5)
             Spacer()
         }
         .padding(.vertical, 4)
     }
}

struct RecordButtonView: View {
    let isRecording: Bool
    var body: some View {
        ZStack {
             Circle()
                 .fill(isRecording ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
                 .frame(width: 70, height: 70)
                 .shadow(radius: 5)
             Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                 .resizable().scaledToFit().foregroundColor(.white).frame(width: 30, height: 30)
         }
    }
}

struct ChatMessageRow: View {
    let message: ChatMessage
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .model { // Model message or Error message from model side
                 Image(systemName: message.isError ? "exclamationmark.triangle.fill" : "brain.head.profile")
                     .symbolRenderingMode(.hierarchical)
                     .foregroundColor(message.isError ? .red : .purple)
                     .padding(.top, 5)
                Text(message.text)
                    .padding(12)
                    .background(message.isError ? Color.red.opacity(0.15) : Color(.systemGray5)) // Subtle error background
                    .foregroundColor(message.isError ? .red : Color(.label)) // Error text color red
                    .cornerRadius(16, corners: [.topRight, .bottomLeft, .bottomRight])
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                    .textSelection(.enabled).lineLimit(nil)
                Spacer()
            } else { // User message
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16, corners: [.topLeft, .bottomLeft, .bottomRight])
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
                    .textSelection(.enabled).lineLimit(nil)
                Image(systemName: "person.fill")
                    .foregroundColor(.gray).padding(.top, 5)
            }
        }
         .padding(.vertical, 4)
    }
}

// Specific view for the partial user transcript while recording
struct UserTranscriptRow: View {
    let text: String
     var body: some View {
         HStack {
             Spacer()
             Text(text)
                 .padding(10)
                 .background(Color.blue.opacity(0.6))
                 .foregroundColor(.white.opacity(0.9))
                 .cornerRadius(15, corners: [.topLeft, .bottomLeft, .bottomRight])
                 .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
                 .italic()
                 .transition(.opacity.combined(with: .scale(scale: 0.95)).animation(.easeInOut(duration: 0.2)))
         }
         .padding(.vertical, 2)
     }
}

// MARK: - Helper Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}

// MARK: - Preview
#Preview {
    // Preview should be safer now as permissions are not requested on init.
    // If it still crashes, ensure API key is set or mock SpeechRecognizer.
    VoiceChatView()
}
