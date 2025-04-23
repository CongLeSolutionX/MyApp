//
//  LiveVoiceChatApp_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/22/25.
//
//
//  ChatDemoVUI_v2.swift
//  MyApp
//
//  Created by Cong Le (AI Assistant) on 4/23/25.
//
//  Single-file SwiftUI Chat Demo with Takeover Voice UI
//
//  Combines Mock, OpenAI, & CoreML backends with Text & Speech I/O.
//  Implements the "Takeover Interface" VUI design concept.
//
//  Requires: Xcode 15+, iOS 17+
//

import SwiftUI
import Combine
import Speech         // For Speech Recognition (Input)
import AVFoundation   // For Text-to-Speech (Output) & Audio Session Management
import CoreML         // For potential local model inference

// MARK: — 1. Data Models (Unchanged from previous version)

enum ChatRole: String, Codable, Hashable {
    case system, user, assistant
}

struct Message: Identifiable, Codable, Hashable {
    let id: UUID
    let role: ChatRole
    let content: String
    let timestamp: Date

    init(role: ChatRole, content: String, timestamp: Date = .now, id: UUID = .init()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }

    static func system(_ text: String)    -> Message { .init(role: .system,    content: text) }
    static func user(_ text: String)      -> Message { .init(role: .user,      content: text) }
    static func assistant(_ text: String) -> Message { .init(role: .assistant, content: text) }
}

struct Conversation: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var messages: [Message]
    var createdAt: Date

    init(id: UUID = .init(),
         title: String = "",
         messages: [Message] = [],
         createdAt: Date = .now)
    {
        self.id = id
        self.messages = messages
        self.createdAt = createdAt
        if title.isEmpty {
            let firstUser = messages.first(where: { $0.role == .user })?.content ?? "New Chat"
            self.title = String(firstUser.prefix(32))
        } else {
            self.title = title
        }
    }
}

// MARK: — 2. Backend Protocols & Implementations (Unchanged)

protocol ChatBackend {
    func streamChat(messages: [Message], systemPrompt: String, completion: @escaping (Result<String, Error>) -> Void)
}

struct MockChatBackend: ChatBackend {
    let replies = [
        "Chắc chắn rồi!", "Okay!", "Để tôi xem...", "Tôi hiểu rồi.",
        "Bạn muốn biết thêm gì?", "Có thể nói rõ hơn không?", "Một ý tưởng hay!"
    ]
    func streamChat(messages: [Message], systemPrompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(.success(replies.randomElement()!))
        }
    }
}

final class RealOpenAIBackend: ChatBackend {
    let apiKey: String, model: String, temperature: Double, maxTokens: Int
    init(apiKey: String, model: String, temperature: Double, maxTokens: Int) {
        self.apiKey = apiKey; self.model = model; self.temperature = temperature; self.maxTokens = maxTokens
    }
    struct RequestPayload: Encodable { struct M: Encodable { let role: String; let content: String }; let model: String; let messages: [M]; let temperature: Double; let max_tokens: Int }
    struct ResponsePayload: Decodable { struct C: Decodable { struct M: Decodable { let content: String }; let message: M }; let choices: [C] }
    struct ErrorResponse: Decodable { struct ED: Decodable { let message: String }; let error: ED? }

    func streamChat(messages: [Message], systemPrompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        var allMessages = systemPrompt.isEmpty ? messages : [.system(systemPrompt)] + messages
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return completion(.failure(NSError(domain: "InvalidURL", code: 0))) }
        var request = URLRequest(url: url); request.httpMethod = "POST"; request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization"); request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = RequestPayload(model: self.model, messages: allMessages.map { RequestPayload.M(role: $0.role.rawValue, content: $0.content) }, temperature: self.temperature, max_tokens: self.maxTokens)
        do { request.httpBody = try JSONEncoder().encode(body) } catch { return completion(.failure(error)) }

        URLSession.shared.dataTask(with: request) { data, _, error in
             DispatchQueue.main.async { // Ensure completion on main thread
                if let netErr = error { return completion(.failure(netErr)) }
                guard let respData = data else { return completion(.failure(NSError(domain: "NoData", code: 1))) }
                do {
                    let decoded = try JSONDecoder().decode(ResponsePayload.self, from: respData)
                    completion(.success(decoded.choices.first?.message.content ?? "Xin lỗi, tôi không nhận được phản hồi."))
                } catch {
                    var errorMsg = "Lỗi giải mã: \(error.localizedDescription)"
                    if let decodedError = try? JSONDecoder().decode(ErrorResponse.self, from: respData), let msg = decodedError.error?.message { errorMsg = "API Error: \(msg)" }
                    completion(.failure(NSError(domain: "DecodingError", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                }
             }
        }.resume()
    }
}

enum BackendType: String, CaseIterable, Identifiable { case mock="Mock"; case openAI="OpenAI"; case coreML="CoreML (Local)"; var id: Self { self } }

final class CoreMLChatBackend: ChatBackend {
    let modelName: String; lazy var coreModel: MLModel? = { guard let url = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else { print("!CoreML '\(modelName).mlmodelc' not found."); return nil }; do { let m = try MLModel(contentsOf: url); print("CoreML model loaded: \(modelName)"); return m } catch { print("!Error loading CoreML '\(modelName)': \(error)"); return nil } }()
    init(modelName: String) { self.modelName = modelName }
    func streamChat(messages: [Message], systemPrompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let model = coreModel else { return completion(.failure(NSError(domain: "CoreMLError", code: 1, userInfo: [NSLocalizedDescriptionKey: "CoreML model '\(modelName)' could not be loaded."]))) }
        let lastInput = messages.last(where: { $0.role == .user })?.content ?? ""
        let reply = "CoreML (\(self.modelName)) trả lời: '\(lastInput)'" // Placeholder
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { completion(.success(reply)) }
        // Actual inference: model.prediction(from: inputFeatures) -> outputFeatures
    }
}

// MARK: — 3. Speech Recognizer (Speech-to-Text - Largely Unchanged, Now Used by VUI)

// V5 SpeechRecognizer logic remains suitable for the takeover VUI
final class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var errorMessage: String?
    // VUI ADDITION: Rough audio level simulation
    @Published var audioLevel: Float = 0.0
    private var levelTimer: Timer?

    var onFinalTranscription: ((String) -> Void)?
    var onErrorOccurred: ((String) -> Void)? // Callback for errors during VUI

    private let recognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let silenceTimeout: TimeInterval = 1.8
    private var silenceWork: DispatchWorkItem?

    override init() { super.init(); self.recognizer?.delegate = self }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            let authorized = authStatus == .authorized
            DispatchQueue.main.async {
                if !authorized { self.errorMessage = "Quyền truy cập microphone và nhận dạng giọng nói là cần thiết." }
                else { self.errorMessage = nil }
                completion(authorized)
            }
        }
    }

    func startRecording() throws {
        errorMessage = nil; transcript = ""; isRecording = true; audioLevel = 0.0
        recognitionTask?.cancel(); recognitionTask = nil
        recognitionRequest?.endAudio(); recognitionRequest = nil
        silenceWork?.cancel(); silenceWork = nil
        levelTimer?.invalidate(); levelTimer = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create request") }
        recognitionRequest.shouldReportPartialResults = true; recognitionRequest.taskHint = .dictation

        guard let speechRecognizer = recognizer, speechRecognizer.isAvailable else {
            stopRecording(); throw NSError(domain: "RecognizerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Bộ nhận dạng giọng nói không khả dụng."])
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            var isFinal = false
            if let result = result {
                DispatchQueue.main.async { self.transcript = result.bestTranscription.formattedString }
                isFinal = result.isFinal
                if isFinal { self.finish(self.transcript) }
                else { self.scheduleSilence() }
            }
            if error != nil || isFinal { self.stopLevelTimer() } // Stop level timer on error or final result
            if let anError = error {
                DispatchQueue.main.async {
                    let errorMsg = (anError as NSError).code == 203 && self.transcript.isEmpty ? "Không nghe thấy gì." : "Lỗi nhận dạng: \(anError.localizedDescription)"
                    self.errorMessage = errorMsg
                    self.onErrorOccurred?(errorMsg) // VUI: Notify error listener
                    self.stopRecording()
                }
            } else if isFinal {
                  // Already handled calling finish above
                 self.stopRecording() // Stop audio parts even if finish was called
             }
        }

        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
             self.updateAudioLevel(buffer: buffer) // VUI: Update level
        }

        audioEngine.prepare(); try audioEngine.start()
        scheduleSilence(); startLevelTimer() // Start timers
    }

    private func scheduleSilence() {
       silenceWork?.cancel()
       let wi = DispatchWorkItem { [weak self] in
           guard let self = self, self.isRecording else { return }
           print("Silence detected.")
           self.finish(self.transcript)
       }
       silenceWork = wi
       DispatchQueue.main.asyncAfter(deadline: .now() + silenceTimeout, execute: wi)
   }

   private func finish(_ text: String) {
       guard isRecording else { return }
       print("Finish called with: '\(text)'")
       onFinalTranscription?(text)
       stopRecording()
   }

   func stopRecording() {
       guard isRecording else { return }
       print("stopRecording called.")
       isRecording = false; audioLevel = 0.0 // Reset level

       stopLevelTimer() // Stop level timer
       silenceWork?.cancel(); silenceWork = nil

       if audioEngine.isRunning { audioEngine.stop(); audioEngine.inputNode.removeTap(onBus: 0) }
       recognitionRequest?.endAudio()
       // Don't finish task, only cancel if it's still running (delegate handles final result)
       if recognitionTask?.error == nil && !(recognitionTask?.isFinishing ?? true) {
          recognitionTask?.cancel()
       }
         recognitionTask = nil; recognitionRequest = nil // Nullify AFTER ensures no race conditions

       do { try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation) }
       catch { print("Error deactivating audio session: \(error)") }
   }

    // --- VUI: Audio Level Simulation Logic ---
    private func startLevelTimer() {
        levelTimer?.invalidate()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // Simulate decay if no new level updates come in
            DispatchQueue.main.async {
                let currentLevel = self?.audioLevel ?? 0
                self?.audioLevel = max(0, currentLevel * 0.7) // Decay factor
            }
        }
    }

    private func stopLevelTimer() {
        levelTimer?.invalidate()
        levelTimer = nil
        // Ensure level goes to 0 when stopped
        DispatchQueue.main.async { self.audioLevel = 0.0 }
    }

    private func updateAudioLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let channelDataValue = channelData.pointee
        let channelDataValueArray = UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength))

        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms) // Power in dB

        // Normalize power level to 0-1 range (adjust magic numbers as needed)
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        var normalizedLevel = (avgPower - minDb) / (maxDb - minDb)
        normalizedLevel = max(0.0, min(1.0, normalizedLevel)) // Clamp

        // Update published property on main thread
        DispatchQueue.main.async { self.audioLevel = normalizedLevel }
    }
    // -----------------------------------------

    func speechRecognizer(_ sr: SFSpeechRecognizer, availabilityDidChange available: Bool) { /* ... error handling ... */ }
}

// MARK: — 4. ViewModel (Central State + VUI State Management)

// VUI State Definition
enum VUIState {
    case idle          // Not active
    case prompting     // Showing suggestions, ready to listen
    case listening     // Actively recording speech
    case acknowledging // Briefly showing what was heard before processing
    case processing    // Waiting for backend response
}

@MainActor
final class ChatStore: ObservableObject {
    // MARK: - Published Properties (UI + VUI State)
    @Published var conversations: [Conversation] = [] { didSet { saveToDisk() } }
    @Published var current: Conversation
    @Published var input: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // VUI State Properties
    @Published var vuiState: VUIState = .idle
    @Published var vuiTranscript: String = "" // Transcript shown in VUI overlay
    @Published var vuiErrorMessage: String?   // Error shown in VUI overlay

    // Suggested Prompts for VUI
    let suggestedPrompts = [
        "Kể một câu chuyện cười",
        "Dự báo thời tiết?",
        "Đặt báo thức lúc 7 giờ sáng"
    ]

    // Settings synced with UserDefaults (Unchanged)
    @AppStorage("system_prompt") var systemPrompt: String = "Bạn là một trợ lý AI hữu ích nói tiếng Việt."
    @AppStorage("tts_enabled") var ttsEnabled: Bool = false
    @AppStorage("tts_rate") var ttsRate: Double = 1.0
    @AppStorage("tts_voice_id") var ttsVoiceID: String = ""
    @AppStorage("openai_api_key") var apiKey: String = ""
    @AppStorage("backend_type") private var backendTypeRaw: String = BackendType.mock.rawValue
    @AppStorage("coreml_model_name") var coreMLModelName: String = "TinyChat"
    @AppStorage("openai_model_name") var openAIModelName: String = "gpt-4o"
    @AppStorage("openai_temperature") var openAITemperature: Double = 0.7
    @AppStorage("openai_max_tokens") var openAIMaxTokens: Int = 512

    // Available models / voices (Unchanged)
    let availableCoreMLModels = ["TinyChat", "LocalChat"]
    let availableOpenAIModels = ["gpt-4o", "gpt-4-turbo", "gpt-3.5-turbo"]
    let availableVoices: [AVSpeechSynthesisVoice]

    // MARK: - Private Properties (Unchanged)
    private(set) var backend: ChatBackend
    private let ttsSynth = AVSpeechSynthesizer()
    private var ttsDelegate: TTSSpeechDelegate?

    // MARK: - Computed Properties (Unchanged)
    var backendType: BackendType {
        get { BackendType(rawValue: backendTypeRaw) ?? .mock }
        set { backendTypeRaw = newValue.rawValue; configureBackend() }
    }

    // MARK: - Initialization (Mostly Unchanged, ensures VUI state starts idle)
    init() {
        self.availableVoices = AVSpeechSynthesisVoice.speechVoices().sorted { v1, v2 in /* ... */ return v1.name < v2.name } // Simplified sort
        self.backend = MockChatBackend()
        self.ttsDelegate = TTSSpeechDelegate()
        self.current = Conversation(id: UUID(), title: "", messages: []) // Placeholder

        // Phase 2
        self.ttsSynth.delegate = self.ttsDelegate
        let initialTTSVoiceID = self.ttsVoiceID
        if initialTTSVoiceID.isEmpty || self.availableVoices.first(where: { $0.identifier == initialTTSVoiceID }) == nil {
            self.ttsVoiceID = self.availableVoices.first(where: {$0.language.starts(with: "vi-VN")})?.identifier ?? self.availableVoices.first?.identifier ?? ""
        }
        let realInitialConversation = Conversation(messages: [.system(self.systemPrompt)])
        loadFromDisk()
        configureBackend() // Call configureBackend before assigning final 'current'
        if let mostRecent = conversations.first { self.current = mostRecent /* + consistency check */ }
        else { self.current = realInitialConversation }
        self.vuiState = .idle // Ensure VUI starts idle
    }

    // MARK: - Backend Management (Unchanged)
    func setBackend(_ newBackend: ChatBackend, type: BackendType) { /* ... */ }
    private func configureBackend() { /* ... */ }

    // MARK: - VUI Interaction Flow

    func startVUIInteraction() {
        guard vuiState == .idle else { return } // Only start if idle
        print("Starting VUI Interaction...")
        errorMessage = nil   // Clear main chat error
        vuiErrorMessage = nil // Clear VUI specific error
        vuiTranscript = ""    // Clear VUI transcript
        ttsSynth.stopSpeaking(at: .immediate) // Stop any ongoing TTS forcefully

        // Change state to present the VUI overlay
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
           vuiState = .prompting
        }
        // Note: SpeechRecognizer isn't started here yet. It starts when VUI enters listening state.
    }

    func startListeningInVUI() {
        guard vuiState == .prompting else { return }
        print("VUI transitioning to Listening...")
        vuiErrorMessage = nil // Clear any previous VUI error

        // Request auth if needed, then start recording
         // Assuming SpeechRecognizer instance is accessible (e.g., passed around or singleton)
          // We'll handle this connection in ChatDemoVUI_v2 view body
           // speech.requestAuthorization { [weak self] granted in
           //      DispatchQueue.main.async {
           //          if granted {
           //              do {
           //                   try self?.speech.startRecording() // MUST have access to SpeechRecognizer instance
           //                   withAnimation { self?.vuiState = .listening }
           //              } catch {
           //                  print("Error starting speech recognition in VUI: \(error)")
           //                  self?.vuiErrorMessage = "Không thể bắt đầu nghe: \(error.localizedDescription)"
           //                  self?.dismissVUI() // Go back to idle on error
           //              }
           //          } else {
           //               self?.vuiErrorMessage = "Cần cấp quyền để sử dụng giọng nói."
           //               // Optionally dismiss after a delay
           //               DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self?.dismissVUI() }
           //          }
            //    }
           }

    func stopListeningAndProcessVUI(recognizedText: String) {
        guard vuiState == .listening || vuiState == .acknowledging else { return } // Allow processing from acknowledge too
        print("VUI stopped listening. Recognized: '\(recognizedText)'")
        let trimmedText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.isEmpty {
            print("VUI: Empty transcript, returning to prompt.")
            // Provide feedback and return to prompting state
            vuiErrorMessage = "Không nghe thấy gì rõ ràng. Thử lại?"
             DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                 // Only reset if still in processing/ack state (user might have closed VUI)
                  if self?.vuiState == .acknowledging || self?.vuiState == .processing {
                      withAnimation { self?.vuiState = .prompting }
                  }
             }
            // Don't proceed to sendMessage
             return
        }

        // 1. Transition to Acknowledging (briefly show final text)
        withAnimation { vuiState = .acknowledging }

        // 2. After a short delay, transition to Processing and send message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
             guard let self = self else { return }
             // Ensure we are still in acknowledging state before processing
             // (user might have closed the VUI)
              if self.vuiState == .acknowledging {
                 withAnimation { self.vuiState = .processing }
                 self.sendMessage(trimmedText) // Send the final transcript
             }
         }
    }

     // Called when VUI backend call completes OR when manually closing VUI
    func dismissVUI() {
        if vuiState != .idle {
             print("Dismissing VUI (Current State: \(vuiState)).")
             withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                 vuiState = .idle
             }
                 isLoading = false // Ensure loading indicator is hidden
                 // If Speech Recognizer is running, stop it (handled in ChatDemoVUI_v2 .onChange(of: vuiState))
         }
    }

    // MARK: - Chat Actions (Modified sendMessage for VUI dismissal)

    func sendMessage(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // VUI: Check if started from VUI or text input
         let initiatedFromVUI = (vuiState == .processing)

        guard !trimmedText.isEmpty, !isLoading else {
             if initiatedFromVUI { dismissVUI() } // Dismiss if empty text somehow came from VUI
            return
        }

        stopSpeaking()

        // Only add user message if it came from text input directly
        if !initiatedFromVUI {
            let userMessage = Message.user(trimmedText)
            current.messages.append(userMessage)
        } else {
           // VUI already showed the user input, don't add duplicates to chat history directly
           // Instead, add it when response is received to show the VUI interaction pair
             print("VUI initiated send. User input '\(trimmedText)' not added to chat *yet*.")
         }

        let messagesForBackend = current.messages
        input = "" // Clear text input field regardless
        isLoading = true // Show loading indicator (in chat OR VUI)
        errorMessage = nil // Clear main chat error

        print("Sending messages (\(messagesForBackend.count)) to backend (\(backendType.rawValue)). VUI Initiated: \(initiatedFromVUI)")

        backend.streamChat(messages: messagesForBackend, systemPrompt: systemPrompt) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false // Hide loading indicator

                // VUI: Dismiss the overlay *after* getting the result
                 if initiatedFromVUI {
                     self.dismissVUI()
                 }

                switch result {
                case .success(let replyText):
                    print("Received reply: \(replyText.prefix(50))...")
                    let assistantMessage = Message.assistant(replyText)
                    // VUI: Add the user's VUI input + AI response together
                     if initiatedFromVUI && !trimmedText.isEmpty {
                         self.current.messages.append(Message.user(trimmedText)) // Add original VUI input now
                     }
                    if !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        self.current.messages.append(assistantMessage)
                         self.upsertConversation() // Save updated conversation
                    } else {
                        print("Received empty reply.")
                    }
                    if self.ttsEnabled && !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        self.speak(replyText)
                    }
                case .failure(let error):
                    print("Backend error: \(error.localizedDescription)")
                    self.errorMessage = "Lỗi Backend: \(error.localizedDescription)" // Show error in main chat
                }
            }
        }
    }

    func speak(_ text: String) { /* ... (Unchanged) ... */ }
    func stopSpeaking() { /* ... (Unchanged) ... */ }

    // MARK: - History Management (Unchanged)
    func deleteConversation(id: UUID) { /* ... */ }
    func selectConversation(_ conversation: Conversation) { /* ... */ }
    func renameConversation(_ conversation: Conversation, to newTitle: String) { /* ... */ }
    func clearHistory() { /* ... */ }

    // MARK: - Voice Command / VUI Speech Handling
    func attachRecognizer(_ sr: SpeechRecognizer) {
        // VUI: Update VUI transcript during listening
        sr.$transcript.sink { [weak self] newTranscript in
            guard self?.vuiState == .listening else { return }
            DispatchQueue.main.async { // Ensure updates on main thread
                 self?.vuiTranscript = newTranscript
            }
        }.store(in: &cancellables) // Need to manage cancellables

        // VUI: Handle final transcription from VUI
        sr.onFinalTranscription = { [weak self] text in
             self?.stopListeningAndProcessVUI(recognizedText: text)
        }

         // VUI: Handle errors reported by recognizer during VUI session
         sr.onErrorOccurred = { [weak self] errorMsg in
             self?.vuiErrorMessage = errorMsg
             // Optionally dismiss VUI after showing error
             DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                 self?.dismissVUI()
             }
         }
    }
    private var cancellables = Set<AnyCancellable>() // For Sink

    // MARK: - Persistence (Unchanged)
    private func loadFromDisk() { /* ... */ }
    private func saveToDisk() { /* ... */ }
    func upsertConversation() { /* ... */ }

} // End ChatStore

// MARK: - 4.1 TTS Delegate (Unchanged)
class TTSSpeechDelegate: NSObject, AVSpeechSynthesizerDelegate { /* ... */ }

// MARK: — 5. UI Subviews (MessageBubble Unchanged)

struct MessageBubble: View {
    let message: Message; let onRespeak: (String) -> Void; var isUser: Bool { message.role == .user }
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 40) }
            if message.role == .assistant { Image(systemName: "sparkles").font(.caption).foregroundColor(.purple).padding(.bottom, 5) }
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content).textSelection(.enabled).padding(.horizontal, 12).padding(.vertical, 8)
                    .background(isUser ? Color.blue.opacity(0.9) : Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundColor(isUser ? .white : .primary).frame(minWidth: 20).fixedSize(horizontal: false, vertical: true)
                Text(message.timestamp, style: .time).font(.caption2).foregroundColor(.secondary)
            }
            if message.role == .user { Image(systemName: "person.crop.circle").font(.caption).foregroundColor(.blue).padding(.bottom, 5) }
            if !isUser { Spacer(minLength: 40) }
        }
        .contextMenu {
            Button { UIPasteboard.general.string = message.content } label: { Label("Copy Text", systemImage: "doc.on.doc") }
            if message.role == .assistant && !message.content.isEmpty { Button { onRespeak(message.content) } label: { Label("Đọc Lại", systemImage: "speaker.wave.2.fill") } }
            if !message.content.isEmpty { ShareLink(item: message.content) { Label("Chia sẻ", systemImage: "square.and.arrow.up") } }
        }
        .padding(.vertical, 2)
    }
}

// MARK: Chat Input Bar (MODIFIED Mic Button Action)
struct ChatInputBar: View {
    @Binding var text: String
    @ObservedObject var store: ChatStore
    @ObservedObject var speech: SpeechRecognizer // Keep reference for VUI trigger
    @FocusState var isFocused: Bool

    var body: some View {
         VStack(spacing: 0) {
             // --- Optional: Speech Status (Only show ERROR from recognizer now) ---
              if speech.errorMessage != nil {
                  HStack {
                      Text(speech.errorMessage!) // Only show if there's an error
                          .font(.caption).foregroundColor(.red).lineLimit(1)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal).padding(.bottom, 4)
                   }
                   .transition(.opacity)
                }

             HStack(spacing: 8) {
                 TextField("Type message...", text: $text, axis: .vertical)
                     .focused($isFocused).lineLimit(1...4).padding(8)
                     .background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                     .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isFocused ? Color.blue.opacity(0.5) : Color.gray.opacity(0.3)))
                     .disabled(store.isLoading || store.vuiState != .idle) // Disable if VUI active

                 // -- Mic Button (MODIFIED Action) ---
                 micButton

                 // -- Send Button ---
                 sendButton
             }
             .padding(.horizontal).padding(.vertical, 6)
             .background(.thinMaterial)
         }
         .onChange(of: speech.errorMessage) { _, newValue in // Error auto-clear
              if newValue != nil {
                  DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { if speech.errorMessage == newValue { speech.errorMessage = nil } }
              }
          }
    }

    // MARK: Mic Button (Action modified for VUI)
    private var micButton: some View {
        Button {
            isFocused = false // Dismiss keyboard
            store.startVUIInteraction() // Trigger the VUI overlay
        } label: {
            Image(systemName: "mic.circle.fill") // Use filled icon to indicate action
                 .resizable().scaledToFit().frame(width: 28, height: 28)
                 .foregroundColor(.blue)
        }
        .disabled(store.isLoading || store.vuiState != .idle) // Disable while loading OR VUI active
        .accessibilityLabel("Start Voice Input")
    }

    // Send Button View (State slightly changed)
    private var sendButton: some View {
        Button {
             let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
             if !trimmedText.isEmpty && !store.isLoading && store.vuiState == .idle { // Ensure VUI is idle
                 store.sendMessage(trimmedText)
                 text = ""
             }
        } label: {
             Image(systemName: "arrow.up.circle.fill")
                 .resizable().scaledToFit().frame(width: 28, height: 28)
                 .foregroundColor(
                     text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isLoading || store.vuiState != .idle
                     ? .gray.opacity(0.5) : .blue
                 )
        }
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isLoading || store.vuiState != .idle) // Disable if VUI active
        .transition(.opacity.combined(with: .scale))
        .accessibilityLabel("Gửi tin nhắn")
    }
}

// MARK: Settings and History Sheets (Unchanged - Use Previous Code)
struct SettingsSheet: View {
    @ObservedObject var store: ChatStore
    @State private var localApiKey: String; @State private var localOpenAIModelName: String; @State private var localOpenAITemperature: Double; @State private var localOpenAIMaxTokens: Int; @State private var localBackendType: BackendType; @State private var localCoreMLModelName: String; @State private var localSystemPrompt: String; @State private var localTtsEnabled: Bool; @State private var localTtsRate: Float; @State private var localTtsVoiceID: String
    @Environment(\.dismiss) var dismiss
    var onUpdate: (ChatBackend, BackendType) -> Void // Keep signature, may be less used

    init(store: ChatStore, onUpdate: @escaping (ChatBackend, BackendType) -> Void) {
        self.store = store; self.onUpdate = onUpdate;
        _localApiKey = State(initialValue: store.apiKey); _localOpenAIModelName = State(initialValue: store.openAIModelName); _localOpenAITemperature = State(initialValue: store.openAITemperature); _localOpenAIMaxTokens = State(initialValue: store.openAIMaxTokens); _localBackendType = State(initialValue: store.backendType); _localCoreMLModelName = State(initialValue: store.coreMLModelName); _localSystemPrompt = State(initialValue: store.systemPrompt); _localTtsEnabled = State(initialValue: store.ttsEnabled); _localTtsRate = State(initialValue: Float(store.ttsRate)); _localTtsVoiceID = State(initialValue: store.ttsVoiceID)
    }

    var body: some View { NavigationStack { Form { /* ... Sections as before ... */ } .navigationTitle("Cài đặt Chat").navigationBarTitleDisplayMode(.inline).toolbar { /* ... Buttons ... */ } } }
    private func applyChanges() { /* ... Previous logic to update store ... */ }
}

struct HistorySheet: View {
    @Binding var conversations: [Conversation]; let onDelete: (UUID) -> Void; let onSelect: (Conversation) -> Void; let onRename: (Conversation, String) -> Void; let onClear: () -> Void;
    @Environment(\.dismiss) var dismiss; @State private var showingRenameAlert=false; @State private var conversationToRename: Conversation?=nil; @State private var newConversationTitle=""; @State private var showingClearConfirm=false;
    var body: some View { NavigationStack { VStack { if conversations.isEmpty { ContentUnavailableView(/* ... */).padding()} else { List { ForEach(conversations) { convo in historyRow(for: convo).contentShape(Rectangle()).onTapGesture { onSelect(convo); dismiss() } }.onDelete(perform: deleteItems) }.listStyle(.plain) }; if !conversations.isEmpty { Button(/* Clear */){showingClearConfirm=true}.padding()} }.navigationTitle("Lịch sử Chat").navigationBarTitleDisplayMode(.inline).toolbar { /* ... Buttons ... */ }.alert("Đổi tên", isPresented: $showingRenameAlert, presenting: conversationToRename){c in TextField("New",text:$newConversationTitle).onAppear{newConversationTitle=c.title}; Button("OK"){if !newConversationTitle.trimmingCharacters(in:.whitespaces).isEmpty{onRename(c,newConversationTitle)}}; Button("Hủy",role:.cancel){}} message:{c in Text("Enter name for \"\(c.title)\"")}.alert("Xác nhận Xóa?", isPresented: $showingClearConfirm) { Button("Xóa", role: .destructive){onClear();dismiss()}; Button("Hủy",role:.cancel){} } message: {Text("Are you sure?")} } .presentationDetents([.medium, .large]) }
    private func historyRow(for c: Conversation) -> some View { HStack { VStack(alignment: .leading){ Text(c.title).font(.headline).lineLimit(1); Text("\(c.messages.filter{$0.role != .system}.count) msgs - \(c.createdAt, style: .date)").font(.caption).foregroundColor(.secondary) }; Spacer(); Menu { Button{conversationToRename=c;showingRenameAlert=true} label:{Label("Đổi",systemImage:"pencil")}; ShareLink(item: formatConversationForSharing(c)) {Label("Share", systemImage: "square.and.arrow.up")}; Button(role:.destructive){onDelete(c.id)} label:{Label("Xóa",systemImage:"trash")} } label: { Image(systemName: "ellipsis.circle").foregroundColor(.gray).padding(.leading, 5).imageScale(.large) }.buttonStyle(.borderless).menuIndicator(.hidden) }.padding(.vertical, 4) }
    private func deleteItems(at offsets: IndexSet) { offsets.map { conversations[$0].id }.forEach(onDelete) }
    private func formatConversationForSharing(_ c: Conversation) -> String { /* ... */ return "Chat: \(c.title)..." }
}

// MARK: — 5.1 VUI Subviews (NEW)

// Close Button for VUI Overlay
struct VUICloseButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(.white, Color.black.opacity(0.3)) // White with subtle shadow/background
                .padding()
        }
        .accessibilityLabel("Close Voice Input")
    }
}

// Suggested Prompts View
struct SuggestedPromptsView: View {
    let prompts: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(prompts, id: \.self) { prompt in
                Button { onSelect(prompt) } label: {
                    Text(prompt)
                         .font(.system(size: 16, weight: .medium)) // Slightly smaller font
                         .foregroundColor(.white) // White text
                         .frame(maxWidth: .infinity)
                         .padding(.vertical, 14) // Make buttons taller
                         .padding(.horizontal, 10)
                         .background(Color.white.opacity(0.15)) // Subtle white background
                         .clipShape(RoundedRectangle(cornerRadius: 12)) // Slightly less rounded
                         .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.4), lineWidth: 1)) // Subtle border
                }
            }
        }
         .padding(.horizontal, 40) // More horizontal padding
    }
}

// Simple Audio Visualizer View
struct AudioVisualizerView: View {
    @ObservedObject var speech: SpeechRecognizer // Get audio level
    let barCount: Int = 5 // Number of visualizer bars

    var body: some View {
         // Animate level changes for smoothness
        let animatedLevel = speech.isRecording ? CGFloat(speech.audioLevel) : 0.0

        HStack(spacing: 6) {
            ForEach(0..<barCount, id: \.self) { index in
                // Vary bar heights slightly randomly based on level for a more dynamic look
                let randomFactor = CGFloat.random(in: 0.7...1.0) // Add randomness
                // Make bars react more significantly to low levels, taper off at high levels
                let calculatedHeight = calculateBarHeight(level: animatedLevel, index: index) * randomFactor

                RoundedRectangle(cornerRadius: 3) // Use rounded rectangles
                    .fill(speech.isRecording ? Color.white.opacity(0.8) : Color.white.opacity(0.3)) // White bars, less opaque when idle
                    .frame(width: 6, height: max(6, calculatedHeight)) // Ensure minimum height
            }
        }
        .frame(height: 60) // Fixed height for the visualizer area
        .animation(.easeOut(duration: 0.15), value: animatedLevel) // Animate height changes
         .opacity(speech.isRecording || speech.audioLevel > 0.01 ? 1.0 : 0.5) // Fade out when truly idle
         .blur(radius: speech.isRecording ? 0 : 0.5) // Slightly blur when inactive
    }

    // Function to calculate bar height with some variation
    private func calculateBarHeight(level: CGFloat, index: Int) -> CGFloat {
        let maxBarHeight: CGFloat = 55.0
        let midIndex = CGFloat(barCount / 2)
        // Bars closer to the center are generally taller
        let closenessToCenter = 1.0 - abs(CGFloat(index) - midIndex) / (midIndex + 0.5) // Normalize 0..1
        // Apply power curve to level to make bars react more at lower volumes
        let sensitivity: CGFloat = 1.8
        let scaledLevel = pow(level, sensitivity)
        // Combine level, center bias, and add a base height
        return max(6, (scaledLevel * maxBarHeight * closenessToCenter * 0.8) + (maxBarHeight * 0.2)) // Add base height + scaled part
    }
}

// MARK: — 5.2 Takeover VUI Overlay (NEW)

struct TakeoverVUIView: View {
    @ObservedObject var store: ChatStore
    @ObservedObject var speech: SpeechRecognizer

    @State private var showAcknowledgedText = false // State for acknowledge transition

    var body: some View {
        ZStack {
            // 1. Background
            Color.blue.opacity(0.95) // Slightly transparent blue
                .ignoresSafeArea()
                .onTapGesture { // Allow tapping background to cancel (except when processing)
                    if store.vuiState == .prompting || store.vuiState == .listening || store.vuiState == .acknowledging {
                         print("VUI Background tapped, dismissing.")
                         store.dismissVUI()
                         speech.stopRecording() // Explicitly stop speech if tapped out
                    }
                }

            // 2. Content based on State
            VStack {
                Spacer() // Push content towards center/bottom

                switch store.vuiState {
                case .prompting:
                    promptingContent
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))

                case .listening:
                    listeningContent
                         .transition(.opacity) // Subtle transition

                case .acknowledging:
                     acknowledgingContent
                         .transition(.opacity)

                case .processing:
                    processingContent
                        .transition(.opacity)

                case .idle:
                    EmptyView() // Should not be visible
                }

                // Show VUI-specific error message if present
                if let vuiError = store.vuiErrorMessage {
                     Text(vuiError)
                         .font(.caption)
                         .foregroundColor(.white.opacity(0.8))
                         .padding(.top, 10)
                         .padding(.horizontal, 30)
                         .multilineTextAlignment(.center)
                         .transition(.opacity)
                 }

                Spacer() // Push visualizer to bottom

                // 3. Audio Visualizer
                AudioVisualizerView(speech: speech)
                    .padding(.bottom, 30) // Position above bottom safe area
            }
            .padding(.vertical, 20) // Overall vertical padding

            // 4. Close Button (Always visible on top right)
            VStack {
                HStack {
                    Spacer()
                    VUICloseButton {
                        print("Close button tapped.")
                         store.dismissVUI()
                         speech.stopRecording() // Ensure speech stops on close
                    }
                }
                Spacer() // Push button to top
            }
            .padding(.top, 10) // Adjust top padding for status bar

        }
        .onChange(of: store.vuiState) { _, newState in
             // Automatically start listening when prompting state is entered
             if newState == .prompting {
                 // Slight delay to allow UI to appear before starting mic
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                      // Check if still in prompting state before starting
                      if store.vuiState == .prompting {
                           requestAndStartListening()
                      }
                  }
             }
             // Reset acknowledge state flag when leaving acknowledge state
             if newState != .acknowledging {
                  showAcknowledgedText = false
              }
              // Automatically transition from acknowledge to process is handled in stopListeningAndProcessVUI
         }
         .onAppear {
             // If view appears and state is prompting, try starting mic immediately
              if store.vuiState == .prompting {
                  requestAndStartListening()
              }
          }
    } // End body

    // MARK: - VUI State Content Views

    private var promptingContent: some View {
        VStack(spacing: 25) {
            Text("Xin hãy nói gì đó,\nHoặc thử một trong những câu này:")
                .font(.title3) // Slightly larger font
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            SuggestedPromptsView(prompts: store.suggestedPrompts) { selectedPrompt in
                print("Suggested prompt selected: \(selectedPrompt)")
                 speech.stopRecording() // Stop listening if active
                 store.vuiTranscript = selectedPrompt // Show selection briefly
                 store.stopListeningAndProcessVUI(recognizedText: selectedPrompt)
            }
        }
    }

    private var listeningContent: some View {
         // Make text larger while listening
        Text(store.vuiTranscript.isEmpty ? "Đang nghe..." : store.vuiTranscript)
            .font(.system(size: 34, weight: .semibold)) // Larger, bolder font
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .frame(minHeight: 100) // Ensure space even when empty
             .scaleEffect(store.vuiTranscript.isEmpty ? 0.95 : 1.0) // Subtle scale effect
             .opacity(store.vuiTranscript.isEmpty ? 0.7 : 1.0) // Fade prompt text
             .animation(.easeInOut, value: store.vuiTranscript.isEmpty)
    }

    private var acknowledgingContent: some View {
        // Show the final transcript more subtly before processing
        Text(store.vuiTranscript)
            .font(.system(size: 28, weight: .medium)) // Slightly smaller than listening
            .foregroundColor(.white.opacity(showAcknowledgedText ? 0.9 : 0.0)) // Control opacity with state
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .frame(minHeight: 100)
             .onAppear {
                 // Trigger fade-in animation shortly after entering state
                 withAnimation(.easeIn(duration: 0.4)) {
                      showAcknowledgedText = true
                  }
             }
    }

    private var processingContent: some View {
         VStack(spacing: 15) {
             ProgressView() // Standard spinner
                 .scaleEffect(1.5) // Make it larger
                 .tint(.white)
             Text("Để tôi xem...") // Processing text
                 .font(.title3)
                 .fontWeight(.medium)
                 .foregroundColor(.white.opacity(0.9))
         }
    }

    // MARK: - Helper Methods
    private func requestAndStartListening() {
        print("VUI: Requesting auth and starting to listen...")
        vuiErrorMessage = nil
        speech.requestAuthorization { [weak self] granted in
            DispatchQueue.main.async {
                 guard let self = self else { return }
                 // Check if still prompting, VUI might have been closed
                  guard self.store.vuiState == .prompting else {
                      print("VUI: State changed before authorization completed. Aborting listen start.")
                      return
                  }

                if granted {
                    do {
                         try self.speech.startRecording()
                         print("VUI: Speech recording started successfully.")
                         // Transition state only AFTER successfully starting recording
                         withAnimation { self.store.vuiState = .listening }
                    } catch {
                        print("VUI Error starting speech recognition: \(error)")
                        self.store.vuiErrorMessage = "Không thể bắt đầu nghe: \(error.localizedDescription)"
                         // Go back to idle on error
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.store.dismissVUI() }
                    }
                } else {
                    print("VUI: Speech permission denied.")
                    self.store.vuiErrorMessage = "Cần cấp quyền để sử dụng giọng nói."
                    // Dismiss after a delay to show message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { self.store.dismissVUI() }
                }
            }
        }
    }

} // End TakeoverVUIView

// MARK: — 6. Main View (Modified for VUI Overlay)

struct ChatDemoVUI_v2: View {
    @StateObject var store = ChatStore()
    @StateObject var speech = SpeechRecognizer() // Speech Recognizer owned here

    @FocusState var isInputFocused: Bool

    @State private var showSettingsSheet = false
    @State private var showHistorySheet = false

    var body: some View {
        ZStack { // Use ZStack to layer VUI on top
            NavigationStack {
                VStack(spacing: 0) {
                    chatHeader
                    messagesScrollView
                    ChatInputBar( // Pass the VUI state and speech recognizer
                        text: $store.input,
                        store: store,
                        speech: speech,
                        isFocused: _isInputFocused
                    )
                }
                .navigationBarHidden(true)
                // VUI: Blur background when VUI is active
                 .blur(radius: store.vuiState != .idle ? 10 : 0)
                 .disabled(store.vuiState != .idle) // Disable interaction behind VUI
            }
            // VUI: Settings/History sheets presentation moved outside ZStack's main content
            //      to ensure they appear *over* the blur/disabled state.

            // VUI: Conditionally show the Takeover Overlay
            if store.vuiState != .idle {
                TakeoverVUIView(store: store, speech: speech)
                     .zIndex(10) // Ensure VUI is on top
                     .transition(.opacity.combined(with: .scale(scale: 0.9))) // VUI appearance animation
            }
        }
        // .sheet presentations remain at the top level
        .sheet(isPresented: $showSettingsSheet) { SettingsSheet(store: store) { _, _ in } }
        .sheet(isPresented: $showHistorySheet) { HistorySheet(conversations: $store.conversations, onDelete: store.deleteConversation, onSelect: store.selectConversation, onRename: store.renameConversation, onClear: store.clearHistory) }
        // Main chat error alert remains at top level
        .alert("Lỗi", isPresented: .constant(store.errorMessage != nil), actions: { Button("OK") { store.errorMessage = nil } }, message: { Text(store.errorMessage ?? "Lỗi Không Xác Định.") })
        .onAppear {
            store.attachRecognizer(speech) // Connect store and speech recognizer logic
            // Don't request global auth here, VUI requests it when needed
        }
        // Tapping outside input bar to dismiss keyboard (only if VUI is idle)
        .onTapGesture { if store.vuiState == .idle { isInputFocused = false } }
        .preferredColorScheme(nil) // Respect system appearance
         // VUI: Explicitly stop speech recognizer if VUI state becomes idle unexpectedly
         .onChange(of: store.vuiState) { _, newState in
              if newState == .idle && speech.isRecording {
                  print("VUI became idle, ensuring speech recognizer stops.")
                  speech.stopRecording()
              }
          }
    }

    // Custom Header View Component (Unchanged)
    private var chatHeader: some View {
        HStack(spacing: 10) {
             Text(store.current.title).font(.headline).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
             Spacer()
             if store.ttsEnabled { Image(systemName: "speaker.wave.2.fill").foregroundColor(.blue).imageScale(.medium).transition(.scale.combined(with: .opacity)).accessibilityLabel("TTS bật") }
             else { Image(systemName: "speaker.slash.fill").foregroundColor(.gray).imageScale(.medium).transition(.scale.combined(with: .opacity)).accessibilityLabel("TTS tắt") }
             Button { showHistorySheet = true } label: { Label("History", systemImage: "clock.arrow.circlepath") }.labelStyle(.iconOnly)
             Button { showSettingsSheet = true } label: { Label("Settings", systemImage: "gearshape.fill") }.labelStyle(.iconOnly)
             Button { store.resetChat() } label: { Label("New", systemImage: "plus.circle.fill") }.labelStyle(.iconOnly)
         }
         .padding(.horizontal).padding(.vertical, 10)
         .background(.thinMaterial)
         .animation(.default, value: store.ttsEnabled)
    }

    // Scrollable View for Messages (Unchanged)
    private var messagesScrollView: some View {
         ScrollViewReader { proxy in
             ScrollView {
                 LazyVStack(spacing: 16) {
                     ForEach(store.current.messages.filter { $0.role != .system }) { message in
                         MessageBubble(message: message, onRespeak: store.speak).id(message.id)
                     }
                     Color.clear.frame(height: 10).id("bottomPadding")
                     if store.isLoading { HStack(spacing:8){ProgressView().tint(.secondary);Text("AI thinking...").font(.caption).foregroundColor(.secondary)}.padding(.vertical).id("loadingIndicator").transition(.opacity) }
                 } .padding(.vertical).padding(.horizontal, 12)
             }
             .background(Color(.systemGroupedBackground))
             .scrollDismissesKeyboard(.interactively)
             .onChange(of: store.current.messages.last?.id) { _, newId in scrollToBottom(proxy: proxy, anchor: .bottom) }
             .onChange(of: store.isLoading) { _, isLoading in if isLoading { DispatchQueue.main.asyncAfter(deadline:.now()+0.1) {withAnimation{proxy.scrollTo("loadingIndicator", anchor:.bottom)}} } }
             .onAppear { scrollToBottom(proxy: proxy, anchor: .bottom, animated: false) }
             .onChange(of: store.current.id) { _, _ in scrollToBottom(proxy: proxy, anchor: .bottom, animated: false) }
         }
    }

    // Helper function for scrolling (Unchanged)
    private func scrollToBottom(proxy: ScrollViewProxy, anchor: UnitPoint?, animated: Bool = true) { /* ... */ }
}

// MARK: — 7. Helper Extensions (Unchanged)
extension UIApplication { static var topViewController: UIViewController? { /* ... */ return nil } } // Placeholder
extension UIActivityViewController { static func present(text: String) { /* ... */ } } // Placeholder

// MARK: — 8. Preview Provider
//
//#Preview("Chat View") {
//    // Simulate VUI being idle for preview
//    let previewStore = ChatStore()
//    previewStore.vuiState = .idle
//    previewStore.current = Conversation(messages: [
//        .system("Preview System Prompt"),
//        .user("Hello there!"),
//        .assistant("Hi! How can I help you today?")
//    ])
//
//    ChatDemoVUI_v2(store: previewStore, speech: SpeechRecognizer())
//         .preferredColorScheme(.light)
//}
//
//#Preview("VUI Overlay - Prompting") {
//    let previewStore = ChatStore()
//    previewStore.vuiState = .prompting
//    TakeoverVUIView(store: previewStore, speech: SpeechRecognizer())
//        .background(Color.gray) // Show background for context
//        .preferredColorScheme(.dark)
//}
//
//#Preview("VUI Overlay - Listening") {
//    let previewStore = ChatStore()
//    let previewSpeech = SpeechRecognizer()
//    previewStore.vuiState = .listening
//    previewStore.vuiTranscript = "What's the weather like tomorrow?"
//    previewSpeech.isRecording = true // Simulate recording state
//    previewSpeech.audioLevel = 0.6    // Simulate audio level
//    TakeoverVUIView(store: previewStore, speech: previewSpeech)
//        .background(Color.gray)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("VUI Overlay - Acknowledging") {
//    let previewStore = ChatStore()
//    previewStore.vuiState = .acknowledging
//    previewStore.vuiTranscript = "Set timer for 5 minutes"
//    TakeoverVUIView(store: previewStore, speech: SpeechRecognizer())
//        .background(Color.gray)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("VUI Overlay - Processing") {
//    let previewStore = ChatStore()
//    previewStore.vuiState = .processing
//    TakeoverVUIView(store: previewStore, speech: SpeechRecognizer())
//        .background(Color.gray)
//        .preferredColorScheme(.dark)
//}
