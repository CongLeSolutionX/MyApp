////
////  EnhancedChatView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
////
////  EnhancedChatView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//// https://huggingface.co/argmaxinc/whisperkit-coreml/tree/main
////
////  EnhancedChatView.swift
////  MyApp // Assumed App Name
////
////  Created by Cong Le on 4/18/25 // Original Creation Date
////  Updated by AI Assistant on [Current Date] to integrate WhisperKit concepts
////
////  Description: A SwiftUI chat view supporting multiple AI backends,
////               including a placeholder local CoreML model, simulated API models,
////               and integrated concepts for WhisperKit voice transcription input.
////
//import SwiftUI
//import CoreML
//import WhisperKit
//
//// MARK: - PLACEHOLDER: WhisperKit Reference (If WhisperKit is not imported)
//// Define minimal stubs if WhisperKit isn't available, allowing the code to compile.
//// Replace these with actual WhisperKit types if the framework is added.
//#if !canImport(WhisperKit)
//struct WhisperKitConfig {
//    // Add properties based on actual WhisperKitConfig if known, otherwise empty.
//}
//struct WhisperKit {
//    enum ModelState: CustomStringConvertible {
//        case unloaded, loading, loaded, error, prewarming, downloading, downloaded // Added states from ContentView
//        var description: String {
//            switch self {
//                case .unloaded: return "Model Unloaded"
//                case .loading: return "Loading Model..."
//                case .loaded: return "Model Ready"
//                case .error: return "Model Error"
//                case .prewarming: return "Optimizing Model..." // Changed description
//                case .downloading: return "Downloading..."
//                case .downloaded: return "Downloaded"
//            }
//        }
//    }
//    var modelState: ModelState = .unloaded
//    let audioProcessor = AudioProcessor() // Assume AudioProcessor exists
//    struct AudioProcessor {
//        var audioSamples: [Float] = []
//        func startRecordingLive(inputDeviceID _: Any? = nil, bufferCallback _: @escaping (Int) -> Void) throws {}
//        func stopRecording() {}
//        static func requestRecordPermission() async -> Bool { return false } // Default to false
//    }
//    // Placeholder for init
//    init(config _: WhisperKitConfig? = nil) async throws {
//        // Simulate async init
//        print("⚠️ WhisperKit Stub Initialized")
//    }
//    // Placeholder for static methods
//    static func recommendedModels() -> (default: String, supported: [String], disabled: [String]) {
//        return (default: "PlaceholderBase", supported: ["PlaceholderBase", "PlaceholderTiny"], disabled: [])
//    }
//    static var sampleRate: Int = 16000 // Common sample rate
//    // Placeholder for transcribe method
//    func transcribe(audioArray _: [Float], decodeOptions _: Any?, callback _: Any?) async throws -> [StubTranscriptionResult] {
//        print("⚠️ WhisperKit Stub: Simulating transcription...")
//        try await Task.sleep(nanoseconds: 1_500_000_000) // Simulate work
//        return [StubTranscriptionResult(text: "Simulated text from WhisperKit stub.")]
//    }
//    // Placeholder result struct
//    struct StubTranscriptionResult { var text: String }
//    // Add other necessary stubs based on ContentView usage...
//    func loadModels() async throws {}
//    func prewarmModels() async throws {}
//    static func download(variant _: String, from _: String, progressCallback _: ((Progress) -> Void)?) async throws -> URL? { return nil }
//    var modelFolder: URL? = nil
//}
//typealias TranscriptionResult = WhisperKit.StubTranscriptionResult // Alias for stub
//struct DecodingOptions {} // Placeholder
//// --- End of WhisperKit Placeholders ---
//#warning("WhisperKit not found. Using placeholder stubs. Transcription will be simulated.")
//#endif // !canImport(WhisperKit)
//
//// MARK: - Data Models
//struct Message: Identifiable, Equatable {
//    let id = UUID()
//    var text: String // Made var for API streaming and potential Whisper edits
//    let isUser: Bool
//    let timestamp: Date = Date()
//    var sourceModel: AIModel? = nil // Which AI generated the response
//    var isLoading: Bool = false // Used for the typing indicator bubble logic
//    var error: String? = nil
//
//    // Enum uniquely identifying supported AI models
//    enum AIModel: String, CaseIterable, Identifiable, Equatable {
//        case localCoreML = "CoreML (Local/Placeholder)" // Clarified it's a placeholder
//        case chatGPT_3_5 = "ChatGPT 3.5 (API Sim)"   // Clarified simulation
//        case chatGPT_4 = "ChatGPT 4 (API Sim)"       // Clarified simulation
//        // Potentially add a WhisperKit model type if responses differ, but here it's for input
//
//        var id: String { self.rawValue } // Conform to Identifiable for Picker
//
//        // System image representation for each model
//        var systemImageName: String {
//            switch self {
//            case .localCoreML: return "cpu" // Chip icon
//            case .chatGPT_3_5: return "cloud" // Cloud icon
//            case .chatGPT_4: return "sparkles" // Advanced/powerful icon
//            }
//        }
//    }
//}
//
//// MARK: - Enhanced Chat View with WhisperKit Integration Concepts
//struct EnhancedChatView: View {
//    // MARK: Chat State
//    @State private var messages: [Message] = [
//        Message(text: "Welcome! Ask the selected AI, or use the microphone to dictate your message with WhisperKit.", isUser: false, sourceModel: .localCoreML),
//    ]
//    @State private var newMessageText: String = "" // Bound to the TextField
//    @State private var isWaitingForResponse: Bool = false // Tracks if waiting for *Chat AI* response
//    @State private var selectedModel: Message.AIModel = .localCoreML // Which *Chat AI* to use
//    @State private var currentError: String? = nil     // General chat/API/CoreML errors
//
//    // MARK: CoreML Specific State (Placeholder Model)
//    @State private var coreMLModel: SimpleChatResponder? = nil // Placeholder class from original code
//    @State private var coreMLModelLoadError: String? = nil // Specific error for the placeholder CoreML model
//    private let coreMLInputLength = 64 // Specific to the placeholder model
//
//    // MARK: WhisperKit Integration State
//    @State private var whisperKit: WhisperKit? = nil // The WhisperKit instance
//    @State private var whisperModelState: ModelState = .unloaded // Tracks WhisperKit model state
//    @State private var whisperModelLoadError: String? = nil // Specific error for WhisperKit loading
//    @State private var whisperLoadingProgress: Float = 0.0 // Progress for WhisperKit model downloading/loading
//    @State private var isRecording: Bool = false       // Tracks if WhisperKit is actively recording audio
//    // TODO: Add @AppStorage for selected Whisper model, repo, compute units etc. if needed
//    @AppStorage("whisperSelectedModel") private var whisperSelectedModel: String = WhisperKit.recommendedModels().default
//
//    // MARK: API Streaming Simulation State (Original Code)
//    @State private var streamTimer: Timer?
//    @State private var currentlyStreamingMessageId: UUID?
//    @State private var fullStreamingResponse: String = ""
//    @State private var streamIndex: Int = 0
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // --- Top Bar: Model Selectors and Status ---
//            VStack(spacing: 4) {
//                ModelSelectorView(selectedModel: $selectedModel) // Selector for *Chat AI*
//                 WhisperKitStatusView( // Dedicated view for WhisperKit status
//                    modelState: $whisperModelState,
//                    loadingProgress: $whisperLoadingProgress,
//                    loadError: $whisperModelLoadError,
//                    selectedWhisperModel: $whisperSelectedModel, // Pass binding if allowing selection
//                    loadAction: loadWhisperKitModel // Pass the action to trigger loading
//                )
//            }
//            .padding(.bottom, 5)
//
//            Divider()
//
//            // --- Chat Message Area ---
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach($messages) { $message in
//                            MessageBubble(message: $message)
//                                .id(message.id)
//                        }
//                        // Show typing indicator only if waiting for CHAT response, not for recording
//                        if isWaitingForResponse && !isRecording {
//                            TypingIndicatorBubble()
//                                .id("typingIndicator")
//                                .transition(.opacity)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top)
//                }
//                .onChange(of: messages.count) { scrollToBottom(proxy: scrollViewProxy) }
//                .onChange(of: isWaitingForResponse) { if isWaitingForResponse && !isRecording { scrollToBottom(proxy: scrollViewProxy, id: UUID()) } } // Modified condition
//            }
//
//            // --- Error Display Area ---
//            // Display WhisperKit load error OR regular chat errors
//            if let error = currentError ?? whisperModelLoadError { // Prioritize chat error, fallback to Whisper load error
//                ErrorDisplayView(errorMessage: error) {
//                    currentError = nil
//                    // Don't clear whisperModelLoadError automatically, user needs to retry loading
//                }
//                .animation(.default, value: currentError ?? whisperModelLoadError)
//            }
//
//            // --- Input Area ---
//            HStack(alignment: .bottom) {
//                // Text Input Field
//                TextField("Ask \(selectedModel.rawValue)... or use Mic", text: $newMessageText, axis: .vertical)
//                    .textFieldStyle(.plain)
//                    .padding(10)
//                    .background(Color.secondary.opacity(0.15))
//                    .cornerRadius(18)
//                    .lineLimit(1...5)
//                   .disabled(isWaitingForResponse || isRecording || whisperModelState != .loaded) // Disable if busy or WhisperKit not ready
//
//                // Microphone Button (WhisperKit)
//                Button {
//                    toggleWhisperRecording()
//                } label: {
//                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(micButtonColor())
//                         .overlay( // Subtle overlay during recording
//                             isRecording ? Circle().stroke(Color.red.opacity(0.5), lineWidth: 2).blur(radius: 3) : nil
//                         )
//                }
//                 .disabled(isWaitingForResponse || whisperModelLoadError != nil || whisperModelState == .loading || whisperModelState == .unloaded || whisperModelState == .prewarming || whisperModelState == .downloading) // Disable if chat is busy OR WhisperKit has errors/is unusable
//
//                // Send Button (Chat AI)
//                Button {
//                    // If recording, stop recording first (user might tap send to finish dictation)
//                    if isRecording {
//                         stopWhisperRecording() // Stop recording will trigger transcription
//                    } else {
//                        sendMessage() // Send text message to selected Chat AI
//                    }
//                } label: {
//                    Image(systemName: sendButtonIcon())
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(sendButtonColor())
//                }
//                 .disabled((newMessageText.isEmpty && !isRecording) || isWaitingForResponse) // Disable if no text AND not recording, or if waiting for chat response
//
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//            .background(.thinMaterial) // Use material for subtle visual separation
//        }
//        .background(Color.black.ignoresSafeArea())
//        .foregroundColor(.white)
//        .onAppear {
//             loadCoreMLModel() // Attempt to load placeholder model
//             loadWhisperKitModel() // Attempt to load WhisperKit model
//        }
//        .onDisappear {
//            stopStreaming() // Clean up API simulation timer
//             // Consider stopping WhisperKit recording/audio processing if needed
//             whisperKit?.audioProcessor.stopRecording()
//        }
//    }
//
//    // MARK: - UI Helper Functions (Button States)
//
//    func micButtonColor() -> Color {
//        if whisperModelState != .loaded { return .gray.opacity(0.5) } // Disabled appearance if not loaded
//        if isRecording { return .red }
//        if isWaitingForResponse { return .gray } // Disable mic visually if chat is busy
//        return .yellow // Default enabled color
//    }
//
//     func sendButtonIcon() -> String {
//         if isRecording { return "stop.circle.fill" } // Treat send as "stop recording" if active
//         return "arrow.up.circle.fill"
//     }
//
//    func sendButtonColor() -> Color {
//        if isWaitingForResponse { return .gray } // Disabled if waiting for chat response
//        if isRecording { return .red } // Show as "stop" color
//        if newMessageText.isEmpty { return .gray } // Disabled if no text
//        return .yellow // Enabled color
//    }
//
//    // MARK: - WhisperKit Logic Integration
//
//    // --- Load WhisperKit Model ---
//    func loadWhisperKitModel() {
////        guard whisperKit == nil || whisperModelState == .unloaded || whisperModelState == .error  else {
////            print("WhisperKit already loaded or in loading process: \(whisperModelState)")
////            return
////        }
//
//        whisperModelState = .loading
//        whisperLoadingProgress = 0.0
//        whisperModelLoadError = nil
//
//        // --- Simulate Loading Process (Based on ContentView logic) ---
//        // In a real integration, replace this simulation with actual WhisperKit calls
//        Task(priority: .userInitiated) {
//            do {
//                print("Attempting to initialize WhisperKit...")
//                // Use actual config if needed: WhisperKitConfig(...)
//                let kit = try await WhisperKit() // Replace with actual init if config needed
//                await MainActor.run { self.whisperKit = kit } // Store the instance
//
//                print("WhisperKit Initialized (Stub). Simulating download/load for \(whisperSelectedModel)...")
//
//                // Simulate Download (if not local - check localModels equivalent)
//                if Bool.random() { // Simulate needing download
//                     await MainActor.run { whisperModelState = .downloading }
//                     var progress: Float = 0.0
//                     while progress < 0.7 { // Simulate download progress up to 70% (specialization ratio)
//                         try await Task.sleep(nanoseconds: 200_000_000)
//                         progress += Float.random(in: 0.05...0.15)
//                         await MainActor.run { whisperLoadingProgress = min(progress, 0.7) }
//                     }
//                     print("Simulated Download Complete.")
//                     await MainActor.run { whisperModelState = .downloaded }
//                }
//
//                // Simulate Prewarming
//                await MainActor.run {
//                    whisperModelState = .prewarming
//                     whisperLoadingProgress = 0.7 // Set progress for prewarm start
//                }
//                print("Simulating Prewarming...")
//                try await Task.sleep(nanoseconds: UInt64(Double.random(in: 1.5...3.0) * 1_000_000_000)) // Simulate prewarm time
//                // try await whisperKit?.prewarmModels() // Actual call
//
//                // Simulate Loading
//                await MainActor.run {
//                     whisperModelState = .loading
//                     whisperLoadingProgress = 0.9 // Set progress after prewarm
//                }
//                print("Simulating Model Loading...")
//                try await Task.sleep(nanoseconds: UInt64(Double.random(in: 1.0...2.0) * 1_000_000_000)) // Simulate load time
//                // try await whisperKit?.loadModels() // Actual call
//
//                print("WhisperKit Model '\(whisperSelectedModel)' Loaded (Simulated).")
//                await MainActor.run {
//                    whisperModelState = .loaded
//                    whisperLoadingProgress = 1.0
//                }
//
//            } catch {
//                print("❌ Error loading WhisperKit model (Simulated): \(error)")
//                await MainActor.run {
////                    whisperModelState = .error
//                    whisperModelLoadError = "Failed to load WhisperKit: \(error.localizedDescription)"
//                    whisperLoadingProgress = 0.0
//                    self.whisperKit = nil // Ensure instance is nil on error
//                }
//            }
//        }
//    }
//
//    // --- Toggle WhisperKit Recording ---
//    func toggleWhisperRecording() {
//        guard whisperModelState == .loaded else {
//            print("WhisperKit not ready. State: \(whisperModelState)")
//            return
//        }
//        isRecording.toggle()
//
//        if isRecording {
//            startWhisperRecording()
//        } else {
//            stopWhisperRecording()
//        }
//    }
//
//    // --- Start WhisperKit Recording ---
//    func startWhisperRecording() {
//        guard let kit = whisperKit else {
//            print("ERROR: WhisperKit instance is nil.")
//            isRecording = false
//            return
//        }
//         
//         // Clear previous transcription result and any chat errors
//         newMessageText = ""
//         currentError = nil
//
//        print("Starting WhisperKit recording...")
//        Task(priority: .userInitiated) {
//            let permissionGranted = await AudioProcessor.requestRecordPermission()
//            guard permissionGranted else {
//                print("Microphone permission denied.")
//                await MainActor.run {
//                    currentError = "Microphone permission needed."
//                    isRecording = false
//                }
//                return
//            }
//
//            do {
//                // Use actual deviceID logic from ContentView if on macOS and needed
//                try kit.audioProcessor.startRecordingLive { bufferSize in
//                    // Callback for buffer updates - can be used for UI like energy levels
//                    // print("Audio buffer updated, size: \(bufferSize)")
//                    // TODO: Update UI based on buffer if desired (visualizer)
//                }
//                 await MainActor.run {
//                     print("WhisperKit Recording Started.")
//                 }
//
//            } catch {
//                print("❌ Failed to start WhisperKit recording: \(error)")
//                await MainActor.run {
//                    currentError = "Mic Start Failed: \(error.localizedDescription)"
//                    isRecording = false
//                }
//            }
//        }
//    }
//
//    // --- Stop WhisperKit Recording & Transcribe ---
//    func stopWhisperRecording() {
//        guard let kit = whisperKit else {
//            print("ERROR: WhisperKit instance is nil.")
//            isRecording = false
//            return
//        }
//        print("Stopping WhisperKit recording...")
//        kit.audioProcessor.stopRecording()
//        print("WhisperKit Recording Stopped. Starting transcription simulation...")
//        // Start transcription immediately after stopping
//        transcribeFinalBuffer()
//       
//        // Update state *after* initiating transcription, but before result
//        Task { @MainActor in
//             self.isRecording = false // Update UI immediately
//        }
//    }
//
//    // --- Transcribe Final Audio Buffer (Simulated) ---
//    func transcribeFinalBuffer() {
//        guard let kit = whisperKit, !kit.audioProcessor.audioSamples.isEmpty else {
//            print("No audio samples recorded or WhisperKit is nil.")
//             // If stopped with no audio, just ensure recording state is false
//             Task { @MainActor in self.isRecording = false }
//            return
//        }
//
//        let samplesToTranscribe = kit.audioProcessor.audioSamples
//        // kit.audioProcessor.audioSamples = [] // Clear samples after copying
//
//        print("Transcribing \(samplesToTranscribe.count) audio samples (Simulated)...")
//        // Show a temporary "Transcribing..." state maybe?
//        let tempMessagePlaceholder = "Transcribing audio..."
//        self.newMessageText = tempMessagePlaceholder
//
//        Task(priority: .userInitiated) {
//            do {
//                // --- ACTUAL TRANSCRIPTION CALL ---
//                // let options = DecodingOptions(...) // Configure options based on AppStorage/settings
//                // let results = try await kit.transcribe(audioArray: samplesToTranscribe, decodeOptions: options, callback: nil)
//                // guard let firstResult = results.first else { throw NSError(...) }
//                // let transcribedText = firstResult.text
//
//                // --- SIMULATED TRANSCRIPTION ---
//                let results = try await kit.transcribe(audioArray: [11.0, 22.9, 33], decodeOptions: nil, callback: nil) // Using stubbed version
//                guard let firstResult = results.first else {
//                     throw CocoaError(.featureUnsupported) // Simulate no result
//                }
//                let transcribedText = firstResult.text
//                // --------------------------------
//
//                print("Simulated Transcription Result: '\(transcribedText)'")
//                await MainActor.run {
//                    // Update the *main* text field with the result
//                     self.newMessageText = transcribedText
//                     // Optionally AUTO-SEND after transcribe: sendMessage()
//                }
//
//            } catch {
//                print("❌ Transcription Failed (Simulated): \(error)")
//                await MainActor.run {
//                    self.currentError = "Transcription failed: \(error.localizedDescription)"
//                     // Reset text field if transcription failed
//                     if self.newMessageText == tempMessagePlaceholder {
//                         self.newMessageText = ""
//                     }
//                }
//            }
//            // Regardless of success/failure, ensure recording state is finally off
//            await MainActor.run {
//                self.isRecording = false
//            }
//        }
//    }
//
//    // MARK: - CoreML Logic (Placeholder Model - Original Code)
//    func loadCoreMLModel() {
//        guard coreMLModel == nil && coreMLModelLoadError == nil else { return }
//        do {
//            coreMLModel = try SimpleChatResponder(configuration: MLModelConfiguration())
//            print("Placeholder CoreML Model 'SimpleChatResponder' loaded.")
//        } catch {
//            print("Error loading Placeholder CoreML model: \(error)")
//            coreMLModelLoadError = "Failed to load local AI: \(error.localizedDescription)"
//            coreMLModel = nil
//        }
//    }
//
//    func tokenizeAndPad(text: String, maxLength: Int) -> (inputIds: MLMultiArray?, positionIds: MLMultiArray?, error: String?) {
//        // --- Using STUB implementation from original code ---
//        print("⚠️ STUB: Tokenizing '\(text)' for placeholder CoreML.")
//        let shape = [1, NSNumber(value: maxLength)]
//        guard let inputIdsArray = try? MLMultiArray(shape: shape, dataType: .double),
//              let positionIdsArray = try? MLMultiArray(shape: shape, dataType: .double) else {
//            return (nil, nil, "Failed to create placeholder MLMultiArray inputs.")
//        }
//        for i in 0..<maxLength {
//            inputIdsArray[i] = 0.0
//            positionIdsArray[i] = NSNumber(value: Double(i))
//        }
//        return (inputIdsArray, positionIdsArray, nil)
//    }
//
//    func decodeLogits(logits: MLMultiArray) -> String {
//        // --- Using STUB implementation from original code ---
//        print("⚠️ STUB: Decoding output logits from placeholder CoreML.")
//        let shapeDescription = logits.shape.map { $0.stringValue }.joined(separator: "x")
//        return "[CoreML Responded - Logits Shape: \(shapeDescription). Decoding not implemented.]"
//    }
//
//    func performCoreMLPrediction(text: String) {
//        // --- Using implementation from original code ---
//        guard let model = coreMLModel else {
//            currentError = "Local AI model (placeholder) is not loaded."
//            isWaitingForResponse = false
//            return
//        }
//        let tokenizationResult = tokenizeAndPad(text: text, maxLength: coreMLInputLength)
//        guard let inputIds = tokenizationResult.inputIds,
//              let positionIds = tokenizationResult.positionIds,
//              tokenizationResult.error == nil else {
//            currentError = "CoreML Input Error: \(tokenizationResult.error ?? "Tokenization failed.")"
//            isWaitingForResponse = false
//            return
//        }
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                 let input = SimpleChatResponderInput(input_ids: inputIds, position_ids: positionIds)
//                 print("🤖 Performing Placeholder CoreML prediction...")
//                 let predictionOutput = try model.prediction(input: input)
//                 print("🤖 Placeholder CoreML prediction successful.")
//                 let responseText = decodeLogits(logits: predictionOutput.output_logits)
//                DispatchQueue.main.async {
//                    addMessage(text: responseText, isUser: false, model: .localCoreML)
//                    isWaitingForResponse = false
//                }
//            } catch {
//                print("❌ Placeholder CoreML Prediction Error: \(error)")
//                DispatchQueue.main.async {
//                    currentError = "Local AI (Placeholder) failed: \(error.localizedDescription)"
//                    isWaitingForResponse = false
//                }
//            }
//        }
//    }
//
//    // MARK: - Message Handling (Chat AI)
//    func addMessage(text: String, isUser: Bool, model: Message.AIModel? = nil, error: String? = nil) {
//        let newMessage = Message(text: text, isUser: isUser, sourceModel: model, error: error)
//        // Avoid adding empty system messages unless it's an intended placeholder
//        if isUser || !text.isEmpty || error != nil {
//             messages.append(newMessage)
//        }
//    }
//
//    func sendMessage() {
//        // Ensure WhisperKit isn't recording when sending a text message
//        guard !isRecording else {
//            print("Stop recording first before sending text.")
//            currentError = "Please stop recording before sending a text message."
//            return
//        }
//
//        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
//        stopStreaming() // Stop any ongoing API streams
//
//        let userText = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
//        addMessage(text: userText, isUser: true)
//        newMessageText = "" // Clear input AFTER adding user message
//        currentError = nil // Clear previous errors
//
//        isWaitingForResponse = true // Set waiting state for Chat response
//
//        switch selectedModel {
//        case .localCoreML:
//            // --- Uses Placeholder CoreML Logic ---
//             guard coreMLModelLoadError == nil else {
//                 currentError = "Local AI model (placeholder) failed to load. Cannot send."
//                 isWaitingForResponse = false; return // Stop waiting
//             }
//             guard coreMLModel != nil else {
//                  currentError = "Local AI model (placeholder) isn't ready."
//                  isWaitingForResponse = false; return // Stop waiting
//             }
//            performCoreMLPrediction(text: userText)
//
//        case .chatGPT_3_5, .chatGPT_4:
//            // --- Uses API Simulation Logic ---
//            let responseDelay = Double.random(in: 0.5...1.5) // Slightly faster simulation
//            DispatchQueue.main.asyncAfter(deadline: .now() + responseDelay) {
//                 // Re-check if still waiting and if model is still API
//                 guard self.isWaitingForResponse, (self.selectedModel == .chatGPT_3_5 || self.selectedModel == .chatGPT_4) else {
//                     print("State changed while waiting for API sim response.")
//                     if self.isWaitingForResponse { self.isWaitingForResponse = false } // Ensure waiting stops if model changed
//                     return
//                 }
//
//                 if userText.lowercased().contains("error") {
//                     currentError = "Simulated Error: Failed connecting to \(selectedModel.rawValue)."
//                     isWaitingForResponse = false
//                     return
//                 }
//
//                 let responseText = generateMockResponse(to: userText, model: selectedModel)
//                 let aiMessage = Message(text: "", isUser: false, sourceModel: selectedModel) // Create message with ID
//                let responseMessageId = aiMessage.id // Get ID before appending
//
//                 messages.append(aiMessage) // Add placeholder
//                 isWaitingForResponse = false // Stop *indicator*, stream starts
//                 startStreamingResponse(for: responseMessageId, fullText: responseText)
//            }
//        }
//    }
//
//    // MARK: - API Streaming Simulation (Unchanged from Original)
//     func startStreamingResponse(for messageId: UUID, fullText: String) {
//        stopStreaming() // Reset just in case
//        guard let messageIndex = messages.firstIndex(where: { $0.id == messageId }) else { return }
//
//        currentlyStreamingMessageId = messageId
//        fullStreamingResponse = fullText
//        streamIndex = 0
//        // Ensure the placeholder text is cleared *only* if it hasn't received actual streamed text yet
//         if messages[messageIndex].text.isEmpty {
//            messages[messageIndex].text = ""
//         }
//
//        streamTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
//            guard self.streamIndex < self.fullStreamingResponse.count,
//                  let currentId = self.currentlyStreamingMessageId,
//                  var msgIdx = self.messages.firstIndex(where: { $0.id == currentId }) // Needs to be var if using Binding/StateObject list
//            else {
//                self.stopStreaming()
//                return
//            }
//
//            let nextCharIndex = self.fullStreamingResponse.index(self.fullStreamingResponse.startIndex, offsetBy: self.streamIndex)
//            guard nextCharIndex < self.fullStreamingResponse.endIndex else {
//                self.stopStreaming() // Should not happen if count check is correct, but safety first
//                return
//            }
//            // Append character using indices for safety
//              let charToAdd = self.fullStreamingResponse[nextCharIndex]
//            self.messages[msgIdx].text.append(charToAdd)
//            self.streamIndex += 1
//
//            // If this is the last character, stop the timer
//            if self.streamIndex == self.fullStreamingResponse.count {
//                self.stopStreaming()
//            }
//        }
//    }
//
//    func stopStreaming() {
//        streamTimer?.invalidate()
//        streamTimer = nil
//        currentlyStreamingMessageId = nil
//        fullStreamingResponse = ""
//        streamIndex = 0
//    }
//
//    func generateMockResponse(to input: String, model: Message.AIModel) -> String {
//         let modelPrefix = "" // More natural without prefix for streaming
//         let lowercasedInput = input.lowercased()
//        let shortInputIndicator = input.count < 15 ? "'\(input)'" : "your message" // Reference short input
//
//        if lowercasedInput.contains("hello") || lowercasedInput.contains("hi") {
//             return "\(modelPrefix)Hi there! 👋 This is a simulated response from \(model.rawValue)."
//         } else if lowercasedInput.contains("coreml") {
//             return "\(modelPrefix)You mentioned CoreML. While I'm simulating \(model.rawValue), WhisperKit *uses* CoreML models for its local transcription."
//         } else if lowercasedInput.contains("whisper") {
//             return "\(modelPrefix)Ah, WhisperKit! It's great for turning speech into text, like using the mic button here. This chat response itself is simulated via \(model.rawValue)."
//         } else if lowercasedInput.contains("stream") && model != .localCoreML {
//             return "\(modelPrefix)Streaming is a nice touch for APIs! It makes the response feel more immediate, character by character."
//         } else {
//             return "\(modelPrefix)This is a simulated \(model.rawValue) reply about \(shortInputIndicator). In a real scenario, I'd provide a more relevant answer."
//         }
//    }
//
//    // MARK: - Utilities
//    func scrollToBottom(proxy: ScrollViewProxy, id: UUID? = nil) {
//        // Determine the target ID: either the provided one, the typing indicator, or the last message
//        var targetId: AnyHashable? = id // Use AnyHashable? to potentially target the typing indicator string
//        if targetId == nil {
//            if isWaitingForResponse && !isRecording {
//                 targetId = "typingIndicator" // Target the indicator if it's visible
//            } else {
//                 targetId = messages.last?.id // Otherwise, target the last message
//            }
//        }
//
//         guard let finalTargetId = targetId else { return }
//
//         DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // Short delay can help rendering catch up
//              withAnimation(.spring(duration: 0.5)) { // Smoother animation
//                 proxy.scrollTo(finalTargetId, anchor: .bottom)
//             }
//         }
//    }
//}
//
//// MARK: - Helper UI Components
//
//// --- Model Selector for Chat AI ---
//struct ModelSelectorView: View {
//    @Binding var selectedModel: Message.AIModel
//
//    var body: some View {
//        HStack {
//            Text("Chat AI:")
//                .font(.caption)
//                .foregroundColor(.gray)
//            Picker("Select Chat Model", selection: $selectedModel) {
//                ForEach(Message.AIModel.allCases) { model in
//                    Label(model.rawValue, systemImage: model.systemImageName)
//                        .tag(model)
//                }
//            }
//            .pickerStyle(.menu)
//            .accentColor(.yellow)
//            .scaleEffect(0.9) // Make picker slightly smaller
//            .padding(.leading, -8) // Reduce space
//
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 2)
//        .frame(maxWidth: .infinity, alignment: .leading) // Align left
//    }
//}
//
//// --- Status View for WhisperKit ---
//struct WhisperKitStatusView: View {
//    @Binding var modelState: ModelState
//    @Binding var loadingProgress: Float
//    @Binding var loadError: String?
//    @Binding var selectedWhisperModel: String // Assuming model name is stored
//    var loadAction: () -> Void // Action to trigger loading
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                // Status Indicator Dot
//                Circle()
//                    .fill(statusColor())
//                    .frame(width: 10, height: 10)
//                    .overlay(
//                        // Add pulsing effect during loading states
//                        (modelState == .loading || modelState == .prewarming || modelState == .downloading) ?
//                        Circle().stroke(statusColor(), lineWidth: 1).scaleEffect(1.5).opacity(0.5).animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: modelState)
//                        : nil
//                    )
//
//                 // Status Text & Model Name
//                Text("WhisperKit (\(modelName(selectedWhisperModel))): \(modelState.description)")
//                    .font(.caption)
////                    .foregroundColor(statusTextColor())
//                    .lineLimit(1)
//
//                  Spacer()
//
//                 // Load/Retry Button (only show when needed)
////                if modelState == .unloaded || modelState == .error {
////                    Button(modelState == .error ? "Retry Load" : "Load Model") {
////                        loadAction()
////                    }
////                    .font(.caption)
////                    .buttonStyle(.bordered)
////                    .tint(.yellow)
////                    .padding(.trailing, 4)
////                }
//            }
//
//            // Progress Bar (only show during loading states)
//            if (modelState == .loading || modelState == .prewarming || modelState == .downloading) && loadingProgress < 1.0 {
//                ProgressView(value: loadingProgress)
//                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
//                    .scaleEffect(x: 1, y: 0.5, anchor: .center) // Make it thinner
//                    .padding(.top, -2) // Adjust spacing
//                    .transition(.opacity)
//            }
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 2)
//        .animation(.default, value: modelState) // Animate changes
//        .animation(.linear(duration: 0.2), value: loadingProgress)
//    }
//
//    // Helper to determine status color
//     private func statusColor() -> Color {
//        switch modelState {
//        case .unloaded: return .gray
//        case .loading, .prewarming, .downloading, .downloaded: return .orange
//        case .loaded: return .green
//        case .unloading:
//            return .yellow
//        case .prewarmed:
//            return .red
//        }
//    }
//
//    // Helper for text color contrast
////    private func statusTextColor() -> Color {
////        modelState == .error ? .red : .gray
////    }
//     
//     // Helper to format model name
//     private func modelName(_ fullId: String) -> String {
//         // Attempt to extract common part like "base", "tiny" etc.
//         let parts = fullId.components(separatedBy: "/") // Handle HuggingFace format
//         if let lastPart = parts.last, lastPart.contains("whisperkit-") {
//             return lastPart.replacingOccurrences(of: "whisperkit-", with: "")
//         }
//         return fullId // Fallback to full name
//     }
//}
//
//// --- Message Bubble (Unchanged from Original) ---
//struct MessageBubble: View {
//    @Binding var message: Message // Use Binding for streaming
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            if message.isUser { Spacer(minLength: 50) } // Push user message right
//
//            // Icon for AI model (only for AI messages)
//            if !message.isUser, let model = message.sourceModel {
//                Image(systemName: model.systemImageName)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.bottom, 5)
//                    .accessibilityLabel("Model: \(model.rawValue)")
//            }
//
//            // Message Content
//            Text(message.text.isEmpty && !message.isUser && message.error == nil && message.sourceModel != .localCoreML ? "..." : message.text) // Ellipsis for streaming start
//                .padding(12)
//                .background(messageContentBackground())
//                .foregroundColor(messageContentForegroundColor()) // Dynamic text color
//                .cornerRadius(15)
//                .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading) // Allow bubble to expand
//                .overlay( // Error indicator
//                    message.error != nil ?
//                    RoundedRectangle(cornerRadius: 15).stroke(Color.red, lineWidth: 1)
//                    : nil
//                )
//                .textSelection(.enabled) // Allow text selection
//
//            if !message.isUser { Spacer(minLength: 50) } // Push AI message left
//        }
//        .animation(.easeOut(duration: 0.15), value: message.text) // Faster animation for streaming
//    }
//
//    // Helper for background
//    @ViewBuilder
//    private func messageContentBackground() -> some View {
//        if message.isUser {
//            Color.yellow // User message
//        } else if message.error != nil {
//            Color.red.opacity(0.3) // AI error
//        } else {
//            Color(white: 0.25) // Standard AI message
//        }
//    }
//
//    // Helper for text color
//    private func messageContentForegroundColor() -> Color {
//        message.isUser ? .black : .white // Ensure contrast
//    }
//}
//
//// --- Typing Indicator (Unchanged from Original) ---
//struct TypingIndicatorBubble: View {
//    @State private var scale: CGFloat = 0.5
//    let animation = Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)
//
//    var body: some View {
//        HStack(spacing: 4) {
//            ForEach(0..<3) { i in
//                Circle()
//                    .fill(Color.gray)
//                    .frame(width: 8, height: 8)
//                    .scaleEffect(scale)
//                    .animation(animation.delay(Double(i) * 0.15), value: scale)
//            }
//        }
//        .padding(12)
//        .background(Color(white: 0.25))
//        .cornerRadius(15)
//        .onAppear { scale = 1.0 }
//        .frame(maxWidth: .infinity, alignment: .leading) // Align left, match bubble width behavior
//        .transition(.opacity.combined(with: .scale(scale: 0.5, anchor: .bottomLeading)))
//        .accessibilityLabel("Assistant is typing")
//    }
//}
//
//// --- Error Display Banner (Unchanged from Original) ---
//struct ErrorDisplayView: View {
//    let errorMessage: String
//    let dismissAction: () -> Void
//
//    var body: some View {
//        HStack {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .foregroundColor(.red)
//            Text(errorMessage)
//                .font(.caption)
//                .lineLimit(2)
//                .foregroundColor(.red.opacity(0.9))
//            Spacer()
//            Button {
//                withAnimation { dismissAction() }
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray.opacity(0.8))
//            }
//        }
//        .padding(10)
//        .background(Color.red.opacity(0.1)) // Subtler background
//        .cornerRadius(8)
//        .padding(.horizontal)
//        .padding(.bottom, 5)
//        .transition(.move(edge: .bottom).combined(with: .opacity))
//    }
//}
//
//// MARK: - Placeholder CoreML Model Swift File Reference
//// This struct is used by `performCoreMLPrediction`.
//// In a real project, this would be generated by Xcode when you import a .mlmodel file.
//// Keep this placeholder definition if you don't have the actual model file imported yet.
//// If you *do* have the model, delete this struct AND the `SimpleChatResponderInput`
//// struct below, and ensure the `coreMLModel` state variable uses the generated class name.
//struct SimpleChatResponder { // Placeholder Struct
//    init(configuration: MLModelConfiguration) throws {
//        print("⚠️ Initialized Placeholder SimpleChatResponder struct.")
//    }
//
//    func prediction(input: SimpleChatResponderInput) throws -> SimpleChatResponderOutput {
//        print("⚠️ Called prediction on Placeholder SimpleChatResponder struct.")
//        // Simulate an output shape, e.g., [1, 64, VocabSize] - VocabSize is unknown here
//        let outputLogits = try! MLMultiArray(shape: [1, input.input_ids.shape[1], 5000], dataType: .double)
//        return SimpleChatResponderOutput(output_logits: outputLogits)
//    }
//}
//struct SimpleChatResponderInput { // Placeholder Input Struct
//    var input_ids: MLMultiArray
//    var position_ids: MLMultiArray
//}
//struct SimpleChatResponderOutput { // Placeholder Output Struct
//    var output_logits: MLMultiArray
//}
//
//// MARK: - Preview
//#Preview {
//    EnhancedChatView()
//        .preferredColorScheme(.dark) // Ensure preview uses dark mode
//        .tint(.yellow) // Apply tint
//}
//
