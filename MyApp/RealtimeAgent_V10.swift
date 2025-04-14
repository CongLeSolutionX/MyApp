//
//  RealtimeAgent_V10.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import AVFoundation
import Speech

// MARK: - Define ChatService Protocol
protocol ChatServiceProtocol {
    func sendMessage(_ message: String) async throws -> String
}

// MARK: - Mock Chat Service (Local Testing)
struct MockChatService: ChatServiceProtocol {
    func sendMessage(_ message: String) async throws -> String {
        // Simple local mock response for quick testing
        ["Hello! How can I assist?",
         "That sounds interesting!",
         "Could you please clarify?",
         "Great point!",
         "Thank you!"].randomElement()!
    }
}

// MARK: - Live Chat Service (OpenAI Cloud API)
struct LiveChatService: ChatServiceProtocol {
    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    private let apiURL = URL(string:"https://api.openai.com/v1/chat/completions")!

    func sendMessage(_ message: String) async throws -> String {
        guard !apiKey.isEmpty else { throw URLError(.userAuthenticationRequired) }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "user", "content": message]],
            "temperature": 0.7
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        struct OpenAIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = decoded.choices.first?.message.content else {
            throw URLError(.cannotDecodeRawData)
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - ChatMessage Data Model
enum Sender { case user, gpt }

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: Sender
    let content: String
}

// MARK: - SpeechRecognition Service
final class SpeechService: NSObject, ObservableObject {
    @Published var transcript = ""
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()

    func startListening() throws {
        stopListening()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest, recognizer.isAvailable else { throw URLError(.resourceUnavailable) }

        request.shouldReportPartialResults = true
        let inputNode = audioEngine.inputNode

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, _ in
            guard let self = self, let result = result else { return }
            DispatchQueue.main.async {
                self.transcript = result.bestTranscription.formattedString
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { speechAuth in
                guard speechAuth == .authorized else {
                    continuation.resume(returning: false)
                    return
                }
                AVAudioSession.sharedInstance().requestRecordPermission { micAllowed in
                    continuation.resume(returning: micAllowed)
                }
            }
        }
    }
}

// MARK: - ViewModel with Mock/Live Toggle
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var loading = false
    @Published var isMockMode = true // ← Switch mode here (true for mock, false for live)
    let speechService = SpeechService()

    private var chatService: ChatServiceProtocol {
        isMockMode ? MockChatService() : LiveChatService()
    }

    func sendUserMessage(_ content: String) async {
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messages.append(.init(sender: .user, content: content))
        loading = true

        do {
            let response = try await chatService.sendMessage(content)
            messages.append(.init(sender: .gpt, content: response))
        } catch {
            messages.append(.init(sender: .gpt, content:"Error: \(error.localizedDescription)"))
        }

        loading = false
    }
}

// MARK: - SwiftUI View to Manage Chat
struct ContentView: View {
    @StateObject var vm = ChatViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                List(vm.messages) { msg in
                    HStack {
                        if msg.sender == .gpt {
                            Text("🤖 GPT")
                            Spacer()
                        }
                        Text(msg.content)
                        if msg.sender == .user {
                            Spacer()
                            Text("😊 You")
                        }
                    }
                }
                if vm.loading { ProgressView("Waiting for response...") }

                Text(vm.speechService.transcript)
                    .padding()

                HStack {
                    Button(vm.speechService.audioEngine.isRunning ? "🎤 Stop" : "🎤 Speak") {
                        Task { await toggleSpeechRecognition() }
                    }.buttonStyle(.bordered)

                    Spacer()

                    Button("🚀 Send") {
                        Task {
                            await vm.sendUserMessage(vm.speechService.transcript)
                            vm.speechService.transcript = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.speechService.transcript == "")
                }.padding()
            }
            .navigationTitle(vm.isMockMode ? "Chat GPT (Mock)" : "Chat GPT (Live)")
            .toolbar {
                Toggle(isOn: $vm.isMockMode.animation()) { Text("Mock Mode") }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            .task { _ = await vm.speechService.requestAuthorization() }
        }
    }

    private func toggleSpeechRecognition() async {
        if vm.speechService.audioEngine.isRunning {
            vm.speechService.stopListening()
        } else {
            try? vm.speechService.startListening()
        }
    }
}

// MARK: - SwiftUI Preview Provider
#Preview {
    ContentView()
        .environmentObject(ChatViewModel())
}
