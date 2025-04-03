////
////  VoiceChatView.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//// Import necessary frameworks
//import GoogleGenerativeAI
//import Speech // For Speech Recognition
//import AVFoundation // For Audio Session
//
//// MARK: - Configuration (API Key - DO NOT HARDCODE IN PRODUCTION)
//struct AIConfig {
//    // --- IMPORTANT ---
//    // Replace "YOUR_API_KEY" with your actual Google Gemini API Key.
//    // For production apps, use environment variables, a configuration file,
//    // or a secure vault service instead of hardcoding the key.
//    // --- IMPORTANT ---
//    static let geminiApiKey = "YOUR_API_KEY"
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
//            return "Permission denied for \(permission). Please enable it in Settings."
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
//        recognizer = SFSpeechRecognizer()
//        Task {
//            await requestPermissions()
//        }
//    }
//
//    // --- Permission Handling ---
//    func requestPermissions() async {
//        let speechAuthStatus = SFSpeechRecognizer.authorizationStatus()
//        let micAuthStatus = AVAudioSession.sharedInstance().recordPermission
//
//        var speechNeedsRequest = false
//        var micNeedsRequest = false
//
//        // Determine which permissions need explicit requests
//        switch speechAuthStatus {
//        case .notDetermined: speechNeedsRequest = true
//        case .denied, .restricted: errorMessage = AIError.permissionDenied("Speech Recognition").localizedDescription; hasPermissions = false; return
//        case .authorized: break
//        @unknown default: errorMessage = "Unknown Speech Recognition authorization status."; hasPermissions = false; return
//        }
//
//        switch micAuthStatus {
//        case .undetermined: micNeedsRequest = true
//        case .denied: errorMessage = AIError.permissionDenied("Microphone").localizedDescription; hasPermissions = false; return
//        case .granted: break
//        @unknown default: errorMessage = "Unknown Microphone permission status."; hasPermissions = false; return
//        }
//
//        // Request permissions if needed
//        var speechGranted = !speechNeedsRequest
//        var micGranted = !micNeedsRequest
//
//        if speechNeedsRequest {
//            speechGranted = await requestSpeechPermission()
//        }
//        if micNeedsRequest {
//            // *** FIX HERE *** Call the corrected function
//            micGranted = await requestMicPermission()
//        }
//
//        // Update overall permission status and error message
//        self.hasPermissions = speechGranted && micGranted
//        if !self.hasPermissions && errorMessage == nil {
//             errorMessage = AIError.permissionDenied("Microphone or Speech Recognition").localizedDescription
//        } else if self.hasPermissions {
//            errorMessage = nil // Clear error if permissions are now granted
//        }
//    }
//
//    // --- Corrected permission request functions ---
//
//    private func requestSpeechPermission() async -> Bool {
//        await withCheckedContinuation { continuation in
//            SFSpeechRecognizer.requestAuthorization { status in
//                continuation.resume(returning: status == .authorized)
//            }
//        }
//    }
//
//    // *** FUNCTION FIX *** Use withCheckedContinuation for Microphone Permission
//    private func requestMicPermission() async -> Bool {
//         await withCheckedContinuation { continuation in
//             AVAudioSession.sharedInstance().requestRecordPermission { granted in
//                 continuation.resume(returning: granted)
//             }
//         }
//    }
//
//    // --- Recording Control (No changes needed here based on the errors) ---
//    func startRecording() {
//         guard hasPermissions else {
//            print("Permissions not granted. Cannot start recording.")
//            errorMessage = AIError.permissionDenied("Microphone or Speech Recognition").localizedDescription
//             // Attempt to request again in case user just denied
//             Task { await requestPermissions() }
//            return
//        }
//        // ... rest of startRecording implementation ...
//    }
//
//    func stopRecording() {
//        // ... stopRecording implementation ...
//    }
//
//    private func resetRecognition() {
//        // ... resetRecognition implementation ...
//    }
//
//    private func resetAudio() {
//         // ... resetAudio implementation ...
//    }
//}
//// MARK: - Main SwiftUI View
//struct VoiceChatView: View {
//    // --- State ---
//    @StateObject private var speechRecognizer = SpeechRecognizer()
//    @State private var messages: [ChatMessage] = []
//    @State private var geminiChat: Chat? = nil
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String? = nil
//
//    // --- Initialization (Assuming it's correct as per previous response) ---
//    init() {
//        // ... (same initialization logic)
//    }
//
//    // --- Body ---
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                 // Error Display Area
//                 // ... (error display logic)
//
//                 // Chat Messages Area
//                 ScrollViewReader { scrollViewProxy in // Note the name: scrollViewProxy
//                     ScrollView {
//                         // ... (VStack with ForEach for messages)
//
//                         // Show partial transcript while recording
//                          if speechRecognizer.isRecording && !speechRecognizer.transcript.isEmpty {
//                              UserTranscriptRow(text: speechRecognizer.transcript + "...")
//                                  .id("transcript")
//                          }
//                     }
//                     .padding(.horizontal).padding(.top, 10)
//
//                     // Scroll to bottom logic
//                     .onChange(of: messages) { _, newMessages in
//                         // Pass the correct proxy variable name
//                         scrollMessages(proxy: scrollViewProxy, msgs: newMessages)
//                     }
//                     .onChange(of: speechRecognizer.transcript) { _, _ in // Use _ if values aren't needed
//                         if speechRecognizer.isRecording {
//                              // *** FIX HERE *** Use the correct proxy variable name
//                              withAnimation(.smooth(duration: 0.2)) {
//                                  scrollViewProxy.scrollTo("transcript", anchor: .bottom)
//                              }
//                         }
//                     }
//                     .onAppear {
//                         // Pass the correct proxy variable name
//                         scrollMessages(proxy: scrollViewProxy, msgs: messages)
//                     }
//                 } // End ScrollViewReader
//
//                 Divider()
//
//                 // Recording Control Area
////                 recordingControlArea
//            }
//            .navigationTitle("Voice Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .onAppear {
//                 // ... (onAppear logic)
//            }
//        } // End NavigationView
//    } // End body
//
//    // --- Computed View for Recording Control ---
//    // ... (recordingControlArea implementation)
//
//    // --- Methods ---
//    // ... (toggleRecording, sendMessageToGemini methods)
//
//    // Helper to scroll to the bottom
//    private func scrollMessages(proxy: ScrollViewProxy, msgs: [ChatMessage]) {
//        guard let lastMessage = msgs.last else { return }
//        withAnimation(.easeOut(duration: 0.3)) {
//            proxy.scrollTo(lastMessage.id, anchor: .bottom)
//        }
//    }
//
//} // End VoiceChatView
//// MARK: - Reusable Chat Message Row Views (Minor Adaptations)
//
//struct ChatMessageRow: View {
//    let message: ChatMessage
//
//    var body: some View {
//        HStack(alignment: .top) {
//            if message.role == .user {
//                Spacer() // Push user message to the right
//                Text(message.text)
//                    .padding(10)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(15)
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing) // Limit width
//                    .textSelection(.enabled)
//            } else { // Model or Error
//                Text(message.text)
//                    .padding(10)
//                    .background(message.isError ? Color.red.opacity(0.7) : Color(.systemGray5))
//                    .foregroundColor(message.isError ? .white : Color(.label))
//                    .cornerRadius(15)
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading) // Limit width
//                     .textSelection(.enabled)
//                Spacer() // Push model message to the left
//            }
//        }
//         .padding(.vertical, 2)
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
//                 .foregroundColor(.white)
//                 .cornerRadius(15)
//                 .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
//                 .italic() // Italicize to show it's tentative
//         }
//          .padding(.vertical, 2)
//     }
//}
//
//// MARK: - Preview
//
//#Preview {
//    VoiceChatView()
//}
