//
//  TranscriptionService_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

//  For licensing see accompanying LICENSE.md file.
//  Copyright © 2024 Argmax, Inc. All rights reserved.
//
//  This service encapsulates WhisperKit interactions and manages transcription state.
//

import Foundation
import WhisperKit
import AVFoundation
import Combine
import CoreML // For MLComputeUnits

// MARK: - Service Protocol (Optional but good practice)

protocol TranscriptionServiceProtocol {
    // Publishers for reactive UI updates
    var modelStatePublisher: AnyPublisher<ModelState, Never> { get }
    var transcriptionUpdatePublisher: AnyPublisher<TranscriptionUpdate, Never> { get }
    var downloadProgressPublisher: AnyPublisher<Double, Never> { get }
    var audioLevelPublisher: AnyPublisher<AudioSignalInfo, Never> { get }
    var availableModelsPublisher: AnyPublisher<[String], Never> { get }
    var localModelsPublisher: AnyPublisher<[String], Never> { get }
    
    // Direct state access (use with caution, prefer publishers)
    var currentModelState: ModelState { get }
    var modelFolderURL: URL? { get }
    var audioProcessor: AudioProcessor { get } // Allow ViewModel access if needed for specific controls
    
    // Asynchronous operations
    func fetchAvailableModels(repoName: String) async
    func loadModel(
        _ modelName: String,
        from repoName: String,
        computeOptions: ModelComputeOptions,
        localModelPathBase: String // e.g., "huggingface/models/argmaxinc/whisperkit-coreml"
    ) async throws
    func transcribeFile(path: String, options: DecodingOptions) async throws
    func startStreamingTranscription(deviceId: DeviceID?, options: DecodingOptions) async throws
    
    // Synchronous operations
    func deleteModel(_ modelName: String, localModelPathBase: String) async throws
    func stopStreamingTranscription()
    func getAudioDevices() async -> [AudioDevice] // macOS specific
    func currentDecodingOptions(from settings: AppSettings) async -> DecodingOptions
    
    // Permissions
    func hasMicrophonePermission() async -> Bool
}

// MARK: - Transcription Update Structure

struct TranscriptionUpdate: Equatable {
    var segments: [TranscriptionSegment] = []       // For standard display
    var confirmedText: String = ""                  // For Eager mode display
    var hypothesisText: String = ""                 // For Eager mode display (unconfirmed part)
    var currentDecodingText: String = ""            // Live preview from decoder callback
    var metrics: TranscriptionMetrics? = nil        // Performance metrics
    var error: Error? = nil                         // Any error that occurred
    var isTranscribing: Bool = false                // Indicates active processing (file or stream)
    
    // Custom Equatable conformance to ignore the error field for simple comparisons
    static func == (lhs: TranscriptionUpdate, rhs: TranscriptionUpdate) -> Bool {
        return lhs.segments == rhs.segments &&
        lhs.confirmedText == rhs.confirmedText &&
        lhs.hypothesisText == rhs.hypothesisText &&
        lhs.currentDecodingText == rhs.currentDecodingText &&
        lhs.metrics == rhs.metrics &&
        lhs.isTranscribing == rhs.isTranscribing
        // Error is intentionally ignored for equality checks
    }
    
    // Nested Metrics structure
    struct TranscriptionMetrics: Equatable {
        var tokensPerSecond: Double = 0
        var realTimeFactor: Double = 0
        var speedFactor: Double = 0 // macOS specific concept perhaps?
        var firstTokenTime: TimeInterval = 0 // Relative to pipeline start
        var pipelineStart: TimeInterval = 0  // Absolute start time (epoch)
        var currentLag: TimeInterval = 0     // Duration of last decoding loop
        var currentFallbacks: Int = 0
        var currentEncodingLoops: Int = 0
        var currentDecodingLoops: Int = 0
        var totalInferenceTime: TimeInterval = 0
        var modelLoadingTime: TimeInterval = 0 // Added from original
    }
}

// MARK: - Audio Signal Info Structure

struct AudioSignalInfo: Equatable {
    var bufferEnergy: [Float] = []
    var bufferSeconds: Double = 0
}

// MARK: - Custom Error Enum

enum TranscriptionServiceError: LocalizedError {
    case whisperKitNotInitialized
    case modelNotLoaded
    case microphonePermissionDenied
    case fileNotFound(path: String)
    case modelFolderAccessError(path: String)
    case downloadFailed(model: String)
    case prewarmFailed(model: String)
    case loadFailed(model: String)
    case eagerModeRequiresWordTimestamps(model: String)
    case transcriptionFailed(underlyingError: Error?)
    
    var errorDescription: String? {
        switch self {
        case .whisperKitNotInitialized: return "WhisperKit has not been initialized."
        case .modelNotLoaded: return "A Whisper model is not loaded."
        case .microphonePermissionDenied: return "Microphone access was denied. Please grant permission in System Settings."
        case .fileNotFound(let path): return "Audio file not found at path: \(path)"
        case .modelFolderAccessError(let path): return "Could not access or create model folder at: \(path)"
        case .downloadFailed(let model): return "Failed to download model: \(model)"
        case .prewarmFailed(let model): return "Failed to prewarm model: \(model)"
        case .loadFailed(let model): return "Failed to load model: \(model)"
        case .eagerModeRequiresWordTimestamps(let model): return "Eager mode requires word timestamps, which are not supported by the current model: \(model)."
        case .transcriptionFailed(let underlyingError):
            if let error = underlyingError {
                return "Transcription failed: \(error.localizedDescription)"
            } else {
                return "An unknown transcription error occurred."
            }
        }
    }
}

// MARK: - Service Implementation

@MainActor // Ensures most interactions with WhisperKit happen on MainActor if needed, or dispatch internally
class TranscriptionService: TranscriptionServiceProtocol, ObservableObject {
    
    private var whisperKit: WhisperKit?
    let audioProcessor = AudioProcessor()
    
    // --- Publishers ---
    private let modelStateSubject = CurrentValueSubject<ModelState, Never>(.unloaded)
    var modelStatePublisher: AnyPublisher<ModelState, Never> { modelStateSubject.eraseToAnyPublisher() }
    
    private let transcriptionUpdateSubject = PassthroughSubject<TranscriptionUpdate, Never>()
    var transcriptionUpdatePublisher: AnyPublisher<TranscriptionUpdate, Never> { transcriptionUpdateSubject.eraseToAnyPublisher() }
    
    private let downloadProgressSubject = CurrentValueSubject<Double, Never>(0.0)
    var downloadProgressPublisher: AnyPublisher<Double, Never> { downloadProgressSubject.eraseToAnyPublisher() }
    
    private let audioLevelSubject = PassthroughSubject<AudioSignalInfo, Never>()
    var audioLevelPublisher: AnyPublisher<AudioSignalInfo, Never> { audioLevelSubject.eraseToAnyPublisher() }
    
    private let availableModelsSubject = CurrentValueSubject<[String], Never>([])
    var availableModelsPublisher: AnyPublisher<[String], Never> { availableModelsSubject.eraseToAnyPublisher() }
    
    private let localModelsSubject = CurrentValueSubject<[String], Never>([])
    var localModelsPublisher: AnyPublisher<[String], Never> { localModelsSubject.eraseToAnyPublisher() }
    
    // --- State ---
    private var currentTranscriptionTask: Task<Void, Error>? // Streaming task
    private(set) var localModels: [String] = []
    private(set) var availableModels: [String] = []
    var modelFolderURL: URL? { whisperKit?.modelFolder }
    var currentModelState: ModelState { modelStateSubject.value }
    
    // Streaming State (Standard & Eager)
    private var lastConfirmedSegmentEndSeconds: Float = 0.0
    private var requiredSegmentsForConfirmation: Int = 4 // TODO: Make configurable via DecodingOptions/AppSettings
    private var confirmedSegments: [TranscriptionSegment] = []
    private var unconfirmedSegments: [TranscriptionSegment] = []
    private var eagerResults: [TranscriptionResult?] = []   // History for comparison
    private var prevResult: TranscriptionResult?            // Previous loop's result
    private var lastAgreedSeconds: Float = 0.0              // Timestamp of last confirmed word boundary
    private var prevWords: [WordTiming] = []                // Words from previous loop's result (relevant window)
    private var lastAgreedWords: [WordTiming] = []          // Confirmed prefix for next prediction
    private var confirmedWords: [WordTiming] = []           // Accumulating confirmed words
    
    // Decoder Preview State
    private var currentDecodingTextPreview: String = ""
    private var currentDecodingFallbacks: Int = 0
    
    // MARK: - Initialization & Model Management
    
    init() {
        // Initial state setup is implicitly handled by defaults
        Logging.info("TranscriptionService Initialized")
    }
    
    // Get Documents directory safely
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func fetchAvailableModels(repoName: String) async {
        guard let documents = getDocumentsDirectory() else {
            Logging.error("Could not access Documents directory.")
            return
        }
        let modelPathBase = documents.appendingPathComponent("huggingface/models/\(repoName)").path // Example path construction
        
        // --- Check Local Models ---
        localModels = []
        if FileManager.default.fileExists(atPath: modelPathBase) {
            do {
                let downloaded = try FileManager.default.contentsOfDirectory(atPath: modelPathBase)
                // Filter out non-directory items and potential hidden files like .DS_Store
                let potentialModels = downloaded.filter { item in
                    var isDir: ObjCBool = false
                    //let itemPath = documents.appendingPathComponent(localModelPathBase).appendingPathComponent(item).path
                    let itemPath = documents.appendingPathComponent(item).path
                    // Ensure it's a directory and not a hidden file
                    return FileManager.default.fileExists(atPath: itemPath, isDirectory: &isDir) && isDir.boolValue && !item.starts(with: ".")
                }
                localModels = WhisperKit.formatModelFiles(potentialModels) // Assumes formatModelFiles handles naming conventions
            } catch {
                Logging.error("Error enumerating local models at \(modelPathBase): \(error)")
            }
        }
        localModelsSubject.send(localModels)
        Logging.info("Found locally: \(localModels)")
        
        // --- Fetch Remote Models ---
        // Assuming recommendedRemoteModels takes repoName
        //let remoteModelSupport = await WhisperKit.recommendedRemoteModels(repoName: repoName)
        let remoteModelSupport = await WhisperKit.recommendedRemoteModels()
        var combined = Set(localModels)
        combined.formUnion(remoteModelSupport.supported)
        // Ensure default model is included if not present
        let defaultModel = WhisperKit.recommendedModels().default
        if !combined.contains(defaultModel) {
            combined.insert(defaultModel) // Add default if missing
        }
        availableModels = Array(combined).sorted() // Ensure uniqueness and standard sorting
        availableModelsSubject.send(availableModels)
        Logging.info("Available models: \(availableModels)")
    }
    
    func loadModel(
        _ modelName: String,
        from repoName: String,
        computeOptions: ModelComputeOptions,
        localModelPathBase: String // e.g., "huggingface/models/argmaxinc/whisperkit-coreml"
    ) async throws {
        guard currentModelState != .loading, currentModelState != .prewarming, currentModelState != .downloading else {
            Logging.warning("Model load requested while already in progress (\(currentModelState)). Ignoring.")
            return // Avoid concurrent loads
        }
        guard !modelName.isEmpty else {
            throw TranscriptionServiceError.modelNotLoaded // Or a specific "no model selected" error
        }
        
        Logging.info("Loading model: \(modelName) from \(repoName) with options: \(computeOptions)")
        modelStateSubject.send(.loading) // Indicate start
        downloadProgressSubject.send(0.0)
        
        do {
            let config = WhisperKitConfig(
                computeOptions: computeOptions,
                verbose: true, // TODO: Control via AppSettings
                logLevel: .debug, // TODO: Control via AppSettings
                prewarm: false, // Service manages prewarm step
                load: false,    // Service manages load step
                download: false // Service manages download step
            )
            // Re-init whisperKit to apply new compute options and clear old state
            whisperKit = try await WhisperKit(config)
            guard let whisperKit = whisperKit else {
                throw TranscriptionServiceError.whisperKitNotInitialized
            }
            
            guard let documents = getDocumentsDirectory() else {
                throw TranscriptionServiceError.modelFolderAccessError(path: "Documents")
            }
            let modelBasePath = documents.appendingPathComponent(localModelPathBase)
            let modelFolderPath = modelBasePath.appendingPathComponent(modelName)
            
            var folder: URL?
            var requiresDownload = false
            
            // --- Determine if download or local load needed ---
            if !localModels.contains(modelName) || !FileManager.default.fileExists(atPath: modelFolderPath.path) {
                requiresDownload = true
                Logging.info("Model \(modelName) not found locally. Starting download.")
            } else {
                Logging.info("Found model \(modelName) locally at \(modelFolderPath.path).")
                folder = modelFolderPath
            }
            
            // --- Download if Required ---
            if requiresDownload {
                modelStateSubject.send(.downloading)
                let specializationProgressRatio = 0.7 // Ratio allocated to download progress vs prewarm/load
                folder = try await WhisperKit.download(variant: modelName, from: repoName) { progress in
                    Task { @MainActor in // Ensure UI update is on main thread
                        self.downloadProgressSubject.send(progress.fractionCompleted * specializationProgressRatio)
                    }
                }
                
                // Ensure downloaded model is moved to the consistent local storage path
                guard let downloadedFolder = folder else {
                    throw TranscriptionServiceError.downloadFailed(model: modelName)
                }
                // Ensure base directory exists
                try FileManager.default.createDirectory(at: modelBasePath, withIntermediateDirectories: true)
                
                // Prepare destination: remove if exists to ensure clean move
                if FileManager.default.fileExists(atPath: modelFolderPath.path) {
                    Logging.warning("Removing existing folder at \(modelFolderPath.path) before moving downloaded model.")
                    try FileManager.default.removeItem(at: modelFolderPath)
                }
                // Move the downloaded content
                try FileManager.default.moveItem(at: downloadedFolder, to: modelFolderPath)
                folder = modelFolderPath // Update to final location
                Logging.info("Moved downloaded model to \(modelFolderPath.path)")
                
                await MainActor.run { // Update state after download completes
                    downloadProgressSubject.send(specializationProgressRatio) // Indicate download finished before prewarm
                }
            }
            
            // --- Prewarm & Load ---
            guard let modelFolder = folder else {
                throw TranscriptionServiceError.modelFolderAccessError(path: modelFolderPath.path)
            }
            
            whisperKit.modelFolder = modelFolder
            modelStateSubject.send(.prewarming)
            Logging.info("Prewarming model \(modelName)...")
            // TODO: Implement smooth progress bar simulation if desired for prewarm/load phase
            do {
                try await whisperKit.prewarmModels()
            } catch {
                Logging.error("Prewarming failed for \(modelName): \(error). Retrying load...")
                // If prewarming fails, WhisperKit might still load, proceed to load attempt
                // Consider if a retry mechanism for download/prewarm is desired here
                // throw TranscriptionServiceError.prewarmFailed(model: modelName) // Optionally fail hard
            }
            
            modelStateSubject.send(.loading) // Distinguish loading after prewarm
            Logging.info("Loading model weights for \(modelName)...")
            try await whisperKit.loadModels()
            
            Logging.info("Model \(modelName) loaded successfully.")
            modelStateSubject.send(whisperKit.modelState) // Expect .loaded
            downloadProgressSubject.send(1.0) // Ensure progress completes
            
            // Update local models list if it was downloaded
            if requiresDownload, !localModels.contains(modelName) {
                localModels.append(modelName)
                localModelsSubject.send(localModels.sorted()) // Keep list sorted
            }
            
        } catch {
            Logging.error("Error during loadModel for \(modelName): \(error)")
            modelStateSubject.send(.unloaded)
            downloadProgressSubject.send(0.0)
            // Wrap error for clarity
            if error is TranscriptionServiceError { throw error } // Don't double-wrap
            else { throw TranscriptionServiceError.loadFailed(model: modelName) }
        }
    }
    
    func deleteModel(_ modelName: String, localModelPathBase: String) throws {
        guard let documents = getDocumentsDirectory() else { return }
        let modelFolder = documents.appendingPathComponent(localModelPathBase).appendingPathComponent(modelName)
        
        Logging.info("Attempting to delete model \(modelName) at \(modelFolder.path)")
        if FileManager.default.fileExists(atPath: modelFolder.path) {
            do {
                try FileManager.default.removeItem(at: modelFolder)
                Logging.info("Successfully deleted folder for model \(modelName).")
                
                // Update internal state and publisher
                if let index = localModels.firstIndex(of: modelName) {
                    localModels.remove(at: index)
                    localModelsSubject.send(localModels.sorted()) // Keep sorted
                    
                    // If the deleted model was the currently loaded one, reset state
                    if whisperKit?.modelFolder?.lastPathComponent == modelName {
                        Logging.info("Deleted model was active, resetting state.")
                        whisperKit = nil // Clear instance
                        modelStateSubject.send(.unloaded)
                    }
                }
            } catch {
                Logging.error("Error deleting model \(modelName) folder: \(error)")
                throw error // Re-throw to inform UI
            }
        } else {
            Logging.warning("Attempted to delete model \(modelName), but folder not found.")
        }
    }
    
    // MARK: - Transcription
    
    func transcribeFile(path: String, options: DecodingOptions) async throws {
        guard let whisperKit = whisperKit, currentModelState == .loaded else {
            throw TranscriptionServiceError.modelNotLoaded
        }
        guard FileManager.default.fileExists(atPath: path) else {
            throw TranscriptionServiceError.fileNotFound(path: path)
        }
        sendUpdate(isTranscribing: true) // Indicate start processing
        
        do {
            Logging.info("Loading audio file: \(path)")
            let loadingStart = Date()
            let audioFileSamples = try await Task { // Run potentially long load off main thread
                try autoreleasepool {
                    return try AudioProcessor.loadAudioAsFloatArray(fromPath: path)
                }
            }.value
            Logging.info("Loaded \(audioFileSamples.count) audio samples in \(Date().timeIntervalSince(loadingStart)) seconds.")
            
            resetTranscriptionState() // Clear previous results before new transcription
            
            Logging.info("Starting file transcription...")
            let transcriptionResults = try await performTranscription(on: audioFileSamples, options: options, isStreaming: false)
            let mergedResult = mergeTranscriptionResults(transcriptionResults)
            
            var update = TranscriptionUpdate(isTranscribing: false) // Indicate finished
            if let result = mergedResult {
                update.segments = result.segments
                update.metrics = mapMetrics(result.timings, totalAudioDuration: Double(audioFileSamples.count) / Double(WhisperKit.sampleRate))
                //                update.modelLoadingTime = result.timings.modelLoading ?? 0
            }
            sendUpdate(update: update)
            Logging.info("File transcription finished.")
            
        } catch {
            Logging.error("Error transcribing file \(path): \(error)")
            sendUpdate(error: TranscriptionServiceError.transcriptionFailed(underlyingError: error), isTranscribing: false)
            throw TranscriptionServiceError.transcriptionFailed(underlyingError: error) // Propagate wrapped error
        }
    }
    
    func startStreamingTranscription(deviceId: DeviceID?, options: DecodingOptions) async throws {
        guard let whisperKit = whisperKit, currentModelState == .loaded else {
            throw TranscriptionServiceError.modelNotLoaded
        }
        guard currentTranscriptionTask == nil else {
            Logging.warning("Streaming start requested while already active. Ignoring.")
            return
        }
        
        // Check permission first
        guard await hasMicrophonePermission() else {
            throw TranscriptionServiceError.microphonePermissionDenied
        }
        
        // Reset state specific to streaming before starting
        resetStreamingState()
        sendUpdate(isTranscribing: true) // Indicate streaming has started
        
        do {
            try audioProcessor.startRecordingLive(inputDeviceID: deviceId) { _ in
                // This callback might fire frequently, update publisher on main thread
                Task { @MainActor in
                    self.audioLevelSubject.send(AudioSignalInfo(
                        bufferEnergy: self.audioProcessor.relativeEnergy, // Use property directly
                        bufferSeconds: Double(self.audioProcessor.audioSamples.count) / Double(WhisperKit.sampleRate)
                    ))
                }
            }
        } catch {
            Logging.error("Failed to start live recording: \(error)")
            sendUpdate(error: error, isTranscribing: false) // Reset state on failure
            throw error // Propagate error
        }
        
        // Start the background transcription loop
        currentTranscriptionTask = Task(priority: .userInitiated) {
            do {
                try await realtimeLoop(options: options)
            } catch let error as CancellationError {
                Logging.info("Realtime loop cancelled.") // Expected cancellation
                throw error // Allow cancellation to propagate if needed elsewhere
            } catch {
                Logging.error("Realtime loop failed: \(error)")
                // Send error update to UI
                sendUpdate(error: TranscriptionServiceError.transcriptionFailed(underlyingError: error), isTranscribing: false)
                // Clean up resources on loop failure
                audioProcessor.stopRecording()
                isRecording = false // Update internal state tracker
                throw error // Propagate error
            }
        }
        Logging.info("Streaming transcription started.")
        isRecording = true // Update internal state tracker
    }
    
    private var isRecording = false // Internal tracker to prevent stopping if not started
    
    func stopStreamingTranscription() {
        guard currentTranscriptionTask != nil || isRecording else {
            Logging.info("Stop streaming called but not active.")
            return
        }
        Logging.info("Stopping streaming transcription.")
        
        // Cancel the loop first
        currentTranscriptionTask?.cancel()
        currentTranscriptionTask = nil
        
        // Stop audio capture
        audioProcessor.stopRecording()
        isRecording = false
        
        // Finalize any pending text/segments (important after cancelling loop)
        finalizeText() // Sends the final update with isTranscribing = false
    }
    
    // MARK: - Realtime Loop & Transcription Logic
    
    private func realtimeLoop(options: DecodingOptions) async throws {
        var lastBufferSize = 0
        //         let requiredDelay = options.realtimeDelayInterval ?? 1.0
        let requiredDelay = 1.0
        
        while !Task.isCancelled {
            // 1. Get current buffer atomically if possible, or copy
            let currentBuffer = audioProcessor.audioSamples // Assume this gives a safe copy or snapshot
            
            // 2. Calculate new audio duration
            let nextBufferSize = currentBuffer.count - lastBufferSize
            let nextBufferSeconds = Float(nextBufferSize) / Float(WhisperKit.sampleRate)
            
            // 3. Check delay threshold
            //            guard nextBufferSeconds > requiredDelay else {
            //                 try await Task.sleep(nanoseconds: 100_000_000) // Sleep 100ms and check again
            //                 continue
            //            }
            
            // 4. Check VAD (Voice Activity Detection) if enabled
            if options.chunkingStrategy == .vad {
                let voiceDetected = AudioProcessor.isVoiceDetected(
                    in: audioProcessor.relativeEnergy, // Use the property directly
                    nextBufferInSeconds: nextBufferSeconds,
                    silenceThreshold: 0.3
                    //silenceThreshold: options.silenceThreshold ?? 0.3 // Use option or default
                )
                guard voiceDetected else {
                    // Logging.debug("[RealtimeLoop] No voice detected in \(nextBufferSeconds)s segment.")
                    // TODO: Potential silent segment purge logic here if desired
                    try await Task.sleep(nanoseconds: 100_000_000)
                    continue
                }
            }
            
            // Record buffer size for next iteration *before* transcription starts
            lastBufferSize = currentBuffer.count
            Logging.info("[RealtimeLoop] Processing buffer of \(nextBufferSeconds)s (Total samples: \(currentBuffer.count))")
            
            // 5. Run transcription based on mode (standard vs eager)
            let transcriptionStart = Date()
            var transcriptionResult: TranscriptionResult? = nil // To hold the result for metric mapping
            
            //             if options.enableEagerDecoding ?? false {
            //                 guard whisperKit?.textDecoder.supportsWordTimestamps ?? false else {
            //                     throw TranscriptionServiceError.eagerModeRequiresWordTimestamps(model: whisperKit?.modelVariant.description ?? "Unknown")
            //                 }
            //                 transcriptionResult = try await performEagerTranscription(on: Array(currentBuffer), options: options)
            //             } else {
            let results = try await performTranscription(on: Array(currentBuffer), options: options, isStreaming: true)
            transcriptionResult = mergeTranscriptionResults(results) // Get merged result for metrics
            processStandardStreamingResults(transcriptionResult, bufferDuration: Double(currentBuffer.count) / Double(WhisperKit.sampleRate))
            //             }
            Logging.info("[RealtimeLoop] Transcription cycle took \(Date().timeIntervalSince(transcriptionStart)) seconds.")
            
            // Update general metrics (might be overridden by specific result processing)
            let generalUpdate = TranscriptionUpdate(
                metrics: mapMetrics(transcriptionResult?.timings, totalAudioDuration: Double(currentBuffer.count) / Double(WhisperKit.sampleRate)),
                isTranscribing: true // We are still in the loop
            )
            sendUpdate(update: generalUpdate) // Send metrics update
            
            // Small delay to prevent overly tight loop if processing is extremely fast
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
        // Loop exited (likely due to cancellation)
        Logging.info("Realtime loop finished.")
    }
    
    // Core transcription function called by file/streaming modes
    private func performTranscription(on samples: [Float], options: DecodingOptions, isStreaming: Bool) async throws -> [TranscriptionResult] {
        guard let whisperKit = whisperKit else { throw TranscriptionServiceError.modelNotLoaded }
        
        var transcriptionOptions = options
        if isStreaming {
            // Use the appropriate clipping timestamp based on mode
            // transcriptionOptions.clipTimestamps = (options.enableEagerDecoding ?? false) ? [lastAgreedSeconds] : [lastConfirmedSegmentEndSeconds]
            transcriptionOptions.chunkingStrategy = Optional.none // Streaming loop now manages audio windows
            transcriptionOptions.concurrentWorkerCount = 1 // Force single worker for streaming? (Check PPU impact)
        } else {
            // File transcription might use multi-worker if enabled in options
            transcriptionOptions.concurrentWorkerCount = Int(options.concurrentWorkerCount) == 0 ? 10 : Int(options.concurrentWorkerCount)
        }
        
        Logging.debug("Running transcription with options: \(transcriptionOptions)")
        return try await whisperKit.transcribe(
            audioArray: samples,
            decodeOptions: transcriptionOptions,
            // Pass the shared callback helper
            callback: decodingCallback(options: transcriptionOptions, isStreaming: isStreaming)
        )
    }
    
    // Eager mode specific transcription flow
    private func performEagerTranscription(on samples: [Float], options: DecodingOptions) async throws -> TranscriptionResult? {
        guard let whisperKit = whisperKit else { throw TranscriptionServiceError.modelNotLoaded }
        
        // Prepare options for eager mode
        var streamOptions = options
        streamOptions.clipTimestamps = [lastAgreedSeconds]      // Start from last agreed point
        let lastAgreedTokens = lastAgreedWords.flatMap { $0.tokens } // Get tokens from last confirmed words
        streamOptions.prefixTokens = lastAgreedTokens           // Provide prefix
        streamOptions.wordTimestamps = true                     // Ensure word timestamps are requested
        streamOptions.chunkingStrategy = Optional.none                  // Override chunking for streaming logic
        
        Logging.info("[EagerMode] Processing from \(lastAgreedSeconds)s with prefix: \(lastAgreedTokens.count) tokens")
        
        // Perform the transcription for this window
        let transcriptionResults: [TranscriptionResult] = try await whisperKit.transcribe(
            audioArray: samples,
            decodeOptions: streamOptions,
            callback: decodingCallback(options: streamOptions, isStreaming: true) // Use shared callback
        )
        
        let transcription = transcriptionResults.first // Eager expects single result for the window
        
        // --- Process Eager Result ---
        guard let result = transcription else {
            Logging.warning("[EagerMode] No transcription result returned for this window.")
            // Send update with existing state but indicate still transcribing
            //sendUpdate(update: currentEagerUpdate(metrics: nil), isTranscribing: true)
            return nil
        }
        
        // Filter hypothesis words relevant to the *current* window (starting from last agreed time)
        let currentHypothesisWords = result.allWords.filter { $0.start >= lastAgreedSeconds }
        
        // Compare with the *previous* window's relevant words
        let previousWindowWords = self.prevResult?.allWords.filter { $0.start >= lastAgreedSeconds } ?? []
        
        // Find the longest common prefix between the previous relevant words and current relevant words
        let commonPrefix = findLongestCommonPrefix(previousWindowWords, currentHypothesisWords)
        Logging.debug("[EagerMode] Prev Hypo: \"\(previousWindowWords.map { $0.word }.joined())\"")
        Logging.debug("[EagerMode] Curr Hypo: \"\(currentHypothesisWords.map { $0.word }.joined())\"")
        Logging.debug("[EagerMode] Common Prefix (\(commonPrefix.count)): \"\(commonPrefix.map { $0.word }.joined())\"")
        
        // Determine how many confirmations are needed from options
        //let confirmationsNeeded = Int(options.tokenConfirmationsNeeded ?? 2.0) // Use option or default
        let confirmationsNeeded = 2
        
        var newWordsConfirmed = false
        if commonPrefix.count >= confirmationsNeeded {
            // The common prefix is stable enough. Confirm words *up to* the start of the trailing confirmation window.
            let newlyConfirmedCount = commonPrefix.count - confirmationsNeeded
            if newlyConfirmedCount > 0 {
                let newlyConfirmedWords = Array(commonPrefix.prefix(newlyConfirmedCount))
                // Add these to the overall confirmed list
                confirmedWords.append(contentsOf: newlyConfirmedWords)
                newWordsConfirmed = true
                // Update the base for the *next* iteration's prefix/clip
                lastAgreedWords = Array(commonPrefix.suffix(confirmationsNeeded))
                lastAgreedSeconds = lastAgreedWords.first?.start ?? lastAgreedSeconds // Update time to start of agreed window
                Logging.info("[EagerMode] Confirmed \(newlyConfirmedCount) words up to \(lastAgreedSeconds)s. Next prefix: \(lastAgreedWords.count) words.")
            } else {
                // Common prefix exists and meets confirmation count, but offers no *new* words to confirm fully.
                // Example: prev="A B C D", curr="A B C E", conf=2. Prefix="A B C". newlyConfirmedCount=1. Confirm "A". lastAgreed=["B", "C"].
                // Example: prev="A B C", curr="A B C", conf=2. Prefix="A B C". newlyConfirmedCount=1. Confirm "A". lastAgreed=["B", "C"].
                // Keep the current lastAgreedWords and lastAgreedSeconds.
                lastAgreedWords = commonPrefix // Update agreed window even if nothing fully new confirmed
                lastAgreedSeconds = lastAgreedWords.first?.start ?? lastAgreedSeconds
                Logging.info("[EagerMode] Re-confirmed prefix window at \(lastAgreedSeconds)s, no new full words added to confirmedText.")
            }
        } else {
            // Not enough stable words in the common prefix. Don't confirm anything new.
            // Keep the existing lastAgreedWords and lastAgreedSeconds.
            Logging.info("[EagerMode] Not enough confirmations (\(commonPrefix.count)/\(confirmationsNeeded)). Holding at \(lastAgreedSeconds)s.")
        }
        
        // Store the current result only if it led to confirmation or is the first result
        // Potentially unstable results (short common prefix) might be discarded to avoid polluting history
        let storeCurrentResult = newWordsConfirmed || self.prevResult == nil
        if storeCurrentResult {
            self.prevResult = result
            eagerResults.append(result) // Optionally keep full history if useful
        } else {
            Logging.debug("[EagerMode] Discarding unstable result from history.")
        }
        
        // --- Update UI Publisher ---
        // Recalculate hypothesis text based on the *latest* potential words from the current result,
        // starting *after* the possibly updated `lastAgreedSeconds`.
        let finalHypothesisWords = result.allWords.filter { $0.start >= lastAgreedSeconds }
        let hypothesisStr = finalHypothesisWords.map { $0.word }.joined()
        
        // Send the update with the latest confirmed text and the new hypothesis
        let update = TranscriptionUpdate(
            confirmedText: confirmedWords.map { $0.word }.joined(),
            hypothesisText: hypothesisStr,
            currentDecodingText: currentDecodingTextPreview, // Include latest preview
            metrics: mapMetrics(result.timings, totalAudioDuration: Double(samples.count) / Double(WhisperKit.sampleRate)),
            isTranscribing: true // Still streaming
        )
        sendUpdate(update: update)
        
        return result // Return the raw result if needed
    }
    
    // Shared callback for decoder preview and early stopping checks
    private func decodingCallback(options: DecodingOptions, isStreaming: Bool) -> ((TranscriptionProgress) -> Bool?) {
        return { [weak self] progress in
            guard let self = self else { return false }
            
            // --- Update Realtime Preview Text ---
            // Use a simple approach: just update with the latest text from progress.
            // More complex logic might try to detect fallbacks or window changes if needed.
            self.currentDecodingTextPreview = progress.text
            // Optionally send frequent preview updates via a separate publisher or include in main update
            // For now, store it and send with main update.
            
            // Also track fallbacks for context if needed during result processing
            self.currentDecodingFallbacks = Int(progress.timings.totalDecodingFallbacks)
            
            // --- Early Stopping Logic ---
            // These thresholds should come from DecodingOptions
            //let compressionCheckWindow = Int(options.compressionCheckWindow ?? 60)
            let compressionCheckWindow = 60
            let compressionRatioThreshold = options.compressionRatioThreshold ?? 2.4
            let logProbThreshold = options.logProbThreshold ?? -1.0
            
            let currentTokens = progress.tokens
            if currentTokens.count > compressionCheckWindow {
                let checkTokens = Array(currentTokens.suffix(compressionCheckWindow))
                let ratio = compressionRatio(of: checkTokens) // Needs implementation
                if ratio > compressionRatioThreshold {
                    Logging.debug("Early stopping: Compression Ratio (\(ratio) > \(compressionRatioThreshold))")
                    return false // Stop decoding this segment
                }
            }; if (progress.avgLogprob ?? 0) < logProbThreshold {
                Logging.debug("Early stopping: Log Probability (\(progress.avgLogprob ?? 0) < \(logProbThreshold))")
                return false // Stop decoding this segment
            }
            
            return nil // Continue decoding by default
        }
    }
    
    // Processes results for standard (non-eager) streaming mode
    private func processStandardStreamingResults(_ result: TranscriptionResult?, bufferDuration: Double) {
        guard let result = result else {
            sendUpdate(isTranscribing: true) // Send keep-alive if no result
            return
        }
        
        let segments = result.segments
        let confirmations = requiredSegmentsForConfirmation // Use state variable
        
        // Logic to determine which segments are newly confirmed vs unconfirmed
        var newlyConfirmed: [TranscriptionSegment] = []
        var stillUnconfirmed: [TranscriptionSegment] = []
        
        if segments.count > confirmations {
            let numberOfSegmentsToConfirm = segments.count - confirmations
            let potentialConfirm = Array(segments.prefix(numberOfSegmentsToConfirm))
            stillUnconfirmed = Array(segments.suffix(confirmations))
            
            // Check the end time of the potential confirmed segments
            if let lastPotential = potentialConfirm.last, lastPotential.end > lastConfirmedSegmentEndSeconds {
                // Add actually new segments to the master confirmed list
                for segment in potentialConfirm where segment.end > lastConfirmedSegmentEndSeconds {
                    if !confirmedSegments.contains(segment) { // Avoid duplicates
                        confirmedSegments.append(segment)
                        newlyConfirmed.append(segment)
                    }
                }
                // Update the official confirmed end time
                if let lastNew = newlyConfirmed.last {
                    lastConfirmedSegmentEndSeconds = lastNew.end
                    Logging.info("[StandardStream] Confirmed up to \(lastConfirmedSegmentEndSeconds)s")
                }
            } else {
                // Segments returned don't extend past the known confirmed time, keep them unconfirmed for now
                stillUnconfirmed = segments
            }
        } else {
            // Not enough segments returned to meet the confirmation threshold
            stillUnconfirmed = segments
        }
        // Update the service's unconfirmed segments list
        unconfirmedSegments = stillUnconfirmed
        
        // Update publisher with the current view of confirmed + unconfirmed
        let update = TranscriptionUpdate(
            segments: self.confirmedSegments + self.unconfirmedSegments, // Combine for display
            currentDecodingText: currentDecodingTextPreview, // Include preview
            metrics: mapMetrics(result.timings, totalAudioDuration: bufferDuration),
            //            modelLoadingTime: result.timings.modelLoading ?? 0,
            isTranscribing: true // Still in streaming loop
        )
        sendUpdate(update: update)
    }
    
    // Finalizes transcription state when stopping
    private func finalizeText() {
        Logging.info("Finalizing transcription text...")
        var finalUpdate = TranscriptionUpdate(isTranscribing: false) // Base update for stopping
        
        // Standard Mode Finalization
        if !unconfirmedSegments.isEmpty {
            confirmedSegments.append(contentsOf: unconfirmedSegments)
            unconfirmedSegments = [] // Clear unconfirmed
        }
        finalUpdate.segments = confirmedSegments // Send final full list
        
        // Eager Mode Finalization
        //if !lastAgreedWords.isEmpty || !hypothesisWords.isEmpty || prevResult != nil {
        if !lastAgreedWords.isEmpty || prevResult != nil {
            // Assume the very last hypothesis (based on prevResult) was the best guess for the end
            let lastHypothesisWords = prevResult?.allWords.filter { $0.start >= lastAgreedSeconds } ?? []
            // Combine remaining agreed + last hypothesis
            let finalWordsToConfirm = lastAgreedWords + lastHypothesisWords
            confirmedWords.append(contentsOf: finalWordsToConfirm)
            
            // Clear eager state after finalization
            lastAgreedWords = []
            //hypothesisWords = [] // Should already be empty if tracking correctly
            prevResult = nil
            eagerResults = []
        }
        finalUpdate.confirmedText = confirmedWords.map { $0.word }.joined()
        finalUpdate.hypothesisText = "" // Hypothesis is now confirmed or discarded
        
        // Include latest metrics if available from last run
        // (metrics state is not explicitly cleared, holds last known values)
        // finalUpdate.metrics = ... (implicitly uses last value from property)
        
        // Send the final consolidated update
        sendUpdate(update: finalUpdate)
        
        // Fully reset internal state after sending final update
        resetStreamingState()
        resetTranscriptionState() // Includes resetting text previews etc.
    }
    
    // Resets state specific to an active transcription stream
    private func resetStreamingState() {
        Logging.debug("Resetting streaming state.")
        lastConfirmedSegmentEndSeconds = 0.0
        confirmedSegments = []
        unconfirmedSegments = []
        eagerResults = []
        prevResult = nil
        lastAgreedSeconds = 0.0
        prevWords = []
        lastAgreedWords = []
        confirmedWords = []
        // Keep decoder preview text? Maybe clear it.
        currentDecodingTextPreview = ""
        currentDecodingFallbacks = 0
    }
    
    // Resets general transcription display state (text, segments)
    private func resetTranscriptionState() {
        Logging.debug("Resetting general transcription state.")
        confirmedSegments = []
        unconfirmedSegments = []
        confirmedWords = []
        lastAgreedWords = []
        //hypothesisWords = [] // Assuming eager mode hypothesis state belongs here too
        currentDecodingTextPreview = ""
        // Don't necessary reset metrics - they reflect the last run
        // But maybe clear lag/loops?
        // metrics?.currentLag = 0 ... etc.
    }
    
    // Send update to publisher (ensures it's on main thread)
    private func sendUpdate(update: TranscriptionUpdate? = nil, error: Error? = nil, isTranscribing: Bool? = nil) {
        // Create the update package on the current thread
        var finalUpdate = update ?? TranscriptionUpdate() // Start with provided or empty base
        
        if let error = error {
            finalUpdate.error = error // Add error if provided
        }
        if let isTranscribing = isTranscribing {
            finalUpdate.isTranscribing = isTranscribing // Set explicit status if provided
        }
        
        // Ensure the latest preview text is included if not already set
        if finalUpdate.currentDecodingText.isEmpty && !currentDecodingTextPreview.isEmpty {
            finalUpdate.currentDecodingText = currentDecodingTextPreview
        }
        // Ensure latest metrics are included if not already set
        // finalUpdate.metrics = finalUpdate.metrics ?? self.metricsProperty // If metrics were a state property
        
        // Dispatch the final update object to the MainActor to publish
        Task { @MainActor in
            transcriptionUpdateSubject.send(finalUpdate)
            
            // Clean up transient state *after* sending?
            // Maybe clear preview only if stopping or erroring?
            if finalUpdate.error != nil || !finalUpdate.isTranscribing {
                if !(error is CancellationError) { // Don't clear preview just on cancellation
                    self.currentDecodingTextPreview = ""
                    self.currentDecodingFallbacks = 0
                }
            }
        }
    }
    
    // MARK: - System Info & Permissions
    
    func hasMicrophonePermission() async -> Bool {
        await AudioProcessor.requestRecordPermission()
    }
    
    func getAudioDevices() -> [AudioDevice] {
#if os(macOS)
        return AudioProcessor.getAudioDevices()
#else
        return [] // Return empty array on non-macOS platforms
#endif
    }
    
    // MARK: - Decoding Options Helper
    
    // Helper to construct DecodingOptions from settings, incorporating service state
    func currentDecodingOptions(from settings: AppSettings) -> DecodingOptions {
        let languageCode = Constants.languages[settings.selectedLanguage, default: Constants.defaultLanguageCode]
        let task: DecodingTask = settings.selectedTask == "transcribe" ? .transcribe : .translate
        
        // Dynamic state for clip timestamps depends on mode (eager vs standard)
        let clipTime: Float = settings.enableEagerDecoding ? lastAgreedSeconds : lastConfirmedSegmentEndSeconds
        
        return DecodingOptions(
            verbose: true, // Or manage via settings?
            task: task,
            language: languageCode,
            temperature: Float(settings.temperatureStart),
            temperatureFallbackCount: Int(settings.fallbackCount),
            sampleLength: Int(settings.sampleLength), usePrefillPrompt: settings.enablePromptPrefill, usePrefillCache: settings.enableCachePrefill, skipSpecialTokens: !settings.enableSpecialCharacters, withoutTimestamps: !settings.enableTimestamps, wordTimestamps: settings.enableEagerDecoding || settings.enableTimestamps, clipTimestamps: [clipTime], compressionRatioThreshold: 2.4, // Default WhisperKit value, make configurable?
            logProbThreshold: -1.0,         // Default WhisperKit value, make configurable?
            firstTokenLogProbThreshold: settings.enableEagerDecoding ? -1.5 : nil, noSpeechThreshold: 0.6, // CRITICAL: Use the dynamic clip time
            concurrentWorkerCount: Int(settings.concurrentWorkerCount) == 0 ? 10 : Int(settings.concurrentWorkerCount), chunkingStrategy: settings.chunkingStrategy
        )
    }
    
    // Maps WhisperKit timings to the metrics struct. Can be expanded.
    private func mapMetrics(_ timings: TranscriptionTimings?, totalAudioDuration: Double? = nil) -> TranscriptionUpdate.TranscriptionMetrics? {
        guard let timings = timings else { return nil }
        
        var metrics = TranscriptionUpdate.TranscriptionMetrics(
            tokensPerSecond: timings.tokensPerSecond,
            realTimeFactor: timings.realTimeFactor,
            speedFactor: timings.speedFactor,
            firstTokenTime: timings.firstTokenTime - timings.pipelineStart, // Make relative
            pipelineStart: timings.pipelineStart,
            currentLag: timings.decodingLoop, // Map relevant timing
            currentFallbacks: Int(timings.totalDecodingFallbacks),
            currentEncodingLoops: Int(timings.totalEncodingRuns),
            //            currentDecodingLoops: Int(timings.totalDecodingRuns),
            totalInferenceTime: timings.fullPipeline,
            modelLoadingTime: timings.modelLoading
        )
        
        // Optionally recalculate RTF/Speed based on total buffer duration if provided (for streaming)
        // This gives a measure over the whole processed audio so far in the stream
        if let duration = totalAudioDuration, duration > 0, metrics.totalInferenceTime > 0 {
            metrics.realTimeFactor = metrics.totalInferenceTime / duration
            metrics.speedFactor = duration / metrics.totalInferenceTime
        }
        
        return metrics
    }
}

// MARK: - Helper Functions & Extensions (Placeholders - Implement based on original code/needs)

// Placeholder: Merges results if WhisperKit returns multiple chunks for a single transcribe call
func mergeTranscriptionResults(_ results: [TranscriptionResult?]) -> TranscriptionResult? {
    let validResults = results.compactMap { $0 }
    guard !validResults.isEmpty else { return nil }
    if validResults.count == 1 { return validResults.first }
    
    // Simple merge: Concatenate segments, average timings? More complex logic likely needed.
    var mergedSegments: [TranscriptionSegment] = []
    var totalTokensPerSecond: Double = 0
    var totalRealTimeFactor: Double = 0
    // ... other timing sums ...
    
    for result in validResults {
        mergedSegments.append(contentsOf: result.segments)
        totalTokensPerSecond += result.timings.tokensPerSecond
        totalRealTimeFactor += result.timings.realTimeFactor
        // ... sum other timings ...
    }
    
    // Create a new TranscriptionResult with merged data (approximation)
    // Return the first result for now until proper merging is implemented
    // Need a constructor or modification method for TranscriptionResult if merging properly.
    return validResults.first
}

// Placeholder: Finds longest common prefix between two WordTiming arrays
func findLongestCommonPrefix(_ arr1: [WordTiming], _ arr2: [WordTiming]) -> [WordTiming] {
    guard !arr1.isEmpty, !arr2.isEmpty else { return [] }
    var commonPrefix: [WordTiming] = []
    let minLength = min(arr1.count, arr2.count)
    for i in 0..<minLength {
        // Requires WordTiming to be Equatable!
        if arr1[i] == arr2[i] { // Use the Equatable conformance
            commonPrefix.append(arr1[i])
        } else {
            break // Stop at first mismatch
        }
    }
    return commonPrefix
}

// Placeholder: Finds suffix of arr2 after the common prefix with arr1
func findLongestDifferentSuffix(_ arr1: [WordTiming], _ arr2: [WordTiming]) -> [WordTiming] {
    let commonPrefix = findLongestCommonPrefix(arr1, arr2)
    if commonPrefix.count < arr2.count {
        return Array(arr2.suffix(from: commonPrefix.count))
    }
    return []
}

// Placeholder: Calculates compression ratio (requires zlib or similar)
func compressionRatio(of tokens: [Int]) -> Float {
    // Needs actual implementation using compression libraries
    Logging.warning("Compression ratio calculation is not implemented.")
    return 0.0 // Return safe value
}

// Add Equatable conformance if WhisperKit types don't already have it
extension TranscriptionSegment {
    public static func == (lhs: TranscriptionSegment, rhs: TranscriptionSegment) -> Bool {
        // Define equality based on unique segment identifier if available,
        // otherwise use start time and text as a proxy. Be careful with floating points.
        let timeThreshold: Float = 0.01 // Tolerance for float comparison
        return abs(lhs.start - rhs.start) < timeThreshold && lhs.text == rhs.text // && lhs.id == rhs.id (if exists)
    }
}

// Make TranscriptionSegment Hashable required by ForEach(viewModel.confirmedSegments, id: \.self)
extension TranscriptionSegment {
    public func hash(into hasher: inout Hasher) {
        // Hash based on the same properties used for equality
        hasher.combine(start)
        hasher.combine(text)
        // hasher.combine(id) // if exists
    }
}

extension WordTiming {
    public static func == (lhs: WordTiming, rhs: WordTiming) -> Bool {
        let timeThreshold: Float = 0.01 // Tolerance for float comparison
        // Consider if probability/tokens need comparison for stricter equality
        return lhs.word == rhs.word &&
        abs(lhs.start - rhs.start) < timeThreshold &&
        abs(lhs.end - rhs.end) < timeThreshold
    }
}

// Add Hashable conformance if needed for Sets or Dictionary keys
extension WordTiming {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        // Hash floats carefully, might need to round or use integer representation
        // hasher.combine(Int(start * 100))
        // hasher.combine(Int(end * 100))
        // Simple hash for example:
        hasher.combine(start)
        hasher.combine(end)
    }
}

// Helper Logging struct (example implementation)
struct Logging {
    static func info(_ message: String) {
        print("[INFO] \(message)")
    }
    static func debug(_ message: String) {
#if DEBUG // Only print debug logs in DEBUG builds
        print("[DEBUG] \(message)")
#endif
    }
    static func warning(_ message: String) {
        print("[WARN] ⚠️ \(message)")
    }
    static func error(_ message: String) {
        print("[ERROR] 💥 \(message)")
    }
}
