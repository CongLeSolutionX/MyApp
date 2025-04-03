////
////  VoiceChatView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//// Import necessary frameworks
//import GoogleGenerativeAI // Make sure this package is added to your project
//import Speech // For Speech Recognition
//import AVFoundation // For Audio Session & Application Permissions
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
//    case permissionDenied(String) // Parameter describes which permission
//    case chatInitializationFailed(String)
//    case unknownError(String?) // Catch-all
//
//    var errorDescription: String? {
//        switch self {
//        case .apiKeyMissing:
//            return "Gemini API Key is missing. Please configure it."
//        case .apiError(let message):
//            return "Gemini API Error: \(message)"
//        case .responseParsingFailed(let reason):
//            return "Failed to parse Gemini response: \(reason)"
//        case .speechRecognizerError(let reason):
//            return "Speech Recognition Error: \(reason)"
//        case .audioSessionError(let reason):
//            return "Audio Session Error: \(reason)"
//        case .permissionDenied(let permission):
//            return "\(permission) permission denied. Please enable it in Settings."
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
//
//        // Check initial permissions using iOS 17+ APIs where available
//        let speechStatus = SFSpeechRecognizer.authorizationStatus()
//        let micStatus = AVAudioApplication.shared.recordPermission // Use new API
//
//        self.hasPermissions = (speechStatus == .authorized) && (micStatus == .granted)
//
//        // Request permissions async if they haven't been determined or granted yet
//        if speechStatus == .notDetermined || micStatus == .undetermined || !self.hasPermissions {
//             Task {
//                 await requestPermissions()
//             }
//        } else if speechStatus == .denied || speechStatus == .restricted || micStatus == .denied {
//            // If already denied, set error message
//            let deniedPermission = (speechStatus != .authorized) ? "Speech Recognition" : "Microphone"
//            self.errorMessage = AIError.permissionDenied(deniedPermission).localizedDescription
//        }
//    }
//
//   deinit {
//       print("SpeechRecognizer deinit starting.")
//       // Clean up resources when the object is deallocated.
//       // Since deinit is non-isolated, and resetAudio/resetRecognition are MainActor-isolated (due to class annotation),
//       // we must explicitly dispatch the calls to the Main Actor.
//       Task {
//           // Use await MainActor.run to ensure these methods execute on the main thread.
//           // We capture [weak self] to avoid prolonging the object's lifetime if the task execution is delayed,
//           // although in deinit context the object is already being destroyed.
//           // NOTE: Swift 6 language mode warns about capturing 'self' here, as the task outlives deinit.
//           // This is currently the standard pattern to call actor-isolated instance methods for cleanup.
//           await MainActor.run { [weak self] in
//               guard let strongSelf = self else {
//                   print("Deinit Task: Self was nil during cleanup attempt on Main Actor.")
//                   return
//               }
//               print("Deinit Task: Executing cleanup on Main Actor for \(strongSelf).")
//               strongSelf.resetAudio()
//               strongSelf.resetRecognition(cancelTask: true)
//               print("Deinit Task: Cleanup finished on Main Actor.")
//           }
//       }
//       print("SpeechRecognizer deinit finished scheduling cleanup.")
//   }
//
//    // --- Permission Handling ---
//    func requestPermissions() async {
//        let speechAuthStatus = SFSpeechRecognizer.authorizationStatus()
//        let micAuthStatus = AVAudioApplication.shared.recordPermission // Use new API
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
//            micGranted = await requestMicPermission() // Use new request method
//        }
//
//        // Update overall permission status and error message *after* requests
//        let finalPermissions = speechGranted && micGranted
//        self.hasPermissions = finalPermissions
//
//        if !finalPermissions && self.errorMessage == nil {
//            // Set error message if permissions were not granted after request
//            let deniedPermission = !speechGranted ? "Speech Recognition" : "Microphone"
//            self.errorMessage = AIError.permissionDenied(deniedPermission).localizedDescription
//        } else if finalPermissions {
//            self.errorMessage = nil // Clear error if permissions are now granted
//        }
//    }
//
//    private func requestSpeechPermission() async -> Bool {
//        await withCheckedContinuation { continuation in
//            SFSpeechRecognizer.requestAuthorization { status in
//                DispatchQueue.main.async { // Ensure UI updates (indirectly via hasPermissions) are safe
//                    continuation.resume(returning: status == .authorized)
//                }
//            }
//        }
//    }
//
//    // Uses new iOS 17+ request method
//    private func requestMicPermission() async -> Bool {
//         await withCheckedContinuation { continuation in
//             AVAudioApplication.requestRecordPermission { granted in // Use new API
//                  DispatchQueue.main.async { // Ensure UI updates are safe
//                     continuation.resume(returning: granted)
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
//            // Use shared session for category setting, still needed
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
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
//                if error != nil || isFinal {
//                    print("Stopping recording from recognition task (Error: \(error?.localizedDescription ?? "None"), isFinal: \(isFinal))")
//                    self.stopRecordingInternal() // Use internal stop to avoid recursion
//                }
//            }
//
//            // Setup Audio Tap
//            let recordingFormat = inputNode.outputFormat(forBus: 0)
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
//        } catch let error as AIError {
//            print("Specific AIError starting recording: \(error.localizedDescription)")
//             self.errorMessage = error.localizedDescription
//             resetAudio()
//             resetRecognition()
//             self.isRecording = false
//        } catch {
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
//         guard isRecording else { return }
//
//         print("Executing stopRecordingInternal...")
//         if let engine = audioEngine, engine.isRunning {
//             engine.stop()
//             engine.inputNode.removeTap(onBus: 0) // Remove tap after stopping engine
//             print("Audio engine stopped and tap removed.")
//         } else if let engine = audioEngine {
//             // Ensure tap is removed even if engine wasn't running but tap might exist
//             engine.inputNode.removeTap(onBus: 0)
//             print("Audio tap removed (engine was not running).")
//         }
//
//          if let req = request, task?.isCancelled == false && task?.isFinishing == false {
//              req.endAudio()
//              print("Recognition request endAudio() called.")
//          }
//
//         // Do NOT modify self.isRecording or self.transcript here. Let the calling code manage these
//         // after potentially retrieving the final transcript.
//
//         resetAudio() // Resets engine, session active state
//         resetRecognition(cancelTask: true) // Resets request, and optionally cancels task
//
//         // Set recording state AFTER cleanup methods complete
//         self.isRecording = false
//         print("stopRecordingInternal finished, isRecording set to false.")
//     }
//
//    private func resetRecognition(cancelTask: Bool = true) {
//         print("Resetting recognition (Cancel Task: \(cancelTask))...")
//         if cancelTask, let task = task, !task.isCancelled {
//            task.cancel()
//            self.task = nil // Ensure task property is nilled after cancellation
//            print("Recognition task cancelled.")
//         }
//         self.request = nil // Release the request object
//         print("Recognition reset.")
//    }
//
//    private func resetAudio() {
//        print("Resetting audio...")
//        if let engine = audioEngine {
//            if engine.isRunning {
//                engine.stop()
//                print("Audio engine stopped during reset.")
//            }
//            // Tap removal is handled in stopRecordingInternal now
//            engine.reset() // Reset internal state
//            self.audioEngine = nil // Release the engine
//            print("Audio engine reset and released.")
//        }
//
//      // Deactivate audio session (usually good practice after finishing recording)
//       do {
//           try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//           print("Audio session deactivated.")
//       } catch {
//           print("Error deactivating audio session: \(error.localizedDescription)")
//           // Avoid setting errorMessage here to not overwrite more critical errors
//       }
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
//        let apiKey = AIConfig.geminiApiKey
//        if apiKey.isEmpty || apiKey == "YOUR_API_KEY" {
//             _viewErrorMessage = State(initialValue: AIError.apiKeyMissing.localizedDescription)
//             _messages = State(initialValue: [ // Add initial instruction even if key is missing
//                ChatMessage(role: .model, text: "API Key needed. Please configure it.", isError: true)
//             ])
//        } else {
//            let generativeModel = GenerativeModel(
//                name: "gemini-1.5-flash-latest",
//                apiKey: apiKey
//                 // Add other configurations if needed
//                 // generationConfig: GenerationConfig(temperature: 0.7)
//            )
//            geminiChat = generativeModel.startChat()
//             _messages = State(initialValue: [
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
//                         .lineLimit(2) // Allow slightly more space for permission errors
//                 }
//
//                 // Chat Messages Area
//                 ScrollViewReader { scrollViewProxy in
//                     ScrollView {
//                         LazyVStack(alignment: .leading, spacing: 5) { // LazyVStack for performance
//                             ForEach(messages) { message in
//                                 ChatMessageRow(message: message)
//                                     .id(message.id) // Ensure each row has a unique ID
//                             }
//
//                             // Show partial transcript while recording
//                             if speechRecognizer.isRecording && !speechRecognizer.transcript.isEmpty {
//                                 UserTranscriptRow(text: speechRecognizer.transcript + "...")
//                                     .id("transcript") // Stable ID for transcript row
//                             }
//
//                             // Loading indicator for Gemini
//                             if isLoading {
//                                 HStack {
//                                     ProgressView().padding(.leading, 10)
//                                     Text("Thinking...").foregroundColor(.secondary).padding(.leading, 5)
//                                     Spacer()
//                                 }
//                                 .id("loading") // Stable ID for loading indicator
//                                 .padding(.vertical, 4)
//                             }
//                         } // End LazyVStack
//                         .padding(.vertical, 5)
//                     }
//                     .padding(.horizontal)
//                     .padding(.top, 5)
//                      .scrollDismissesKeyboard(.interactively) // Dismiss keyboard on scroll
//
//                     // Scroll to bottom logic
//                     .onChange(of: messages.last?.id) { _, newLastId in // Trigger on last message ID change
//                        scrollMessages(proxy: scrollViewProxy, targetId: newLastId)
//                     }
//                     .onChange(of: speechRecognizer.transcript) { _, newTranscript in
//                         if speechRecognizer.isRecording && !newTranscript.isEmpty {
//                             scrollMessages(proxy: scrollViewProxy, targetId: "transcript")
//                         }
//                     }
//                     .onChange(of: isLoading) { _, newValue in
//                         if newValue { // Scroll when loading starts
//                             scrollMessages(proxy: scrollViewProxy, targetId: "loading")
//                         } else { // Scroll to last message when loading finishes
//                             scrollMessages(proxy: scrollViewProxy, targetId: messages.last?.id)
//                         }
//                     }
//                     .onAppear { // Scroll on initial appear to the last message
//                         scrollMessages(proxy: scrollViewProxy, targetId: messages.last?.id)
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
//             // Removed onAppear permission request here, handled in SpeechRecognizer init
//             // Use standard alert for view-specific errors *that aren't permissions*
//             .alert("Chat Error", isPresented: Binding(get: { viewErrorMessage != nil }, set: { if !$0 { viewErrorMessage = nil } })) {
//                 Button("OK", role: .cancel) { }
//             } message: {
//                  Text(viewErrorMessage ?? "An unknown error occurred.")
//             }
//        } // End NavigationView
//         .navigationViewStyle(.stack)
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
//                ZStack {
//                    Circle()
//                        .fill(speechRecognizer.isRecording ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
//                        .frame(width: 70, height: 70)
//                        .shadow(radius: 5)
//
//                    Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
//                         .resizable().scaledToFit().foregroundColor(.white).frame(width: 30, height: 30)
//                 }
//            }
//            .padding(.vertical, 10)
//            // Disable button carefully:
//            // - If API key is missing (geminiChat is nil) AND not currently recording (allow stopping)
//            // - OR if permissions are missing AND not currently recording
//            .disabled(
//                 (geminiChat == nil && !speechRecognizer.isRecording) ||
//                 (!speechRecognizer.hasPermissions && !speechRecognizer.isRecording)
//            )
//            Spacer()
//        }
//        .background(.thinMaterial) // Add a subtle background
//    }
//
//    // --- Methods ---
//
//    private func toggleRecording() {
//         // Always allow stopping if currently recording
//        if speechRecognizer.isRecording {
//            print("Toggle: Stopping recording...")
//            speechRecognizer.stopRecording() // Signal recognizer to stop
//
//            // Get transcript immediately after stop request. Recognition handler might update it slightly later.
//            let transcriptToSend = speechRecognizer.transcript
//            print("Toggle: Transcript obtained immediately after stop: '\(transcriptToSend)'")
//
//            if !transcriptToSend.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                 // Send immediately with the captured transcript
//                 Task {
//                     await sendMessageToGemini(message: transcriptToSend)
//                     // Clear transcript *after* sending logic completes (success or error)
//                     speechRecognizer.transcript = ""
//                 }
//            } else {
//                 print("Toggle: Final transcript was empty, not sending.")
//                 speechRecognizer.transcript = "" // Clear empty transcript
//            }
//        } else {
//            print("Toggle: Starting recording...")
//            // Clear specific view errors when user attempts action
//            if viewErrorMessage != nil { viewErrorMessage = nil }
//
//            if speechRecognizer.hasPermissions {
//                 speechRecognizer.startRecording()
//            } else {
//                 // Request permissions again if not granted
//                 Task {
//                     print("Toggle: Requesting permissions before starting...")
//                     await speechRecognizer.requestPermissions()
//                     // Try starting only if permissions were granted *after* the request
//                     if speechRecognizer.hasPermissions {
//                          print("Toggle: Permissions granted, starting recording now.")
//                          speechRecognizer.startRecording()
//                     } else {
//                          print("Toggle: Permissions still not granted after request.")
//                     }
//                 }
//            }
//        }
//    }
//
//    @MainActor // Ensure UI updates happen on main thread
//    private func sendMessageToGemini(message: String) async {
//         guard geminiChat != nil else {
//            self.viewErrorMessage = AIError.apiKeyMissing.localizedDescription
//            return
//        }
//        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            print("Attempted to send empty message.")
//            return
//        }
//
//        print("Sending to Gemini: \(message)")
//        isLoading = true
//        viewErrorMessage = nil // Clear previous view errors before sending
//        let userMessage = ChatMessage(role: .user, text: message)
//        messages.append(userMessage)
//
//        do {
//            guard let chat = geminiChat else {
//                 throw AIError.chatInitializationFailed("Gemini chat service is not available.")
//            }
//            let response = try await chat.sendMessage(message)
//            isLoading = false // Set loading to false on successful response first
//
//            if let modelText = response.text {
//                print("Gemini Response: \(modelText)")
//                let modelMessage = ChatMessage(role: .model, text: modelText.trimmingCharacters(in: .whitespacesAndNewlines))
//                messages.append(modelMessage)
//            } else {
//                 print("Gemini response text was nil.")
//                 throw AIError.responseParsingFailed("Response content was empty.")
//            }
//        } catch let error as GoogleGenerativeAI.GenerateContentError {
//             isLoading = false // Set loading false on error
//             print("Gemini API GenerateContentError: \(error)")
//             // Extract more specific info if available (e.g., blocked reason)
//             let detailedDesc = error.localizedDescription
//             let aiError = AIError.apiError(detailedDesc)
//             self.viewErrorMessage = aiError.localizedDescription
//            messages.append(ChatMessage(role: .model, text: aiError.localizedDescription, isError: true))
//        }
//         catch let error as AIError {
//             isLoading = false
//             print("Caught AIError: \(error.localizedDescription)")
//             self.viewErrorMessage = error.localizedDescription
//             messages.append(ChatMessage(role: .model, text: error.localizedDescription, isError: true))
//         }
//        catch {
//            isLoading = false
//             print("Caught unknown error: \(error.localizedDescription)")
//             let errorDesc = error.localizedDescription // Non-optional string
//             let aiError = AIError.unknownError(errorDesc)
//             self.viewErrorMessage = aiError.localizedDescription
//             // Use errorDesc directly, no need for ?? ""
//             messages.append(ChatMessage(role: .model, text: errorDesc, isError: true))
//        }
//    }
//
//    // Simplified scroll helper using AnyHashable ID
//    private func scrollMessages(proxy: ScrollViewProxy, targetId: AnyHashable?) {
//        guard let id = targetId else {
//            print("Scroll target ID is nil.")
//            return
//        }
//        print("Scrolling to ID: \(id)")
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
//        HStack(alignment: .top, spacing: 8) {
//            if message.role == .model {
//                 Image(systemName: message.isError ? "exclamationmark.triangle.fill" : "brain.head.profile")
//                     .symbolRenderingMode(.hierarchical) // Nicer rendering for errors
//                     .foregroundColor(message.isError ? .red : .purple)
//                     .padding(.top, 5)
//            }
//
//            if message.role == .user {
//                Spacer()
//                Text(message.text)
//                    .padding(12)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(16, corners: [.topLeft, .bottomLeft, .bottomRight])
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
//                    .textSelection(.enabled).lineLimit(nil)
//            } else { // Model or Error
//                Text(message.text)
//                    .padding(12)
//                    .background(message.isError ? Color.red.opacity(0.8) : Color(.systemGray5))
//                    .foregroundColor(message.isError ? .white : Color(.label))
//                    .cornerRadius(16, corners: [.topRight, .bottomLeft, .bottomRight])
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
//                     .textSelection(.enabled).lineLimit(nil)
//                Spacer()
//            }
//
//            if message.role == .user {
//                 Image(systemName: "person.fill")
//                     .foregroundColor(.gray).padding(.top, 5)
//            }
//        }
//         .padding(.vertical, 4)
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
//                 .background(Color.blue.opacity(0.6))
//                 .foregroundColor(.white.opacity(0.9))
//                 .cornerRadius(15, corners: [.topLeft, .bottomLeft, .bottomRight])
//                 .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
//                 .italic()
//                 .transition(.opacity.combined(with: .scale(scale: 0.95)).animation(.easeInOut(duration: 0.2)))
//         }
//         .padding(.vertical, 2)
//     }
//}
//
//// MARK: - Helper Extensions
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
//    // Add guards or mock data here if the preview still crashes
//    // For now, just instantiate the view directly.
//    VoiceChatView()
//}
