//
//  VoiceInputAreaView.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

// MARK: - VoiceCommandFeature.swift

import SwiftUI
import Combine
import Speech // For SFSpeechRecognizer
import AVFoundation // For AVAudioEngine & AVAudioSession

// MARK: - Info.plist Requirements
/*
 IMPORTANT: Add the following keys to your Info.plist file:

 <key>NSSpeechRecognitionUsageDescription</key>
 <string>Transcribes your voice commands into text prompts for the chat.</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>Captures your voice to create chat prompts.</string>
*/

// MARK: - Voice Input Manager (ObservableObject)

@MainActor // Ensure published properties update on main thread
class VoiceInputManager: ObservableObject {

    // --- Published Properties for UI Binding ---
    @Published var isListening: Bool = false
    @Published var transcribedText: String = ""
    @Published var error: String? = nil
    @Published var hasPermissions: Bool = false // Track if permissions are granted

    // --- Speech Recognition Components ---
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // --- Audio Engine Components ---
    private let audioEngine = AVAudioEngine()

    // --- Initialization ---
    init(localeIdentifier: String = "en-US") { // Default to US English
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        // Initial permission check (doesn't request, just checks status)
        updatePermissionStatus()
    }

    // --- Permission Handling ---
    func requestPermissions() {
        // Combine requests for clarity
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async { // Ensure UI updates on main
                AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                    DispatchQueue.main.async { // Double ensure main thread
                        self?.hasPermissions = (authStatus == .authorized && granted)
                        if !granted {
                            self?.error = "Microphone permission denied."
                        }
                        if authStatus != .authorized {
                            self?.error = "Speech recognition permission denied. Status: \(authStatus.rawValue)"
                        }
                        // Clear error if both succeed
                        if self?.hasPermissions ?? false {
                           self?.error = nil
                        }
                    }
                }
            }
        }
    }

    private func updatePermissionStatus() {
       let speechStatus = SFSpeechRecognizer.authorizationStatus()
       let micStatus = AVAudioSession.sharedInstance().recordPermission
       self.hasPermissions = (speechStatus == .authorized && micStatus == .granted)
    }

    // --- Control Methods ---
    func startListening() {
        guard hasPermissions else {
            error = "Permissions not granted. Please grant microphone and speech recognition access in Settings."
            // Optionally trigger the request again if appropriate
            // requestPermissions()
            return
        }

        guard !isListening else { return } // Don't start if already listening
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            error = "Speech recognizer is not available for the selected locale or device."
            return
        }

        cleanupPreviousTask() // Ensure clean state
        error = nil // Clear previous errors
        transcribedText = "" // Reset text

        do {
            // 1. Configure Audio Session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            // 2. Setup Recognition Request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { throw VoiceError.requestSetupFailed }
            recognitionRequest.shouldReportPartialResults = true // Get live transcription
            // Use on-device recognition if available and desired (faster, private, potentially less accurate)
            if #available(iOS 13, *), recognizer.supportsOnDeviceRecognition {
                 recognitionRequest.requiresOnDeviceRecognition = true // Set based on preference/need
            }

            // 3. Start Recognition Task
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, err in
                guard let self = self else { return }
                var isFinal = false

                if let result = result {
                    // Update transcribed text on the main thread
                    DispatchQueue.main.async {
                         self.transcribedText = result.bestTranscription.formattedString
                    }
                    isFinal = result.isFinal
                }

                // Handle errors or finalization
                if err != nil || isFinal {
                    DispatchQueue.main.async {
                        self.stopListening() // Stop audio engine and cleanup
                        if let err = err {
                             // Don't show cancellation error explicitly if we initiated stop
                            if (err as NSError).code != 203 { // Code 203: SFSpeechErrorCode.cancelled
                                self.error = "Recognition error: \(err.localizedDescription)"
                            }
                        }
                    }
                }
            }

            // 4. Configure Audio Engine Input
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)

            // Check if format is valid (non-zero sample rate crucial)
            guard recordingFormat.sampleRate > 0 else {
                throw VoiceError.invalidAudioFormat("Input node has an invalid format (sample rate is zero). Ensure microphone is connected and working.")
            }

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer) // Feed audio buffer to request
            }

            // 5. Start Audio Engine
            audioEngine.prepare()
            try audioEngine.start()

            // 6. Update State
            isListening = true

        } catch let setupError as VoiceError {
            error = setupError.localizedDescription
            cleanupResources()
        } catch {
//            error = "Audio engine setup failed: \(error.localizedDescription)"
            cleanupResources()
        }
    }

    func stopListening() {
        guard isListening else { return }

        // Stop audio processing first
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        // End the recognition request gracefully
        recognitionRequest?.endAudio()

        // Update state (before potentially long cleanup)
        isListening = false

         // No need to explicitly cancel the task here, ending audio usually stops it.
         // If needed: recognitionTask?.cancel()

        // Cleanup remaining resources
        cleanupPreviousTask()

        // Deactivate audio session (allow other apps to play sound)
        // This can sometimes cause a small delay, do it last.
        // Consider doing it asynchronously if needed.
         DispatchQueue.main.async { // Or slightly delayed async
             try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
         }
    }

    // --- Cleanup ---
    private func cleanupPreviousTask() {
        recognitionTask?.cancel() // Cancel ongoing task if any
        recognitionTask = nil
        recognitionRequest = nil // Release request
    }

    private func cleanupResources() {
        stopListening() // Use stopListening logic for consistent cleanup
    }

    deinit {
        //cleanupResources() // Ensure cleanup on deinitialization
    }
}

// MARK: - Custom Error Enum
enum VoiceError: Error, LocalizedError {
    case requestSetupFailed
    case audioSessionError(Error)
    case audioEngineError(Error)
    case invalidAudioFormat(String)

    var errorDescription: String? {
        switch self {
        case .requestSetupFailed:
            return "Could not initialize the speech recognition request."
        case .audioSessionError(let error):
            return "Audio session configuration failed: \(error.localizedDescription)"
        case .audioEngineError(let error):
            return "Audio engine setup failed: \(error.localizedDescription)"
        case .invalidAudioFormat(let details):
            return "Invalid audio format detected: \(details)"
        }
    }
}

// MARK: - Modified Input Area View (Now includes Voice Button)

struct VoiceInputAreaView: View {
    // Bindings & State passed from the main chat view/view model
    @Binding var userInput: String
    let isProcessing: Bool // For disabling during Gemini response
    let placeholder: String
    let sendMessageAction: () -> Void

    // Voice Input Manager (passed in)
    @ObservedObject var voiceManager: VoiceInputManager

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Microphone Button
            Button {
                if voiceManager.isListening {
                    voiceManager.stopListening()
                    isTextFieldFocused = true // Focus text field when done listening
                } else {
                    voiceManager.startListening()
                    isTextFieldFocused = false // Unfocus text field while listening
                }
            } label: {
                Image(systemName: voiceManager.isListening ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(voiceManager.isListening ? .red : ( isProcessing ? .gray.opacity(0.6) : .blue) ) // Visual feedback
                    .padding(.leading, 4) // Slight padding before text editor
                    .symbolEffect(.pulse.byLayer, options: .repeating, isActive: voiceManager.isListening) // Pulse effect
            }
            .disabled(isProcessing) // Disable mic button while Gemini is thinking
            .sensoryFeedback(.impact(weight: .light), trigger: voiceManager.isListening)

            // Text Editor Area (largely unchanged from previous version)
            ZStack(alignment: .trailing) {
                 TextEditor(text: $userInput)
                     .focused($isTextFieldFocused)
                     .frame(minHeight: 36, maxHeight: 120)
                     .padding(.leading, 10).padding(.trailing, 35) // Inner padding
                     .background(Color(.systemBackground)) // Input field background contrast
                     .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                     .overlay( userInput.isEmpty && !voiceManager.isListening ? Text(placeholder).foregroundColor(Color(.placeholderText)) // Show placeholder only if not listening
                         .padding(.leading, 14).padding(.top, 8) : nil, alignment: .topLeading )
                     .disabled(voiceManager.isListening) // Optionally disable editing while listening

                // Clear button (only if text exists and not listeing)
                if !userInput.isEmpty && !voiceManager.isListening {
                    Button { userInput = "" } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.secondary.opacity(0.7)) }
                    .padding(.trailing, 8).padding(.top, 8).transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .animation(.easeInOut(duration: 0.15), value: userInput.isEmpty)
            .animation(.easeInOut(duration: 0.20), value: voiceManager.isListening) // Animate enable/disable state

            // Send Button (unchanged functionality)
            Button {
                sendMessageAction(); isTextFieldFocused = false
            } label: {
                Group {
                    if isProcessing {
                        ProgressView().tint(.white).frame(width: 30, height: 30)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(isSendButtonEnabled ? Color.blue : Color.gray.opacity(0.5)))
                    }
                }
            }
            .disabled(!isSendButtonEnabled || isProcessing || voiceManager.isListening) // Disable send if listening
            .animation(.easeInOut(duration: 0.2), value: isProcessing)
            .animation(.easeInOut(duration: 0.2), value: isSendButtonEnabled)
            .animation(.easeInOut, value: voiceManager.isListening)
            .keyboardShortcut(.defaultAction).keyboardShortcut(.return, modifiers: .command)
            .sensoryFeedback(.impact(weight: .medium), trigger: isProcessing && isSendButtonEnabled) // Existing feedback

        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 12)) // Adjust padding for mic button
        // --- Card Styling (Applied Externally as before) ---
         .background(.regularMaterial)
         .clipShape(RoundedRectangle(cornerRadius: StyleConstants.cardCornerRadius * 1.5, style: .continuous))
         .shadow(color: .black.opacity(0.15), radius: StyleConstants.cardShadowRadius, x: 0, y: 2)
         .padding(.horizontal)
         .padding(.bottom, 8)
         .padding(.bottom)
        // --- End Card Styling ---

        // Update userInput when transcribed text changes
        .onReceive(voiceManager.$transcribedText) { newText in
            self.userInput = newText
            // Optional: Automatically send message when voice input finishes?
            // Depends on desired UX. Be cautious with auto-sending.
              if !voiceManager.isListening && !newText.isEmpty {
                 sendMessageAction()
             }
        }
         // Request permissions when the view appears
        .onAppear {
            // Only request if status is undetermined, to avoid pestering the user.
            if SFSpeechRecognizer.authorizationStatus() == .notDetermined || AVAudioSession.sharedInstance().recordPermission == .undetermined {
                 voiceManager.requestPermissions()
            }
        }
//         // Handle potential errors (e.g., show an alert via ViewModel binding)
//          .alert("Voice Error", isPresented: $showVoiceErrorAlert, presenting: voiceManager.error) { _ in }
//             message: { errorText in Text(errorText) }
    }

    private var isSendButtonEnabled: Bool { !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

// MARK: - Previews (Illustrative)

// Preview requires setting up a dummy VoiceInputManager
struct VoiceInputAreaView_Previews: PreviewProvider {
    @State static var previewUserInput: String = ""
    @StateObject static var previewVoiceManager = VoiceInputManager()

    static var previews: some View {
        VStack {
            VoiceInputAreaView(
                userInput: $previewUserInput,
                isProcessing: false,
                placeholder: "Ask with voice or text...",
                sendMessageAction: { print("Send: \(previewUserInput)") },
                voiceManager: previewVoiceManager
            )
            .padding()
            .background(.regularMaterial) // Apply card background for preview
            .cornerRadius(20)
            .padding()

            // --- Test Controls for Preview ---
            HStack {
                Button("Toggle Listen") {
                    if previewVoiceManager.isListening {
                        previewVoiceManager.stopListening()
                        // Simulate transcription result for preview
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                             if previewUserInput.isEmpty { // Only set if empty after stop
                                 previewUserInput = "This is transcribed text."
                             }
                         }
                    } else {
                         // Simulate starting listening (won't actually record in preview)
                          previewVoiceManager.isListening = true
                          previewUserInput = "" // Clear input on start
                          previewVoiceManager.error = nil // Clear error
                         // Simulate partial results
                         DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            if previewVoiceManager.isListening { previewUserInput = "This is..." }
                         }
                         DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                             if previewVoiceManager.isListening { previewUserInput = "This is transcribed..." }
                         }
                    }
                }
                Button("Simulate Error") {
                    previewVoiceManager.error = "Simulated permission denied."
                     previewVoiceManager.isListening = false // Ensure listening stops on error
                }
            }.padding()
        }
        .previewLayout(.sizeThatFits)
        .onAppear {
            // In Preview, we can assume permissions for layout testing
            previewVoiceManager.hasPermissions = true
        }
    }
}
