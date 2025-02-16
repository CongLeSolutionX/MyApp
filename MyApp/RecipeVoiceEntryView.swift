//
//  RecipeVoiceEntryView.swift
//  MyApp
//
//  Created by Cong Le on 2/16/25.
//
import SwiftUI
import AVFoundation
import OpenAI
import Combine

// MARK: - Enums & Protocols

enum VoiceState {
    case idle
    case recording
    case processing
//    case error(Error)
}

protocol AudioRecorderDelegate: AnyObject {
    func didFinishRecording(audioURL: URL)
    func didFailRecording(with error: Error)
}

// MARK: - AudioRecorderManager

class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private let audioFileName = "audioRecording.m4a"
    private let audioFileURL: URL = {
        FileManager.default.temporaryDirectory.appendingPathComponent("audioRecording.m4a")
    }()

    weak var delegate: AudioRecorderDelegate?

    func startRecording() throws {
        guard audioRecorder == nil else { throw NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Already recording"]) }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }

    func deleteAudio() {
        try? FileManager.default.removeItem(at: audioFileURL)
    }

    func getAudioData() -> Data? {
        return try? Data(contentsOf: audioFileURL)
    }

    // MARK: AVAudioRecorderDelegate Methods

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            delegate?.didFinishRecording(audioURL: recorder.url)
        } else {
            delegate?.didFailRecording(with: NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording failed."]))
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            delegate?.didFailRecording(with: error)
        } else {
            delegate?.didFailRecording(with: NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Encoding failed with unknown error."]))
        }
    }
}

// MARK: - TranscriptionManager

class TranscriptionManager: ObservableObject {
    private let openAI: OpenAI

    init(apiToken: String) {
        self.openAI = OpenAI(configuration: .init(token: apiToken, timeoutInterval: 700))
    }

    func transcribe(audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let query = AudioTranscriptionQuery(
            file: audioData,
            fileType: .m4a,
            model: .whisper_1,
            prompt: "N/A" // You can customize the prompt here if needed
        )

        openAI.audioTranscriptions(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transcriptionResult):
                    completion(.success(transcriptionResult.text))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - SpeechManager

class SpeechManager: ObservableObject, AudioRecorderDelegate {
    private let audioRecorder: AudioRecorderManager
    private let transcriptionManager: TranscriptionManager

    @Published var state: VoiceState = .idle
    @Published var transcription: String = "" // Initialized as empty string
    @Published var errorMessage: String?

    init(audioRecorder: AudioRecorderManager, transcriptionManager: TranscriptionManager) {
        self.audioRecorder = audioRecorder
        self.transcriptionManager = transcriptionManager
        self.audioRecorder.delegate = self
    }

    func startRecording() {
        do {
            try audioRecorder.startRecording()
            state = .recording
            transcription = "" // Clear previous transcription when starting to record again
            errorMessage = nil // Clear any previous error message
        } catch {
            handleError(error)
        }
    }

    func stopRecording() {
        audioRecorder.stopRecording()
        state = .processing
    }

    func processRecording() {
        guard let audioData = audioRecorder.getAudioData() else {
            handleError(NSError(domain: "SpeechManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Audio data not available"]))
            return
        }

        transcriptionManager.transcribe(audioData: audioData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    self?.transcription = text
                    self?.state = .idle
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }

        audioRecorder.deleteAudio()
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
//        state = .error()
        print("error here for now")
        transcription = "" // Clear transcription on error
    }

    // MARK: AudioRecorderDelegate Methods

    func didFinishRecording(audioURL: URL) {
        processRecording()
    }

    func didFailRecording(with error: Error) {
        handleError(error)
    }
}

// MARK: - SwiftUI Views

struct RecipeVoiceEntryView: View {
    @StateObject var speechManager: SpeechManager
    @State private var isRecording = false
    var onSubmit: () -> Void

    init(apiKey: String, onSubmit: @escaping () -> Void) {
        _speechManager = StateObject(wrappedValue: SpeechManager(audioRecorder: AudioRecorderManager(), transcriptionManager: TranscriptionManager(apiToken: apiKey)))
        self.onSubmit = onSubmit
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Describe Your Thoughts")
                    .font(.system(.title2, weight: .bold))

                if !speechManager.transcription.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(speechManager.transcription)
                            .font(.system(.subheadline, weight: .regular))
                            .multilineTextAlignment(.leading)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading) // Use frame instead of .infiniteWidth
                    .background(Color.gray.opacity(0.2)) // Use opacity for surfaceGray
                    .cornerRadius(4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: speechManager.transcription)
                }

                if let errorMessage = speechManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding([.horizontal, .top], 16)
        }
        .safeAreaInset(edge: .bottom) {
            SpeechRecorderView(speechManager: speechManager) {
                onSubmit()
            }
            .padding(16)
        }
    }
}

struct SpeechRecorderView: View {
    @ObservedObject var speechManager: SpeechManager
    var onSubmit: () -> Void

    var body: some View {
        HStack {
            Spacer()
            recordingButton()
            Spacer()
        }
    }

    private func recordingButton() -> some View {
        Button(action: {
            if speechManager.state == .idle || speechManager.state == .error {
                speechManager.startRecording()
            } else if speechManager.state == .recording {
                speechManager.stopRecording()
                onSubmit() // Call onSubmit action when recording is stopped
            }
        }) {
            Image(systemName: buttonImageName)
                .font(.system(size: 24))
                .padding()
                .background(buttonBackgroundColor)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
    }

    private var buttonImageName: String {
        switch speechManager.state {
        case .idle, .error:
            return "mic.fill"
        case .recording:
            return "stop.fill"
        case .processing, .returning:
            return "hourglass" // Indicate processing state
        }
    }

    private var buttonBackgroundColor: Color {
        switch speechManager.state {
        case .idle, .error:
            return .blue
        case .recording:
            return .red
        case .processing, .returning:
            return .orange // Indicate processing state
        }
    }
}


// MARK: - Preview

struct RecipeVoiceEntryView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeVoiceEntryView(apiKey: "YOUR_API_TOKEN_HERE") {
            print("Submit Action Triggered")
        }
    }
}

