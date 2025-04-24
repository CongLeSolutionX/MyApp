////
////  ChatApp_UsingAppleVoiceUserInterfaceDesign_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/22/25.
////
//
////
////  SynthesizedChatApp_With_TakeoverVUI.swift
////  Single-file SwiftUI Chat Demo with Takeover Voice UI
////
////  Combines Mock, OpenAI, CoreML backends with Text & Speech I/O.
////  Integrates a modal "Takeover Interface" for voice input,
////  inspired by the provided VUI design image.
////
////  Requires: Xcode 15+, iOS 17+
////
//
//import SwiftUI
//import Combine
//import Speech // For Speech Recognition (Input)
//import AVFoundation // For Text-to-Speech (Output) & Audio Session Management
//import CoreML // For potential local model inference
//
//// MARK: --- Configuration ---
//// Replace with your actual API key or leave empty to use Mock/CoreML
//let DEFAULT_OPENAI_API_KEY = ""
//// Name of your *compiled* CoreML model in the bundle (e.g., "MyChatModel.mlmodelc")
//let DEFAULT_COREML_MODEL_NAME = "TinyChat" // Ensure this exists in your project
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
//    // Static factory methods for convenience
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
//    func streamChat(
//        messages: [Message],
//        systemPrompt: String,
//        completion: @escaping (Result<String, Error>) -> Void)
//    {
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
//        struct RequestPayload: Encodable {
//            struct MessagePayload: Encodable { let role: String; let content: String }
//            let model: String
//            let messages: [MessagePayload]
//            let temperature: Double
//            let max_tokens: Int
//        }
//
//        let body = RequestPayload(
//            model: self.model,
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
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let networkError = error {
//                DispatchQueue.main.async { completion(.failure(networkError)) }
//                return
//            }
//            guard let responseData = data else {
//                DispatchQueue.main.async { completion(.failure(NSError(domain: "NoData", code: 1))) }
//                return
//            }
//
//            struct ResponsePayload: Decodable {
//                struct Choice: Decodable {
//                    struct Message: Decodable { let content: String }
//                    let message: Message
//                }
//                let choices: [Choice]
//            }
//
//            do {
//                let decodedResponse = try JSONDecoder().decode(ResponsePayload.self, from: responseData)
//                let replyText = decodedResponse.choices.first?.message.content ?? "Xin lỗi, tôi không nhận được phản hồi."
//                DispatchQueue.main.async { completion(.success(replyText)) }
//            } catch {
//                struct ErrorResponse: Decodable {
//                    struct ErrorDetail: Decodable { let message: String }
//                    let error: ErrorDetail?
//                }
//                let errorMsg: String
//                if let decodedError = try? JSONDecoder().decode(ErrorResponse.self, from: responseData),
//                   let message = decodedError.error?.message {
//                    errorMsg = "API Error: \(message)"
//                } else {
//                    errorMsg = "Lỗi giải mã phản hồi: \(error.localizedDescription)"
//                }
//                let wrappedError = NSError(domain: "DecodingError", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMsg])
//                DispatchQueue.main.async { completion(.failure(wrappedError)) }
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
//// Implementation using a local CoreML model
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
//    }
//}
//// MARK: — 3. Speech Recognizer (Speech-to-Text - V5 Logic)
//
//final class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
//    // Published properties to update the UI
//    @Published var transcript = ""
//    @Published var isRecording = false
//    @Published var errorMessage: String?
//
//    // Callback for when transcription is finalized (called by V5 finish logic)
//    var onFinalTranscription: ((String) -> Void)?
//
//    // Speech recognition components
//    private let recognizer: SFSpeechRecognizer?
//    private let audioEngine = AVAudioEngine()
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//
//    // Silence detection mechanism (V5 logic)
//    private let silenceTimeout: TimeInterval = 1.8
//    private var silenceWork: DispatchWorkItem?
//
//    override init() {
//        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN"))
//        super.init()
//        self.recognizer?.delegate = self
//    }
//
//    func requestAuthorization(completion: @escaping (Bool) -> Void) {
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            let authorized = authStatus == .authorized
//            DispatchQueue.main.async {
//                if !authorized {
//                    self.errorMessage = "Quyền truy cập microphone và nhận dạng giọng nói là cần thiết. Vui lòng bật trong Cài đặt."
//                } else {
//                    self.errorMessage = nil
//                }
//                completion(authorized)
//            }
//        }
//    }
//
//    func startRecording() throws {
//        // Reset state
//        errorMessage = nil
//        transcript = "" // Reset transcript on new start
//        recognitionTask?.cancel(); recognitionTask = nil
//        recognitionRequest?.endAudio(); recognitionRequest = nil
//        silenceWork?.cancel(); silenceWork = nil
//
//        // Configure audio session (moved inside start to ensure it's set correctly)
//        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//
//        // Create recognition request
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            fatalError("Unable to create SFSpeechAudioBufferRecognitionRequest")
//        }
//        recognitionRequest.shouldReportPartialResults = true
//        recognitionRequest.taskHint = .dictation
//
//        // Check recognizer availability
//        guard let speechRecognizer = recognizer, speechRecognizer.isAvailable else {
//            errorMessage = "Bộ nhận dạng giọng nói không khả dụng cho tiếng Việt."
//            isRecording = false // Set recording state correctly on failure
//             try? audioSession.setActive(false) // Deactivate session if started
//            throw NSError(domain: "SpeechRecognizerError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage!])
//        }
//
//        // Must update state *before* starting task/engine
//        isRecording = true // Set state *before* starting async task
//
//        // Start recognition task
//        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//            guard let self = self else { return } // Ensure self is valid
//
//            var isFinal = false
//
//            if let result = result {
//                // VUI: Update transcript for live feedback
//                  let newTranscript = result.bestTranscription.formattedString
//                   // Update only if it changed to avoid unnecessary UI refreshes
//                   if self.transcript != newTranscript {
//                      DispatchQueue.main.async {
//                          self.transcript = newTranscript
//                      }
//                  }
//                isFinal = result.isFinal
//                if isFinal {
//                     // V5 Logic: Call finish with the final text
//                     self.finish(self.transcript)
//                } else {
//                    // Reset silence timer for V5 logic (scheduleSilence)
//                    self.scheduleSilence()
//                }
//            }
//
//            // VUI: Handle errors clearly
//            if error != nil {
//                // Only update error and stop if we are still considered to be recording
//                 if self.isRecording {
//                     DispatchQueue.main.async {
//                         if let anError = error {
//                              if (anError as NSError).code == 203 && self.transcript.isEmpty {
//                                  self.errorMessage = "Không nghe thấy gì. Vui lòng thử lại."
//                              } else if (anError as NSError).domain == NSURLErrorDomain {
//                                   self.errorMessage = "Lỗi mạng, không thể nhận dạng."
//                              } else {
//                                  self.errorMessage = "Lỗi nhận dạng: \(anError.localizedDescription)"
//                              }
//                          }
//                         self.stopRecording() // Call modified stop on error
//                     }
//                 }
//            } else if isFinal {
//                 // Already handled calling finish above
//                 self.stopRecording() // Stop audio parts even if finish was called
//            }
//        }
//
//        // Configure audio engine input node
//        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
//        audioEngine.inputNode.removeTap(onBus: 0) // Remove existing tap first
//        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            // Append buffer only if request exists
//             guard let request = self.recognitionRequest else { return }
//            request.append(buffer)
//        }
//
//        // Prepare and start audio engine
//        audioEngine.prepare()
//        try audioEngine.start()
//
//        // Start the initial silence timer (V5 logic)
//        scheduleSilence()
//        print("Speech Recognizer: Recording Started.")
//    }
//
//    // V5 Silence Detection Logic
//    private func scheduleSilence() {
//       silenceWork?.cancel()
//       let wi = DispatchWorkItem { [weak self] in
//           guard let self = self, self.isRecording else { return }
//           print("Speech Recognizer: Silence detected.")
//           self.finish(self.transcript) // Call V5 finish logic
//       }
//       silenceWork = wi
//       DispatchQueue.main.asyncAfter(deadline: .now() + silenceTimeout, execute: wi)
//   }
//
//   // V5 Finish Logic
//   private func finish(_ text: String) {
//       // This can be called multiple times (e.g., silence + task ending), add guard
//       guard isRecording else {
//            print("Speech Recognizer: Finish called but already stopped.")
//           return
//       }
//       print("Speech Recognizer: Finish called with transcript: '\(text)'")
//       onFinalTranscription?(text) // Trigger the callback
//       stopRecording() // Ensure cleanup happens
//   }
//
//    // Stop audio engine, invalidate timers, clean up resources (Modified for V5 compatibility)
//   func stopRecording() {
//      guard isRecording else {
//          print("Speech Recognizer: Stop called but not recording.")
//          return
//      } // Check if actually recording
//      print("Speech Recognizer: Stopping recording...")
//       isRecording = false // Update state immediately
//
//       silenceWork?.cancel(); silenceWork = nil
//
//       // Only stop engine/tasks if they were potentially running
//       if audioEngine.isRunning {
//           audioEngine.stop()
//           audioEngine.inputNode.removeTap(onBus: 0)
//           print("Speech Recognizer: Audio engine stopped and tap removed.")
//        } else {
//            print("Speech Recognizer: Audio engine was not running.")
//        }
//
//       // Safely end/cancel request and task
//        recognitionRequest?.endAudio()
//        recognitionTask?.cancel() // Cancel is safer than finish if called manually
//
//       // Deactivate audio session
//       do {
//           try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//           print("Speech Recognizer: Audio session deactivated.")
//       } catch {
//           print("Speech Recognizer: Error deactivating audio session: \(error.localizedDescription)")
//       }
//
//       // Nullify task and request AFTER stopping engine and session
//       recognitionTask = nil
//       recognitionRequest = nil
//       print("Speech Recognizer: Recording stopped completely.")
//   }
//
//    // SFSpeechRecognizerDelegate method (optional)
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        DispatchQueue.main.async {
//            if !available {
//                self.errorMessage = "Bộ nhận dạng giọng nói không còn khả dụng."
//                if self.isRecording {
//                    self.stopRecording()
//                }
//            } else {
//                 self.errorMessage = nil
//            }
//        }
//    }
//}
//
//// MARK: — 4. ViewModel (Central State Management)
//@MainActor
//final class ChatStore: ObservableObject {
//    // MARK: - Published Properties (UI State)
//    @Published var conversations: [Conversation] = [] { didSet { saveToDisk() } }
//    @Published var current: Conversation // Will be initialized below
//    @Published var input: String = "" // Used for text input bar, not the VUI transcript
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//
//    // Settings synced with UserDefaults
//    @AppStorage("system_prompt") var systemPrompt: String = "Bạn là một trợ lý AI hữu ích nói tiếng Việt."
//    @AppStorage("tts_enabled") var ttsEnabled: Bool = false
//    @AppStorage("tts_rate") var ttsRate: Double = 1.0
//    @AppStorage("tts_voice_id") var ttsVoiceID: String = ""
//    @AppStorage("openai_api_key") var apiKey: String = DEFAULT_OPENAI_API_KEY
//    @AppStorage("backend_type") private var backendTypeRaw: String = BackendType.mock.rawValue
//    @AppStorage("coreml_model_name") var coreMLModelName: String = DEFAULT_COREML_MODEL_NAME
//    @AppStorage("openai_model_name") var openAIModelName: String = "gpt-4o"
//    @AppStorage("openai_temperature") var openAITemperature: Double = 0.7
//    @AppStorage("openai_max_tokens") var openAIMaxTokens: Int = 512
//
//    // Available models for settings
//    let availableCoreMLModels = ["TinyChat", "LocalChat"] // Example names
//    let availableOpenAIModels = ["gpt-4o", "gpt-4-turbo", "gpt-3.5-turbo"]
//    let availableVoices: [AVSpeechSynthesisVoice]
//
//    // MARK: - Private Properties
//    private(set) var backend: ChatBackend
//    private let ttsSynth = AVSpeechSynthesizer()
//    private var ttsDelegate: TTSSpeechDelegate?
//
//    // MARK: - Computed Properties
//    var backendType: BackendType {
//        get { BackendType(rawValue: backendTypeRaw) ?? .mock }
//        set { backendTypeRaw = newValue.rawValue; configureBackend() }
//    }
//
//    // MARK: - Initialization
//    init() {
//        self.availableVoices = AVSpeechSynthesisVoice.speechVoices().sorted { v1, v2 in
//            let v1Vi = v1.language.starts(with: "vi")
//            let v2Vi = v2.language.starts(with: "vi")
//            if v1Vi != v2Vi { return v1Vi }
//            return v1.name < v2.name
//        }
//        self.backend = MockChatBackend() // Temp backend
//        self.ttsDelegate = TTSSpeechDelegate()
//        self.current = Conversation(id: UUID(), title: "", messages: []) // Temp current
//
//        // --- Phase 2 ---
//        self.ttsSynth.delegate = self.ttsDelegate
//
//        let initialTTSVoiceID = self.ttsVoiceID
//        if initialTTSVoiceID.isEmpty || self.availableVoices.first(where: { $0.identifier == initialTTSVoiceID }) == nil {
//            self.ttsVoiceID = self.availableVoices.first(where: {$0.language.starts(with: "vi-VN")})?.identifier ?? availableVoices.first?.identifier ?? ""
//        }
//
//        let realInitialConversation = Conversation(messages: [.system(self.systemPrompt)])
//
//        loadFromDisk() // Load history
//        configureBackend() // Configure actual backend based on loaded settings
//
//        // Assign final 'current'
//        if let mostRecent = conversations.first {
//            self.current = mostRecent
//            // Ensure system prompt consistency if needed
//             if self.current.messages.first?.role != .system {
//                 self.current.messages.insert(.system(self.systemPrompt), at: 0)
//                 if let index = self.conversations.firstIndex(where: { $0.id == self.current.id }) {
//                     self.conversations[index] = self.current
//                 }
//             }
//        } else {
//            self.current = realInitialConversation
//        }
//
//        print("ChatStore Initialized. Backend: \(backendType), Current Convo ID: \(current.id)")
//    }
//
//    // MARK: - Backend Management
//    func setBackend(_ newBackend: ChatBackend, type: BackendType) {
//        backend = newBackend
//        backendType = type // Use computed property setter to trigger configure
//        print("Backend explicitly set to: \(type.rawValue)")
//    }
//
//    private func configureBackend() {
//        print("Configuring backend for type: \(self.backendType.rawValue)")
//
//        // Safety checks before creating backend instances
//        if self.backendType == .openAI && self.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            print("Warning: OpenAI backend selected but API key is missing. Falling back to Mock.")
//            DispatchQueue.main.async { [weak self] in
//                 guard let self = self, self.backendType != .mock else { return }
//                 self.errorMessage = "Khóa API OpenAI bị thiếu. Sử dụng Mock backend."
//                 self.backend = MockChatBackend()
//                 self.backendTypeRaw = BackendType.mock.rawValue // Update storage directly
//            }
//            return
//        }
//         if self.backendType == .coreML {
//            let coreMLCheck = CoreMLChatBackend(modelName: self.coreMLModelName)
//             if coreMLCheck.coreModel == nil {
//                print("Warning: CoreML model '\(self.coreMLModelName)' failed to load. Falling back to Mock.")
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self, self.backendType != .mock else { return }
//                    self.errorMessage = "Không tải được mô hình CoreML '\(self.coreMLModelName)'. Sử dụng Mock backend."
//                    self.backend = MockChatBackend()
//                    self.backendTypeRaw = BackendType.mock.rawValue
//                }
//                return
//            }
//             self.backend = coreMLCheck // Assign the checked instance
//             print("CoreML Backend configured successfully.")
//             return // Explicit return after successful CoreML config
//        }
//
//        // Configure other backends if checks passed or not applicable
//        switch self.backendType {
//        case .mock:
//            self.backend = MockChatBackend()
//        case .openAI:
//             // Key presence was checked earlier
//            self.backend = RealOpenAIBackend(
//                apiKey: self.apiKey.trimmingCharacters(in: .whitespacesAndNewlines),
//                model: self.openAIModelName,
//                temperature: self.openAITemperature,
//                maxTokens: self.openAIMaxTokens
//            )
//         case .coreML:
//             // Should have been handled above, but include as safeguard
//             print("Re-checking CoreML configuration.")
//             let coreMLCheck = CoreMLChatBackend(modelName: self.coreMLModelName)
//             self.backend = (coreMLCheck.coreModel != nil) ? coreMLCheck : MockChatBackend()
//        }
//        print("Backend configured successfully to: \(self.backendType.rawValue)")
//    }
//
//    // MARK: - Chat Actions
//    func resetChat() {
//        stopSpeaking()
//        self.current = Conversation(messages: [.system(self.systemPrompt)])
//        self.input = "" // Clear text input too
//        self.isLoading = false
//        self.errorMessage = nil
//        print("Chat reset.")
//    }
//
//    // Used for sending text from the input bar OR from voice commands
//    func sendMessage(_ text: String) {
//        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        // Allow sending even if isLoading is true (e.g., user manually sent during voice processing)
//        // but avoid sending empty messages.
//        guard !trimmedText.isEmpty else { return }
//
//        stopSpeaking()
//
//        let userMessage = Message.user(trimmedText)
//        current.messages.append(userMessage)
//
//        // Clear text input if this came from the text field
//        if self.input == text { // Check if it matches the state bound to TextField
//            self.input = ""
//        }
//
//        // Only set loading if not already loading (prevents flicker if user sends text while voice processes)
//        if !isLoading {
//            isLoading = true
//        }
//        errorMessage = nil
//
//        // Create a copy _after_ adding the user message
//        let messagesForBackend = current.messages
//
//        print("Sending messages to backend (\(backendType.rawValue)). Count: \(messagesForBackend.count)")
//
//        backend.streamChat(messages: messagesForBackend, systemPrompt: systemPrompt) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                self.isLoading = false // Always turn off loading when response arrives
//
//                switch result {
//                case .success(let replyText):
//                    print("Received reply: \(replyText.prefix(50))...")
//                    let assistantMessage = Message.assistant(replyText)
//                    if !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                        self.current.messages.append(assistantMessage)
//                        self.upsertConversation() // Save history
//                    } else {
//                        print("Received empty reply from backend.")
//                    }
//
//                    if self.ttsEnabled && !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                        self.speak(replyText)
//                    }
//
//                case .failure(let error):
//                    print("Backend error: \(error.localizedDescription)")
//                    self.errorMessage = "Lỗi Backend: \(error.localizedDescription)"
//                    // Optionally remove the user's message that failed
//                    // if self.current.messages.last?.id == userMessage.id {
//                    //      self.current.messages.removeLast()
//                    // }
//                }
//            }
//        }
//    }
//
//    func speak(_ text: String) {
//       guard ttsEnabled, !text.isEmpty else { return }
//
//       // Re-assign delegate if needed (might be nil initially)
//       if ttsSynth.delegate == nil {
//           ttsDelegate = TTSSpeechDelegate() // Ensure delegate exists
//           ttsSynth.delegate = ttsDelegate
//       }
//
//       // Ensure correct audio configuration before speaking
//       do {
//           let currentCategory = AVAudioSession.sharedInstance().category
//           if currentCategory != .playback && currentCategory != .playAndRecord { // Allow playAndRecord too
//                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
//                print("Set audio session category to playback for TTS.")
//           }
//       } catch {
//           print("Failed to set audio session category for TTS: \(error)")
//       }
//
//       let utterance = AVSpeechUtterance(string: text)
//       utterance.rate = Float(ttsRate) * AVSpeechUtteranceDefaultSpeechRate
//       utterance.voice = AVSpeechSynthesisVoice(identifier: ttsVoiceID)
//           ?? AVSpeechSynthesisVoice(language: "vi-VN")
//           ?? AVSpeechSynthesisVoice.speechVoices().first
//
//       if ttsSynth.isSpeaking {
//           ttsSynth.stopSpeaking(at: .word)
//           // Short delay before speaking new utterance
//           DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
//                 self?.ttsSynth.speak(utterance)
//             }
//       } else {
//           ttsSynth.speak(utterance)
//       }
//       print("Attempting to speak: \(text.prefix(30))...")
//   }
//
//   func stopSpeaking() {
//       if ttsSynth.isSpeaking {
//           ttsSynth.stopSpeaking(at: .word)
//           print("Stopped speaking.")
//           // Delegate handles audio session deactivation
//       }
//   }
//
//    // MARK: - History Management
//    func deleteConversation(id: UUID) {
//        conversations.removeAll { $0.id == id }
//        if current.id == id {
//            resetChat()
//        }
//        print("Deleted conversation: \(id). Remaining: \(conversations.count)")
//    }
//
//    func selectConversation(_ conversation: Conversation) {
//        stopSpeaking()
//        var selectedConvo = conversation
//        if selectedConvo.messages.first?.role != .system {
//            selectedConvo.messages.insert(.system(self.systemPrompt), at: 0)
//        }
//        self.current = selectedConvo
//        print("Selected conversation: \(current.id) - \(current.title)")
//    }
//
//    func renameConversation(_ conversation: Conversation, to newTitle: String) {
//        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedTitle.isEmpty, let index = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
//        conversations[index].title = trimmedTitle
//        if current.id == conversation.id {
//            current.title = trimmedTitle
//        }
//        print("Renamed conversation \(conversation.id) to: \(trimmedTitle)")
//    }
//
//    func clearHistory() {
//        stopSpeaking()
//        conversations.removeAll()
//        resetChat()
//        print("Cleared all conversation history.")
//    }
//
//    // MARK: - Voice Command Handling (Triggered by SpeechRecognizer's onFinalTranscription)
//    func attachRecognizer(_ sr: SpeechRecognizer) {
//        sr.onFinalTranscription = { [weak self] text in
//            DispatchQueue.main.async {
//                 self?.handleVoiceCommand(text)
//            }
//        }
//    }
//
//    private func handleVoiceCommand(_ command: String) {
//        let lowercasedCommand = command.lowercased().trimmingCharacters(in: .whitespaces)
//        guard !lowercasedCommand.isEmpty else {
//             print("Voice command discarded: Empty transcript.")
//            return
//        }
//        print("Handling voice command: '\(lowercasedCommand)'")
//
//        // Map commands to specific actions
//        let commandActions: [String: () -> Void] = [
//            "chat mới": { self.resetChat() },
//            "new chat": { self.resetChat() },
//            "bật đọc": { self.ttsEnabled = true },
//            "tts on": { self.ttsEnabled = true },
//            "tắt đọc": { self.ttsEnabled = false },
//            "tts off": { self.ttsEnabled = false },
//            "dùng mock": { self.attemptSetBackend(.mock) },
//            "use mock": { self.attemptSetBackend(.mock) },
//            "dùng open ai": { self.attemptSetBackend(.openAI) },
//            "dùng real": { self.attemptSetBackend(.openAI) },
//            "use real": { self.attemptSetBackend(.openAI) },
//            "dùng coreml": { self.attemptSetBackend(.coreML) },
//            "dùng local": { self.attemptSetBackend(.coreML) },
//            "use coreml": { self.attemptSetBackend(.coreML) },
//            "use local": { self.attemptSetBackend(.coreML) }
//        ]
//
//        // Execute command if found, otherwise send as message
//        if let action = commandActions[lowercasedCommand] {
//            action()
//             self.speak("Đã thực hiện: \(command)") // Optional feedback for commands
//        } else {
//            print("Voice command not recognized, sending as message.")
//            let originalCommand = command.trimmingCharacters(in: .whitespaces)
//            if !originalCommand.isEmpty {
//                sendMessage(originalCommand) // Send the original casing
//            }
//        }
//    }
//
//    // Helper for voice command backend switching with checks
//    private func attemptSetBackend(_ type: BackendType) {
//        guard type != self.backendType else {
//            print("Voice command ignored: Backend type already set to \(type.rawValue).")
//             if ttsEnabled { speak("Backend đã là \(type.rawValue).") }
//            return
//        }
//
//        var canSwitch = true
//        var failureMessage = ""
//
//        switch type {
//        case .openAI:
//            if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                canSwitch = false
//                failureMessage = "Thiếu API key để dùng OpenAI."
//            }
//        case .coreML:
//            let tempBackend = CoreMLChatBackend(modelName: coreMLModelName)
//            if tempBackend.coreModel == nil {
//                canSwitch = false
//                failureMessage = "Không thể tải mô hình CoreML \(coreMLModelName)."
//            }
//         case .mock:
//             break // Always possible to switch to mock
//        }
//
//        if canSwitch {
//            print("Setting backend to \(type.rawValue) via voice command.")
//             backendType = type // Trigger setter and reconfiguration
//             if ttsEnabled { speak("Đã chuyển sang backend \(type.rawValue).") }
//        } else {
//            print("Voice command failed: \(failureMessage)")
//            errorMessage = failureMessage
//             if ttsEnabled { speak(failureMessage) }
//        }
//    }
//
//    // MARK: - Persistence
//    private func loadFromDisk() {
//        guard let data = UserDefaults.standard.data(forKey: "ChatHistory_v2") else {
//            print("No chat history found in UserDefaults.")
//            self.conversations = []
//            return
//        }
//        do {
//            let decoder = JSONDecoder()
//            let loadedConversations = try decoder.decode([Conversation].self, from: data)
//            self.conversations = loadedConversations.filter { convo in
//                convo.messages.contains { $0.role == .user }
//            }
//            print("Loaded \(self.conversations.count) valid conversations from UserDefaults.")
//        } catch {
//            print("Failed to decode chat history: \(error). Clearing corrupted data.")
//            self.conversations = []
//            UserDefaults.standard.removeObject(forKey: "ChatHistory_v2")
//            DispatchQueue.main.async {
//                self.errorMessage = "Lịch sử chat bị lỗi và đã được xóa."
//            }
//        }
//    }
//
//    private func saveToDisk() {
//         let validConversations = conversations.filter { convo in
//             !convo.title.isEmpty && convo.messages.contains { $0.role == .user }
//         }
//
//        guard !validConversations.isEmpty else {
//            if UserDefaults.standard.object(forKey: "ChatHistory_v2") != nil {
//                UserDefaults.standard.removeObject(forKey: "ChatHistory_v2")
//                print("Removed chat history key from UserDefaults as no valid conversations remain.")
//            }
//            return
//        }
//        do {
//            let encoder = JSONEncoder()
//            let data = try encoder.encode(validConversations)
//            UserDefaults.standard.set(data, forKey: "ChatHistory_v2")
//            print("Saved \(validConversations.count) conversations to UserDefaults.")
//        } catch {
//            print("Failed to encode chat history: \(error)")
//            errorMessage = "Không thể lưu lịch sử chat." // Update error message
//        }
//    }
//
//    func upsertConversation() {
//        guard current.messages.contains(where: { $0.role == .user }) else { return }
//
//        let generatedTitle = String(current.messages.first(where: { $0.role == .user })?.content.prefix(32) ?? "Chat")
//        if current.title.isEmpty || current.title == "Loading..." || current.title == "New Chat" {
//            current.title = generatedTitle
//        } else {
//            current.title = current.title.trimmingCharacters(in: .whitespacesAndNewlines)
//            if current.title.isEmpty { current.title = generatedTitle }
//        }
//
//        if let index = conversations.firstIndex(where: { $0.id == current.id }) {
//            print("Upserting: Updating conversation ID \(current.id)")
//            conversations[index] = current
//        } else {
//             if current.title != "New Chat" || current.messages.count > 1 {
//                 print("Upserting: Inserting new conversation ID \(current.id) with title '\(current.title)'")
//                 conversations.insert(current, at: 0)
//             } else {
//                 print("Upserting: Skipping insert for initial placeholder.")
//             }
//        }
//    }
//}
//
//// MARK: - 4.1 TTS Delegate
//
//class TTSSpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        do {
//             let currentCategory = AVAudioSession.sharedInstance().category
//             // Set category only if needed, avoid interrupting recording if possible
//             if currentCategory != .playback && currentCategory != .playAndRecord {
//                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
//             }
//            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
//            print("TTS Delegate: Audio session activated.")
//        } catch {
//            print("TTS Delegate: Error activating audio session: \(error)")
//        }
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
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            do {
//                // Check if another synthesizer started quickly
//                let synth = AVSpeechSynthesizer() // Create temp instance to check global state
//                if !synth.isSpeaking {
//                    try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//                    print("TTS Delegate: Audio session deactivated.")
//                } else {
//                     print("TTS Delegate: Synthesizer restarted, keeping session active.")
//                 }
//            } catch {
//                print("TTS Delegate: Error deactivating audio session: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: — 5. UI Subviews
//
//struct MessageBubble: View {
//    let message: Message
//    let onRespeak: (String) -> Void // Callback to trigger TTS for this message
//
//    var isUser: Bool { message.role == .user }
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            if isUser { Spacer(minLength: 40) }
//
//            if message.role == .assistant {
//                Image(systemName: "sparkles.circle.fill") // Use filled icon for assistant
//                    .foregroundColor(.purple)
//                    .font(.title3) // Make icon slightly larger
//                    .padding(.bottom, isUser ? 0 : 5) // Align better
//            }
//
//            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
//                Text(message.content)
//                    .textSelection(.enabled)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .background(isUser ? Color.blue.opacity(0.9) : Color.secondary.opacity(0.2)) // Use secondary for assistant
//                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                    .foregroundColor(isUser ? .white : .primary)
//                    .frame(minWidth: 20)
//                    .fixedSize(horizontal: false, vertical: true)
//
//                Text(message.timestamp, style: .time)
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            }
//
//            if message.role == .user {
//                Image(systemName: "person.crop.circle.fill") // Use filled icon for user
//                    .foregroundColor(.blue)
//                     .font(.title3) // Match assistant icon size
//                    .padding(.bottom, isUser ? 5 : 0)
//            }
//
//            if !isUser { Spacer(minLength: 40) }
//        }
//        .contextMenu {
//            Button { UIPasteboard.general.string = message.content } label: {
//                Label("Copy Text", systemImage: "doc.on.doc")
//            }
//            if message.role == .assistant && !message.content.isEmpty {
//                Button { onRespeak(message.content) } label: {
//                    Label("Đọc Lại", systemImage: "speaker.wave.2.fill")
//                }
//            }
//            if !message.content.isEmpty {
//                ShareLink(item: message.content) {
//                    Label("Chia sẻ Tin nhắn", systemImage: "square.and.arrow.up")
//                }
//            }
//        }
//        .padding(.vertical, 2)
//    }
//}
//
//// MARK: Chat Input Bar (Modified for Takeover VUI)
//struct ChatInputBar: View {
//    @Binding var text: String
//    @ObservedObject var store: ChatStore // Needed for isLoading state
//    var onMicButtonTapped: () -> Void // Closure to trigger the VUI sheet
//
//    @FocusState var isFocused: Bool
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // --- Main Input Bar Row ---
//            HStack(spacing: 8) {
//                TextField("Gõ hoặc bấm micro để nói…", // Updated placeholder
//                          text: $text,
//                          axis: .vertical)
//                .focused($isFocused)
//                .lineLimit(1...4)
//                .padding(8)
//                .background(Color(.secondarySystemBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
//                            .stroke(isFocused ? Color.blue.opacity(0.5) : Color.gray.opacity(0.3)))
//                .disabled(store.isLoading) // Keep textfield disabled while loading
//
//                // -- Mic Button (Triggers Takeover Sheet) ---
//                micButton
//
//                // -- Send Button (Standard text send) ---
//                sendButton
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 6)
//            .background(.thinMaterial)
//        }
//    }
//
//    // --- Mic Button (NEW: Triggers sheet presentation) ---
//    private var micButton: some View {
//         Button {
//             print("ChatInputBar: Mic button tapped.")
//             isFocused = false // Dismiss keyboard
//             onMicButtonTapped() // Call the closure to show the sheet
//         } label: {
//             Image(systemName: "mic.circle.fill") // Consistent filled icon
//                 .resizable()
//                 .scaledToFit()
//                 .frame(width: 28, height: 28)
//                 .foregroundColor(store.isLoading ? .gray.opacity(0.5) : .blue) // Dim if loading
//         }
//         .disabled(store.isLoading) // Disable if store is processing backend request
//         .accessibilityLabel("Bắt đầu nhập liệu bằng giọng nói")
//    }
//
//    // Send Button View (Standard text send)
//    private var sendButton: some View {
//        Button {
//             let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//             if !trimmedText.isEmpty && !store.isLoading {
//                 store.sendMessage(trimmedText)
//                 text = ""
//             }
//        } label: {
//             Image(systemName: "arrow.up.circle.fill")
//                 .resizable()
//                 .scaledToFit()
//                 .frame(width: 28, height: 28)
//                 .foregroundColor(
//                     text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isLoading
//                     ? .gray.opacity(0.5) : .blue
//                 )
//        }
//        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isLoading)
//        .transition(.opacity.combined(with: .scale))
//        .accessibilityLabel("Gửi tin nhắn")
//    }
//}
//
//// Settings View Presented as a Sheet (No change from previous version)
//struct SettingsSheet: View {
//    @ObservedObject var store: ChatStore
//    @State private var localApiKey: String
//    @State private var localOpenAIModelName: String
//    @State private var localOpenAITemperature: Double
//    @State private var localOpenAIMaxTokens: Int
//    @State private var localBackendType: BackendType
//    @State private var localCoreMLModelName: String
//    @State private var localSystemPrompt: String
//    @State private var localTtsEnabled: Bool
//    @State private var localTtsRate: Float
//    @State private var localTtsVoiceID: String
//
//    @Environment(\.dismiss) var dismiss
//
//    init(store: ChatStore) {
//        self.store = store
//        // Initialize local state from the store's current values
//        _localApiKey = State(initialValue: store.apiKey)
//        _localOpenAIModelName = State(initialValue: store.openAIModelName)
//        _localOpenAITemperature = State(initialValue: store.openAITemperature)
//        _localOpenAIMaxTokens = State(initialValue: store.openAIMaxTokens)
//        _localBackendType = State(initialValue: store.backendType)
//        _localCoreMLModelName = State(initialValue: store.coreMLModelName)
//        _localSystemPrompt = State(initialValue: store.systemPrompt)
//        _localTtsEnabled = State(initialValue: store.ttsEnabled)
//        _localTtsRate = State(initialValue: Float(store.ttsRate))
//        _localTtsVoiceID = State(initialValue: store.ttsVoiceID)
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
//                    .pickerStyle(.menu)
//
//                    if localBackendType == .coreML {
//                        Picker("Chọn CoreML Model", selection: $localCoreMLModelName) {
//                            ForEach(store.availableCoreMLModels, id: \.self) { Text($0).tag($0) }
//                        }
//                    }
//                    Text("Backend hiện tại: \(store.backendType.rawValue)").font(.caption).foregroundColor(.secondary)
//                }
//
//                // MARK: OpenAI Configuration (Conditional)
//                if localBackendType == .openAI {
//                   Section("Cấu hình OpenAI") {
//                        Picker("Model", selection: $localOpenAIModelName) {
//                            ForEach(store.availableOpenAIModels, id: \.self) { Text($0) }
//                        }
//
//                        HStack {
//                           Text("Nhiệt độ:")
//                           Slider(value: $localOpenAITemperature, in: 0...1, step: 0.05)
//                            Text("\(localOpenAITemperature, specifier: "%.2f")").frame(width: 40, alignment: .trailing)
//                         }
//
//                       Stepper("Tokens Tối đa: \(localOpenAIMaxTokens)", value: $localOpenAIMaxTokens, in: 64...4096, step: 64)
//
//                        SecureField("API Key (openai.com)", text: $localApiKey)
//                            .textContentType(.password)
//                            .autocapitalization(.none)
//                            .disableAutocorrection(true)
//
//                       if localApiKey.isEmpty { Text("Cần có API key.").font(.footnote).foregroundColor(.orange) }
//                   }
//                }
//
//                // MARK: General Settings
//                 Section("Cài đặt Chung") {
//                     VStack(alignment: .leading) {
//                         Text("System Prompt (Personality)")
//                         TextEditor(text: $localSystemPrompt)
//                             .frame(height: 100)
//                             .font(.body)
//                             .border(Color.gray.opacity(0.3), width: 1)
//                             .clipShape(RoundedRectangle(cornerRadius: 6))
//                     }
//                 }
//
//                // MARK: Text-to-Speech Settings
//                Section("Đọc Phản Hồi (TTS)") {
//                    Toggle("Bật Đọc Phản Hồi", isOn: $localTtsEnabled)
//
//                    if localTtsEnabled {
//                        Picker("Giọng Đọc", selection: $localTtsVoiceID) {
//                             ForEach(store.availableVoices, id: \.identifier) { voice in
//                                 Text("\(voice.name) (\(voice.language.prefix(2)))").tag(voice.identifier)
//                             }
//                        }
//
//                        HStack {
//                           Text("Tốc độ đọc:")
//                           Slider(value: $localTtsRate, in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate)
//                           Text("\(localTtsRate, specifier: "%.2f")").frame(width: 40, alignment: .trailing)
//                        }
//                        Text("Mặc định: \(String(format: "%.2f", AVSpeechUtteranceDefaultSpeechRate)).").font(.caption).foregroundColor(.secondary)
//                    }
//                }
//            }
//            .navigationTitle("Cài đặt Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) { Button("Hủy") { dismiss() } }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Lưu") {
//                        applyChanges()
//                        dismiss()
//                    }
//                    .disabled(localBackendType == .openAI && localApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                }
//            }
//        }
//    }
//
//    // Apply the local changes back to the store
//    private func applyChanges() {
//        store.systemPrompt = localSystemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
//        store.ttsEnabled = localTtsEnabled
//        store.ttsRate = Double(localTtsRate)
//        store.ttsVoiceID = localTtsVoiceID
//
//        let backendSettingsChanged = (
//            store.apiKey.trimmingCharacters(in: .whitespacesAndNewlines) != localApiKey.trimmingCharacters(in: .whitespacesAndNewlines) ||
//            store.openAIModelName != localOpenAIModelName ||
//            store.openAITemperature != localOpenAITemperature ||
//            store.openAIMaxTokens != localOpenAIMaxTokens ||
//            store.coreMLModelName != localCoreMLModelName ||
//            store.backendType != localBackendType
//        )
//
//        if backendSettingsChanged {
//            print("Settings applying backend changes.")
//            store.apiKey = localApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
//            store.openAIModelName = localOpenAIModelName
//            store.openAITemperature = localOpenAITemperature
//            store.openAIMaxTokens = localOpenAIMaxTokens
//            store.coreMLModelName = localCoreMLModelName
//            store.backendType = localBackendType // Assign last to trigger configure
//        } else {
//              print("Settings applying non-backend changes.")
//            // If only system prompt changed, update it in current chat
//             if store.systemPrompt != localSystemPrompt {
//                 if let firstMsg = store.current.messages.first, firstMsg.role == .system {
//                     store.current.messages[0] = .system(store.systemPrompt)
//                     store.upsertConversation()
//                 }
//             }
//        }
//    }
//}
//
//// History View Presented as a Sheet (No change from previous version)
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
//                    ContentUnavailableView(
//                         "Không có lịch sử chat",
//                         systemImage: "bubble.middle.bottom.fill",
//                         description: Text("Các đoạn chat đã lưu sẽ xuất hiện ở đây.")
//                    )
//                } else {
//                    List {
//                        ForEach(conversations) { convo in
//                            historyRow(for: convo)
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    onSelect(convo)
//                                    dismiss()
//                                }
//                        }
//                        .onDelete(perform: deleteItems)
//                    }
//                    .listStyle(.plain)
//                }
//
//                if !conversations.isEmpty {
//                    Button("Xóa Tất Cả Lịch Sử", role: .destructive) {
//                        showingClearConfirm = true
//                    }
//                    .padding(.vertical)
//                }
//            }
//            .navigationTitle("Lịch sử Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Xong") { dismiss() }
//                }
//            }
//            .alert("Đổi tên Đoạn Chat", isPresented: $showingRenameAlert, presenting: conversationToRename) { convo in
//                 TextField("Tên mới", text: $newConversationTitle)
//                     .autocapitalization(.sentences)
//                     .onAppear { newConversationTitle = convo.title }
//                 Button("OK") {
//                     if !newConversationTitle.trimmingCharacters(in: .whitespaces).isEmpty {
//                         onRename(convo, newConversationTitle)
//                     }
//                 }
//                 Button("Hủy", role: .cancel) {}
//             } message: { convo in Text("Nhập tên mới cho \"\(convo.title)\"") }
//             .alert("Xác nhận Xóa?", isPresented: $showingClearConfirm) {
//                 Button("Xóa Tất Cả", role: .destructive) { onClear(); dismiss() }
//                 Button("Hủy", role: .cancel) {}
//             } message: { Text("Bạn có chắc muốn xóa toàn bộ lịch sử chat? Hành động này không thể hoàn tác.") }
//        }
//        .presentationDetents([.medium, .large])
//    }
//
//    private func historyRow(for conversation: Conversation) -> some View {
//       HStack {
//           VStack(alignment: .leading, spacing: 4) {
//               Text(conversation.title).font(.headline).lineLimit(1)
//                Text("\(conversation.messages.filter{$0.role != .system}.count) tin nhắn - \(conversation.createdAt, style: .date)")
//                   .font(.caption).foregroundColor(.secondary)
//           }
//           Spacer()
//           Menu {
//               Button { conversationToRename = conversation; showingRenameAlert = true }
//                   label: { Label("Đổi tên", systemImage:"pencil") }
//               ShareLink(item: formatConversationForSharing(conversation)) { Label("Chia sẻ", systemImage: "square.and.arrow.up") }
//               Button(role: .destructive) { onDelete(conversation.id) }
//                   label: { Label("Xóa", systemImage: "trash") }
//           } label: {
//               Image(systemName: "ellipsis.circle").foregroundColor(.gray).padding(.leading, 5).imageScale(.large)
//           }
//           .buttonStyle(.borderless)
//           .menuIndicator(.hidden)
//       }
//        .padding(.vertical, 4)
//   }
//
//   private func deleteItems(at offsets: IndexSet) {
//       offsets.map { conversations[$0].id }.forEach(onDelete)
//   }
//
//   private func formatConversationForSharing(_ conversation: Conversation) -> String {
//       var shareText = "Chat: \(conversation.title)\nNgày: \(conversation.createdAt.formatted())\n\n"
//       for message in conversation.messages where message.role != .system {
//           let prefix = message.role == .user ? "You:" : "AI:"
//           shareText += "\(prefix) \(message.content)\n\n"
//       }
//       return shareText.trimmingCharacters(in: .whitespacesAndNewlines)
//   }
//}
//
//// MARK: — 5.5 Takeover Voice UI View (NEW)
//
//// Represents the states of the takeover voice interface
//enum VoiceUIState {
//    case prompt // Showing initial prompt and suggestions
//    case listening // Actively listening, showing waveform and transcript
//    case acknowledging // Briefly acknowledging received input (optional visual)
//    case processing // Waiting for backend/command processing
//    case error(String) // Displaying an error
//}
//
//// The modal view for voice input
//struct TakeoverVoiceView: View {
//    @ObservedObject var speech: SpeechRecognizer
//    @ObservedObject var store: ChatStore // To send suggestion messages
//    @State private var voiceState: VoiceUIState = .prompt
//    @Environment(\.dismiss) var dismiss
//
//    // Example suggestions
//    let suggestions = [
//        "Tôi bị mất thẻ.",
//        "Tại sao thẻ của tôi bị từ chối?",
//        "Làm cách nào để đổi thưởng?"
//    ]
//
//    var body: some View {
//        ZStack {
//            // Background
//            Color.blue.opacity(0.9).gradient.ignoresSafeArea()
//
//            VStack {
//                // Top Dismiss Button
//                HStack {
//                    Spacer()
//                    Button {
//                        stopAndDismiss()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.title)
//                            .foregroundColor(.white.opacity(0.7))
//                    }
//                }
//                .padding()
//
//                Spacer() // Push content to center/bottom
//
//                // Content Area (Changes based on state)
//                Group {
//                    switch voiceState {
//                    case .prompt:
//                         promptView
//                            .transition(.opacity.combined(with: .scale(scale: 0.8))) // Add transition
//                    case .listening, .acknowledging:
//                         listeningView
//                            .transition(.opacity)
//                    case .processing:
//                         processingView
//                            .transition(.opacity)
//                    case .error(let message):
//                         errorView(message)
//                         .transition(.opacity)
//                    }
//                }
//                .foregroundColor(.white)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//
//                Spacer()
//
//                // Bottom Waveform / Indicator Area
//                waveformArea
//                    .frame(height: 100) // Allocate space
//                    .padding(.bottom)
//            }
//        }
//        // Dark mode appearance for the modal
//        .preferredColorScheme(.dark)
//        .onAppear(perform: startVoiceInteraction)
//        .onDisappear(perform: speech.stopRecording) // Ensure cleanup if dismissed externally
//        // --- State Transitions based on SpeechRecognizer ---
//        .onChange(of: speech.isRecording) { _, isRecording in
//             // This is the primary driver for changing state
//             if isRecording && (voiceState == .prompt || isErrorState(voiceState)) {
//                 withAnimation { voiceState = .listening }
//             } else if !isRecording && voiceState == .listening {
//                  // If isRecording becomes false WHILE listening, implies stop/finish
//                  // Let onFinalTranscription handle moving to processing/dismissal
//                   print("TakeoverView: isRecording changed to false while listening.")
//                 // Optionally move to acknowledging briefly? Depends on desired feel.
//                 // withAnimation { voiceState = .acknowledging }
//                 // Or directly to processing if finish logic is fast
//                 // withAnimation { voiceState = .processing }
//             }
//        }
//        .onChange(of: speech.transcript) { _, newTranscript in
//            // Keep updating UI while listening
//            if speech.isRecording {
//                 // Stay in listening state, the view reflects the transcript change
//                 if voiceState != .listening { // Ensure we are in listening state visually
//                      withAnimation { voiceState = .listening }
//                  }
//            }
//        }
//        .onChange(of: speech.errorMessage) { _, newError in
//            if let errorMsg = newError {
//                withAnimation { voiceState = .error(errorMsg) }
//                // Auto-dismiss error after a few seconds?
//                 DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
//                     // Only reset/dismiss if the *same* error is still showing
//                      if case .error(let currentMsg) = voiceState, currentMsg == errorMsg {
//                           // Option 1: Go back to prompt
//                           // withAnimation { voiceState = .prompt }
//                           // speech.errorMessage = nil // Clear error in recognizer
//
//                          // Option 2: Dismiss the sheet
//                          stopAndDismiss()
//                      }
//                 }
//            } else {
//                // If error becomes nil, transition back *if* in error state
//                if isErrorState(voiceState) {
//                    withAnimation { voiceState = .prompt }
//                }
//            }
//        }
//    }
//
//    // MARK: - Subviews for Voice States
//
//    private var promptView: some View {
//        VStack(spacing: 20) {
//            Text("Hỏi tôi một câu hỏi, hoặc thử một trong những gợi ý sau:")
//                .font(.title3)
//                .padding(.bottom)
//
//            ForEach(suggestions, id: \.self) { suggestion in
//                Button {
//                    sendSuggestion(suggestion)
//                } label: {
//                    Text(suggestion)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(.white.opacity(0.2))
//                        .clipShape(Capsule())
//                         .foregroundColor(.white)
//                }
//            }
//        }
//    }
//
//    private var listeningView: some View {
//        // Show transcript, emphasize it
//        Text(speech.transcript.isEmpty ? "Đang nghe..." : speech.transcript)
//            .font(speech.transcript.isEmpty ? .title2.weight(.light) : .title.weight(.medium)) // Larger font for transcript
//            .opacity(speech.transcript.isEmpty ? 0.7 : 1.0) // Dim "Listening..."
//    }
//
//    private var processingView: some View {
//        VStack {
//            ProgressView() // Simple spinner
//                .tint(.white)
//                .scaleEffect(1.5)
//                .padding(.bottom)
//            Text("Để tôi xem...") // "One moment..."
//                .font(.title2)
//                .opacity(0.8)
//        }
//    }
//
//    private func errorView(_ message: String) -> some View {
//        VStack(spacing: 15) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .font(.largeTitle)
//                .foregroundColor(.yellow)
//            Text("Đã xảy ra lỗi")
//                .font(.title3)
//            Text(message)
//                .font(.callout)
//                .opacity(0.8)
//                .padding(.horizontal)
//        }
//    }
//
//    // MARK: - Waveform Placeholder
//
//    // Replace with actual waveform visualization if available
//    private var waveformArea: some View {
//        Group {
//            if voiceState == .listening || voiceState == .acknowledging {
//                // Simple placeholder animation
//                 WaveformView(isAnimating: .constant(true)) // Pass binding
//            } else if voiceState == .processing {
//                Color.clear // Keep space, but no waveform
//            } else {
//                Color.clear // Keep space occupied
//            }
//        }
//    }
//
//    // MARK: - Helper Functions
//
//    private func startVoiceInteraction() {
//        print("TakeoverView: onAppear - starting interaction.")
//        voiceState = .prompt // Ensure starting state
//        speech.requestAuthorization { authorized in
//            if authorized {
//                DispatchQueue.main.async { // Ensure state update on main thread
//                    do {
//                        if !speech.isRecording { // Check if not already recording
//                           try speech.startRecording()
//                           // State change to .listening is handled by .onChange(of: speech.isRecording)
//                            print("TakeoverView: Speech recording started.")
//                        } else {
//                            print("TakeoverView: Speech recognizer was already recording.")
//                            // If already recording, ensure UI state is listening
//                             if voiceState != .listening {
//                                 withAnimation{ voiceState = .listening }
//                             }
//                        }
//                    } catch {
//                        print("TakeoverView: Error starting recording - \(error)")
//                        withAnimation { voiceState = .error("Không thể bắt đầu ghi âm: \(error.localizedDescription)") }
//                    }
//                }
//            } else {
//                 print("TakeoverView: Authorization denied.")
//                // Set state here as isRecording won't change
//                 DispatchQueue.main.async {
//                     withAnimation { voiceState = .error(speech.errorMessage ?? "Quyền truy cập microphone/speech bị từ chối.") }
//                 }
//            }
//        }
//
//        // Attach the final transcription handler
//         speech.onFinalTranscription = { [weak speech, weak store] transcript in
//             print("TakeoverView: Received final transcription - '\(transcript)'")
//              DispatchQueue.main.async {
//                  // Update state to processing BEFORE calling handleVoiceCommand
//                   withAnimation { self.voiceState = .processing }
//
//                  // Reset the recognizer's transcript *after* getting the final value
//                  speech?.transcript = ""
//
//                  // Call the store's handler
//                  store?.handleVoiceCommand(transcript)
//
//                   // Dismiss the sheet after a short delay to show processing state
//                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                      self.dismiss()
//                  }
//              }
//        }
//    }
//
//    private func stopAndDismiss() {
//        print("TakeoverView: Stop and dismiss requested.")
//         speech.stopRecording() // V5 stopRecording handles cleanup
//        dismiss()
//    }
//
//    // Function to handle suggestion button taps
//    private func sendSuggestion(_ text: String) {
//        print("TakeoverView: Sending suggestion - '\(text)'")
//        // Stop any active recording immediately
//        speech.stopRecording()
//        // Send the message via the store
//        store.sendMessage(text)
//        // Dismiss the sheet
//        dismiss()
//    }
//
//    // Helper to check if the current state is an error state
//    private func isErrorState(_ state: VoiceUIState) -> Bool {
//        if case .error = state { return true }
//        return false
//    }
//}
//
//// MARK: - Simple Waveform Placeholder View
//
//struct WaveformView: View {
//     @Binding var isAnimating: Bool // Control animation externally if needed
//     @State private var phase: CGFloat = 0
//
//    var body: some View {
//        GeometryReader { geometry in
//            HStack(spacing: 2) {
//                // Create a number of bars based on width
//                 ForEach(0..<Int(geometry.size.width / 4), id: \.self) { index in
//                    // Calculate height based on sine wave and individual randomness
//                     let waveHeight = abs(sin(CGFloat(index) * 0.2 + phase)) // Base wave
//                     let randomFactor = CGFloat.random(in: 0.5...1.0) // Add variation
//                     let barHeight = max(5, waveHeight * randomFactor * (geometry.size.height * 0.8)) // Ensure min height
//
//                    RoundedRectangle(cornerRadius: 2)
//                        .fill(Color.white.opacity(0.7))
//                        .frame(width: 3, height: barHeight)
//                        .scaleEffect(y: isAnimating ? 1 : 0.1, anchor: .bottom) // Animate scale
//                }
//            }
//             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center bars
//             .onAppear {
//                 // Only start animation if explicitly told to
//                  if isAnimating {
//                      startAnimation()
//                  }
//             }
//             .onChange(of: isAnimating) { _, newValue in
//                 if newValue {
//                     startAnimation()
//                 }
//             }
//        }
//    }
//
//     private func startAnimation() {
//         // Use a repeating timer or timeline view for continuous animation
//         // For simplicity, using a repeating timer here.
//         Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
//              guard isAnimating else { return } // Stop if animation is turned off
//             withAnimation(.linear(duration: 0.05)) {
//                 phase += 0.5 // Adjust speed of wave
//             }
//         }
//     }
//}
//
//// MARK: — 6. Main View ( INTEGRATED WITH TAKEOVER VUI SHEET )
//
//struct ChatDemoView: View {
//    // State Objects
//    @StateObject var store = ChatStore()
//    @StateObject var speech = SpeechRecognizer()
//
//    // Focus state for the text input bar
//    @FocusState var isInputFocused: Bool
//
//    // State for presenting modal sheets
//    @State private var showSettingsSheet = false
//    @State private var showHistorySheet = false
//    @State private var showTakeoverVoiceView = false // NEW state for VUI sheet
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                chatHeader
//                messagesScrollView
//                // Pass the closure to trigger the VUI Sheet
//                ChatInputBar(
//                    text: $store.input,
//                    store: store, // Pass store for isLoading state
//                    onMicButtonTapped: { showTakeoverVoiceView = true }, // Trigger sheet
//                    isFocused: _isInputFocused
//                )
//            }
//            .navigationBarHidden(true)
//            // --- Settings Sheet ---
//            .sheet(isPresented: $showSettingsSheet) {
//                SettingsSheet(store: store)
//            }
//            // --- History Sheet ---
//            .sheet(isPresented: $showHistorySheet) {
//                HistorySheet(
//                    conversations: $store.conversations,
//                    onDelete: store.deleteConversation(id:),
//                    onSelect: { store.selectConversation($0) },
//                    onRename: store.renameConversation(_:to:),
//                    onClear: store.clearHistory
//                )
//            }
//            // --- Takeover Voice UI Sheet (NEW) ---
//            .sheet(isPresented: $showTakeoverVoiceView) {
//                 // VUI sheet presentation
//                 TakeoverVoiceView(speech: speech, store: store)
//                    // Optional: Add onDismiss cleanup if needed,
//                    // but TakeoverVoiceView tries to handle its own cleanup.
//                     .onDisappear {
//                          print("ChatDemoView: Takeover sheet dismissed.")
//                          // Ensure speech is stopped if sheet is dismissed externally
//                           if speech.isRecording {
//                               speech.stopRecording()
//                           }
//                     }
//            }
//            // --- Error Alert ---
//            .alert("Lỗi", isPresented: .constant(store.errorMessage != nil), actions: {
//                Button("OK") { store.errorMessage = nil }
//            }, message: {
//                Text(store.errorMessage ?? "Đã xảy ra lỗi không xác định.")
//            })
//            .onAppear {
//                // Request auth on appear, but don't start recording here
//                speech.requestAuthorization { _ in }
//                // Attach recognizer results to store handler (V5 link)
//                store.attachRecognizer(speech)
//            }
//            .onTapGesture { // Dismiss keyboard on tap outside
//                isInputFocused = false
//            }
//        }
//        .preferredColorScheme(nil)
//    }
//
//    // Custom Header View Component (No change)
//    private var chatHeader: some View {
//        HStack(spacing: 10) {
//             Text(store.current.title).font(.headline).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
//            Spacer()
//
//            if store.ttsEnabled {
//                 Image(systemName: "speaker.wave.2.fill").foregroundColor(.blue).imageScale(.medium).transition(.scale.combined(with: .opacity))
//                     .accessibilityLabel("Đọc phản hồi đang bật")
//            } else {
//                 Image(systemName: "speaker.slash.fill").foregroundColor(.gray).imageScale(.medium).transition(.scale.combined(with: .opacity))
//                     .accessibilityLabel("Đọc phản hồi đang tắt")
//            }
//
//            Button { showHistorySheet = true } label: { Label("Lịch sử", systemImage: "clock.arrow.circlepath") }.labelStyle(.iconOnly)
//            Button { showSettingsSheet = true } label: { Label("Cài đặt", systemImage: "gearshape.fill") }.labelStyle(.iconOnly)
//            Button { store.resetChat() } label: { Label("Chat Mới", systemImage: "plus.circle.fill") }.labelStyle(.iconOnly)
//
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 10)
//        .background(.thinMaterial)
//        .animation(.default, value: store.ttsEnabled)
//    }
//
//    // Scrollable View for Messages (No change)
//    private var messagesScrollView: some View {
//        ScrollViewReader { proxy in
//            ScrollView {
//                LazyVStack(spacing: 16) {
//                    ForEach(store.current.messages.filter { $0.role != .system }) { message in
//                        MessageBubble(message: message, onRespeak: store.speak)
//                            .id(message.id)
//                    }
//                    Color.clear.frame(height: 10).id("bottomPadding")
//
//                    if store.isLoading {
//                        HStack(spacing: 8) { ProgressView().tint(.secondary); Text("AI đang suy nghĩ...").font(.caption).foregroundColor(.secondary) }
//                            .padding(.vertical).id("loadingIndicator").transition(.opacity)
//                    }
//                }
//                .padding(.vertical).padding(.horizontal, 12)
//            }
//            .background(Color(.systemGroupedBackground))
//            .scrollDismissesKeyboard(.interactively)
//            .onChange(of: store.current.messages.last?.id) { _, newId in scrollToBottom(proxy: proxy, anchor: .bottom) }
//            .onChange(of: store.isLoading) { _, isLoading in
//                if isLoading {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        withAnimation { proxy.scrollTo("loadingIndicator", anchor: .bottom) }
//                    }
//                }
//            }
//             .onAppear { scrollToBottom(proxy: proxy, anchor: .bottom, animated: false) }
//             .onChange(of: store.current.id) { _, _ in scrollToBottom(proxy: proxy, anchor: .bottom, animated: false) }
//        }
//    }
//
//    // Helper function for scrolling (No change)
//    private func scrollToBottom(proxy: ScrollViewProxy, anchor: UnitPoint?, animated: Bool = true) {
//       DispatchQueue.main.async {
//           let targetId: AnyHashable = store.isLoading ? "loadingIndicator" : (store.current.messages.last?.id ?? "bottomPadding")
//           let fallbackId: AnyHashable = "bottomPadding"
//           let idToScroll: AnyHashable = targetId ?? fallbackId
//
//           if animated {
//               withAnimation(.spring(duration: 0.4)) { proxy.scrollTo(idToScroll, anchor: anchor) }
//           } else {
//               proxy.scrollTo(idToScroll, anchor: anchor)
//           }
//       }
//   }
//}
//
//// MARK: — 7. Helper Extensions
//
//extension UIApplication { // No change
//    static var topViewController: UIViewController? {
//        let scenes = UIApplication.shared.connectedScenes
//        let windowScene = scenes.first as? UIWindowScene
//        let window = windowScene?.windows.first { $0.isKeyWindow }
//        var topController = window?.rootViewController
//        while let presentedViewController = topController?.presentedViewController {
//            topController = presentedViewController
//        }
//        return topController
//    }
//}
//
//extension UIActivityViewController { // No change
//    static func present(text: String) {
//        guard let topVC = UIApplication.topViewController else { return }
//        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
//        if let popoverController = activityViewController.popoverPresentationController {
//            popoverController.sourceView = topVC.view
//            popoverController.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
//            popoverController.permittedArrowDirections = []
//        }
//        topVC.present(activityViewController, animated: true, completion: nil)
//    }
//}
//
//// MARK: — 8. App Entry Point & Preview
//
//// Define the main App struct
//@main
//struct TakeoverVUIDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ChatDemoView() // Start with the main chat view
//        }
//    }
//}
//
//#Preview {
//    ChatDemoView()
//    // Example environment overrides for preview if needed:
//        .preferredColorScheme(.dark) // Preview in dark mode
//}
