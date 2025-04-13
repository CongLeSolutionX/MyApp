////
////  RealtimeAgent_V5.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import SwiftUI
//import Combine
//import Speech
//import AVFoundation
//
//// MARK: - Model Layer
//
//struct VoiceNote: Identifiable {
//    let id = UUID()
//    let date: Date
//    let text: String
//}
//
//enum SessionStatus: String, CaseIterable {
//    case active, expired, connecting, disconnected
//    
//    var color: Color {
//        switch self {
//        case .active: .green
//        case .expired, .disconnected: .red
//        case .connecting: .yellow
//        }
//    }
//}
//
//struct UserSession: Identifiable {
//    let id: UUID
//    let title: String
//    let detail: String
//    var status: SessionStatus
//    var notes: [VoiceNote]
//    
//    static func mockSessions() -> [UserSession] {
//        [
//            UserSession(id: UUID(), title: "Brainstorm Session", detail: "Ideation and project scope discussion.", status: .active, notes: []),
//            UserSession(id: UUID(), title: "Team Sync", detail: "Daily stand-up with team members.", status: .connecting, notes: []),
//            UserSession(id: UUID(), title: "Customer Interview", detail: "Insights from user behavior.", status: .expired, notes: [])
//        ]
//    }
//}
//
//// MARK: - ViewModel Layer
//
//class AppViewModel: ObservableObject {
//    @Published var sessions: [UserSession] = UserSession.mockSessions()
//    @Published var selectedSession: UserSession?
//    
//    func updateSessionStatus(sessionId: UUID, status: SessionStatus) {
//        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
//            sessions[index].status = status
//        }
//    }
//    
//    func addNote(toSession sessionId: UUID, text: String) {
//        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
//            let note = VoiceNote(date: Date(), text: text)
//            sessions[index].notes.append(note)
//        }
//    }
//}
//
//class SpeechRecognizer: ObservableObject {
//    @Published var transcript = ""
//    @Published var isRecording = false
//    @Published var recognitionEnabled = false
//    @Published var statusMessage = "Tap to speak"
//    
//    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let engine = AVAudioEngine()
//
//    func authorize() {
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            DispatchQueue.main.async {
//                self.recognitionEnabled = (authStatus == .authorized)
//                self.statusMessage = authStatus == .authorized ? "Ready to recognize speech" : "Speech recognition denied"
//            }
//        }
//    }
//    
//    func startRecording() {
//        guard recognitionEnabled else {
//            statusMessage = "Not Authorized"
//            return
//        }
//        
//        reset()
//        
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let inputNode = engine.inputNode else { return }
//        guard let recognitionRequest else { return }
//
//        recognitionRequest.shouldReportPartialResults = true
//        
//        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
//            if let result = result {
//                self.transcript = result.bestTranscription.formattedString
//            }
//            if error != nil || result?.isFinal == true {
//                self.stopRecording()
//            }
//        })
//
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
//            recognitionRequest.append(buffer)
//        }
//        
//        try? AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
//        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
//        
//        engine.prepare()
//        try? engine.start()
//        
//        isRecording = true
//        statusMessage = "Listening..."
//    }
//    
//    func stopRecording() {
//        engine.stop()
//        recognitionRequest?.endAudio()
//        engine.inputNode.removeTap(onBus: 0)
//        
//        isRecording = false
//        statusMessage = "Tap to speak"
//    }
//    
//    func reset() {
//        recognitionTask?.cancel()
//        self.transcript = ""
//        recognitionTask = nil
//        recognitionRequest = nil
//    }
//}
//
//// MARK: - View Layer
//
//struct ContentView: View {
//    @StateObject var viewModel = AppViewModel()
//    @StateObject var speechRecognizer = SpeechRecognizer()
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(viewModel.sessions) { session in
//                    SessionRow(session: session)
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            viewModel.selectedSession = session
//                        }
//                }
//            }
//            .navigationTitle("Sessions")
//            .sheet(item: $viewModel.selectedSession) { session in
//                SessionDetailView(session: session, appViewModel: viewModel, speechRecognizer: speechRecognizer)
//            }
//            .onAppear {
//                speechRecognizer.authorize()
//            }
//        }
//    }
//}
//
//struct SessionRow: View {
//    let session: UserSession
//
//    var body: some View {
//        HStack {
//            Circle()
//                .fill(session.status.color)
//                .frame(width: 12, height: 12)
//
//            VStack(alignment: .leading) {
//                Text(session.title).font(.headline)
//                Text(session.detail).font(.caption).foregroundColor(.gray)
//            }
//        }
//    }
//}
//
//struct SessionDetailView: View {
//    let session: UserSession
//    @ObservedObject var appViewModel: AppViewModel
//    @ObservedObject var speechRecognizer: SpeechRecognizer
//
//    var body: some View {
//        VStack {
//            Text("Session: \(session.title)")
//                .font(.title.bold())
//                .padding()
//
//            List(session.notes) { note in
//                VStack(alignment: .leading) {
//                    Text(note.text)
//                    Text(note.date, style: .time).foregroundColor(.gray).font(.caption)
//                }
//            }
//
//            Spacer()
//
//            Text(speechRecognizer.transcript)
//                .padding()
//                .multilineTextAlignment(.center)
//
//            Button(action: {
//                speechRecognizer.isRecording ? speechRecognizer.stopRecording() : speechRecognizer.startRecording()
//            }, label: {
//                Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle")
//                    .resizable()
//                    .foregroundColor(speechRecognizer.isRecording ? .red : .blue)
//                    .frame(width: 60, height: 60)
//            }).padding()
//
//            Button("Save Note", action: {
//                appViewModel.addNote(toSession: session.id, text: speechRecognizer.transcript)
//                speechRecognizer.reset()
//            })
//            .disabled(speechRecognizer.transcript.isEmpty)
//
//            Spacer()
//        }
//    }
//}
//
//@main
//struct OptimizedSwiftApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
