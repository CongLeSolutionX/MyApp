//
//  RealtimeAgent_V6.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import Combine
import Speech
import AVFoundation

// MARK: - Models

enum SessionStatus: String, CaseIterable {
    case active, expired, connecting, paused, error
    
    var icon: String {
        switch self {
        case .active: "checkmark.circle.fill"
        case .expired: "xmark.circle.fill"
        case .connecting: "ellipsis.circle.fill"
        case .paused: "pause.circle"
        case .error: "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .active: .green
        case .expired: .gray
        case .connecting: .yellow
        case .paused: .blue
        case .error: .red
        }
    }
}

struct Session: Identifiable {
    let id = UUID()
    let sessionId: String
    let model: String
    let creationDate: Date
    let status: SessionStatus
    
    static func mockSessions(count: Int = 10) -> [Session] {
        return (0..<count).map { _ in
            Session(sessionId: UUID().uuidString.prefix(8).uppercased(),
                    model: ["gpt-4", "gpt-3.5-turbo", "custom-model"].randomElement()!,
                    creationDate: Date().addingTimeInterval(-Double.random(in: 0...3600)),
                    status: SessionStatus.allCases.randomElement()!)
        }
    }
}

// MARK: - ViewModels

protocol SpeechCommandProtocol: AnyObject {
    func didReceiveVoiceCommand(_ command: String)
}

@MainActor
class AppViewModel: ObservableObject, @preconcurrency SpeechCommandProtocol {
    @Published var sessions: [Session] = Session.mockSessions()
    @Published var speechText: String = ""
    
    func refreshSessions() {
        sessions = Session.mockSessions()
    }

    func deleteExpiredSessions() {
        sessions.removeAll { $0.status == .expired }
    }

    func clearAllSessions() {
        sessions.removeAll()
    }
    
    func didReceiveVoiceCommand(_ command: String) {
        switch command.lowercased() {
        case let cmd where cmd.contains("refresh"):
            refreshSessions()
        case let cmd where cmd.contains("delete expired"):
            deleteExpiredSessions()
        case let cmd where cmd.contains("clear all"):
            clearAllSessions()
        default:
            speechText = "Command unknown: \(command)"
        }
    }
}

@MainActor
class SpeechRecognizerViewModel: ObservableObject {
    @Published var isListening: Bool = false
    @Published var transcript: String = ""
    private var speechTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    weak var delegate: SpeechCommandProtocol?

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: allowed && status == .authorized)
                }
            }
        }
    }
    
    func toggleListening() {
        Task {
            if isListening {
                stopListening()
            } else {
                if await requestAuthorization() {
                    startListening()
                }
            }
        }
    }
    
    private func startListening() {
        guard let recognizer, recognizer.isAvailable else { return }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        recognitionRequest?.taskHint = .dictation
        speechTask = recognizer.recognitionTask(with: recognitionRequest!) { result, error in
            if let result {
                self.transcript = result.bestTranscription.formattedString
            }
            if error != nil || result?.isFinal == true {
                self.stopListening()
                if let finalText = result?.bestTranscription.formattedString {
                    self.delegate?.didReceiveVoiceCommand(finalText)
                }
            }
        }
        
        let inputNode = audioEngine.inputNode
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        isListening = true
    }
    
    private func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        speechTask?.cancel()
        speechTask = nil
        isListening = false
    }
}

// MARK: - Views

struct ContentView: View {
    @StateObject private var appVM = AppViewModel()
    @StateObject private var speechVM = SpeechRecognizerViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Voice: \(speechVM.transcript.isEmpty ? "Tap mic to speak." : speechVM.transcript)")
                    .padding()
                    .foregroundStyle(.secondary)
                
                sessionList
                
                microphoneButton
            }
            .navigationTitle("Session Manager")
            .toolbar {
                refreshButton
            }
            .onAppear {
                speechVM.delegate = appVM
            }
        }
    }
    
    private var sessionList: some View {
        List {
            Section("Active Sessions") {
                ForEach(appVM.sessions) { session in
                    sessionCell(session)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func sessionCell(_ session: Session) -> some View {
        HStack {
            Image(systemName: session.status.icon)
                .foregroundStyle(session.status.color)
            VStack(alignment: .leading) {
                Text("Session ID: \(session.sessionId)")
                    .font(.headline)
                Text("Model: \(session.model)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(session.status.rawValue.capitalized)
                .foregroundStyle(session.status.color)
                .font(.subheadline)
        }
    }
    
    private var microphoneButton: some View {
        Button(action: speechVM.toggleListening) {
            Image(systemName: speechVM.isListening ? "mic.circle.fill" : "mic.slash.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(speechVM.isListening ? .red : .gray)
        }
        .padding()
        .accessibilityLabel(speechVM.isListening ? "Stop listening" : "Start listening")
    }
    
    private var refreshButton: some View {
        Button(action: appVM.refreshSessions) {
            Image(systemName: "arrow.clockwise.circle")
        }
        .accessibilityLabel("Refresh sessions")
    }
}

#Preview {
    ContentView()
}
// MARK: - App entry point
//
//@main
//struct OptimizediOSApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
