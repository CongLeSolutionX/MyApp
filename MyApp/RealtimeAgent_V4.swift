////
////  RealtimeAgent_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import SwiftUI
//import AVFoundation
//import Speech
//import Combine
//
//// MARK: - MODELS
//
//enum SessionStatus: String, CaseIterable {
//    case active, expired, connecting, error
//    
//    var icon: String {
//        switch self {
//        case .active: "checkmark.circle.fill"
//        case .expired: "xmark.circle.fill"
//        case .connecting: "hourglass.circle"
//        case .error: "exclamationmark.triangle.fill"
//        }
//    }
//    
//    var color: Color {
//        switch self {
//        case .active: .green
//        case .expired: .gray
//        case .connecting: .orange
//        case .error: .red
//        }
//    }
//}
//
//struct RealtimeSessionInfo: Identifiable {
//    let id = UUID()
//    let sessionId: String
//    let model: String
//    let modalities: [String]
//    let instructions: String
//    let voice: String
//    let clientSecretExpiresAt: Date?
//    let creationDate: Date
//    var status: SessionStatus
//    
//    var isExpired: Bool {
//        guard let expiry = clientSecretExpiresAt else { return false }
//        return expiry < Date()
//    }
//    
//    static func mockSessions(count: Int = 5) -> [RealtimeSessionInfo] {
//        (0..<count).map { _ in
//            RealtimeSessionInfo(
//                sessionId: UUID().uuidString.prefix(16).lowercased(),
//                model: ["gpt-4", "custom-model"].randomElement()!,
//                modalities: ["Text", "Audio"],
//                instructions: "You are a helpful assistant.",
//                voice: "echo",
//                clientSecretExpiresAt: Date().addingTimeInterval(3600),
//                creationDate: Date(),
//                status: [.active, .connecting, .expired, .error].randomElement()!
//            )
//        }
//    }
//}
//
//// MARK: - VIEW MODEL
//
//protocol SpeechCommandHandler {
//    func processVoiceCommand(_ command: String)
//}
//
//@MainActor
//class SpeechRecognitionViewModel: ObservableObject {
//    @Published var isListening = false
//    @Published var transcribedText: String = ""
//    @Published var statusMessage: String = "Tap mic to speak."
//    @Published var micLevel: Float = 0.0
//    @Published var hasError: Bool = false
//    
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine()
//    private let audioSession = AVAudioSession.sharedInstance()
//    private var inputNode: AVAudioInputNode?
//    var commandHandler: SpeechCommandHandler?
//    
//    init() {
//        speechRecognizer?.delegate = self
//        requestAuthorization()
//    }
//    
//    func requestAuthorization() {
//        SFSpeechRecognizer.requestAuthorization { status in
//            DispatchQueue.main.async {
//                self.hasError = (status != .authorized)
//            }
//        }
//        
//        audioSession.requestRecordPermission { allowed in
//            DispatchQueue.main.async {
//                self.hasError = self.hasError || !allowed
//            }
//        }
//    }
//    
//    func toggleListening() {
//        audioEngine.isRunning ? stopListening() : startListening()
//    }
//    
//    func startListening() {
//        resetRecognitionTask()
//        configureAudioSession()
//        
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        recognitionRequest?.shouldReportPartialResults = true
//        
//        self.inputNode = audioEngine.inputNode
//        guard let inputNode else { return }
//        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
//            if let result = result {
//                self.transcribedText = result.bestTranscription.formattedString
//            }
//            
//            if error != nil || result?.isFinal == true {
//                self.stopListening()
//                if let finalizedText = result?.bestTranscription.formattedString {
//                    self.commandHandler?.processVoiceCommand(finalizedText)
//                }
//            }
//        }
//        
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { buffer, _ in
//            self.recognitionRequest?.append(buffer)
//        }
//        
//        audioEngine.prepare()
//        try? audioEngine.start()
//        isListening = true
//        statusMessage = "Listening..."
//    }
//    
//    func stopListening() {
//        audioEngine.stop()
//        recognitionRequest?.endAudio()
//        inputNode?.removeTap(onBus: 0)
//        isListening = false
//        statusMessage = "Stopped."
//    }
//    
//    private func resetRecognitionTask() {
//        recognitionTask?.cancel()
//        recognitionTask = nil
//    }
//    
//    private func configureAudioSession() {
//        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//    }
//}
//
//extension SpeechRecognitionViewModel: SFSpeechRecognizerDelegate {
//    nonisolated func isEqual(_ object: Any?) -> Bool {
//        return true
//    }
//    
//    var hash: Int {
//        return 0
//    }
//    
//    var superclass: AnyClass? {
//        return nil
//    }
//    
//    nonisolated func `self`() -> Self {
//        return self
//    }
//    
//    nonisolated func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    nonisolated func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    nonisolated func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    nonisolated func isProxy() -> Bool {
//        return true
//    }
//    
//    nonisolated func isKind(of aClass: AnyClass) -> Bool {
//        return true
//    }
//    
//    nonisolated func isMember(of aClass: AnyClass) -> Bool {
//        return true
//    }
//    
//    nonisolated func conforms(to aProtocol: Protocol) -> Bool {
//        return true
//    }
//    
//    nonisolated func responds(to aSelector: Selector!) -> Bool {
//        return true
//    }
//    
//    var description: String {
//        return ""
//    }
//    
//    nonisolated func speechRecognizer(_ recognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        Task { @MainActor in
//            self.hasError = !available
//            self.statusMessage = available ? "Speech recognition ready." : "Currently unavailable."
//            if !available && self.isListening { stopListening() }
//        }
//    }
//}
//
//// MARK: - REUSABLE COMPONENTS
//
//struct InfoRow<T: View>: View {
//    let label: String, value: String
//    @ViewBuilder var trailingContent: T
//    var body: some View {
//        HStack {
//            Text("\(label):").font(.caption.bold()).frame(width: 80, alignment: .leading)
//            Text(value).font(.caption)
//            Spacer()
//            trailingContent
//        }
//    }
//}
//
//struct CopyButton: View {
//    let text: String
//    var body: some View {
//        Button { UIPasteboard.general.string = text } label: {
//            Image(systemName: "doc.on.doc")
//        }
//    }
//}
//
//// MARK: - VIEWS
//
//struct VoiceInputView: View {
//    @ObservedObject var vm: SpeechRecognitionViewModel
//    var body: some View {
//        VStack {
//            Text(vm.transcribedText.isEmpty ? vm.statusMessage : vm.transcribedText)
//                .multilineTextAlignment(.center).padding()
//            
//            Button(action: vm.toggleListening) {
//                Image(systemName: vm.isListening ? "mic.circle.fill" : "mic.slash.circle.fill")
//                    .resizable().frame(width: 50, height: 50)
//                    .foregroundColor(vm.isListening ? .red : .gray)
//            }
//        }
//    }
//}
//
//#Preview("VoiceInputView"){
//    VoiceInputView(vm: SpeechRecognitionViewModel())
//}
//
//struct SessionDetailView: View {
//    let session: RealtimeSessionInfo
//    var body: some View {
//        List {
//            InfoRow(label: "Session", value: session.sessionId) { CopyButton(text: session.sessionId) }
//            InfoRow(label: "Status", value: session.status.rawValue.capitalized) { Image(systemName: session.status.icon).foregroundColor(session.status.color) }
//            InfoRow(label: "Model", value: session.model) { EmptyView() }
//        }
//        .navigationTitle("Details")
//    }
//}
//#Preview("SessionDetailView"){
//    SessionDetailView(session: RealtimeSessionInfo(sessionId: <#T##String#>, model: <#T##String#>, modalities: <#T##[String]#>, instructions: <#T##String#>, voice: <#T##String#>, creationDate: <#T##Date#>, status: <#T##SessionStatus#>))
//}
//
//struct ContentView: View, SpeechCommandHandler {
//    @State private var sessions = RealtimeSessionInfo.mockSessions()
//    @StateObject private var speechVM = SpeechRecognitionViewModel()
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                List(sessions) { sess in
//                    NavigationLink(destination: SessionDetailView(session: sess)) {
//                        Text(sess.sessionId)
//                    }
//                }
//                VoiceInputView(vm: speechVM).padding()
//            }.onAppear { speechVM.commandHandler = self }
//        }
//    }
//    
//    func processVoiceCommand(_ command: String) {
//        if command.lowercased().contains("refresh") {
//            sessions = RealtimeSessionInfo.mockSessions()
//        } else if command.lowercased().contains("clear all") {
//            sessions = []
//        }
//    }
//}
//#Preview("ContentView"){
//    ContentView()
//}
////
////@main
////struct OptimizedApp: App {
////    var body: some Scene {
////        WindowGroup { ContentView() }
////    }
////}
