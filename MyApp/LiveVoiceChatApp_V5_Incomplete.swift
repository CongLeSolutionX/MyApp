////
////  LiveVoiceChatApp_V5.swift
////  MyApp
////
////  Created by Cong Le on 4/22/25.
////
//
//
////
////  LiveVoiceChatApp_V5_Functional.swift
////  MyApp
////
////  Created by Cong Le (AI Assistant) on 4/24/25. // Updated version marker
////
////  Single-file SwiftUI Chat Demo with Functional Takeover Voice UI
////
////  Combines Mock, OpenAI, & CoreML backends with Text & Speech I/O.
////  Implements the "Takeover Interface" VUI design concept.
////  UI elements are now functional and connected to the ChatStore logic.
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
//// MARK: — 1. Data Models (Unchanged)
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
//// MARK: — 2. Backend Protocols & Implementations (Unchanged from V4)
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
//        "Bạn muốn biết thêm gì?", "Có thể nói rõ hơn không?", "Một ý tưởng hay!",
//        "Điều đó thú vị đấy.", "Tôi có thể giúp gì khác không?", "Hãy tiếp tục."
//    ]
//    func streamChat(
//        messages: [Message],
//        systemPrompt: String,
//        completion: @escaping (Result<String, Error>) -> Void
//    ) {
//        // Simulate network delay more randomly
//        let delay = Double.random(in: 0.5...1.5)
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//            // Maybe occasionally "fail"
//            if Int.random(in: 0...10) == 0 {
//                completion(.failure(NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock backend bị lỗi ngẫu nhiên."])))
//            } else {
//                completion(.success(replies.randomElement()!))
//            }
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
//        print("OpenAI Backend Initialized with Model: \(model), Temp: \(temperature), Max Tokens: \(maxTokens)")
//    }
//    
//    struct RequestPayload: Encodable {
//        struct MessagePayload: Encodable { let role: String; let content: String }
//        let model: String
//        let messages: [MessagePayload]
//        let temperature: Double
//        let max_tokens: Int
//    }
//    struct ResponsePayload: Decodable {
//        struct Choice: Decodable {
//            struct Message: Decodable { let content: String }
//            let message: Message
//        }
//        let choices: [Choice]
//    }
//    struct ErrorResponse: Decodable {
//        struct ErrorDetail: Decodable { let message: String; let type: String? }
//        let error: ErrorDetail?
//    }
//    
//    func streamChat(
//        messages: [Message],
//        systemPrompt: String,
//        completion: @escaping (Result<String, Error>) -> Void)
//    {
//        print("OpenAI Request: Sending \(messages.count) messages (plus system prompt) to model \(self.model)")
//        var allMessages = messages
//        // Ensure system prompt is always first if provided
//        if !systemPrompt.isEmpty {
//            if allMessages.first?.role == .system { allMessages[0] = .system(systemPrompt) }
//            else { allMessages.insert(.system(systemPrompt), at: 0) }
//        }
//        
//        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            DispatchQueue.main.async { completion(.failure(NSError(domain: "OpenAIError", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key của OpenAI bị thiếu hoặc không hợp lệ."]))) }
//            return
//        }
//        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
//            DispatchQueue.main.async { completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL API của OpenAI không hợp lệ."]))) }
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let body = RequestPayload(
//            model: self.model,
//            messages: allMessages.map { RequestPayload.MessagePayload(role: $0.role.rawValue, content: $0.content) },
//            temperature: self.temperature,
//            max_tokens: self.maxTokens
//        )
//        
//        do { request.httpBody = try JSONEncoder().encode(body) }
//        catch { DispatchQueue.main.async { completion(.failure(error)); return } }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if let networkError = error {
//                    completion(.failure(networkError)); return
//                }
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    completion(.failure(NSError(domain:"NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Phản hồi không hợp lệ từ server."]))); return
//                }
//                guard let responseData = data else {
//                    completion(.failure(NSError(domain: "NoData", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Không nhận được dữ liệu từ server."]))); return
//                }
//                
//                // Handle HTTP errors first
//                if (200...299).contains(httpResponse.statusCode) {
//                    do {
//                        let decodedResponse = try JSONDecoder().decode(ResponsePayload.self, from: responseData)
//                        let replyText = decodedResponse.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//                        if replyText.isEmpty { print("Warning: Received empty successful reply from OpenAI.") }
//                        completion(.success(replyText))
//                    } catch {
//                        completion(.failure(NSError(domain: "DecodingError", code: 5, userInfo: [NSLocalizedDescriptionKey:"Lỗi giải mã phản hồi thành công: \(error.localizedDescription)"])))
//                    }
//                } else {
//                    // Attempt to decode OpenAI error format
//                    let errorMsg: String
//                    var errorCode = httpResponse.statusCode // Use HTTP status as default code
//                    if let decodedError = try? JSONDecoder().decode(ErrorResponse.self, from: responseData),
//                       let detail = decodedError.error {
//                        errorCode = (detail.type == "insufficient_quota") ? 429 : httpResponse.statusCode // Specific code for quota
//                        errorMsg = "Lỗi API (\(httpResponse.statusCode) - \(detail.type ?? "unknown")): \(detail.message)"
//                    } else {
//                        errorMsg = "Lỗi Server (\(httpResponse.statusCode)): \(String(data: responseData, encoding: .utf8) ?? "Không thể đọc phản hồi lỗi.")"
//                    }
//                    completion(.failure(NSError(domain: "APIError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
//                }
//            }
//        }.resume()
//    }
//}
//
//// Enum for different backend types (Unchanged)
//enum BackendType: String, CaseIterable, Identifiable {
//    case mock = "Mock"
//    case openAI = "OpenAI"
//    case coreML = "CoreML (Local)"
//    var id: Self { self }
//}
//
//// Implementation using a local CoreML model (Placeholder with functional check)
//final class CoreMLChatBackend: ChatBackend {
//    let modelName: String
//    lazy var coreModel: MLModel? = { // Keep lazy loading
//        guard let url = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
//            print("❌ Error: CoreML model '\(modelName).mlmodelc' not found in bundle.")
//            return nil
//        }
//        do {
//            print("⏳ Attempting to load CoreML model at URL: \(url.path)")
//            let model = try MLModel(contentsOf: url)
//            print("✅ Successfully loaded CoreML model: \(modelName)")
//            return model
//        } catch {
//            print("❌ Error loading CoreML model '\(modelName)': \(error)")
//            return nil
//        }
//    }()
//    
//    init(modelName: String) { self.modelName = modelName }
//    
//    func streamChat(
//        messages: [Message],
//        systemPrompt: String,
//        completion: @escaping (Result<String, Error>) -> Void
//    ) {
//        guard let model = coreModel else {
//            let error = NSError(domain: "CoreMLError", code: 1, userInfo: [NSLocalizedDescriptionKey: "CoreML model '\(modelName)' không thể tải."])
//            DispatchQueue.main.async { completion(.failure(error)) }
//            return
//        }
//        
//        // --- Placeholder for actual CoreML inference ---
//        // In a real app, you'd convert messages+prompt into the model's expected MLFeatureProvider input
//        print("CoreML Request: Simulating inference with model '\(modelName)'...")
//        let lastUserInput = messages.last(where: { $0.role == .user })?.content ?? "(no input)"
//        let promptContext = systemPrompt.isEmpty ? "" : "[Prompt: \(systemPrompt)] "
//        
//        // Simulate some processing time
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + Double.random(in: 0.3...0.8)) {
//            // Construct a mock reply based on input and model name
//            let reply = "\(self.modelName) trả lời: \(promptContext)Bạn đã nói '\(lastUserInput)'."
//            DispatchQueue.main.async { completion(.success(reply)) }
//        }
//        // Actual inference would look something like:
//        // let inputFeatures = createMLInput(from: messages, prompt: systemPrompt) // Custom function
//        // do {
//        //     let outputFeatures = try model.prediction(from: inputFeatures)
//        //     let resultText = parseMLOutput(outputFeatures) // Custom function
//        //     DispatchQueue.main.async { completion(.success(resultText)) }
//        // } catch {
//        //     DispatchQueue.main.async { completion(.failure(error)) }
//        // }
//    }
//}
//
//// MARK: — 3. Speech Recognizer (Speech-to-Text) (Unchanged from V4)
//
//final class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
//    // Published properties to update the UI
//    @Published var transcript = ""
//    @Published var isRecording = false
//    @Published var errorMessage: String? // VUI: Expose errors for UI feedback
//    @Published var audioLevel: Float = 0.0
//    private var levelTimer: Timer?
//    
//    // Callbacks
//    var onFinalTranscription: ((String) -> Void)?
//    var onErrorOccurred: ((String) -> Void)?
//    
//    // Speech recognition components
//    private let recognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN"))
//    private let audioEngine = AVAudioEngine()
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    
//    // Silence detection
//    private let silenceTimeout: TimeInterval = 1.8
//    private var silenceWork: DispatchWorkItem?
//    
//    override init() {
//        super.init()
//        self.recognizer?.delegate = self
//    }
//    
//    func requestAuthorization(completion: @escaping (Bool) -> Void) {
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            let authorized = authStatus == .authorized
//            DispatchQueue.main.async {
//                print("Speech Recognition Authorization Status: \(authStatus.rawValue)")
//                if !AVAudioSession.sharedInstance().isInputAvailable {
//                    self.errorMessage = "Không tìm thấy thiết bị input âm thanh."
//                    print("🎤 Audio Input NOT Available")
//                    completion(false)
//                    return
//                }
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
//        print("🎤 Attempting to start recording...")
//        errorMessage = nil
//        transcript = ""
//        isRecording = true
//        audioLevel = 0.0
//        recognitionTask?.cancel(); recognitionTask = nil
//        recognitionRequest?.endAudio(); recognitionRequest = nil
//        silenceWork?.cancel(); silenceWork = nil
//        levelTimer?.invalidate(); levelTimer = nil
//        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            // Ensure input availability one last time
//            guard audioSession.isInputAvailable else {
//                throw NSError(domain: "AudioSessionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Input âm thanh không khả dụng."])
//            }
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//            print("🎤 Audio Session configured and activated for recording.")
//        } catch {
//            print("❌ Error setting up Audio Session: \(error)")
//            stopRecordingInternal() // Clean up on session error
//            throw error // Re-throw for caller
//        }
//        
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            fatalError("Unable to create SFSpeechAudioBufferRecognitionRequest")
//        }
//        recognitionRequest.shouldReportPartialResults = true
//        recognitionRequest.taskHint = .dictation
//        
//        guard let speechRecognizer = recognizer, speechRecognizer.isAvailable else {
//            print("❌ Recognizer not available.")
//            stopRecordingInternal()
//            throw NSError(domain: "RecognizerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Bộ nhận dạng giọng nói không khả dụng."])
//        }
//        
//        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//            guard let self = self else { return }
//            var isFinal = false
//            
//            if let result = result {
//                print("🎤 Partial Result: \(result.bestTranscription.formattedString)")
//                DispatchQueue.main.async {
//                    self.transcript = result.bestTranscription.formattedString
//                }
//                isFinal = result.isFinal
//                if isFinal {
//                    print("🎤 Final Result: \(self.transcript)")
//                    self.finish(self.transcript)
//                } else {
//                    self.scheduleSilence()
//                }
//            }
//            
//            if error != nil || isFinal {
//                self.stopLevelTimer()
//                if isFinal && error == nil {
//                    print("🎤 Recognition finished normally.")
//                    self.stopRecordingInternal() // Clean up audio after final valid result
//                }
//            }
//            
//            if let anError = error {
//                DispatchQueue.main.async {
//                    let nsError = anError as NSError
//                    let errorMsg: String
//                    // Handle common errors gracefully
//                    if nsError.code == 203 && self.transcript.isEmpty { // Retry / No Speech
//                        errorMsg = "Không nghe thấy gì. Vui lòng thử lại."
//                        print("🎤 Error 203 (No Speech/Retry)")
//                    } else if nsError.code == 1101 { // Audio engine node creation failed
//                        errorMsg = "Lỗi khởi tạo audio engine. Vui lòng thử lại."
//                        print("🎤 Error 1101 (Audio Engine Node)")
//                    } else {
//                        errorMsg = "Lỗi nhận dạng: \(anError.localizedDescription) (Code: \(nsError.code))"
//                        print("🎤 Recognition Error: \(errorMsg)")
//                    }
//                    self.errorMessage = errorMsg
//                    self.onErrorOccurred?(errorMsg)
//                    self.stopRecordingInternal() // Stop everything on error
//                }
//            }
//        }
//        
//        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
//        // Check format before installing tap
//        guard recordingFormat.sampleRate > 0 else {
//            print("❌ Invalid recording format: \(recordingFormat). Cannot install tap.")
//            stopRecordingInternal()
//            throw NSError(domain: "AudioEngineError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Định dạng audio không hợp lệ."])
//        }
//        print("🎤 Recording Format: SR=\(recordingFormat.sampleRate), Channels=\(recordingFormat.channelCount)")
//        audioEngine.inputNode.removeTap(onBus: 0)
//        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            self.recognitionRequest?.append(buffer)
//            self.updateAudioLevel(buffer: buffer)
//        }
//        
//        do {
//            audioEngine.prepare()
//            try audioEngine.start()
//            print("🎤 Audio Engine prepared and started.")
//        } catch {
//            print("❌ Error starting Audio Engine: \(error)")
//            stopRecordingInternal()
//            throw error
//        }
//        
//        scheduleSilence()
//        startLevelTimer()
//        print("🎤 Recording successfully started.")
//    }
//    
//    private func scheduleSilence() {
//        silenceWork?.cancel()
//        let wi = DispatchWorkItem { [weak self] in
//            guard let self = self, self.isRecording else { return }
//            print("🎤 Silence detected, finishing.")
//            self.finish(self.transcript)
//        }
//        silenceWork = wi
//        DispatchQueue.main.asyncAfter(deadline: .now() + silenceTimeout, execute: wi)
//    }
//    
//    private func finish(_ text: String) {
//        guard isRecording else { print("🎤 Finish called but not recording."); return }
//        print("🎤 Finish requested with transcript: '\(text)'")
//        stopRecordingInternal() // Clean up resources first
//        
//        // Only call back if the text isn't considered empty (or just whitespace)
//        let finalText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        if !finalText.isEmpty {
//            onFinalTranscription?(finalText)
//        } else {
//            print("🎤 Final transcript was empty after trimming, not sending.")
//            // Optionally call onErrorOccurred or specific handler for empty final text
//            DispatchQueue.main.async { // Update UI safely
//                self.errorMessage = "Không nghe thấy gì rõ ràng."
//                self.onErrorOccurred?("Không nghe thấy gì rõ ràng.")
//            }
//        }
//    }
//    
//    // Public function to stop recording externally (e.g., user cancels VUI)
//    func stopRecording() {
//        print("🎤 External stopRecording called.")
//        guard isRecording else { return }
//        stopRecordingInternal()
//        // Explicitly trigger finish with current transcript if needed,
//        // or maybe just reset state depending on desired behavior.
//        // For cancellation, maybe just clean up without `onFinalTranscription`.
//        // Let's just clean up for now.
//        DispatchQueue.main.async {
//            self.transcript = "" // Clear transcript on external stop
//        }
//    }
//    
//    // Internal function for cleanup to avoid redundant code
//    private func stopRecordingInternal() {
//        guard isRecording else { return } // Prevent multiple internal stops
//        print("🎤 stopRecordingInternal executing...")
//        isRecording = false
//        
//        DispatchQueue.main.async { // Ensure UI updates happen on main thread
//            self.audioLevel = 0.0
//        }
//        
//        stopLevelTimer()
//        silenceWork?.cancel(); silenceWork = nil
//        
//        if audioEngine.isRunning {
//            print("🎤 Stopping audio engine and removing tap.")
//            audioEngine.stop()
//            audioEngine.inputNode.removeTap(onBus: 0)
//        }
//        
//        // Safely end/cancel tasks
//        if recognitionRequest != nil {
//            recognitionRequest?.endAudio()
//            recognitionRequest = nil
//            print("🎤 Audio Request Ended.")
//        }
//        if let task = recognitionTask {
//            // Check state before cancelling to avoid crashing if already cancelled/completed
//            if ![.completed, .canceling, .finishing].contains(task.state) {
//                task.cancel()
//                print("🎤 Recognition Task Cancelled.")
//            }
//            recognitionTask = nil
//        }
//        
//        do {
//            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//            print("🎤 Audio Session Deactivated.")
//        } catch {
//            print("❌ Error deactivating audio session: \(error.localizedDescription)")
//        }
//        print("🎤 stopRecordingInternal finished.")
//    }
//    
//    // Audio Level Logic (Unchanged)
//    private func startLevelTimer() {
//        levelTimer?.invalidate()
//        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            DispatchQueue.main.async {
//                let currentLevel = self?.audioLevel ?? 0
//                self?.audioLevel = max(0, currentLevel * 0.85) // Decay
//            }
//        }
//    }
//    
//    private func stopLevelTimer() {
//        levelTimer?.invalidate(); levelTimer = nil
//        DispatchQueue.main.async { self.audioLevel = 0.0 }
//    }
//    
//    private func updateAudioLevel(buffer: AVAudioPCMBuffer) {
//        guard let channelData = buffer.floatChannelData else { return }
//        let frameLength = Int(buffer.frameLength)
//        guard frameLength > 0 else { return } // Avoid division by zero
//        let channelDataValue = channelData.pointee
//        let channelDataValueArray = UnsafeBufferPointer(start: channelDataValue, count: frameLength)
//        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(frameLength))
//        let avgPower = 20 * log10(max(rms, 1e-5))
//        let minDb: Float = -55.0; let maxDb: Float = -5.0
//        var normalizedLevel = (avgPower - minDb) / (maxDb - minDb)
//        normalizedLevel = max(0.0, min(1.0, normalizedLevel))
//        DispatchQueue.main.async {
//            let smoothedLevel = (self.audioLevel * 0.3) + (normalizedLevel * 0.7)
//            self.audioLevel = smoothedLevel
//        }
//    }
//    
//    // Delegate Method (Unchanged)
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        DispatchQueue.main.async {
//            print("🎤 Recognizer Availability Changed: \(available)")
//            if !available {
//                self.errorMessage = "Bộ nhận dạng giọng nói không còn khả dụng."
//                self.onErrorOccurred?("Bộ nhận dạng giọng nói hiện không có.")
//                if self.isRecording { self.stopRecordingInternal() }
//            } else {
//                if self.errorMessage == "Bộ nhận dạng giọng nói không còn khả dụng." {
//                    self.errorMessage = nil
//                }
//            }
//        }
//    }
//}
//
//
//// MARK: — 4. ViewModel (Central State + VUI State Management)
//
//// VUI State Definition (Unchanged)
//enum VUIState {
//    case idle, prompting, listening, acknowledging, processing
//}
//
//@MainActor
//final class ChatStore: ObservableObject {
//    // MARK: - Published Properties (UI + VUI State)
//    @Published var conversations: [Conversation] = [] { didSet { saveToDisk() } }
//    @Published var current: Conversation
//    @Published var input: String = ""
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    
//    // VUI State Properties
//    @Published var vuiState: VUIState = .idle
//    @Published var vuiTranscript: String = ""
//    @Published var vuiErrorMessage: String?
//    
//    // Suggested Prompts for VUI (Constant)
//    let suggestedPrompts = ["Tôi bị mất thẻ", "Thẻ của tôi bị từ chối?", "Làm sao đổi điểm thưởng?", "Kiểm tra số dư tài khoản"]
//    
//    // Settings synced with UserDefaults
//    @AppStorage("system_prompt") var systemPrompt: String = "Bạn là một trợ lý ngân hàng ảo, hữu ích và lịch sự, nói tiếng Việt. Hãy trả lời ngắn gọn và tập trung vào các câu hỏi liên quan đến ngân hàng." // Enhanced default prompt
//    @AppStorage("tts_enabled") var ttsEnabled: Bool = true // Default to true
//    @AppStorage("tts_rate") var ttsRate: Double = 1.0
//    @AppStorage("tts_voice_id") var ttsVoiceID: String = ""
//    @AppStorage("openai_api_key") var apiKey: String = "" // Store securely in real app!
//    @AppStorage("backend_type") private var backendTypeRaw: String = BackendType.mock.rawValue
//    @AppStorage("coreml_model_name") var coreMLModelName: String = "TinyChat" // Example name, Ensure this file exists!
//    @AppStorage("openai_model_name") var openAIModelName: String = "gpt-4o"
//    @AppStorage("openai_temperature") var openAITemperature: Double = 0.6 // Adjusted slightly
//    @AppStorage("openai_max_tokens") var openAIMaxTokens: Int = 150 // Lowered default for shorter bank replies
//    
//    // Available models / voices
//    let availableCoreMLModels = ["TinyChat"] // Only list models verified to exist
//    let availableOpenAIModels = ["gpt-4o", "gpt-4-turbo", "gpt-3.5-turbo"]
//    let availableVoices: [AVSpeechSynthesisVoice]
//    
//    // MARK: - Private Properties
//    private(set) var backend: ChatBackend
//    private let ttsSynth = AVSpeechSynthesizer()
//    private var ttsDelegate: TTSSpeechDelegate?
//    private var cancellables = Set<AnyCancellable>()
//    
//    // MARK: - Computed Properties
//    var backendType: BackendType {
//        get { BackendType(rawValue: backendTypeRaw) ?? .mock }
//        // Explicit setter now calls configureBackend AFTER updating the raw value
//        set {
//            let oldValue = backendTypeRaw
//            backendTypeRaw = newValue.rawValue
//            if oldValue != newValue.rawValue {
//                 print("Backend type changed to \(newValue.rawValue). Reconfiguring...")
//                 configureBackend()
//            }
//        }
//    }
//    
//    // MARK: - Initialization
//    init() {
//        // Initialize non-dependent properties first
//        self.availableVoices = AVSpeechSynthesisVoice.speechVoices()
//            .filter { $0.language.starts(with: "vi-VN") || $0.language.starts(with: "en") } // Focus on Vietnamese first
//            .sorted { v1, v2 in
//                let v1Vi = v1.language.starts(with: "vi-VN"); let v2Vi = v2.language.starts(with: "vi-VN")
//                if v1Vi != v2Vi { return v1Vi }
//                return v1.name < v2.name
//            }
//        self.ttsDelegate = TTSSpeechDelegate()
//        self.ttsSynth.delegate = self.ttsDelegate
//       
//        // Placeholder backend and conversation
//        self.backend = MockChatBackend()
//        self.current = Conversation(messages: [])
//
//        // Configure TTS voice from AppStorage or default
//        let initialTTSVoiceID = self.ttsVoiceID
//        if initialTTSVoiceID.isEmpty || self.availableVoices.first(where: { $0.identifier == initialTTSVoiceID }) == nil {
//            self.ttsVoiceID = self.availableVoices.first(where: { $0.language.starts(with: "vi-VN") })?.identifier // Prioritize Vietnamese
//                               ?? self.availableVoices.first?.identifier // Absolute fallback
//                               ?? "" // Could still be empty if no voices found
//             print("TTS Voice initialized to: \(self.ttsVoiceID)")
//        } else {
//             print("Loaded TTS Voice from AppStorage: \(initialTTSVoiceID)")
//        }
//
//        // Load saved conversations
//        loadFromDisk()
//
//        // Configure the backend based on *loaded* settings
//        configureBackend() // This now uses the AppStorage value for backendTypeRaw
//
//        // Assign the final 'current' conversation
//        if let mostRecent = conversations.first {
//            self.current = mostRecent
//            // Apply current system prompt to loaded conversation if policy requires it
//            updateSystemPromptInCurrent(applyToExisting: false) // Policy: Don't overwrite old chats' prompts
//        } else {
//            // If no history, create a fresh conversation with the current system prompt
//            self.current = Conversation(messages: [.system(self.systemPrompt)])
//        }
//
//        // Ensure initial state is clean
//        self.vuiState = .idle
//        self.isLoading = false
//        self.errorMessage = nil
//        self.vuiErrorMessage = nil
//
//        print("✅ ChatStore Initialized. Backend: \(backendType.rawValue), History: \(conversations.count) chats, TTS Voice: \(ttsVoiceID)")
//    }
//    
//    // Helper to ensure system prompt consistency
//    private func updateSystemPromptInCurrent(applyToExisting: Bool) {
//        guard !current.messages.isEmpty else {
//             current.messages.insert(.system(self.systemPrompt), at: 0)
//             return
//        }
//        
//        if current.messages.first?.role == .system {
//             if applyToExisting && current.messages.first?.content != self.systemPrompt {
//                 current.messages[0] = .system(self.systemPrompt)
//                 print("Updated system prompt in existing conversation.")
//             }
//        } else {
//             current.messages.insert(.system(self.systemPrompt), at: 0)
//             print("Added system prompt to current conversation.")
//        }
//    }
//
//    // MARK: - Backend Management
//    // configureBackend is now called by the backendType setter
//    private func configureBackend() {
//        print("⚙️ Configuring backend for type: \(self.backendType.rawValue)")
//        var newBackend: ChatBackend?
//        var configError: String? = nil
//
//        switch self.backendType {
//        case .mock:
//            newBackend = MockChatBackend()
//            print("-> Using Mock Backend")
//            
//        case .openAI:
//            if self.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                configError = "Khóa API OpenAI bị thiếu. Sử dụng Mock backend."
//                print("⚠️ OpenAI selected but API key missing.")
//            } else {
//                newBackend = RealOpenAIBackend(
//                    apiKey: self.apiKey.trimmingCharacters(in: .whitespacesAndNewlines),
//                    model: self.openAIModelName,
//                    temperature: self.openAITemperature,
//                    maxTokens: self.openAIMaxTokens
//                )
//                print("-> Using OpenAI Backend (Model: \(self.openAIModelName))")
//            }
//            
//        case .coreML:
//            let coreMLBackend = CoreMLChatBackend(modelName: self.coreMLModelName)
//            if coreMLBackend.coreModel == nil { // Check if model loaded during lazy init attempt
//                configError = "Không tải được mô hình CoreML '\(self.coreMLModelName)'. Sử dụng Mock backend."
//                print("⚠️ CoreML model '\(self.coreMLModelName)' failed to load.")
//            } else {
//                newBackend = coreMLBackend
//                print("-> Using CoreML Backend (Model: \(self.coreMLModelName))")
//            }
//        }
//
//        // Apply the new backend or fallback to Mock on error
//        if let error = configError {
//            self.backend = MockChatBackend() // Fallback
//            self.errorMessage = error
//            // Crucially, update the raw value so the UI reflects the fallback
//            if self.backendTypeRaw != BackendType.mock.rawValue {
//                 self.backendTypeRaw = BackendType.mock.rawValue
//                 print("-> Fallback to Mock Backend due to configuration error.")
//            }
//        } else if let configuredBackend = newBackend {
//            self.backend = configuredBackend
//            // Clear previous configuration errors if successful
//            if self.errorMessage?.contains("backend") ?? false || self.errorMessage?.contains("API") ?? false || self.errorMessage?.contains("CoreML") ?? false {
//                self.errorMessage = nil
//            }
//        } else {
//            // Should not happen, but safety fallback
//            print("⚠️ Unexpected state in configureBackend. Falling back to Mock.")
//            self.backend = MockChatBackend()
//            self.backendTypeRaw = BackendType.mock.rawValue
//        }
//        
//        // Ensure current chat always has the latest system prompt reflecting settings
//        updateSystemPromptInCurrent(applyToExisting: false) // Don't overwrite old chats
//        print("⚙️ Backend configuration complete.")
//    }
//    
//    // MARK: - VUI Interaction Flow (Mostly Unchanged Logic, Added Logging)
//    
//    func startVUIInteraction() {
//        guard vuiState == .idle else { print("⚠️ VUI Interaction already active."); return }
//        print("🎬 Starting VUI Interaction...")
//        errorMessage = nil; vuiErrorMessage = nil; vuiTranscript = ""
//        stopSpeaking()
//        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) { vuiState = .prompting }
//    }
//    
//    func handleVUIListenStartRequest(speechRecognizer sr: SpeechRecognizer) {
//        guard self.vuiState == .prompting else {
//            print("⚠️ Attempted to start VUI listen, but state is \(vuiState). Aborting.")
//            return
//        }
//        print("🎤 VUI attempting to start listening...")
//        vuiErrorMessage = nil
//        
//        sr.requestAuthorization { [weak self] granted in
//            // Use Task for async/await on main actor
//            Task { @MainActor [weak self] in
//                guard let self = self else { return }
//                guard self.vuiState == .prompting else {
//                    print("🎤 VUI: State changed (\(self.vuiState)) before authorization completed. Aborting listen start.")
//                    // Ensure recognizer is stopped if it somehow started
//                    if sr.isRecording { sr.stopRecording() }
//                    return
//                }
//                
//                if granted {
//                    do {
//                        try sr.startRecording()
//                        print("🎤 VUI: Speech recording started successfully.")
//                        withAnimation { self.vuiState = .listening }
//                    } catch {
//                        print("❌ VUI Error starting speech recognition: \(error)")
//                        self.vuiErrorMessage = "Không thể bắt đầu nghe: \(error.localizedDescription)"
//                        self.scheduleVUIDismissal(delay: 2.5) // Dismiss after showing error
//                    }
//                } else {
//                    print("🚫 VUI: Speech permission denied.")
//                    self.vuiErrorMessage = "Cần cấp quyền để sử dụng giọng nói."
//                    self.scheduleVUIDismissal(delay: 2.5)
//                }
//            } // End Task
//        }
//    }
//    
//    func stopListeningAndProcessVUI(recognizedText: String) {
//        guard vuiState == .listening || vuiState == .acknowledging else {
//            print("⚠️ stopListeningAndProcessVUI called in invalid state: \(vuiState)")
//            return
//        }
//        let trimmedText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
//        print("🎤 VUI stopped listening. Recognized: '\(trimmedText)'")
//        
//        vuiErrorMessage = nil
//        
//        if trimmedText.isEmpty {
//            print("🎤 VUI: Empty transcript, returning to prompt.")
//            vuiErrorMessage = "Không nghe thấy gì rõ ràng. Thử lại?"
//            // Schedule return to prompting *only if* still in acknowledge/processing
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
//                guard let self = self else { return }
//                if self.vuiState == .acknowledging || self.vuiState == .processing {
//                    withAnimation { self.vuiState = .prompting }
//                }
//            }
//            return
//        }
//        
//        // 1. Update VUI transcript
//        vuiTranscript = trimmedText
//        // 2. Transition to Acknowledging
//        withAnimation { vuiState = .acknowledging }
//        // 3. Schedule Processing
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
//            guard let self = self else { return }
//            if self.vuiState == .acknowledging {
//                print("⏳ VUI: Transitioning to Processing state for text: '\(trimmedText)'")
//                withAnimation { self.vuiState = .processing }
//                self.sendMessage(trimmedText) // Send the final transcript
//            } else {
//                print("⚠️ VUI: State changed (\(self.vuiState)) before processing could start.")
//            }
//        }
//    }
//    
//    func dismissVUI() {
//        if vuiState != .idle {
//            print("🎬 Dismissing VUI (Current State: \(vuiState)).")
//            withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
//                vuiState = .idle
//            }
//            isLoading = false // Ensure loading indicator is hidden
//            // Speech recognizer stop is handled by onChange in main view
//        }
//    }
//    
//    // Helper for delayed dismissal
//    private func scheduleVUIDismissal(delay: TimeInterval) {
//         DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
//             // Only dismiss if VUI is still active (user might have dismissed manually)
//             if self?.vuiState != .idle {
//                 self?.dismissVUI()
//             }
//         }
//    }
//    
//    // MARK: - Chat Actions (Refined VUI handling)
//    
//    func sendMessage(_ text: String) {
//        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        let initiatedFromVUI = (vuiState == .processing || vuiState == .acknowledging) // Check if VUI involved
//        
//        guard !trimmedText.isEmpty else {
//            print("⚠️ Attempted to send empty message.")
//            if initiatedFromVUI { dismissVUI() } // Still dismiss VUI if it triggered an empty send
//            return
//        }
//        guard !isLoading else {
//            print("⚠️ Attempted to send message while already loading.")
//            return
//        }
//        
//        print("🚀 Sending message: '\(trimmedText.prefix(50))...' | From VUI: \(initiatedFromVUI)")
//        stopSpeaking()
//        
//        // Add user message immediately *only* if from text input
//        if !initiatedFromVUI {
//            let userMessage = Message.user(trimmedText)
//            current.messages.append(userMessage)
//            upsertConversation() // Save state immediately after text input
//        }
//        // The VUI user message is added *later*, after successful backend response.
//        
//        input = "" // Clear text input field always
//        isLoading = true // Show loading indicator (shared)
//        errorMessage = nil // Clear main chat error
//        if initiatedFromVUI { vuiErrorMessage = nil } // Clear VUI error
//        
//        // Prepare messages for backend (use current state)
//        let messagesForBackend = current.messages
//        print("  Sending \(messagesForBackend.count) messages to backend: \(backendType.rawValue)")
//        
//        // Make the backend call
//        backend.streamChat(messages: messagesForBackend, systemPrompt: systemPrompt) { [weak self] result in
//            Task { @MainActor [weak self] in // Ensure main thread execution
//                guard let self = self else { return }
//                
//                // --- VUI Handling: Dismiss *after* getting result ---
//                let wasProcessingVUI = self.vuiState == .processing // Capture state *before* potential dismissal
//                if wasProcessingVUI {
//                    print("✅ Backend response received for VUI. Dismissing VUI.")
//                    self.dismissVUI() // Dismiss VUI now
//                }
//                // ------------------------------------------------------
//                
//                // Always hide loading indicator regardless of VUI state
//                self.isLoading = false
//                
//                switch result {
//                case .success(let replyText):
//                    let assistantMessage = Message.assistant(replyText)
//                    print("✅ Backend Success. Reply: '\(replyText.prefix(50))...'")
//                    
//                    // If VUI initiated it, add the *user's* voice input message NOW
//                    if wasProcessingVUI && !trimmedText.isEmpty {
//                        let vuiUserMessage = Message.user(trimmedText)
//                        self.current.messages.append(vuiUserMessage)
//                        print("  Added VUI user message to history: '\(trimmedText)'")
//                        // Note: We don't call upsert here yet, wait for assistant msg
//                    }
//                    
//                    // Add assistant message if it's not empty
//                    if !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                        self.current.messages.append(assistantMessage)
//                        print("  Added assistant message to history.")
//                    } else {
//                        print("  Received empty reply, assistant message not added.")
//                        // Optional: Maybe provide a default message if backend returned empty success?
//                        // E.g., self.current.messages.append(.assistant("Xin lỗi, tôi không có gì để nói về điều đó."))
//                    }
//                    
//                    // Save conversation now that user (if VUI) + assistant messages are added
//                    self.upsertConversation()
//                    
//                    // Speak if enabled and reply is not empty
//                    if self.ttsEnabled && !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                        self.speak(replyText)
//                    }
//                    
//                case .failure(let error):
//                    print("❌ Backend error: \(error.localizedDescription)")
//                    self.errorMessage = "Lỗi: \(error.localizedDescription)" // Show error in main chat UI
//                    
//                    // Policy Decision: If VUI failed, should we still add the user's VUI message?
//                    // Current: No. Only text input messages are added before the send attempt.
//                    // To add VUI message on failure:
//                    // if wasProcessingVUI && !trimmedText.isEmpty {
//                    //    self.current.messages.append(.user(trimmedText))
//                    //    self.upsertConversation()
//                    // }
//                }
//            } // End Task
//        } // End backend.streamChat
//    }
//    
//    // MARK: - TTS Actions (Refined Logging and Error Handling)
//    func speak(_ text: String) {
//        guard ttsEnabled else { print("🔊 TTS skipped (disabled)."); return }
//        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { print("🔊 TTS skipped (empty text)."); return }
//        
//        if ttsSynth.delegate == nil { // Re-assign delegate if needed
//            ttsDelegate = TTSSpeechDelegate(); ttsSynth.delegate = ttsDelegate
//            print("🔊 Re-assigned TTS Delegate.")
//        }
//        
//        stopSpeaking() // Stop previous utterance first
//        
//        // Attempt to activate audio session for playback
//        do {
//            let session = AVAudioSession.sharedInstance()
//            if session.category != .playback {
//                try session.setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
//                print("🔊 Audio session category set to playback.")
//            }
//            if !session.isOtherAudioPlaying { // Only activate if needed? Reduces interruptions.
//                // try session.setActive(true, options: .notifyOthersOnDeactivation) // Delegate handles this now
//                // print("🔊 Audio session activated for TTS.")
//            }
//        } catch { print("❌ Failed to set audio session category for TTS: \(error)") }
//        
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * Float(ttsRate) // Apply rate multiplier
//        utterance.voice = AVSpeechSynthesisVoice(identifier: ttsVoiceID)     // Use selected voice ID
//                            ?? AVSpeechSynthesisVoice(language: "vi-VN")     // Fallback to default Vietnamese
//                            ?? AVSpeechSynthesisVoice.speechVoices().first   // Fallback to any voice
//        
//        if utterance.voice == nil {
//            print("❌ Warning: No suitable TTS voice found for ID '\(ttsVoiceID)' or language 'vi-VN'.")
//            self.errorMessage = "Không tìm thấy giọng đọc phù hợp."
//            // Optionally disable TTS temporarily? this.ttsEnabled = false
//            return
//        }
//        
//        print("🔊 Attempting to speak (\(text.count) chars) using voice: \(utterance.voice!.name) (\(utterance.voice!.language)) at rate \(utterance.rate)")
//        ttsSynth.speak(utterance) // Delegate will handle session activation/deactivation
//    }
//    
//    func stopSpeaking() {
//        if ttsSynth.isSpeaking {
//            ttsSynth.stopSpeaking(at: .word) // Smoother interruption (.immediate also works)
//            print("🔊 Stopped speaking.")
//            // Delegate handles audio session deactivation
//        }
//    }
//    
//    
//    // MARK: - History Management Actions (Functional)
//    
//    func deleteConversation(id: UUID) {
//        stopSpeaking()
//        let initialCount = conversations.count
//        conversations.removeAll { $0.id == id }
//        print("🗑️ Deleted conversation: \(id). Count changed: \(initialCount) -> \(conversations.count)")
//        if current.id == id {
//            print("  Current conversation was deleted, resetting chat.")
//            resetChat() // Reset if the active one was deleted
//        }
//        // saveToDisk handled by didSet
//    }
//    
//    func selectConversation(_ conversation: Conversation) {
//        guard current.id != conversation.id else {
//            print("🔄 Conversation \(conversation.id) already selected."); return
//        }
//        stopSpeaking()
//        isLoading = false // Ensure loading indicator is off
//        errorMessage = nil // Clear errors
//        
//        // Apply current system prompt setting if policy requires
//        var selectedConvo = conversation
//        updateSystemPromptInCurrentForSelection(&selectedConvo, applyToExisting: false)
//        
//        self.current = selectedConvo
//        print("🔄 Selected conversation: \(current.id) - '\(current.title)'")
//        // No immediate save needed, just changing the 'current' reference
//    }
//    
//    // Helper for system prompt logic during selection
//    private func updateSystemPromptInCurrentForSelection(_ conversation: inout Conversation, applyToExisting: Bool) {
//         guard !conversation.messages.isEmpty else {
//              conversation.messages.insert(.system(self.systemPrompt), at: 0)
//              return
//         }
//         if conversation.messages.first?.role == .system {
//              if applyToExisting && conversation.messages.first?.content != self.systemPrompt {
//                  conversation.messages[0] = .system(self.systemPrompt)
//              }
//         } else {
//              conversation.messages.insert(.system(self.systemPrompt), at: 0)
//         }
//    }
//    
//    func renameConversation(_ conversation: Conversation, to newTitle: String) {
//        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedTitle.isEmpty, let index = conversations.firstIndex(where: { $0.id == conversation.id }) else {
//            print("⚠️ Rename failed: Invalid title or conversation not found.")
//            return
//        }
//        conversations[index].title = trimmedTitle
//        if current.id == conversation.id { current.title = trimmedTitle } // Update current if it's the one being renamed
//        print("✏️ Renamed conversation \(conversation.id) to: '\(trimmedTitle)'")
//        // saveToDisk handled by didSet
//    }
//    
//    func clearHistory() {
//        stopSpeaking()
//        let count = conversations.count
//        conversations.removeAll()
//        resetChat() // Reset to a new, clean chat state
//        print("🧹 Cleared all \(count) conversations.")
//        // saveToDisk handled by didSet
//    }
//    
//    // MARK: - Reset / Initial State
//    func resetChat() {
//        stopSpeaking()
//        isLoading = false
//        errorMessage = nil
//        vuiErrorMessage = nil
//        input = ""
//        if vuiState != .idle { vuiState = .idle } // Ensure VUI state resets
//        
//        // Create a new conversation object
//        let newConversation = Conversation(messages: [.system(self.systemPrompt)])
//        self.current = newConversation
//        
//        // Policy: Do we add this new conversation to the list immediately?
//        // Usually no, wait until the user sends the first message.
//        print("✨ Chat reset to new conversation state.")
//    }
//    
//    // MARK: - Voice Command / VUI Speech Handling (Functional Attachment)
//    
//    func attachRecognizer(_ sr: SpeechRecognizer) {
//        // Detach previous sinks
//        cancellables.forEach { $0.cancel() }
//        cancellables.removeAll()
//        
//        // Update VUI transcript during listening
//        sr.$transcript.sink { [weak self] newTranscript in
//            Task { @MainActor [weak self] in // Ensure main thread
//                guard let self = self else { return }
//                // Only update if actively listening; prevents overwriting acknowledge/processing text
//                if self.vuiState == .listening {
//                     self.vuiTranscript = newTranscript
//                }
//            }
//        }.store(in: &cancellables)
//        
//        // Handle final transcription from VUI
//        sr.onFinalTranscription = { [weak self] text in
//            print("🎤 Recognizer callback: onFinalTranscription with text: '\(text)'")
//            // Ensure we are on the main actor to modify published properties
//            Task { @MainActor [weak self] in
//                self?.stopListeningAndProcessVUI(recognizedText: text)
//            }
//        }
//        
//        // Handle errors reported by recognizer during VUI session
//        sr.onErrorOccurred = { [weak self] errorMsg in
//            print("🎤 Recognizer callback: onErrorOccurred with message: '\(errorMsg)'")
//            Task { @MainActor [weak self] in // Ensure main thread
//                guard let self = self else { return }
//                // Only show error if VUI is *currently* active
//                if self.vuiState != .idle {
//                    self.vuiErrorMessage = errorMsg
//                    // Schedule dismissal *only* if the error didn't come from finish() already (which handles its own dismissal logic)
//                    // Crude check: If finish didn't trigger it, then likely a recognizer/session error occurred mid-way.
//                    if !errorMsg.contains("Không nghe") { // Avoid double-dismissal on empty finish
//                        self.scheduleVUIDismissal(delay: 2.5)
//                    }
//                }
//            }
//        }
//        
//        print("🔗 Speech Recognizer attached to ChatStore.")
//    }
//    
//    // MARK: - Persistence (Refined Loading/Saving Logic)
//    private func loadFromDisk() {
//        guard let data = UserDefaults.standard.data(forKey: "ChatHistory_v2") else {
//            print("💾 No chat history found in UserDefaults."); self.conversations = []; return
//        }
//        do {
//            let decoder = JSONDecoder()
//            // Decode into a temporary variable
//            var loaded = try decoder.decode([Conversation].self, from: data)
//            
//            // Validate and potentially repair loaded conversations
//            for i in loaded.indices.reversed() { // Iterate backwards for safe removal
//                // Ensure title exists
//                if loaded[i].title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                    loaded[i].title = String(loaded[i].messages.first(where: {$0.role == .user})?.content.prefix(32) ?? "Untitled")
//                    print("🛠️ Repaired title for conversation \(loaded[i].id)")
//                }
//                // Ensure at least one user or assistant message exists
//                if !loaded[i].messages.contains(where: { $0.role == .user || $0.role == .assistant }) {
//                    print("🗑️ Removing invalid conversation \(loaded[i].id) (no user/assistant messages)")
//                    loaded.remove(at: i)
//                    continue // Skip next check
//                }
//            }
//            
//            // Sort by creation date, most recent first
//            loaded.sort { $0.createdAt > $1.createdAt }
//            
//            self.conversations = loaded
//            print("💾 Loaded and validated \(self.conversations.count) conversations.")
//        } catch {
//            print("❌ Failed to decode chat history: \(error). Clearing corrupted data.")
//            self.conversations = []
//            UserDefaults.standard.removeObject(forKey: "ChatHistory_v2")
//            // Don't show UI error on initial load failure, just log it.
//        }
//    }
//    
//    private func saveToDisk() {
//        // Filter out any conversations that are truly empty or invalid before saving
//        let validConversations = conversations.filter {
//            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
//            $0.messages.contains { $0.role == .user || $0.role == .assistant }
//        }
//        
//        guard !validConversations.isEmpty else {
//            if UserDefaults.standard.object(forKey: "ChatHistory_v2") != nil {
//                UserDefaults.standard.removeObject(forKey: "ChatHistory_v2")
//                print("💾 Removed chat history key (no valid conversations to save).")
//            }
//            return
//        }
//        
//        do {
//            // Sort before saving to maintain order consistency (optional but good practice)
//            let sortedConversations = validConversations.sorted { $0.createdAt > $1.createdAt }
//            
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted // Makes debugging easier
//            let data = try encoder.encode(sortedConversations)
//            UserDefaults.standard.set(data, forKey: "ChatHistory_v2")
//            print("💾 Saved \(sortedConversations.count) conversations.")
//        } catch {
//            print("❌ Failed to encode chat history: \(error)")
//            self.errorMessage = "Không thể lưu lịch sử chat." // Show error in main UI
//        }
//    }
//    
//    func upsertConversation() {
//        // Essential Check: Must have at least one user or assistant message
//        guard current.messages.contains(where: { $0.role == .user || $0.role == .assistant }) else {
//            print("💾 Upsert skipped: No user/assistant message in current conversation \(current.id).")
//            return
//        }
//        
//        // Ensure title generation/validation
//        let defaultTitle = "Chat \(current.createdAt.formatted(.numeric))" // More descriptive default
//        if current.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || current.title == "New Chat" {
//             // Generate title from first user message if possible, otherwise use default
//            current.title = current.messages.first(where: { $0.role == .user })?.content.prefix(32).trimmingCharacters(in: .whitespacesAndNewlines) ?? defaultTitle
//            if current.title.isEmpty { current.title = defaultTitle } // Handle case where user message was just whitespace
//            print("💾 Generated title '\(current.title)' for conversation \(current.id)")
//        } else {
//             current.title = current.title.trimmingCharacters(in: .whitespacesAndNewlines) // Clean existing title
//        }
//        
//        // Find and update or insert
//        if let index = conversations.firstIndex(where: { $0.id == current.id }) {
//            print("💾 Upserting: Updating conversation ID \(current.id) at index \(index)")
//            conversations[index] = current // Update existing
//        } else {
//            print("💾 Upserting: Inserting new conversation ID \(current.id) with title '\(current.title)'")
//            conversations.insert(current, at: 0) // Insert new at the beginning
//        }
//        // saveToDisk() is handled by the didSet observer on `conversations`
//    }
//    
//} // End ChatStore
//
//
//// MARK: - 4.1 TTS Delegate (Unchanged from V4)
//
//class TTSSpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        do {
//            let session = AVAudioSession.sharedInstance()
//            try session.setCategory(.playback, mode: .voicePrompt, options: [.duckOthers]) // Keep ducking
//            try session.setActive(true, options: .notifyOthersOnDeactivation)
//            print("🔊 TTSSpeechDelegate: Audio session ACTIVATED.")
//        } catch { print("❌ TTSSpeechDelegate: Error activating audio session: \(error)") }
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        print("🔊 TTSSpeechDelegate: DidFinish utterance.")
//        deactivateAudioSession(synthesizer: synthesizer)
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
//        print("🔊 TTSSpeechDelegate: DidCancel utterance.")
//        deactivateAudioSession(synthesizer: synthesizer)
//    }
//
//    private func deactivateAudioSession(synthesizer: AVSpeechSynthesizer) {
//        // Use a slight delay to prevent glitches if speech restarts immediately
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            do {
//                // Check if synth is *still* not speaking before deactivating
//                guard !synthesizer.isSpeaking else {
//                    print("🔊 TTSSpeechDelegate: Synthesizer restarted quickly, keeping session active.")
//                    return
//                }
//                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//                print("🔊 TTSSpeechDelegate: Audio session DEACTIVATED.")
//            } catch { print("❌ TTSSpeechDelegate: Error deactivating audio session: \(error)") }
//        }
//    }
//}
//
//
//// MARK: — 5. UI Subviews (Connecting functionality)
//
//// Displays a single message bubble (Added functional Respeak)
//struct MessageBubble: View {
//    let message: Message
//    let onRespeak: (String) -> Void // Callback passed from ScrollView
//
//    var isUser: Bool { message.role == .user }
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            if isUser { Spacer(minLength: 40) }
//
//            if message.role == .assistant {
//                Image(systemName: "sparkles.circle.fill") // Changed icon slightly
//                    .font(.caption)
//                    .foregroundColor(.purple.opacity(0.8))
//                    .padding(.bottom, 5)
//                    .accessibilityHidden(true)
//            }
//
//            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
//                Text(message.content)
//                    .textSelection(.enabled)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .background(isUser ? Color.blue.opacity(0.9) : Color.secondary.opacity(0.15)) // Adjusted assistant color
//                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                    .foregroundColor(isUser ? .white : .primary)
//                    .fixedSize(horizontal: false, vertical: true)
//
//                Text(message.timestamp, style: .time)
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            }
//
//            if message.role == .user {
//                Image(systemName: "person.crop.circle.fill") // Changed icon slightly
//                    .font(.caption)
//                    .foregroundColor(.blue.opacity(0.8))
//                    .padding(.bottom, 5)
//                    .accessibilityHidden(true)
//            }
//
//            if !isUser { Spacer(minLength: 40) }
//        }
//        .contextMenu {
//            // Functional Copy Button
//            Button {
//                UIPasteboard.general.string = message.content
//                print("📋 Copied message: \(message.content.prefix(20))...")
//            } label: {
//                Label("Sao chép", systemImage: "doc.on.doc")
//            }
//
//            // Functional Respeak Button
//            if message.role == .assistant && !message.content.isEmpty {
//                Button {
//                    print("🔊 Context Menu: Respeak requested.")
//                    onRespeak(message.content) // Call the passed-in function
//                } label: {
//                    Label("Đọc Lại", systemImage: "speaker.wave.2.fill")
//                }
//            }
//            
//            // Functional Share Button
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
//
//// Chat Input Bar (Functional VUI trigger, refined disabling)
//struct ChatInputBar: View {
//    @Binding var text: String
//    @ObservedObject var store: ChatStore // For VUI state + send action
//    @ObservedObject var speech: SpeechRecognizer // For SR errors (optional)
//    @FocusState var isFocused: Bool
//
//    // Computed property to determine if Send should be enabled
//    private var canSend: Bool {
//        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
//        !store.isLoading &&
//        store.vuiState == .idle // Only allow send if VUI is idle
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Optional: Show Speech Recognizer errors (transient)
//            if let srError = speech.errorMessage {
//                Text(srError)
//                    .font(.caption).foregroundColor(.red).padding(.horizontal).padding(.bottom, 4)
//                    .frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
//                    .transition(.opacity.combined(with: .move(edge: .bottom)))
//            }
//
//            // Main Input Row
//            HStack(spacing: 10) { // Increased spacing
//                // Text Field
//                TextField("Nhập tin nhắn hoặc nhấn mic...", text: $text, axis: .vertical)
//                    .focused($isFocused)
//                    .lineLimit(1...5) // Increased line limit slightly
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .background(Color(.systemGray6)) // Slightly different background
//                    .clipShape(Capsule()) // Use Capsule shape
//                    .overlay(Capsule().stroke(isFocused ? Color.accentColor.opacity(0.6) : Color.gray.opacity(0.2), lineWidth: 1))
//                    .disabled(store.isLoading || store.vuiState != .idle) // Disabled if loading or VUI active
//                    .onSubmit { // Send on Return key if text exists
//                        if canSend { store.sendMessage(text) }
//                    }
//
//                // Microphone Button (Triggers VUI)
//                micButton
//
//                // Send Button (Conditional visibility or appearance)
//                // Option 1: Always show, change appearance
//                sendButton
//
//                // Option 2: Hide send button if text is empty (more compact)
//                /*
//                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                    sendButton
//                        .transition(.opacity.combined(with: .scale))
//                }
//                */
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//            .background(.thinMaterial) // Standard bar background
//        }
//        .animation(.default, value: speech.errorMessage) // Animate error appearance/disappearance
//        .onChange(of: speech.errorMessage) { _, newValue in // Auto-clear SR error
//            if newValue != nil {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {  // Slightly longer display
//                    if speech.errorMessage == newValue { speech.errorMessage = nil }
//                }
//            }
//        }
//    }
//
//    // Mic Button (Functional: starts VUI)
//    private var micButton: some View {
//        Button {
//            isFocused = false // Dismiss keyboard
//            if store.vuiState == .idle && !store.isLoading {
//                print("🎤 Mic button tapped, starting VUI.")
//                store.startVUIInteraction()
//            } else {
//                print("🎤 Mic button tapped, but VUI not idle or app is loading.")
//            }
//        } label: {
//            // Animate icon based on VUI state
//            Image(systemName: store.vuiState == .idle ? "mic.circle.fill" : "mic.slash.circle.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 30, height: 30) // Slightly larger
//                .symbolRenderingMode(.palette) // Allows foreground/background colors
//                .foregroundStyle(.white, store.vuiState == .idle ? Color.accentColor : Color.gray) // White inner, accent/gray outer
//                .opacity(store.isLoading ? 0.5 : 1.0) // Dim if loading globally
//        }
//        // Disable only if globally loading (allows cancelling VUI via background tap)
//        .disabled(store.isLoading)
//        .animation(.easeInOut, value: store.vuiState)
//        .accessibilityLabel(store.vuiState == .idle ? "Bắt đầu nhập liệu bằng giọng nói" : "Nhập liệu bằng giọng nói đang hoạt động")
//    }
//
//    // Send Button View (Functional: sends text message)
//    private var sendButton: some View {
//        Button {
//             if canSend {
//                 print("➡️ Send button tapped.")
//                 store.sendMessage(text)
//                 // Clearing text is now handled within sendMessage
//             } else {
//                  print("➡️ Send button tapped, but cannot send (condition not met).")
//             }
//        } label: {
//            Image(systemName: "arrow.up.circle.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 30, height: 30)
//                .foregroundStyle(canSend ? Color.accentColor : Color.gray.opacity(0.5))
//        }
//        .disabled(!canSend) // Disable based on computed property
//        .animation(.easeInOut, value: canSend) // Animate color change
//        .accessibilityLabel("Gửi tin nhắn")
//    }
//}
//
//
//// MARK: — Settings Sheet (Functional Save)
//
//struct SettingsSheet: View {
//    @ObservedObject var store: ChatStore
//    // Local states for temporary edits
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
//    // No callback needed, we access store directly
//
//    // Init to load store values into local state
//    init(store: ChatStore) {
//        self._store = ObservedObject(initialValue: store) // Use ObservedObject init correctly
//        // Initialize @State vars from the store's current values
//        _localApiKey = State(initialValue: store.apiKey)
//        _localOpenAIModelName = State(initialValue: store.openAIModelName)
//        _localOpenAITemperature = State(initialValue: store.openAITemperature)
//        _localOpenAIMaxTokens = State(initialValue: store.openAIMaxTokens)
//        _localBackendType = State(initialValue: store.backendType)
//        _localCoreMLModelName = State(initialValue: store.coreMLModelName)
//        _localSystemPrompt = State(initialValue: store.systemPrompt)
//        _localTtsEnabled = State(initialValue: store.ttsEnabled)
//        _localTtsRate = State(initialValue: Float(store.ttsRate)) // Convert Double to Float
//        _localTtsVoiceID = State(initialValue: store.ttsVoiceID)
//    }
//
//    // Computed property to check if save should be enabled
//    var canSave: Bool {
//        // Cannot save if OpenAI is selected but the key is empty
//        !(localBackendType == .openAI && localApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//    }
//
////    var body: some View {
////        NavigationStack {
////            Form {
////                // MARK: Backend Selection
////                Section("Backend Engine") {
////                    Picker("Chọn Backend", selection: $localBackendType) {
////                        ForEach(BackendType.allCases) { type in Text(type.rawValue).tag(type) }
////                    }
////                    .pickerStyle(.menu) // More compact picker style
////                }
////                
////                // MARK: OpenAI Configuration (Conditional)
////                if localBackendType == .openAI {
////                    Section("Cấu hình OpenAI") {
////                        Picker("Model", selection: $localOpenAIModelName) {
////                            ForEach(store.availableOpenAIModels, id: \.self) { Text($0) }
////                        }
////                        HStack { Text("Nhiệt độ:"); Slider(value: $localOpenAITemperature, in: 0...1.5, step: 0.05); Text("\(localOpenAITemperature, specifier: "%.2f")").frame(width: 45, alignment: .trailing) } // Wider text field
////                        Stepper("Tokens Tối đa: \(localOpenAIMaxTokens)", value: $localOpenAIMaxTokens, in: 64...4096, step: 64)
////                        LabeledContent("API Key") { // Use LabeledContent for better alignment
////                           SecureField("Dán API Key của bạn...", text: $localApiKey)
////                               .lineLimit(1).autocapitalization(.none).disableAutocorrection(true)
////                               .multilineTextAlignment(.trailing) // Align key to the right
////                        }
////                        if localApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
////                            Text("⚠️ Cần có API key để sử dụng OpenAI.").font(.footnote).foregroundColor(.orange)
////                        }
////                    }
////                }
////
////                // MARK: CoreML Configuration (Conditional)
////                if localBackendType == .coreML {
////                    Section("Cấu hình CoreML") {
////                        Picker("Chọn CoreML Model", selection: $localCoreMLModelName) {
////                            ForEach(store.availableCoreMLModels, id: \.self) { model in Text(model).tag(model) }
////                        }
////                         // Add info about local models if needed
////                         Text("Đảm bảo tệp '\(localCoreMLModelName).mlmodelc' có trong ứng dụng.")
////                            .font(.caption).foregroundColor(.secondary)
////                    }
////                }
////
////                // MARK: General Settings
////                Section("Cài đặt Chung") {
////                    VStack(alignment: .leading) {
////                        Text("System Prompt (Tính cách AI)")
////                        TextEditor(text: $localSystemPrompt)
////                             .frame(height: 120) // Slightly more height
////                             .font(.body)
////                             .border(Color.gray.opacity(0.2), width: 1) // Use border instead of overlay
////                             .clipShape(RoundedRectangle(cornerRadius: 6))
////                             .padding(.bottom, 5)
////                    }
////                }
////
////                // MARK: Text-to-Speech Settings
////                Section("Đọc Phản Hồi (TTS)") {
////                    Toggle("Bật Đọc Phản Hồi", isOn: $localTtsEnabled)
////                    if localTtsEnabled {
////                        Picker("Giọng Đọc", selection: $localTtsVoiceID) {
////                             // Group by language for clarity
////                            ForEach(["vi-VN", "en-US", "en-GB"], id: \.self) { langCode in // Prioritize these
////                                Section(header: Text(Locale.current.localizedString(forLanguageCode: langCode.prefix(2)) ?? langCode)) {
////                                     ForEach(store.availableVoices.filter { $0.language == langCode }, id: \.identifier) { voice in
////                                         Text(voice.name).tag(voice.identifier)
////                                     }
////                                 }
////                            }
////                            // Add other voices if any exist
////                            let otherVoices = store.availableVoices.filter { !["vi-VN", "en-US", "en-GB"].contains($0.language) }
////                            if !otherVoices.isEmpty {
////                                Section(header: Text("Khác")) {
////                                    ForEach(otherVoices, id: \.identifier) { voice in
////                                         Text("\(voice.name) (\(voice.language))").tag(voice.identifier)
////                                     }
////                                }
////                            }
////                        }
////                        HStack {
////                            Text("Tốc độ đọc:")
////                            Slider(value: $localTtsRate, in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate, step: 0.05) // Finer step
////                            Text("\(localTtsRate, specifier: "%.2f")x").frame(width: 50, alignment: .trailing) // Add 'x'
////                        }
////                        Text("Mặc định: \(String(format: "%.2f", AVSpeechUtteranceDefaultSpeechRate))x").font(.caption).foregroundColor(.secondary)
////                    }
////                }
////            }
////            .navigationTitle("Cài đặt Chat")
////            .navigationBarTitleDisplayMode(.inline)
////            .toolbar {
////                ToolbarItem(placement: .navigationBarLeading) { Button("Hủy") { dismiss() } }
////                ToolbarItem(placement: .navigationBarTrailing) {
////                    Button("Lưu") {
////                        applyChanges()
////                        dismiss()
////                    }
////                    // Disable Save button based on computed property
////                    .disabled(!canSave)
////                }
////            }
////        }
////    }
//
//    /// Applies the local changes from @State variables back to the ChatStore's @AppStorage variables.
//    private func applyChanges() {
//        print("💾 Applying settings changes...")
//        
//        // 1. Update non-backend settings directly in ChatStore (triggers @AppStorage save)
//        store.systemPrompt = localSystemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
//        store.ttsEnabled = localTtsEnabled
//        store.ttsRate = Double(localTtsRate) // Convert Float back to Double
//        store.ttsVoiceID = localTtsVoiceID
//
//        // 2. Update backend-related settings in ChatStore
//        store.apiKey = localApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
//        store.openAIModelName = localOpenAIModelName
//        store.openAITemperature = localOpenAITemperature
//        store.openAIMaxTokens = localOpenAIMaxTokens
//        store.coreMLModelName = localCoreMLModelName
//
//        // 3. Update backendType LAST. Its `didSet` in ChatStore will trigger `configureBackend`.
//        store.backendType = localBackendType
//
//        print("💾 Settings applied. Backend type set to: \(store.backendType.rawValue).")
//    }
//}
//
//
//// MARK: — History Sheet (Functional Actions)
//
//struct HistorySheet: View {
//    // Use Binding to directly modify the store's conversations array
//    @Binding var conversations: [Conversation]
//    // Actions passed from the parent view (connected to ChatStore methods)
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
//                    ContentUnavailableView {
//                         Label("Không có lịch sử chat", systemImage: "bubble.middle.bottom.fill")
//                    } description: {
//                         Text("Các đoạn chat đã lưu sẽ xuất hiện ở đây.").padding(.top)
//                    }
//                    .padding(.vertical, 50)
//                } else {
//                    List {
//                        ForEach(conversations) { convo in
//                             historyRow(for: convo)
//                                 .contentShape(Rectangle()) // Make entire row tappable
//                                 .onTapGesture {
//                                     print("📜 History: Selecting conversation \(convo.id)")
//                                     onSelect(convo)
//                                     dismiss()
//                                 }
//                                 // Swipe to delete action
//                                 .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                                     Button(role: .destructive) {
//                                         print("📜 History: Swipe deleting conversation \(convo.id)")
//                                         onDelete(convo.id)
//                                     } label: {
//                                         Label("Xóa", systemImage: "trash.fill")
//                                     }
//                                 }
//                                 // Context menu for more actions
//                                 .contextMenu { rowContextMenu(for: convo) }
//                        }
//                        // No need for .onDelete modifier if using swipeActions
//                    }
//                    .listStyle(.plain)
//                }
//
//                // Clear All button shown only if history exists
//                if !conversations.isEmpty {
//                    Button("Xóa Tất Cả Lịch Sử", role: .destructive) {
//                         showingClearConfirm = true
//                    }
//                    .padding(.vertical)
//                    .buttonStyle(.borderedProminent).tint(.red) // Make it stand out
//                }
//            }
//            .navigationTitle("Lịch sử Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) { EditButton() } // Standard Edit button
//                ToolbarItem(placement: .navigationBarTrailing) { Button("Xong") { dismiss() } }
//            }
//            // Rename Alert (Functional)
//            .alert("Đổi tên Đoạn Chat", isPresented: $showingRenameAlert, presenting: conversationToRename) { convo in
//                 TextField("Tên mới", text: $newConversationTitle)
//                     .onAppear { newConversationTitle = convo.title } // Pre-fill with current title
//                 Button("Lưu") {
//                     let trimmed = newConversationTitle.trimmingCharacters(in: .whitespacesAndNewlines)
//                     if !trimmed.isEmpty {
//                         print("📜 History: Saving rename for \(convo.id) to '\(trimmed)'")
//                         onRename(convo, trimmed)
//                     } else {
//                         print("📜 History: Rename skipped (empty title)")
//                     }
//                 }
//                 Button("Hủy", role: .cancel) {}
//            } message: { convo in Text("Nhập tên mới cho \"\(convo.title)\"") }
//            // Clear Confirmation Alert (Functional)
//            .alert("Xác nhận Xóa?", isPresented: $showingClearConfirm) {
//                 Button("Xóa Tất Cả", role: .destructive) {
//                     print("📜 History: Clearing all history confirmed.")
//                     onClear()
//                     dismiss() // Dismiss sheet after clearing
//                 }
//                 Button("Hủy", role: .cancel) {}
//            } message: { Text("Bạn có chắc muốn xóa toàn bộ lịch sử chat? Hành động này không thể hoàn tác.") }
//        }
//        .presentationDetents([.medium, .large]) // Allow resizing
//    }
//
//    // Row View Component
//    private func historyRow(for conversation: Conversation) -> some View {
//         HStack {
//             Image(systemName: "bubble.left.and.bubble.right") // Chat icon
//                 .foregroundColor(.secondary).padding(.trailing, 5)
//             VStack(alignment: .leading, spacing: 4) {
//                 Text(conversation.title).font(.headline).lineLimit(1)
//                 // Count messages excluding system prompt
//                 let messageCount = conversation.messages.filter{$0.role != .system}.count
//                 Text("\(messageCount) tin nhắn - \(conversation.createdAt, style: .relative) trước") // Relative time
//                     .font(.caption).foregroundColor(.secondary)
//             }
//             Spacer()
//             // More actions button (ellipsis) - context menu attached to row now
//             // Image(systemName: "ellipsis.circle").foregroundColor(.gray).padding(.leading, 5).imageScale(.large)
//         }
//         .padding(.vertical, 6) // Slightly more padding
//    }
//    
//    // Context Menu Content for the Row
//    @ViewBuilder private func rowContextMenu(for conversation: Conversation) -> some View {
//        // Rename Action
//        Button {
//            print("📜 History Menu: Rename requested for \(conversation.id)")
//            conversationToRename = conversation // Set the conversation for the alert
//            // Delay showing alert slightly to allow menu to dismiss smoothly
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                showingRenameAlert = true
//            }
//        } label: { Label("Đổi tên", systemImage:"pencil") }
//
//        // Share Action (Functional)
//        ShareLink(item: formatConversationForSharing(conversation),
//                  subject: Text("Lịch sử chat: \(conversation.title)"),
//                  message: Text("Được chia sẻ từ ứng dụng Chat Demo.")) { // Add subject/message
//             Label("Chia sẻ", systemImage: "square.and.arrow.up")
//        }
//
//        Divider()
//
//        // Destructive Delete Action
//        Button(role: .destructive) {
//             print("📜 History Menu: Delete requested for \(conversation.id)")
//             onDelete(conversation.id)
//        } label: { Label("Xóa", systemImage: "trash") }
//    }
//
//    // Helper to format conversation text for sharing
//    private func formatConversationForSharing(_ conversation: Conversation) -> String {
//        var shareText = "Chat: \(conversation.title)\n"
//        shareText += "Ngày: \(conversation.createdAt.formatted(date: .numeric, time: .shortened))\n===\n\n"
//        for message in conversation.messages where message.role != .system {
//            let prefix = message.role == .user ? "👤 Bạn:" : "🤖 AI:"
//            shareText += "\(prefix)\n\(message.content)\n\n"
//        }
//        return shareText.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//}
//
//
//// MARK: — 5.1 VUI Subviews (Unchanged Visually, but driven by functional store/speech)
//
//// Close Button for VUI Overlay (Action passed in)
//struct VUICloseButton: View {
//    let action: () -> Void // Passed from TakeoverVUIView
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: "xmark.circle.fill")
//                .resizable().scaledToFit().frame(width: 32, height: 32) // Slightly larger
//                .foregroundStyle(.white.opacity(0.8), Color.black.opacity(0.3))
//                .padding(12) // Slightly smaller padding area
//        }
//        .contentShape(Rectangle()) // Ensure tappable area includes padding
//        .accessibilityLabel("Đóng Nhập liệu bằng Giọng nói")
//    }
//}
//
//// Suggested Prompts View (Action passed in)
//struct SuggestedPromptsView: View {
//    let prompts: [String]
//    let onSelect: (String) -> Void // Passed from TakeoverVUIView
//
//    var body: some View {
//        VStack(spacing: 12) {
//            ForEach(prompts, id: \.self) { prompt in
//                Button { onSelect(prompt) } label: {
//                    Text(prompt)
//                        .font(.system(size: 17, weight: .medium)) // Slightly larger font
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity, alignment: .center) // Center text
//                        .padding(.vertical, 15)
//                        .padding(.horizontal, 12)
//                        .background(Color.white.opacity(0.2)) // Slightly more visible background
//                        .clipShape(RoundedRectangle(cornerRadius: 14))
//                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.5), lineWidth: 1))
//                }
//                .buttonStyle(.plain) // Remove default button effects for better custom look
//            }
//        }
//        .padding(.horizontal, 35) // Adjusted padding
//    }
//}
//
//// Simple Audio Visualizer View (Driven by functional SpeechRecognizer)
//struct AudioVisualizerView: View {
//    @ObservedObject var speech: SpeechRecognizer // Takes the functional instance
//    let barCount: Int = 6 // Increased bar count
//
//    var body: some View {
//        // Directly use audioLevel, animation smoothed in the recognizer/view modifier
//        let level = CGFloat(speech.audioLevel)
//        
//        HStack(spacing: 5) { // Reduced spacing
//            ForEach(0..<barCount, id: \.self) { index in
//                // Use a slightly different calculation for height based on index and level
//                let calculatedHeight = calculateBarHeight(level: level, index: index, barCount: barCount)
//
//                RoundedRectangle(cornerRadius: 3)
//                    .fill(Material.bar) // Use a material-like fill for depth
//                    .frame(width: 6, height: max(6, calculatedHeight)) // Maintain min height
//            }
//        }
//        .frame(height: 60) // Keep fixed height
//        .opacity(level > 0.02 ? 1.0 : 0.5) // Fade out when mostly silent
//        // Apply animation directly to the HStack content changes
//        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0.1), value: level)
//    }
//
//    // Refined bar height calculation
//    private func calculateBarHeight(level: CGFloat, index: Int, barCount: Int) -> CGFloat {
//        let maxBarHeight: CGFloat = 55.0
//        let minBarHeight: CGFloat = 6.0
//        let midIndex = CGFloat(barCount - 1) / 2.0 // Correct midIndex calculation
//        // Gaussian-like falloff from center
//        let falloff = exp(-pow(CGFloat(index) - midIndex, 2) / (CGFloat(barCount) * 0.5)) // Adjust divisor for spread
//        // Make it more sensitive to lower levels
//        let sensitivity: CGFloat = 1.7
//        let scaledLevel = pow(max(0, level), sensitivity) // Ensure level >= 0
//
//        let dynamicHeight = (maxBarHeight - minBarHeight) * scaledLevel * falloff
//        return minBarHeight + dynamicHeight
//    }
//}
//
//// MARK: — 5.2 Takeover VUI Overlay (Functional Connections)
//
//struct TakeoverVUIView: View {
//    @ObservedObject var store: ChatStore
//    @ObservedObject var speech: SpeechRecognizer
//    
//    @State private var showAcknowledgedText = false
//    
//    var body: some View {
//        ZStack {
//            // Background: Dynamic gradient based on listening state + Blur
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color.blue.opacity(speech.isRecording ? 0.8 : 0.6), // More intense blue when listening
//                    Color.purple.opacity(speech.isRecording ? 0.6 : 0.4) // More purple when listening
//                ]),
//                startPoint: .topLeading, endPoint: .bottomTrailing
//            )
//            .overlay(.ultraThinMaterial) // Blur layer on top of gradient
//            .ignoresSafeArea()
//            .onTapGesture { // Functional background tap to cancel
//                if store.vuiState == .prompting || store.vuiState == .listening || store.vuiState == .acknowledging {
//                    print("⚫️ VUI Background tapped, dismissing.")
//                    speech.stopRecording() // Ensure speech stops first
//                    Task { @MainActor in store.dismissVUI() } // Dismiss store state
//                }
//            }
//            
//            // Content VStack
//            VStack {
//                Spacer() // Push content lower
//                
//                // VUI State Content Switch (Transitions between states)
//                Group {
//                    switch store.vuiState {
//                    case .prompting:     promptingContent.transition(.opacity.combined(with: .scale(scale: 0.9)))
//                    case .listening:     listeningContent.transition(.opacity)
//                    case .acknowledging: acknowledgingContent.transition(.opacity)
//                    case .processing:    processingContent.transition(.opacity)
//                    case .idle:          EmptyView() // Should not be visible, but handle state
//                    }
//                }
//                .padding(.horizontal, 30)
//                
//                // VUI Error Message Display
//                if let vuiError = store.vuiErrorMessage {
//                    Text(vuiError)
//                        .font(.footnote).bold() // Make error slightly bolder
//                        .foregroundColor(.white.opacity(0.85))
//                        .padding(.top, 15)
//                        .padding(.horizontal, 40)
//                        .multilineTextAlignment(.center)
//                        .transition(.opacity)
//                        .id("VUIError:\(vuiError)") // ID to potentially re-trigger transition
//                } else {
//                    // Placeholder to maintain layout consistency when no error
//                    Text(" ").font(.footnote).padding(.top, 15).padding(.horizontal, 40)
//                }
//                
//                Spacer() // Separator
//                
//                // Audio Visualizer (Always visible, animates based on speech level)
//                AudioVisualizerView(speech: speech)
//                    .padding(.bottom, 45) // Adjusted padding
//            }
//            .padding(.vertical, 20)
//            
//            // Close Button (Top Right - Functional)
//            VStack {
//                HStack {
//                    Spacer()
//                    VUICloseButton { // Pass functional closure
//                        print("❌ VUI Close button tapped.")
//                        speech.stopRecording() // Stop speech
//                        Task { @MainActor in store.dismissVUI() } // Dismiss state
//                    }
//                }
//                Spacer()
//            }
//            .padding(.top, safeAreaInsets.top + 5) // Adjust for safe area
//            .padding(.trailing)
//            
//        }
//        // Trigger listening when prompting state appears
//        .onChange(of: store.vuiState) { _, newState in
//            if newState == .prompting {
//                // Delay slightly for smoother UI transition before asking permission/starting
//                print("🔁 VUI State changed to Prompting. Scheduling listen start.")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                    // Check if state is still prompting before starting
//                    if store.vuiState == .prompting {
//                        store.handleVUIListenStartRequest(speechRecognizer: speech)
//                    } else {
//                        print("⚠️ Listen start cancelled: VUI state changed before delay finished (\(store.vuiState)).")
//                    }
//                }
//            }
//            // Reset acknowledge animation flag
//            if newState != .acknowledging {
//                showAcknowledgedText = false
//            }
//        }
//        .onDisappear {
//            // Ensure speech recognizer is stopped if the view disappears unexpectedly
//            if speech.isRecording {
//                print("⚠️ TakeoverVUIView disappearing while recording, stopping speech.")
//                speech.stopRecording()
//            }
//        }
//    }
//    
//    // MARK: - VUI State Content Views (Functional Prompts)
//    private var promptingContent: some View {
//        VStack(spacing: 30) { // Increased spacing
//            Text("Nói yêu cầu của bạn,\nhoặc chọn một gợi ý:") // Slightly rephrased
//                .font(.title2).fontWeight(.medium) // Slightly smaller title
//                .foregroundColor(.white)
//                .shadow(color: .black.opacity(0.2), radius: 3, y: 2) // Add subtle shadow
//                .multilineTextAlignment(.center)
//            
//            // Functional Suggested Prompts
//            SuggestedPromptsView(prompts: store.suggestedPrompts) { selectedPrompt in
//                print("💡 Suggested prompt selected: \(selectedPrompt)")
//                if speech.isRecording { speech.stopRecording() } // Stop if accidentally listening
//                // Trigger the processing flow directly from ChatStore
//                Task { @MainActor in
//                    store.stopListeningAndProcessVUI(recognizedText: selectedPrompt)
//                }
//            }
//        }
//    }
//    
//    // Listening state view (uses store's transcript)
//    private var listeningContent: some View {
//        // Use a minimum height to prevent layout jumps
//        Text(store.vuiTranscript.isEmpty ? "Đang nghe..." : store.vuiTranscript)
//            .font(.system(size: store.vuiTranscript.isEmpty ? 28 : 36, weight: .semibold)) // Dynamic size
//            .foregroundColor(.white)
//            .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
//            .multilineTextAlignment(.center)
//            .frame(maxWidth: .infinity)
//            .frame(minHeight: 120, alignment: .center) // Ensure min height
//            .scaleEffect(showAcknowledgedText ? 1.0 : 0.95) // Use state for subtle animation
//            .opacity(showAcknowledgedText ? 1.0 : 0.8)
//            .onAppear {
//                // Animate in when listening starts
//                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
//                    showAcknowledgedText = true
//                }
//            }
//    }
//}
//
////    private var acknowledgingContent: some View {
////         Text(store.vuiTranscript)
////             .font(.system(size: 30, weight: .medium)) // Consistent size
////             .foregroundColor(.white)
////             .shadow
