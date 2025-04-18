////
////  WhisperAXRenameView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
////  TranscriptionService.swift
////  WhisperAX (Enhanced)
////
////  For licensing see accompanying LICENSE.md file.
////  Copyright © 2024 Argmax, Inc. All rights reserved.
////
//
//import Foundation
//import WhisperKit
//import AVFoundation
//import Combine
//import CoreML
//
//// MARK: - Service Protocol (Optional but good practice)
//
//protocol TranscriptionServiceProtocol {
//    var modelStatePublisher: AnyPublisher<ModelState, Never> { get }
//    var transcriptionUpdatePublisher: AnyPublisher<TranscriptionUpdate, Never> { get }
//    var downloadProgressPublisher: AnyPublisher<Double, Never> { get }
//    var audioLevelPublisher: AnyPublisher<AudioSignalInfo, Never> { get }
//    var availableModelsPublisher: AnyPublisher<[String], Never> { get }
//    var localModelsPublisher: AnyPublisher<[String], Never> { get }
//
//    var currentModelState: ModelState { get }
//    var modelFolderURL: URL? { get }
//    var audioProcessor: AudioProcessor { get }
//
//    func fetchAvailableModels(repoName: String) async
//    func loadModel(
//        _ modelName: String,
//        from repoName: String,
//        computeOptions: ModelComputeOptions,
//        localModelPathBase: String
//    ) async throws
//    func deleteModel(_ modelName: String, localModelPathBase: String) throws
//    func transcribeFile(path: String, options: DecodingOptions) async throws
//    func startStreamingTranscription(deviceId: DeviceID?, options: DecodingOptions) async throws
//    func stopStreamingTranscription()
//    func hasMicrophonePermission() async -> Bool
//    func getAudioDevices() -> [AudioDevice] // macOS specific
//    func currentDecodingOptions(from settings: AppSettings) async -> DecodingOptions
//}
//
//// MARK: - Transcription Update Structure
//
//struct TranscriptionUpdate: Equatable {
//    static func == (lhs: TranscriptionUpdate, rhs: TranscriptionUpdate) -> Bool {
//        return true
//    }
//    
//    var segments: [TranscriptionSegment] = []
//    var confirmedText: String = ""           // For Eager mode
//    var hypothesisText: String = ""          // For Eager mode
//    var currentDecodingText: String = ""     // Preview
//    var metrics: TranscriptionMetrics? = nil // RTF, Speed, Tokens/s etc.
//    var error: Error? = nil
//    var isTranscribing: Bool = false         // Indicates active processing
//
//    // Metrics structure (simplified example)
//    struct TranscriptionMetrics: Equatable{
//        var tokensPerSecond: Double = 0
//        var realTimeFactor: Double = 0
//        var speedFactor: Double = 0 // macOS only concept perhaps?
//        var firstTokenTime: TimeInterval = 0
//        var pipelineStart: TimeInterval = 0
//        var currentLag: TimeInterval = 0
//        var currentFallbacks: Int = 0
//        var currentEncodingLoops: Int = 0
//        var currentDecodingLoops: Int = 0
//        var totalInferenceTime: TimeInterval = 0
//    }
//}
//
//// MARK: - Audio Signal Info Structure
//
//struct AudioSignalInfo: Equatable {
//    var bufferEnergy: [Float] = []
//    var bufferSeconds: Double = 0
//}
//
//// MARK: - Service Implementation
//
//@MainActor // Ensure WhisperKit interactions happen safely if needed, or dispatch internally
//class TranscriptionService: TranscriptionServiceProtocol, ObservableObject {
//
//    private var whisperKit: WhisperKit?
//    let audioProcessor = AudioProcessor()
//
//    // --- Publishers ---
//    private let modelStateSubject = CurrentValueSubject<ModelState, Never>(.unloaded)
//    var modelStatePublisher: AnyPublisher<ModelState, Never> { modelStateSubject.eraseToAnyPublisher() }
//
//    private let transcriptionUpdateSubject = PassthroughSubject<TranscriptionUpdate, Never>()
//    var transcriptionUpdatePublisher: AnyPublisher<TranscriptionUpdate, Never> { transcriptionUpdateSubject.eraseToAnyPublisher() }
//
//    private let downloadProgressSubject = CurrentValueSubject<Double, Never>(0.0)
//    var downloadProgressPublisher: AnyPublisher<Double, Never> { downloadProgressSubject.eraseToAnyPublisher() }
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
//    private var currentTranscriptionTask: Task<Void, Error>?
//    private(set) var localModels: [String] = []
//    private(set) var availableModels: [String] = []
//    var modelFolderURL: URL? { whisperKit?.modelFolder }
//    var currentModelState: ModelState { modelStateSubject.value }
//    private var lastConfirmedSegmentEndSeconds: Float = 0.0 // For standard streaming
//    private var requiredSegmentsForConfirmation: Int = 4   // Example: Make configurable
//    private var confirmedSegments: [TranscriptionSegment] = []
//    private var unconfirmedSegments: [TranscriptionSegment] = []
//
//    // --- Eager Mode State ---
//    private var eagerResults: [TranscriptionResult?] = []
//    private var prevResult: TranscriptionResult?
//    private var lastAgreedSeconds: Float = 0.0
//    private var prevWords: [WordTiming] = []
//    private var lastAgreedWords: [WordTiming] = []
//    private var confirmedWords: [WordTiming] = []
//    private var tokenConfirmationsNeeded: Int = 2 // Example: Configurable
//
//    // MARK: - Initialization & Model Management
//
//    init() {
//        // Initial model fetch could happen here or triggered externally
//    }
//
//    func fetchAvailableModels(repoName: String) async {
//         guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            return
//        }
//        let modelPathBase = documents.appendingPathComponent("huggingface/models/\(repoName)").path // Example path construction
//
//        // Check local
//         localModels = []
//        if FileManager.default.fileExists(atPath: modelPathBase) {
//            do {
//                let downloaded = try FileManager.default.contentsOfDirectory(atPath: modelPathBase)
//                localModels = WhisperKit.formatModelFiles(downloaded)
//                    .filter { !$0.contains("mel") } // Filter out mel specs if they exist
//            } catch {
//                print("Error enumerating local models: \(error)")
//            }
//        }
//        localModelsSubject.send(localModels)
//        print("Found locally: \(localModels)")
//
//        // Fetch remote
//        let remoteModelSupport = await WhisperKit.recommendedRemoteModels()
//        var combined = Set(localModels)
//        combined.formUnion(remoteModelSupport.supported)
//        availableModels = Array(combined).sorted() // Ensure uniqueness and order
//        availableModelsSubject.send(availableModels)
//        print("Available models: \(availableModels)")
//    }
//
//    func loadModel(
//        _ modelName: String,
//        from repoName: String,
//        computeOptions: ModelComputeOptions,
//        localModelPathBase: String // e.g., huggingface/models/argmaxinc/whisperkit-coreml
//    ) async throws {
//        guard currentModelState != .loading, currentModelState != .prewarming, currentModelState != .downloading else {
//             print("Model load already in progress.")
//             return
//         }
//
//        print("Loading model: \(modelName)")
//        modelStateSubject.send(.loading) // Indicate start
//        downloadProgressSubject.send(0.0)
//
//        do {
//            let config = WhisperKitConfig(
//                computeOptions: computeOptions,
//                verbose: true, // Or controlled by settings
//                logLevel: .debug, // Or controlled by settings
//                prewarm: false, // Let the service handle steps
//                load: false,
//                download: false
//            )
//            // Re-init whisperKit to ensure fresh state for new model/compute options
//            whisperKit = try await WhisperKit(config)
//            guard let whisperKit = whisperKit else {
//                throw NSError(domain: "TranscriptionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit initialization failed."])
//            }
//
//            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let modelBasePath = documents.appendingPathComponent(localModelPathBase)
//            let modelFolderPath = modelBasePath.appendingPathComponent(modelName)
//
//            var folder: URL?
//
//            // Check local cache first
//            if FileManager.default.fileExists(atPath: modelFolderPath.path) {
//                print("Found model locally at \(modelFolderPath.path)")
//                folder = modelFolderPath
//            } else {
//                // Download
//                print("Downloading model \(modelName)...")
//                modelStateSubject.send(.downloading)
//                let specializationProgressRatio = 0.7 // As in original code
//                 folder = try await WhisperKit.download(variant: modelName, from: repoName) { progress in
//                     // Update publisher on main thread
//                     Task { @MainActor in
//                         self.downloadProgressSubject.send(progress.fractionCompleted * specializationProgressRatio)
//                     }
//                 }
//                 // Ensure model is moved to the expected location if needed (WhisperKit.download might return temp location)
//                if let downloadedFolder = folder, downloadedFolder.path != modelFolderPath.path {
//                    try FileManager.default.createDirectory(at: modelBasePath, withIntermediateDirectories: true)
//                    if FileManager.default.fileExists(atPath: modelFolderPath.path) {
//                        try FileManager.default.removeItem(at: modelFolderPath) // Remove existing if somehow re-downloading
//                    }
//                    try FileManager.default.moveItem(at: downloadedFolder, to: modelFolderPath)
//                    folder = modelFolderPath // Update to final location
//                    print("Moved downloaded model to \(modelFolderPath.path)")
//                 }
//
//                 await MainActor.run { // Update state back on main actor after download completes
//                     downloadProgressSubject.send(specializationProgressRatio) // Indicate download finished
//                }
//            }
//
//            guard let modelFolder = folder else {
//                 throw NSError(domain: "TranscriptionService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Model folder not found or created."])
//             }
//
//            whisperKit.modelFolder = modelFolder
//            modelStateSubject.send(.prewarming)
//            print("Prewarming model...")
//            // TODO: Implement the smooth progress bar simulation if desired, using the downloadProgressSubject
//             try await whisperKit.prewarmModels()
//
//            modelStateSubject.send(.loading) // Distinguish loading after prewarm
//            print("Loading model weights...")
//            try await whisperKit.loadModels()
//
//            print("Model \(modelName) loaded successfully.")
//            modelStateSubject.send(whisperKit.modelState) // Should be .loaded
//            if !localModels.contains(modelName) {
//                 localModels.append(modelName)
//                 localModelsSubject.send(localModels)
//             }
//              downloadProgressSubject.send(1.0)
//
//        } catch {
//            print("Error loading model \(modelName): \(error)")
//            modelStateSubject.send(.unloaded)
//            downloadProgressSubject.send(0.0)
//            throw error // Re-throw for ViewModel to handle
//        }
//    }
//
//    func deleteModel(_ modelName: String, localModelPathBase: String) throws {
//        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        let modelFolder = documents.appendingPathComponent(localModelPathBase).appendingPathComponent(modelName)
//
//        if FileManager.default.fileExists(atPath: modelFolder.path) {
//            try FileManager.default.removeItem(at: modelFolder)
//            if let index = localModels.firstIndex(of: modelName) {
//                localModels.remove(at: index)
//                localModelsSubject.send(localModels)
//                if currentModelState != .unloaded { // Only reset state if the *active* model was deleted
//                    modelStateSubject.send(.unloaded)
//                     whisperKit = nil // Clear instance if its model was deleted
//                }
//                print("Deleted model \(modelName)")
//            }
//        }
//    }
//
//    // MARK: - Transcription
//
//    func transcribeFile(path: String, options: DecodingOptions) async throws {
//        guard let whisperKit = whisperKit, currentModelState == .loaded else {
//            throw NSError(domain: "TranscriptionService", code: -3, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not loaded."])
//        }
//        // Reset relevant state? Handled by ViewModel usually before calling.
//        sendUpdate(isTranscribing: true) // Indicate start
//
//        do {
//            print("Loading audio file: \(path)")
//            let audioFileSamples = try await Task {
//                 try autoreleasepool {
//                    // Ensure file exists and is accessible
//                     guard FileManager.default.fileExists(atPath: path) else {
//                        throw NSError(domain: "TranscriptionService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Audio file not found at path: \(path)"])
//                     }
//                    return try AudioProcessor.loadAudioAsFloatArray(fromPath: path)
//                 }
//            }.value
//            print("Loaded audio file, starting transcription...")
//
//            let transcriptionResults = try await performTranscription(on: audioFileSamples, options: options, isStreaming: false)
//            let mergedResult = mergeTranscriptionResults(transcriptionResults) // Use helper if needed
//
//             var update = TranscriptionUpdate(isTranscribing: false)
//             if let result = mergedResult {
//                 update.segments = result.segments
//                 update.metrics = mapMetrics(result.timings) // Map timings to metrics struct
//             }
//             sendUpdate(update: update)
//            print("File transcription finished.")
//
//        } catch {
//            print("Error transcribing file: \(error)")
//            sendUpdate(error: error, isTranscribing: false)
//            throw error
//        }
//    }
//
//    func startStreamingTranscription(deviceId: DeviceID?, options: DecodingOptions) async throws {
//        guard let whisperKit = whisperKit, currentModelState == .loaded else {
//            throw NSError(domain: "TranscriptionService", code: -3, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not loaded."])
//        }
//         guard currentTranscriptionTask == nil else {
//             print("Streaming already in progress.")
//             return
//         }
//
//        // Request permission
//        guard await hasMicrophonePermission() else {
//             throw NSError(domain: "TranscriptionService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Microphone permission not granted."])
//        }
//
//        // Reset state for new stream
//        resetStreamingState()
//        sendUpdate(isTranscribing: true)
//
//        try audioProcessor.startRecordingLive(inputDeviceID: deviceId) { _ in
//             // Update audio level publisher periodically
//             Task { @MainActor in
//                 self.audioLevelSubject.send(AudioSignalInfo(
//                    bufferEnergy: self.audioProcessor.relativeEnergy,
//                    bufferSeconds: Double(self.audioProcessor.audioSamples.count) / Double(WhisperKit.sampleRate)
//                 ))
//             }
//         }
//
//        // Start the background transcription loop
//        currentTranscriptionTask = Task(priority: .userInitiated) {
//             try await realtimeLoop(options: options)
//         }
//        print("Streaming transcription started.")
//    }
//
//    func stopStreamingTranscription() {
//        guard currentTranscriptionTask != nil else { return }
//
//        print("Stopping streaming transcription.")
//        currentTranscriptionTask?.cancel()
//        currentTranscriptionTask = nil
//        audioProcessor.stopRecording()
//
//        // Finalize any pending text/segments
//         finalizeText()
//        sendUpdate(isTranscribing: false) // Indicate stopped
//    }
//
//    // MARK: - Helpers
//
//    private func realtimeLoop(options: DecodingOptions) async throws {
//         var lastBufferSize = 0
//
//        while !Task.isCancelled {
//            // 1. Get current buffer
//            let currentBuffer = audioProcessor.audioSamples // This is a copy
//
//            // 2. Check amount of new audio samples
//            let nextBufferSize = currentBuffer.count - lastBufferSize
//            let nextBufferSeconds = Float(nextBufferSize) / Float(WhisperKit.sampleRate)
//
//            // 3. Check delay interval
//            // Use configurable delay from options or a default
//            let requiredDelay = options.maxInitialTimestamp ?? 1.0
//            guard nextBufferSeconds > requiredDelay else {
//                 try await Task.sleep(nanoseconds: 100_000_000) // Sleep 100ms
//                 continue
//            }
//
//            // 4. Check VAD (if enabled in options)
//            if options.chunkingStrategy == .vad { // Assuming VAD option controls this check
//                 let voiceDetected = AudioProcessor.isVoiceDetected(
//                     in: audioProcessor.relativeEnergy,
//                     nextBufferInSeconds: nextBufferSeconds,
//                     silenceThreshold: options.noSpeechThreshold ?? 0.3 // Use option or default
//                 )
//                 guard voiceDetected else {
//                     // TODO: Potential silent segment purge logic
//                    try await Task.sleep(nanoseconds: 100_000_000)
//                    continue
//                }
//            }
//
//             // Record buffer size for next iteration *before* transcription
//            lastBufferSize = currentBuffer.count
//
//            // 5. Perform transcription on the *current* buffer
//            print("Processing buffer of \(nextBufferSeconds)s (Total: \(Double(currentBuffer.count) / Double(WhisperKit.sampleRate))s)")
//            do {
//                // Determine if using Eager mode based on options
////                if options.enableEagerDecoding ?? false {
////                     guard whisperKit?.textDecoder.supportsWordTimestamps ?? false else {
////                        throw NSError(domain: "Service", code: -10, userInfo: [NSLocalizedDescriptionKey: "Eager mode requires word timestamps not supported by this model."])
////                    }
////                    _ = try await performEagerTranscription(on: Array(currentBuffer), options: options)
////                 } else {
//                    let results = try await performTranscription(on: Array(currentBuffer), options: options, isStreaming: true)
//                    processStandardStreamingResults(results, bufferDuration: Double(currentBuffer.count) / Double(WhisperKit.sampleRate))
////                 }
//            } catch let error as CancellationError {
//                print("Realtime loop cancelled.")
//                throw error // Propagate cancellation
//            } catch {
//                print("Error during streaming transcription loop: \(error)")
//                // Decide if loop should continue or stop based on error type
//                 sendUpdate(error: error)
//                // Maybe break or throw depending on severity
//                 throw error // Example: Stop loop on error
//            }
//
//              // Small sleep to prevent tight looping if transcription is very fast
//            try await Task.sleep(nanoseconds: 50_000_000)
//        }
//    }
//
//    // Refactored transcription logic used by file and standard streaming
//    private func performTranscription(on samples: [Float], options: DecodingOptions, isStreaming: Bool) async throws -> [TranscriptionResult] {
//         guard let whisperKit = whisperKit else { throw TransServErr.notLoaded }
//
//         var transcriptionOptions = options
//         if isStreaming {
//            transcriptionOptions.clipTimestamps = [lastConfirmedSegmentEndSeconds] // Use the state for clipping
//             transcriptionOptions.chunkingStrategy = Optional.none // Streaming manages chunks via loop
//         }
//
//        return try await whisperKit.transcribe(
//             audioArray: samples,
//             decodeOptions: transcriptionOptions,
//             callback: decodingCallback(options: transcriptionOptions, isStreaming: isStreaming)
//         )
//     }
//
//    private func performEagerTranscription(on samples: [Float], options: DecodingOptions) async throws -> TranscriptionResult? {
//        guard let whisperKit = whisperKit else { throw TransServErr.notLoaded }
//
//        var streamOptions = options
//        streamOptions.clipTimestamps = [lastAgreedSeconds]
//        let lastAgreedTokens = lastAgreedWords.flatMap { $0.tokens }
//        streamOptions.prefixTokens = lastAgreedTokens
//        streamOptions.chunkingStrategy = Optional.none // Eager mode handles segments internally
//
//        Logging.info("[EagerMode] Processing from \(lastAgreedSeconds)s")
//
//        let transcriptionResults: [TranscriptionResult] = try await whisperKit.transcribe(
//            audioArray: samples,
//            decodeOptions: streamOptions,
//            callback: decodingCallback(options: streamOptions, isStreaming: true) // Use same callback logic for preview
//        )
//
//        let transcription = transcriptionResults.first // Eager assumes one result for the window
//
//        // --- Eager Result Processing ---
//        var skipAppend = false // Reuse existing logic structure
//        if let result = transcription {
//            // Filter words starting at or after the last agreed point
//            let currentHypothesisWords = result.allWords.filter { $0.start >= lastAgreedSeconds }
//
//            if let previousResult = self.prevResult {
//                 let previousWindowWords = previousResult.allWords.filter { $0.start >= lastAgreedSeconds }
//                 let commonPrefix = findLongestCommonPrefix(previousWindowWords, currentHypothesisWords)
//
//                 // Use configurable confirmations needed
//                //let confirmations = Int(options.tokenConfirmationsNeeded ?? 2.0)
//                let confirmations = 2
//
//                if commonPrefix.count >= confirmations {
//                    // Agree on all but the last 'confirmations' number of words in the prefix
//                    let newlyConfirmed = Array(commonPrefix.prefix(commonPrefix.count - confirmations))
//                    if !newlyConfirmed.isEmpty {
//                        confirmedWords.append(contentsOf: newlyConfirmed)
//                         // Set the *new* agreed starting point and words for the *next* iteration
//                         lastAgreedWords = Array(commonPrefix.suffix(confirmations))
//                         lastAgreedSeconds = lastAgreedWords.first?.start ?? lastAgreedSeconds // Update time
//                        Logging.info("[EagerMode] Confirmed up to \(lastAgreedSeconds)s")
//                    } else {
//                        // Prefix found, >= confirmations, but nothing *new* to confirm (overlap only)
//                        lastAgreedWords = commonPrefix // Keep the overlap as agreed
//                        lastAgreedSeconds = lastAgreedWords.first?.start ?? lastAgreedSeconds
//                        Logging.info("[EagerMode] Re-confirmed prefix, still at \(lastAgreedSeconds)s")
//                    }
//                } else {
//                    // Not enough common words to confirm anything new
//                    Logging.info("[EagerMode] Not enough confirmations (\(commonPrefix.count)/\(confirmations)). Holding at \(lastAgreedSeconds)s")
//                    skipAppend = true // Prevent adding this result to the history if unstable
//                }
//            }
//            // Store the current result for the *next* iteration's comparison
//            if !skipAppend {
//                self.prevResult = result
//                 eagerResults.append(result) // Keep history if needed
//            }
//        }
//
//        // --- Update UI Publisher ---
//        let confirmedStr = confirmedWords.map { $0.word }.joined()
//        // Recalculate hypothesis based on *current* result relative to *newly updated* lastAgreedWords/Seconds
//        let finalHypothesisWords = (transcription?.allWords ?? []).filter { $0.start >= lastAgreedSeconds }
//        let hypothesisStr = finalHypothesisWords.map { $0.word }.joined()
//
//         let update = TranscriptionUpdate(
//            confirmedText: confirmedStr,
//            hypothesisText: hypothesisStr,
//            currentDecodingText: currentDecodingTextPreview, // From callback
//             metrics: mapMetrics(transcription?.timings),
//             isTranscribing: true // Still actively streaming
//         )
//        sendUpdate(update: update)
//
//        return transcription // Return result for potential external use
//    }
//
//    // Store the ongoing preview from the callback
//    private var currentDecodingTextPreview: String = ""
//    private var currentDecodingFallbacks: Int = 0
//
//    // Shared decoding callback (simplified version)
//    private func decodingCallback(options: DecodingOptions, isStreaming: Bool) -> ((TranscriptionProgress) -> Bool?) {
//         return { [weak self] progress in
//             guard let self = self else { return false } // Should not happen due to Task capturing self
//
//             // --- Update Realtime Preview Text ---
//            // Logic to handle fallbacks and update the ongoing preview text
//             let fallbacks = Int(progress.timings.totalDecodingFallbacks)
//             var newPreview = progress.text
//             if isStreaming { // Only manage chunks concept in streaming; file is one chunk
//                 // If fallbacks increased, it might replace the last part of the text
//                 if fallbacks > self.currentDecodingFallbacks {
//                    // Basic assumption: fallback replaces previous attempt for the *same window*
//                     print("Fallback occurred in decoder preview")
//                 } else if newPreview.count < self.currentDecodingTextPreview.count && fallbacks == self.currentDecodingFallbacks {
//                     // Text got shorter without fallback - likely new window processing started? Append conceptually.
//                    // This part is tricky without window IDs from WhisperKit progress.
//                    // Simplification: Assume it continues if not fallback.
//                    newPreview = self.currentDecodingTextPreview + newPreview
//                 }
//             }
//            
//             self.currentDecodingTextPreview = newPreview
//             self.currentDecodingFallbacks = fallbacks
//
//             // Send an update *only* containing the preview text if needed frequently,
//             // or just store it here and include it in the main update after transcription finishes/loops.
//             // For simplicity here, we store it and let the main loop send the update.
//
//             // --- Early Stopping Logic ---
//             let currentTokens = progress.tokens
//             //let checkWindow = Int(options.compressionCheckWindow ?? 60) // Use option or default
//             let checkWindow = 60
//             if currentTokens.count > checkWindow {
//                 let checkTokens: [Int] = currentTokens.suffix(checkWindow)
//                 let compressionRatio = compressionRatio(of: checkTokens)
//                 if compressionRatio > options.compressionRatioThreshold ?? 2.4 { // Use option or default
//                     Logging.debug("Early stopping: Compression Ratio")
//                     return false // Stop decoding this segment
//                 }
//             }
//             if progress.avgLogprob ?? 0 < options.logProbThreshold ?? -1.0 { // Use option or default
//                 Logging.debug("Early stopping: Log Probability")
//                 return false // Stop decoding this segment
//             }
//
//             return nil // Continue decoding
//         }
//     }
//
//    // Helper to process results for standard (non-eager) streaming
//    private func processStandardStreamingResults(_ results: [TranscriptionResult], bufferDuration: Double) {
//        guard let result = mergeTranscriptionResults(results) else { return } // Assuming merge helper exists
//
//        let segments = result.segments
//
//        // Use configurable required segments
//        let confirmations = requiredSegmentsForConfirmation
//
//        if segments.count > confirmations {
//             let numberOfSegmentsToConfirm = segments.count - confirmations
//             let confirmedSegmentsArray = Array(segments.prefix(numberOfSegmentsToConfirm))
//             let remainingSegments = Array(segments.suffix(confirmations))
//
//             if let lastConfirmed = confirmedSegmentsArray.last, lastConfirmed.end > lastConfirmedSegmentEndSeconds {
//                 lastConfirmedSegmentEndSeconds = lastConfirmed.end
//                 print("Standard Stream: Confirmed up to \(lastConfirmedSegmentEndSeconds)s")
//                 // Append confirmed segments, avoiding duplicates
//                 for segment in confirmedSegmentsArray {
//                     if !confirmedSegments.contains(where: { $0 == segment }) { // Requires TranscriptionSegment: Equatable
//                        confirmedSegments.append(segment)
//                    }
//                 }
//             }
//             unconfirmedSegments = remainingSegments
//        } else {
//            unconfirmedSegments = segments
//        }
//
//        // Update publisher
//        let update = TranscriptionUpdate(
//            segments: confirmedSegments + unconfirmedSegments, // Combine for display
//            currentDecodingText: currentDecodingTextPreview,
//            metrics: mapMetrics(result.timings, totalAudioDuration: bufferDuration),
//            isTranscribing: true
//        )
//        sendUpdate(update: update)
//     }
//
//     private func finalizeText() {
//        // Called when stopping transcription
//        if !unconfirmedSegments.isEmpty {
//            confirmedSegments.append(contentsOf: unconfirmedSegments)
//            unconfirmedSegments = []
//        }
//        // Eager mode finalization
////         if !lastAgreedWords.isEmpty || !hypothesisWords.isEmpty {
//         if !lastAgreedWords.isEmpty {
//            // Assume the last hypothesis was correct
//             let finalWordsToConfirm = lastAgreedWords //+ hypothesisWords
//             confirmedWords.append(contentsOf: finalWordsToConfirm)
//             lastAgreedWords = []
////             hypothesisWords = []
//         }
//
//         // Send final update
//        let update = TranscriptionUpdate(
//            segments: confirmedSegments,
//            confirmedText: confirmedWords.map { $0.word }.joined(),
//            hypothesisText: "",
//            isTranscribing: false
//        )
//        sendUpdate(update: update)
//        resetStreamingState() // Clean up for next time
//     }
//
//     private func resetStreamingState() {
//        lastConfirmedSegmentEndSeconds = 0.0
//        confirmedSegments = []
//        unconfirmedSegments = []
//        eagerResults = []
//        prevResult = nil
//        lastAgreedSeconds = 0.0
//        prevWords = []
//        lastAgreedWords = []
//        confirmedWords = []
//         currentDecodingTextPreview = ""
//         currentDecodingFallbacks = 0
//         // Don't reset metrics here, they reflect the *last* run
//    }
//
//    // Simplified error enum
//    enum TransServErr: LocalizedError {
//        case notLoaded
//        var errorDescription: String? {
//            switch self {
//            case .notLoaded: return "WhisperKit model is not loaded."
//            }
//        }
//    }
//
//    // Maps WhisperKit timings to the metrics struct
//     private func mapMetrics(_ timings: TranscriptionTimings?, totalAudioDuration: Double? = nil) -> TranscriptionUpdate.TranscriptionMetrics? {
//        guard let timings = timings else { return nil }
//        
//         var metrics = TranscriptionUpdate.TranscriptionMetrics(
//             tokensPerSecond: timings.tokensPerSecond,
//             realTimeFactor: timings.realTimeFactor,
//             speedFactor: timings.speedFactor, // Assuming this comes from timings
//             firstTokenTime: timings.firstTokenTime,
//             pipelineStart: timings.pipelineStart,
//             currentLag: timings.decodingLoop, // Example mapping
//             currentFallbacks: Int(timings.totalDecodingFallbacks),
//             currentEncodingLoops: Int(timings.totalEncodingRuns),
//             currentDecodingLoops: Int(timings.totalDecodingRuns),
//             totalInferenceTime: timings.fullPipeline ?? 0
//         )
//
//         // Recalculate RTF/Speed based on total buffer if provided (for streaming)
//         if let duration = totalAudioDuration, duration > 0 {
//            metrics.realTimeFactor = metrics.totalInferenceTime / duration
//             metrics.speedFactor = duration / metrics.totalInferenceTime
//         }
//         
//         return metrics
//     }
//
//    // Send update to publisher (ensures it's on main thread)
//    private func sendUpdate(update: TranscriptionUpdate? = nil, error: Error? = nil, isTranscribing: Bool? = nil) {
//        Task { @MainActor in
//            var finalUpdate = update ?? TranscriptionUpdate() // Start with provided or empty
//            if let error = error {
//                 finalUpdate.error = error
//             }
//             if let isTranscribing = isTranscribing {
//                 finalUpdate.isTranscribing = isTranscribing
//             }
//             // Always ensure preview text is included if it exists
//             if finalUpdate.currentDecodingText.isEmpty && !currentDecodingTextPreview.isEmpty {
//                 finalUpdate.currentDecodingText = currentDecodingTextPreview
//             }
//             
//            transcriptionUpdateSubject.send(finalUpdate)
//            
//            // Clear transient state after sending update
//            if error != nil || isTranscribing == false {
//                currentDecodingTextPreview = "" // Clear preview on error or stop
//            }
//        }
//    }
//
//    // --- Permissions and System Info ---
//    func hasMicrophonePermission() async -> Bool {
//         await AudioProcessor.requestRecordPermission()
//    }
//
//    func getAudioDevices() -> [AudioDevice] {
//        #if os(macOS)
//        return AudioProcessor.getAudioDevices()
//        #else
//        return []
//        #endif
//    }
//    
//    // Helper to construct DecodingOptions from settings
//    func currentDecodingOptions(from settings: AppSettings) -> DecodingOptions {
//         let languageCode = Constants.languages[settings.selectedLanguage, default: Constants.defaultLanguageCode]
//         let task: DecodingTask = settings.selectedTask == "transcribe" ? .transcribe : .translate
//
//         // Use *state* for clip timestamps, not raw settings value
//        let seekClip: [Float] = (settings.enableEagerDecoding) ? [lastAgreedSeconds] : [lastConfirmedSegmentEndSeconds]
//
//         return DecodingOptions(
//             verbose: true, // Or from settings
//             task: task,
//             language: languageCode,
//             temperature: Float(settings.temperatureStart),
//             temperatureFallbackCount: Int(settings.fallbackCount),
//             compressionRatioThreshold: options.compressionRatioThreshold, // Keep existing default or add setting
//             logProbThreshold: options.logProbThreshold, // Keep existing default or add setting
//             noSpeechThreshold: options.noSpeechThreshold, // Keep existing default or add setting
//             sampleLength: Int(settings.sampleLength),
//             usePrefillPrompt: settings.enablePromptPrefill,
//             usePrefillCache: settings.enableCachePrefill,
//             skipSpecialTokens: !settings.enableSpecialCharacters,
//             withoutTimestamps: !settings.enableTimestamps,
//             wordTimestamps: settings.enableEagerDecoding || settings.enableTimestamps, // Enable if eager or if timestamps wanted
//             firstTokenLogProbThreshold: (settings.enableEagerDecoding ?? false) ? -1.5 : nil, // Eager specific threshold
//             clipTimestamps: seekClip, // Use dynamically determined clip time
//             chunkingStrategy: settings.chunkingStrategy,
//             silenceThreshold: Float(settings.silenceThreshold), // Pass VAD setting
//             realtimeDelayInterval: Float(settings.realtimeDelayInterval), // Pass streaming delay
//             tokenConfirmationsNeeded: settings.tokenConfirmationsNeeded, // Pass eager setting
//             enableEagerDecoding: settings.enableEagerDecoding, // Pass eager setting
//             concurrentWorkerCount: Int(settings.concurrentWorkerCount) == 0 ? nil : Int(settings.concurrentWorkerCount) // nil for unlimited
//         )
//     }
//}
//
//// MARK: - Helper Functions (Example: Merge Results, Needs definition based on original)
//func mergeTranscriptionResults(_ results: [TranscriptionResult?]) -> TranscriptionResult? {
//    // Implementation depends on how WhisperKit returns chunked results.
//    // Often involves merging segments, recalculating timings average/sum.
//    // Placeholder: just return the first non-nil for simplicity
//    results.compactMap { $0 }.first
//}
//
//func findLongestCommonPrefix(_ arr1: [WordTiming], _ arr2: [WordTiming] ) -> [WordTiming] {
//    // Implementation needed - compares sequences of WordTiming based on equality
//    // Return the common prefix sequence
//    guard !arr1.isEmpty, !arr2.isEmpty else { return [] }
//    var commonPrefix: [WordTiming] = []
//    let minLength = min(arr1.count, arr2.count)
//    for i in 0..<minLength {
//        // Need a proper equality check for WordTiming (start, end, word, tokens?)
//        if arr1[i].word == arr2[i].word && abs(arr1[i].start - arr2[i].start) < 0.1 { // Example equality check
//            commonPrefix.append(arr1[i])
//        } else {
//            break // Stop at first mismatch
//        }
//    }
//    return commonPrefix
//}
//
//func findLongestDifferentSuffix(_ arr1: [WordTiming], _ arr2: [WordTiming] ) -> [WordTiming] {
//     // Helper to find the part of arr2 that comes *after* the common prefix with arr1
//     let commonPrefix = findLongestCommonPrefix(arr1, arr2)
//     if commonPrefix.count < arr2.count {
//        return Array(arr2.suffix(from: commonPrefix.count))
//     }
//     return []
// }
//
//// Need `compressionRatio` implementation from original or WhisperKit utils
//func compressionRatio(of tokens: [Int]) -> Float {
//    // Placeholder implementation
//    return 0.0
//}
//
//// Make TranscriptionSegment Equatable if not already
//extension TranscriptionSegment {
//    public static func == (lhs: TranscriptionSegment, rhs: TranscriptionSegment) -> Bool {
//        // Define equality based on start time and possibly text
//        return lhs.start == rhs.start && lhs.text == rhs.text
//    }
//}
//
//// Make WordTiming Equatable if not already (needed for eager mode prefix logic)
//extension WordTiming {
//     public static func == (lhs: WordTiming, rhs: WordTiming) -> Bool {
//         return lhs.word == rhs.word && lhs.start == rhs.start && lhs.end == rhs.end
//     }
// }
//
//
//
