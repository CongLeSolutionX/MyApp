////
////  RealtimeAgent_V9.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import SwiftUI
//import Speech
//import AVFoundation
//
//// MARK: - Secure API Key Management
//let openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
//
//// MARK: - Chat Models
//enum Sender {
//    case user, gpt
//}
//
//struct ChatMessage: Identifiable {
//    let id = UUID()
//    let sender: Sender
//    let content: String
//    let timestamp: Date = Date()
//}
//
//// MARK: - OpenAI API Models
//struct OpenAIResponse: Decodable {
//    struct Choice: Decodable {
//        struct Message: Decodable {
//            let role: String
//            let content: String
//        }
//        let message: Message
//    }
//    let choices: [Choice]
//}
//
//// MARK: - OpenAIService with Robust Networking
//struct OpenAIService {
//    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
//    
//    func sendMessage(_ message: String) async throws -> String {
//        guard !openAIKey.isEmpty else { throw URLError(.userAuthenticationRequired) }
//
//        var request = URLRequest(url: apiURL)
//        request.httpMethod = "POST"
//        request.addValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let requestBody: [String: Any] = [
//            "model": "gpt-4",
//            "messages": [["role": "user", "content": message]],
//            "temperature": 0.8
//        ]
//        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
//            throw URLError(.badServerResponse)
//        }
//
//        let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
//
//        guard let content = decodedResponse.choices.first?.message.content else {
//            throw URLError(.cannotDecodeRawData)
//        }
//
//        return content.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//}
//
//// MARK: - Speech Service Improvements
//final class SpeechService: NSObject, ObservableObject {
//    @Published var transcript = ""
//    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
//    let audioEngine = AVAudioEngine()
//    private var request: SFSpeechAudioBufferRecognitionRequest?
//    private var task: SFSpeechRecognitionTask?
//
//    func startListening() throws {
//        stopListening() // Ensure clean state first
//
//        request = SFSpeechAudioBufferRecognitionRequest()
//        guard let request = request, recognizer.isAvailable else {
//            throw URLError(.resourceUnavailable)
//        }
//
//        let inputNode = audioEngine.inputNode
//        request.shouldReportPartialResults = true
//
//        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
//            guard let self = self else { return }
//
//            if let result = result {
//                DispatchQueue.main.async {
//                    self.transcript = result.bestTranscription.formattedString
//                }
//            }
//
//            if result?.isFinal == true || error != nil {
//                self.stopListening()
//            }
//        }
//
//        inputNode.removeTap(onBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { buffer, _ in
//            request.append(buffer)
//        }
//
//        audioEngine.prepare()
//        try audioEngine.start()
//    }
//
//    func stopListening() {
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            audioEngine.inputNode.removeTap(onBus: 0)
//            request?.endAudio()
//            task?.cancel()
//            task = nil
//            request = nil
//        }
//    }
//
//    func requestAuthorization() async -> Bool {
//        await withCheckedContinuation { continuation in
//            SFSpeechRecognizer.requestAuthorization { speechAuth in
//                guard speechAuth == .authorized else {
//                    print("Speech authorization denied.")
//                    continuation.resume(returning: false)
//                    return
//                }
//                AVAudioSession.sharedInstance().requestRecordPermission { allowed in
//                    if !allowed { print("Microphone access denied.") }
//                    continuation.resume(returning: allowed)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - ViewModel Improvements
//@MainActor
//final class ChatViewModel: ObservableObject {
//    @Published var chatMessages: [ChatMessage] = []
//    @Published var isLoading = false
//    private let openAIService = OpenAIService()
//    let speechService = SpeechService()
//
//    func sendUserMessage(_ text: String) async {
//        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
//
//        chatMessages.append(ChatMessage(sender: .user, content: text))
//        isLoading = true
//
//        do {
//            let gptResponse = try await openAIService.sendMessage(text)
//            chatMessages.append(ChatMessage(sender: .gpt, content: gptResponse))
//        } catch is URLError {
//            chatMessages.append(ChatMessage(sender: .gpt, content: "Connection issue. Ensure your internet is connected and try again."))
//        } catch {
//            chatMessages.append(ChatMessage(sender: .gpt, content: "An unexpected error occurred. Please try again later."))
//        }
//
//        isLoading = false
//    }
//}
//
//// MARK: - SwiftUI View with Enhanced UX/UI
//struct ContentView: View {
//    @StateObject private var vm = ChatViewModel()
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                List(vm.chatMessages) { message in
//                    HStack {
//                        if message.sender == .gpt {
//                            Text("🤖 GPT")
//                            Spacer()
//                        }
//                        Text(message.content)
//                            .multilineTextAlignment(message.sender == .user ? .trailing : .leading)
//                        if message.sender == .user {
//                            Spacer()
//                            Text("😊 You")
//                        }
//                    }
//                }
//
//                if vm.isLoading {
//                    ProgressView("Waiting for GPT...")
//                        .padding()
//                }
//
//                VStack {
//                    Text(vm.speechService.transcript.isEmpty ? "Tap Mic and Speak" : vm.speechService.transcript)
//                        .padding(.horizontal)
//                        .foregroundColor(.primary)
//
//                    HStack {
//                        Button(vm.speechService.audioEngine.isRunning ? "Stop 🎙️" : "Speak 🎤") {
//                            Task { await toggleListening() }
//                        }
//                        .disabled(vm.isLoading)
//
//                        Spacer()
//
//                        Button("Send 📤") {
//                            Task {
//                                await vm.sendUserMessage(vm.speechService.transcript)
//                                vm.speechService.transcript = ""
//                            }
//                        }
//                        .disabled(vm.speechService.transcript.isEmpty || vm.isLoading)
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Live GPT Chat")
//            .task { _ = await vm.speechService.requestAuthorization() }
//        }
//    }
//
//    private func toggleListening() async {
//        if vm.speechService.audioEngine.isRunning {
//            vm.speechService.stopListening()
//        } else {
//            do {
//                try vm.speechService.startListening()
//            } catch {
//                print("Audio input error: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//// MARK: - SwiftUI Preview
//#Preview {
//    ContentView()
//        .environmentObject(ChatViewModel())
//}
