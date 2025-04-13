//
//  RealtimeAgent_V7.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI
import Foundation
import Speech
import AVFoundation

enum Sender {
    case user, gpt
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: Sender
    let content: String
    let timestamp: Date = Date()
}

struct OpenAIService {
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let apiKey = "YOUR_API_KEY"

    func sendMessage(_ message: String) async throws -> String {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "user", "content": message]],
            "temperature": 0.8
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: json)

        let (data, _) = try await URLSession.shared.data(for: request)
        let responseJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let choices = responseJSON?["choices"] as? [[String: Any]],
              let messageDict = choices.first?["message"] as? [String: Any],
              let content = messageDict["content"] as? String else {
            throw URLError(.badServerResponse)
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

final class SpeechService: NSObject, ObservableObject {
    @Published var transcript = ""
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    // Updated async permission request compatible with iOS 17+
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            // Request Speech Authorization
            SFSpeechRecognizer.requestAuthorization { speechStatus in
                guard speechStatus == .authorized else {
                    print("Speech authorization denied.")
                    continuation.resume(returning: false)
                    return
                }
                // Request Microphone Recording Authorization
                if #available(iOS 17.0, *) {
                    AVAudioApplication.requestRecordPermission { allowed in
                        continuation.resume(returning: allowed)
                    }
                } else {
                    // Fallback on earlier versions
                    AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                        continuation.resume(returning: allowed)
                    }
                }
            }
        }
    }

    func startListening() throws {
        if audioEngine.isRunning { return }
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request else { return }

        let inputNode = audioEngine.inputNode
        request.shouldReportPartialResults = true

        task = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopListening()
            }
        }

        audioEngine.prepare()
        try audioEngine.start()

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { buffer, _ in
            request.append(buffer)
        }
    }

    func stopListening() {
        audioEngine.stop()
        request?.endAudio()
        task?.cancel()
        task = nil
    }
}
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var chatMessages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    let openAIService = OpenAIService()
    let speechService = SpeechService()

    func sendUserMessage(_ text: String) async {
        guard !text.isEmpty else { return }
        chatMessages.append(ChatMessage(sender: .user, content: text))
        isLoading = true

        do {
            let gptResponse = try await openAIService.sendMessage(text)
            chatMessages.append(ChatMessage(sender: .gpt, content: gptResponse))
        } catch {
            chatMessages.append(ChatMessage(sender: .gpt, content: "Sorry, something went wrong. Try again."))
        }
        isLoading = false
    }
}


struct ContentView: View {
    @StateObject private var vm = ChatViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                List(vm.chatMessages) { message in
                    HStack {
                        if message.sender == .gpt {
                            Text("🤖 GPT")
                            Spacer()
                        }
                        Text(message.content)
                            .multilineTextAlignment(message.sender == .user ? .trailing : .leading)
                        if message.sender == .user {
                            Spacer()
                            Text("😊 You")
                        }
                    }
                }

                VStack {
                    Text(vm.speechService.transcript.isEmpty ? "Tap Mic and Speak" : vm.speechService.transcript)
                        .padding()
                        .foregroundColor(.primary)

                    HStack {
                        Button(vm.speechService.audioEngine.isRunning ? "Stop 🎙️" : "Speak 🎤") {
                            Task { await toggleListening() }
                        }
                        .disabled(vm.isLoading)
                        Spacer()
                        Button("Send 📤") {
                            Task { await vm.sendUserMessage(vm.speechService.transcript) }
                            vm.speechService.transcript = ""
                        }
                        .disabled(vm.speechService.transcript.isEmpty || vm.isLoading)
                    }
                    .padding()
                }
            }
            .navigationTitle("Live GPT Chat")
            .task { _ = await vm.speechService.requestAuthorization() }
        }
    }

    func toggleListening() async {
        if vm.speechService.audioEngine.isRunning {
            vm.speechService.stopListening()
        } else {
            do {
                try vm.speechService.startListening()
            } catch {
                print("Error starting speech: \(error.localizedDescription)")
            }
        }
    }
}

#Preview("ContentView") {
    ContentView()
}
