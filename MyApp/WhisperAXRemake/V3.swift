////
////  V3.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//
////
////  WhisperAXAppMain.swift
////  WhisperAX (Combined Refactored Version)
////
////  Created by Cong Le on 4/18/25. - Refactored from original ContentView
////  Original Copyright © 2024 Argmax, Inc. All rights reserved. (See original LICENSE.md)
////
////  This file combines AppSettings, TranscriptionService, ContentViewModel,
////  and all SwiftUI Views into a single file for demonstration and review.
////
//
//import SwiftUI
//import Combine
//import WhisperKit
//import AVFoundation
//import CoreML // For ModelState, MLComputeUnits
//#if canImport(UIKit)
//import UIKit
//#elseif canImport(AppKit)
//import AppKit
//#endif
//
//// MARK: - Constants & Global Helpers
//
//// Moved languages and default code here for broader access if needed
//struct Constants {
//    static let languages = "en"//WhisperKit.languages // Assuming WhisperKit exposes this
//    static let defaultLanguageCode = "en"
//    static let maxTokenContext = 4096 // Example context length
//}
//
//// Simple Logging Helper (from refactor)
//struct Logging {
//    static func info(_ message: String) { print("[INFO] \(message)") }
//    static func debug(_ message: String) {
//#if DEBUG
//        print("[DEBUG] \(message)");
//#endif
//    }
//    static func warning(_ message: String) { print("[WARN] ⚠️ \(message)") }
//    static func error(_ message: String) { print("[ERROR] 💥 \(message)") }
//}
//
//// MARK: - AppSettings (Observable Object for Persistent Settings)
//
//// Centralized place for AppStorage-backed settings
//class AppSettings: ObservableObject {
//    @AppStorage("selectedAudioInput") var selectedAudioInput: String = "No Audio Input" // macOS only
//    @AppStorage("selectedModel") var selectedModel: String = WhisperKit.recommendedModels().default
//    @AppStorage("selectedTab") var selectedTabString: String = "Transcribe" // Store string, map to enum later
//    @AppStorage("selectedTask") var selectedTask: String = "transcribe"
//    @AppStorage("selectedLanguage") var selectedLanguage: String = "english"
//    @AppStorage("repoName") var repoName: String = "argmaxinc/whisperkit-coreml"
//    @AppStorage("modelStoragePath") var modelStoragePath: String = "huggingface/models/argmaxinc/whisperkit-coreml" // More explicit name
//    
//    // Decoding Options
//    @AppStorage("enableTimestamps") var enableTimestamps: Bool = true
//    @AppStorage("enablePromptPrefill") var enablePromptPrefill: Bool = true
//    @AppStorage("enableCachePrefill") var enableCachePrefill: Bool = true
//    @AppStorage("enableSpecialCharacters") var enableSpecialCharacters: Bool = false
//    @AppStorage("enableDecoderPreview") var enableDecoderPreview: Bool = true
//    @AppStorage("enableEagerDecoding") var enableEagerDecoding: Bool = false
//    
//    @AppStorage("temperatureStart") var temperatureStart: Double = 0
//    @AppStorage("fallbackCount") var fallbackCount: Double = 5
//    @AppStorage("compressionCheckWindow") var compressionCheckWindow: Double = 60
//    @AppStorage("sampleLength") var sampleLength: Double = 224
//    @AppStorage("silenceThreshold") var silenceThreshold: Double = 0.3
//    @AppStorage("realtimeDelayInterval") var realtimeDelayInterval: Double = 1.0 // Ensure default matches original
//    @AppStorage("tokenConfirmationsNeeded") var tokenConfirmationsNeeded: Double = 2
//    @AppStorage("requiredSegmentsForConfirmation") var requiredSegmentsForConfirmation: Double = 4.0 // From original state
//    
//    // Strategy & Compute
//    @AppStorage("useVAD") var useVAD: Bool = true // From original state
//    @AppStorage("chunkingStrategy") var chunkingStrategy: ChunkingStrategy = .vad
//    @AppStorage("encoderComputeUnits") var encoderComputeUnits: MLComputeUnits = .cpuAndNeuralEngine
//    @AppStorage("decoderComputeUnits") var decoderComputeUnits: MLComputeUnits = .cpuAndNeuralEngine
//    @AppStorage("concurrentWorkerCount") var concurrentWorkerCount: Double = 4
//    
//    // Helper function to create ComputeOptions
//    func getComputeOptions() -> ModelComputeOptions {
//        // Assuming same compute units for Mel/Prefill as Encoder/Decoder based on original UI
//        return ModelComputeOptions(
//            melCompute: encoderComputeUnits,
//            audioEncoderCompute: encoderComputeUnits,
//            textDecoderCompute: decoderComputeUnits,
//            prefillCompute: decoderComputeUnits
//        )
//    }
//    
//    // Helper to convert stored string tab to enum
//    var selectedTab: ContentViewModel.Tab {
//        ContentViewModel.Tab(rawValue: selectedTabString) ?? .transcribe
//    }
//}
//
//// MARK: - TranscriptionService Protocol & Structures
//
//protocol TranscriptionServiceProtocol {
//    var modelStatePublisher: AnyPublisher<ModelState, Never> { get }
//    var transcriptionUpdatePublisher: AnyPublisher<TranscriptionUpdate, Never> { get }
//    var downloadProgressPublisher: AnyPublisher<(progress: Double, description: String), Never> { get } // Include description
//    var audioLevelPublisher: AnyPublisher<AudioSignalInfo, Never> { get }
//    var availableModelsPublisher: AnyPublisher<[String], Never> { get }
//    var localModelsPublisher: AnyPublisher<[String], Never> { get }
//    var currentModelState: ModelState { get } // Direct access needed sometimes
//    var modelFolderURL: URL? { get }
//    var audioProcessor: AudioProcessor { get } // Expose for raw access if needed
//    
//    func fetchAvailableModels(repoName: String, localModelPathBase: String) async
//    func loadModel(_ modelName: String, from repoName: String, computeOptions: ModelComputeOptions, localModelPathBase: String) async throws
//    func deleteModel(_ modelName: String, localModelPathBase: String) async throws
//    func transcribeFile(path: String, options: DecodingOptions) async throws
//    func startStreamingTranscription(deviceId: DeviceID?, options: DecodingOptions) async throws
//    func stopStreamingTranscription() async
//    func getAudioDevices() -> [AudioDevice] // macOS specific
//    func currentDecodingOptions(from settings: AppSettings) -> DecodingOptions // Make async if state access needed
//    func hasMicrophonePermission() async -> Bool
//    func resetServiceState() // Add explicit reset
//}
//
//struct TranscriptionUpdate: Equatable {
//    var segments: [TranscriptionSegment] = []
//    var confirmedText: String = ""
//    var hypothesisText: String = ""
//    var currentDecodingText: String = ""
//    var metrics: TranscriptionMetrics? = nil
//    var error: Error? = nil
//    var isTranscribing: Bool = false
//    var isRecording: Bool = false // Include recording status
//    
//    static func == (lhs: TranscriptionUpdate, rhs: TranscriptionUpdate) -> Bool {
//        lhs.segments == rhs.segments &&
//        lhs.confirmedText == rhs.confirmedText &&
//        lhs.hypothesisText == rhs.hypothesisText &&
//        lhs.currentDecodingText == rhs.currentDecodingText &&
//        lhs.metrics == rhs.metrics &&
//        lhs.isTranscribing == rhs.isTranscribing &&
//        lhs.isRecording == rhs.isRecording
//        // Error ignored for equality
//    }
//    
//    struct TranscriptionMetrics: Equatable {
//        var tokensPerSecond: Double = 0
//        var realTimeFactor: Double = 0
//        var speedFactor: Double = 0
//        var firstTokenTime: TimeInterval = 0
//        var pipelineStart: TimeInterval = 0
//        var currentLag: TimeInterval = 0
//        var currentFallbacks: Int = 0
//        var currentEncodingLoops: Int = 0
//        var currentDecodingLoops: Int = 0
//        var totalInferenceTime: TimeInterval = 0
//        var modelLoadingTime: TimeInterval = 0
//    }
//}
//
//struct AudioSignalInfo: Equatable {
//    var bufferEnergy: [Float] = []
//    var bufferSeconds: Double = 0
//}
//
//enum TranscriptionServiceError: LocalizedError {
//    case whisperKitNotInitialized, modelNotLoaded, microphonePermissionDenied, fileNotFound(path: String), modelFolderAccessError(path: String), downloadFailed(model: String), prewarmFailed(model: String), loadFailed(model: String), eagerModeRequiresWordTimestamps(model: String), fileAccessDenied(path: String), transcriptionFailed(underlyingError: Error?)
//    
//    var errorDescription: String? { /* ... (implement descriptions as before) ... */
//        switch self {
//        case .whisperKitNotInitialized: return "WhisperKit not initialized."
//        case .modelNotLoaded: return "Model not loaded."
//        case .microphonePermissionDenied: return "Microphone permission denied."
//        case .fileNotFound(let path): return "File not found: \(path)"
//        case .modelFolderAccessError(let path): return "Cannot access model folder: \(path)"
//        case .downloadFailed(let model): return "Download failed: \(model)"
//        case .prewarmFailed(let model): return "Prewarm failed: \(model)"
//        case .loadFailed(let model): return "Load failed: \(model)"
//        case .eagerModeRequiresWordTimestamps(let model): return "Eager mode requires word timestamps (\(model))."
//        case .fileAccessDenied(let path): return "Permission denied for file: \(path)"
//        case .transcriptionFailed(let underlyingError): return "Transcription failed: \(underlyingError?.localizedDescription ?? "Unknown error")"
//        }
//    }
//}
//
//// MARK: - TranscriptionService Implementation
//
//@MainActor
//class TranscriptionService: TranscriptionServiceProtocol, ObservableObject {
//    
//    private var whisperKit: WhisperKit?
//    let audioProcessor = AudioProcessor() // Keep public if ViewModel needs direct access (e.g., raw samples)
//    
//    // --- Publishers ---
//    private let modelStateSubject = CurrentValueSubject<ModelState, Never>(.unloaded)
//    var modelStatePublisher: AnyPublisher<ModelState, Never> { modelStateSubject.eraseToAnyPublisher() }
//    
//    private let transcriptionUpdateSubject = PassthroughSubject<TranscriptionUpdate, Never>()
//    var transcriptionUpdatePublisher: AnyPublisher<TranscriptionUpdate, Never> { transcriptionUpdateSubject.eraseToAnyPublisher() }
//    
//    private let downloadProgressSubject = CurrentValueSubject<(progress: Double, description: String), Never>((0.0, "Idle"))
//    var downloadProgressPublisher: AnyPublisher<(progress: Double, description: String), Never> { downloadProgressSubject.eraseToAnyPublisher() }
//    
//    private let audioLevelSubject = PassthroughSubject<AudioSignalInfo, Never>()
//    var audioLevelPublisher: AnyPublisher<AudioSignalInfo, Never> { audioLevelSubject.eraseToAnyPublisher() }
//    
//    private let availableModelsSubject = CurrentValueSubject<[String], Never>([])
//    var availableModelsPublisher: AnyPublisher<[String], Never> { availableModelsSubject.eraseToAnyPublisher() }
//    
//    private let localModelsSubject = CurrentValueSubject<[String], Never>([])
//    var localModelsPublisher: AnyPublisher<[String], Never> { localModelsSubject.eraseToAnyPublisher() }
//    
//    // --- State ---
//    private var currentStreamingTask: Task<Void, Error>? // Keeps track of the streaming loop
//    private(set) var localModels: [String] = []
//    private(set) var availableModels: [String] = []
//    var modelFolderURL: URL? { whisperKit?.modelFolder }
//    var currentModelState: ModelState { modelStateSubject.value }
//    private var isCurrentlyRecording: Bool = false
//    
//    // Streaming State
//    private var lastConfirmedSegmentEndSeconds: Float = 0.0
//    private var confirmedSegments: [TranscriptionSegment] = []
//    private var unconfirmedSegments: [TranscriptionSegment] = []
//    private var eagerResults: [TranscriptionResult?] = []
//    private var prevResult: TranscriptionResult?
//    private var lastAgreedSeconds: Float = 0.0
//    private var prevWords: [WordTiming] = []
//    private var lastAgreedWords: [WordTiming] = []
//    private var confirmedWords: [WordTiming] = []
//    
//    // Decoder Preview State
//    private var currentDecodingTextPreview: String = ""
//    private var currentDecodingFallbacks: Int = 0
//    private var currentDecodingLoops: Int = 0 // Track loops for metrics
//    
//    // MARK: - Initialization & Model Management
//    
//    init() {
//        Logging.info("TranscriptionService Initialized")
//        // Note: Initial model fetch now happens explicitly from ViewModel
//    }
//    
//    private func getDocumentsDirectory() -> URL? {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//    }
//    
//    func fetchAvailableModels(repoName: String, localModelPathBase: String) async {
//        guard let documents = getDocumentsDirectory() else {
//            Logging.error("Could not access Documents directory.")
//            return
//        }
//        let effectivePath = documents.appendingPathComponent(localModelPathBase) // Base path for models
//        
//        // --- Check Local Models ---
//        var foundLocalModels: [String] = []
//        if FileManager.default.fileExists(atPath: effectivePath.path) {
//            do {
//                let items = try FileManager.default.contentsOfDirectory(at: effectivePath, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
//                foundLocalModels = items.filter { url in
//                    var isDir: ObjCBool = false
//                    FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
//                    return isDir.boolValue
//                }.map { $0.lastPathComponent } // Get folder names
//                foundLocalModels = WhisperKit.formatModelFiles(foundLocalModels) // Format as needed
//            } catch {
//                Logging.error("Error enumerating local models at \(effectivePath.path): \(error)")
//            }
//        }
//        self.localModels = foundLocalModels // Update internal state
//        localModelsSubject.send(localModels.sorted()) // Publish sorted list
//        Logging.info("Found locally: \(localModels)")
//        
//        // --- Fetch Remote Models ---
//        let remoteModelSupport = await WhisperKit.recommendedRemoteModels()
//        var combined = Set(localModels)
//        combined.formUnion(remoteModelSupport.supported)
//        combined.insert(WhisperKit.recommendedModels().default) // Ensure default is present
//        availableModels = Array(combined).sorted()
//        availableModelsSubject.send(availableModels)
//        Logging.info("Available models: \(availableModels)")
//    }
//    
//    func loadModel(_ modelName: String, from repoName: String, computeOptions: ModelComputeOptions, localModelPathBase: String) async throws {
//        guard currentModelState != .loading, currentModelState != .prewarming, currentModelState != .downloading else {
//            Logging.warning("Model load requested while already in progress (\(currentModelState)). Ignoring.")
//            return // Prevent concurrent loads
//        }
//        guard !modelName.isEmpty else { throw TranscriptionServiceError.modelNotLoaded /* Or specific "no model selected" error */ }
//        
//        Logging.info("Loading model: \(modelName) from \(repoName)")
//        modelStateSubject.send(.loading)
//        downloadProgressSubject.send((0.0, "Initializing..."))
//        
//        do {
//            let config = WhisperKitConfig(computeOptions: computeOptions, verbose: true, logLevel: .debug, prewarm: false, load: false, download: false)
//            whisperKit = try await WhisperKit(config) // Re-init WhisperKit instance
//            guard let whisperKit = whisperKit else { throw TranscriptionServiceError.whisperKitNotInitialized }
//            
//            guard let documents = getDocumentsDirectory() else { throw TranscriptionServiceError.modelFolderAccessError(path: "Documents") }
//            let modelBasePath = documents.appendingPathComponent(localModelPathBase)
//            let modelFolderPath = modelBasePath.appendingPathComponent(modelName)
//            
//            var folder: URL?
//            var requiresDownload = false
//            
//            if !localModels.contains(modelName) || !FileManager.default.fileExists(atPath: modelFolderPath.path) {
//                requiresDownload = true
//                Logging.info("Model \(modelName) not found locally. Downloading.")
//            } else {
//                Logging.info("Found model \(modelName) locally.")
//                folder = modelFolderPath
//            }
//            
//            if requiresDownload {
//                modelStateSubject.send(.downloading)
//                let specializationProgressRatio = 0.7 // Portion of progress bar for download
//                folder = try await WhisperKit.download(variant: modelName, from: repoName) { progress in
//                    Task { @MainActor in
//                        let overallProgress = progress.fractionCompleted * specializationProgressRatio
//                        self.downloadProgressSubject.send((overallProgress, "Downloading \(modelName)..."))
//                    }
//                }
//                guard let downloadedFolder = folder else { throw TranscriptionServiceError.downloadFailed(model: modelName) }
//                try FileManager.default.createDirectory(at: modelBasePath, withIntermediateDirectories: true)
//                if FileManager.default.fileExists(atPath: modelFolderPath.path) {
//                    try FileManager.default.removeItem(at: modelFolderPath)
//                }
//                try FileManager.default.moveItem(at: downloadedFolder, to: modelFolderPath)
//                folder = modelFolderPath // Update to the final location
//                await MainActor.run { downloadProgressSubject.send((specializationProgressRatio, "Download Complete")) }
//            }
//            
//            guard let modelFolder = folder else { throw TranscriptionServiceError.modelFolderAccessError(path: modelFolderPath.path) }
//            whisperKit.modelFolder = modelFolder
//            
//            modelStateSubject.send(.prewarming)
//            downloadProgressSubject.send((downloadProgressSubject.value.progress,"Prewarming..."))
//            Logging.info("Prewarming model \(modelName)...")
//            // Simulate prewarm progress gently
//            try await Task.sleep(nanoseconds: 100_000_000) // Small delay before potential long op
//            let targetProgressPrewarm = downloadProgressSubject.value.progress + (1.0 - downloadProgressSubject.value.progress) * 0.5 // Aim for halfway through remaining
//            
//            do {
//                try await whisperKit.prewarmModels()
//                await MainActor.run { downloadProgressSubject.send((targetProgressPrewarm, "Prewarm Complete")) }
//            } catch {
//                Logging.error("Prewarming failed for \(modelName): \(error). Continuing to load...")
//                // Don't throw yet, load might still work
//                await MainActor.run { downloadProgressSubject.send((targetProgressPrewarm, "Prewarm Failed - Loading...")) }
//            }
//            
//            modelStateSubject.send(.loading)
//            let targetProgressLoad = downloadProgressSubject.value.progress + (1.0 - downloadProgressSubject.value.progress) * 0.9 // Aim for almost done
//            await MainActor.run { downloadProgressSubject.send((targetProgressLoad, "Loading Model Weights...")) }
//            Logging.info("Loading model weights for \(modelName)...")
//            try await whisperKit.loadModels()
//            
//            Logging.info("Model \(modelName) loaded successfully.")
//            modelStateSubject.send(whisperKit.modelState) // Should be .loaded
//            downloadProgressSubject.send((1.0, "Model Loaded"))
//            
//            if requiresDownload, !localModels.contains(modelName) {
//                localModels.append(modelName)
//                localModelsSubject.send(localModels.sorted())
//            }
//            
//        } catch {
//            Logging.error("Error during loadModel for \(modelName): \(error)")
//            modelStateSubject.send(.unloaded)
//            downloadProgressSubject.send((0.0, "Load Failed"))
//            throw error // Re-throw original error
//        }
//    }
//    
//    func deleteModel(_ modelName: String, localModelPathBase: String) async throws {
//        guard let documents = getDocumentsDirectory() else { return }
//        let modelFolder = documents.appendingPathComponent(localModelPathBase).appendingPathComponent(modelName)
//        Logging.info("Attempting delete model \(modelName) at \(modelFolder.path)")
//        if FileManager.default.fileExists(atPath: modelFolder.path) {
//            try FileManager.default.removeItem(at: modelFolder)
//            Logging.info("Deleted folder for model \(modelName).")
//            if let index = localModels.firstIndex(of: modelName) {
//                localModels.remove(at: index)
//                localModelsSubject.send(localModels.sorted())
//                if whisperKit?.modelFolder?.lastPathComponent == modelName {
//                    whisperKit = nil
//                    modelStateSubject.send(.unloaded)
//                }
//            }
//        } else {
//            Logging.warning("Folder not found for deletion: \(modelName)")
//        }
//    }
//    
//    func resetServiceState() {
//        Logging.info("Resetting TranscriptionService state.")
//        stopStreamingTranscription() // Ensure any active stream stops
//        whisperKit = nil // Clear WhisperKit instance
//        modelStateSubject.send(.unloaded)
//        downloadProgressSubject.send((0.0, "Idle"))
//        // Don't clear models lists (available/local) as they persist
//        resetStreamingState() // Clear segments, eager state, etc.
//    }
//    
//    // MARK: - Transcription Core Logic
//    
//    func transcribeFile(path: String, options: DecodingOptions) async throws {
//        guard let whisperKit = whisperKit, currentModelState == .loaded else { throw TranscriptionServiceError.modelNotLoaded }
//        Logging.info("Starting transcription for file: \(path)")
//        sendUpdate(updateBase: TranscriptionUpdate(isTranscribing: true, isRecording: false))
//        
//        do {
//            let loadingStart = Date()
//            // Ensure file exists before loading
//            guard FileManager.default.fileExists(atPath: path) else {
//                throw TranscriptionServiceError.fileNotFound(path: path)
//            }
//            let audioFileSamples = try await Task {
//                try autoreleasepool { try AudioProcessor.loadAudioAsFloatArray(fromPath: path) }
//            }.value
//            Logging.info("Loaded \(audioFileSamples.count) samples in \(Date().timeIntervalSince(loadingStart))s.")
//            
//            resetStreamingState() // Clear previous streaming/eager state
//            
//            let transcriptionResults = try await performTranscription(on: audioFileSamples, options: options, isStreaming: false)
//            let mergedResult = mergeTranscriptionResults(transcriptionResults)
//            
//            var update = TranscriptionUpdate(isTranscribing: false, isRecording: false) // Finished
//            //            if let result = mergedResult {
//            //                update.segments = result.segments
//            //                update.metrics = mapMetrics(result.timings, totalAudioDuration: Double(audioFileSamples.count) / Double(WhisperKit.sampleRate))
//            //            }
//            sendUpdate(updateBase: update)
//            Logging.info("File transcription finished.")
//        } catch {
//            Logging.error("Error transcribing file \(path): \(error)")
//            sendUpdate(updateBase: TranscriptionUpdate(error: error, isTranscribing: false, isRecording: false))
//            throw error // Re-throw
//        }
//    }
//    
//    func startStreamingTranscription(deviceId: DeviceID?, options: DecodingOptions) async throws {
//        guard let whisperKit = whisperKit, currentModelState == .loaded else { throw TranscriptionServiceError.modelNotLoaded }
//        guard currentStreamingTask == nil else { Logging.warning("Streaming already active."); return }
//        guard await hasMicrophonePermission() else { throw TranscriptionServiceError.microphonePermissionDenied }
//        
//        Logging.info("Starting streaming transcription...")
//        resetStreamingState() // Clear previous stream state
//        sendUpdate(updateBase: TranscriptionUpdate(isTranscribing: true, isRecording: true)) // Indicate start
//        
//        do {
//            try audioProcessor.startRecordingLive(inputDeviceID: deviceId) { _ in
//                Task { @MainActor in
//                    self.audioLevelSubject.send(AudioSignalInfo(
//                        bufferEnergy: self.audioProcessor.relativeEnergy,
//                        bufferSeconds: Double(self.audioProcessor.audioSamples.count) / Double(WhisperKit.sampleRate)
//                    ))
//                }
//            }
//            isCurrentlyRecording = true // Internal flag
//            
//            currentStreamingTask = Task(priority: .userInitiated) {
//                do {
//                    try await realtimeLoop(options: options)
//                } catch is CancellationError {
//                    Logging.info("Realtime loop cancelled.")
//                } catch {
//                    Logging.error("Realtime loop failed: \(error)")
//                    sendUpdate(updateBase: TranscriptionUpdate(error: error, isTranscribing: false, isRecording: false))
//                    self.stopAudioCapture() // Ensure resources are freed
//                }
//            }
//        } catch {
//            Logging.error("Failed to start live recording: \(error)")
//            sendUpdate(updateBase: TranscriptionUpdate(error: error, isTranscribing: false, isRecording: false))
//            throw error
//        }
//    }
//    
//    func stopStreamingTranscription() {
//        guard currentStreamingTask != nil || isCurrentlyRecording else { return }
//        Logging.info("Stopping streaming transcription.")
//        currentStreamingTask?.cancel()
//        currentStreamingTask = nil
//        stopAudioCapture()
//        finalizeText() // Send final consolidated update
//    }
//    
//    private func stopAudioCapture() {
//        if isCurrentlyRecording {
//            audioProcessor.stopRecording()
//            isCurrentlyRecording = false
//            Logging.info("Audio capture stopped.")
//        }
//    }
//    
//    private func realtimeLoop(options: DecodingOptions) async throws {
//        var lastBufferSize = 0
//        let delayInterval = 1.0 //Float(options.realtimeDelayInterval ?? 1.0)
//        let requiredSegmentsForConfirmation = 4.0 //Int(options.requiredSegmentsForConfirmation ?? 4.0) // Get from options
//        let useVAD = true //options.useVAD ?? true // Get from options
//        let silenceThreshold = 0.3 //Float(options.silenceThreshold ?? 0.3) // Get from options
//        let enableEager = true//options.enableEagerDecoding ?? false // Get from options
//        
//        while !Task.isCancelled {
//            let currentBuffer = audioProcessor.audioSamples
//            let nextBufferSize = currentBuffer.count - lastBufferSize
//            let nextBufferSeconds = Float(nextBufferSize) / Float(WhisperKit.sampleRate)
//            
//            //            guard nextBufferSeconds > delayInterval else {
//            //                try await Task.sleep(nanoseconds: 100_000_000)
//            //                continue
//            //            }
//            
//            if useVAD && options.chunkingStrategy == .vad { // Check both flags
//                let voiceDetected = AudioProcessor.isVoiceDetected(
//                    in: audioProcessor.relativeEnergy,
//                    nextBufferInSeconds: nextBufferSeconds,
//                    silenceThreshold: Float(silenceThreshold)
//                )
//                
//                guard voiceDetected else {
//                    try await Task.sleep(nanoseconds: 100_000_000)
//                    continue
//                }
//            }
//            
//            lastBufferSize = currentBuffer.count
//            Logging.info("[StreamLoop] Processing \(nextBufferSeconds)s chunk.")
//            
//            var transcriptionResult: TranscriptionResult?
//            do {
//                if enableEager {
//                    guard whisperKit?.textDecoder.supportsWordTimestamps ?? false else {
//                        throw TranscriptionServiceError.eagerModeRequiresWordTimestamps(model: whisperKit?.modelVariant.description ?? "Unknown")
//                    }
//                    transcriptionResult = try await performEagerTranscription(on: Array(currentBuffer), options: options)
//                } else {
//                    let results = try await performTranscription(on: Array(currentBuffer), options: options, isStreaming: true)
//                    transcriptionResult = mergeTranscriptionResults(results)
//                    processStandardStreamingResults(transcriptionResult, bufferDuration: Double(currentBuffer.count) / Double(WhisperKit.sampleRate), requiredConfirmations: Int(requiredSegmentsForConfirmation))
//                }
//            } catch {
//                Logging.error("[StreamLoop] Transcription error: \(error)")
//                // Don't stop the whole loop on a single chunk error? Or maybe we should?
//                // Send an error update but keep trying?
//                sendUpdate(updateBase: TranscriptionUpdate(error: error, isTranscribing: false, isRecording: true)) // Indicate error but loop may continue
//                // For now, let's rethrow to stop the loop on error
//                throw error
//            }
//            
//            // Update metrics based on the result of either path
//            let bufferDuration = Double(currentBuffer.count) / Double(WhisperKit.sampleRate)
//            sendUpdate(updateBase: TranscriptionUpdate(metrics: mapMetrics(transcriptionResult?.timings, totalAudioDuration: bufferDuration), isTranscribing: true, isRecording: true))
//            
//            try await Task.sleep(nanoseconds: 50_000_000) // Small yield
//        }
//        Logging.info("Realtime loop exited.")
//    }
//    
//    private func performTranscription(on samples: [Float], options: DecodingOptions, isStreaming: Bool) async throws -> [TranscriptionResult] {
//        guard let whisperKit = whisperKit else { throw TranscriptionServiceError.modelNotLoaded }
//        var effectiveOptions = options
//        if isStreaming {
//            effectiveOptions.clipTimestamps = options.enableEagerDecoding ?? false ? [lastAgreedSeconds] : [lastConfirmedSegmentEndSeconds]
//            effectiveOptions.chunkingStrategy = Optional.none // Managed by loop
//            effectiveOptions.concurrentWorkerCount = 1        // Often better for streaming
//        } else {
//            // File mode - use concurrent workers setting
//            effectiveOptions.concurrentWorkerCount = Int(options.concurrentWorkerCount) == 0 ? 4 : Int(options.concurrentWorkerCount) // Use setting or default
//        }
//        
//        currentDecodingLoops = 0 // Reset loop count for this call
//        
//        return try await whisperKit.transcribe(
//            audioArray: samples,
//            decodeOptions: effectiveOptions,
//            callback: decodingCallback(options: effectiveOptions, isStreaming: isStreaming)
//        )
//    }
//    
//    private func performEagerTranscription(on samples: [Float], options: DecodingOptions) async throws -> TranscriptionResult? {
//        guard let whisperKit = whisperKit else { throw TranscriptionServiceError.modelNotLoaded }
//        var streamOptions = options
//        streamOptions.clipTimestamps = [lastAgreedSeconds]
//        streamOptions.prefixTokens = lastAgreedWords.flatMap { $0.tokens }
//        streamOptions.wordTimestamps = true
//        streamOptions.chunkingStrategy = Optional.none
//        streamOptions.concurrentWorkerCount = 1
//        
//        currentDecodingLoops = 0 // Reset loop count
//        
//        let transcriptionResults = try await whisperKit.transcribe(
//            audioArray: samples,
//            decodeOptions: streamOptions,
//            callback: decodingCallback(options: streamOptions, isStreaming: true)
//        )
//        let transcription = transcriptionResults.first
//        
//        guard let result = transcription else {
//            sendUpdate(updateBase: currentEagerUpdate(metrics: nil)) // Keep UI sync'd
//            return nil
//        }
//        
//        let currentHypothesisWords = result.allWords.filter { $0.start >= lastAgreedSeconds }
//        let previousWindowWords = self.prevResult?.allWords.filter { $0.start >= lastAgreedSeconds } ?? []
//        let commonPrefix = findLongestCommonPrefix(previousWindowWords, currentHypothesisWords)
//        let confirmationsNeeded = Int(options.tokenConfirmationsNeeded ?? 2.0)
//        
//        var newWordsConfirmed = false
//        if commonPrefix.count >= confirmationsNeeded {
//            let newlyConfirmedCount = commonPrefix.count - confirmationsNeeded
//            if newlyConfirmedCount > 0 {
//                let newlyConfirmedWords = Array(commonPrefix.prefix(newlyConfirmedCount))
//                confirmedWords.append(contentsOf: newlyConfirmedWords)
//                newWordsConfirmed = true
//                lastAgreedWords = Array(commonPrefix.suffix(confirmationsNeeded))
//                lastAgreedSeconds = lastAgreedWords.first?.start ?? lastAgreedSeconds
//                Logging.info("[Eager] Confirmed \(newlyConfirmedCount) words up to \(lastAgreedSeconds)s.")
//            } else {
//                lastAgreedWords = commonPrefix
//                lastAgreedSeconds = lastAgreedWords.first?.start ?? lastAgreedSeconds
//                Logging.debug("[Eager] Re-confirmed prefix, no new full words.")
//            }
//        } else {
//            Logging.debug("[Eager] Not enough confirmations (\(commonPrefix.count)/\(confirmationsNeeded)).")
//        }
//        
//        if newWordsConfirmed || self.prevResult == nil {
//            self.prevResult = result
//            eagerResults.append(result) // Optional history
//        }
//        
//        sendUpdate(updateBase: currentEagerUpdate(result: result, samplesCount: samples.count)) // send latest eager state
//        
//        return result
//    }
//    
//    private func decodingCallback(options: DecodingOptions, isStreaming: Bool) -> ((TranscriptionProgress) -> Bool?) {
//        return { [weak self] progress in
//            guard let self = self else { return false }
//            
//            // Update internal state (text preview, fallbacks, loops)
//            // Be careful with threading if this callback isn't guaranteed on MainActor
//            Task { @MainActor in
//                self.currentDecodingTextPreview = progress.text
//                self.currentDecodingFallbacks = Int(progress.timings.totalDecodingFallbacks)
//                self.currentDecodingLoops += 1 // Increment loop counter
//                
//                // Send *only* the preview text update frequently if needed,
//                // otherwise it gets included in the main update after transcription finishes.
//                // self.transcriptionUpdateSubject.send(TranscriptionUpdate(currentDecodingText: progress.text, ...))
//            }
//            
//            // Early Stopping Logic (from original)
//            let compressionCheckWindow = Int(options.compressionCheckWindow ?? 60)
//            let compressionRatioThreshold = options.compressionRatioThreshold ?? 2.4
//            let logProbThreshold = options.logProbThreshold ?? -1.0
//            let currentTokens = progress.tokens
//            if currentTokens.count > compressionCheckWindow {
//                let checkTokens = Array(currentTokens.suffix(compressionCheckWindow))
//                if compressionRatio(of: checkTokens) > compressionRatioThreshold {
//                    Logging.debug("Early stopping: Compression Ratio")
//                    return false
//                }
//            }
//            if (progress.avgLogprob ?? 0) < logProbThreshold {
//                Logging.debug("Early stopping: Log Probability")
//                return false
//            }
//            
//            return nil // Continue decoding
//        }
//    }
//    
//    private func processStandardStreamingResults(_ result: TranscriptionResult?, bufferDuration: Double, requiredConfirmations: Int) {
//        guard let result = result else {
//            sendUpdate(updateBase: currentStandardUpdate(metrics: nil)) // Keep UI sync'd
//            return
//        }
//        
//        let segments = result.segments
//        var newlyConfirmed: [TranscriptionSegment] = []
//        var stillUnconfirmed: [TranscriptionSegment] = []
//        
//        if segments.count > requiredConfirmations {
//            let numberOfSegmentsToConfirm = segments.count - requiredConfirmations
//            let potentialConfirm = Array(segments.prefix(numberOfSegmentsToConfirm))
//            stillUnconfirmed = Array(segments.suffix(requiredConfirmations))
//            
//            if let lastPotential = potentialConfirm.last, lastPotential.end > lastConfirmedSegmentEndSeconds {
//                for segment in potentialConfirm where segment.end > lastConfirmedSegmentEndSeconds {
//                    if !confirmedSegments.contains(where: { $0.id == segment.id }) { // Use ID for uniqueness
//                        confirmedSegments.append(segment)
//                        newlyConfirmed.append(segment)
//                    }
//                }
//                if let lastNew = newlyConfirmed.last {
//                    lastConfirmedSegmentEndSeconds = lastNew.end
//                    Logging.info("[StandardStream] Confirmed up to \(lastConfirmedSegmentEndSeconds)s")
//                }
//            } else {
//                stillUnconfirmed = segments
//            }
//        } else {
//            stillUnconfirmed = segments
//        }
//        unconfirmedSegments = stillUnconfirmed // Update service state
//        
//        // Send update with latest confirmed + unconfirmed snapshot
//        sendUpdate(updateBase: currentStandardUpdate(result: result, bufferDuration: bufferDuration))
//    }
//    
//    private func finalizeText() {
//        Logging.info("Finalizing transcription text...")
//        var finalUpdate = TranscriptionUpdate(isTranscribing: false, isRecording: false) // Base for stopping
//        
//        // Standard Finalization
//        if !unconfirmedSegments.isEmpty {
//            confirmedSegments.append(contentsOf: unconfirmedSegments.filter { !confirmedSegments.contains(where: { c in c.id == $0.id }) }) // Avoid duplicates
//            unconfirmedSegments = []
//        }
//        finalUpdate.segments = confirmedSegments
//        
//        // Eager Finalization
//        if prevResult != nil {
//            let lastHypothesisWords = prevResult?.allWords.filter { $0.start >= lastAgreedSeconds } ?? []
//            let finalWordsToConfirm = lastAgreedWords + lastHypothesisWords
//            confirmedWords.append(contentsOf: finalWordsToConfirm)
//            resetEagerState() // Clear eager working state
//        }
//        finalUpdate.confirmedText = confirmedWords.map { $0.word }.joined()
//        finalUpdate.hypothesisText = "" // No more hypothesis
//        
//        finalUpdate.currentDecodingText = "" // Clear preview on finalization
//        // Include latest metrics if available
//        // finalUpdate.metrics = mapMetrics(lastKnownTimings... )
//        
//        sendUpdate(updateBase: finalUpdate)
//        resetStreamingState() // Clear segment lists etc.
//    }
//    
//    private func sendUpdate(updateBase: TranscriptionUpdate) {
//        // Inject latest state into the base update package
//        var updateToSend = updateBase
//        // Ensure consistent status flags are set if needed
//        updateToSend.isRecording = self.isCurrentlyRecording
//        // Inject latest preview text if not explicitly set otherwise
//        if updateToSend.currentDecodingText.isEmpty {
//            updateToSend.currentDecodingText = self.currentDecodingTextPreview
//        }
//        // Inject latest metrics if not set
//        // updateToSend.metrics = updateToSend.metrics ?? self.lastMetrics
//        
//        // Publish on main thread
//        Task { @MainActor in
//            transcriptionUpdateSubject.send(updateToSend)
//            if !updateToSend.isTranscribing { // Clear preview only when fully stopped
//                self.currentDecodingTextPreview = ""
//                self.currentDecodingFallbacks = 0
//                self.currentDecodingLoops = 0
//            }
//        }
//    }
//    
//    // Helpers to create consistent update snapshots
//    private func currentStandardUpdate(result: TranscriptionResult? = nil, bufferDuration: Double? = nil, metrics explicitMetrics: TranscriptionUpdate.TranscriptionMetrics? = nil) -> TranscriptionUpdate {
//        TranscriptionUpdate(
//            segments: self.confirmedSegments + self.unconfirmedSegments,
//            currentDecodingText: self.currentDecodingTextPreview,
//            metrics: explicitMetrics ?? mapMetrics(result?.timings, totalAudioDuration: bufferDuration),
//            isTranscribing: true, isRecording: self.isCurrentlyRecording // Assume still transcribing within loop/processing
//        )
//    }
//    
//    private func currentEagerUpdate(result: TranscriptionResult? = nil, samplesCount: Int? = nil, metrics explicitMetrics: TranscriptionUpdate.TranscriptionMetrics? = nil) -> TranscriptionUpdate {
//        let bufferDuration = samplesCount != nil ? Double(samplesCount!) / Double(WhisperKit.sampleRate) : nil
//        let finalHypothesisWords = result?.allWords.filter { $0.start >= lastAgreedSeconds } ?? lastAgreedWords // Use lastAgreed if no new result
//        let hypothesisStr = finalHypothesisWords.map { $0.word }.joined()
//        
//        return TranscriptionUpdate(
//            confirmedText: self.confirmedWords.map { $0.word }.joined(),
//            hypothesisText: hypothesisStr,
//            currentDecodingText: self.currentDecodingTextPreview,
//            metrics: explicitMetrics ?? mapMetrics(result?.timings, totalAudioDuration: bufferDuration),
//            isTranscribing: true, isRecording: self.isCurrentlyRecording
//        )
//    }
//    
//    // Resets state specific to streaming/eager mode
//    private func resetStreamingState() {
//        Logging.debug("Resetting streaming state.")
//        lastConfirmedSegmentEndSeconds = 0.0
//        confirmedSegments = []
//        unconfirmedSegments = []
//        resetEagerState()
//        currentDecodingTextPreview = ""
//        currentDecodingFallbacks = 0
//        currentDecodingLoops = 0
//    }
//    private func resetEagerState() {
//        eagerResults = []
//        prevResult = nil
//        lastAgreedSeconds = 0.0
//        prevWords = []
//        lastAgreedWords = []
//        confirmedWords = []
//    }
//    
//    // MARK: - Helpers & Permissions
//    
//    func hasMicrophonePermission() async -> Bool {
//        await AudioProcessor.requestRecordPermission()
//    }
//    
//    func getAudioDevices() -> [AudioDevice] {
//#if os(macOS)
//        return AudioProcessor.getAudioDevices()
//#else
//        return []
//#endif
//    }
//    
//    // Constructs DecodingOptions using AppSettings and current Service state
//    func currentDecodingOptions(from settings: AppSettings) -> DecodingOptions {
//        let languageCode = Constants.languages[settings.selectedLanguage, default: Constants.defaultLanguageCode]
//        let task: DecodingTask = settings.selectedTask == "transcribe" ? .transcribe : .translate
//        let clipTime: Float = settings.enableEagerDecoding ? lastAgreedSeconds : lastConfirmedSegmentEndSeconds
//        let wordTimestampsEnabled = settings.enableEagerDecoding || settings.enableTimestamps // Enable WT if eager or if standard timestamps are on
//        
//        return DecodingOptions(
//            verbose: true,
//            task: task,
//            language: languageCode,
//            temperature: Float(settings.temperatureStart),
//            temperatureFallbackCount: Int(settings.fallbackCount),
//            compressionRatioThreshold: 2.4, // Default, make configurable?
//            logProbThreshold: -1.0, // Default, make configurable?
//            noSpeechThreshold: 0.6, // Default, make configurable?
//            sampleLength: Int(settings.sampleLength),
//            usePrefillPrompt: settings.enablePromptPrefill,
//            usePrefillCache: settings.enableCachePrefill,
//            skipSpecialTokens: !settings.enableSpecialCharacters,
//            withoutTimestamps: !settings.enableTimestamps,
//            wordTimestamps: wordTimestampsEnabled, // Use combined flag
//            firstTokenLogProbThreshold: settings.enableEagerDecoding ? -1.5 : nil, // Only for eager
//            clipTimestamps: [clipTime], // Use dynamic clip time
//            realtimeDelayInterval: settings.realtimeDelayInterval,// Added property
//            useVAD: settings.useVAD,// Added property
//            silenceThreshold: settings.silenceThreshold,// Added property
//            tokenConfirmationsNeeded: settings.tokenConfirmationsNeeded,// Added property
//            requiredSegmentsForConfirmation: settings.requiredSegmentsForConfirmation,// Added property
//            concurrentWorkerCount: Int(settings.concurrentWorkerCount), // Use setting directly
//            chunkingStrategy: settings.chunkingStrategy
//        )
//    }
//    
//    // Maps WhisperKit timings to the metrics struct
//    private func mapMetrics(_ timings: TranscriptionTimings?, totalAudioDuration: Double? = nil) -> TranscriptionUpdate.TranscriptionMetrics? {
//        guard let timings = timings else { return nil }
//        // Get loop counts from internal state
//        let decodingLoops = self.currentDecodingLoops
//        
//        var metrics = TranscriptionUpdate.TranscriptionMetrics(
//            tokensPerSecond: timings.tokensPerSecond,
//            realTimeFactor: timings.realTimeFactor,
//            speedFactor: timings.speedFactor,
//            firstTokenTime: max(0, timings.firstTokenTime - timings.pipelineStart),
//            pipelineStart: timings.pipelineStart,
//            currentLag: timings.decodingLoop,
//            currentFallbacks: Int(timings.totalDecodingFallbacks),
//            currentEncodingLoops: Int(timings.totalEncodingRuns), // Use timing's encoding runs
//            currentDecodingLoops: decodingLoops, // Use internal loop counter
//            totalInferenceTime: timings.fullPipeline,
//            modelLoadingTime: timings.modelLoading
//        )
//        if let duration = totalAudioDuration, duration > 0, metrics.totalInferenceTime > 0 {
//            metrics.realTimeFactor = metrics.totalInferenceTime / duration
//            metrics.speedFactor = duration / metrics.totalInferenceTime
//        }
//        return metrics
//    }
//}
//
//// MARK: - ContentViewModel (MVVM)
//
//@MainActor
//class ContentViewModel: ObservableObject {
//    
//    // MARK: Dependencies
//    private let transcriptionService: TranscriptionServiceProtocol
//    @ObservedObject var settings: AppSettings
//    
//    // MARK: Published UI State (Mirroring Service + UI Specifics)
//    @Published var modelState: ModelState = .unloaded
//    @Published var availableModels: [String] = []
//    @Published var localModels: [String] = []
//    @Published var downloadProgress: Double = 0.0
//    @Published var downloadDescription: String = "Idle"
//    @Published var modelFolderExists: Bool = false
//    
//    @Published var isRecording: Bool = false
//    @Published var isTranscribing: Bool = false
//    @Published var confirmedSegments: [TranscriptionSegment] = []
//    @Published var unconfirmedSegments: [TranscriptionSegment] = []
//    @Published var confirmedEagerText: String = ""
//    @Published var hypothesisEagerText: String = ""
//    @Published var decoderPreviewText: String = ""
//    
//    @Published var audioSignal = AudioSignalInfo()
//    @Published var metrics = TranscriptionUpdate.TranscriptionMetrics()
//    
//    @Published var availableLanguages: [String] = Constants.languages.map { $0.key }.sorted()
//    @Published var audioDevices: [AudioDevice] = []
//    
//    @Published var errorMessage: String? = nil
//    @Published var showSettingsSheet: Bool = false
//    @Published var selectedTab: Tab // Use enum
//    
//    // For File Picker binding
//    @Published var showFilePicker: Bool = false
//    
//    
//    // MARK: Tab Enum
//    enum Tab: String, Identifiable, CaseIterable {
//        case transcribe = "Transcribe"
//        case stream = "Stream"
//        var id: String { rawValue }
//        var imageName: String {
//            switch self {
//            case .transcribe: return "book.pages"
//            case .stream: return "waveform.badge.mic"
//            }
//        }
//    }
//    
//    // MARK: Private State
//    private var cancellables = Set<AnyCancellable>()
//    private var currentProcessingTask: Task<Void, Never>? // For managing async operations
//    
//    // MARK: Initialization
//    init(transcriptionService: TranscriptionServiceProtocol, settings: AppSettings = AppSettings()) {
//        self.transcriptionService = transcriptionService
//        self.settings = settings
//        self.selectedTab = settings.selectedTab // Initialize from AppSettings
//        
//        // Initial data fetch
//        Task {
//            await transcriptionService.fetchAvailableModels(repoName: settings.repoName, localModelPathBase: settings.modelStoragePath)
//            self.updateModelFolderExistsStatus()
//#if os(macOS)
//            self.audioDevices = transcriptionService.getAudioDevices()
//            self.validateSelectedAudioDevice()
//#endif
//        }
//        
//        setupBindings()
//    }
//    
//    // MARK: Bindings Setup
//    private func setupBindings() {
//        // --- Service Publisher Bindings ---
//        transcriptionService.modelStatePublisher
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$modelState)
//        
//        transcriptionService.downloadProgressPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] progressUpdate in
//                self?.downloadProgress = progressUpdate.progress
//                self?.downloadDescription = progressUpdate.description
//            }
//            .store(in: &cancellables)
//        
//        transcriptionService.availableModelsPublisher
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$availableModels)
//        
//        transcriptionService.localModelsPublisher
//            .receive(on: DispatchQueue.main)
//            .handleEvents(receiveOutput: { [weak self] _ in self?.updateModelFolderExistsStatus() })
//            .assign(to: &$localModels)
//        
//        transcriptionService.audioLevelPublisher
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$audioSignal)
//        
//        transcriptionService.transcriptionUpdatePublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] update in self?.handleTranscriptionUpdate(update) }
//            .store(in: &cancellables)
//        
//        // --- Settings Change Reactions ---
//        // React to selectedModel change: Reset requires reload
//        settings.$selectedModel
//            .dropFirst // Don't react on init
//            .sink { [weak self] newModel in
//                print("Selected model changed to \(newModel). Resetting UI.")
//                self?.modelState = .unloaded
//                self?.resetTranscriptionState() // Clear text/segments
//            }
//            .store(in: &cancellables)
//        
//        // React to compute unit changes: Reset requires reload
//        settings.$encoderComputeUnits
//            .dropFirst()
//            .sink { [weak self] _ in self?.triggerModelReloadReset() }
//            .store(in: &cancellables)
//        
//        settings.$decoderComputeUnits
//            .dropFirst()
//            .sink { [weak self] _ in self?.triggerModelReloadReset() }
//            .store(in: &cancellables)
//        
//        // Persist selected tab changes
//        $selectedTab
//            .dropFirst()
//            .map { $0.rawValue }
//            .assign(to: &settings.$selectedTabString)
//    }
//    
//    // Helper called when compute units change
//    private func triggerModelReloadReset() {
//        print("Compute units changed. Resetting UI for model reload.")
//        self.modelState = .unloaded
//        self.resetTranscriptionState()
//    }
//    
//    
//    private func updateModelFolderExistsStatus() {
//        if let modelURL = transcriptionService.modelFolderURL {
//            self.modelFolderExists = FileManager.default.fileExists(atPath: modelURL.path)
//        } else {
//            self.modelFolderExists = false // No active model folder in service
//        }
//    }
//    
//#if os(macOS)
//    private func validateSelectedAudioDevice() {
//        if !audioDevices.contains(where: { $0.name == settings.selectedAudioInput }) && !audioDevices.isEmpty {
//            settings.selectedAudioInput = audioDevices.first!.name // Use the first available if selection is invalid
//            Logging.warning("Selected audio device was invalid, defaulting to '\(settings.selectedAudioInput)'")
//        } else if audioDevices.isEmpty {
//            settings.selectedAudioInput = "No Audio Input" // Set to placeholder if no devices found
//        }
//    }
//#endif
//    
//    
//    // MARK: Intents (Triggered by View)
//    
//    func loadSelectedModel() {
//        guard modelState == .unloaded else { return }
//        cancelOngoingTask() // Cancel previous task if any
//        resetTranscriptionState() // Clear old text/metrics
//        errorMessage = nil
//        
//        currentProcessingTask = Task {
//            do {
//                // Service publishers update modelState to .loading etc.
//                try await transcriptionService.loadModel(
//                    settings.selectedModel,
//                    from: settings.repoName,
//                    computeOptions: settings.getComputeOptions(),
//                    localModelPathBase: settings.modelStoragePath
//                )
//            } catch {
//                await handleError(error, context: "load model '\(settings.selectedModel)'")
//            }
//        }
//    }
//    
//    func deleteSelectedModel() async {
//        guard localModels.contains(settings.selectedModel) else { return }
////        guard !modelState.isProcessing else {
////            handleError(message: "Cannot delete model while it's being processed.")
////            return
////        }
//        cancelOngoingTask() // Cancel task before deletion
//        
//        let modelToDelete = settings.selectedModel
//        errorMessage = nil
//        
//        currentProcessingTask = Task {
//            do {
//                try await transcriptionService.deleteModel(modelToDelete, localModelPathBase: settings.modelStoragePath)
//                // Local models list updates via publisher
//                if settings.selectedModel == modelToDelete {
//                    // Select a new default: first available local, or global default
//                    let nextModel = localModels.first ?? WhisperKit.recommendedModels().default
//                    settings.selectedModel = nextModel
//                    print("Deleted model was selected. Switched selection to '\(nextModel)'")
//                    // Ensure UI reflects unload state if the active model was deleted
//                    if modelState != .unloaded {
//                        modelState = .unloaded
//                    }
//                }
//                updateModelFolderExistsStatus()
//            } catch {
//                await handleError(error, context: "delete model '\(modelToDelete)'")
//            }
//        }
//    }
//    
//    func toggleRecording() async { // Single func handles both modes
//        guard modelState == .loaded else {
//            await handleError(message: "Model not loaded.")
//            return
//        }
//        cancelOngoingTask() // Cancel previous file/stream task
//        
//        if isRecording { // --- STOP ---
//            currentProcessingTask = Task {
//                await transcriptionService.stopStreamingTranscription() // Let service handle finalizing
//            }
//        } else { // --- START ---
//            resetTranscriptionState() // Clear previous output
//            let options = transcriptionService.currentDecodingOptions(from: settings)
//            var deviceId: DeviceID? = nil
//#if os(macOS)
//            if settings.selectedAudioInput != "No Audio Input" {
//                deviceId = audioDevices.first { $0.name == settings.selectedAudioInput }?.id
//            }
//#endif
//            
//            currentProcessingTask = Task {
//                do {
//                    // Service publishers update isRecording = true, isTranscribing = true
//                    try await transcriptionService.startStreamingTranscription(deviceId: deviceId, options: options)
//                } catch {
//                    // Error already handled by transcriptionUpdate publisher sink
//                    await handleError(error, context: "start recording")
//                }
//            }
//        }
//    }
//    
//    // Triggered by the File Importer modifier in the View
//    func handleFileSelection(result: Result<[URL], Error>) async {
//        switch result {
//        case .success(let urls):
//            guard let url = urls.first else { return }
//            
//            // Start file transcription task
//            await transcribeFile(url: url)
//            
//        case .failure(let error):
//            await handleError(error, context: "select file")
//        }
//    }
//    
//    
//    func transcribeFile(url: URL) async { // Renamed to avoid clash with Task local var
//        guard modelState == .loaded else {
//            await handleError(message: "Model not loaded.")
//            return
//        }
//        guard url.startAccessingSecurityScopedResource() else {
//            await handleError(message: "Permission denied for file: \(url.lastPathComponent)")
//            return
//        }
//        defer { url.stopAccessingSecurityScopedResource() }
//        
//        cancelOngoingTask()
//        resetTranscriptionState()
//        errorMessage = nil
//        
//        let options = transcriptionService.currentDecodingOptions(from: settings)
//        
//        currentProcessingTask = Task {
//            do {
//                // Service publishers update isTranscribing
//                try await transcriptionService.transcribeFile(path: url.path, options: options)
//            } catch {
//                // Error handled by publisher sink
//                await handleError(error, context: "transcribe file '\(url.lastPathComponent)'")
//            }
//        }
//    }
//    
//    func openModelFolder() {
//#if os(macOS)
//        guard let url = transcriptionService.modelFolderURL else { return }
//        guard FileManager.default.fileExists(atPath: url.path) else {
//            handleError(message: "Model folder not found.")
//            return
//        }
//        NSWorkspace.shared.open(url)
//#endif
//    }
//    
//    func openRepoURL() {
//        guard let url = URL(string: "https://huggingface.co/\(settings.repoName)") else { return }
//#if os(macOS)
//        NSWorkspace.shared.open(url)
//#else
//        UIApplication.shared.open(url)
//#endif
//    }
//    
//    func copyTranscriptionToClipboard() {
//        let textToCopy: String
//        if settings.enableEagerDecoding && selectedTab == .stream {
//            textToCopy = confirmedEagerText + hypothesisEagerText
//        } else {
//            let combinedSegments = confirmedSegments + unconfirmedSegments
//            textToCopy = formatSegments(combinedSegments, withTimestamps: settings.enableTimestamps).joined(separator: "\n")
//        }
//        guard !textToCopy.isEmpty else { return }
//#if os(iOS) || os(visionOS)
//        UIPasteboard.general.string = textToCopy
//#elseif os(macOS)
//        NSPasteboard.general.clearContents()
//        NSPasteboard.general.setString(textToCopy, forType: .string)
//#endif
//        Logging.info("Transcription copied.")
//    }
//    
//    // MARK: State Update Handling
//    private func handleTranscriptionUpdate(_ update: TranscriptionUpdate) async {
//        // Handle Error
//        if let error = update.error, !(error is CancellationError) {
//            await handleError(error, context: "transcription update")
//        } else if update.error == nil {
//            errorMessage = nil // Clear potentially stale error on success
//        }
//        
//        // Update State (ensure these are distinct updates to avoid redundant UI refreshes)
//        if self.isRecording != update.isRecording { self.isRecording = update.isRecording }
//        if self.isTranscribing != update.isTranscribing { self.isTranscribing = update.isTranscribing }
//        
//        // Update Text/Segments
//        if settings.enableEagerDecoding && selectedTab == .stream {
//            if self.confirmedEagerText != update.confirmedText { self.confirmedEagerText = update.confirmedText }
//            if self.hypothesisEagerText != update.hypothesisText { self.hypothesisEagerText = update.hypothesisText }
//            // Clear standard segments if switching to eager
//            if !confirmedSegments.isEmpty { confirmedSegments = [] }
//            if !unconfirmedSegments.isEmpty { unconfirmedSegments = [] }
//        } else {
//            // Use the service's segment separation logic (less efficient full replace/filter shown here)
//            let newConfirmed = update.segments.filter { s in confirmedSegments.contains { $0.id == s.id } || s.end <= (confirmedSegments.last?.end ?? -1.0) }
//            let newUnconfirmed = update.segments.filter { s in s.end > (newConfirmed.last?.end ?? -1.0) }
//            
//            if self.confirmedSegments != newConfirmed { self.confirmedSegments = newConfirmed }
//            if self.unconfirmedSegments != newUnconfirmed { self.unconfirmedSegments = newUnconfirmed }
//            
//            // Clear eager text if switching to standard
//            if !confirmedEagerText.isEmpty { confirmedEagerText = "" }
//            if !hypothesisEagerText.isEmpty { hypothesisEagerText = "" }
//        }
//        
//        if self.decoderPreviewText != update.currentDecodingText { self.decoderPreviewText = update.currentDecodingText }
//        
//        // Update Metrics
//        if let newMetrics = update.metrics, self.metrics != newMetrics {
//            self.metrics = newMetrics
//        }
//        
//        // If transcription stopped, ensure recording is also stopped
//        if !update.isTranscribing && self.isRecording {
//            self.isRecording = false
//        }
//    }
//    
//    // MARK: Error Handling
//    private func handleError(_ error: Error? = nil, message: String? = nil, context: String? = nil) async {
//        var finalMessage = message ?? error?.localizedDescription ?? "An unknown error occurred."
//        if let context = context {
//            finalMessage = "Error during \(context): \(finalMessage)"
//        }
//        print("[ViewModel ERROR] \(finalMessage)") // Log detailed error
//        self.errorMessage = finalMessage // Set user-facing message
//        
//        // Ensure processing state is reset on error
//        if isTranscribing { isTranscribing = false }
//        if isRecording { isRecording = false } // Usually stop recording on error too
//        // Consider telling service to stop capture explicitly if error originated elsewhere
//        await transcriptionService.stopStreamingTranscription()
//    }
//    
//    // MARK: Task Management
//    private func cancelOngoingTask() {
//        currentProcessingTask?.cancel()
//        currentProcessingTask = nil
//        // Service handles its own cancellation via stopStreamingTranscription or internal checks
//    }
//    
//    // MARK: Formatting Helpers
//    private func formatSegments(_ segments: [TranscriptionSegment], withTimestamps: Bool) -> [String] {
//        segments.map { segment in
//            let timestampPrefix = withTimestamps ? "[\(String(format: "%.2f", segment.start)) → \(String(format: "%.2f", segment.end))] " : ""
//            return timestampPrefix + (segment.text.isEmpty ? "" : segment.text)
//        }
//    }
//    
//    // Called by UI, resets UI state, tells service to reset internal state
//    func resetStateAndService() {
//        cancelOngoingTask()
//        resetTranscriptionState()
//        transcriptionService.resetServiceState() // Tell service to clear its state too
//    }
//    
//    // Resets only the ViewModel's transcription output related state
//    func resetTranscriptionState() {
//        errorMessage = nil
//        confirmedSegments = []
//        unconfirmedSegments = []
//        confirmedEagerText = ""
//        hypothesisEagerText = ""
//        decoderPreviewText = ""
//        metrics = .init()
//        audioSignal = .init()
//        // Do NOT reset isRecording/isTranscribing here
//    }
//    
//    // MARK: Application Info (Read-only computed properties)
//    var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A" }
//    var appBuild: String { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A" }
//    var deviceName: String { WhisperKit.deviceName() }
//    var osVersion: String {
//#if os(iOS)
//        UIDevice.current.systemVersion
//#elseif os(macOS)
//        let v = ProcessInfo.processInfo.operatingSystemVersion; return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
//#else
//        "N/A"
//#endif
//    }
//}
//
//// MARK: - SwiftUI Views
//
//// MARK: - Main Content View
//struct ContentView: View {
//    // Initialize ViewModel & Settings here, or receive from App struct
//    @StateObject private var settings = AppSettings()
//    // Inject TranscriptionService instance - good practice for testability
//    @StateObject private var viewModel = ContentViewModel(transcriptionService: TranscriptionService(), settings: AppSettings())
//    
//    
//    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
//    
//    var body: some View {
//        NavigationSplitView(columnVisibility: $columnVisibility) {
//            SidebarView()
//                .navigationTitle("WhisperAX")
//                .navigationSplitViewColumnWidth(min: 280, ideal: 320) // Adjusted width
//        } detail: {
//            DetailView()
//        }
//        // Pass VM and Settings down explicitly or via environment
//        .environmentObject(viewModel)
//        .environmentObject(settings)
//        .alert("Error", isPresented: Binding( // Centralized error alert
//            get: { viewModel.errorMessage != nil },
//            set: { _, _ in viewModel.errorMessage = nil } // Clear error on dismiss
//                                            )) {
//                                                Button("OK", role: .cancel) {}
//                                            } message: {
//                                                Text(viewModel.errorMessage ?? "An unknown error occurred.")
//                                            }
//                                            .onChange(of: viewModel.errorMessage) { _, newValue in // Debug print errors
//                                                if let msg = newValue { print("UI Alert: \(msg)") }
//                                            }
//    }
//}
//
//// MARK: - Sidebar View
//struct SidebarView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) { // Increased spacing
//            ModelSelectorView() // Card 1: Model Management
//            ComputeUnitsView() // Card 2: Compute Units
//            TabSelectionView() // Simple List for Mode selection
//            Spacer() // Pushes App Info to bottom
//            AppInfoView()
//        }
//        .padding()
//    }
//}
//
//// MARK: - Detail View
//struct DetailView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    
//    var body: some View {
//        VStack(spacing: 0) { // Remove spacing, dividers handle it
//            TranscriptionDisplayView()
//                .layoutPriority(1) // Ensure it expands
//            
//            Divider().padding(.vertical, 10) // Provide visual separation
//            
//            ControlsView() // Contains settings/actions
//        }
//        .padding()
//        .toolbar {
//            ToolbarItem {
//                Button {
//                    viewModel.copyTranscriptionToClipboard()
//                } label: {
//                    Label("Copy Text", systemImage: "doc.on.doc")
//                }
//                .keyboardShortcut("c", modifiers: .command)
//                .disabled(viewModel.confirmedEagerText.isEmpty && viewModel.confirmedSegments.isEmpty && viewModel.unconfirmedSegments.isEmpty) // Disable if nothing to copy
//            }
//        }
//        // File importer attached here, triggered by viewModel.showFilePicker
//        .fileImporter(
//            isPresented: $viewModel.showFilePicker, // Bind to ViewModel state
//            allowedContentTypes: [.audio],
//            allowsMultipleSelection: false
//        ) { result in
//            viewModel.handleFileSelection(result: result)
//        }
//    }
//}
//
//// MARK: - Model Selector View (GroupBox Card)
//struct ModelSelectorView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//    
//    var body: some View {
//        GroupBox("Model Management") {
//            VStack(alignment: .leading, spacing: 12) { // Consistent spacing
//                HStack {
//                    modelStatusIndicator
//                    Spacer()
//                    modelPickerOrProgress // Combined picker/loading state
//                    Spacer() // Ensure picker doesn't push buttons off
//                    modelActionButtons
//                }
//                .frame(minHeight: 30) // Ensure row has minimum height
//                
//                modelLoadingProgressView // Shows progress bar or Load button
//            }
//            .padding(EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 5)) // Reduced padding inside box
//        }
//    }
//    
//    @ViewBuilder private var modelStatusIndicator: some View {
//        HStack(spacing: 5) {
//            Image(systemName: "circle.fill")
//               // .foregroundColor(viewModel.modelState.color)
//                .font(.title3) // Slightly larger indicator
//                .symbolEffect(.variableColor.iterative.reversing, isActive: viewModel.modelState == .loading)
//            Text(viewModel.modelState.description)
//                .font(.headline)
//        }
//    }
//    
//    @ViewBuilder private var modelPickerOrProgress: some View {
//        if viewModel.availableModels.isEmpty && !(viewModel.modelState == .loading) {
//            Text("Fetching models...")
//                .font(.caption)
//                .foregroundColor(.secondary)
//        } else if !viewModel.availableModels.isEmpty {
//            Picker("Model", selection: $settings.selectedModel) {
//                ForEach(viewModel.availableModels, id: \.self) { model in
//                    HStack {
//                        Image(systemName: viewModel.localModels.contains(model) ? "checkmark.circle.fill" : "arrow.down.circle")
//                            .foregroundColor(viewModel.localModels.contains(model) ? .green : .accentColor)
//                        Text(model.friendlyName).tag(model)
//                    }
//                }
//            }
//            .labelsHidden()
//            .pickerStyle(.menu)
//            .frame(maxWidth: 180) // Constrain width
//            .disabled(viewModel.modelState.isProcessing)
//        } else {
//            ProgressView().scaleEffect(0.8) // Loading indicator if initializing
//        }
//    }
//    
//    private var modelActionButtons: some View {
//        HStack(spacing: 15) {
//            deleteButton
//#if os(macOS)
//            folderButton
//#endif
//            repoLinkButton
//        }
//    }
//    
//    @ViewBuilder private var modelLoadingProgressView: some View {
//        if viewModel.modelState == .loading {
//            VStack(alignment: .leading) {
//                ProgressView(value: viewModel.downloadProgress, total: 1.0)
//                    .animation(.linear, value: viewModel.downloadProgress) // Animate progress change
//                Text(viewModel.downloadDescription)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//            }
//            .padding(.top, 5)
//        } else if viewModel.modelState == .unloaded {
//            Button {
//                viewModel.loadSelectedModel()
//            } label: {
//                Label("Load Model", systemImage: "bolt.fill")
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.top, 5)
//            .disabled(settings.selectedModel.isEmpty || viewModel.availableModels.isEmpty)
//            // Add transition for Load button appearing/disappearing
//            .transition(.opacity.combined(with: .scale(scale: 0.9)))
//        }
//    }
//    
//    private var deleteButton: some View {
//        Button { viewModel.deleteSelectedModel() } label: { Image(systemName: "trash") }
//          //  .help("Delete '\(settings.selectedModel.friendlyName)'")
//            .buttonStyle(.plain) // Use plain to integrate better with GroupBox
//            .foregroundColor(.red)
//           // .disabled(!viewModel.localModels.contains(settings.selectedModel) || viewModel.modelState.isProcessing)
//    }
//    
//#if os(macOS)
//    private var folderButton: some View {
//        Button { viewModel.openModelFolder() } label: { Image(systemName: "folder") }
//            .help("Show Model Folder")
//            .buttonStyle(.plain)
//            .disabled(!viewModel.modelFolderExists || viewModel.modelState.isProcessing)
//    }
//#endif
//    
//    private var repoLinkButton: some View {
//        Button { viewModel.openRepoURL() } label: { Image(systemName: "link.circle") }
//            .help("Open Hugging Face Repo")
//            .buttonStyle(.plain)
//    }
//}
//
//// MARK: - Compute Units View (GroupBox Card)
//struct ComputeUnitsView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//    @State private var isExpanded: Bool = true // Keep expanded by default
//    
//    var body: some View {
//        GroupBox {
//            DisclosureGroup("Compute Units", isExpanded: $isExpanded) {
//                VStack(spacing: 8) {
//                    computeUnitPicker(label: "Encoder", selection: $settings.encoderComputeUnits)
//                    computeUnitPicker(label: "Decoder", selection: $settings.decoderComputeUnits)
//                }
//                .padding(.top, 5)
//            }
//            //.disabled(viewModel.modelState.isProcessing) // Disable changes during model load/process
//        }
//    }
//    
//    private func computeUnitPicker(label: String, selection: Binding<MLComputeUnits>) -> some View {
//        HStack {
//            // No status indicator here, as it's driven by the overall model state
//            Text(label).frame(width: 80, alignment: .leading) // Align labels
//            Spacer()
//            Picker(label, selection: selection) {
//                Text("CPU").tag(MLComputeUnits.cpuOnly)
//                Text("GPU").tag(MLComputeUnits.cpuAndGPU)
//                Text("ANE").tag(MLComputeUnits.cpuAndNeuralEngine) // Use ANE for Neural Engine
//                Text("All").tag(MLComputeUnits.all)
//            }
//            .labelsHidden()
//            .pickerStyle(.segmented) // Segmented style for concise options
//            .frame(maxWidth: 200) // Adjust width
//        }
//    }
//}
//
//// MARK: - Tab Selection View
//struct TabSelectionView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    
//    var body: some View {
//        Picker("Mode", selection: $viewModel.selectedTab) {
//            ForEach(ContentViewModel.Tab.allCases) { tab in
//                Label(tab.rawValue, systemImage: tab.imageName).tag(tab)
//            }
//        }
//        .pickerStyle(.segmented) // Use segmented control for main mode switching
//        .disabled(viewModel.modelState != .loaded) // Disable if model not loaded
//        .opacity(viewModel.modelState != .loaded ? 0.6 : 1.0)
//    }
//}
//
//// MARK: - App Info View
//struct AppInfoView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) { // Added spacing
//            Text("WhisperAX v\(viewModel.appVersion) (\(viewModel.appBuild))").bold() // Make version bolder
//            Divider()
//            Text("Device: \(viewModel.deviceName)")
//            Text("OS: \(viewModel.osVersion)")
//        }
//        .font(.caption)
//        .foregroundColor(.secondary)
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
//// MARK: - Transcription Display View (Improved Card & Layout)
//struct TranscriptionDisplayView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//    @Namespace var bottomID // Namespace for programmatic scrolling
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) { // Add spacing
//            // Optional Audio Level Meter (Improved Styling)
//            if viewModel.isRecording { // Show only when recording actively
//                SignalEnergyView(energy: viewModel.audioSignal.bufferEnergy, threshold: Float(settings.silenceThreshold))
//                    .frame(height: 30)
//                    .padding(.horizontal, 5).padding(.vertical, 3) // Minimal padding
//                    .background(.quaternary.opacity(0.5)) // More subtle background
//                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
//                    .transition(.scale(scale: 0.9).combined(with: .opacity)) // Add transition
//            }
//            
//            // Main Transcription Area (GroupBox Card)
//            GroupBox("Transcription Output") {
//                ScrollViewReader { scrollProxy in
//                    ScrollView {
//                        transcriptionContent // Extracted content view
//                            .padding(5) // Inner padding for text content
//                            .onChange(of: viewModel.confirmedSegments.count + viewModel.unconfirmedSegments.count) { _, _ in scrollToBottom(proxy: scrollProxy) } // Scroll on segment change
//                            .onChange(of: viewModel.confirmedEagerText) { _, _ in scrollToBottom(proxy: scrollProxy) }
//                            .onChange(of: viewModel.hypothesisEagerText) { _, _ in scrollToBottom(proxy: scrollProxy) }
//                            .onChange(of: viewModel.decoderPreviewText) { _, _ in scrollToBottom(proxy: scrollProxy) } // Scroll on preview change too
//                    }
//                }
//                fileTranscriptionProgressView // Progress bar overlay at bottom if needed
//            }
//            // Height control managed by VStack & layoutPriority
//        }
//    }
//    
//    @ViewBuilder
//    private var transcriptionContent: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            if settings.enableEagerDecoding && viewModel.selectedTab == .stream {
//                eagerTextView
//            } else {
//                standardTextView
//            }
//            decoderPreviewSection // Optional preview at the end
//            
//            // Invisible element at the bottom to scroll to
//            Spacer().frame(height: 0).id("bottom")
//        }
//        .textSelection(.enabled)
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//    
//    // Standard Segment Display
//    @ViewBuilder private var standardTextView: some View {
//        let segmentsToDisplay = viewModel.confirmedSegments + viewModel.unconfirmedSegments
//        
//        if segmentsToDisplay.isEmpty && viewModel.isTranscribing {
//            placeholderText("Listening...")
//        } else if segmentsToDisplay.isEmpty && !viewModel.isTranscribing {
//            placeholderText("No transcription available.")
////        } else {
////            ForEach(segmentsToDisplay) { segment in // Use segments直接 (requires Hashable/Identifiable)
////                let isConfirmed = viewModel.confirmedSegments.contains { $0.id == segment.id }
////                SegmentView(segment: segment, isConfirmed: isConfirmed, showTimestamps: settings.enableTimestamps)
////                    .padding(.bottom, 2) // Small spacing between segments
////            }
//        }
//    }
//    
//    // Eager Text Display
//    @ViewBuilder private var eagerTextView: some View {
//        let hasText = !viewModel.confirmedEagerText.isEmpty || !viewModel.hypothesisEagerText.isEmpty
//        if !hasText && viewModel.isTranscribing {
//            placeholderText("Listening (Eager Mode)...")
//        } else if !hasText && !viewModel.isTranscribing {
//            placeholderText("No transcription available.")
//        } else {
//            // Combine styles within a single Text view for better layout flow
//            Text(viewModel.confirmedEagerText)
//                .fontWeight(.medium)
//                .foregroundColor(.primary)
//            + Text(viewModel.hypothesisEagerText.isEmpty ? "" : " " + viewModel.hypothesisEagerText) // Add space only if hypothesis exists
//                .fontWeight(.regular)
//                .foregroundColor(.secondary.opacity(0.8)) // Slightly less prominent hypothesis
//        }
//    }
//    
//    // Placeholder Text View
//    @ViewBuilder private func placeholderText(_ text: String) -> some View {
//        Text(text)
//            .font(.headline)
//            .foregroundColor(.secondary)
//            .frame(maxWidth: .infinity, alignment: .center) // Center placeholder
//            .padding()
//    }
//    
//    // Decoder Preview Section
//    @ViewBuilder private var decoderPreviewSection: some View {
//        if settings.enableDecoderPreview && !viewModel.decoderPreviewText.isEmpty {
//            Divider().padding(.vertical, 5)
//            VStack(alignment: .leading) {
//                Text("Decoder Preview").font(.caption.weight(.semibold)).foregroundColor(.orange)
//                Text(viewModel.decoderPreviewText).font(.caption).foregroundColor(.orange.opacity(0.8))
//            }
//        }
//    }
//    
//    // File Transcription Progress Bar View
//    @ViewBuilder private var fileTranscriptionProgressView: some View {
//        if viewModel.isTranscribing && viewModel.selectedTab == .transcribe && !viewModel.isRecording {
//            ProgressView() // Simple indeterminate for now
//                .progressViewStyle(.linear)
//                .padding(.horizontal, 5).padding(.bottom, 5) // Padding within GroupBox
//                .transition(.opacity)
//        }
//    }
//    
//    // Helper function to scroll to bottom
//    private func scrollToBottom(proxy: ScrollViewProxy) {
//        withAnimation(.easeOut(duration: 0.2)) { // Smooth scroll animation
//            proxy.scrollTo("bottom", anchor: .bottom)
//        }
//    }
//}
//// Separate view for individual segments for better structure
//struct SegmentView: View {
//    let segment: TranscriptionSegment
//    let isConfirmed: Bool
//    let showTimestamps: Bool
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 4) { // Align timestamp and text
//            if showTimestamps {
//                Text("[\(String(format: "%.2f", segment.start)) → \(String(format: "%.2f", segment.end))]")
//                    .font(.caption.monospacedDigit()) // Monospaced for alignment
//                    .foregroundColor(isConfirmed ? .secondary : .secondary.opacity(0.6))
//                    .frame(minWidth: 110, alignment: .leading) // Give timestamp fixed width
//            }
//            Text(segment.text)
//                .fontWeight(isConfirmed ? .medium : .regular)
//                .foregroundColor(isConfirmed ? .primary : .secondary.opacity(0.8))
//                .frame(maxWidth: .infinity, alignment: .leading) // Allow text to wrap
//        }
//        .id(segment.id) // Make sure segment has a unique ID
//    }
//}
//
//
//// MARK: - Signal Energy View (Visualizer)
//struct SignalEnergyView: View {
//    let energy: [Float]
//    let threshold: Float
//    private let maxPoints = 200 // Limit visual complexity
//    private let scale: CGFloat = 2.5 // Visual magnification
//    private let barWidth: CGFloat = 2.0 // Fixed width for bars
//    
//    var body: some View {
//        Canvas { context, size in
//            let displayEnergy = energy.suffix(maxPoints)
//            let spacing = max(0, (size.width - CGFloat(displayEnergy.count) * barWidth) / CGFloat(displayEnergy.count - 1)) // Calculate spacing
//            let maxBarHeight = size.height
//            
//            var x: CGFloat = 0
//            for level in displayEnergy {
//                let isAbove = level > threshold
//                let height = min(maxBarHeight, max(1.0, CGFloat(level) * maxBarHeight * scale)) // Ensure min height 1
//                let bar = Path(CGRect(x: x, y: maxBarHeight - height, width: barWidth, height: height))
//                context.fill(bar, with: .color(isAbove ? .green : .red))
//                x += barWidth + spacing
//            }
//        }
//        .opacity(0.7) // Make it slightly transparent
//        .clipped()
//    }
//}
//
//// MARK: - Controls View (Bottom Action Area)
//struct ControlsView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//    
//    var body: some View {
//        VStack(spacing: 15) {
//            BasicSettingsView() // Language, Task, Metrics
//            
//            GroupBox("Actions") {
//                modeSpecificControls
//                    .padding(5) // Inner padding for GroupBox content
//            }
//        }
////        .sheet(isPresented: $viewModel.showSettingsSheet) { // Present Settings sheet
////            SettingsView() // Pass environment objects implicitly
////        }
//    }
//    
//    @ViewBuilder private var modeSpecificControls: some View {
//        switch viewModel.selectedTab {
//        case .transcribe: transcribeModeControls
//        case .stream: streamModeControls
//        }
//    }
//    
//    // --- Transcribe Mode Controls ---
//    private var transcribeModeControls: some View {
//        VStack(spacing: 15) {
//            controlBar // Reset, Device (macOS), Settings
//            HStack(spacing: 20) {
//                fileButton
//                recordButton(isStream: false)
//            }
//        }
//    }
//    
//    // --- Stream Mode Controls ---
//    private var streamModeControls: some View {
//        VStack(spacing: 15) {
//            controlBar
//            ZStack { // Center record button, overlay status
//                recordButton(isStream: true)
//                if viewModel.isRecording { streamStatusOverlay }
//            }
//            .frame(minHeight: 70) // Ensure space for overlay
//        }
//    }
//    
//    // --- Common Control Bar Elements ---
//    private var controlBar: some View {
//        HStack {
//            resetButton
//            Spacer()
//#if os(macOS)
//            audioDevicePicker.disabled(viewModel.isRecording || viewModel.isTranscribing)
//#else
//            Spacer() // Keep balance
//#endif
//            Spacer()
//            settingsButton
//        }
//    }
//    
//    private var resetButton: some View {
//        Button { viewModel.resetStateAndService() } label: {
//            //Label("Reset Text", systemImage: "arrow.clockwise")
//            Label("Reset All", systemImage: "arrow.clockwise.circle.fill") // Clarify it resets more
//        }
//        .buttonStyle(.borderless)
//        .disabled(viewModel.isTranscribing || viewModel.isRecording)
//        .help("Reset transcription state and audio buffer")
//    }
//    
//    private var settingsButton: some View {
//        Button { viewModel.showSettingsSheet = true } label: {
//            Label("Settings", systemImage: "slider.horizontal.3")
//        }
//        .buttonStyle(.borderless)
//    }
//    
//#if os(macOS)
//    private var audioDevicePicker: some View {
//        Picker("Input", selection: $settings.selectedAudioInput) {
//            if viewModel.audioDevices.isEmpty { Text("No Input").tag("No Audio Input") }
//            else { ForEach(viewModel.audioDevices) { Text($0.name).tag($0.name) } }
//        }
//        .labelsHidden().frame(maxWidth: 180)
//    }
//#endif
//    
//    // --- Action Buttons ---
//    private var fileButton: some View {
//        Button { viewModel.showFilePicker = true } label: {
//            VStack {
//                Image(systemName: "doc.text.fill").font(.title2)
//                Text("FROM FILE").font(.headline)
//            }
//        }
//      //  .buttonStyle(CardButtonStyle(enabled: viewModel.modelState == .loaded && !viewModel.isRecording && !viewModel.isTranscribing))
//    }
//    
//    private func recordButton(isStream: Bool) -> some View {
//        Button { viewModel.toggleRecording() } label: { // Single toggle action
//            if viewModel.isRecording {
//                Image(systemName: "stop.circle.fill")
//                    .resizable().scaledToFit().frame(width: 60, height: 60)
//                    .foregroundColor(.red) // Always red when recording
//            } else {
//                VStack {
//                    Image(systemName: isStream ? "record.circle" : "mic.circle.fill").font(.title)
//                    Text(isStream ? "STREAM" : "RECORD").font(.headline)
//                }
//            }
//        }
//       // .buttonStyle(CardButtonStyle)
//        .contentTransition(.symbolEffect(.replace))
//    }
//    
//    // --- Stream Status Overlay ---
//    private var streamStatusOverlay: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("Enc: \(viewModel.metrics.currentEncodingLoops)")
//                Text("Dec: \(viewModel.metrics.currentDecodingLoops)")
//            }.font(.caption2).foregroundColor(.secondary) // Smaller caption
//            Spacer()
//            Text("\(String(format: "%.1f", viewModel.audioSignal.bufferSeconds)) s buffer")
//                .font(.caption2).foregroundColor(.secondary)
//        }
//        .padding(.horizontal)
//        .offset(y: 40) // Position below button
//        .transition(.opacity.combined(with: .offset(y: 10))) // Add transition
//    }
//}
//
//// MARK: - Basic Settings View (Task, Language, Metrics)
//struct BasicSettingsView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//    
//    var body: some View {
//        VStack(spacing: 12) { // Consistent spacing
//            Picker("Task", selection: $settings.selectedTask) {
//                Text("Transcribe").tag("transcribe")
//                Text("Translate").tag("translate")
//            }
//            .pickerStyle(SegmentedPickerStyle())
//           //s .disabled(viewModel.isBusy) // Unified busy state check
//            
//            LabeledContent {
//                Picker("Language", selection: $settings.selectedLanguage) {
//                    ForEach(viewModel.availableLanguages, id: \.self) { language in
//                        Text(language.capitalized).tag(language)
//                    }
//                }
//                // Simplification: Disable only when busy. Assume multilingual status is handled by available languages?
//               // .disabled(viewModel.isBusy)
//            } label: {
//                Label("Language", systemImage: "globe")
//            }
//            
//            metricsDisplay // Extracted metrics view
//        }
//    }
//    
//    private var metricsDisplay: some View {
//        
//        Divider() // Separate metrics visually
//        
//        return HStack {
//            metricItem(value: viewModel.metrics.realTimeFactor, unit: "RTF", precision: 2)
//            Spacer()
//            metricItem(value: viewModel.metrics.tokensPerSecond, unit: "tok/s", precision: 0)
//#if os(macOS)
//            Spacer()
//            metricItem(value: viewModel.metrics.speedFactor, unit: "x Speed", precision: 1)
//#endif
//            Spacer()
//            metricItem(value: abs(viewModel.metrics.firstTokenTime), unit: "s First", precision: 2) // Show absolute time
//        }
//        .font(.system(size: 11, design: .monospaced)) // Smaller monospaced font
//        .foregroundColor(.secondary)
//        .lineLimit(1)
//        .padding(.top, 5) // Space after divider
//    }
//    
//    @ViewBuilder func metricItem(value: Double, unit: String, precision: Int) -> some View {
//        let number = (value.isNaN || value.isInfinite) ? "--" : String(format: "%.\(precision)f", value)
//        Text("\(number) \(unit)")
//    }
//}
////
////// MARK: - Reusable Card Button Style
////struct CardButtonStyle: ButtonStyle {
////    var enabled: Bool = true
////    var isRecording: Bool = false
////
////    func makeBody(configuration: Configuration) -> some View {
////        configuration.
