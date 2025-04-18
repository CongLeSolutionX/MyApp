////
////  ChatView_V7.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//
////  Created by Cong Le on 4/17/25, adapted on [Current Date] for Realtime API Simulation
////
//
//import SwiftUI
//import AVFoundation // Needed for audio handling simulation
//
//// MARK: - Data Models (Enhanced for Realtime)
//
//// Represents a chunk of interactive conversation (can be text or audio focused)
//struct ConversationTurn: Identifiable {
//    let id = UUID()
//    var userMessage: MessageContent?
//    var aiResponse: MessageContent?
//    var timestamp: Date = Date()
//}
//
//// Holds the content, distinguishing type and streaming state
//struct MessageContent: Identifiable {
//    let id = UUID()
//    var text: String = ""
//    var audioData: Data? = nil // For received AI audio OR recorded user audio
//    var isFinal: Bool = false // Indicates if the response/transcript is complete
//    var sourceModel: String? = "gpt-4o-realtime-preview" // Model identifier
//    var error: String? = nil
//    var isUser: Bool
//    var isStreaming: Bool = false // True while text/audio is actively arriving
//    
//    // Computed property to check if it's primarily audio
//    var isAudio: Bool {
//        audioData != nil && !audioData!.isEmpty
//    }
//}
//
//// Represents session details (from API response)
//struct SessionInfo: Identifiable {
//    let id: String // session ID like "sess_001"
//    let model: String
//    let modalities: [String]
//    let clientSecretValue: String // Placeholder for the secret
//    let expiresAt: TimeInterval // Placeholder for expiration
//    var isConnected: Bool = false // Local state for WS connection
//}
//
//// MARK: - Constants (Replace with secure handling in a real app)
//private let OPENAI_API_KEY = "YOUR_API_KEY_HERE" // <-- DO NOT HARDCODE IN PRODUCTION
//
//// MARK: - Main Chat View for Realtime API Simulation
//
//struct ChatView: View {
//    // --- State Variables ---
//    @State private var conversationTurns: [ConversationTurn] = []
//    @State private var currentSession: SessionInfo? = nil
//    @State private var sessionError: String? = nil
//    @State private var isConnecting: Bool = false // True while establishing session/WS
//
//    // Input Area State
//    @State private var currentInputText: String = ""
//    @State private var isRecording: Bool = false
//    @State private var liveTranscript: String = "" // Shows live speech-to-text
//    @State private var audioInputLevel: CGFloat = 0.0 // For visualizer
//
//    // WebSocket Simulation State (replace with actual WS Task in real app)
//    @State private var webSocketConnected: Bool = false // Tracks WS status within session
//    @State private var simulatedWebSocketTimer: Timer? // To mimic incoming messages
//
//    // Audio Simulation State (replace with real AVAudioEngine etc.)
//    @State private var audioRecorderSim: AudioRecorderSimulator?
//    @State private var audioPlayerSim: AudioPlayerSimulator?
//
//    // --- Body ---
//    var body: some View {
//        VStack(spacing: 0) {
//            // 1. Session Control Area
//            SessionControlView(
//                sessionInfo: $currentSession,
//                isConnected: $webSocketConnected,
//                isConnecting: $isConnecting,
//                error: $sessionError,
//                startAction: startSession,
//                endAction: endSession
//            )
//            .padding(.vertical, 5)
//
//            Divider()
//
//            // 2. Conversation Display Area
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    LazyVStack(spacing: 15) {
//                        ForEach(conversationTurns) { turn in
//                            ConversationTurnView(turn: turn)
//                                .id(turn.id)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top)
//                }
//                .onChange(of: conversationTurns.count) { // Scroll on new turns
//                    if let lastTurnId = conversationTurns.last?.id {
//                        withAnimation {
//                            scrollViewProxy.scrollTo(lastTurnId, anchor: .bottom)
//                        }
//                    }
//                }
//                // Potential: Scroll when AI response starts streaming
//                .onChange(of: conversationTurns.last?.aiResponse?.isStreaming) {
//                    let isStreaming = conversationTurns.last?.aiResponse?.isStreaming
//                     if isStreaming == true, let lastTurnId = conversationTurns.last?.id {
//                         withAnimation {
//                             scrollViewProxy.scrollTo(lastTurnId, anchor: .bottom)
//                         }
//                     }
//                }
//            }
//
//            Divider()
//
//            // 3. Realtime Input Area (Text, Audio, Live Transcript)
//            RealtimeInputArea(
//                inputText: $currentInputText,
//                liveTranscript: $liveTranscript,
//                isRecording: $isRecording,
//                audioLevel: $audioInputLevel,
//                isSessionActive: .constant(currentSession != nil && webSocketConnected), // Bind active state
//                sendAction: sendTextMessage,
//                recordAction: toggleRecording
//            )
//        }
//        .background(Color.black.ignoresSafeArea())
//        .foregroundColor(.white)
//        .onAppear {
//            // Setup audio session (important for real app)
//            // setupAudioSession()
//            // Instantiate simulators
//            audioRecorderSim = AudioRecorderSimulator { level in
//                self.audioInputLevel = level
//            } onTranscript: { transcriptChunk, isFinal in
//                // Simulate live transcription update
//                 handleIncomingWebSocketMessage(jsonString: """
//                 {"type": "transcript", "text": "\(transcriptChunk)", "is_final": \(isFinal)}
//                 """)
//                // Simulate sending audio chunk over WS
//                 sendAudioChunkViaWebSocket(data: Data()) // Placeholder data
//            }
//            audioPlayerSim = AudioPlayerSimulator { level in
//                 // Update UI for AI audio playback visualization if needed
//            }
//        }
//        .onDisappear {
//            endSession() // Clean up session when view disappears
//             stopSimulatedWebSocket() // Clean up timer
//             audioRecorderSim?.stop()
//             audioPlayerSim?.stop()
//        }
//    }
//
//    // MARK: - Session Management Logic (Simulated)
//
//    func startSession() {
//        guard OPENAI_API_KEY != "YOUR_API_KEY_HERE" else {
//            sessionError = "API Key not set."
//            return
//        }
//        sessionError = nil
//        isConnecting = true
//        currentSession = nil
//        webSocketConnected = false
//        endSession() // Ensure any previous session is cleaned up
//
//        print("Simulating: Starting Realtime Session...")
//
//        // Simulate network call to /v1/realtime/sessions
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            // Simulate success
//            let newSession = SessionInfo(
//                id: "sess_\(UUID().uuidString.prefix(8))",
//                model: "gpt-4o-realtime-preview",
//                modalities: ["audio", "text"],
//                clientSecretValue: "ek_simulated_\(UUID().uuidString.prefix(6))",
//                expiresAt: Date().timeIntervalSince1970 + 3600 // Simulate 1 hour expiry
//            )
//            self.currentSession = newSession
//            print("Simulating: Session Created - ID: \(newSession.id)")
//
//            // Proceed to connect WebSocket
//            connectWebSocket(session: newSession)
//        }
//    }
//
//    func connectWebSocket(session: SessionInfo) {
//        print("Simulating: Connecting WebSocket...")
//        // Simulate WebSocket connection attempt
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.isConnecting = false // Finished connection attempt
//            // Simulate successful connection
//            self.webSocketConnected = true
//            self.currentSession?.isConnected = true // Update session state
//            print("Simulating: WebSocket Connected for Session ID: \(session.id)")
//            // Start a timer to simulate receiving messages (like keep-alives or initial prompts)
//             startSimulatedWebSocket()
//        }
//    }
//
//    func endSession() {
//        guard currentSession != nil else { return }
//        print("Simulating: Ending Session ID: \(currentSession?.id ?? "N/A")")
//         stopSimulatedWebSocket()
//        webSocketConnected = false
//        if isRecording { stopRecording() } // Stop recording if active
//         audioPlayerSim?.stop()
//        
//        // Reset state
//        currentSession = nil
//        conversationTurns = [] // Clear conversation on session end
//        currentInputText = ""
//        liveTranscript = ""
//        sessionError = nil
//        isConnecting = false
//        
//        print("Simulating: Session Ended and Cleaned Up.")
//    }
//
//    // MARK: - WebSocket Communication (Simulated)
//
//    func startSimulatedWebSocket() {
//        stopSimulatedWebSocket() // Ensure no duplicate timers
//        // Simulate receiving messages periodically
//        simulatedWebSocketTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
//            // Simulate receiving a message. Could be keep-alive, status, or async AI response
//             if Bool.random() && conversationTurns.last?.aiResponse == nil { // Simulate random AI start
//                 handleIncomingWebSocketMessage(jsonString: """
//                 {"type": "ai_text", "text": "Thinking... ", "is_final": false}
//                 """)
//             } else {
//                  print("Simulated Keep-Alive") // Simulate keep-alive
//             }
//        }
//    }
//
//    func stopSimulatedWebSocket() {
//        simulatedWebSocketTimer?.invalidate()
//        simulatedWebSocketTimer = nil
//    }
//
//    func sendTextMessage() {
//        guard let session = currentSession, webSocketConnected, !currentInputText.isEmpty else { return }
//        let textToSend = currentInputText
//        currentInputText = "" // Clear input field
//
//        // Ensure a turn exists or create a new one
//        if addOrUpdateUserMessage(text: textToSend) {
//            print("Simulating: Sending text message via WebSocket: \(textToSend)")
//            // Simulate receiving AI response after a delay
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                let aiText = "Simulated AI response to: \(textToSend.prefix(30))..."
//                 handleIncomingWebSocketMessage(jsonString: """
//                 {"type": "ai_text", "text": "\(aiText)", "is_final": false}
//                 """)
//                // Simulate final chunk shortly after
//                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                     handleIncomingWebSocketMessage(jsonString: """
//                     {"type": "ai_text", "text": " That's the full thought.", "is_final": true}
//                     """)
//                 }
//            }
//             // Simulate potential audio response too
//             DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//                  handleIncomingWebSocketMessage(jsonString: """
//                  {"type": "ai_audio", "audio_data": "SIMULATED_BASE64_AUDIO", "is_final": true}
//                  """)
//             }
//        }
//    }
//
//    func sendAudioChunkViaWebSocket(data: Data) {
//        guard let session = currentSession, webSocketConnected else { return }
//        // In a real app, send `data` over the actual WebSocketTask
//         print("Simulating: Sending audio chunk (\(data.count) bytes) via WebSocket.")
//        
//        // NOTE: Simulation of AI responses is handled separately for simplicity here,
//        // triggered by transcription or text messages. In reality, the API responds
//        // fluidly based on incoming audio/text turns.
//    }
//
//    // Central handler for incoming WebSocket messages (JSON strings for simulation)
//    func handleIncomingWebSocketMessage(jsonString: String) {
//        guard let jsonData = jsonString.data(using: .utf8) else { return }
//        
//        // Simulate JSON parsing
//        // In real app, use JSONDecoder with proper Codable structs
//        do {
//            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//                guard let type = json["type"] as? String else { return }
//                
//                switch type {
//                case "transcript":
//                    liveTranscript = json["text"] as? String ?? liveTranscript // Update live transcript
//                    let isFinal = json["is_final"] as? Bool ?? false
//                    if isFinal {
//                        // Add transcript as a user message turn
//                        _ = addOrUpdateUserMessage(text: liveTranscript, isFinal: true)
//                        liveTranscript = "" // Clear live transcript after final
//                    }
//                case "ai_text":
//                    let textChunk = json["text"] as? String ?? ""
//                    let isFinal = json["is_final"] as? Bool ?? false
//                    addOrUpdateAIResponse(textChunk: textChunk, isFinal: isFinal)
//                case "ai_audio":
//                     let audioDataBase64 = json["audio_data"] as? String // Simulate base64 encoded audio
//                     let isFinal = json["is_final"] as? Bool ?? false
//                     // Simulate decoding and playing
//                     if audioDataBase64 != nil {
//                         addOrUpdateAIResponse(audioData: Data(), isFinal: isFinal) // Placeholder data
//                         audioPlayerSim?.playSimulated(duration: 1.0) // Simulate playback
//                     }
//                case "error":
//                    sessionError = json["message"] as? String ?? "Unknown WebSocket error"
//                    print("WebSocket Error: \(sessionError ?? "Unknown")")
//                default:
//                    print("Received unknown message type: \(type)")
//                }
//            }
//        } catch {
//            print("Error parsing simulated JSON: \(error)")
//        }
//    }
//
//    // MARK: - Conversation Turn Management
//
//    // Adds or updates the user message in the latest turn
//    // Returns true if successful (turn exists/created), false otherwise
//    func addOrUpdateUserMessage(text: String, isFinal: Bool = true) -> Bool {
//        if conversationTurns.isEmpty || conversationTurns.last?.aiResponse != nil {
//            // Create a new turn if conversation is empty or last turn has AI response
//            let userContent = MessageContent(text: text, isFinal: isFinal, isUser: true, isStreaming: false)
//            conversationTurns.append(ConversationTurn(userMessage: userContent))
//            print("Debug: Created new turn for user message.")
//            return true
//        } else if var lastTurn = conversationTurns.last, lastTurn.userMessage == nil || !lastTurn.userMessage!.isFinal {
//            // Update existing user message if it's not final (e.g. accumulating transcript)
//            if lastTurn.userMessage == nil {
//                lastTurn.userMessage = MessageContent(text: "", isUser: true)
//            }
//            // Append text, update final status
//            lastTurn.userMessage?.text += text
//            lastTurn.userMessage?.isFinal = isFinal
//            lastTurn.userMessage?.isStreaming = !isFinal // Streaming if not final
//            
//            // Ensure we update the array
//            conversationTurns[conversationTurns.count - 1] = lastTurn
//             print("Debug: Updated user message in last turn. Final: \(isFinal)")
//            return true
//        } else {
//             print("Debug: Cannot add user message - Last turn user message is already final.")
//            return false // Last user message was final, shouldn't overwrite
//        }
//    }
//
//    // Adds or updates the AI response in the latest turn
//    // Adds or updates the AI response in the latest turn
//        func addOrUpdateAIResponse(textChunk: String? = nil, audioData: Data? = nil, isFinal: Bool) {
//            guard !conversationTurns.isEmpty else {
//                print("Debug: Cannot add AI response - No turns exist.")
//                return
//            } // Need a turn first
//            // Make `lastTurn` mutable to modify it before reassigning.
//            // Using index access avoids issues with local copies if `ConversationTurn` were a class.
//            // Since it's a struct, direct index access is more robust for mutation.
//            let lastTurnIndex = conversationTurns.count - 1
//            guard conversationTurns[lastTurnIndex].userMessage != nil && conversationTurns[lastTurnIndex].userMessage!.isFinal else {
//                 print("Debug: Cannot add AI response - User message in last turn is missing or not final.")
//                return // Need a final user message to respond to
//            }
//
//            if conversationTurns[lastTurnIndex].aiResponse == nil {
//                // Create new AI response if one doesn't exist
//                conversationTurns[lastTurnIndex].aiResponse = MessageContent(
//                    text: textChunk ?? "",
//                    audioData: audioData, // Directly assign initial audio data
//                    isFinal: isFinal,
//                    sourceModel: currentSession?.model ?? "gpt-4o-realtime-preview", isUser: false,
//                    isStreaming: !isFinal // Streaming if not final
//                )
//                 print("Debug: Created new AI response. Final: \(isFinal)")
//            } else {
//                // Append to existing AI response if it's not final
//                // Use direct index access and check `isFinal` safely
//                if let isResponseFinal = conversationTurns[lastTurnIndex].aiResponse?.isFinal, !isResponseFinal {
//                     // Append text if provided
//                     if let chunk = textChunk {
//                         conversationTurns[lastTurnIndex].aiResponse!.text += chunk
//                     }
//
//                     // --- Corrected Audio Data Handling ---
//                     if let newData = audioData {
//                         // 1. Get current data (or empty if nil) into a local variable from the array element
//                         var currentAudio = conversationTurns[lastTurnIndex].aiResponse!.audioData ?? Data()
//                         // 2. Append the new data to the local variable
//                         currentAudio += newData
//                         // 3. Assign the result back to the array element
//                         conversationTurns[lastTurnIndex].aiResponse!.audioData = currentAudio
//                     }
//                     // --- End Correction ---
//
//                     // Update final and streaming status
//                     conversationTurns[lastTurnIndex].aiResponse!.isFinal = isFinal
//                     conversationTurns[lastTurnIndex].aiResponse!.isStreaming = !isFinal
//                     print("Debug: Updated AI response. Final: \(isFinal)")
//                } else {
//                     print("Debug: Skipping update - AI response already final or doesn't exist.")
//                }
//            }
//            
//            // No need to reassign the whole turn back if we modified the array element directly via index.
//            // The update happens in place within the array's element.
//        }
//    
//    
////    func addOrUpdateAIResponse(textChunk: String? = nil, audioData: Data? = nil, isFinal: Bool) {
////        guard !conversationTurns.isEmpty else {
////            print("Debug: Cannot add AI response - No turns exist.")
////            return
////        } // Need a turn first
////        guard var lastTurn = conversationTurns.last else { return } // Should exist if not empty
////        guard lastTurn.userMessage != nil && lastTurn.userMessage!.isFinal else {
////             print("Debug: Cannot add AI response - User message in last turn is missing or not final.")
////            return // Need a final user message to respond to
////        }
////
////        if lastTurn.aiResponse == nil {
////            // Create new AI response if one doesn't exist
////            lastTurn.aiResponse = MessageContent(
////                text: textChunk ?? "",
////                audioData: audioData,
////                isFinal: isFinal,
////                sourceModel: currentSession?.model ?? "gpt-4o-realtime-preview", isUser: false,
////                isStreaming: !isFinal // Streaming if not final
////            )
////             print("Debug: Created new AI response. Final: \(isFinal)")
////        } else {
////            // Append to existing AI response if it's not final
////            if !lastTurn.aiResponse!.isFinal {
////                if let chunk = textChunk {
////                    lastTurn.aiResponse?.text += chunk
////                }
////                if let data = audioData {
////                     // Append audio data if needed (simplififed here)
////                     lastTurn.aiResponse?.audioData = (lastTurn.aiResponse!.audioData ?? Data()) + data
////                }
////                lastTurn.aiResponse?.isFinal = isFinal
////                lastTurn.aiResponse?.isStreaming = !isFinal
////                 print("Debug: Updated AI response. Final: \(isFinal)")
////            } else {
////                 print("Debug: Skipping update - AI response already final.")
////            }
////        }
////        
////        // Update the actual array item
////        conversationTurns[conversationTurns.count - 1] = lastTurn
////    }
//
//    // MARK: - Audio Handling Logic (Simulated)
//
//    func toggleRecording() {
//        guard currentSession != nil && webSocketConnected else { return }
//
//        if isRecording {
//            stopRecording()
//        } else {
//            startRecording()
//        }
//    }
//
//    func startRecording() {
//        print("Simulating: Start Recording")
//        liveTranscript = "" // Clear previous live transcript
//        isRecording = true
//        audioRecorderSim?.start()
//        // Start sending audio chunks over WebSocket (simulated via recorder callback)
//    }
//
//    func stopRecording() {
//        print("Simulating: Stop Recording")
//        isRecording = false
//        audioRecorderSim?.stop()
//        audioInputLevel = 0.0
//        
//        // In a real app, send a final audio chunk or end signal
//    }
//
//    // --- Audio Session Setup (Placeholder) ---
//    // func setupAudioSession() {
//    //     let audioSession = AVAudioSession.sharedInstance()
//    //     do {
//    //         try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.duckOthers, .defaultToSpeaker])
//    //         try audioSession.setActive(true)
//    //         print("Audio session setup successfully.")
//    //     } catch {
//    //         print("Failed to set up audio session: \(error)")
//    //         sessionError = "Audio Error: Could not configure audio."
//    //     }
//    // }
//}
//
//// MARK: - Helper UI Components
//
//// Displays Session Status and Controls
//struct SessionControlView: View {
//    @Binding var sessionInfo: SessionInfo?
//    @Binding var isConnected: Bool
//    @Binding var isConnecting: Bool
//    @Binding var error: String?
//
//    let startAction: () -> Void
//    let endAction: () -> Void
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                if let session = sessionInfo {
//                    Text("Session: \(session.id.prefix(12))...")
//                        .font(.caption).bold()
//                    HStack(spacing: 4) {
//                         Circle()
//                            .fill(isConnected ? Color.green : Color.orange)
//                            .frame(width: 8, height: 8)
//                         Text(isConnected ? "Connected (\(session.model))" : (isConnecting ? "Connecting..." : "Disconnected"))
//                             .font(.caption2)
//                             .foregroundColor(isConnected ? .green : .orange)
//                    }
//                } else {
//                    Text("No Active Session")
//                        .font(.caption).foregroundColor(.gray)
//                }
//                
//                // Display Session Error
//                 if let errorMsg = error {
//                     Text("Error: \(errorMsg)")
//                         .font(.caption)
//                         .foregroundColor(.red)
//                         .lineLimit(1)
//                 }
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
//                if isConnecting {
//                    ProgressView()
//                        .controlSize(.small)
//                } else {
//                    Text(sessionInfo != nil ? "End Session" : "Start Session")
//                        .font(.caption)
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 5)
//                        .background(sessionInfo != nil ? Color.red : Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(5)
//                }
//            }
//              .disabled(isConnecting)
//             .animation(.easeInOut, value: isConnecting)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//         .background(Color(white: 0.1)) // Subtle background
//    }
//}
//
//// Displays a single User/AI turn
//struct ConversationTurnView: View {
//    let turn: ConversationTurn
//
//    var body: some View {
//        VStack(spacing: 10) {
//            if let userMsg = turn.userMessage {
//                MessageBubble(message: userMsg, isUser: true)
//            }
//            if let aiMsg = turn.aiResponse {
//                MessageBubble(message: aiMsg, isUser: false)
//            }
//        }
//    }
//}
//
//// Displays a single message bubble (Text or Audio placeholder)
//struct MessageBubble: View {
//    let message: MessageContent
//    let isUser: Bool
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            if isUser { Spacer() }
//
//            VStack(alignment: isUser ? .trailing : .leading) {
//                // Display Text
//                if !message.text.isEmpty {
//                    Text(message.text + (message.isStreaming ? "▌" : "" )) // Add cursor if streaming
//                        .padding(12)
//                        .background(bubbleBackground())
//                        .foregroundColor(isUser ? .black : .white)
//                        .cornerRadius(15)
//                }
//
//                // Display Audio Placeholder/Indicator
//                if message.isAudio {
//                     HStack {
//                         Image(systemName: "waveform.path")
//                         Text("Audio Response")
//                           //  + (message.isStreaming ? " (Receiving...)" : (message.isFinal ? "" : " (Partial)")))
//                     }
//                        .font(.caption)
//                        .padding(8)
//                        .background(bubbleBackground().opacity(0.7))
//                        .foregroundColor(isUser ? .black.opacity(0.8) : .white.opacity(0.8))
//                        .cornerRadius(10)
//                }
//              
//              // Display Error
//              if let errorMsg = message.error {
//                  Text("Error: \(errorMsg)")
//                      .font(.caption2)
//                      .foregroundColor(.red)
//                      .padding(.top, 2)
//              }
//            }
//            .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)
//
//            if !isUser { Spacer() }
//        }
//         .transition(.opacity.combined(with: .move(edge: isUser ? .trailing : .leading))) // Add transition
//    }
//
//    @ViewBuilder
//    private func bubbleBackground() -> some View {
//        if message.error != nil {
//            Color.red.opacity(isUser ? 0.6 : 0.4)
//        } else if isUser {
//            Color.yellow.opacity(0.9)
//        } else {
//            Color(white: 0.25)
//        }
//    }
//}
//
//// Input area for Text, Recording, and Live Transcript
//struct RealtimeInputArea: View {
//    @Binding var inputText: String
//    @Binding var liveTranscript: String // Display live transcription here
//    @Binding var isRecording: Bool
//    @Binding var audioLevel: CGFloat
//    @Binding var isSessionActive: Bool
//
//    let sendAction: () -> Void
//    let recordAction: () -> Void
//
//    var body: some View {
//        VStack(spacing: 5) {
//            // Live Transcript / Input Field Placeholder
//            Text(isRecording ? (liveTranscript.isEmpty ? "Listening..." : liveTranscript) : "Type message or hold mic to talk...")
//                .font(.caption)
//                .foregroundColor(isRecording ? .yellow : .gray)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//                .lineLimit(1)
//
//            HStack {
//                // Text Field
//                TextField("Enter text", text: $inputText, axis: .vertical)
//                    .textFieldStyle(.plain)
//                    .padding(10)
//                    .background(Color(white: 0.15))
//                    .cornerRadius(18)
//                    .lineLimit(1...3)
//                    .opacity(isRecording ? 0.5 : 1.0) // Dim text field when recording
//                    .disabled(isRecording || !isSessionActive)
//
//                // Record Button
//                 Button(action: recordAction) {
//                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(isRecording ? .red : (isSessionActive ? .yellow : .gray))
//                }
//                 .disabled(!isSessionActive) // Disable if no active session
//
//                // Send Button (Only enable if not recording and text exists)
//                 Button(action: sendAction) {
//                    Image(systemName: "arrow.up.circle.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(isSessionActive && !inputText.isEmpty && !isRecording ? .yellow : .gray)
//                 }
//                 .disabled(inputText.isEmpty || isRecording || !isSessionActive)
//
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 8)
//             .padding(.top, 2)
//
//            // Audio Visualizer (Simple Bar)
//            AudioVisualizer(audioLevel: $audioLevel)
//                .frame(height: isRecording ? 15 : 0) // Only show when recording
//                .opacity(isRecording ? 1 : 0)
//                .padding(.bottom, 5)
//                 .animation(.easeInOut(duration: 0.1), value: isRecording)
//        }
//        .background(Color(white: 0.1))
//    }
//}
//
//// Simple Bar Visualizer
//struct AudioVisualizer: View {
//    @Binding var audioLevel: CGFloat // Expected range 0.0 to 1.0
//
//    var body: some View {
//        GeometryReader { geometry in
//            HStack(spacing: 1) {
//                // Create bars based on level
//                ForEach(0..<Int(geometry.size.width / 4), id: \.self) { index in
//                    let barHeight = max(1, geometry.size.height * CGFloat.random(in: 0.1...1.0) * audioLevel * (1.0 - CGFloat(index) / (geometry.size.width / 4))) // Taper off
//                    RoundedRectangle(cornerRadius: 1)
//                        .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .bottom, endPoint: .top))
//                        .frame(width: 2, height: barHeight)
//                }
//            }
//            .frame(height: geometry.size.height)
//            .clipped()
//             .drawingGroup() // Improve performance
//              .animation(.easeOut(duration: 0.05), value: audioLevel)
//        }
//    }
//}
//
//// MARK: - Audio Simulators (Replace with Actual AVFoundation Logic)
//
//class AudioRecorderSimulator {
//    var levelCallback: (CGFloat) -> Void
//    var transcriptCallback: (String, Bool) -> Void
//    var timer: Timer?
//    var transcriptTimer: Timer?
//    var counter = 0
//    let sampleTranscripts = ["Hel", "Hello ", "Hello world", "world this ", "this is ", "is a test", "a test."]
//
//    init(onLevelUpdate: @escaping (CGFloat) -> Void, onTranscript: @escaping (String, Bool) -> Void) {
//        self.levelCallback = onLevelUpdate
//        self.transcriptCallback = onTranscript
//    }
//
//    func start() {
//        stop() // Ensure clean start
//        counter = 0
//        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
//            self?.levelCallback(CGFloat.random(in: 0.1...0.8)) // Simulate fluctuating level
//        }
//        transcriptTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//             let index = Int.random(in: 0..<self.sampleTranscripts.count)
//             let isFinal = Bool.random() && (index == self.sampleTranscripts.count - 1) // Make final more likely at end
//            if index < self.sampleTranscripts.count {
//                self.transcriptCallback(self.sampleTranscripts[index], isFinal)
//            }
//            if isFinal {
//                 self.stop() // Stop simulating on final transcript
//            }
//        }
//    }
//
//    func stop() {
//        timer?.invalidate()
//        timer = nil
//        transcriptTimer?.invalidate()
//        transcriptTimer = nil
//        levelCallback(0.0) // Reset level
//        print("AudioRecorderSimulator stopped.")
//    }
//}
//
//class AudioPlayerSimulator {
//    var levelCallback: (CGFloat) -> Void
//    var timer: Timer?
//
//     init(onLevelUpdate: @escaping (CGFloat) -> Void) {
//         self.levelCallback = onLevelUpdate
//    }
//    
//    func playSimulated(duration: TimeInterval) {
//        stop()
//        print("AudioPlayerSimulator: Starting playback...")
//        let startTime = Date()
//        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] t in
//            let elapsed = Date().timeIntervalSince(startTime)
//            if elapsed >= duration {
//                self?.stop()
//                return
//            }
//            self?.levelCallback(CGFloat.random(in: 0.2...0.7) * CGFloat(1.0 - elapsed / duration) ) // Simulate level tapering off
//        }
//    }
//
//    func stop() {
//        timer?.invalidate()
//        timer = nil
//        levelCallback(0.0)
//         print("AudioPlayerSimulator: Playback stopped.")
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    // Use a simple container for preview
//    VStack {
//         ChatView()
//    }
//     .preferredColorScheme(.dark) // Ensure preview uses dark mode
//}
