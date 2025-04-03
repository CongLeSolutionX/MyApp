////
////  VoiceChatView_V5.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//// Import necessary frameworks
//import GoogleGenerativeAI // Make sure this package is added to your project
//import Speech       // For Speech Recognition
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
//// MARK: - Custom Error Type (Used by VoiceChatView primarily)
//enum AIError: Error, LocalizedError {
//    case apiKeyMissing
//    case apiError(String)
//    case responseParsingFailed(String)
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
//// MARK: - Speech Recognizer View Model (User's Provided Logic + Enhancements)
//// ViewModel for handling Speech Recognition logic
//class SpeechRecognizerViewModel: ObservableObject {
//    @Published var transcript: String = ""
//    @Published var isRecording: Bool = false
//    @Published var errorMessage: String? = nil
//    // Track microphone permission state separately
//    @Published private(set) var hasMicrophonePermission: Bool = false
//    @Published private(set) var speechRecognitionAuthorized: Bool = false
//
//    private var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Default locale
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine()
//
//    // Computed property to check both permissions
//    var hasRequiredPermissions: Bool {
//        speechRecognitionAuthorized && hasMicrophonePermission
//    }
//
//    // Combined permission request function
//    func requestAllPermissions() async {
//        print("Requesting all permissions...")
//        errorMessage = nil // Clear previous errors
//
//        // 1. Request Speech Recognition Permission
//        let speechStatus = await requestSpeechPermission()
//        DispatchQueue.main.async {
//            self.speechRecognitionAuthorized = speechStatus
//            if !speechStatus {
//                self.errorMessage = AIError.permissionDenied("Speech Recognition").localizedDescription
//                print("Speech recognition permission denied or restricted.")
//            } else {
//                 print("Speech recognition authorized.")
//            }
//        }
//
//        // 2. Request Microphone Permission (only if speech was granted)
//        // If speech wasn't granted, there's no point requesting mic for this feature.
//        if speechStatus {
//            let micStatus = await requestMicPermission()
//            DispatchQueue.main.async {
//                self.hasMicrophonePermission = micStatus
//                if !micStatus {
//                    // Only set mic error if speech was okay but mic failed
//                    self.errorMessage = AIError.permissionDenied("Microphone").localizedDescription
//                    print("Microphone permission denied.")
//                } else {
//                     // Clear error only if BOTH are now granted
//                     if self.speechRecognitionAuthorized { self.errorMessage = nil }
//                     print("Microphone permission granted.")
//                }
//            }
//        }
//        print("Permission request process completed. Speech: \(speechRecognitionAuthorized), Mic: \(hasMicrophonePermission)")
//    }
//
//    // --- Private Permission Helpers ---
//    private func requestSpeechPermission() async -> Bool {
//        await withCheckedContinuation { continuation in
//            SFSpeechRecognizer.requestAuthorization { status in
//                continuation.resume(returning: status == .authorized)
//            }
//        }
//    }
//
//    private func requestMicPermission() async -> Bool {
//         await withCheckedContinuation { continuation in
//             AVAudioApplication.requestRecordPermission { granted in // Use new API
//                 continuation.resume(returning: granted)
//             }
//         }
//    }
//    // --- End Private Permission Helpers ---
//
//    func startRecording() {
//         guard hasRequiredPermissions else {
//            print("Cannot start recording: Required permissions not granted.")
//            // Error message should be set by requestAllPermissions if called previously
//            if errorMessage == nil { // Set a generic one if somehow missed
//                 errorMessage = AIError.permissionDenied("Speech or Microphone").localizedDescription
//            }
//            // Optionally trigger permission request again
//             Task { await requestAllPermissions() }
//            return
//        }
//
//       guard let recognizer = speechRecognizer, recognizer.isAvailable else {
//           print("Speech recognizer not available or not authorized.")
//           self.errorMessage = "Speech recognizer is not available on this device or locale."
//           stopRecording() // Ensure state consistency
//           return
//       }
//
//        if audioEngine.isRunning {
//            print("Audio engine already running, stopping first.")
//            stopRecording() // Stop cleanly before restarting
//        }
//
//        // Clear previous task if exists
//        if recognitionTask != nil {
//            recognitionTask?.cancel()
//            recognitionTask = nil
//            print("Previous recognition task cancelled.")
//        }
//         // Clear transcript and errors when starting fresh
//         DispatchQueue.main.async {
//            self.transcript = ""
//            self.errorMessage = nil
//         }
//
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//            print("Audio session configured successfully.")
//        } catch {
//            print("Audio session setup failed: \(error.localizedDescription)")
//            DispatchQueue.main.async {
//                self.errorMessage = "Audio session setup failed: \(error.localizedDescription)"
//             }
//            return // Exit if audio session fails
//        }
//
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            print("Unable to create recognition request.")
//            DispatchQueue.main.async {
//                self.errorMessage = "Failed to create speech recognition request."
//            }
//            return
//        }
//
//        recognitionRequest.shouldReportPartialResults = true
//
//        let inputNode = audioEngine.inputNode
//         // Ensure no tap exists before installing a new one
//        inputNode.removeTap(onBus: 0)
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//
//         // Check for valid format, especially after permission changes
//         guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
//             print("Invalid recording format detected. SampleRate: \(recordingFormat.sampleRate), Channels: \(recordingFormat.channelCount)")
//             DispatchQueue.main.async {
//                 self.errorMessage = "Invalid audio format. Microphone might be unavailable."
//             }
//             // Attempt to reset audio session
//             do { try audioSession.setActive(false) } catch { print("Failed to deactivate session: \(error)") }
//             return
//         }
//
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
//             self?.recognitionRequest?.append(buffer)
//        }
//
//        audioEngine.prepare()
//
//        do {
//            try audioEngine.start()
//            // Update recording state on main thread AFTER engine starts
//            DispatchQueue.main.async { [weak self] in
//                self?.isRecording = true
//            }
//            print("Audio engine started successfully.")
//        } catch {
//            print("Audio engine start failure: \(error.localizedDescription)")
//             // Clean up resources if start fails
//            inputNode.removeTap(onBus: 0)
//            recognitionRequest.endAudio() // Important to end request
//            self.recognitionRequest = nil
//            do { try audioSession.setActive(false) } catch { print("Failed to deactivate session: \(error)") }
//            DispatchQueue.main.async {
//                self.isRecording = false // Ensure UI reflects stopped state
//                self.errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
//            }
//            return // Exit if engine fails
//        }
//
//        // Start the recognition task
//        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//            guard let self = self else { return } // Ensure self is available
//
//            var isFinal = false
//            if let result = result {
//                // Update transcript on the main thread
//                DispatchQueue.main.async {
//                    self.transcript = result.bestTranscription.formattedString
//                     // print("Transcript Updated: \(self.transcript)") // Debugging
//                }
//                isFinal = result.isFinal
//            }
//
//            // Handle errors or finalization
//            if let error = error {
//                 print("Recognition task error: \(error.localizedDescription)")
//                 // Check for specific errors if needed (e.g., SFSpeechRecognizerError.operationInProgress)
//                 // Stop recording process and display error
//                 self.stopRecording() // Trigger cleanup and UI update
//                 DispatchQueue.main.async {
//                    // Avoid overwriting permission errors if they occured earlier
//                    if self.errorMessage == nil {
//                        self.errorMessage = "Recognition error: \(error.localizedDescription)"
//                    }
//                 }
//
//            } else if isFinal {
//                print("Recognition task finalized.")
//                 // Stop recording process on final result
//                 self.stopRecording() // Trigger cleanup and UI update
//            }
//       }
//    } // End startRecording
//
//    func stopRecording() {
//        // Ensure operations happen safely even if called multiple times
//        guard audioEngine.isRunning || isRecording || recognitionTask != nil else {
//             print("Stop recording called but not active.")
//             // Ensure state is consistent if something went wrong before
//             if isRecording {
//                 DispatchQueue.main.async { self.isRecording = false }
//             }
//            return
//        }
//        print("Stopping recording sequence...")
//
//        // Stop audio engine first
//        if audioEngine.isRunning {
//            audioEngine.stop()
//             print("Audio engine stopped.")
//        }
//
//        // Remove tap
//        audioEngine.inputNode.removeTap(onBus: 0)
//         print("Audio tap removed.")
//
//        // End the audio request
//        recognitionRequest?.endAudio()
//         print("Recognition request audio ended.")
//         self.recognitionRequest = nil // Release request object
//
//        // Cancel the recognition task
//        recognitionTask?.cancel()
//         print("Recognition task cancelled.")
//        self.recognitionTask = nil // Release task object
//
//        // Deactivate audio session
//        do {
//            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//             print("Audio session deactivated.")
//        } catch {
//            print("Failed to deactivate audio session: \(error.localizedDescription)")
//            // Don't set errorMessage here generally, might overwrite recording errors
//        }
//
//        // Update recording state on main thread LAST
//        if isRecording { // Only update if it was true
//             DispatchQueue.main.async { [weak self] in
//                 print("Setting isRecording to false.")
//                 self?.isRecording = false
//             }
//        }
//    } // End stopRecording
//
//} // End SpeechRecognizerViewModel
//
//// MARK: - Main SwiftUI View (Adapted for ViewModel)
//struct VoiceChatView: View {
//    // --- State Objects and State ---
//    // Use the new ViewModel
//    @StateObject private var speechRecognizer = SpeechRecognizerViewModel()
//    @State private var messages: [ChatMessage] = []
//    @State private var geminiChat: Chat? = nil // Use Gemini's Chat object type
//    @State private var isLoading: Bool = false // For Gemini API calls
//    @State private var viewErrorMessage: String? = nil // Specific errors for this view (e.g., API key, Gemini errors)
//
//    private var combinedErrorMessage: String? {
//        // Prioritize view-specific (Gemini/API Key) errors, then speech errors
//        viewErrorMessage ?? speechRecognizer.errorMessage
//    }
//
//    // --- Initialization ---
//    init() {
//        let apiKey = AIConfig.geminiApiKey
//        if apiKey.isEmpty || apiKey == "YOUR_API_KEY" {
//             _viewErrorMessage = State(initialValue: AIError.apiKeyMissing.localizedDescription)
//             _messages = State(initialValue: [
//                ChatMessage(role: .model, text: "API Key needed. Please configure it.", isError: true)
//             ])
//        } else {
//            let generativeModel = GenerativeModel(
//                name: "gemini-1.5-flash-latest",
//                apiKey: apiKey
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
//                         .foregroundColor(.red).padding(.horizontal).padding(.vertical, 5)
//                         .frame(maxWidth: .infinity, alignment: .leading)
//                         .background(Color.red.opacity(0.1)).textSelection(.enabled)
//                         .transition(.opacity.animation(.easeInOut)).lineLimit(2)
//                 }
//
//                 // Chat Messages Area
//                 ScrollViewReader { scrollViewProxy in
//                     ScrollView {
//                         LazyVStack(alignment: .leading, spacing: 5) {
//                             ForEach(messages) { message in
//                                 ChatMessageRow(message: message).id(message.id)
//                             }
//                             if speechRecognizer.isRecording && !speechRecognizer.transcript.isEmpty {
//                                 UserTranscriptRow(text: speechRecognizer.transcript + "...")
//                                     .id("transcript")
//                             }
//                             if isLoading {
//                                 HStack { ProgressView().padding(.leading, 10); Text("Thinking...").foregroundColor(.secondary).padding(.leading, 5); Spacer() }
//                                     .id("loading").padding(.vertical, 4)
//                             }
//                         }
//                         .padding(.vertical, 5)
//                     }
//                     .padding(.horizontal).padding(.top, 5)
//                     .scrollDismissesKeyboard(.interactively)
//                     .onChange(of: messages.last?.id) { _, newLastId in scrollMessages(proxy: scrollViewProxy, targetId: newLastId) }
//                     .onChange(of: speechRecognizer.transcript) { _, newTranscript in if speechRecognizer.isRecording && !newTranscript.isEmpty { scrollMessages(proxy: scrollViewProxy, targetId: "transcript") } }
//                     .onChange(of: isLoading) { _, newValue in if newValue { scrollMessages(proxy: scrollViewProxy, targetId: "loading") } else { scrollMessages(proxy: scrollViewProxy, targetId: messages.last?.id) } }
//                     .onAppear {
//                         // Request permissions when the view appears
//                         Task { await speechRecognizer.requestAllPermissions() }
//                         // Scroll on initial appear
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
//             // Alert for view-specific errors (API key, Gemini)
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
//                        .frame(width: 70, height: 70).shadow(radius: 5)
//                    Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
//                         .resizable().scaledToFit().foregroundColor(.white).frame(width: 30, height: 30)
//                 }
//            }
//            .padding(.vertical, 10)
//            // Disable if API key is missing OR if required permissions aren't granted (unless currently recording, allow stop)
//            .disabled(
//                 (geminiChat == nil && !speechRecognizer.isRecording) ||
//                 (!speechRecognizer.hasRequiredPermissions && !speechRecognizer.isRecording)
//            )
//            Spacer()
//        }
//        .background(.thinMaterial)
//    }
//
//    // --- Methods ---
//    private func toggleRecording() {
//        // Always allow stopping if currently recording
//        if speechRecognizer.isRecording {
//            print("Toggle: Stopping recording...")
//            speechRecognizer.stopRecording() // ViewModel handles internal state
//
//            // Grab transcript immediately. ViewModel's task handler might update it slightly later on `isFinal`.
//            let transcriptToSend = speechRecognizer.transcript
//            print("Toggle: Transcript obtained immediately after stop: '\(transcriptToSend)'")
//
//            if !transcriptToSend.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                 Task {
//                     await sendMessageToGemini(message: transcriptToSend)
//                     // Don't clear transcript here; ViewModel does on next start
//                     // speechRecognizer.transcript = "" // Let ViewModel manage transcript state
//                 }
//            } else {
//                 print("Toggle: Final transcript was empty, not sending.")
//                 // speechRecognizer.transcript = "" // Let ViewModel manage transcript state
//            }
//        } else {
//            print("Toggle: Attempting to start recording...")
//            // Clear specific view errors when user attempts action
//            viewErrorMessage = nil
//            // Clear speech errors as well, let startRecording handle new ones
//            speechRecognizer.errorMessage = nil
//
//            // Check permissions FIRST
//            if speechRecognizer.hasRequiredPermissions {
//                speechRecognizer.startRecording()
//            } else {
//                // If permissions not granted, request them again.
//                Task {
//                    print("Toggle: Requesting permissions before starting...")
//                    await speechRecognizer.requestAllPermissions()
//                    // Try starting only if permissions were granted *after* the request
//                    if speechRecognizer.hasRequiredPermissions {
//                        print("Toggle: Permissions granted after request, starting recording now.")
//                        speechRecognizer.startRecording()
//                    } else {
//                        print("Toggle: Permissions still not granted after request.")
//                        // Error message should already be set by requestAllPermissions in ViewModel
//                    }
//                }
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
//         guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
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
//            isLoading = false
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
//             isLoading = false
//             print("Gemini API GenerateContentError: \(error)")
//             let detailedDesc = error.localizedDescription
//             let aiError = AIError.apiError(detailedDesc)
//             self.viewErrorMessage = aiError.localizedDescription
//             messages.append(ChatMessage(role: .model, text: aiError.localizedDescription ?? "API Error", isError: true))
//        }
//         catch let error as AIError { // Handles our custom errors
//             isLoading = false
//             print("Caught AIError: \(error.localizedDescription ?? "Unknown AIError")")
//             self.viewErrorMessage = error.localizedDescription
//             messages.append(ChatMessage(role: .model, text: error.localizedDescription ?? "Error", isError: true))
//         }
//        catch { // Catch any other errors
//            isLoading = false
//             print("Caught unknown error: \(error.localizedDescription)")
//             let errorDesc = error.localizedDescription
//             let aiError = AIError.unknownError(errorDesc)
//             self.viewErrorMessage = aiError.localizedDescription
//             messages.append(ChatMessage(role: .model, text: errorDesc, isError: true))
//        }
//    }
//
//    // Simplified scroll helper
//    private func scrollMessages(proxy: ScrollViewProxy, targetId: AnyHashable?) {
//        guard let id = targetId else { return }
//        print("Scrolling to ID: \(id)")
//        withAnimation(.easeOut(duration: 0.25)) {
//            proxy.scrollTo(id, anchor: .bottom)
//        }
//    }
//
//} // End VoiceChatView
//
//// MARK: - Reusable Chat Message Row Views (Unchanged)
//struct ChatMessageRow: View {
//    let message: ChatMessage
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 8) {
//            if message.role == .model {
//                 Image(systemName: message.isError ? "exclamationmark.triangle.fill" : "brain.head.profile")
//                     .symbolRenderingMode(.hierarchical)
//                     .foregroundColor(message.isError ? .red : .purple).padding(.top, 5)
//            }
//            if message.role == .user {
//                Spacer()
//                Text(message.text).padding(12).background(Color.blue).foregroundColor(.white)
//                    .cornerRadius(16, corners: [.topLeft, .bottomLeft, .bottomRight])
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
//                    .textSelection(.enabled).lineLimit(nil)
//            } else { // Model or Error
//                Text(message.text).padding(12)
//                    .background(message.isError ? Color.red.opacity(0.8) : Color(.systemGray5))
//                    .foregroundColor(message.isError ? .white : Color(.label))
//                    .cornerRadius(16, corners: [.topRight, .bottomLeft, .bottomRight])
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
//                     .textSelection(.enabled).lineLimit(nil)
//                Spacer()
//            }
//            if message.role == .user {
//                 Image(systemName: "person.fill").foregroundColor(.gray).padding(.top, 5)
//            }
//        }
//         .padding(.vertical, 4)
//    }
//}
//
//// MARK: - User Transcript Row (Unchanged)
//struct UserTranscriptRow: View {
//    let text: String
//     var body: some View {
//         HStack {
//             Spacer()
//             Text(text).padding(10).background(Color.blue.opacity(0.6)).foregroundColor(.white.opacity(0.9))
//                 .cornerRadius(15, corners: [.topLeft, .bottomLeft, .bottomRight])
//                 .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
//                 .italic().transition(.opacity.combined(with: .scale(scale: 0.95)).animation(.easeInOut(duration: 0.2)))
//         }
//         .padding(.vertical, 2)
//     }
//}
//
//// MARK: - Helper Extensions (Unchanged)
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View { clipShape(RoundedCorner(radius: radius, corners: corners)) }
//}
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity; var corners: UIRectCorner = .allCorners
//    func path(in rect: CGRect) -> Path { Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath) }
//}
//
//// MARK: - Preview
//#Preview {
//    // Preview should work better now as ViewModel init is safer
//    VoiceChatView()
//}
