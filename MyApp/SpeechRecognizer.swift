//
//  SpeechRecognizer.swift
//  MyApp
//
//  Created by Cong Le on 10/7/24.
//

import Foundation
import AVFoundation
import Speech

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
actor SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        case unknownError(Error)
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            case .unknownError(let error): return "Unknown error: \(error.localizedDescription)"
            }
        }
    }
        private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
            let audioEngine = AVAudioEngine()
    
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
    
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
    
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                request.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()
    
            return (audioEngine, request)
        }
    
    @MainActor @Published var transcript: String = ""
    @MainActor @Published var isTranscribing: Bool = false // Indicate transcribing state
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    init() {
        recognizer = SFSpeechRecognizer()
        Task {
            do {
                try await requestPermissions()
            } catch {
                await handleError(error)
            }
        }
    }
    
    /// Resets the transcription to an empty string.
    @MainActor
    func resetTranscript() async {
        transcript = ""
    }
    
    private func requestPermissions() async throws {
        guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
            throw RecognizerError.notAuthorizedToRecognize
        }
        guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
            throw RecognizerError.notPermittedToRecord
        }
    }
    
    
    func startTranscribing() async {
        guard await !isTranscribing else { return } // Prevent multiple starts

        await setIsTranscribing(true)
        defer { Task { await setIsTranscribing(false) } } // Ensure isTranscribing is reset

        guard let recognizer, recognizer.isAvailable else {
            await handleError(RecognizerError.recognizerIsUnavailable)
            return
        }

        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            self.task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in // Create a new Task to handle the async work
                    await self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
                }
            }
        } catch {
            await handleError(error)
        }
    }
    
    func stopTranscribing() {
        reset()
    }
    
    /// Resets the speech recognizer
    private func reset() {
        task?.cancel()
        task = nil
        request = nil
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0) // Remove tap before stopping the engine
        audioEngine = nil
    }
    
    private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) async {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            reset() // Reset only when finished or error
        }
        
        if let result {
            await setTranscript(result.bestTranscription.formattedString)
        } else if let error {
            await handleError(error)
        }
    }
    
    @MainActor private func handleError(_ error: Error) {
        if let error = error as? RecognizerError {
            transcript = "<< \(error.message) >>"
        } else {
            transcript = "<< \(RecognizerError.unknownError(error).message) >>"
        }
    }
    
    @MainActor private func setTranscript(_ newTranscript: String) {
        transcript = newTranscript
    }
    
    @MainActor private func setIsTranscribing(_ transcribing: Bool) {
        isTranscribing = transcribing
    }
    
    
    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            transcript = message
        }
    }
    nonisolated private func transcribe(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        Task { @MainActor [errorMessage] in
            transcript = "<< \(errorMessage) >>"
        }
    }
}



//MARK: - Extensions
extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { isAuthorized in
                if isAuthorized {
                    continuation.resume(returning: isAuthorized)
                }
            }
        }
    }
}