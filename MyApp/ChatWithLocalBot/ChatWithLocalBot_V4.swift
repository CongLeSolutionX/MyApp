//
//  ChatWithLocalBot_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/24/25.
//

import SwiftUI
import Combine
import LLM // Your LLM framework
import Speech // For Speech Recognition
import AVFoundation // For Speech Synthesis (Text-to-Speech)

// --- Core AI Interaction Logic ---
// (Adapted to accept question as parameter)

func runDemoAIModel(question: String) async throws -> String {
    // System prompt might influence the tone, but the user question drives content
    let systemPrompt = "You are a helpful AI assistant who responds in Vietnamese."
    
    // WARNING: Force unwrapping LLM init with '!' is dangerous. Handle errors.
    // https://huggingface.co/arcee-ai/Arcee-VyLinh-GGUF
    // vylinh-3b-q8_0.gguf
    
    // Q8_0 (8-bit quantization) is relatively high quality but uses more memory than lower-bit quantizations.
    // Q4_K_M or Q4_0: These 4-bit quantizations significantly reduce memory usage, often with a minimal perceived impact on quality for many tasks.
    // Q5_K_M is another good option slightly larger than 4-bit.
    // Q3_K_M is even smaller but might show more quality degradation.

    let bot = try await LLM(from: HuggingFaceModel("arcee-ai/Arcee-VyLinh-GGUF", .Q4_K_M, template: .chatML(systemPrompt)))!
    
    let preparedQuestion = bot.preprocess(question, []) // Pass the transcribed question
    print("Sending Vietnamese question to AI: \(question)")
    let answer = await bot.getCompletion(from: preparedQuestion)
    print("Received Vietnamese answer: \(answer)")
    return answer
}

// Optional: Define a custom error for better handling
enum AIError: Error {
    case initializationFailed
    case processingError(String)
    case speechRecognitionError(String)
    case permissionDenied(String)
}

// --- SwiftUI Card View with Voice ---

struct AICardView: View {
    // --- State Variables Overall ---
    @State private var aiResponse: String? = nil
    @State private var userQuestion: String? = nil // Store the transcribed question
    @State private var isLoading: Bool = false // Covers both speech rec and AI processing
    @State private var errorMessage: String? = nil
    
    // --- State Variables for Speech Recognition ---
    @State private var isRecording: Bool = false
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN")) // Specify Vietnamese
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // --- State Variable for Text-to-Speech ---
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // --- UI Constants ---
    private let vietnameseLocale = Locale(identifier: "vi-VN")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // --- Card Header ---
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("Trợ lý AI Tiếng Việt") // Vietnamese Title
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Divider()
            
            // --- Content Area ---
            VStack(alignment: .leading, spacing: 10) {
                // Display User's Question (once transcribed)
                if let question = userQuestion {
                    Text("Bạn hỏi:") // "You asked:"
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(question)
                        .font(.body)
                    Spacer().frame(height: 10)
                } else if isRecording {
                    Text("Đang nghe...") // "Listening..."
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                // Display AI Response or Status
                if isLoading && !isRecording { // Show loading only during AI processing
                    HStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Đang xử lý...") // "Processing..."
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if let errorMsg = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Lỗi: \(errorMsg)") // "Error:"
                            .font(.callout)
                            .foregroundColor(.red)
                        Spacer()
                    }
                } else if let response = aiResponse {
                    Text("AI trả lời:") // "AI answered:"
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(response)
                        .font(.body)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if !isRecording && userQuestion == nil {
                    // Initial State
                    Text("Nhấn nút micro để hỏi.") // "Press the microphone button to ask."
                        .font(.callout)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 5)
            
            Spacer() // Pushes the button to the bottom
            
            // --- Action Button (Microphone) ---
            Button {
                toggleRecording()
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title) // Make mic bigger
                    Text(isRecording ? "Dừng lại" : "Hỏi AI") // "Stop" : "Ask AI"
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(isRecording ? .red : .purple) // Change color when recording
            .disabled(isLoading && !isRecording) // Disable only during AI processing, not recording
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .padding()
        .onAppear {
            requestSpeechAuthorization() // Request permission when view appears
        }
        // Stop audio resources if the view disappears
        .onDisappear {
            stopRecording() // Ensure recording stops if view is dismissed
            speechSynthesizer.stopSpeaking(at: .immediate) // Stop any ongoing speech
        }
    }
    
    // MARK: - Permission Handling
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized.")
                    // Enable mic button if needed (it's enabled by default)
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not authorized.")
                    self.errorMessage = "Cần cấp quyền nhận dạng giọng nói và micro trong Cài đặt." // "Need to grant speech rec and microphone permission in Settings."
                    // Consider disabling the mic button here
                @unknown default:
                    fatalError("Unknown speech recognition authorization status.")
                }
            }
        }
        
        // Also requesting microphone permission implicitly via AVAudioEngine setup,
        // but good practice to be aware of both permissions.
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            OperationQueue.main.addOperation {
                if !granted {
                    print("Microphone permission denied.")
                    self.errorMessage = "Cần cấp quyền micro trong Cài đặt." // "Need to grant microphone permission in Settings."
                }
            }
        }
    }
    
    // MARK: - Recording Control
    private func toggleRecording() {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            do {
                try startRecording()
            } catch let error as AIError {
                self.errorMessage = error.localizedDescription // Display specific AIError
            }
            catch {
                self.errorMessage = "Không thể bắt đầu ghi âm: \(error.localizedDescription)" // "Cannot start recording:"
            }
        }
        isRecording.toggle()
    }
    
    // MARK: - Speech Recognition (Speech-to-Text)
    private func startRecording() throws {
        // 0. Clear previous state
        errorMessage = nil
        aiResponse = nil
        userQuestion = "" // Reset question display
        
        // 1. Check recognizer availability
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw AIError.speechRecognitionError("Trình nhận dạng giọng nói không khả dụng cho Tiếng Việt.") // "Speech recognizer not available for Vietnamese."
        }
        
        // 2. Prepare Audio Session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // 3. Setup Recognition Request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw AIError.speechRecognitionError("Không thể tạo yêu cầu nhận dạng.") // "Cannot create recognition request."
        }
        recognitionRequest.shouldReportPartialResults = true // Get live transcription
        recognitionRequest.requiresOnDeviceRecognition = false // Use server-based for potentially better accuracy (requires internet)
        // Set requiresOnDeviceRecognition = true if offline is mandatory and supported for Vietnamese
        
        // 4. Setup Recognition Task
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            //            guard let self = self else { return }
            var isFinal = false
            
            if let result = result {
                let bestTranscription = result.bestTranscription.formattedString
                print("Partial Transcription: \(bestTranscription)")
                // Update the UI with the transcription
                DispatchQueue.main.async {
                    self.userQuestion = bestTranscription // Update live transcription
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                DispatchQueue.main.async {
                    print("Stopping audio engine and recognition task.")
                    self.audioEngine.stop()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    self.isRecording = false // Update button state
                    
                    // Deactivate audio session (optional, depends on app structure)
                    do {
                        try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                    } catch {
                        print("Failed to deactivate audio session: \(error)")
                    }
                    
                    if let error = error {
                        print("Recognition Error: \(error)")
                        self.errorMessage = "Lỗi nhận dạng: \(error.localizedDescription)" // "Recognition Error:"
                        self.isLoading = false // Stop loading indicator on error
                        self.userQuestion = nil // Clear question if recognition failed badly
                    } else if isFinal, let finalQuestion = self.userQuestion, !finalQuestion.isEmpty {
                        print("Final Transcription: \(finalQuestion)")
                        // Trigger AI call ONLY if we have a final, non-empty transcription
                        self.fetchAIResponse(question: finalQuestion)
                    } else if isFinal {
                        // Handle case where recording stopped but no text was recognized
                        self.isLoading = false
                        self.userQuestion = nil
                        self.errorMessage = "Không nhận dạng được giọng nói." // "Could not recognize speech."
                    }
                }
            }
        }
        
        // 5. Configure Audio Engine Input
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        // Check if format is valid
        guard recordingFormat.sampleRate > 0 else {
            throw AIError.speechRecognitionError("Định dạng âm thanh đầu vào không hợp lệ.")//"Invalid input audio format."
        }
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // 6. Start Audio Engine
        audioEngine.prepare()
        try audioEngine.start()
        
        print("Audio engine started for recording.")
    }
    
    private func stopRecording() {
        if audioEngine.isRunning {
            print("Manually stopping recording.")
            recognitionRequest?.endAudio() // Signal end of audio stream
            // Task completion handler will stop the engine and task itself
        }
        // Ensure state reflects stopped recording even if task handler is delayed
        isRecording = false
    }
    
    // MARK: - AI Interaction
    private func fetchAIResponse(question: String) {
        guard !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Ignoring empty question.")
            return
        }
        
        isLoading = true
        aiResponse = nil
        errorMessage = nil
        self.userQuestion = question // Ensure final question is displayed
        
        Task {
            do {
                let response = try await runDemoAIModel(question: question)
                // Update state on the main thread
                await MainActor.run {
                    self.aiResponse = response
                    self.isLoading = false
                    speak(response) // Speak the response after receiving it
                }
            } catch {
                print("Caught AI error: \(error)")
                await MainActor.run {
                    // Provide a user-friendly error message
                    if let aiErr = error as? AIError {
                        switch aiErr {
                        case .initializationFailed: self.errorMessage = "Lỗi khởi tạo mô hình AI." //"Failed to initialize AI model."
                        case .processingError(let msg): self.errorMessage = "Lỗi xử lý AI: \(msg)" //"AI Processing error:"
                        case .speechRecognitionError(let msg): self.errorMessage = "Lỗi nhận dạng: \(msg)" //"Recognition Error:"
                        case .permissionDenied(let msg): self.errorMessage = msg // Permissions already specific
                        }
                    } else {
                        self.errorMessage = "Lỗi AI không xác định: \(error.localizedDescription)" //"Unknown AI Error:"
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Text-to-Speech
    private func speak(_ text: String) {
        guard !text.isEmpty else { return }
        
        do {
            // Ensure audio session category allows playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let utterance = AVSpeechUtterance(string: text)
            
            // Find a Vietnamese voice
            let vietnameseVoice = AVSpeechSynthesisVoice(language: "vi-VN")
            utterance.voice = vietnameseVoice ?? AVSpeechSynthesisVoice(language: Locale.current.language.languageCode?.identifier) // Fallback to current locale if Vietnamese isn't available
            
            // Adjust speech rate or pitch if desired
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 1.0
            
            speechSynthesizer.speak(utterance)
            print("Attempting to speak: \(text)")
            
        } catch {
            print("Error setting up audio session for playback: \(error)")
            // Optionally show an error to the user that speech output failed
            self.errorMessage = "Không thể phát âm thanh trả lời." // "Cannot play back audio response."
        }
    }
}

// --- SwiftUI Previews ---
struct AICardView_Previews: PreviewProvider {
    static var previews: some View {
        AICardView()
            .padding()
            .background(Color(.systemGroupedBackground))
    }
}

// --- Extension for Localized Description of AIError (Optional) ---
extension AIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .initializationFailed:
            return "Không thể khởi tạo mô hình AI." // "Failed to initialize AI model."
        case .processingError(let message):
            return "Lỗi xử lý AI: \(message)" // "AI Processing Error:"
        case .speechRecognitionError(let message):
            return "Lỗi nhận dạng giọng nói: \(message)" // "Speech Recognition Error:"
        case .permissionDenied(let message):
            return "Quyền bị từ chối: \(message)" // "Permission Denied:"
        }
    }
}
