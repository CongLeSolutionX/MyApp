////
////  ChatView_V8.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//import AVFoundation
//
//// MARK: - Constants & Configuration (IMPORTANT)
//private let OPENAI_API_KEY = "sk-proj-" // <--- PASTE YOUR **REAL** API KEY HERE (VERY INSECURE - FOR DEMO ONLY)
//private let SESSION_URL = URL(string: "https://api.openai.com/v1/realtime/sessions")!
//private let DESIRED_AUDIO_FORMAT = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: true)! // Match common API expectation
//
//// MARK: - Codable Structs for API Interaction
//
//// --- Session Creation ---
//struct CreateSessionRequest: Codable {
//    let model: String = "gpt-4o-realtime-preview"
//    let modalities: [String] = ["audio", "text"] // Both needed
//    // Add other parameters like instructions, voice, tools etc. if needed
//    // let instructions: String = "You are a helpful assistant."
//}
//
//struct CreateSessionResponse: Codable, Identifiable {
//    let id: String // Session ID (e.g., "sess_abc123")
//    let object: String
//    let model: String
//    let modalities: [String]
//    // **ASSUMPTION:** WebSocket URL might be provided separately or derived.
//    // Let's assume a field `websocket_url` exists for this example.
//    // If not, this structure and connection logic needs updating based on actual API response.
//    let websocket_url: String? // Placeholder - Adjust based on actual API spec!
//    let client_secret: ClientSecret? // Assuming structure from earlier docs
//
//    struct ClientSecret: Codable {
//        let value: String
//        let expires_at: Int // Unix timestamp
//    }
//}
//
//// --- WebSocket Messages ---
//
//// Base structure for messages sent TO OpenAI
//struct UplinkMessage: Codable {
//    let type: String // e.g., "text", "audio"
//    // Include other fields based on type below
//}
//
//struct UplinkTextMessage: Codable {
//    let type: String = "text"
//    let text: String
//}
//
//// Structure for sending audio TO OpenAI (Base64 Encoding is Common)
//struct UplinkAudioMessage: Codable {
//    let type: String = "audio" // Or maybe "audio_chunk" - check API spec
//    let data: String // Base64 encoded audio data string
//    let sequence_id: Int? // Optional: Might be needed for ordering chunks
//}
//
//// Base structure for messages received FROM OpenAI
//// Use tagged enum for easier decoding? Or decode based on 'type' field.
//struct DownlinkMessageBase: Decodable {
//    let type: String
//}
//
//// Example concrete downlink message types (Adjust based on actual API spec)
//struct DownlinkTranscriptMessage: Decodable {
//    let type: String // "transcript"
//    let text: String
//    let is_final: Bool
//    let sequence_id: Int?
//}
//
//struct DownlinkAITextMessage: Decodable {
//    let type: String // "ai_text"
//    let text: String
//    let is_final: Bool
//    let sequence_id: Int?
//}
//
//struct DownlinkAIAudioMessage: Decodable {
//    let type: String // "ai_audio"
//    let audio_data: String // Base64 encoded audio data string
//    let is_final: Bool
//    let sequence_id: Int?
//}
//
//struct DownlinkErrorMessage: Decodable {
//    let type: String // "error"
//    let message: String
//    let code: Int?
//}
//
//// Add other message types as needed (e.g., session_status, keep_alive)
//
//// MARK: - Data Models for UI State
//
//struct ConversationTurn: Identifiable {
//    let id = UUID()
//    var userMessage: MessageContent?
//    var aiResponse: MessageContent?
//    var timestamp: Date = Date()
//}
//
//@MainActor // Ensure UI updates happen on main thread
//class MessageContent: Identifiable, ObservableObject {
//    let id = UUID()
//    @Published var text: String = ""
//    @Published var audioData: Data? = nil
//    @Published var isFinal: Bool = false
//    @Published var sourceModel: String? = "gpt-4o-realtime-preview"
//    @Published var error: String? = nil
//    let isUser: Bool
//    @Published var isStreaming: Bool = false // True while text/audio is actively arriving
//
//    // Initializer
//    init(id: UUID = UUID(), text: String = "", audioData: Data? = nil, isFinal: Bool = false, sourceModel: String? = "gpt-4o-realtime-preview", error: String? = nil, isUser: Bool, isStreaming: Bool = false) {
//        self.id = id
//        self.text = text
//        self.audioData = audioData
//        self.isFinal = isFinal
//        self.sourceModel = sourceModel
//        self.error = error
//        self.isUser = isUser
//        self.isStreaming = isStreaming
//    }
//
//    // Computed property for UI bubble checks
//    var isAudio: Bool { audioData != nil && !audioData!.isEmpty }
//}
//
//// MARK: - Audio Service (Actor for thread safety)
//
//actor AudioService {
//    private var audioEngine: AVAudioEngine?
//    private var inputNode: AVAudioInputNode?
//    private var audioPlayerNode: AVAudioPlayerNode?
//    private var audioSession: AVAudioSession?
//
//    // Callback for processing buffer data and levels
//    var onBufferProcessed: ((Data, Float) -> Void)? // Data chunk, RMS level
//    var onPlaybackFinished: (() -> Void)?
//
//    var isRecording = false
//    var isPlaying = false
//
//    init() {
//        print("AudioService initialized")
//    }
//
//    private func setupAudioSession() throws {
//        guard audioSession == nil else { return } // Setup only once
//        audioSession = AVAudioSession.sharedInstance()
//        try audioSession?.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
//        try audioSession?.setPreferredSampleRate(DESIRED_AUDIO_FORMAT.sampleRate) // Request desired rate
//        try audioSession?.setActive(true)
//        print("Audio session setup successfully.")
//    }
//
//    private func setupEngine() throws {
//        guard audioEngine == nil else { return } // Setup only once
//        audioEngine = AVAudioEngine()
//        inputNode = audioEngine?.inputNode
//        audioPlayerNode = AVAudioPlayerNode()
//
//        guard let engine = audioEngine, let player = audioPlayerNode else {
//            throw AudioError.initializationFailed("Engine or Player Node is nil")
//        }
//
//        engine.attach(player)
//
//        // Connect player to main mixer -> output
//        let mainMixer = engine.mainMixerNode
//        engine.connect(player, to: mainMixer, format: DESIRED_AUDIO_FORMAT) // Use desired format for playback connection
//
//        try engine.start()
//        print("Audio engine started.")
//    }
//
//    func startRecording() throws {
//        guard !isRecording else { return }
//        try setupAudioSession()
//        try setupEngine()
//        guard let engine = audioEngine, let input = inputNode else {
//            throw AudioError.notInitialized
//        }
//        guard onBufferProcessed != nil else {
//             throw AudioError.invalidState("onBufferProcessed callback not set")
//        }
//
//        let inputFormat = input.outputFormat(forBus: 0)
//        // Ensure input format matches desired format for simplicity, or use converter
//        guard inputFormat.sampleRate == DESIRED_AUDIO_FORMAT.sampleRate,
//              inputFormat.channelCount == DESIRED_AUDIO_FORMAT.channelCount,
//              inputFormat.commonFormat == DESIRED_AUDIO_FORMAT.commonFormat else {
//                print("Warning: Mic input format (\(inputFormat)) differs from desired format (\(DESIRED_AUDIO_FORMAT)). Conversion might be needed.")
//                // Here you'd potentially insert an AVAudioConverter if formats don't match
//                // This example proceeds assuming they match or are close enough
//                throw AudioError.formatMismatch("Input format does not match desired PCM16 format")
//            }
//
//        input.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] (buffer, time) in
//            guard let self = self, self.isRecording else { return }
//
//            // Calculate RMS level (simple volume indicator)
//            var rms: Float = 0.0
//            if let channelData = buffer.floatChannelData?[0] {
//                let channelDataValue = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
//                let sumOfSquares = channelDataValue.map { $0 * $0 }.reduce(0, +)
//                rms = sqrt(sumOfSquares / Float(buffer.frameLength))
//            }
//             
//            // --- Convert buffer to Data ---
//            // Ensure we get data in the desired PCM16 format
//            guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: DESIRED_AUDIO_FORMAT, frameCapacity: buffer.frameCapacity), let bufferData = buffer.audioBufferList.pointee.mBuffers.mData else {
//                 print("AudioService: Failed to create or access buffer data")
//                return
//            }
//
//            // This assumes the input tap format IS pcmFormatInt16. If not, conversion is required BEFORE this.
//            // Copy data into the correctly formatted buffer (Crude, improve with format check/conversion)
//            pcmBuffer.frameLength = buffer.frameLength
//            if let pcmInt16ChannelData = pcmBuffer.int16ChannelData?[0], let inputFloatChannelData = buffer.floatChannelData?[0] {
//                 // VERY Basic Float32 to Int16 conversion (Not production quality!)
//                 for i in 0..<Int(buffer.frameLength) {
//                     pcmInt16ChannelData[i] = Int16(max(Float(Int16.min), min(Float(Int16.max), inputFloatChannelData[i] * Float(Int16.max))))
//                 }
//                 
//                 let byteCapacity = Int(pcmBuffer.frameLength) * Int(pcmBuffer.format.streamDescription.pointee.mBytesPerFrame)
//                  let data = Data(bytes: pcmBuffer.audioBufferList.pointee.mBuffers.mData!, count: byteCapacity)
//
//                 // Send data and level back
//                 self.onBufferProcessed?(data, rms)
//            } else {
//                 print("AudioService: Could not get channel data for conversion/copy.")
//            }
//        }
//
//        isRecording = true
//        print("AudioService: Recording started.")
//    }
//
//    func stopRecording() {
//        guard isRecording else { return }
//        inputNode?.removeTap(onBus: 0)
//        // Don't stop the engine usually, just the tap
//        // audioEngine?.pause() // Can pause if needed
//        isRecording = false
//        print("AudioService: Recording stopped.")
//        // Reset level potentially here? Maybe just stop sending updates
//    }
//
//    func playAudioChunk(data: Data) throws {
//        guard !data.isEmpty else { return }
//        try setupAudioSession() // Ensure session is active
//        try setupEngine() // Ensure engine is running
//        guard let engine = audioEngine, let player = audioPlayerNode else {
//            throw AudioError.notInitialized
//        }
//        guard let buffer = data.makePCMBuffer(format: DESIRED_AUDIO_FORMAT) else {
//            print("Failed to create buffer from data chunk")
//            throw AudioError.bufferCreationFailed
//        }
//        
//        player.scheduleBuffer(buffer) { [weak self] in
//             // Called when buffer finishes playing
//             DispatchQueue.main.async { // Ensure UI updates on main thread if needed
//                 // Check if queue is empty - this indicates actual end of playback sequence
//                 // This basic check might not be robust enough for rapid chunks
//                 // print("Audio chunk finished playing.")
//                 // If more sophisticated end-of-speech detection is needed, manage player node state.
//             }
//        }
//
//        if !engine.isRunning { try engine.start() } // Engine must be running
//        if !player.isPlaying { player.play() }       // Player must be playing
//        isPlaying = true // Set local flag
//    }
//
//    func stopPlayback() {
//        audioPlayerNode?.stop()
//        isPlaying = false
//        // audioEngine?.pause() // Optional: Pause engine if no longer needed
//         print("AudioService: Playback stopped.")
//    }
//
//    func shutdown() {
//        stopRecording()
//        stopPlayback()
//        audioEngine?.stop()
//        audioEngine = nil
//        inputNode = nil
//        audioPlayerNode = nil
//        try? audioSession?.setActive(false)
//        audioSession = nil
//        print("AudioService: Shutdown complete.")
//    }
//
//    enum AudioError: Error {
//        case initializationFailed(String)
//        case notInitialized
//        case sessionError(Error)
//        case engineError(Error)
//        case invalidState(String)
//        case bufferCreationFailed
//        case formatMismatch(String)
//    }
//}
//
//// Helper extension to create AVAudioPCMBuffer from Data
//extension Data {
//    func makePCMBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
//        let streamDesc = format.streamDescription.pointee
//        let frameCapacity = UInt32(count) / streamDesc.mBytesPerFrame
//        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }
//        buffer.frameLength = frameCapacity
//        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
//        withUnsafeBytes { (bufferPointer) in
//            guard let baseAddress = bufferPointer.baseAddress else { return }
//            memcpy(audioBuffer.mData, baseAddress, count)
//        }
//        return buffer
//    }
//}
//
//// MARK: - OpenAI Service (Actor for thread safety)
//
//actor OpenAIService {
//    private var webSocketTask: URLSessionWebSocketTask?
//    private let session: URLSession
//    private var sessionInfo: CreateSessionResponse? // Store session details
//
//    // Stream for downlink messages
//    private let downlinkStreamContinuation: AsyncStream<DownlinkMessageBase>.Continuation
//    let downlinkStream: AsyncStream<DownlinkMessageBase>
//
//    init() {
//        self.session = URLSession(configuration: .default)
//        // Setup the AsyncStream
//        var tempContinuation: AsyncStream<DownlinkMessageBase>.Continuation?
//        self.downlinkStream = AsyncStream { continuation in
//            tempContinuation = continuation
//        }
//        guard let continuation = tempContinuation else {
//             fatalError("Failed to initialize AsyncStream continuation") // Should not happen
//        }
//        self.downlinkStreamContinuation = continuation
//    }
//
//    func createSession() async throws -> CreateSessionResponse {
//        var request = URLRequest(url: SESSION_URL)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(OPENAI_API_KEY)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let requestBody = CreateSessionRequest()
//        request.httpBody = try JSONEncoder().encode(requestBody)
//
//        do {
//            let (data, response) = try await session.data(for: request)
//             guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                 let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
//                 print("HTTP Error: \(String(describing: (response as? HTTPURLResponse)?.statusCode)) - \(errorBody)")
//                 throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, description: errorBody)
//             }
//            let decodedResponse = try JSONDecoder().decode(CreateSessionResponse.self, from: data)
//             self.sessionInfo = decodedResponse // Store session info
//             print("Session created successfully: \(decodedResponse.id)")
//             return decodedResponse
//        } catch {
//             print("Failed to create session: \(error)")
//             throw error
//        }
//    }
//
//    func connectWebSocket(sessionData: CreateSessionResponse) async throws {
//        guard let wsURLString = sessionData.websocket_url else {
//            print("Error: WebSocket URL not found in session response.")
//            throw NetworkError.invalidResponse("WebSocket URL missing")
//        }
//        // **ASSUMPTION:** How to use client_secret? Maybe append to URL? Needs clarification.
//        // Example: let urlString = "\(wsURLString)?secret=\(sessionData.client_secret.value)"
//         guard let url = URL(string: wsURLString) else {
//             throw NetworkError.invalidURL(wsURLString)
//         }
//
//         // Prepare request (maybe needs auth header)
//        var request = URLRequest(url: url)
//        //Potentially add headers if WS security requires it:
//        //request.setValue("Bearer \(OPENAI_API_KEY)", forHTTPHeaderField: "Authorization") // Or other auth scheme
//
//        webSocketTask = session.webSocketTask(with: request)
//        webSocketTask?.receive(completionHandler: handleWebSocketError) // Initial receive setup also catches pending errors
//        webSocketTask?.resume()
//        listenForMessages()
//        print("WebSocket connection initiated to: \(url)")
//         // Maybe send an initial auth message here if required by API spec
//    }
//
//    private func listenForMessages() {
//        guard let task = webSocketTask else { return }
//
//        task.receive { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let message):
//                // Handle received message
//                self.handleReceivedMessage(message)
//                // Continue listening for the next message
//                self.listenForMessages()
//            case .failure(let error):
//                // Handle connection error or closure
//                self.handleWebSocketError(error: error)
//                 self.cleanUpWebSocket() // Clean up on error
//            }
//        }
//    }
//
//    private func handleReceivedMessage(_ message: URLSessionWebSocketTask.Message) {
//        switch message {
//        case .string(let text):
//            print("WS Received String: \(text)")
//            if let data = text.data(using: .utf8) {
//                // Attempt to decode as a known downlink message type
//                decodeAndYieldMessage(data: data)
//            }
//        case .data(let data):
//            print("WS Received Data: \(data.count) bytes")
//             // APIs might sendProtobuf or other binary formats.
//             // Assume JSON for now based on other messages.
//            decodeAndYieldMessage(data: data)
//        @unknown default:
//            print("WS Received unknown message type")
//        }
//    }
//
//    private func decodeAndYieldMessage(data: Data) {
//        do {
//            // First, try decoding the base to get the type
//            let baseMessage = try JSONDecoder().decode(DownlinkMessageBase.self, from: data)
//            
//            // Yield the base structure itself, ViewModels can switch on type
//             downlinkStreamContinuation.yield(baseMessage)
//             print("Yielded BaseMessage of type: \(baseMessage.type)")
//             
//             // --- Optional: Decode into specific types if needed here ---
//             // This adds complexity but can be done. Yielding base is often simpler.
//             // switch baseMessage.type {
//             // case "transcript":
//             //     let specificMsg = try JSONDecoder().decode(DownlinkTranscriptMessage.self, from: data)
//             //     // Yield specificMsg instead? Or let ViewModel handle full decode?
//             // case "ai_text":
//             //      let specificMsg = try JSONDecoder().decode(DownlinkAITextMessage.self, from: data)
//             // // ... etc ...
//             // default:
//             //     print("No specific decoder for type: \(baseMessage.type)")
//             // }
//             
//        } catch {
//            print("WS JSON Decoding Error: \(error)")
//             // Yield a generic error?
//             let errorMsg = DownlinkErrorMessage(type: "error", message: "Decoding failed: \(error.localizedDescription)", code: nil)
//             downlinkStreamContinuation.yield(errorMsg)
//        }
//    }
//
//    private func handleWebSocketError(error: Error?) {
//         if let wsError = error as NSError? {
//             // Handle specific WebSocket closure codes if needed
//             // e.g., wsError.code == 1000 (normal closure)
//             print("WebSocket Error/Closed: \(wsError.localizedDescription) (Code: \(wsError.code))")
//              let message = "WebSocket disconnected: \(wsError.localizedDescription)"
//              let downlinkError = DownlinkErrorMessage(type: "error", message: message, code: wsError.code)
//             downlinkStreamContinuation.yield(downlinkError)
//         } else {
//              print("WebSocket closed or unknown error.")
//              let downlinkError = DownlinkErrorMessage(type: "error", message: "WebSocket connection closed.", code: nil)
//             downlinkStreamContinuation.yield(downlinkError)
//         }
//         cleanUpWebSocket() // Ensure cleanup
//    }
//
//    func sendText(_ text: String) async throws {
//        guard let task = webSocketTask, task.closeCode == .invalid else {
//            throw NetworkError.notConnected
//        }
//        let message = UplinkTextMessage(text: text)
//        let data = try JSONEncoder().encode(message)
//        guard let jsonString = String(data: data, encoding: .utf8) else {
//            throw NetworkError.encodingFailed("Could not encode text message")
//        }
//         print("WS Sending Text: \(jsonString)")
//        try await task.send(.string(jsonString))
//    }
//
//    func sendAudioData(_ data: Data, sequenceId: Int? = nil) async throws {
//         guard let task = webSocketTask, task.closeCode == .invalid else {
//             throw NetworkError.notConnected
//         }
//         // Base64 encode audio data
//         let base64String = data.base64EncodedString()
//         let message = UplinkAudioMessage(data: base64String, sequence_id: sequenceId)
//         let messageData = try JSONEncoder().encode(message)
//         guard let jsonString = String(data: messageData, encoding: .utf8) else {
//             throw NetworkError.encodingFailed("Could not encode audio message")
//         }
//          print("WS Sending Audio Chunk: \(data.count) bytes (as base64)")
//         // Send as string (common for JSON-based WS APIs)
//          try await task.send(.string(jsonString))
//          // Alternatively, if API accepts raw binary for audio:
//          // try await task.send(.data(data)) // Depends entirely on API spec
//    }
//
//    func disconnect() {
//        print("WebSocket disconnect requested.")
//         webSocketTask?.cancel(with: .normalClosure, reason: nil)
//         cleanUpWebSocket()
//    }
//
//    private func cleanUpWebSocket() {
//         webSocketTask = nil
//          print("WebSocket task cleaned up.")
//     }
//     
//     deinit {
//         downlinkStreamContinuation.finish()
//         disconnect() // Ensure disconnect on deinit
//         print("OpenAIService deinitialized")
//     }
//
//     enum NetworkError: Error, LocalizedError {
//         case invalidURL(String)
//         case invalidResponse(String)
//         case serverError(statusCode: Int, description: String)
//         case encodingFailed(String)
//         case decodingFailed(Error)
//         case notConnected
//         case webSocketError(Error)
//
//         var errorDescription: String? {
//             switch self {
//             case .invalidURL(let url): return "Invalid URL: \(url)"
//             case .invalidResponse(let reason): return "Invalid API response: \(reason)"
//             case .serverError(let code, let desc): return "Server error (\(code)): \(desc)"
//             case .encodingFailed(let reason): return "Failed to encode message: \(reason)"
//             case .decodingFailed(let err): return "Failed to decode message: \(err.localizedDescription)"
//             case .notConnected: return "WebSocket is not connected."
//             case .webSocketError(let err): return "WebSocket error: \(err.localizedDescription)"
//             }
//         }
//     }
//}
//
//// MARK: - ViewModel (ObservableObject)
//
//@MainActor // Ensure properties are updated on the main thread for UI
//class RealtimeViewModel: ObservableObject {
//    @Published var conversationTurns: [ConversationTurn] = []
//    @Published var currentSessionInfo: CreateSessionResponse? = nil // Full session info
//    @Published var sessionError: String? = nil
//    @Published var isConnecting: Bool = false
//    @Published var webSocketConnected: Bool = false
//
//    // Input Area State
//    @Published var currentInputText: String = ""
//    @Published var isRecording: Bool = false
//    @Published var liveTranscript: String = "" // Shows live speech-to-text
//    @Published var audioInputLevel: Float = 0.0 // Use Float from AudioService
//
//    private var openAIService: OpenAIService?
//    private var audioService: AudioService?
//    private var downlinkTask: Task<Void, Never>? // Task to handle incoming messages
//
//    init() {
//        setupServices()
//    }
//
//    private func setupServices() {
//        openAIService = OpenAIService()
//        audioService = AudioService()
//         audioService?.onBufferProcessed = { [weak self] (data, level) in
//             guard let self = self, self.isRecording else { return }
//             Task { // Send audio data asynchronously
//                  await self.sendAudioData(data)
//                  await self.updateAudioLevel(level)
//             }
//         }
//        audioService?.onPlaybackFinished = { [weak self] in /* Handle playback end if needed */ }
//    }
//
//    // Update audio level on main thread
//     private func updateAudioLevel(_ level: Float) {
//         self.audioInputLevel = level
//     }
//
//    // MARK: - Session Control
//    func startSession() {
//        guard !isConnecting else { return }
//        print("ViewModel: Start Session requested.")
//        isConnecting = true
//        sessionError = nil
//        webSocketConnected = false
//        currentSessionInfo = nil
//        conversationTurns = [] // Clear previous conversation
//
//        Task {
//            do {
//                guard let service = openAIService else { throw AudioService.AudioError.notInitialized } // Use a generic or specific error
//                let sessionData = try await service.createSession()
//                
//                 // Update UI immediately with session info
//                 self.currentSessionInfo = sessionData
//                 print("ViewModel: Session created successfully (ID: \(sessionData.id)), attempting WS connect.")
//                 
//                 try await service.connectWebSocket(sessionData: sessionData)
//                // Start listening to the downlink stream AFTER connection attempt
//                startListeningToDownlink()
//                
//                 // Connection status will be updated via downlink messages or errors
//                 // For now, assume connection attempt implies "connecting" state handled by WS listen start
//            } catch {
//                print("ViewModel: Failed to start session or connect: \(error)")
//                sessionError = error.localizedDescription
//                isConnecting = false
//                webSocketConnected = false
//            }
//        }
//    }
//
//    func endSession() {
//         guard let service = openAIService else { return }
//         print("ViewModel: End Session requested.")
//         currentSessionInfo = nil
//         isConnecting = false
//         webSocketConnected = false
//         sessionError = nil
//         stopRecording() // Ensure recording stops
//         Task { await service.disconnect() }
//         downlinkTask?.cancel() // Stop listening
//         Task { await audioService?.shutdown() } // Clean up audio engine
//         setupServices() // Re-init services for potential next session
//         conversationTurns = [] // Clear conversation
//         liveTranscript = ""
//         currentInputText = ""
//    }
//
//    // MARK: - WebSocket Downlink Handling
//    private func startListeningToDownlink() {
//        guard let service = openAIService else { return }
//        downlinkTask?.cancel() // Cancel previous listener if any
//
//        downlinkTask = Task {
//             print("ViewModel: Started listening to downlink stream.")
//            await MainActor.run { // Ensure initial connection state update is on main thread
//                 // We might receive an error immediately if connection failed
//                 self.isConnecting = false // No longer in the explicit "connecting" phase
//                 // Note: webSocketConnected might still be false if connectWebSocket failed before listen started
//                 // We rely on receiving messages (or errors) to truly confirm 'connected' status.
//            }
//             for await baseMessage in service.downlinkStream {
//                 if Task.isCancelled { break }
//                 await handleDownlinkMessage(baseMessage)
//             }
//             print("ViewModel: Downlink stream finished or cancelled.")
//             await MainActor.run { // Update state if stream ends unexpectedly
//                 if self.webSocketConnected { // Only if we thought we were connected
//                     self.webSocketConnected = false
//                     self.sessionError = self.sessionError ?? "WebSocket disconnected unexpectedly."
//                 }
//             }
//        }
//    }
//
//    private func handleDownlinkMessage(_ baseMessage: DownlinkMessageBase) {
//         // Switch on the message type and update state accordingly
//         print("ViewModel: Handling downlink message type: \(baseMessage.type)")
//         self.webSocketConnected = true // Any successful message implies connection is working
//         self.isConnecting = false  // Definitely not connecting anymore
//
//        // Decode based on type (Requires full JSON string/data again, or pass it down)
//         // This is simplified. In reality, you'd pass the raw data/string from the service
//         // or the service would fully decode and pass specific structs/enums. Let's assume base for now.
//
//        switch baseMessage.type {
//        case "transcript":
//             // Assume we can get full details if needed - requires more complex decoding
//             if let text = (baseMessage as? DownlinkTranscriptMessage)?.text ?? (baseMessage as? DecodedPlaceholder)?.text {
//                 self.liveTranscript = text // Update live transcript display
//                 print("Live transcript updated: \(text)")
//                 // If final, add as user message? Be careful not to double-add if recording stop also adds it.
//                 // Let's assume final transcript handling happens elsewhere for now
//                 // or needs a more concrete 'isFinal' flag check here.
//            }
//             
//        case "ai_text":
//            // Needs full decode for text and is_final
//            if let text = (baseMessage as? DownlinkAITextMessage)?.text ?? (baseMessage as? DecodedPlaceholder)?.text,
//               let isFinal = (baseMessage as? DownlinkAITextMessage)?.is_final ?? (baseMessage as? DecodedPlaceholder)?.isFinal {
//                addOrUpdateAIResponseInTurn(textChunk: text, isFinal: isFinal)
//             }
//             
//        case "ai_audio":
//             // Needs full decode for audio_data (base64) and is_final
//                           // Needs full decode for audio_data (base64) and is_final
//             if let base64Data = (baseMessage as? DownlinkAIAudioMessage)?.audio_data ?? (baseMessage as? DecodedPlaceholder)?.audioData,
//               let isFinal = (baseMessage as? DownlinkAIAudioMessage)?.is_final ?? (baseMessage as? DecodedPlaceholder)?.isFinal {
//                 if let audioData = Data(base64Encoded: base64Data) {
//                     addOrUpdateAIResponseInTurn(audioData: audioData, isFinal: isFinal)
//                     // Trigger playback
//                     Task {
//                          try? await audioService?.playAudioChunk(data: audioData)
//                     }
//                 } else {
//                      print("Error: Could not decode base64 audio data.")
//                      sessionError = "Received corrupted audio data."
//                 }
//             }
//
//        case "error":
//             if let msg = (baseMessage as? DownlinkErrorMessage)?.message ?? (baseMessage as? DecodedPlaceholder)?.errorMessage {
//                 print("ViewModel Received Error: \(msg)")
//                 sessionError = msg
//                 webSocketConnected = false // Assume connection is lost on error
//                 // Potentially end session fully based on error code?
//            }
//            
//        default:
//            print("ViewModel: Received unhandled message type: \(baseMessage.type)")
//        }
//    }
//    
// // Placeholder struct if full decoding can't be done easily from base
//  private struct DecodedPlaceholder: Decodable {
//      let type: String
//      var text: String?
//      var isFinal: Bool?
//      var audioData: String? // base64 string
//      var errorMessage: String?
//      // Add other potential fields
//  }
//
//    // MARK: - User Actions
//    func sendTextMessage() {
//        guard let service = openAIService, !currentInputText.isEmpty, webSocketConnected else { return }
//        let textToSend = currentInputText
//        addOrUpdateUserMessageInTurn(text: textToSend, isFinal: true) // Add to UI immediately
//        currentInputText = "" // Clear field
//
//        Task {
//            do {
//                try await service.sendText(textToSend)
//            } catch {
//                sessionError = "Failed to send text: \(error.localizedDescription)"
//            }
//        }
//    }
//    
//    func sendAudioData(_ data: Data) async {
//         guard let service = openAIService, webSocketConnected else { return }
//         do {
//             try await service.sendAudioData(data)
//         } catch {
//              await MainActor.run { sessionError = "Failed to send audio: \(error.localizedDescription)" }
//         }
//     }
//
//    func toggleRecording() {
//        guard let audio = audioService, currentSessionInfo != nil, webSocketConnected else {
//             print("Cannot toggle recording: Session not active or audio service unavailable.")
//             return
//         }
//
//        Task {
//            if isRecording {
//                await audio.stopRecording()
//                // Optionally add the final accumulated transcript here if needed AFTER stopping.
//                // Be cautious not to add duplicate messages.
//                // addOrUpdateUserMessageInTurn(text: self.liveTranscript, isFinal: true)
//                // self.liveTranscript = "" // Clear after adding
//            } else {
//                 self.liveTranscript = "" // Clear before starting
//                do {
//                    try await audio.startRecording()
//                } catch {
//                     sessionError = "Failed to start recording: \(error.localizedDescription)"
//                     // Explicitly set isRecording to false if start fails
//                     await MainActor.run { self.isRecording = false }
//                     return // Exit if start failed
//                }
//            }
//             // Update state AFTER awaiting action completion
//             await MainActor.run { self.isRecording.toggle() }
//        }
//    }
//     
//     func stopRecording() {
//         guard isRecording, let audio = audioService else { return }
//         Task {
//             await audio.stopRecording()
//              await MainActor.run { self.isRecording = false }
//         }
//     }
//
//    // MARK: - Conversation Turn Management Helpers
//
//    private func addOrUpdateUserMessageInTurn(text: String, isFinal: Bool) {
//         if conversationTurns.isEmpty || conversationTurns.last?.aiResponse != nil {
//              // Create new turn with user message
//             let userContent = MessageContent(text: text, isFinal: isFinal, isUser: true, isStreaming: false)
//              conversationTurns.append(ConversationTurn(userMessage: userContent))
//          } else if let lastTurn = conversationTurns.last, lastTurn.userMessage == nil || !lastTurn.userMessage!.isFinal {
//              // Update existing user message (e.g., for accumulating live transcript)
//              if lastTurn.userMessage == nil {
//                   conversationTurns[conversationTurns.count - 1].userMessage = MessageContent(/*...*/ isUser: true) // Create if nil
//              }
//               conversationTurns[conversationTurns.count - 1].userMessage!.text += text
//               conversationTurns[conversationTurns.count - 1].userMessage!.isFinal = isFinal
//               conversationTurns[conversationTurns.count - 1].userMessage!.isStreaming = !isFinal
//          }
//         // If last user message IS final, typically we'd start a NEW turn,
//         // but the logic here allows appending if the AI hasn't responded yet. Adjust as needed.
//     }
//
//    func addOrUpdateAIResponseInTurn(textChunk: String? = nil, audioData: Data? = nil, isFinal: Bool) {
//     guard !conversationTurns.isEmpty else { return }
//     let lastTurnIndex = conversationTurns.count - 1
//     
//     // Ensure there's a user message to respond to
//     guard let userMessage = conversationTurns[lastTurnIndex].userMessage, userMessage.isFinal else {
//         print("AI Response ignored: No final user message in last turn.")
//         return
//     }
//
//     // Get or create the AI response object
//     if conversationTurns[lastTurnIndex].aiResponse == nil {
//         conversationTurns[lastTurnIndex].aiResponse = MessageContent(
//             sourceModel: currentSessionInfo?.model,
//             isUser: false
//         )
//     }
//     
//     // Use optional chaining for safety
//     guard let aiResponse = conversationTurns[lastTurnIndex].aiResponse else { return }
//
//     // Update content only if not already final
//     if !aiResponse.isFinal {
//         if let chunk = textChunk {
//             aiResponse.text += chunk
//         }
//         if let data = audioData {
//             aiResponse.audioData = (aiResponse.audioData ?? Data()) + data
//         }
//         aiResponse.isFinal = isFinal
//         aiResponse.isStreaming = !isFinal // Update streaming state
//         
//         // Ensure the view observes changes IF using ObservableObject for MessageContent
//         // objectWillChange.send() // Not needed if MessageContent isn't ObservableObject,
//                                   // but @Published vars in ViewModel handle parent updates.
//                                   // If MessageContent *is* ObservableObject use it.
//     } else {
//         print("AI Response ignored: Already final.")
//     }
// }
//
//    // MARK: - Deinit
//    deinit {
//        print("RealtimeViewModel deinitialized")
//        endSession() // Ensure cleanup
//    }
//}
//
//// MARK: - SwiftUI Views (Mostly Unchanged, Bind to ViewModel)
//
//struct ChatView: View {
//    @StateObject private var viewModel = RealtimeViewModel() // Use StateObject
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // 1. Session Control Area
//            SessionControlView(
//                 // Use viewModel properties directly
//                 sessionInfo: .constant(viewModel.currentSessionInfo), // Pass non-binding copy if view doesn't modify it
//                 isConnected: $viewModel.webSocketConnected,
//                 isConnecting: $viewModel.isConnecting,
//                 error: $viewModel.sessionError,
//                 startAction: viewModel.startSession,
//                 endAction: viewModel.endSession
//             )
//            .padding(.vertical, 5)
//
//            Divider()
//
//            // 2. Conversation Display Area
//            ScrollViewReader { scrollViewProxy in
//                 ScrollView {
//                     LazyVStack(spacing: 15) {
//                         // Iterate over viewModel's published turns
//                         ForEach(viewModel.conversationTurns) { turn in
//                             ConversationTurnView(turn: turn)
//                                 .id(turn.id)
//                         }
//                     }
//                     .padding(.horizontal)
//                     .padding(.top)
//                 }
//                .onChange(of: viewModel.conversationTurns.count) { // Scroll on new turns
//                     if let lastTurnId = viewModel.conversationTurns.last?.id {
//                         withAnimation(.spring()) {
//                             scrollViewProxy.scrollTo(lastTurnId, anchor: .bottom)
//                         }
//                     }
//                 }
//                 // Scroll when AI response starts streaming
//                 .onChange(of: viewModel.conversationTurns.last?.aiResponse?.isStreaming) {
//                      let isStreaming = viewModel.conversationTurns.last?.aiResponse?.isStreaming
//                     if isStreaming == true, let lastTurnId = viewModel.conversationTurns.last?.id {
//                          withAnimation(.spring()) {
//                              scrollViewProxy.scrollTo(lastTurnId, anchor: .bottom)
//                          }
//                      }
//                 }
//            }
//
//            Divider()
//
//            // 3. Realtime Input Area (Bind to ViewModel)
//             RealtimeInputArea(
//                 inputText: $viewModel.currentInputText,
//                 liveTranscript: $viewModel.liveTranscript,
//                 isRecording: $viewModel.isRecording,
//                 audioLevel: .constant(CGFloat(viewModel.audioInputLevel)), // Convert Float -> CGFloat
//                 isSessionActive: $viewModel.webSocketConnected, // Session active if WS is connected
//                 sendAction: viewModel.sendTextMessage,
//                 recordAction: viewModel.toggleRecording
//             )
//        }
//        .background(Color.black.ignoresSafeArea())
//        .foregroundColor(.white)
//        .alert("Session Error", isPresented: .constant(viewModel.sessionError != nil), actions: { // Simpler alert binding
//             Button("OK") { viewModel.sessionError = nil } // Clear error
//         }, message: {
//             Text(viewModel.sessionError ?? "An unknown error occurred.")
//         })
//        .onDisappear {
//             viewModel.endSession() // Ensure cleanup when view disappears
//        }
//    }
//}
//
//// Displays Session Status and Controls
//struct SessionControlView: View {
//     // Use non-binding 'let' for read-only props if view doesn't modify SessionInfo itself
//     let sessionInfo: CreateSessionResponse?
//     @Binding var isConnected: Bool
//     @Binding var isConnecting: Bool
//     @Binding var error: String? // Use Binding for error clearance
//
//    let startAction: () -> Void
//    let endAction: () -> Void
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                if let session = sessionInfo {
//                    Text("Session: \(session.id.prefix(12))...")
//                         .font(.caption).bold()
//                     HStack(spacing: 4) {
//                         Circle()
//                            .fill(isConnected ? Color.green : (isConnecting ? Color.orange : Color.red))
//                             .frame(width: 8, height: 8)
//                         Text(isConnected ? "Connected (\(session.model))" : (isConnecting ? "Connecting..." : "Disconnected"))
//                             .font(.caption2)
//                             .foregroundColor(isConnected ? .green : (isConnecting ? .orange : .red))
//                     }
//                } else {
//                    Text("No Active Session")
//                         .font(.caption).foregroundColor(.gray)
//                }
//                
//                // Display Session Error with clear button
//                if let errorMsg = error {
//                     HStack {
//                         Text("Error: \(errorMsg)")
//                             .font(.caption)
//                             .foregroundColor(.red)
//                             .lineLimit(1)
//                         Spacer()
//                         Button { error = nil } label: { // Clear error via binding
//                             Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
//                         }
//                     }
//                }
//            }
//
//            Spacer()
//
//            Button {
//                if sessionInfo != nil {
//                    endAction()
//                } else {
//                    startAction()
//                }
//            } label: {
//                 HStack {
//                     if isConnecting {
//                         ProgressView().controlSize(.mini).tint(.white)
//                     }
//                    Text(sessionInfo != nil ? (isConnected ? "End" : "Cancel") : "Start") // Adjust button text
//                 }
//                  .font(.caption)
//                  .padding(.horizontal, 10)
//                  .padding(.vertical, 5)
//                  .background(sessionInfo != nil ? Color.red : Color.blue)
//                  .foregroundColor(.white)
//                  .cornerRadius(5)
//                  .animation(.easeInOut, value: sessionInfo?.id) // Animate button change
//                  .animation(.easeInOut, value: isConnecting)
//            }
//              .disabled(isConnecting && sessionInfo == nil) // Disable Start if connecting
//             .opacity(isConnecting && sessionInfo != nil ? 0.7 : 1.0) // Dim End/Cancel if connecting
//
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//         .background(Color(white: 0.05).opacity(0.8)) // Slightly transparent background
//         .clipShape(RoundedRectangle(cornerRadius: 8))
//         .padding(.horizontal, 5) // Add padding around the control view
//    }
//}
//
//// Displays a single User/AI turn
//struct ConversationTurnView: View {
//    // Observe MessageContent if it's an ObservableObject
//    // @ObservedObject var turn: ConversationTurn // If ConversationTurn holds @ObservedObject MessageContent
//    let turn: ConversationTurn // Use let if MessageContent isn't directly observed here
//
//    var body: some View {
//        VStack(spacing: 10) {
//            // Pass MessageContent directly if it's not ObservableObject
//             // If MessageContent IS an @ObservableObject use @StateObject or @ObservedObject
//             if let userMsg = turn.userMessage {
//                  MessageBubble(messageContent: userMsg) // Pass the object
//             }
//             if let aiMsg = turn.aiResponse {
//                  MessageBubble(messageContent: aiMsg) // Pass the object
//             }
//        }
//    }
//}
//
//// Displays a single message bubble (Observes MessageContent)
//struct MessageBubble: View {
//     @ObservedObject var messageContent: MessageContent // Observe changes
//
//    var body: some View {
//         let isUser = messageContent.isUser
//         HStack(alignment: .bottom, spacing: 8) {
//             if isUser { Spacer() }
//
//            VStack(alignment: isUser ? .trailing : .leading) {
//                 // Display Text - reacts to @Published changes
//                 if !messageContent.text.isEmpty || messageContent.isStreaming {
//                     Text(messageContent.text + (messageContent.isStreaming ? "▌" : "" ))
//                         .padding(12)
//                         .background(bubbleBackground())
//                         .foregroundColor(isUser ? .black : .white)
//                         .cornerRadius(15)
//                          .transition(.identity) // Prevent default transition issues with streaming text
//                 }
//
//                 // Display Audio Placeholder/Indicator
//                 if messageContent.isAudio {
//                      HStack {
//                          Image(systemName: "waveform.path")
//                          Text("Audio Response") // Simple indicator
//                      }
//                         .font(.caption)
//                         .padding(8)
//                         .background(bubbleBackground().opacity(0.7))
//                         .foregroundColor(isUser ? .black.opacity(0.8) : .white.opacity(0.8))
//                         .cornerRadius(10)
//                 }
//               
//               // Display Error
//               if let errorMsg = messageContent.error {
//                   Text("Error: \(errorMsg)")
//                       .font(.caption2)
//                       .foregroundColor(.red)
//                       .padding(.top, 2)
//               }
//             }
//             .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)
//
//             if !isUser { Spacer() }
//         }
//     }
//
//     // Determine background based on observed MessageContent state
//     @ViewBuilder
//     private func bubbleBackground() -> some View {
//         if messageContent.error != nil {
//             Color.red.opacity(messageContent.isUser ? 0.6 : 0.4)
//         } else if messageContent.isUser {
//             Color.yellow.opacity(0.9)
//         } else {
//             Color(white: 0.25)
//         }
//     }
//}
//
//// Input area for Text, Recording, and Live Transcript (Bindings to ViewModel)
//struct RealtimeInputArea: View {
//    @Binding var inputText: String
//    @Binding var liveTranscript: String
//    @Binding var isRecording: Bool
//    @Binding var audioLevel: CGFloat // Using CGFloat from ViewModel binding
//    @Binding var isSessionActive: Bool // Directly bind to ViewModel's connection status
//
//    let sendAction: () -> Void
//    let recordAction: () -> Void
//
//     @FocusState private var isTextFieldFocused: Bool // Manage focus state
//
//    var body: some View {
//        VStack(spacing: 5) {
//             // Live Transcript / Input Field Placeholder
//             Text(isRecording ? (liveTranscript.isEmpty ? "Listening..." : liveTranscript) : (inputText.isEmpty ? "Type or hold mic..." : ""))
//                 .font(.caption)
//                 .foregroundColor(isRecording ? .yellow.opacity(0.8) : .gray)
//                 .frame(maxWidth: .infinity, alignment: .leading)
//                 .padding(.horizontal)
//                 .lineLimit(1)
//                 .id("transcriptArea") // ID for potential high-frequency updates?
//
//            HStack(spacing: 8) {
//                // Text Field
//                TextField("Enter text", text: $inputText, axis: .vertical) {
//                     // Optionally handle commit action if needed (e.g., send on Enter)
//                 }
//                  .focused($isTextFieldFocused)
//                  .textFieldStyle(.plain)
//                  .padding(10)
//                  .background(Color.white.opacity(0.1)) // Lighter background
//                  .cornerRadius(18)
//                   .overlay(RoundedRectangle(cornerRadius: 18).stroke(isTextFieldFocused ? Color.yellow : Color.clear, lineWidth: 1))
//                  .lineLimit(1...3)
//                  .opacity(isRecording ? 0.3 : 1.0) // Dim more when recording
//                  .disabled(isRecording || !isSessionActive)
//
//                 // --- Combined Record/Stop and Send Button ---
//                 Button {
//                      if isRecording {
//                          recordAction() // Stops recording
//                      } else if !inputText.isEmpty {
//                          sendAction() // Sends text
//                      } else {
//                          recordAction() // Starts recording
//                          isTextFieldFocused = false  // Dismiss keyboard when starting recording
//                      }
//                 } label: {
//                      Image(systemName: buttonIconName)
//                           .resizable()
//                           .scaledToFit()
//                           .frame(width: 28, height: 28) // Slightly smaller icon
//                           .padding(8) // Make tap area slightly larger
//                           .background(buttonBackgroundColor.opacity(isSessionActive ? 1.0 : 0.5)) // Dim if inactive
//                           .foregroundColor(.black)
//                           .clipShape(Circle())
//                 }
//                  .disabled(!isSessionActive && !isRecording) // Disable if session inactive unless stopping recording
//                  .animation(.easeInOut, value: isRecording)
//                  .animation(.easeInOut, value: inputText.isEmpty)
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 8)
//             .padding(.top, 2)
//
//             // Audio Visualizer
//             AudioVisualizer(audioLevel: $audioLevel)
//                 .frame(height: isRecording ? 15 : 0)
//                 .opacity(isRecording ? 1 : 0)
//                 .padding(.bottom, 5)
//                 .animation(.easeInOut(duration: 0.1), value: isRecording)
//                 .allowsHitTesting(false) // Prevent visualizer from blocking interactions
//        }
//        .background(Color(white: 0.08)) // Slightly darker input area background
//         .contentShape(Rectangle()) // Ensure background taps dismiss keyboard
//         .onTapGesture { isTextFieldFocused = false }
//    }
//    
//     // Determine button icon based on state
//     private var buttonIconName: String {
//         if isRecording {
//             return "stop.fill"
//         } else if !inputText.isEmpty {
//             return "arrow.up"
//         } else {
//             return "mic.fill"
//         }
//     }
//     
//     // Determine button background color
//     private var buttonBackgroundColor: Color {
//         if isRecording {
//             return .red
//         } else if !inputText.isEmpty {
//             return .yellow // Send color
//         } else {
//             return .yellow // Record color
//         }
//     }
//}
//
//// Simple Bar Visualizer (Unchanged)
// struct AudioVisualizer: View {
//     @Binding var audioLevel: CGFloat // Expected range 0.0 to 1.0
//
//     var body: some View {
//          // Use Canvas for potentially better performance with frequent drawing
//          Canvas { context, size in
//              let barWidth: CGFloat = 3
//              let spacing: CGFloat = 1
//              let numberOfBars = Int(size.width / (barWidth + spacing))
//              let barMaxHeight = size.height
//              let center = size.height / 2.0
//
//              for i in 0..<numberOfBars {
//                   // Simulate more dynamic visualization - vary height slightly
//                   let randomFactor = CGFloat.random(in: 0.7...1.3)
//                   // Use audioLevel more directly, scaling random factor by it
//                   let barHeight = max(1, barMaxHeight * audioLevel * randomFactor) * (1.0 - abs(CGFloat(i) - CGFloat(numberOfBars)/2.0) / (CGFloat(numberOfBars)/1.5)) // Taper off edges
//                   
//                   let xPos = CGFloat(i) * (barWidth + spacing)
//                   // Draw bar centered vertically? Or from bottom? From bottom is simpler.
//                    // Draw from bottom
//                   let rect = CGRect(x: xPos, y: size.height - barHeight, width: barWidth, height: barHeight)
//                   // // Draw centered
//                   // let rect = CGRect(x: xPos, y: center - barHeight / 2.0, width: barWidth, height: barHeight)
//                   
//                   context.fill(Path(roundedRect: rect, cornerRadius: 1), with: .linearGradient(Gradient(colors: [.yellow.opacity(0.8), .orange]), startPoint: .bottom, endPoint: .top))
//              }
//          }
//           .clipped() // Clip drawing to bounds
//           .animation(.easeOut(duration: 0.05), value: audioLevel)
//          // No drawingGroup needed with Canvas typically
//     }
// }
//
//// MARK: - Preview
//
//#Preview {
//     ChatView()
//          .preferredColorScheme(.dark)
//}
