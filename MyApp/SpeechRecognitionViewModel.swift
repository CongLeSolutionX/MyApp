////
////  SpeechRecognitionViewModel.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//// SpeechRecognitionViewModel.swift
//import Foundation
//import Speech
//import AVFoundation
//import Combine // For @Published
//
//// Protocol to define the actions that can be performed based on speech input
//protocol SpeechCommandHandler {
//    func handleVoiceCommand(_ command: String)
//}
//
//@MainActor // Ensure UI updates happen on the main thread
//class SpeechRecognitionViewModel: ObservableObject {
//
//    // MARK: - Published Properties for UI Binding
//    @Published var isListening = false
//    @Published var transcribedText: String = ""
//    @Published var statusMessage: String = "Tap the mic to start speaking."
//    @Published var micLevel: Float = 0.0 // For visual feedback (optional)
//    @Published var hasError: Bool = false
//
//    // MARK: - Speech Recognition Components
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Use appropriate locale
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine()
//
//    // MARK: - Audio Session Management
//    private let audioSession = AVAudioSession.sharedInstance()
//
//    // MARK: - State & Timers
//    private var inputNode: AVAudioInputNode? // Store input node reference
//    private var micLevelTimer: Timer?
//
//    // MARK: - Command Handling
//    // Make the handler weak to avoid retain cycles if it holds a reference back to the view model
//    var commandHandler: SpeechCommandHandler?
//
//    // MARK: - Initialization and Setup
//    init(commandHandler: SpeechCommandHandler? = nil) {
//        self.commandHandler = commandHandler
//        requestAuthorization()
//        setupRecognizerDelegate() // Setup delegate to monitor availability
//    }
//
//    deinit {
//        //stopListening() // Clean up resources
//        micLevelTimer?.invalidate()
//    }
//
//    private func setupRecognizerDelegate() {
//        speechRecognizer?.delegate = self // Requires conforming to SFSpeechRecognizerDelegate
//    }
//
//    // MARK: - Permissions
//    func requestAuthorization() {
//        // Request Speech Recognition authorization
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            DispatchQueue.main.async { // Update UI on main thread
//                switch authStatus {
//                case .authorized:
//                    self.statusMessage = "Speech recognition authorized. Tap mic."
//                    self.hasError = false
//                case .denied:
//                    self.statusMessage = "Speech recognition denied. Please enable in Settings."
//                    self.hasError = true
//                case .restricted:
//                    self.statusMessage = "Speech recognition restricted on this device."
//                    self.hasError = true
//                case .notDetermined:
//                    self.statusMessage = "Speech recognition not yet authorized."
//                    self.hasError = false // Not an error yet, just needs request
//                @unknown default:
//                    self.statusMessage = "Unknown speech authorization status."
//                    self.hasError = true
//                }
//            }
//        }
//
//        // Request Microphone access
//        audioSession.requestRecordPermission { [unowned self] allowed in
//            DispatchQueue.main.async {
//                if !allowed {
//                    self.statusMessage = "Microphone access denied. Please enable in Settings."
//                    self.hasError = true
//                }
//                // You might combine status messages or prioritize one if both denied
//            }
//        }
//    }
//
//    // MARK: - Core Listening Logic
//    func toggleListening() {
//        guard !hasError else {
//            print("Cannot start listening due to previous error or permissions issue.")
//            // Optionally, trigger requestAuth again or guide user
//            requestAuthorization() // Re-check/re-request permissions
//            return
//        }
//
//        if audioEngine.isRunning {
//            stopListening()
//        } else {
//            do {
//                try startListening()
//                statusMessage = "Listening... Speak now!"
//                isListening = true
//            } catch {
//                print("Error starting listening: \(error)")
//                statusMessage = "Error starting listening: \(error.localizedDescription)"
//                hasError = true
//                isListening = false
//                // Reset maybe needed here depending on error type
//            }
//        }
//    }
//
//    private func startListening() throws {
//        // 1. Cancel any previous task
//        if let recognitionTask = recognitionTask {
//            recognitionTask.cancel()
//            self.recognitionTask = nil
//        }
//        transcribedText = "" // Reset text
//
//        // 2. Configure Audio Session
//        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//
//        // 3. Prepare Recognition Request
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
//        }
//        recognitionRequest.shouldReportPartialResults = true // Get live results
//
//        // Keep speech recognition data on device
//        if #available(iOS 13, *) {
//             recognitionRequest.requiresOnDeviceRecognition = false // Set to true if you want on-device only (check availability first)
//        }
//
//        // 4. Get Audio Input Node
//        inputNode = audioEngine.inputNode // Assign to stored property
//
//        // 5. Create Recognition Task
//        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//             guard let self = self else { return }
//             var isFinal = false
//
//             if let result = result {
//                self.transcribedText = result.bestTranscription.formattedString
//                isFinal = result.isFinal
//                self.hasError = false // Reset error if we get a result
//                 // Print("Partial Transcription: \(self.transcribedText)")
//            }
//
//            if error != nil || isFinal {
//                // Stop audio engine and processing
//                self.audioEngine.stop()
//                self.inputNode?.removeTap(onBus: 0) // Use stored property
//                self.recognitionRequest = nil
//                self.recognitionTask = nil
//
//                 DispatchQueue.main.async { // Ensure UI updates on main thread
//                    self.isListening = false
//                    self.micLevelTimer?.invalidate()
//                    self.micLevel = 0.0
//
//                    if let error = error {
//                        self.statusMessage = "Recognition Error: \(error.localizedDescription)"
//                        print("Recognition Error: \(error.localizedDescription)")
//                        self.hasError = true
//                    } else if isFinal {
//                        self.statusMessage = "Processing complete. Tap mic again."
//                        // --- HERE: Handle the final command ---
//                        print("Final Command: \(self.transcribedText)")
//                        self.commandHandler?.handleVoiceCommand(self.transcribedText)
//                        // --------------------------------------
//                    } else {
//                        self.statusMessage = "Tap the mic to start speaking." // Reset if stopped manually
//                    }
//                }
//                // Deactivate audio session when done
//                do {
//                    try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
//                } catch {
//                    print("Audio Session error on deactivation: \(error)")
//                }
//            }
//        }
//
//        // 6. Configure Audio Engine Input
//        let recordingFormat = inputNode?.outputFormat(forBus: 0) // Use stored property
//        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//            self.recognitionRequest?.append(buffer)
//
//            // --- Mic Level Calculation (Optional) ---
//             let channelData = buffer.floatChannelData?[0]
//             let channelDataValue = UnsafeMutablePointer<Float>(channelData)
//             let channelDataValueArray = stride(from: 0,
//                                               to: Int(buffer.frameLength),
//                                                by: buffer.stride).map{ channelDataValue![$0] }
//            let rms = sqrt(channelDataValueArray.map{ $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
//            let avgPower = 20 * log10(rms)
//            let meterLevel = self.scaledPower(power: avgPower)
//
//            DispatchQueue.main.async {
//                self.micLevel = meterLevel
//            }
//            // -----------------------------------------
//        }
//
//        // 7. Start Audio Engine
//        audioEngine.prepare()
//        try audioEngine.start()
//
//        // Start mic level timer
//        startMicLevelTimer()
//    }
//
//    func stopListening() {
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            inputNode?.removeTap(onBus: 0) // Clean up tap
//            recognitionRequest?.endAudio() // Explicitly mark end of audio
//            recognitionTask?.finish() // Indicate task is finishing
//            statusMessage = "Stopping listener..."
//            isListening = false
//            micLevelTimer?.invalidate()
//            micLevel = 0.0
//            print("Stopped listening manually.")
//        }
//        // Deactivate audio session
//        do {
//            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
//        } catch {
//            print("Audio Session error on deactivation: \(error)")
//        }
//    }
//
//    // Optional: Reset state if needed
//    func reset() {
//        stopListening()
//        transcribedText = ""
//        statusMessage = "Tap the mic to start speaking."
//        hasError = false
//        micLevel = 0.0
//    }
//
//    // MARK: - Mic Level Helpers (Optional Visual Feedback)
//    private func startMicLevelTimer() {
//        micLevelTimer?.invalidate()
//        micLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//             guard let self = self, self.isListening else {
//                 self?.micLevel = 0.0 // Reset if not listening
//                 return
//             }
//             // The actual level update happens in the installTap block
//        }
//    }
//
//    // Helper to scale audio power to 0.0-1.0 range
//    private func scaledPower(power: Float) -> Float {
//        guard power.isFinite else { return 0.0 }
//        let minDb: Float = -80.0 // Adjust based on testing
//        if power < minDb { return 0.0 }
//        if power >= 0.0 { return 1.0 }
//        let scaled = (abs(minDb) - abs(power)) / abs(minDb)
//        return max(0.0, min(1.0, scaled)) // Clamp between 0 and 1
//    }
//}
//
//// MARK: - SFSpeechRecognizerDelegate Conformance
//extension SpeechRecognitionViewModel: SFSpeechRecognizerDelegate {
//    nonisolated func isEqual(_ object: Any?) -> Bool {
//        return true
//    }
//    
//    var hash: Int {
//        return 0
//    }
//    
//    var superclass: AnyClass? {
//        return nil
//    }
//    
//    nonisolated func `self`() -> Self {
//        return self
//    }
//    
//    nonisolated func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    nonisolated func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    nonisolated func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    nonisolated func isProxy() -> Bool {
//        return true
//    }
//    
//    nonisolated func isKind(of aClass: AnyClass) -> Bool {
//        return true
//    }
//    
//    nonisolated func isMember(of aClass: AnyClass) -> Bool {
//        return true
//    }
//    
//    nonisolated func conforms(to aProtocol: Protocol) -> Bool {
//        return true
//    }
//    
//    nonisolated func responds(to aSelector: Selector!) -> Bool {
//        return true
//    }
//    
//    var description: String {
//        return ""
//    }
//    
//     nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//         Task { @MainActor in // Switch back to main actor for UI updates
//             if available {
//                 self.statusMessage = "Speech recognition available. Tap mic."
//                 self.hasError = false
//             } else {
//                 self.statusMessage = "Speech recognition not currently available."
//                 self.hasError = true
//                 // Consider stopping listening if it becomes unavailable mid-session
//                 if self.isListening {
//                     self.stopListening()
//                 }
//             }
//         }
//    }
//}
