//
//  SpeechRecognizerView.swift
//  MyApp
//
//  Created by Cong Le on 10/8/24.
//

import SwiftUI
import Speech

//// ViewModel for handling Speech Recognition logic
class SpeechRecognizerViewModel: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    
    private var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition authorization denied")
                case .restricted:
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    print("Speech recognition not authorized")
                @unknown default:
                    fatalError("Unknown authorization status")
                }
            }
        }
    }

    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session configured successfully.")
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create recognition request.")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0) // Remove any existing tap
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            DispatchQueue.main.async { [weak self] in
                self?.isRecording = true
            }
            print("Audio engine started successfully.")
        } catch {
            print("Audio engine start failure: \(error.localizedDescription)")
            return
        }

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognizer not available")
            stopRecording()
            return
        }
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.transcript = result.bestTranscription.formattedString
                }
            }
            
            if let error = error {
                print("Recognition error: \(error.localizedDescription)")
                self?.stopRecording()
                return
            }
            
            if result?.isFinal == true {
                self?.stopRecording()
                return
            }
            
        }
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        audioEngine.inputNode.removeTap(onBus: 0)
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}

struct SpeechRecognizerView_ContentView: View {
    @StateObject private var viewModel = SpeechRecognizerViewModel()
    
    var body: some View {
        VStack {
            Text("Speech to Text")
                .font(.largeTitle)
                .padding()

            Text(viewModel.transcript)
                .padding()
                .border(Color.gray, width: 1)
                .frame(height: 200)

            Button(action: {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }) {
                Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut, value: 0.2) // Smooth transition
            }
            .padding()
        }
        .onAppear {
            viewModel.requestAuthorization()
        }
    }
}

#Preview {
    SpeechRecognizerView_ContentView()
}
