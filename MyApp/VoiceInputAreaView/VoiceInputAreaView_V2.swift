////
////  VoiceInputAreaView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//import Combine
//import Speech // For SFSpeechRecognizer
//import AVFoundation // For AVAudioEngine & AVAudioSession
//
//// MARK: - Info.plist Requirements (CRUCIAL!)
///*
// Add the following keys and descriptive strings to your project's Info.plist file:
//
// <key>NSSpeechRecognitionUsageDescription</key>
// <string>This app uses speech recognition to transcribe your voice into text for chat prompts.</string>
// <key>NSMicrophoneUsageDescription</key>
// <string>This app needs access to the microphone to capture your voice for transcription.</string>
//*/
//
//// MARK: - Voice Mode Enum
//enum VoiceMode: String, CaseIterable, Identifiable {
//    case liveTranscription = "Live" // Tap mic to start/stop, text updates live
//    case holdToTalk = "Hold"      // Press and hold mic, release to stop/transcribe
//    var id: String { self.rawValue }
//}
//
//// MARK: - Custom Error Enum
//enum VoiceError: Error, LocalizedError {
//    case requestSetupFailed
//    case audioSessionError(Error)
//    case audioEngineError(Error)
//    case invalidAudioFormat(String)
//    case recognizerUnavailable
//    case permissionsMissing(String) // More specific permission error
//
//    var errorDescription: String? {
//        switch self {
//        case .requestSetupFailed:
//            return "Could not initialize the speech recognition request."
//        case .audioSessionError(let error):
//            return "Audio session configuration failed: \(error.localizedDescription)"
//        case .audioEngineError(let error):
//            return "Audio engine setup failed: \(error.localizedDescription)"
//        case .invalidAudioFormat(let details):
//            return "Invalid audio format detected: \(details)"
//        case .recognizerUnavailable:
//            return "Speech recognizer is not available for the selected locale or device."
//        case .permissionsMissing(let type):
//            return "Required permission missing: \(type). Please grant access in Settings."
//        }
//    }
//}
//
//// MARK: - Voice Input Manager (ObservableObject) - Supports Modes
//
//@MainActor // Ensure published properties update on main thread
//class VoiceInputManager: ObservableObject {
//
//    // --- Mode ---
//    @Published var currentMode: VoiceMode = .liveTranscription {
//        didSet {
//            // If listening, stop when mode changes to avoid weird states
//            if isListening {
//                stopListening()
//            }
//        }
//    }
//
//    // --- Published Properties for UI Binding & State ---
//    @Published var isListening: Bool = false // True if actively recognizing/mic on
//    @Published var transcribedText: String = "" // Final/Live transcription for binding
//    @Published var error: String? = nil
//    @Published private(set) var hasPermissions: Bool = false // Track if permissions are granted
//
//    // --- Internal State ---
//    private var latestHoldTranscription: String = "" // Store intermediate results for hold mode
//
//    // --- Speech Recognition Components ---
//    private var speechRecognizer: SFSpeechRecognizer?
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//
//    // --- Audio Engine Components ---
//    private let audioEngine = AVAudioEngine()
//    private var audioSessionActive = false // Track audio session state
//
//    // --- Initialization ---
//    init(localeIdentifier: String = "en-US") { // Default to US English
//        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
//        // Initial permission check (doesn't request, just checks status)
//        updatePermissionStatus()
//    }
//
//    // --- Permission Handling ---
//    func requestPermissions() {
//        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
//            DispatchQueue.main.async {
//                AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
//                    DispatchQueue.main.async { // Ensure UI updates on main
//                        guard let self = self else { return }
//                        let micPermissionGranted = granted
//                        let speechPermissionAuthorized = (authStatus == .authorized)
//
//                        self.hasPermissions = micPermissionGranted && speechPermissionAuthorized
//
//                        if !micPermissionGranted && !speechPermissionAuthorized {
//                            self.error = VoiceError.permissionsMissing("Microphone & Speech Recognition").localizedDescription
//                        } else if !micPermissionGranted {
//                            self.error = VoiceError.permissionsMissing("Microphone").localizedDescription
//                        } else  if !speechPermissionAuthorized {
//                              self.error = VoiceError.permissionsMissing("Speech Recognition (\(authStatus.description))").localizedDescription
//                        } else {
//                            self.error = nil // Clear error if both succeed
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    private func updatePermissionStatus() {
//       let speechStatus = SFSpeechRecognizer.authorizationStatus()
//       let micStatus = AVAudioSession.sharedInstance().recordPermission
//       self.hasPermissions = (speechStatus == .authorized && micStatus == .granted)
//    }
//
//    // --- Control Methods (Updated for Modes) ---
//    func startListening() {
//        // 1. Check Permissions
//        guard hasPermissions else {
//            error = VoiceError.permissionsMissing("Microphone/Speech").localizedDescription
//            // Attempt to request if not explicitly denied
//            if SFSpeechRecognizer.authorizationStatus() == .notDetermined || AVAudioSession.sharedInstance().recordPermission == .undetermined {
//                requestPermissions()
//            }
//            return
//        }
//
//        // 2. Check State & Recognizer Availability
//        guard !isListening else { return } // Don't start if already listening
//        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
//            error = VoiceError.recognizerUnavailable.localizedDescription
//            return
//        }
//
//        // 3. Initial Setup
//        cleanupPreviousTask() // Ensure clean state before starting
//        error = nil // Clear previous errors
//
//        // Reset text based on mode
//        if currentMode == .liveTranscription {
//             transcribedText = ""
//        }
//        latestHoldTranscription = "" // Always reset internal hold text
//
//        do {
//            // 4. Configure Audio Session
//            try setupAudioSession(activate: true)
//
//            // 5. Setup Recognition Request
//            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//            guard let recognitionRequest = recognitionRequest else { throw VoiceError.requestSetupFailed }
//            recognitionRequest.shouldReportPartialResults = true // Report partials for both modes internally
//            if #available(iOS 13, *), recognizer.supportsOnDeviceRecognition {
//                 recognitionRequest.requiresOnDeviceRecognition = false // Set based on preference/accuracy needs
//            }
//
//            // 6. Start Recognition Task (Calls handleResult)
//            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, err in
//                self?.handleResult(result, error: err) // Delegate to handler method
//            }
//
//            // 7. Configure Audio Engine Input Tap
//            let inputNode = audioEngine.inputNode
//            let recordingFormat = inputNode.outputFormat(forBus: 0)
//
//            // Check if format is valid (non-zero sample rate crucial)
//            guard recordingFormat.sampleRate > 0 else {
//                throw VoiceError.invalidAudioFormat("Input node has an invalid format (sample rate is zero).")
//            }
//
//            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//                // Append buffer only if recognition request is still active
//                self.recognitionRequest?.append(buffer)
//            }
//
//            // 8. Start Audio Engine
//            audioEngine.prepare()
//            try audioEngine.start()
//
//            // 9. Update State
//            isListening = true
//
//        } catch let setupError as VoiceError {
//            error = setupError.localizedDescription
//            cleanupResources(deactivateSession: true) // Cleanup with session deactivation on error
//        } catch {
//            //error = "Audio engine setup failed: \(error.localizedDescription)"
//            cleanupResources(deactivateSession: true)
//        }
//    }
//
//    func stopListening() {
//        guard isListening else { return } // Only stop if actually listening
//
//        // 1. Signal End of Audio to Recognizer (do this early)
//        recognitionRequest?.endAudio()
//
//        // 2. Stop Audio Engine
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            // Remove tap immediately after stopping
//            audioEngine.inputNode.removeTap(onBus: 0)
//        }
//
//        // 3. Update State (critical to do early for UI responsiveness)
//        isListening = false
//
//        // 4. Handle Final Transcription for Hold Mode
//        if currentMode == .holdToTalk && !latestHoldTranscription.isEmpty {
//             // If recognition task hasn't pushed a final result *yet*, use the last known good one.
//             // handleResult might still overwrite this shortly if it gets a truly final result.
//             // We only assign if it's different to avoid redundant UI updates.
//             if transcribedText != latestHoldTranscription {
//                 DispatchQueue.main.async { // Main thread guarantee needed
//                     self.transcribedText = self.latestHoldTranscription
//                 }
//             }
//        }
//
//        // 5. Deactivate Audio Session (Asynchronously)
//        // Give the system a moment to process the endAudio signal before deactivating.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//            try? self?.setupAudioSession(activate: false)
//        }
//
//        // Note: We DO NOT call cleanupPreviousTask() here anymore.
//        // handleResult will manage the final cleanup when the task actually finishes/errors.
//        // Forcefully cancelling the task here could cause issues if handleResult is pending.
//    }
//
//    // --- Result Handling (Centralized Logic) ---
//    private func handleResult(_ result: SFSpeechRecognitionResult?, error: Error?) {
//        var isFinal = false
//        var bestText = ""
//
//        if let result = result {
//            bestText = result.bestTranscription.formattedString
//            isFinal = result.isFinal // Check if this is the final result from the recognizer
//        }
//
//        // Update state based on mode - MUST BE ON MAIN THREAD
//        DispatchQueue.main.async {
//           // guard let self = self else { return } // Check if self is still valid
//
//            // Ensure we only process results if we are *supposed* to be listening
//            // or if this is the final result after stopListening was called.
//            guard self.isListening || isFinal else {
//                // If not listening and not final (e.g., delayed partial result), ignore.
//                // However, if an error occurs, we need to process it regardless.
//                if error == nil { return }
//                return
//            }
//
//            // Update transcribed text based on mode
//            if self.currentMode == .liveTranscription {
//                 self.transcribedText = bestText // Update bound property directly
//            } else { // HoldToTalk mode
//                 self.latestHoldTranscription = bestText // Store latest internally
//                 if isFinal {
//                     // If recognizer confirms it's done, push the final result
//                     self.transcribedText = bestText
//                 }
//            }
//
//            // Handle errors or task finalization
//            if error != nil || isFinal {
//                 // If we are currently marked as listening, call stopListening first
//                 // to ensure audio engine etc. are stopped consistently.
//                 // stopListening() has internal guards, safe to call even if already stopping.
//                 if self.isListening {
//                     self.stopListening()
//                 }
//
//                 // Process the error *after* ensuring resources are stopping/stopped
//                 if let error = error {
//                      let nsError = error as NSError
//                      // Filter out common cancellation/engine stop errors unless they are unexpected
//                      if !(nsError.domain == "com.apple.Speech" && nsError.code == 203) && // SFSpeechErrorCode.cancelled
//                         !(nsError.domain == NSOSStatusErrorDomain && nsError.code == 1717046381) && // kAudioQueueErr_EnqueueDuringReset
//                         !(nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1107) // Asset fetch error
//                      {
//                         // Only set error if one isn't already set (e.g., from startListening)
//                         if self.error == nil {
//                             self.error = "Recognition Error: \(error.localizedDescription)"
//                         }
//                      }
//                 }
//
//                 // Final cleanup of the speech recognition task and request objects
//                 self.cleanupPreviousTask()
//            }
//        } // End DispatchQueue.main.async
//    }
//
//    // --- Audio Session Management ---
//     private func setupAudioSession(activate: Bool) throws {
//         guard audioSessionActive != activate else { return } // Avoid redundant calls
//
//         let audioSession = AVAudioSession.sharedInstance()
//         if activate {
//             // Use .record for primary function, .measurement for fine-tuning if needed
//             // .duckOthers is usually desirable for voice input
//             try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//             // Set preferred buffer duration for lower latency (adjust as needed)
//             // try audioSession.setPreferredIOBufferDuration(0.02)
//             // Activate the session
//             try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//             audioSessionActive = true
//         } else {
//             // Deactivate the session
//             try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
//             audioSessionActive = false
//         }
//     }
//
//    // --- Cleanup Methods ---
//    private func cleanupPreviousTask() {
//        recognitionTask?.cancel() // Cancel ongoing task if any
//        recognitionTask = nil
//        recognitionRequest = nil // Release request object
//    }
//
//    private func cleanupResources(deactivateSession: Bool) {
//        // Ensure listening state matches audio engine state
//        if isListening || audioEngine.isRunning {
//             // Use stopListening for active states, handles most cleanup
//             stopListening()
//        } else {
//            // If not listening (e.g., error during setup), do minimal cleanup
//             cleanupPreviousTask()
//             if deactivateSession && audioSessionActive {
//                  try? setupAudioSession(activate: false)
//             }
//        }
//    }
//
//    deinit {
//         print("VoiceInputManager deinit") // For debugging
//       // cleanupResources(deactivateSession: true) // Ensure full cleanup on deinitialization
//    }
//}
//
//// MARK: - SFSpeechRecognizerAuthorizationStatus Extension (Helper)
//extension SFSpeechRecognizerAuthorizationStatus {
//    var description: String {
//        switch self {
//        case .authorized: return "Authorized"
//        case .denied: return "Denied"
//        case .restricted: return "Restricted"
//        case .notDetermined: return "Not Determined"
//        @unknown default: return "Unknown"
//        }
//    }
//}
//
//// MARK: - Voice Input Area View (Supports Live & Hold Modes)
//
//struct VoiceInputAreaView: View {
//    // Passed In State & Actions
//    @Binding var userInput: String
//    let isProcessing: Bool // Is Gemini thinking?
//    let placeholder: String
//    let sendMessageAction: () -> Void
//
//    // Voice Manager Instance
//    @ObservedObject var voiceManager: VoiceInputManager
//
//    // Internal View State
//    @FocusState private var isTextFieldFocused: Bool
//    @State private var isPressingHoldButton: Bool = false // Track hold gesture state
//
//    var body: some View {
//        HStack(spacing: 10) {
//            // --- Microphone Button Area (Handles both modes) ---
//            voiceModeButton
//                .padding(.leading, 4) // Maintain consistent padding
//
//            // --- Text Editor Area ---
//            textEditorArea
//
//            // --- Send Button Area ---
//            sendButtonArea
//        }
//        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 12))
//        // External Card Styling (Apply in the parent view)
//        // e.g., .background(.regularMaterial)...
//
//        // --- View Logic ---
//        .onAppear {
//            // Request permissions on appear only if status is undetermined
//            if voiceManager.hasPermissions == false && (SFSpeechRecognizer.authorizationStatus() == .notDetermined || AVAudioSession.sharedInstance().recordPermission == .undetermined) {
//                 voiceManager.requestPermissions()
//            }
//             // Ensure manager mode reflects current selection if changed externally
//             // (Not strictly necessary if ViewModel handles it, but good practice)
//        }
//        // You would typically handle error presentation (like an alert) in the parent view
//        // by observing `voiceManager.error` and binding it to an alert's presentation state.
//    }
//
//    // MARK: - Subviews for Clarity
//
//    @ViewBuilder
//    private var voiceModeButton: some View {
//        Group {
//            if voiceManager.currentMode == .liveTranscription {
//                // --- Live Transcription Button (Tap Toggle) ---
//                Button {
//                    if voiceManager.isListening {
//                        voiceManager.stopListening()
//                        isTextFieldFocused = true // Focus text field when live mode stops
//                    } else {
//                        userInput = "" // Clear text field when STARTING live mode
//                        isTextFieldFocused = false // Unfocus text field while listening
//                        voiceManager.startListening()
//                    }
//                } label: {
//                    micIcon // Use the shared icon view
//                }
//                .disabled(isProcessing) // Disable if Gemini is responding
//
//            } else {
//                // --- Hold-to-Talk Button (Press & Hold Gesture) ---
//                micIcon // The icon itself is the gesture target
//                    .gesture(
//                        DragGesture(minimumDistance: 0) // Detect immediate touch down
//                            .onChanged { _ in // Touch down or drag started
//                                // Start listening only on the initial touch down
//                                if !isPressingHoldButton && !voiceManager.isListening && !isProcessing {
//                                    isPressingHoldButton = true
//                                    isTextFieldFocused = false // Unfocus text field on press
//                                    userInput = "" // Clear text field on press for hold mode
//                                    voiceManager.startListening()
//                                     // Haptic feedback for press down
//                                    #if os(iOS)
//                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                                    #endif
//                                }
//                            }
//                            .onEnded { _ in // Touch released or drag ended
//                                // Stop listening only if we were actually pressing/listening
//                                if isPressingHoldButton {
//                                    voiceManager.stopListening()
//                                    isPressingHoldButton = false
//                                    // Wait a tiny bit before focusing to let transcription finalize
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                         isTextFieldFocused = true
//                                    }
//                                     // Haptic feedback for release
//                                     #if os(iOS)
//                                     UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                     #endif
//                                }
//                            }
//                    )
//                   .disabled(isProcessing) // Prevent gesture if Gemini is processing
//            }
//        }
//        // Use isListening for general impact, button/gesture handles specific haptics
//        .sensoryFeedback(.impact(weight: .light), trigger: voiceManager.isListening)
//    }
//
//    // Shared Microphone Icon View
//    private var micIcon: some View {
//        // Determine icon color based on multiple states
//        let micColor: Color
//        if isProcessing {
//            micColor = .gray.opacity(0.6) // Disabled due to processing
//        } else if voiceManager.isListening || isPressingHoldButton {
//             micColor = .red // Actively listening or being held down
//        } else {
//            micColor = .blue // Idle state
//        }
//
//        // Determine icon image name
//        let iconName = (voiceManager.isListening || isPressingHoldButton) ? "stop.circle.fill" : "mic.circle.fill"
//
//        return Image(systemName: iconName)
//             .resizable()
//             .scaledToFit()
//             .frame(width: 30, height: 30)
//             .foregroundColor(micColor)
//             // Pulse effect only when actively listening (mic is on)
//             .symbolEffect(.pulse.byLayer, options: .repeating, isActive: voiceManager.isListening)
//             .animation(.easeInOut(duration: 0.2), value: isProcessing)
//             .animation(.easeInOut(duration: 0.2), value: voiceManager.isListening)
//             .animation(.easeInOut(duration: 0.2), value: isPressingHoldButton)
//    }
//
//    private var textEditorArea: some View {
//        ZStack(alignment: .trailing) {
//             TextEditor(text: $userInput)
//                 .focused($isTextFieldFocused)
//                 .frame(minHeight: 36, maxHeight: 120) // Consistent height constraints
//                 .padding(.leading, 10) // Inner padding L
//                 .padding(.trailing, 35) // Inner padding R (space for clear button)
//                 .background(Color(.systemBackground).opacity(isInputDisabled ? 0.6 : 1.0)) // Dim if disabled
//                 .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                 .overlay(
//                     // Show placeholder only if input is empty AND not actively listening/pressing
//                     userInput.isEmpty && !isInputDisabled ?
//                     Text(placeholder)
//                         .foregroundColor(Color(.placeholderText))
//                         .padding(.leading, 14) // Adjust padding to align with TextEditor text
//                         .padding(.top, 8) // Align vertically
//                         .allowsHitTesting(false) // Don't block touches to TextEditor
//                     : nil,
//                     alignment: .topLeading
//                 )
//                 .disabled(isInputDisabled) // Disable editing when mic is active
//                 .onChange(of: isTextFieldFocused) { focused in
//                      // If text field gains focus *while* mic is active, stop voice input.
//                      if focused && voiceManager.isListening {
//                          voiceManager.stopListening()
//                          isPressingHoldButton = false // Ensure hold state resets
//                      }
//                 }
//
//            // Clear button (Show if text exists AND input field is not disabled)
//            if !userInput.isEmpty && !isInputDisabled {
//                Button {
//                    userInput = ""
//                    #if os(iOS) // Add haptic feedback for clear action
//                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                    #endif
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.secondary.opacity(0.7))
//                }
//                    .padding(.trailing, 8) // Position inside the ZStack
//                    // .padding(.top, 8) // Align vertically if needed
//                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
//            }
//        }
//        .animation(.easeInOut(duration: 0.15), value: userInput.isEmpty) // Animate clear button
//        .animation(.easeInOut(duration: 0.20), value: isInputDisabled) // Animate disabled state
//    }
//
//     private var sendButtonArea: some View {
//         Button {
//             sendMessageAction() // Call the passed-in action
//             isTextFieldFocused = false // Unfocus text field on send
//         } label: {
//             Group { // Group allows applying frame/background uniformly
//                 if isProcessing {
//                     ProgressView()
//                         .tint(.white) // Make spinner white
//                         .frame(width: 30, height: 30) // Match size
//                 } else {
//                     Image(systemName: "arrow.up")
//                         .font(.system(size: 16, weight: .semibold))
//                         .foregroundColor(.white)
//                         .frame(width: 30, height: 30)
//                         .background(Circle().fill(isSendButtonEnabled ? Color.blue : Color.gray.opacity(0.5)))
//                 }
//             }
//         }
//         .disabled(!isSendButtonEnabled || isProcessing || isInputDisabled) // Disable send if no text, processing, or mic active
//         .animation(.easeInOut(duration: 0.2), value: isProcessing) // Animate spinner transition
//         .animation(.easeInOut(duration: 0.2), value: isSendButtonEnabled) // Animate enabled/disabled state color
//         .animation(.easeInOut, value: isInputDisabled) // Animate disabled state due to mic
//         .keyboardShortcut(.defaultAction) // Allows Enter/Return key press to trigger send
//         .keyboardShortcut(.return, modifiers: .command) // Command+Return also sends
//         .sensoryFeedback(.impact(weight: .medium), trigger: isProcessing && isSendButtonEnabled) // Feedback on send
//     }
//
//    // Computed property to determine if text input/send should be disabled
//     private var isInputDisabled: Bool {
//         voiceManager.isListening || isPressingHoldButton
//     }
//
//    // Computed property for send button enable state (based on text content)
//    private var isSendButtonEnabled: Bool {
//        !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//    }
//}
//
//// MARK: - Preview Provider (Updated for Modes & Debugging)
//
//struct VoiceInputAreaView_ModePreviews: PreviewProvider {
//    // State for the preview environment
//    @State static var previewUserInput: String = ""
//    @StateObject static var previewVoiceManager = VoiceInputManager()
//    @State static var previewIsProcessing: Bool = false // Simulate Gemini processing
//
//    // Mode selection state for the preview controls
//    @State static var previewMode: VoiceMode = .liveTranscription
//
//    static var previews: some View {
//        VStack(spacing: 15) {
//            // --- Preview Controls ---
//            GroupBox("Preview Controls") {
//                Picker("Voice Mode", selection: $previewMode) {
//                    ForEach(VoiceMode.allCases) { mode in
//                        Text(mode.rawValue).tag(mode)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .onChange(of: previewMode) { newMode in
//                     previewVoiceManager.currentMode = newMode // Update the manager's mode
//                     // Reset state when switching modes for a clean preview
//                     if previewVoiceManager.isListening { previewVoiceManager.stopListening() }
//                     previewUserInput = ""
//                     previewVoiceManager.error = nil
//                     previewIsProcessing = false
//                }
//
//                Toggle("Simulate Processing", isOn: $previewIsProcessing)
//            } // End GroupBox
//
//            Divider()
//
//            // --- The Component Being Previewed ---
//            Text("Input Area (Mode: \(previewVoiceManager.currentMode.rawValue))")
//                .font(.headline)
//
//            VoiceInputAreaView(
//                userInput: $previewUserInput,
//                isProcessing: previewIsProcessing,
//                placeholder: "Ask Gemini...",
//                sendMessageAction: {
//                    print("Send (\(previewMode.rawValue)): \(previewUserInput)")
//                    previewUserInput = "" // Clear input after simulating send
//                },
//                voiceManager: previewVoiceManager
//            )
//            .padding(.horizontal, 8) // Add padding to mimic container
//            .padding(.vertical, 5)
//            .background(.thinMaterial) // Use thinMaterial for better context
//            .cornerRadius(25) // Match the rounded corners
//
//            Divider()
//
//            // --- Debugging Info ---
//            GroupBox("Debug Info") {
//                 Text("ManagerListening: \(previewVoiceManager.isListening ? "YES" : "NO")")
//                 Text("Has Permissions: \(previewVoiceManager.hasPermissions ? "YES" : "NO")")
//                 if let err = previewVoiceManager.error {
//                      Text("Error: \(err)").foregroundColor(.red).lineLimit(2).font(.caption)
//                 } else {
//                      Text("Error: None").foregroundColor(.green)
//                 }
//                Text("User Input Binding: \"\(previewUserInput)\"")
//            }
//            .font(.caption)
//            .frame(maxWidth: .infinity)
//
//        }
//        .padding() // Padding around the entire VStack
//        .previewLayout(.sizeThatFits)
//        .onAppear {
//            // Grant permissions *only for preview* to test interaction
//           // previewVoiceManager.hasPermissions = true
//            // Sync the initial mode when the preview appears
//            previewVoiceManager.currentMode = previewMode
//        }
//    }
//}
//
//// MARK: - Integration Notes (For the user)
///*
// HOW TO INTEGRATE THIS INTO YOUR APP:
//
// 1.  Info.plist: Ensure the `NSSpeechRecognitionUsageDescription` and `NSMicrophoneUsageDescription` keys are added to your Info.plist.
//
// 2.  ViewModel (`ObservableObject`):
//     *   Create an instance of `VoiceInputManager`:
//         ```swift
//         @StateObject private var voiceInputManager = VoiceInputManager()
//         // Or use @ObservedObject if passed from elsewhere
//         ```
//     *   Manage the selected voice mode:
//         ```swift
//         @Published var selectedVoiceMode: VoiceMode = .liveTranscription // Load from UserDefaults?
//         ```
//     *   Keep your chat input text state:
//         ```swift
//         @Published var userInput: String = ""
//         ```
//     *   Handle Gemini's processing state:
//         ```swift
//         @Published var isGeminiProcessing: Bool = false
//         ```
//      *   Handle potential errors (e.g., for displaying alerts):
//         ```swift
//         @Published var voiceErrorMessage: String? = nil
//         @Published var showVoiceErrorAlert: Bool = false
//         ```
//     *   In your ViewModel's `init` or a setup function, link the states using Combine:
//         ```swift
//         // Link selected mode to the manager's mode
//         $selectedVoiceMode
//              .receive(on: DispatchQueue.main) // Ensure main thread
//             .assign(to: &voiceInputManager.$currentMode)
//
//         // Update ViewModel's userInput when manager transcribes text
//         voiceInputManager.$transcribedText
//             .dropFirst() // Ignore initial empty value
//             .receive(on: DispatchQueue.main)
//             .assign(to: &$userInput) // Use your ViewModel's @Published var here
//
//         // Handle errors from the manager
//         voiceInputManager.$error
//              .dropFirst()
//              .receive(on: DispatchQueue.main)
//              .sink { [weak self] errorMsg in
//                   self?.voiceErrorMessage = errorMsg
//                   self?.showVoiceErrorAlert = (errorMsg != nil)
//              }
//              .store(in: &cancellables) // Store subscription if using Combine
//         ```
//
// 3.  Main Chat View (`View`):
//     *   Pass the necessary state and the `voiceInputManager` instance to `VoiceInputAreaView`:
//         ```swift
//         VoiceInputAreaView(
//             userInput: $viewModel.userInput, // Binding to ViewModel's state
//             isProcessing: viewModel.isGeminiProcessing, // Pass processing state
//             placeholder: "Ask Gemini...",
//             sendMessageAction: {
//                 viewModel.sendMessage() // Call your ViewModel's send action
//             },
//             voiceManager: viewModel.voiceInputManager // Pass the manager instance
//         )
//         // Apply your card styling here (background, cornerRadius, shadow, padding)
//         .background(.regularMaterial)
//         .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
//         .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
//         .padding(.horizontal)
//         .padding(.bottom, 8)
//         ```
//     *   Add UI for selecting the mode (e.g., a Picker bound to `viewModel.selectedVoiceMode`).
//     *   Add an `.alert` modifier to present errors based on `viewModel.showVoiceErrorAlert` and `viewModel.voiceErrorMessage`.
//
// 4.  Send Message Action: In your `viewModel.sendMessage()` function, remember to clear the `userInput` after successfully sending the message.
//*/
