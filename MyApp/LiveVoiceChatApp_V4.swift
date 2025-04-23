////
////  LiveVoiceChatApp_V4.swift
////  MyApp
////
////  Created by Cong Le (AI Assistant) on 4/23/25.
////
////  Single-file SwiftUI Chat Demo with Takeover Voice UI
////
////  Combines Mock, OpenAI, & CoreML backends with Text & Speech I/O.
////  Implements the "Takeover Interface" VUI design concept.
////
////  Requires: Xcode 15+, iOS 17+
////
//
//import SwiftUI
//import Combine
//import Speech         // For Speech Recognition (Input)
//import AVFoundation   // For Text-to-Speech (Output) & Audio Session Management
//import CoreML         // For potential local model inference
//
//// MARK: — 1. Data Models
//
//enum ChatRole: String, Codable, Hashable {
//    case system, user, assistant
//}
//
//struct Message: Identifiable, Codable, Hashable {
//    let id: UUID
//    let role: ChatRole
//    let content: String
//    let timestamp: Date
//    
//    init(role: ChatRole, content: String, timestamp: Date = .now, id: UUID = .init()) {
//        self.id = id
//        self.role = role
//        self.content = content
//        self.timestamp = timestamp
//    }
//    
//    static func system(_ text: String)    -> Message { .init(role: .system,    content: text) }
//    static func user(_ text: String)      -> Message { .init(role: .user,      content: text) }
//    static func assistant(_ text: String) -> Message { .init(role: .assistant, content: text) }
//}
//
//struct Conversation: Identifiable, Codable, Hashable {
//    let id: UUID
//    var title: String
//    var messages: [Message]
//    var createdAt: Date
//    
//    init(id: UUID = .init(),
//         title: String = "",
//         messages: [Message] = [],
//         createdAt: Date = .now)
//    {
//        self.id = id
//        self.messages = messages
//        self.createdAt = createdAt
//        // Auto-generate title from first user message if not provided
//        if title.isEmpty {
//            let firstUser = messages.first(where: { $0.role == .user })?.content ?? "New Chat" // Default title
//            self.title = String(firstUser.prefix(32)) // Limit title length
//        } else {
//            self.title = title
//        }
//    }
//}
//
//// MARK: — 2. Backend Protocols & Implementations
//
//// Protocol defining the contract for any chat service
//protocol ChatBackend {
//    func streamChat(
//        messages: [Message],
//        systemPrompt: String,
//        completion: @escaping (Result<String, Error>) -> Void
//    )
//}
//
//// Mock implementation for testing and development
//struct MockChatBackend: ChatBackend {
//    let replies = [
//        "Chắc chắn rồi!", "Okay!", "Để tôi xem...", "Tôi hiểu rồi.",
//        "Bạn muốn biết thêm gì?", "Có thể nói rõ hơn không?", "Một ý tưởng hay!"
//    ]
//    func streamChat(
//        messages: [Message],
//        systemPrompt: String,
//        completion: @escaping (Result<String, Error>) -> Void
//    ) {
//        // Simulate network delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            completion(.success(replies.randomElement()!))
//        }
//    }
//}
//
//// Implementation using the OpenAI API
//final class RealOpenAIBackend: ChatBackend {
//    let apiKey: String
//    let model: String
//    let temperature: Double
//    let maxTokens: Int
//    
//    init(apiKey: String, model: String, temperature: Double, maxTokens: Int) {
//        self.apiKey = apiKey
//        self.model = model
//        self.temperature = temperature
//        self.maxTokens = maxTokens
//    }
//    
//    // Define the structure matching the OpenAI API request body
//    struct RequestPayload: Encodable {
//        struct MessagePayload: Encodable { let role: String; let content: String }
//        let model: String
//        let messages: [MessagePayload]
//        let temperature: Double
//        let max_tokens: Int // Renamed to match API
//    }
//    // Define the structure matching the OpenAI API response body
//    struct ResponsePayload: Decodable {
//        struct Choice: Decodable {
//            struct Message: Decodable { let content: String }
//            let message: Message
//        }
//        let choices: [Choice]
//    }
//    // Define the structure matching the OpenAI API Error response body
//    struct ErrorResponse: Decodable {
//        struct ErrorDetail: Decodable { let message: String }
//        let error: ErrorDetail?
//    }
//    
//    func streamChat(
//        messages: [Message],
//        systemPrompt: String,
//        completion: @escaping (Result<String, Error>) -> Void)
//    {
//        // VUI: Include system prompt for context/personality
//        var allMessages = messages
//        if !systemPrompt.isEmpty {
//            allMessages.insert(.system(systemPrompt), at: 0)
//        }
//        
//        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
//            DispatchQueue.main.async { completion(.failure(NSError(domain: "InvalidURL", code: 0))) }
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        // Map our Message model to the API's expected format
//        let body = RequestPayload(
//            model: self.model, // Use the model specified during initialization
//            messages: allMessages.map { RequestPayload.MessagePayload(role: $0.role.rawValue, content: $0.content) },
//            temperature: self.temperature,
//            max_tokens: self.maxTokens
//        )
//        
//        do {
//            request.httpBody = try JSONEncoder().encode(body)
//        } catch {
//            DispatchQueue.main.async { completion(.failure(error)) }
//            return
//        }
//        
//        // Perform the network request
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async { // Ensure completion happens on main thread
//                // VUI: Clear and actionable error handling
//                if let networkError = error {
//                    completion(.failure(networkError))
//                    return
//                }
//                guard let responseData = data else {
//                    completion(.failure(NSError(domain: "NoData", code: 1)))
//                    return
//                }
//                
//                // Decode the response
//                do {
//                    let decodedResponse = try JSONDecoder().decode(ResponsePayload.self, from: responseData)
//                    let replyText = decodedResponse.choices.first?.message.content ?? "Xin lỗi, tôi không nhận được phản hồi." // VUI: Graceful failure message
//                    completion(.success(replyText))
//                } catch {
//                    // Try decoding potential error response from OpenAI
//                    let errorMsg: String
//                    if let decodedError = try? JSONDecoder().decode(ErrorResponse.self, from: responseData),
//                       let message = decodedError.error?.message {
//                        errorMsg = "API Error: \(message)"
//                    } else {
//                        errorMsg = "Lỗi giải mã phản hồi: \(error.localizedDescription)"
//                    }
//                    let wrappedError = NSError(domain: "DecodingError", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMsg])
//                    completion(.failure(wrappedError))
//                }
//            }
//        }.resume()
//    }
//}
//
//// Enum for different backend types
//enum BackendType: String, CaseIterable, Identifiable {
//    case mock = "Mock"
//    case openAI = "OpenAI"
//    case coreML = "CoreML (Local)"
//    var id: Self { self }
//}
//
//// Implementation using a local CoreML model (Placeholder)
//final class CoreMLChatBackend: ChatBackend {
//    let modelName: String
//    lazy var coreModel: MLModel? = {
//        guard let url = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
//            print("Error: CoreML model '\(modelName).mlmodelc' not found.")
//            return nil
//        }
//        do {
//            print("Attempting to load CoreML model at URL: \(url.path)")
//            let model = try MLModel(contentsOf: url)
//            print("Successfully loaded CoreML model: \(modelName)")
//            return model
//        } catch {
//            print("Error loading CoreML model '\(modelName)': \(error)")
//            return nil
//        }
//    }()
//    
//    init(modelName: String) {
//        self.modelName = modelName
//    }
//    
//    func streamChat(
//        messages: [Message],
//        systemPrompt: String,
//        completion: @escaping (Result<String, Error>) -> Void
//    ) {
//        guard let model = coreModel else {
//            let error = NSError(domain: "CoreMLError", code: 1, userInfo: [NSLocalizedDescriptionKey: "CoreML model '\(modelName)' could not be loaded."])
//            DispatchQueue.main.async { completion(.failure(error)) }
//            return
//        }
//        
//        // --- Placeholder for actual CoreML inference ---
//        let lastUserInput = messages.last(where: { $0.role == .user })?.content ?? ""
//        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
//            let reply = "CoreML (\(self.modelName)) trả lời: '\(lastUserInput)'"
//            DispatchQueue.main.async { completion(.success(reply)) }
//        }
//        // Actual inference: model.prediction(from: inputFeatures) -> outputFeatures
//    }
//}
//
//// MARK: — 3. Speech Recognizer (Speech-to-Text)
//
//// V5 SpeechRecognizer logic remains suitable for the takeover VUI
//final class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
//    // Published properties to update the UI
//    @Published var transcript = ""
//    @Published var isRecording = false
//    @Published var errorMessage: String? // VUI: Expose errors for UI feedback
//    // VUI ADDITION: Rough audio level simulation
//    @Published var audioLevel: Float = 0.0
//    private var levelTimer: Timer?
//    
//    // Callback for when transcription is finalized (e.g., by silence or stopping)
//    var onFinalTranscription: ((String) -> Void)?
//    var onErrorOccurred: ((String) -> Void)? // Callback for errors during VUI
//    
//    // Speech recognition components
//    private let recognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN")) // Use the specified Vietnamese locale
//    private let audioEngine = AVAudioEngine() // Processes audio buffers
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // Request for buffering audio
//    private var recognitionTask: SFSpeechRecognitionTask? // The actual recognition task
//    
//    // Silence detection mechanism (USED BY THE VUI LOGIC)
//    private let silenceTimeout: TimeInterval = 1.8 // Adjust as needed
//    private var silenceWork: DispatchWorkItem?
//    
//    override init() {
//        super.init()
//        self.recognizer?.delegate = self // Set delegate if needed for availability changes
//    }
//    
//    // VUI: Request user authorization clearly
//    func requestAuthorization(completion: @escaping (Bool) -> Void) {
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            let authorized = authStatus == .authorized
//            DispatchQueue.main.async {
//                if !authorized {
//                    self.errorMessage = "Quyền truy cập microphone và nhận dạng giọng nói là cần thiết. Vui lòng bật trong Cài đặt."
//                } else {
//                    self.errorMessage = nil // Clear error on success
//                }
//                completion(authorized)
//            }
//        }
//    }
//    
//    // Start the recording and recognition process
//    func startRecording() throws {
//        // Reset state
//        errorMessage = nil
//        transcript = ""
//        isRecording = true
//        audioLevel = 0.0 // Reset audio level
//        recognitionTask?.cancel(); recognitionTask = nil
//        recognitionRequest?.endAudio(); recognitionRequest = nil
//        silenceWork?.cancel(); silenceWork = nil
//        levelTimer?.invalidate(); levelTimer = nil // Stop level timer
//        
//        // Configure audio session
//        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        
//        // Create recognition request
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            fatalError("Unable to create SFSpeechAudioBufferRecognitionRequest")
//        }
//        recognitionRequest.shouldReportPartialResults = true // VUI: Show live transcript
//        recognitionRequest.taskHint = .dictation // Optimize for dictation
//        
//        // Check recognizer availability
//        guard let speechRecognizer = recognizer, speechRecognizer.isAvailable else {
//            stopRecording() // Clean up if recognizer not available
//            throw NSError(domain: "RecognizerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Bộ nhận dạng giọng nói không khả dụng."])
//        }
//        
//        // Start recognition task
//        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//            guard let self = self else { return }
//            var isFinal = false
//            
//            if let result = result {
//                // VUI: Update transcript for live feedback
//                DispatchQueue.main.async {
//                    self.transcript = result.bestTranscription.formattedString
//                }
//                isFinal = result.isFinal
//                if isFinal {
//                    self.finish(self.transcript) // Call finish logic
//                } else {
//                    // Reset silence timer
//                    self.scheduleSilence()
//                }
//            }
//            
//            // Stop level timer on error or final result
//            if error != nil || isFinal {
//                self.stopLevelTimer()
//            }
//            
//            // VUI: Handle errors clearly
//            if let anError = error {
//                DispatchQueue.main.async {
//                    let errorMsg: String
//                    // Map specific error codes if needed
//                    if (anError as NSError).code == 203 && self.transcript.isEmpty { // Code 203 retry, often occurs on empty audio
//                        errorMsg = "Không nghe thấy gì. Vui lòng thử lại."
//                    } else {
//                        errorMsg = "Lỗi nhận dạng: \(anError.localizedDescription)"
//                    }
//                    self.errorMessage = errorMsg // Update error message
//                    self.onErrorOccurred?(errorMsg) // VUI: Notify error listener
//                    self.stopRecording() // Call modified stop on error
//                }
//            } else if isFinal {
//                // Already handled calling finish above
//                self.stopRecording() // Stop audio parts even if finish was called
//            }
//        }
//        
//        // Configure audio engine input node
//        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
//        audioEngine.inputNode.removeTap(onBus: 0) // Remove existing tap first
//        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            self.recognitionRequest?.append(buffer)
//            self.updateAudioLevel(buffer: buffer) // VUI: Update level
//        }
//        
//        // Prepare and start audio engine
//        audioEngine.prepare()
//        try audioEngine.start()
//        
//        // Start the initial silence timer and level timer
//        scheduleSilence()
//        startLevelTimer()
//    }
//    
//    // Silence Detection Logic
//    private func scheduleSilence() {
//        silenceWork?.cancel()
//        let wi = DispatchWorkItem { [weak self] in
//            guard let self = self, self.isRecording else { return }
//            print("Silence detected.")
//            self.finish(self.transcript) // Call finish logic
//        }
//        silenceWork = wi
//        // Use the timeout defined in this class
//        DispatchQueue.main.asyncAfter(deadline: .now() + silenceTimeout, execute: wi)
//    }
//    
//    // Finish Logic (Called by silence or explicit stop if needed)
//    private func finish(_ text: String) {
//        guard isRecording else { return } // Prevent multiple calls
//        print("Finish called with transcript: '\(text)'")
//        onFinalTranscription?(text)
//        stopRecording() // Call modified stop
//    }
//    
//    // Stop audio engine, invalidate timers, clean up resources
//    func stopRecording() {
//        guard isRecording else { return } // Check if actually recording
//        print("stopRecording called.")
//        isRecording = false // Update state immediately
//        audioLevel = 0.0 // Reset level
//        
//        stopLevelTimer() // Stop level timer
//        silenceWork?.cancel(); silenceWork = nil
//        
//        if audioEngine.isRunning {
//            print("Stopping audio engine and removing tap.")
//            audioEngine.stop()
//            audioEngine.inputNode.removeTap(onBus: 0)
//        } else {
//            print("Audio engine was not running.")
//        }
//        
//        // Check if request/task exist before ending/cancelling
//        if recognitionRequest != nil {
//            print("Ending audio request.")
//            recognitionRequest?.endAudio()
//        }
//        recognitionRequest = nil // Nullify after ending
//        
//        // Cancel recognition task if it's still active and not finishing
//        if let task = recognitionTask, !task.isFinishing, task.error == nil {
//            print("Cancelling recognition task.")
//            task.cancel()
//        }
//        recognitionTask = nil // Nullify after cancelling
//        
//        // Deactivate audio session
//        do {
//            print("Deactivating audio session.")
//            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//        } catch {
//            print("Error deactivating audio session: \(error.localizedDescription)")
//        }
//        
//        print("stopRecording finished.")
//    }
//    
//    // --- VUI: Audio Level Simulation Logic ---
//    private func startLevelTimer() {
//        levelTimer?.invalidate()
//        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            // Simulate decay if no new level updates come in
//            DispatchQueue.main.async {
//                let currentLevel = self?.audioLevel ?? 0
//                // Use a smaller decay factor for slower decay
//                self?.audioLevel = max(0, currentLevel * 0.85)
//            }
//        }
//    }
//    
//    private func stopLevelTimer() {
//        levelTimer?.invalidate()
//        levelTimer = nil
//        // Ensure level goes to 0 when stopped
//        DispatchQueue.main.async { self.audioLevel = 0.0 }
//    }
//    
//    private func updateAudioLevel(buffer: AVAudioPCMBuffer) {
//        guard let channelData = buffer.floatChannelData else { return }
//        let channelDataValue = channelData.pointee
//        let channelDataValueArray = UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength))
//        
//        // Calculate Root Mean Square (RMS)
//        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
//        let avgPower = 20 * log10(max(rms, 1e-5)) // Power in dB, avoid log10(0)
//        
//        // Normalize power level to 0-1 range (adjust range as needed)
//        let minDb: Float = -55.0 // Quieter threshold
//        let maxDb: Float = -5.0   // Louder threshold, don't need 0
//        var normalizedLevel = (avgPower - minDb) / (maxDb - minDb)
//        normalizedLevel = max(0.0, min(1.0, normalizedLevel)) // Clamp
//        
//        // Update published property on main thread, smoothing slightly
//        DispatchQueue.main.async {
//            // Apply a simple smoothing factor (e.g., previous level * 0.2 + new level * 0.8)
//            let smoothedLevel = (self.audioLevel * 0.3) + (normalizedLevel * 0.7)
//            self.audioLevel = smoothedLevel
//        }
//    }
//    // -----------------------------------------
//    
//    // SFSpeechRecognizerDelegate method (optional)
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        DispatchQueue.main.async {
//            if !available {
//                self.errorMessage = "Bộ nhận dạng giọng nói không còn khả dụng."
//                self.onErrorOccurred?("Bộ nhận dạng giọng nói hiện không có.")
//                if self.isRecording {
//                    self.stopRecording() // Stop if it becomes unavailable mid-recording
//                }
//            } else {
//                // If it becomes available again, clear the "unavailable" error
//                if self.errorMessage == "Bộ nhận dạng giọng nói không còn khả dụng." {
//                    self.errorMessage = nil
//                }
//            }
//        }
//    }
//}
//
//// MARK: — 4. ViewModel (Central State + VUI State Management)
//
//// VUI State Definition
//enum VUIState {
//    case idle          // Not active
//    case prompting     // Showing suggestions, ready to listen
//    case listening     // Actively recording speech
//    case acknowledging // Briefly showing what was heard before processing
//    case processing    // Waiting for backend response
//}
//
//@MainActor
//final class ChatStore: ObservableObject {
//    // MARK: - Published Properties (UI + VUI State)
//    @Published var conversations: [Conversation] = [] { didSet { saveToDisk() } }
//    @Published var current: Conversation
//    @Published var input: String = ""
//    @Published var isLoading: Bool = false // Used for BOTH chat and VUI processing indicator
//    @Published var errorMessage: String?   // For errors shown in main Chat UI
//    
//    // VUI State Properties
//    @Published var vuiState: VUIState = .idle
//    @Published var vuiTranscript: String = "" // Transcript shown in VUI overlay
//    @Published var vuiErrorMessage: String?   // Error shown ONLY in VUI overlay
//    
//    // Suggested Prompts for VUI
//    let suggestedPrompts = [
//        "Tôi bị mất thẻ",
//        "Thẻ của tôi bị từ chối?",
//        "Làm sao đổi điểm thưởng?"
//    ]
//    
//    // Settings synced with UserDefaults
//    @AppStorage("system_prompt") var systemPrompt: String = "Bạn là một trợ lý AI hữu ích nói tiếng Việt."
//    @AppStorage("tts_enabled") var ttsEnabled: Bool = false
//    @AppStorage("tts_rate") var ttsRate: Double = 1.0 // Default rate multiplier
//    @AppStorage("tts_voice_id") var ttsVoiceID: String = ""
//    @AppStorage("openai_api_key") var apiKey: String = ""
//    @AppStorage("backend_type") private var backendTypeRaw: String = BackendType.mock.rawValue
//    @AppStorage("coreml_model_name") var coreMLModelName: String = "TinyChat" // Default CoreML model name
//    @AppStorage("openai_model_name") var openAIModelName: String = "gpt-4o" // Default OpenAI model
//    @AppStorage("openai_temperature") var openAITemperature: Double = 0.7
//    @AppStorage("openai_max_tokens") var openAIMaxTokens: Int = 512
//    
//    // Available models / voices
//    let availableCoreMLModels = ["TinyChat", "LocalChat"] // Example model names
//    let availableOpenAIModels = ["gpt-4o", "gpt-4-turbo", "gpt-3.5-turbo"]
//    let availableVoices: [AVSpeechSynthesisVoice]
//    
//    // MARK: - Private Properties
//    private(set) var backend: ChatBackend
//    private let ttsSynth = AVSpeechSynthesizer()
//    private var ttsDelegate: TTSSpeechDelegate?
//    private var cancellables = Set<AnyCancellable>() // For Sink
//    
//    // MARK: - Computed Properties
//    var backendType: BackendType {
//        get { BackendType(rawValue: backendTypeRaw) ?? .mock }
//        set { backendTypeRaw = newValue.rawValue; configureBackend() }
//    }
//    
//    // MARK: - Initialization
//    init() {
//        // Phase 1: Initialize stored properties
//        self.availableVoices = AVSpeechSynthesisVoice.speechVoices()
//            .filter { $0.language.starts(with: "vi") || $0.language.starts(with: "en") } // Filter for Vi/En initially
//            .sorted { v1, v2 in
//                let v1Vi = v1.language.starts(with: "vi"); let v2Vi = v2.language.starts(with: "vi")
//                if v1Vi != v2Vi { return v1Vi } // Vietnamese first
//                return v1.name < v2.name // Then sort by name
//            }
//        self.backend = MockChatBackend() // Start with a temporary backend
//        self.ttsDelegate = TTSSpeechDelegate()
//        self.current = Conversation(id: UUID(), title: "", messages: []) // Temporary placeholder
//        
//        // Phase 2: Logic after properties are initialized
//        self.ttsSynth.delegate = self.ttsDelegate
//        let initialTTSVoiceID = self.ttsVoiceID // Read @AppStorage value
//        // Set default voice if needed
//        if initialTTSVoiceID.isEmpty || self.availableVoices.first(where: { $0.identifier == initialTTSVoiceID }) == nil {
//            self.ttsVoiceID = self.availableVoices.first(where: {$0.language.starts(with: "vi-VN")})?.identifier ?? self.availableVoices.first?.identifier ?? ""
//        }
//        // Create initial conversation template using loaded systemPrompt
//        let realInitialConversation = Conversation(messages: [.system(self.systemPrompt)])
//        // Load saved conversations FIRST
//        loadFromDisk()
//        // Configure the actual backend based on loaded settings
//        configureBackend()
//        // Assign the final 'current' conversation (most recent or new template)
//        if let mostRecent = conversations.first {
//            self.current = mostRecent
//            // Optional: Ensure system prompt consistency if needed
//            if self.current.messages.first?.role != .system {
//                self.current.messages.insert(.system(self.systemPrompt), at: 0)
//            }
//            // Policy: Decide if system prompt updates should apply to old chats
//            // else if self.current.messages.first?.content != self.systemPrompt {
//            //     self.current.messages[0] = .system(self.systemPrompt)
//            // }
//            // If modifications were made, ensure they reflect in the main array for saving
//            if let index = self.conversations.firstIndex(where: { $0.id == self.current.id }) {
//                self.conversations[index] = self.current
//            }
//        } else {
//            self.current = realInitialConversation
//        }
//        self.vuiState = .idle // Ensure VUI starts idle
//        
//        print("ChatStore Initialized. Backend: \(backendType.rawValue), TTS Voice: \(ttsVoiceID)")
//    } // End init
//    
//    // MARK: - Backend Management
//    func setBackend(_ newBackend: ChatBackend, type: BackendType) {
//        backend = newBackend
//        backendTypeRaw = type.rawValue // Update AppStorage (indirectly calls configureBackend via setter)
//        print("Backend explicitly set to: \(type.rawValue)")
//    }
//    
//    private func configureBackend() {
//        print("Configuring backend for type: \(self.backendType.rawValue)")
//        
//        // Safety Check: OpenAI API Key
//        if self.backendType == .openAI && self.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            print("Warning: OpenAI selected but API key missing. Falling back to Mock.")
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self, self.backendType != .mock else { return } // Prevent loop
//                self.errorMessage = "Khóa API OpenAI bị thiếu. Sử dụng Mock backend."
//                self.backend = MockChatBackend() // Set directly
//                self.backendTypeRaw = BackendType.mock.rawValue // Update storage
//            }
//            return
//        }
//        
//        // Safety Check: CoreML Model Load
//        if self.backendType == .coreML {
//            let coreMLBackend = CoreMLChatBackend(modelName: self.coreMLModelName)
//            if coreMLBackend.coreModel == nil { // Check if model loaded
//                print("Warning: CoreML model '\(self.coreMLModelName)' failed to load. Falling back to Mock.")
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self, self.backendType != .mock else { return }
//                    self.errorMessage = "Không tải được mô hình CoreML '\(self.coreMLModelName)'. Sử dụng Mock backend."
//                    self.backend = MockChatBackend()
//                    self.backendTypeRaw = BackendType.mock.rawValue
//                }
//                return
//            }
//            // If model loaded successfully, assign the created instance
//            self.backend = coreMLBackend
//        } else {
//            // Configure other backends (Mock or OpenAI if key was present)
//            switch self.backendType {
//            case .mock:
//                self.backend = MockChatBackend()
//            case .openAI:
//                self.backend = RealOpenAIBackend(
//                    apiKey: self.apiKey.trimmingCharacters(in: .whitespacesAndNewlines),
//                    model: self.openAIModelName,
//                    temperature: self.openAITemperature,
//                    maxTokens: self.openAIMaxTokens
//                )
//            case .coreML: // Should have been handled above, but for safety
//                print("CoreML should have been configured already.")
//                let backendCheck = CoreMLChatBackend(modelName: self.coreMLModelName)
//                self.backend = (backendCheck.coreModel != nil) ? backendCheck : MockChatBackend()
//            }
//        }
//        print("Backend configured successfully to: \(self.backendType.rawValue)")
//        // Clear general error message if configuration succeeds
//        if self.errorMessage?.contains("backend") ?? false || self.errorMessage?.contains("API") ?? false || self.errorMessage?.contains("CoreML") ?? false {
//            self.errorMessage = nil
//        }
//    }
//    
//    // MARK: - VUI Interaction Flow
//    
//    func startVUIInteraction() {
//        guard vuiState == .idle else { return } // Only start if idle
//        print("Starting VUI Interaction...")
//        errorMessage = nil   // Clear main chat error
//        vuiErrorMessage = nil // Clear VUI specific error
//        vuiTranscript = ""    // Clear VUI transcript
//        stopSpeaking() // Stop any ongoing TTS
//        
//        // Change state to present the VUI overlay
//        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
//            vuiState = .prompting
//        }
//        // Note: SpeechRecognizer isn't started here. It starts automatically via .onChange in TakeoverVUIView.
//    }
//    
//    // Called by TakeoverVUIView when prompting state is entered
//    // Needs access to the SpeechRecognizer instance managed by the main view
//    func handleVUIListenStartRequest(speechRecognizer sr: SpeechRecognizer) {
//        guard self.vuiState == .prompting else { return }
//        print("VUI attempting to start listening...")
//        vuiErrorMessage = nil // Clear any previous VUI error
//        
//        sr.requestAuthorization { [weak self] granted in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                // Check if still prompting, VUI might have been closed
//                guard self.vuiState == .prompting else {
//                    print("VUI: State changed before authorization completed. Aborting listen start.")
//                    return
//                }
//                
//                if granted {
//                    do {
//                        try sr.startRecording()
//                        print("VUI: Speech recording started successfully.")
//                        // Transition state only AFTER successfully starting recording
//                        withAnimation { self.vuiState = .listening }
//                    } catch {
//                        print("VUI Error starting speech recognition: \(error)")
//                        self.vuiErrorMessage = "Không thể bắt đầu nghe: \(error.localizedDescription)"
//                        // Go back to idle on error
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.dismissVUI() }
//                    }
//                } else {
//                    print("VUI: Speech permission denied.")
//                    self.vuiErrorMessage = "Cần cấp quyền để sử dụng giọng nói."
//                    // Dismiss after a delay to show message
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { self.dismissVUI() }
//                }
//            }
//        }
//    }
//    
//    func stopListeningAndProcessVUI(recognizedText: String) {
//        guard vuiState == .listening || vuiState == .acknowledging else { return } // Allow processing from acknowledge too
//        print("VUI stopped listening. Recognized: '\(recognizedText)'")
//        let trimmedText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        vuiErrorMessage = nil // Clear error on successful recognition
//        
//        if trimmedText.isEmpty {
//            print("VUI: Empty transcript, returning to prompt.")
//            vuiErrorMessage = "Không nghe thấy gì rõ ràng. Thử lại?"
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
//                if self?.vuiState == .acknowledging || self?.vuiState == .processing { // Check state before resetting
//                    withAnimation { self?.vuiState = .prompting }
//                }
//            }
//            return
//        }
//        
//        // 1. Update VUI transcript to final recognized text
//        vuiTranscript = trimmedText
//        
//        // 2. Transition to Acknowledging (briefly show final text)
//        withAnimation { vuiState = .acknowledging }
//        
//        // 3. After a short delay, transition to Processing and send message
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
//            guard let self = self else { return }
//            if self.vuiState == .acknowledging { // Check state before processing
//                withAnimation { self.vuiState = .processing }
//                self.sendMessage(trimmedText) // Send the final transcript
//            }
//        }
//    }
//    
//    // Called when VUI backend call completes OR when manually closing VUI
//    func dismissVUI() {
//        if vuiState != .idle {
//            print("Dismissing VUI (Current State: \(vuiState)).")
//            withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
//                vuiState = .idle
//            }
//            isLoading = false // Ensure loading indicator is hidden
//            // Speech recognizer stop is handled in ChatDemoVUI_v2's .onChange(of: vuiState)
//        }
//    }
//    
//    // MARK: - Chat Actions (Modified sendMessage for VUI dismissal)
//    
//    func sendMessage(_ text: String) {
//        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        let initiatedFromVUI = (vuiState == .processing) // Check if VUI is in processing state
//        
//        guard !trimmedText.isEmpty else {
//            if initiatedFromVUI { dismissVUI() } // Dismiss VUI if empty text triggered send
//            return
//        }
//        // Prevent sending if already loading (could happen with rapid taps?)
//        guard !isLoading else {
//            print("Attempted to send message while already loading.")
//            return
//        }
//        
//        stopSpeaking() // Stop previous TTS
//        
//        // Add user message to history *only if* it came from text input
//        if !initiatedFromVUI {
//            let userMessage = Message.user(trimmedText)
//            current.messages.append(userMessage)
//        }
//        
//        // Prepare messages for the backend
//        // If from VUI, use the current state which *doesn't* yet include the VUI user message
//        // If from text, use current state *with* the just-added user message
//        let messagesForBackend = current.messages
//        
//        input = "" // Clear text input field regardless
//        isLoading = true // Show loading indicator (in chat OR VUI)
//        errorMessage = nil // Clear main chat error
//        if initiatedFromVUI { vuiErrorMessage = nil } // Clear VUI error when processing starts
//        
//        print("Sending messages (\(messagesForBackend.count)) to backend (\(backendType.rawValue)). VUI Initiated: \(initiatedFromVUI)")
//        
//        backend.streamChat(messages: messagesForBackend, systemPrompt: systemPrompt) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                self.isLoading = false // Hide loading indicator
//                
//                // VUI: Dismiss the overlay *after* getting the result
//                if initiatedFromVUI {
//                    self.dismissVUI()
//                }
//                
//                switch result {
//                case .success(let replyText):
//                    print("Received reply: \(replyText.prefix(50))...")
//                    let assistantMessage = Message.assistant(replyText)
//                    
//                    // VUI: Add the user's VUI input + AI response together to history
//                    if initiatedFromVUI && !trimmedText.isEmpty {
//                        let vuiUserMessage = Message.user(trimmedText) // Create the message for the VUI input
//                        self.current.messages.append(vuiUserMessage) // Add VUI input now
//                        print("Added VUI user message to history: '\(trimmedText)'")
//                    }
//                    
//                    // Add assistant message if not empty
//                    if !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                        self.current.messages.append(assistantMessage)
//                        print("Added assistant message to history: '\(replyText.prefix(50))...'")
//                    } else {
//                        print("Received empty reply from backend. Not adding to history.")
//                        // Optional: Add a placeholder or error message to chat?
//                    }
//                    
//                    // Save conversation regardless of whether assistant msg was empty,
//                    // especially if user VUI msg was added
//                    self.upsertConversation()
//                    
//                    // Speak if enabled and reply is not empty
//                    if self.ttsEnabled && !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                        self.speak(replyText)
//                    }
//                    
//                case .failure(let error):
//                    print("Backend error: \(error.localizedDescription)")
//                    // Show error in main chat UI, VUI is already dismissed
//                    self.errorMessage = "Lỗi Backend: \(error.localizedDescription)"
//                    // Policy: Should we add the user message (text or VUI) if the backend failed?
//                    // Current logic: VUI input is NOT added on failure. Text input WAS added before send.
//                }
//            }
//        }
//    }
//    
//    func speak(_ text: String) {
//        guard ttsEnabled, !text.isEmpty else { return }
//        if ttsSynth.delegate == nil { // Re-assign delegate if needed (safety)
//            ttsDelegate = TTSSpeechDelegate(); ttsSynth.delegate = ttsDelegate
//        }
//        stopSpeaking() // Explicitly stop before speaking new utterance
//        
//        do { // Configure audio session
//            let currentCategory = AVAudioSession.sharedInstance().category
//            if currentCategory != .playback {
//                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
//                print("Set audio session category to playback for TTS.")
//            }
//        } catch { print("Failed to set audio session for TTS: \(error)") }
//        
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.rate = Float(ttsRate) * AVSpeechUtteranceDefaultSpeechRate // Use multiplier
//        utterance.voice = AVSpeechSynthesisVoice(identifier: ttsVoiceID)
//        ?? AVSpeechSynthesisVoice(language: "vi-VN") // Vietnamese fallback
//        ?? AVSpeechSynthesisVoice.speechVoices().first // Absolute fallback
//        
//        if utterance.voice == nil { print("Warning: No suitable TTS voice found.") }
//        print("Attempting to speak: \(text.prefix(50))... using voice: \(utterance.voice?.name ?? "Unknown")")
//        ttsSynth.speak(utterance) // Delegate handles session activation/deactivation
//    }
//    
//    func stopSpeaking() {
//        if ttsSynth.isSpeaking {
//            ttsSynth.stopSpeaking(at: .word) // Smoother interruption
//            print("Stopped speaking.")
//            // Delegate will handle audio session deactivation
//        }
//    }
//    
//    // MARK: - History Management
//    func deleteConversation(id: UUID) {
//        conversations.removeAll { $0.id == id }
//        if current.id == id { resetChat() }
//        print("Deleted conversation: \(id). Remaining: \(conversations.count)")
//        // saveToDisk handled by didSet
//    }
//    
//    func selectConversation(_ conversation: Conversation) {
//        stopSpeaking()
//        // Ensure system prompt consistency if needed
//        var selectedConvo = conversation
//        if selectedConvo.messages.first?.role != .system {
//            selectedConvo.messages.insert(.system(self.systemPrompt), at: 0)
//        } // else if system prompt changed... (policy decision)
//        
//        self.current = selectedConvo
//        print("Selected conversation: \(current.id) - \(current.title)")
//    }
//    
//    func renameConversation(_ conversation: Conversation, to newTitle: String) {
//        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedTitle.isEmpty, let index = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
//        conversations[index].title = trimmedTitle
//        if current.id == conversation.id { current.title = trimmedTitle }
//        print("Renamed conversation \(conversation.id) to: \(trimmedTitle)")
//        // saveToDisk handled by didSet
//    }
//    
//    func clearHistory() {
//        stopSpeaking()
//        conversations.removeAll()
//        resetChat()
//        print("Cleared all conversation history.")
//        // saveToDisk handled by didSet
//    }
//    
//    // MARK: - Reset / Initial State
//    func resetChat() {
//        stopSpeaking()
//        self.current = Conversation(messages: [.system(self.systemPrompt)]) // Create new based on *current* prompt
//        self.input = ""
//        self.isLoading = false
//        self.errorMessage = nil
//        // Don't save to history until messages are added.
//        print("Chat reset.")
//    }
//    
//    // MARK: - Voice Command / VUI Speech Handling
//    func attachRecognizer(_ sr: SpeechRecognizer) {
//        // Detach previous sinks if any to prevent duplicates
//        cancellables.forEach { $0.cancel() }
//        cancellables.removeAll()
//        
//        // VUI: Update VUI transcript during listening
//        sr.$transcript.sink { [weak self] newTranscript in
//            guard self?.vuiState == .listening else { return }
//            DispatchQueue.main.async {
//                self?.vuiTranscript = newTranscript
//            }
//        }.store(in: &cancellables)
//        
//        // VUI: Handle final transcription from VUI
//        sr.onFinalTranscription = { [weak self] text in
//            self?.stopListeningAndProcessVUI(recognizedText: text)
//        }
//        
//        // VUI: Handle errors reported by recognizer during VUI session
//        sr.onErrorOccurred = { [weak self] errorMsg in
//            DispatchQueue.main.async { // Ensure UI updates happen on main thread
//                guard let self = self, self.vuiState != .idle else { return } // Only act if VUI is active
//                self.vuiErrorMessage = errorMsg
//                // Optional: Automatically dismiss VUI after showing error
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                    // Check state again before dismissing, user might have closed it
//                    if self.vuiState != .idle {
//                        self.dismissVUI()
//                    }
//                }
//            }
//        }
//        
//        print("Speech Recognizer attached to ChatStore.")
//    }
//    
//    // MARK: - Persistence
//    private func loadFromDisk() {
//        guard let data = UserDefaults.standard.data(forKey: "ChatHistory_v2") else {
//            print("No chat history found in UserDefaults."); self.conversations = []; return
//        }
//        do {
//            let decoder = JSONDecoder()
//            let loaded = try decoder.decode([Conversation].self, from: data)
//            // Basic validation: Ensure conversations have titles and at least a user message
//            self.conversations = loaded.filter { !$0.title.isEmpty && $0.messages.contains { $0.role == .user } }
//            print("Loaded \(self.conversations.count) valid conversations from UserDefaults.")
//        } catch {
//            print("Failed to decode chat history: \(error). Clearing corrupted data.")
//            self.conversations = []
//            UserDefaults.standard.removeObject(forKey: "ChatHistory_v2")
//            self.errorMessage = "Lịch sử chat bị lỗi và đã được xóa." // Inform user via main chat UI
//        }
//    }
//    
//    private func saveToDisk() {
//        // Filter out any conversations that became invalid before saving
//        let validConversations = conversations.filter { !$0.title.isEmpty && $0.messages.contains { $0.role == .user } }
//        
//        if validConversations.isEmpty {
//            if UserDefaults.standard.object(forKey: "ChatHistory_v2") != nil {
//                UserDefaults.standard.removeObject(forKey: "ChatHistory_v2")
//                print("Removed chat history key (no valid conversations).")
//            }
//            return
//        }
//        do {
//            let encoder = JSONEncoder()
//            let data = try encoder.encode(validConversations)
//            UserDefaults.standard.set(data, forKey: "ChatHistory_v2")
//            print("Saved \(validConversations.count) conversations.")
//        } catch {
//            print("Failed to encode chat history: \(error)")
//            self.errorMessage = "Không thể lưu lịch sử chat." // Show error in main UI
//        }
//    }
//    
//    func upsertConversation() {
//        // Ensure there's at least one user message before saving
//        guard current.messages.contains(where: { $0.role == .user }) else {
//            print("Upsert skipped: No user message in current conversation.")
//            return
//        }
//        
//        // Auto-generate/update title if needed
//        let generatedTitle = String(current.messages.first(where: { $0.role == .user })!.content.prefix(32)) // Safer unwrapping assumed
//        if current.title.isEmpty || current.title == "New Chat" {
//            current.title = generatedTitle
//        } else {
//            current.title = current.title.trimmingCharacters(in: .whitespacesAndNewlines)
//            if current.title.isEmpty { current.title = generatedTitle } // Revert if trimmed empty
//        }
//        
//        if let index = conversations.firstIndex(where: { $0.id == current.id }) {
//            print("Upserting: Updating conversation ID \(current.id) at index \(index)")
//            conversations[index] = current
//        } else {
//            // Only insert if it has a valid title (not the initial placeholder) AND user message
//            if current.title != "New Chat" {
//                print("Upserting: Inserting new conversation ID \(current.id) with title '\(current.title)'")
//                conversations.insert(current, at: 0) // Insert at beginning
//            } else {
//                print("Upserting: Skipping insert for placeholder 'New Chat'.")
//            }
//        }
//        // saveToDisk() is handled by the didSet observer on `conversations`
//    }
//} // End ChatStore
//
//// MARK: - 4.1 TTS Delegate (for Audio Session Management)
//
//// Manages audio session activation/deactivation for TTS
//class TTSSpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
//            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
//            print("Audio session activated for TTS.")
//        } catch { print("Error activating audio session for TTS: \(error)") }
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        deactivateAudioSession()
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
//        deactivateAudioSession()
//    }
//    
//    private func deactivateAudioSession() {
//        // Use a slight delay to prevent issues if speech restarts quickly
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            do {
//                // Check if synth is *still* not speaking before deactivating
//                guard !AVSpeechSynthesizer().isSpeaking else {
//                    print("TTS delegate: Synthesizer restarted quickly, keeping session active.")
//                    return
//                }
//                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//                print("Audio session deactivated after TTS.")
//            } catch { print("Error deactivating audio session after TTS: \(error)") }
//        }
//    }
//}
//
//// MARK: — 5. UI Subviews
//
//// Displays a single message bubble
//struct MessageBubble: View {
//    let message: Message
//    let onRespeak: (String) -> Void // Callback to trigger TTS for this message
//    
//    var isUser: Bool { message.role == .user }
//    
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            if isUser { Spacer(minLength: 40) } // Align user right
//            
//            // Assistant Icon
//            if message.role == .assistant {
//                Image(systemName: "sparkles")
//                    .font(.caption)
//                    .foregroundColor(.purple)
//                    .padding(.bottom, 5) // Align roughly with text baseline
//                    .accessibilityHidden(true)
//            }
//            
//            // Message Content VStack
//            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
//                Text(message.content)
//                    .textSelection(.enabled)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .background(isUser ? Color.blue.opacity(0.9) : Color.gray.opacity(0.2))
//                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                    .foregroundColor(isUser ? .white : .primary)
//                    .frame(minWidth: 20) // Prevent tiny bubbles
//                    .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
//                
//                // Timestamp
//                Text(message.timestamp, style: .time)
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            } // End Content VStack
//            
//            // User Icon
//            if message.role == .user {
//                Image(systemName: "person.crop.circle")
//                    .font(.caption)
//                    .foregroundColor(.blue)
//                    .padding(.bottom, 5)
//                    .accessibilityHidden(true)
//            }
//            
//            if !isUser { Spacer(minLength: 40) } // Align assistant left
//        }
//        .contextMenu { // Actions on long press
//            Button { UIPasteboard.general.string = message.content } label: {
//                Label("Copy Text", systemImage: "doc.on.doc")
//            }
//            // Show Respeak only for non-empty assistant messages
//            if message.role == .assistant && !message.content.isEmpty {
//                Button { onRespeak(message.content) } label: {
//                    Label("Đọc Lại", systemImage: "speaker.wave.2.fill")
//                }
//            }
//            // Show Share only if content exists
//            if !message.content.isEmpty {
//                ShareLink(item: message.content) {
//                    Label("Chia sẻ Tin nhắn", systemImage: "square.and.arrow.up")
//                }
//            }
//        }
//        .padding(.vertical, 2) // Slight vertical padding between bubbles
//    }
//}
//
//// Chat Input Bar (Mic button triggers VUI)
//struct ChatInputBar: View {
//    @Binding var text: String
//    @ObservedObject var store: ChatStore // Needed to check VUI state and trigger VUI
//    @ObservedObject var speech: SpeechRecognizer // Only for showing error messages now
//    @FocusState var isFocused: Bool
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Optional: Only show Speech Recognizer *errors* here
//            if let srError = speech.errorMessage {
//                HStack {
//                    Text(srError)
//                        .font(.caption).foregroundColor(.red).lineLimit(1)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal).padding(.bottom, 4)
//                }
//                .transition(.opacity)
//            }
//            
//            // Main Input Row
//            HStack(spacing: 8) {
//                // Text Field
//                TextField("Type message...", text: $text, axis: .vertical)
//                    .focused($isFocused)
//                    .lineLimit(1...4)
//                    .padding(8)
//                    .background(Color(.secondarySystemBackground))
//                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
//                        .stroke(isFocused ? Color.blue.opacity(0.5) : Color.gray.opacity(0.3)))
//                // Disable text field if loading OR VUI is active
//                    .disabled(store.isLoading || store.vuiState != .idle)
//                
//                // Microphone Button (Triggers VUI)
//                micButton
//                
//                // Send Button
//                sendButton
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 6)
//            .background(.thinMaterial) // Standard background
//        }
//        // Auto-clear SpeechRecognizer error after delay
//        .onChange(of: speech.errorMessage) { _, newValue in
//            if newValue != nil {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                    // Only clear if the error message hasn't changed again
//                    if speech.errorMessage == newValue {
//                        speech.errorMessage = nil
//                    }
//                }
//            }
//        }
//    }
//    
//    // Mic Button (Action triggers VUI)
//    private var micButton: some View {
//        Button {
//            isFocused = false // Dismiss keyboard before showing VUI
//            store.startVUIInteraction() // Start the Takeover VUI flow
//        } label: {
//            Image(systemName: "mic.circle.fill") // Consistent filled icon
//                .resizable()
//                .scaledToFit()
//                .frame(width: 28, height: 28) // Standard size
//                .foregroundColor(.blue) // Standard color
//        }
//        // Disable button if loading OR VUI is already active
//        .disabled(store.isLoading || store.vuiState != .idle)
//        .accessibilityLabel("Start Voice Input")
//    }
//    
//    // Send Button View (Disabled if VUI active)
//    private var sendButton: some View {
//        Button {
//            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//            // Only send if text exists, not loading, AND VUI is idle
//            if !trimmedText.isEmpty && !store.isLoading && store.vuiState == .idle {
//                store.sendMessage(trimmedText)
//                text = "" // Clear input field
//            }
//        } label: {
//            Image(systemName: "arrow.up.circle.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 28, height: 28)
//                .foregroundColor(
//                    // Determine disabled state
//                    text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isLoading || store.vuiState != .idle
//                    ? .gray.opacity(0.5) // Disabled color if VUI active
//                    : .blue // Enabled color
//                )
//        }
//        // Disable if text empty, loading, OR VUI is active
//        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isLoading || store.vuiState != .idle)
//        .transition(.opacity.combined(with: .scale)) // Animate appearance
//        .accessibilityLabel("Gửi tin nhắn")
//    }
//}
//
//// MARK: — Settings and History Sheets (Struct Definitions Only - Content Unchanged)
//
//struct SettingsSheet: View {
//    @ObservedObject var store: ChatStore
//    // Local states for edits...
//    @State private var localApiKey: String; @State private var localOpenAIModelName: String; @State private var localOpenAITemperature: Double; @State private var localOpenAIMaxTokens: Int; @State private var localBackendType: BackendType; @State private var localCoreMLModelName: String; @State private var localSystemPrompt: String; @State private var localTtsEnabled: Bool; @State private var localTtsRate: Float; @State private var localTtsVoiceID: String
//    @Environment(\.dismiss) var dismiss
//    var onUpdate: (ChatBackend, BackendType) -> Void // Keep signature
//    
//    // Init to load store values into local state
//    init(store: ChatStore, onUpdate: @escaping (ChatBackend, BackendType) -> Void) {
//        self.store = store; self.onUpdate = onUpdate;
//        _localApiKey = State(initialValue: store.apiKey); _localOpenAIModelName = State(initialValue: store.openAIModelName); _localOpenAITemperature = State(initialValue: store.openAITemperature); _localOpenAIMaxTokens = State(initialValue: store.openAIMaxTokens); _localBackendType = State(initialValue: store.backendType); _localCoreMLModelName = State(initialValue: store.coreMLModelName); _localSystemPrompt = State(initialValue: store.systemPrompt); _localTtsEnabled = State(initialValue: store.ttsEnabled); _localTtsRate = State(initialValue: Float(store.ttsRate)); _localTtsVoiceID = State(initialValue: store.ttsVoiceID)
//    }
//    
//    var body: some View {
//        NavigationStack {
//            Form {
//                // MARK: Backend Selection
//                Section("Backend Engine") {
//                    Picker("Chọn Backend", selection: $localBackendType) {
//                        ForEach(BackendType.allCases) { type in Text(type.rawValue).tag(type) }
//                    }
//                    .onChange(of: localBackendType) { _, _ in /* Optionally trigger immediate backend check? */ }
//                    
//                    if localBackendType == .coreML {
//                        Picker("Chọn CoreML Model", selection: $localCoreMLModelName) {
//                            ForEach(store.availableCoreMLModels, id: \.self) { model in Text(model).tag(model) }
//                        }
//                    }
//                    Text("Backend hiện tại: \(store.backendType.rawValue)").font(.caption).foregroundColor(.secondary)
//                }
//                
//                // MARK: OpenAI Configuration (Conditional)
//                if localBackendType == .openAI {
//                    Section("Cấu hình OpenAI") {
//                        Picker("Model", selection: $localOpenAIModelName) {
//                            ForEach(store.availableOpenAIModels, id: \.self) { Text($0) }
//                        }
//                        HStack { Text("Nhiệt độ:"); Slider(value: $localOpenAITemperature, in: 0...1, step: 0.05); Text("\(localOpenAITemperature, specifier: "%.2f")").frame(width: 40) }
//                        Stepper("Tokens Tối đa: \(localOpenAIMaxTokens)", value: $localOpenAIMaxTokens, in: 64...4096, step: 64)
//                        SecureField("API Key (openai.com)", text: $localApiKey).textContentType(.password).autocapitalization(.none).disableAutocorrection(true)
//                        if localApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { Text("Cần có API key.").font(.footnote).foregroundColor(.orange) }
//                    }
//                }
//                
//                // MARK: General Settings
//                Section("Cài đặt Chung") {
//                    VStack(alignment: .leading) {
//                        Text("System Prompt (Personality)")
//                        TextEditor(text: $localSystemPrompt).frame(height: 100).font(.body)
//                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))
//                            .padding(.bottom, 5)
//                    }
//                }
//                
//                // MARK: Text-to-Speech Settings
//                Section("Đọc Phản Hồi (TTS)") {
//                    Toggle("Bật Đọc Phản Hồi", isOn: $localTtsEnabled)
//                    if localTtsEnabled {
//                        Picker("Giọng Đọc", selection: $localTtsVoiceID) {
//                            ForEach(store.availableVoices, id: \.identifier) { voice in Text("\(voice.name) (\(voice.language.prefix(2)))").tag(voice.identifier) }
//                        }
//                        HStack { Text("Tốc độ đọc:"); Slider(value: $localTtsRate, in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate); Text("\(localTtsRate, specifier: "%.2f")").frame(width: 40) }
//                        Text("Mặc định: \(String(format: "%.2f", AVSpeechUtteranceDefaultSpeechRate)).").font(.caption).foregroundColor(.secondary)
//                    }
//                }
//            }
//            .navigationTitle("Cài đặt Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) { Button("Hủy") { dismiss() } }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Lưu") { applyChanges(); dismiss() }
//                        .disabled(localBackendType == .openAI && localApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Disable save if invalid
//                }
//            }
//        }
//    }
//    
//    // Apply the local changes back to the store
//    private func applyChanges() {
//        // 1. Update non-backend settings directly
//        store.systemPrompt = localSystemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
//        store.ttsEnabled = localTtsEnabled
//        store.ttsRate = Double(localTtsRate)
//        store.ttsVoiceID = localTtsVoiceID
//        
//        // 2. Determine if backend-related settings changed
//        let backendSettingsChanged = (
//            store.apiKey.trimmingCharacters(in: .whitespacesAndNewlines) != localApiKey.trimmingCharacters(in: .whitespacesAndNewlines) ||
//            store.openAIModelName != localOpenAIModelName || store.openAITemperature != localOpenAITemperature || store.openAIMaxTokens != localOpenAIMaxTokens ||
//            store.coreMLModelName != localCoreMLModelName || store.backendType != localBackendType
//        )
//        
//        // 3. If settings changed, update store and trigger reconfiguration
//        if backendSettingsChanged {
//            print("Backend settings changed. Applying updates...")
//            store.apiKey = localApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
//            store.openAIModelName = localOpenAIModelName
//            store.openAITemperature = localOpenAITemperature
//            store.openAIMaxTokens = localOpenAIMaxTokens
//            store.coreMLModelName = localCoreMLModelName
//            // Assign backendType LAST to trigger its setter which calls configureBackend()
//            store.backendType = localBackendType
//        } else {
//            print("No backend-related settings changed.")
//        }
//        
//        // Optional: Handle system prompt change propagation if needed
//        // if !backendSettingsChanged && store.systemPrompt != localSystemPrompt { ... }
//    }
//}
//
//struct HistorySheet: View {
//    @Binding var conversations: [Conversation]
//    let onDelete: (UUID) -> Void
//    let onSelect: (Conversation) -> Void
//    let onRename: (Conversation, String) -> Void
//    let onClear: () -> Void
//    
//    @Environment(\.dismiss) var dismiss
//    @State private var showingRenameAlert = false
//    @State private var conversationToRename: Conversation? = nil
//    @State private var newConversationTitle: String = ""
//    @State private var showingClearConfirm = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if conversations.isEmpty {
//                    ContentUnavailableView("Không có lịch sử chat", systemImage: "bubble.middle.bottom.fill", description: Text("Các đoạn chat đã lưu sẽ xuất hiện ở đây.")).padding(.vertical, 50)
//                } else {
//                    List {
//                        ForEach(conversations) { convo in
//                            historyRow(for: convo)
//                                .contentShape(Rectangle()) // Make row tappable
//                                .onTapGesture { onSelect(convo); dismiss() }
//                        }
//                        .onDelete(perform: deleteItems)
//                    }
//                    .listStyle(.plain)
//                }
//                
//                if !conversations.isEmpty {
//                    Button("Xóa Tất Cả Lịch Sử", role: .destructive) { showingClearConfirm = true }.padding(.vertical)
//                }
//            }
//            .navigationTitle("Lịch sử Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
//                ToolbarItem(placement: .navigationBarTrailing) { Button("Xong") { dismiss() } }
//            }
//            .alert("Đổi tên Đoạn Chat", isPresented: $showingRenameAlert, presenting: conversationToRename) { convo in
//                TextField("Tên mới", text: $newConversationTitle).onAppear { newConversationTitle = convo.title }
//                Button("OK") { if !newConversationTitle.trimmingCharacters(in: .whitespaces).isEmpty { onRename(convo, newConversationTitle)} }
//                Button("Hủy", role: .cancel) {}
//            } message: { convo in Text("Nhập tên mới cho \"\(convo.title)\"") }
//                .alert("Xác nhận Xóa?", isPresented: $showingClearConfirm) {
//                    Button("Xóa Tất Cả", role: .destructive) { onClear(); dismiss() }
//                    Button("Hủy", role: .cancel) {}
//                } message: { Text("Bạn có chắc muốn xóa toàn bộ lịch sử chat? Hành động này không thể hoàn tác.") }
//        }
//        .presentationDetents([.medium, .large])
//    }
//    
//    private func historyRow(for conversation: Conversation) -> some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(conversation.title).font(.headline).lineLimit(1)
//                Text("\(conversation.messages.filter{$0.role != .system}.count) tin nhắn - \(conversation.createdAt, style: .date)").font(.caption).foregroundColor(.secondary)
//            }
//            Spacer()
//            Menu {
//                Button { conversationToRename = conversation; showingRenameAlert = true } label: { Label("Đổi tên", systemImage:"pencil") }
//                ShareLink(item: formatConversationForSharing(conversation)) { Label("Chia sẻ", systemImage: "square.and.arrow.up") }
//                Button(role: .destructive) { onDelete(conversation.id) } label: { Label("Xóa", systemImage: "trash") }
//            } label: { Image(systemName: "ellipsis.circle").foregroundColor(.gray).padding(.leading, 5).imageScale(.large) }
//                .buttonStyle(.borderless).menuIndicator(.hidden)
//        }
//        .padding(.vertical, 4)
//    }
//    
//    private func deleteItems(at offsets: IndexSet) { offsets.map { conversations[$0].id }.forEach(onDelete) }
//    private func formatConversationForSharing(_ conversation: Conversation) -> String {
//        var shareText = "Chat: \(conversation.title)\nDate: \(conversation.createdAt.formatted(date: .long, time: .shortened))\n\n"
//        for message in conversation.messages where message.role != .system {
//            let prefix = message.role == .user ? "You:" : "AI:"
//            shareText += "\(prefix) \(message.content)\n\n"
//        }
//        return shareText.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//}
//
//// MARK: — 5.1 VUI Subviews
//
//// Close Button for VUI Overlay
//struct VUICloseButton: View {
//    let action: () -> Void
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: "xmark.circle.fill")
//                .resizable().scaledToFit().frame(width: 30, height: 30)
//                .foregroundStyle(.white, Color.black.opacity(0.3)) // More contrast
//                .padding()
//        }
//        .accessibilityLabel("Close Voice Input")
//    }
//}
//
//// Suggested Prompts View
//struct SuggestedPromptsView: View {
//    let prompts: [String]
//    let onSelect: (String) -> Void
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            ForEach(prompts, id: \.self) { prompt in
//                Button { onSelect(prompt) } label: {
//                    Text(prompt)
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 14)
//                        .padding(.horizontal, 10)
//                        .background(Color.white.opacity(0.15)) // Subtle background
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.4), lineWidth: 1)) // Subtle border
//                }
//            }
//        }
//        .padding(.horizontal, 40)
//    }
//}
//
//// Simple Audio Visualizer View
//struct AudioVisualizerView: View {
//    @ObservedObject var speech: SpeechRecognizer // Get audio level
//    let barCount: Int = 5 // Number of visualizer bars
//    
//    var body: some View {
//        let animatedLevel = speech.isRecording ? CGFloat(speech.audioLevel) : 0.0
//        
//        HStack(spacing: 6) {
//            ForEach(0..<barCount, id: \.self) { index in
//                let randomFactor = CGFloat.random(in: 0.7...1.0)
//                let calculatedHeight = calculateBarHeight(level: animatedLevel, index: index) * randomFactor
//                
//                RoundedRectangle(cornerRadius: 3)
//                    .fill(speech.isRecording ? Color.white.opacity(0.8) : Color.white.opacity(0.3))
//                    .frame(width: 6, height: max(6, calculatedHeight)) // Min height
//            }
//        }
//        .frame(height: 60) // Fixed height
//        // Use spring animation for more bounce
//        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0.1), value: animatedLevel)
//        .opacity(speech.isRecording || animatedLevel > 0.01 ? 1.0 : 0.5) // Fade out when idle
//    }
//    
//    private func calculateBarHeight(level: CGFloat, index: Int) -> CGFloat {
//        let maxBarHeight: CGFloat = 55.0
//        let midIndex = CGFloat(barCount / 2)
//        let closenessToCenter = 1.0 - abs(CGFloat(index) - midIndex) / (midIndex + 0.5)
//        let sensitivity: CGFloat = 1.8 // Power curve makes it more reactive at low levels
//        let scaledLevel = pow(level, sensitivity)
//        let baseHeight: CGFloat = 6.0 // Minimum height when level is 0
//        let dynamicHeight = (maxBarHeight - baseHeight) * scaledLevel * closenessToCenter * 0.9 // Add some tapering towards max
//        return baseHeight + dynamicHeight
//    }
//}
//
//// MARK: — 5.2 Takeover VUI Overlay
//
//struct TakeoverVUIView: View {
//    @ObservedObject var store: ChatStore
//    @ObservedObject var speech: SpeechRecognizer
//    
//    // State specifically for the Acknowledge transition
//    @State private var showAcknowledgedText = false
//    
//    var body: some View {
//        ZStack {
//            // Background: Slightly Material Blur for Depth
//            Rectangle()
//                .fill(.ultraThinMaterial) // Use material blur
//                .background(Color.blue.opacity(0.7)) // Tint the blur
//                .ignoresSafeArea()
//                .onTapGesture { // Allow tapping background to cancel (except when processing)
//                    if store.vuiState == .prompting || store.vuiState == .listening || store.vuiState == .acknowledging {
//                        print("VUI Background tapped, dismissing.")
//                        store.dismissVUI()
//                        speech.stopRecording() // Explicitly stop speech
//                    }
//                }
//            
//            // Content based on State
//            VStack {
//                Spacer() // Push content towards center/bottom
//                
//                // VUI State Content Switch
//                Group { // Group for applying common modifiers if needed
//                    switch store.vuiState {
//                    case .prompting:     promptingContent.transition(.opacity.combined(with: .scale(scale: 0.95)))
//                    case .listening:     listeningContent.transition(.opacity)
//                    case .acknowledging: acknowledgingContent.transition(.opacity)
//                    case .processing:    processingContent.transition(.opacity)
//                    case .idle:          EmptyView()
//                    }
//                }
//                .padding(.horizontal, 30) // Horizontal padding for text content
//                
//                // Show VUI-specific error message if present
//                if let vuiError = store.vuiErrorMessage {
//                    Text(vuiError)
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.8))
//                        .padding(.top, 15)
//                        .padding(.horizontal, 30)
//                        .multilineTextAlignment(.center)
//                        .transition(.opacity)
//                }
//                
//                Spacer() // Push visualizer to bottom
//                
//                // Audio Visualizer
//                AudioVisualizerView(speech: speech)
//                    .padding(.bottom, 30) // Position above bottom safe area
//            }
//            .padding(.vertical, 20) // Overall vertical padding
//            
//            // Close Button (Top Right)
//            VStack {
//                HStack {
//                    Spacer()
//                    VUICloseButton {
//                        print("Close button tapped.")
//                        store.dismissVUI()
//                        speech.stopRecording() // Ensure speech stops on close
//                    }
//                }
//                Spacer()
//            }
//            .padding(.top, 10)
//            
//        }
//        .onChange(of: store.vuiState) { _, newState in
//            // Automatically start listening when prompting state is entered
//            if newState == .prompting {
//                // Delay allows UI transition first
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    // Pass the speech instance directly
//                    store.handleVUIListenStartRequest(speechRecognizer: speech)
//                }
//            }
//            // Reset acknowledge state flag when leaving acknowledge state
//            if newState != .acknowledging {
//                showAcknowledgedText = false
//            }
//        }
//        .onAppear {
//            // If view appears already in prompting state, try starting immediately
//            if store.vuiState == .prompting {
//                store.handleVUIListenStartRequest(speechRecognizer: speech)
//            }
//        }
//    } // End body
//    
//    // MARK: - VUI State Content Views
//    private var promptingContent: some View {
//        VStack(spacing: 25) {
//            Text("Xin hãy nói gì đó,\nHoặc thử một trong những câu này:")
//                .font(.title3).fontWeight(.medium)
//                .foregroundColor(.white.opacity(0.9))
//                .multilineTextAlignment(.center)
//            SuggestedPromptsView(prompts: store.suggestedPrompts) { selectedPrompt in
//                print("Suggested prompt selected: \(selectedPrompt)")
//                // If speech is somehow active, stop it
//                if speech.isRecording { speech.stopRecording() }
//                store.vuiTranscript = selectedPrompt // Set transcript for acknowledge phase
//                store.stopListeningAndProcessVUI(recognizedText: selectedPrompt) // Trigger process
//            }
//        }
//    }
//    
//    private var listeningContent: some View {
//        Text(store.vuiTranscript.isEmpty ? "Đang nghe..." : store.vuiTranscript)
//            .font(.system(size: 34, weight: .semibold))
//            .foregroundColor(.white)
//            .multilineTextAlignment(.center)
//            .frame(minHeight: 100, alignment: .center) // Ensure minimum height
//            .scaleEffect(store.vuiTranscript.isEmpty ? 0.95 : 1.0)
//            .opacity(store.vuiTranscript.isEmpty ? 0.7 : 1.0)
//            .animation(.easeInOut, value: store.vuiTranscript.isEmpty)
//    }
//    
//    private var acknowledgingContent: some View {
//        Text(store.vuiTranscript)
//            .font(.system(size: 28, weight: .medium)) // Slightly smaller
//            .foregroundColor(.white.opacity(showAcknowledgedText ? 0.9 : 0.0)) // Control opacity
//            .multilineTextAlignment(.center)
//            .frame(minHeight: 100, alignment: .center)
//            .onAppear { // Trigger fade-in
//                withAnimation(.easeIn(duration: 0.4)) { showAcknowledgedText = true }
//            }
//    }
//    
//    private var processingContent: some View {
//        VStack(spacing: 15) {
//            ProgressView().scaleEffect(1.5).tint(.white) // Standard spinner
//            Text("Để tôi xem...") // Static processing text
//                .font(.title3).fontWeight(.medium)
//                .foregroundColor(.white.opacity(0.9))
//        }
//        .frame(minHeight: 100, alignment: .center) // Match height of others
//    }
//    
//} // End TakeoverVUIView
//
//// MARK: — 6. Main View (Modified for VUI Overlay)
//
//// Renamed main struct to reflect the file name and version
//struct ChatDemoVUI_v2: View {
//    // State Objects: Own the lifecycle of these crucial objects
//    @StateObject var store = ChatStore()
//    @StateObject var speech = SpeechRecognizer() // Speech Recognizer owned here
//    
//    // Focus state for the input text field
//    @FocusState var isInputFocused: Bool
//    
//    // State for presenting modal sheets
//    @State private var showSettingsSheet = false
//    @State private var showHistorySheet = false
//    
//    var body: some View {
//        ZStack { // Use ZStack to layer VUI on top
//            // Main Chat UI Layer
//            NavigationStack {
//                VStack(spacing: 0) {
//                    chatHeader          // Custom top bar
//                    messagesScrollView  // Scrollable message list
//                    ChatInputBar(       // Bottom input bar
//                        text: $store.input,
//                        store: store,
//                        speech: speech, // Pass speech for mic button action
//                        isFocused: _isInputFocused
//                    )
//                }
//                .navigationBarHidden(true) // Use custom header
//                // Apply effects when VUI is active
//                .blur(radius: store.vuiState != .idle ? 15 : 0) // Increased blur
//                .saturation(store.vuiState != .idle ? 0.8 : 1.0) // Desaturate slightly
//                .scaleEffect(store.vuiState != .idle ? 0.98 : 1.0) // Subtle scale down
//                .animation(.easeInOut(duration: 0.3), value: store.vuiState != .idle) // Animate effects
//                .disabled(store.vuiState != .idle) // Disable interaction behind VUI
//            }
//            // Sheets need to be presented outside the NavigationStack content
//            // if the content itself gets disabled/blurred.
//            // Putting them directly under ZStack ensures they appear on top.
//            
//            // VUI Takeover Overlay Layer (Conditional)
//            if store.vuiState != .idle {
//                TakeoverVUIView(store: store, speech: speech)
//                    .zIndex(10) // Ensure VUI is absolutely on top
//                // Use a spring animation for VUI appearance/disappearance
//                    .transition(.opacity.combined(with: .scale(scale: 0.9)).animation(.interpolatingSpring(stiffness: 250, damping: 25)))
//            }
//        }
//        // Modal Sheet Presentations (Remain at top level)
//        .sheet(isPresented: $showSettingsSheet) {
//            SettingsSheet(store: store) { _, _ in /* Optional callback */ }
//        }
//        .sheet(isPresented: $showHistorySheet) {
//            HistorySheet(
//                conversations: $store.conversations,
//                onDelete: store.deleteConversation, // Pass methods directly
//                onSelect: store.selectConversation,
//                onRename: store.renameConversation,
//                onClear: store.clearHistory
//            )
//        }
//        // Main Chat Error Reporting Alert (Remains at top level)
//        .alert("Lỗi", isPresented: .constant(store.errorMessage != nil), actions: {
//            Button("OK") { store.errorMessage = nil } // Action to dismiss
//        }, message: {
//            Text(store.errorMessage ?? "Đã xảy ra lỗi không xác định.")
//        })
//        .onAppear {
//            // Connect store and speech recognizer logic when the main view appears
//            store.attachRecognizer(speech)
//            // VUI requests auth specifically when mic is tapped, not globally on appear
//        }
//        // Tapping outside input bar to dismiss keyboard (only if VUI is idle)
//        .onTapGesture { if store.vuiState == .idle { isInputFocused = false } }
//        .preferredColorScheme(nil) // Respect system appearance
//        // Ensure speech recognizer stops if VUI becomes idle unexpectedly
//        .onChange(of: store.vuiState) { _, newState in
//            if newState == .idle && speech.isRecording {
//                print("VUI became idle, ensuring speech recognizer stops.")
//                speech.stopRecording()
//            }
//        }
//    }
//    
//    // Custom Header View Component
//    private var chatHeader: some View {
//        HStack(spacing: 10) {
//            Text(store.current.title) // Display current chat title
//                .font(.headline).lineLimit(1)
//                .frame(maxWidth: .infinity, alignment: .leading) // Take available space
//            Spacer() // Push buttons to the right
//            
//            // TTS Status Indicator
//            Group { // Group for applying common modifiers
//                if store.ttsEnabled { Image(systemName: "speaker.wave.2.fill").foregroundColor(.blue) }
//                else { Image(systemName: "speaker.slash.fill").foregroundColor(.gray) }
//            }
//            .imageScale(.medium)
//            .transition(.scale.combined(with: .opacity))
//            .accessibilityLabel(store.ttsEnabled ? "Đọc phản hồi đang bật" : "Đọc phản hồi đang tắt")
//            
//            // History Button
//            Button { showHistorySheet = true } label: { Label("Lịch sử", systemImage: "clock.arrow.circlepath") }
//                .labelStyle(.iconOnly) // Icon only
//            
//            // Settings Button
//            Button { showSettingsSheet = true } label: { Label("Cài đặt", systemImage: "gearshape.fill") }
//                .labelStyle(.iconOnly)
//            
//            // New Chat Button
//            Button { store.resetChat() } label: { Label("Chat Mới", systemImage: "plus.circle.fill") }
//                .labelStyle(.iconOnly)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 10)
//        .background(.thinMaterial) // Subtle background separation
//        .animation(.default, value: store.ttsEnabled) // Animate TTS icon change
//    }
//    
//    // Scrollable View for Messages
//    private var messagesScrollView: some View {
//        ScrollViewReader { proxy in // Allows programmatic scrolling
//            ScrollView {
//                LazyVStack(spacing: 16) { // Spacing between bubbles
//                    // Iterate through messages (excluding system prompt)
//                    ForEach(store.current.messages.filter { $0.role != .system }) { message in
//                        MessageBubble(message: message, onRespeak: store.speak) // Pass respeak action
//                            .id(message.id) // Assign ID for scrolling
//                    }
//                    // Padding at the bottom to push last message up
//                    Color.clear.frame(height: 10).id("bottomPadding")
//                    
//                    // Loading Indicator
//                    if store.isLoading && store.vuiState == .idle { // Only show if VUI is NOT processing
//                        HStack(spacing: 8) {
//                            ProgressView().tint(.secondary)
//                            Text("AI đang suy nghĩ...")
//                                .font(.caption).foregroundColor(.secondary)
//                        }
//                        .padding(.vertical).id("loadingIndicator").transition(.opacity)
//                    }
//                }
//                .padding(.vertical) // Padding inside the scroll view content
//                .padding(.horizontal, 12) // Horizontal padding for bubbles
//            }
//            .background(Color(.systemGroupedBackground)) // Adapts light/dark
//            .scrollDismissesKeyboard(.interactively) // iOS 16+ Interactive dismiss
//            // Scroll logic (unchanged)
//            .onChange(of: store.current.messages.last?.id) { _, newId in scrollToBottom(proxy: proxy, anchor: .bottom) }
//            .onChange(of: store.isLoading) { _, isLoading in if isLoading && store.vuiState == .idle { DispatchQueue.main.asyncAfter(deadline:.now()+0.1){withAnimation{proxy.scrollTo("loadingIndicator",anchor:.bottom)}}}}
//            .onAppear { scrollToBottom(proxy: proxy, anchor: .bottom, animated: false) }
//            .onChange(of: store.current.id) { _, _ in scrollToBottom(proxy: proxy, anchor: .bottom, animated: false) }
//        }
//    }
//    
//    // Helper function for scrolling (unchanged)
//    private func scrollToBottom(proxy: ScrollViewProxy, anchor: UnitPoint?, animated: Bool = true) {
//        DispatchQueue.main.async {
//            let targetId = findScrollTargetId()
//            print("Scrolling to ID: \(targetId)") // Debug print
//            if animated { withAnimation(.spring(duration: 0.4)) { proxy.scrollTo(targetId, anchor: anchor) } }
//            else { proxy.scrollTo(targetId, anchor: anchor) }
//        }
//    }
//    
//    // Helper to determine the target ID for scrolling
//    private func findScrollTargetId() -> AnyHashable {
//        if store.isLoading && store.vuiState == .idle { return "loadingIndicator" }
//        if let lastMessageId = store.current.messages.last?.id { return lastMessageId }
//        return "bottomPadding" // Fallback to padding ID
//    }
//}
//
//// MARK: — 7. Helper Extensions
//
//// Helper to find the topmost view controller (Placeholder - real implementation needed if using UIKit elements)
//extension UIApplication {
//    static var topViewController: UIViewController? {
//        // This requires a more robust implementation depending on the app's structure (scenes, windows, navigation controllers etc.)
//        // For a pure SwiftUI app using ShareLink/standard alerts, this might not be strictly necessary often.
//        print("Warning: Accessing topViewController is a placeholder.")
//        return nil
//    }
//}
//
//// Helper to easily present the standard iOS Share Sheet (Placeholder - ShareLink is preferred in pure SwiftUI)
//extension UIActivityViewController {
//    static func present(text: String) {
//        print("Warning: UIActivityViewController.present is a placeholder. Use ShareLink in SwiftUI.")
//    }
//}
//
//// MARK: — 8. Preview Provider
//
//// Previews for the main chat view and VUI states
//#Preview("Chat View - Light") {
//    let previewStore = ChatStore()
//    previewStore.current.messages.append(Message.user("Đây là tin nhắn của người dùng."))
//    previewStore.current.messages.append(Message.assistant("Đây là phản hồi của trợ lý."))
//    return ChatDemoVUI_v2(store: previewStore, speech: SpeechRecognizer()) // Pass required StateObjects
//        .preferredColorScheme(.light)
//}
//
//#Preview("Chat View - Dark") {
//    let previewStore = ChatStore()
//    previewStore.current.messages.append(Message.user("Another user message example."))
//    previewStore.current.messages.append(Message.assistant("A slightly longer assistant reply to test wrapping and layout."))
//    return ChatDemoVUI_v2(store: previewStore, speech: SpeechRecognizer())
//        .preferredColorScheme(.dark)
//}
//
//#Preview("VUI Overlay - Prompting") {
//    let store = ChatStore(); store.vuiState = .prompting
//    return TakeoverVUIView(store: store, speech: SpeechRecognizer())
//        .background(Color.gray.opacity(0.5)) // Context background
//        .preferredColorScheme(.dark)
//}
//
//#Preview("VUI Overlay - Listening") {
//    let store = ChatStore(); let speech = SpeechRecognizer()
//    store.vuiState = .listening; store.vuiTranscript = "Nói cho tôi nghe về SwiftUI đi"
//    speech.isRecording = true; speech.audioLevel = 0.7
//    return TakeoverVUIView(store: store, speech: speech)
//        .background(Color.gray.opacity(0.5))
//        .preferredColorScheme(.dark)
//}
//
//#Preview("VUI Overlay - Acknowledging") {
//    let store = ChatStore(); store.vuiState = .acknowledging
//    store.vuiTranscript = "Thời tiết ngày mai thế nào?"
//    return TakeoverVUIView(store: store, speech: SpeechRecognizer())
//        .background(Color.gray.opacity(0.5))
//        .preferredColorScheme(.dark)
//}
//
//#Preview("VUI Overlay - Processing") {
//    let store = ChatStore(); store.vuiState = .processing
//    return TakeoverVUIView(store: store, speech: SpeechRecognizer())
//        .background(Color.gray.opacity(0.5))
//        .preferredColorScheme(.dark)
//}
