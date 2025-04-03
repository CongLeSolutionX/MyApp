////
////  VoiceChatView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//// Import necessary frameworks
//import GoogleGenerativeAI // Make sure this package is added to your project
//import Speech // For Speech Recognition
//import AVFoundation // For Audio Session
//
//// MARK: - Configuration (API Key - DO NOT HARDCODE IN PRODUCTION)
//struct AIConfig {
//    // --- IMPORTANT ---
//    // Replace "YOUR_API_KEY" with your actual Google Gemini API Key.
//    // For production apps, use environment variables, a configuration file,
//    // or a secure vault service instead of hardcoding the key.
//    // Get your key from Google AI Studio: https://makersuite.google.com/app/apikey
//    // --- IMPORTANT ---
//    static let geminiApiKey = "YOUR_API_KEY" // <<< PASTE YOUR KEY HERE
//}
//
//// MARK: - Custom Error Type
//enum AIError: Error, LocalizedError {
//    case apiKeyMissing
//    case apiError(String)
//    case responseParsingFailed(String)
//    case speechRecognizerError(String)
//    case audioSessionError(String)
//    case permissionDenied(String)
//    case chatInitializationFailed(String)
//    case unknownError(String?) // Catch-all
//
//    var errorDescription: String? {
//        switch self {
//        case .apiKeyMissing:
//            return "Gemini API Key is missing. Please configure it in AIConfig.swift and ensure it's valid."
//        case .apiError(let message):
//            return "Gemini API Error: \(message)"
//        case .responseParsingFailed(let reason):
//            return "Failed to parse Gemini response: \(reason)"
//        case .speechRecognizerError(let reason):
//            return "Speech Recognition Error: \(reason)"
//        case .audioSessionError(let reason):
//            return "Audio Session Error: \(reason)"
//        case .permissionDenied(let permission):
//            return "Permission denied for \(permission). Please enable it in Settings."
//        case .chatInitializationFailed(let reason):
//            return "Failed to initialize Gemini chat: \(reason)"
//        case .unknownError(let message):
//            return "An unexpected error occurred: \(message ?? "No details available.")"
//        }
//    }
//}
//
//// MARK: - Data Models
//enum SenderRole {
//    case user
//    case model
//}
//
//struct ChatMessage: Identifiable, Hashable {
//    let id = UUID()
//    var role: SenderRole
//    var text: String
//    var isError: Bool = false
//}
//
//// MARK: - Speech Recognizer Class (Manages Speech Recognition Logic)
//@MainActor // Ensure updates happen on the main thread
//class SpeechRecognizer: ObservableObject {
//    @Published var transcript: String = ""
//    @Published var isRecording: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var hasPermissions: Bool = false
//
//    private var audioEngine: AVAudioEngine?
//    private var request: SFSpeechAudioBufferRecognitionRequest?
//    private var task: SFSpeechRecognitionTask?
//    private let recognizer: SFSpeechRecognizer?
//
//    init() {
//        recognizer = SFSpeechRecognizer() // Use default locale
//         // Check initial permissions synchronously if possible, then request async if needed
//         let speechStatus = SFSpeechRecognizer.authorizationStatus()
//         let micStatus = AVAudioSession.sharedInstance().recordPermission
//         self.hasPermissions = (speechStatus == .authorized) && (micStatus == .granted)
//
//         // Request permissions async if they haven't been determined or granted yet
//        if speechStatus == .notDetermined || micStatus == .undetermined || !self.hasPermissions {
//             Task {
//                 await requestPermissions()
//             }
//         } else if speechStatus == .denied || speechStatus == .restricted || micStatus == .denied {
//            // If already denied, set error message
//            self.errorMessage = AIError.permissionDenied("Microphone or Speech Recognition").localizedDescription
//         }
//    }
//
////    deinit {
////        // Clean up resources when the object is deallocated
////        resetAudio()
////        resetRecognition()
////    }
//    deinit {
//        print("SpeechRecognizer deinit starting.")
//        // Clean up resources when the object is deallocated.
//        // Since deinit is non-isolated, and resetAudio/resetRecognition are MainActor-isolated (due to class annotation),
//        // we must explicitly dispatch the calls to the Main Actor.
//        Task {
//            // Use await MainActor.run to ensure these methods execute on the main thread.
//            // We capture [weak self] to avoid prolonging the object's lifetime if the task execution is delayed,
//            // although in deinit context the object is already being destroyed.
//            await MainActor.run { [weak self] in
//                // Check if self still exists when this task runs.
//                guard let strongSelf = self else {
//                    print("Deinit Task: Self was nil during cleanup attempt on Main Actor.")
//                    return
//                }
//                print("Deinit Task: Executing cleanup on Main Actor for \(strongSelf).")
//                strongSelf.resetAudio()
//                strongSelf.resetRecognition(cancelTask: true) // Ensure recognition task is stopped/cancelled
//                print("Deinit Task: Cleanup finished on Main Actor.")
//            }
//        }
//        print("SpeechRecognizer deinit finished scheduling cleanup.") // deinit returns synchronously
//    }
//
//    // --- Permission Handling ---
//    func requestPermissions() async {
//        let speechAuthStatus = SFSpeechRecognizer.authorizationStatus()
//        let micAuthStatus = AVAudioSession.sharedInstance().recordPermission
//
//        var speechNeedsRequest = false
//        var micNeedsRequest = false
//        var currentErrorMessage: String? = nil // Local var to avoid race conditions on @Published
//
//        // Determine which permissions need explicit requests
//        switch speechAuthStatus {
//        case .notDetermined: speechNeedsRequest = true
//        case .denied, .restricted: currentErrorMessage = AIError.permissionDenied("Speech Recognition").localizedDescription
//        case .authorized: break // Already granted
//        @unknown default: currentErrorMessage = "Unknown Speech Recognition authorization status."
//        }
//
//        // Only proceed to check mic if speech isn't already denied/restricted
//        if currentErrorMessage == nil {
//            switch micAuthStatus {
//            case .undetermined: micNeedsRequest = true
//            case .denied: currentErrorMessage = AIError.permissionDenied("Microphone").localizedDescription
//            case .granted: break // Already granted
//            @unknown default: currentErrorMessage = "Unknown Microphone permission status."
//            }
//        }
//
//        // If errors detectedstatus early, update state and return
//        if let errorMsg = currentErrorMessage {
//            self.hasPermissions = false
//            self.errorMessage = errorMsg
//            return
//        }
//
//        // Request permissions if needed (only if status was notDetermined/undetermined)
//        var speechGranted = (speechAuthStatus == .authorized)
//        var micGranted = (micAuthStatus == .granted)
//
//        if speechNeedsRequest {
//            speechGranted = await requestSpeechPermission()
//        }
//        // Ensure mic request happens only if needed and speech was granted (or already was)
//        if micNeedsRequest && speechGranted {
//            micGranted = await requestMicPermission()
//        }
//
//        // Update overall permission status and error message *after* requests
//        let finalPermissions = speechGranted && micGranted
//        self.hasPermissions = finalPermissions
//
//        if !finalPermissions && self.errorMessage == nil {
//            // Set error message if permissions were not granted after request
//            self.errorMessage = AIError.permissionDenied("Microphone or Speech Recognition").localizedDescription
//        } else if finalPermissions {
//            self.errorMessage = nil // Clear error if permissions are now granted
//        }
//    }
//
//    private func requestSpeechPermission() async -> Bool {
//        await withCheckedContinuation { continuation in
//            SFSpeechRecognizer.requestAuthorization { status in
//                // Ensure continuation runs on main thread if it interacts with UI state later
//                DispatchQueue.main.async {
//                    continuation.resume(returning: status == .authorized)
//                }
//            }
//        }
//    }
//
//    private func requestMicPermission() async -> Bool {
//         await withCheckedContinuation { continuation in
//             AVAudioSession.sharedInstance().requestRecordPermission { granted in
//                  // Ensure continuation runs on main thread if it interacts with UI state later
//                 DispatchQueue.main.async {
//                    continuation.resume(returning: granted)
//                 }
//             }
//         }
//    }
//
//    // --- Recording Control ---
//    func startRecording() {
//         guard hasPermissions else {
//            print("Permissions not granted. Cannot start recording.")
//            errorMessage = AIError.permissionDenied("Microphone or Speech Recognition").localizedDescription
//             // Attempt to request again in case user denied it just now
//             Task { await requestPermissions() }
//            return
//        }
//
//        guard let recognizer = recognizer, recognizer.isAvailable else {
//            self.errorMessage = AIError.speechRecognizerError("Recognizer not available.").localizedDescription
//            return
//        }
//
//        // Reset previous state just in case
//        resetAudio()
//        resetRecognition()
//        transcript = "" // Clear previous transcript
//
//        // Setup Audio Session
//        do {
//            audioEngine = AVAudioEngine()
//            guard let audioEngine = audioEngine else { throw AIError.audioSessionError("Failed to create audio engine.") }
//
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers) // Duck others for better recording
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//
//            let inputNode = audioEngine.inputNode
//
//            // Setup Speech Recognition Request
//            request = SFSpeechAudioBufferRecognitionRequest()
//            guard let request = request else { throw AIError.speechRecognizerError("Failed to create recognition request.") }
//            request.shouldReportPartialResults = true // Get live transcription
//
//             // Start Recognition Task
//             task = recognizer.recognitionTask(with: request) { [weak self] result, error in
//                 guard let self = self else { return } // Avoid strong reference cycles
//
//                var isFinal = false
//
//                if let result = result {
//                    self.transcript = result.bestTranscription.formattedString
//                    isFinal = result.isFinal
//                     // print("Partial transcript: \(self.transcript)") // Debugging
//                }
//
//                // Handle errors or finalization
//                // Important: Recognition task can finish *before* stopRecording is called if user stops talking for long enough
//                if error != nil || isFinal {
//                    print("Stopping recording from recognition task (Error: \(error?.localizedDescription ?? "None"), isFinal: \(isFinal))")
//                    self.stopRecordingInternal() // Use internal stop to avoid recursion
//                }
//            }
//
//            // Setup Audio Tap
//            let recordingFormat = inputNode.outputFormat(forBus: 0)
//             // Handle potential format errors (e.g., 0 sample rate if mic access denied after check)
//             guard recordingFormat.sampleRate > 0 else {
//                 throw AIError.audioSessionError("Invalid audio recording format (Sample Rate: \(recordingFormat.sampleRate)). Microphone access might be restricted.")
//             }
//            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//                self.request?.append(buffer)
//            }
//
//            // Start Audio Engine
//            audioEngine.prepare()
//            try audioEngine.start()
//
//            self.isRecording = true
//            self.errorMessage = nil // Clear previous errors
//             print("Recording started successfully.")
//
//        } catch let error as AIError { // Catch specific AIError
//             print("Specific AIError starting recording: \(error.localizedDescription ?? "Unknown AIError")")
//             self.errorMessage = error.localizedDescription
//             resetAudio()
//             resetRecognition()
//             self.isRecording = false
//        } catch { // Catch any other errors
//            print("Generic Error starting recording: \(error.localizedDescription)")
//            self.errorMessage = AIError.audioSessionError("Setup failed: \(error.localizedDescription)").localizedDescription
//            resetAudio()
//            resetRecognition()
//            self.isRecording = false
//       }
//    }
//
//    // Public stop function
//    func stopRecording() {
//         print("stopRecording() called publicly.")
//         stopRecordingInternal()
//    }
//
//     // Internal stop function to prevent state issues and potential recursion
//     private func stopRecordingInternal() {
//         guard isRecording else { return } // Prevent stopping if not recording
//
//         print("Executing stopRecordingInternal...")
//         // Order matters: Stop engine first to prevent further buffer appends
//         if let engine = audioEngine, engine.isRunning {
//             engine.stop()
//              print("Audio engine stopped.")
//         }
//         audioEngine?.inputNode.removeTap(onBus: 0)
//          print("Audio tap removed.")
//
//          // End the request *after* stopping the engine/tap
//          // Check if request exists and task is not already cancelled/finished
//          if let req = request, task?.isCancelled == false && task?.isFinishing == false {
//              req.endAudio() // Signal the end of audio input
//              print("Recognition request endAudio() called.")
//          }
//
//         // Only set isRecording to false *after* operations are done
//         self.isRecording = false
//          print("isRecording set to false.")
//
//         // Reset resources (task cancellation handled in result handler or deinit)
//         // Don't reset transcript here, let the calling view handle it after sending
//         resetAudio() // Resets engine, session active state
//         resetRecognition(cancelTask: true) // Resets request, and optionally cancels task
//
//         print("stopRecordingInternal finished.")
//     }
//
//    private func resetRecognition(cancelTask: Bool = true) {
//         print("Resetting recognition (Cancel Task: \(cancelTask))...")
//         if cancelTask, let task = task, !task.isCancelled {
//            task.cancel()
//            print("Recognition task cancelled.")
//         }
//         self.task = nil
//         self.request = nil // Release the request object
//         print("Recognition reset.")
//    }
//
//    private func resetAudio() {
//        print("Resetting audio...")
//        if let engine = audioEngine {
//            if engine.isRunning {
//                engine.stop()
//                 print("Audio engine stopped during reset.")
//            }
//           // Don't remove tap here if stopRecordingInternal already did
//            // audioEngine?.inputNode.removeTap(onBus: 0)
//            engine.reset() // Reset internal state
//            print("Audio engine reset.")
//        }
//        self.audioEngine = nil // Release the engine
//
//      // Deactivate audio session (optional - might affect other audio)
//      // do {
//      //     try AVAudioSession.sharedInstance().setActive(false)
//      //      print("Audio session deactivated.")
//      // } catch {
//      //     print("Error deactivating audio session: \(error.localizedDescription)")
//      //     // Don't set errorMessage here usually, as it might overwrite a more critical error
//      // }
//        print("Audio reset complete.")
//    }
//}
//
//// MARK: - Main SwiftUI View
//struct VoiceChatView: View {
//    // --- State Objects and State ---
//    @StateObject private var speechRecognizer = SpeechRecognizer()
//    @State private var messages: [ChatMessage] = []
//    @State private var geminiChat: Chat? = nil // Use Gemini's Chat object type
//    @State private var isLoading: Bool = false // For Gemini API calls
//    @State private var viewErrorMessage: String? = nil // Specific errors for this view (e.g., API key)
//
//    private var combinedErrorMessage: String? {
//        // Prioritize view-specific errors, then speech errors
//        viewErrorMessage ?? speechRecognizer.errorMessage
//    }
//
//    // --- Initialization ---
//    init() {
//        // --- Gemini Chat Initialization ---
//        let apiKey = AIConfig.geminiApiKey
//        if apiKey.isEmpty || apiKey == "YOUR_API_KEY" {
//            // Set error state immediately if key is missing/placeholder
//            // Use _viewErrorMessage to set initial value before view body is rendered
//             _viewErrorMessage = State(initialValue: AIError.apiKeyMissing.localizedDescription)
//        } else {
//            // Configure the model and start the chat
//            // See https://ai.google.dev/tutorials/swift_quickstart
//            let generativeModel = GenerativeModel(
//                name: "gemini-1.5-flash-latest", // Or another suitable model
//                apiKey: apiKey,
//                 // Optional: Add system instructions, safety settings etc. here
//                 // systemInstruction: ModelContent("You are a helpful voice assistant."),
//                 // safetySettings: [...]
//                 generationConfig: GenerationConfig(
//                     temperature: 0.7 // Adjust creativity vs predictability
//                 )
//            )
//            // Start a new chat session
//             // It's okay for geminiChat to be nil initially if key was bad.
//             // sendMessageToGemini will handle the nil case.
//            geminiChat = generativeModel.startChat()
//
//            // --- Add Initial Welcome Message ---
//             // Use _messages to set initial value
//            _messages = State(initialValue: [
//                ChatMessage(role: .model, text: "Hello! Tap the mic and start speaking.")
//             ])
//        }
//    }
//
//    // --- Body ---
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                 // Error Display Area
//                 if let errorMsg = combinedErrorMessage {
//                     Text(errorMsg)
//                         .foregroundColor(.red)
//                         .padding(.horizontal)
//                         .padding(.vertical, 5)
//                         .frame(maxWidth: .infinity, alignment: .leading)
//                         .background(Color.red.opacity(0.1))
//                         .textSelection(.enabled)
//                         .transition(.opacity.animation(.easeInOut))
//                 }
//
//                 // Chat Messages Area
//                 ScrollViewReader { scrollViewProxy in
//                     ScrollView {
//                         VStack(alignment: .leading, spacing: 5) { // Reduced spacing
//                             ForEach(messages) { message in
//                                 ChatMessageRow(message: message)
//                             }
//
//                             // Show partial transcript while recording
//                             if speechRecognizer.isRecording && !speechRecognizer.transcript.isEmpty {
//                                 UserTranscriptRow(text: speechRecognizer.transcript + "...")
//                                     .id("transcript") // ID for scrolling
//                             }
//
//                             // Loading indicator for Gemini
//                             if isLoading {
//                                 HStack {
//                                     ProgressView()
//                                         .padding(.leading, 10)
//                                     Text("Thinking...")
//                                         .foregroundColor(.secondary)
//                                         .padding(.leading, 5)
//                                     Spacer()
//                                 }
//                                 .id("loading") // ID for scrolling
//                             }
//                         } // End VStack
//                         .padding(.vertical, 5) // Allows content edges to be seen better
//                     }
//                     .padding(.horizontal)
//                     .padding(.top, 5)
//
//                     // Scroll to bottom logic
//                     .onChange(of: messages.count) { _, _ in // Trigger on count change
//                          scrollMessages(proxy: scrollViewProxy, msgs: messages, loading: isLoading)
//                     }
//                     .onChange(of: speechRecognizer.transcript) { _, newTranscript in
//                         // Scroll only if recording and transcript isn't empty
//                         if speechRecognizer.isRecording && !newTranscript.isEmpty {
//                              withAnimation(.smooth(duration: 0.15)) {
//                                  scrollViewProxy.scrollTo("transcript", anchor: .bottom)
//                              }
//                         }
//                     }
//                     .onChange(of: isLoading) { _, newValue in
//                         // Scroll when loading starts or stops if needed
//                         scrollMessages(proxy: scrollViewProxy, msgs: messages, loading: newValue)
//                     }
//                     .onAppear { // Scroll on initial appear
//                         scrollMessages(proxy: scrollViewProxy, msgs: messages, loading: isLoading)
//                     }
//                 } // End ScrollViewReader
//
//                 Divider()
//
//                 // Recording Control Area
//                 recordingControlArea
//            }
//            .navigationTitle("Gemini Voice Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            // .onAppear { // Permission check moved to SpeechRecognizer init for earlier feedback
//            //      Task { await speechRecognizer.requestPermissions() }
//            // }
//             // Use standard alert for view-specific errors that aren't permissions
//             .alert("Chat Error", isPresented: Binding(get: { viewErrorMessage != nil && viewErrorMessage != AIError.apiKeyMissing.localizedDescription }, set: { if !$0 { viewErrorMessage = nil } })) {
//                 Button("OK", role: .cancel) { }
//             } message: {
//                  Text(viewErrorMessage ?? "An unknown error occurred.")
//             }
//        } // End NavigationView
//         .navigationViewStyle(.stack) // Use stack style for better behavior on iPad
//    } // End body
//
//    // --- Computed View for Recording Control ---
//    @ViewBuilder
//    private var recordingControlArea: some View {
//        HStack {
//            Spacer()
//            Button {
//                toggleRecording()
//            } label: {
//                ZStack { // Use ZStack for potential background effects or rings
//                    Circle()
//                        .fill(speechRecognizer.isRecording ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
//                        .frame(width: 70, height: 70)
//                        .shadow(radius: 5)
//
//                    Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
//                         .resizable()
//                         .scaledToFit()
//                         .foregroundColor(.white)
//                         .frame(width: 30, height: 30)
//                 }
//            }
//            .padding(.vertical, 10)
//            // Disable if API key is missing OR if permissions are not granted AND not currently recording
//             .disabled((geminiChat == nil && !speechRecognizer.isRecording) || (!speechRecognizer.hasPermissions && !speechRecognizer.isRecording))
//            Spacer()
//        }
//        .background(.thinMaterial) // Add a subtle background
//    }
//
//    // --- Methods ---
//
//    private func toggleRecording() {
//         // Clear view-specific errors when user tries to record
//         if viewErrorMessage != nil { viewErrorMessage = nil }
//
//        if speechRecognizer.isRecording {
//            print("Toggle: Stopping recording...")
//            speechRecognizer.stopRecording() // Stop the recognizer
//
//            // Send the final transcript *after* stopping and getting the final result
//            // Use a small delay or ideally a completion handler from stopRecording
//            Task {
//                 // Give a brief moment for the final recognition result to update the transcript
//                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds delay
//
//                let finalTranscript = speechRecognizer.transcript // Grab transcript AFTER stopping
//                print("Toggle: Final transcript obtained: '\(finalTranscript)'")
//                if !finalTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                    await sendMessageToGemini(message: finalTranscript)
//                    speechRecognizer.transcript = "" // Clear transcript *after* sending
//                } else {
//                     print("Toggle: Final transcript was empty, not sending.")
//                     speechRecognizer.transcript = "" // Still clear it
//                 }
//            }
//        } else {
//            print("Toggle: Starting recording...")
//            // Ensure permissions are okay before starting
//            if speechRecognizer.hasPermissions {
//                 speechRecognizer.startRecording()
//            } else {
//                 // If permissions are not granted, trigger the request again
//                 Task {
//                     print("Toggle: Requesting permissions before starting...")
//                     await speechRecognizer.requestPermissions()
//                     // Try starting again only if permissions were granted by the request
//                     if speechRecognizer.hasPermissions {
//                          print("Toggle: Permissions granted, starting recording now.")
//                          speechRecognizer.startRecording()
//                     } else {
//                          print("Toggle: Permissions still not granted after request.")
//                          // Error message should already be set by requestPermissions
//                     }
//                 }
//            }
//        }
//    }
//
//    @MainActor // Ensure UI updates happen on main thread
//    private func sendMessageToGemini(message: String) async {
//         guard geminiChat != nil else {
//            // This case should be handled by init setting viewErrorMessage,
//             // but double-check for safety.
//            self.viewErrorMessage = AIError.apiKeyMissing.localizedDescription
//            return
//        }
//        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//             print("Attempted to send empty message.")
//            return // Don't send empty messages
//        }
//
//        print("Sending to Gemini: \(message)")
//        isLoading = true
//        let userMessage = ChatMessage(role: .user, text: message)
//        messages.append(userMessage)
//
//        do {
//            // Use the initialized geminiChat
//            guard let chat = geminiChat else {
//                 throw AIError.chatInitializationFailed("Gemini chat service is not available.")
//            }
//
//            // Send message to the Gemini model
//            let response = try await chat.sendMessage(message)
//
//            // Handle the response
//            isLoading = false
//            if let modelText = response.text {
//                print("Gemini Response: \(modelText)")
//                let modelMessage = ChatMessage(role: .model, text: modelText.trimmingCharacters(in: .whitespacesAndNewlines))
//                messages.append(modelMessage)
//                self.viewErrorMessage = nil // Clear previous errors on success
//            } else {
//                 print("Gemini response text was nil.")
//                 // If response is nil but no error thrown, treat as parsing failure
//                 throw AIError.responseParsingFailed("Response content was empty.")
//            }
//        } catch let error as GoogleGenerativeAI.GenerateContentError {
//             isLoading = false
//             // Handle specific Gemini API errors (e.g., blocked prompt, API key issue)
//             print("Gemini API GenerateContentError: \(error)")
//             let specificErrorDesc = "\(error.localizedDescription)" // Get detailed message
//             self.viewErrorMessage = AIError.apiError(specificErrorDesc).localizedDescription
//             messages.append(ChatMessage(role: .model, text: self.viewErrorMessage ?? "An API error occurred.", isError: true))
//        }
//         catch let error as AIError { // Catch specific AIError types we defined
//             isLoading = false
//             print("Caught AIError: \(error.localizedDescription ?? "Unknown AIError")")
//             self.viewErrorMessage = error.localizedDescription
//             messages.append(ChatMessage(role: .model, text: error.localizedDescription ?? "An error occurred.", isError: true))
//         }
//        catch { // Catch any other unexpected errors
//            isLoading = false
//             print("Caught unknown error: \(error.localizedDescription)")
//             let errorDesc = error.localizedDescription
//             self.viewErrorMessage = AIError.unknownError(errorDesc).localizedDescription
//             messages.append(ChatMessage(role: .model, text: self.viewErrorMessage ?? "An unknown error occurred.", isError: true))
//        }
//    }
//
//    // Helper to scroll to the bottom
//    private func scrollMessages(proxy: ScrollViewProxy, msgs: [ChatMessage], loading: Bool) {
//        // Determine the last element to scroll to
//        var lastElementId: UUID? = nil
//        if loading {
//            lastElementId = messages.last(where: { $0.role == .user })?.id // Scroll to last user msg before loading
//        } else {
//            lastElementId = msgs.last?.id // Scroll to the very last message
//        }
//
//        // Find the ID to scroll to
//        let targetId: AnyHashable?
//        if loading && !speechRecognizer.isRecording { // Scroll to loading indicator if active
//             targetId = "loading"
//        } else if speechRecognizer.isRecording && !speechRecognizer.transcript.isEmpty { // Scroll to transcript if active
//             targetId = "transcript"
//        } else { // Otherwise scroll to the last message
//             targetId = msgs.last?.id
//        }
//
//        guard let id = targetId else { return }
//
//        withAnimation(.easeOut(duration: 0.25)) {
//            proxy.scrollTo(id, anchor: .bottom)
//        }
//    }
//
//} // End VoiceChatView
//
//// MARK: - Reusable Chat Message Row Views
//struct ChatMessageRow: View {
//    let message: ChatMessage
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 8) { // Added spacing
//            if message.role == .model {
//                 // Optional: Add an icon for the model
//                 Image(systemName: message.isError ? "exclamationmark.triangle.fill" : "brain.head.profile")
//                     .foregroundColor(message.isError ? .white : .purple)
//                     .padding(.top, 5) // Align icon slightly
//            }
//
//            if message.role == .user {
//                Spacer() // Push user message to the right
//                Text(message.text)
//                    .padding(12) // Slightly larger padding
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(16, corners: [.topLeft, .bottomLeft, .bottomRight]) // Custom corners
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing) // Limit width
//                    .textSelection(.enabled)
//                    .lineLimit(nil) // Allow multiple lines
//            } else { // Model or Error
//                Text(message.text)
//                    .padding(12)
//                    .background(message.isError ? Color.red.opacity(0.8) : Color(.systemGray5))
//                    .foregroundColor(message.isError ? .white : Color(.label))
//                    .cornerRadius(16, corners: [.topRight, .bottomLeft, .bottomRight]) // Custom corners
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading) // Limit width
//                     .textSelection(.enabled)
//                     .lineLimit(nil) // Allow multiple lines
//                Spacer() // Push model message to the left
//            }
//
//            if message.role == .user {
//                 // Optional: Add icon for the user
//                 Image(systemName: "person.fill")
//                     .foregroundColor(.gray)
//                      .padding(.top, 5)
//            }
//        }
//         .padding(.vertical, 4) // Reduced vertical padding between rows
//    }
//}
//
//// Specific view for the partial user transcript while recording
//struct UserTranscriptRow: View {
//    let text: String
//
//     var body: some View {
//         HStack {
//             Spacer()
//             Text(text)
//                 .padding(10)
//                 .background(Color.blue.opacity(0.6)) // Indicate 'in progress'
//                 .foregroundColor(.white.opacity(0.9))
//                 .cornerRadius(15, corners: [.topLeft, .bottomLeft, .bottomRight])
//                 .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
//                 .italic() // Italicize to show it's tentative
//                 .transition(.opacity.combined(with: .scale(scale: 0.95)).animation(.easeInOut(duration: 0.2))) // Add transition
//         }
//          .padding(.vertical, 2)
//     }
//}
//
//// MARK: - Helper Extensions (Optional)
//extension View {
//    // Helper for applying corner radius to specific corners
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCorner(radius: radius, corners: corners))
//    }
//}
//
//// Custom Shape for specific corner radii
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    VoiceChatView()
//}
