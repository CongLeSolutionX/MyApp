//
//  ContentViewModel_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

//  ContentViewModel.swift
//  WhisperAX (Enhanced)
//
//  For licensing see accompanying LICENSE.md file.
//  Copyright © 2024 Argmax, Inc. All rights reserved.
//
//  This ViewModel orchestrates the interaction between the UI (Views)
//  and the backend logic (TranscriptionService). It holds the application's
//  state relevant to the UI and exposes actions (intents) that the View can call.
//

import Foundation
import SwiftUI // For Color, UIPasteboard/NSPasteboard access within #if blocks
import Combine
import WhisperKit // Primarily for types like ModelState, AudioDevice, DecodingOptions, TranscriptionSegment etc.
#if os(macOS)
import AppKit // For NSWorkspace, NSPasteboard
#else
import UIKit // For UIDevice, UIApplication, UIPasteboard
#endif

@MainActor // Ensure UI-related updates happen on the main thread
class ContentViewModel: ObservableObject {

    // MARK: - Dependencies

    private let transcriptionService: TranscriptionServiceProtocol
    @ObservedObject var settings: AppSettings // Settings are directly observed for reactivity

    // MARK: - Published UI State

    // Model Status & Management
    @Published var modelState: ModelState = .unloaded
    @Published var availableModels: [String] = []
    @Published var localModels: [String] = []
    @Published var downloadProgress: Double = 0.0
    @Published var modelFolderExists: Bool = false

    // Transcription Status & Output
    @Published var isRecording: Bool = false
    @Published var isTranscribing: Bool = false // Reflects actual processing activity
    @Published var transcriptionText: String = "" // General purpose display text (formatted)
    @Published var confirmedSegments: [TranscriptionSegment] = [] // For standard streaming/file display
    @Published var unconfirmedSegments: [TranscriptionSegment] = [] // For standard streaming display (often styled differently)
    @Published var confirmedEagerText: String = "" // For eager streaming display (confirmed part)
    @Published var hypothesisEagerText: String = "" // For eager streaming display (likely next part)
    @Published var decoderPreviewText: String = "" // Raw decoder output preview

    // Realtime Signals & Metrics
    @Published var audioSignal = AudioSignalInfo() // Holds buffer energy and duration
    @Published var metrics = TranscriptionUpdate.TranscriptionMetrics() // Performance metrics

    // Configuration UI Support
    @Published var availableLanguages: [String] = Constants.languages.map { $0.key }.sorted() // Static list from WhisperKit
    @Published var audioDevices: [AudioDevice] = [] // macOS specific audio input devices

    // UI Interaction State
    @Published var errorMessage: String? = nil // For displaying errors to the user
    @Published var showSettingsSheet: Bool = false // Controls visibility of the settings sheet
    @Published var selectedTab: Tab = .transcribe // Current active tab (enum for type safety)

    // MARK: - Tab Enum Definition
    enum Tab: String, Identifiable, CaseIterable {
        case transcribe = "Transcribe"
        case stream = "Stream"

        var id: String { rawValue } // Conformance to Identifiable

        // Associated system image name for UI
        var imageName: String {
            switch self {
            case .transcribe: return "book.pages"
            case .stream: return "waveform.badge.mic"
            }
        }
    }

    // MARK: - Private State

    private var cancellables = Set<AnyCancellable>() // Stores Combine subscriptions
    private var currentTranscriptionTask: Task<Void, Never>? // Holds the active transcription task (file or stream loop)

    // MARK: - Initialization

    init(transcriptionService: TranscriptionServiceProtocol = TranscriptionService(), settings: AppSettings = AppSettings()) {
        self.transcriptionService = transcriptionService
        self.settings = settings

        // Fetch initial data asynchronously
        Task {
            await transcriptionService.fetchAvailableModels(repoName: settings.repoName)
            self.updateModelFolderExists() // Check initial folder status
        }

        #if os(macOS)
        self.audioDevices = transcriptionService.getAudioDevices()
        // Ensure the default selection is valid
        if !audioDevices.contains(where: { $0.name == settings.selectedAudioInput }) {
            settings.selectedAudioInput = audioDevices.first?.name ?? "No Audio Input"
        }
        #endif

        setupBindings() // Connect publishers to state variables
    }

    // MARK: - Combine Bindings Setup

    private func setupBindings() {
        // Model State Binding
        transcriptionService.modelStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$modelState)

        // Download Progress Binding
        transcriptionService.downloadProgressPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$downloadProgress)

        // Available Models Binding
        transcriptionService.availableModelsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$availableModels)
            
        // Local Models Binding
        transcriptionService.localModelsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$localModels)

        // Realtime Audio Level Binding
        transcriptionService.audioLevelPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$audioSignal)

        // Transcription Updates Handling
        transcriptionService.transcriptionUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.handleTranscriptionUpdate(update)
            }
            .store(in: &cancellables)

        // React to Settings Changes Requiring Model Reset/Reload
//        settings.$selectedModel
//            //.dropFirst() // Ignore the initial value set during init
//            //.receive(on: DispatchQueue.main)
//            .sink { [weak self] newModel in
//                print("Selected model changed to \(newModel), resetting state.")
//                self?.resetState() // Ensure UI/transcription state is cleared
//                // Service state might persist, but ViewModel state indicates need for reload
//                self?.modelState = .unloaded
//            }
//            .store(in: &cancellables)
//            
//        settings.$encoderComputeUnits
//            .dropFirst()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                print("Encoder compute units changed, resetting state.")
//                self?.resetState()
//                self?.modelState = .unloaded // Trigger UI to show "Load Model"
//            }
//            .store(in: &cancellables)
//
//        settings.$decoderComputeUnits
//           .dropFirst()
//           .receive(on: DispatchQueue.main)
//           .sink { [weak self] _ in
//               print("Decoder compute units changed, resetting state.")
//               self?.resetState()
//               self?.modelState = .unloaded // Trigger UI to show "Load Model"
//           }
//           .store(in: &cancellables)

        // Update Model Folder Existence Status
        // React to both model state changes and potentially local model list changes
        Publishers.CombineLatest(
            transcriptionService.modelStatePublisher,
            transcriptionService.localModelsPublisher
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _, _ in
            self?.updateModelFolderExists()
        }
        .store(in: &cancellables)
    }

    // Helper to check model folder existence
    private func updateModelFolderExists() {
        self.modelFolderExists = self.transcriptionService.modelFolderURL != nil && FileManager.default.fileExists(atPath: transcriptionService.modelFolderURL!.path)
    }

    // MARK: - Intents (Actions triggered by the View)

    func loadSelectedModel() {
        // Prevent concurrent loads
        guard modelState == .unloaded else {
            print("Load request ignored: Model state is \(modelState)")
            return
        }

        let modelToLoad = settings.selectedModel
        let computeOptions = settings.getComputeOptions()
        let repo = settings.repoName
        let storagePath = settings.modelStoragePath // Use the setting for path

        errorMessage = nil // Clear previous error

        Task {
            do {
                resetState() // Ensure clean state before loading starts
                // Model state is updated via publisher to .loading etc.
                try await transcriptionService.loadModel(
                    modelToLoad,
                    from: repo,
                    computeOptions: computeOptions,
                    localModelPathBase: storagePath
                )
                // Successful load state (.loaded) will be set via publisher
            } catch {
                // Error occurred, state set to .unloaded by service
                errorMessage = "Failed to load model '\(modelToLoad)': \(error.localizedDescription)"
            }
        }
    }

    func deleteSelectedModel() async {
        guard localModels.contains(settings.selectedModel) else {
            print("Delete request ignored: Model '\(settings.selectedModel)' not found locally.")
            return
        }
        // Prevent deletion while model is actively loading/prewarming
        guard !modelState.isProcessing else {
             print("Delete request ignored: Model is currently being processed.")
             errorMessage = "Cannot delete model while it's loading or prewarming."
            return
        }

        let modelToDelete = settings.selectedModel
        let storagePath = settings.modelStoragePath
        
        errorMessage = nil // Clear previous error

        do {
            try await transcriptionService.deleteModel(modelToDelete, localModelPathBase: storagePath)
            // State updates (localModels list, potentially modelState) handled by service publishers

            // If the deleted model was the currently selected one, select a new default
            if settings.selectedModel == modelToDelete {
                // Prefer another *local* model if available, otherwise the global default
                settings.selectedModel = availableModels.first(where: { localModels.contains($0) && $0 != modelToDelete }) ?? WhisperKit.recommendedModels().default
                // Make sure the service state for the active model is reset if needed
                if transcriptionService.currentModelState != .unloaded {
                    // This shouldn't strictly be necessary if service handles it, but belt-and-suspenders
                     self.modelState = .unloaded
                }
            }
             updateModelFolderExists() // Update folder status after deletion
        } catch {
            errorMessage = "Failed to delete model '\(modelToDelete)': \(error.localizedDescription)"
        }
    }
    
    // Unified function to handle starting/stopping recording for stream or single buffer
    func toggleRecording(isStream: Bool) async {
        cancelOngoingTranscription() // Ensure any previous file task is stopped

        if isRecording {
            // --- Stop Recording ---
            Task {
               transcriptionService.stopStreamingTranscription() // Handles cancelling loop and finalizing
               // isRecording and isTranscribing state updates flow from service via handleTranscriptionUpdate
           }
        } else {
            // --- Start Recording / Streaming ---
            guard modelState == .loaded else {
                errorMessage = "Model is not loaded. Please load a model first."
                return
            }
            resetTranscriptionState() // Clear previous text, segments, etc.

            let options = await transcriptionService.currentDecodingOptions(from: settings)
            var deviceId: DeviceID? = nil
            #if os(macOS)
                // Find the selected device ID, be careful if selection is "No Audio Input"
                if settings.selectedAudioInput != "No Audio Input" {
                    deviceId = audioDevices.first(where: { $0.name == settings.selectedAudioInput })?.id
                 }
                 // Handle case where selected device isn't found anymore? Fallback? Error?
                 if deviceId == nil && settings.selectedAudioInput != "No Audio Input" {
                     print("Warning: Selected audio device '\(settings.selectedAudioInput)' not found. Using default.")
                 }
            #endif
            
            currentTranscriptionTask = Task {
               do {
                   isRecording = true // Set immediately for responsive UI
                   // Service will update isTranscribing via publisher
                   if isStream {
                       try await transcriptionService.startStreamingTranscription(deviceId: deviceId, options: options)
                   } else {
                       // For non-streaming, we start recording but transcription happens *after* stop
                       try await transcriptionService.startStreamingTranscription(deviceId: deviceId, options: options) // Reuse startStreaming for audio capture setup
                       // Don't start the `realtimeLoop` in this case, just capture audio
                       // The transcription will be triggered in the stop action below
                       print("Started recording mode (buffered).")
                   }
               } catch {
                   isRecording = false
                   errorMessage = "Failed to start recording: \(error.localizedDescription)"
                   // Ensure isTranscribing is also false if start fails
                   isTranscribing = false
               }
            }
        }
    }

    // Specific function for stopping the buffered recording mode
    func stopBufferedRecordingAndTranscribe() async {
         guard isRecording && selectedTab == .transcribe else { return } // Only applies to non-stream recording

         print("Stopping buffered recording and starting transcription...")
         // 1. Stop audio capture via the service
         transcriptionService.stopStreamingTranscription() // This stops audio capture and cancels any potential loop (though none was started)
         isRecording = false

         // 2. Trigger transcription of the captured buffer
        let options = await transcriptionService.currentDecodingOptions(from: settings)
         // Access the buffer *after* stopping capture
         let capturedSamples = transcriptionService.audioProcessor.audioSamples

         currentTranscriptionTask = Task {
            do {
                 isTranscribing = true // Indicate processing start
                 // Directly transcribe the captured buffer (assuming service has method or combine methods)
                 // This might require adding a method like `transcribeSamples` to the service protocol
                 // For now, let's simulate using the file transcription logic path with samples
                 
                 // --- Simulating transcription from samples ---
                 // Ideally, service would have: try await service.transcribeSamples(capturedSamples, options: options)
                 let results = try await transcriptionService.performTranscription( // Use internal helper for demo
                     on: capturedSamples,
                     options: options,
                     isStreaming: false // Treat as a single batch
                 )
                 let mergedResult = mergeTranscriptionResults(results)
                 handleTranscriptionUpdate(TranscriptionUpdate(
                     segments: mergedResult?.segments ?? [],
                     metrics: mapMetrics(mergedResult?.timings), // Need mapMetrics helper
                     isTranscribing: false
                 ))
                 // --- End Simulation ---
                 
            } catch {
                 errorMessage = "Failed to transcribe recorded audio: \(error.localizedDescription)"
                 isTranscribing = false
            }
         }
     }

    // Called by the View after file picker selection
    func transcribeFile(url: URL) async {
        guard modelState == .loaded else {
            errorMessage = "Model is not loaded."
            return
        }
        // Ensure we have security scope access if needed
        guard url.startAccessingSecurityScopedResource() else {
           errorMessage = "Permission denied for file access at \(url.path)."
           return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        cancelOngoingTranscription() // Stop any active stream/recording
        resetTranscriptionState() // Clear previous results

        let options = await transcriptionService.currentDecodingOptions(from: settings)

        currentTranscriptionTask = Task {
            do {
                // Service will publish updates, including isTranscribing=true at start
                try await transcriptionService.transcribeFile(path: url.path, options: options)
                // Service will publish final update with isTranscribing=false
            } catch {
                 // Service should publish an error update, caught by handleTranscriptionUpdate
                errorMessage = "Failed to transcribe file: \(error.localizedDescription)"
                // Ensure transcription state is false if error occurs during processing
                 isTranscribing = false
            }
        }
    }
    
    // Action to open the folder containing the currently selected model
    func openModelFolder() {
        #if os(macOS)
        guard let url = transcriptionService.modelFolderURL else {
            print("Model folder URL not available.")
            return
        }
        guard FileManager.default.fileExists(atPath: url.path) else {
             print("Model folder does not exist at \(url.path)")
             errorMessage = "Model folder not found. It might have been deleted or moved."
             return
         }
        NSWorkspace.shared.open(url)
        #endif
    }

    // Action to open the Hugging Face repository URL
    func openRepoURL() {
        guard let url = URL(string: "https://huggingface.co/\(settings.repoName)") else { return }
       #if os(macOS)
        NSWorkspace.shared.open(url)
       #else
        // Ensure the app can open external URLs (check Info.plist LSApplicationQueriesSchemes if needed)
        UIApplication.shared.open(url)
       #endif
    }

    // Action to copy the current transcription text to the clipboard
    func copyTranscriptionToClipboard() {
        let textToCopy: String
        if settings.enableEagerDecoding && selectedTab == .stream {
            // Combine confirmed and hypothesis for eager mode copy
            textToCopy = confirmedEagerText + hypothesisEagerText
        } else {
            // Format standard segments with optional timestamps
           textToCopy = formatSegments(confirmedSegments + unconfirmedSegments, withTimestamps: settings.enableTimestamps)
               .joined(separator: "\n")
        }

        guard !textToCopy.isEmpty else { return } // Don't copy empty string

        #if os(iOS) || os(visionOS) // visionOS uses UIKit patterns here
        UIPasteboard.general.string = textToCopy
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(textToCopy, forType: .string)
        #endif
        print("Transcription copied to clipboard.") // Maybe add user feedback (brief message?)
    }
    
    // MARK: - State Update Handling

    // Centralized function to process updates received from the TranscriptionService
    private func handleTranscriptionUpdate(_ update: TranscriptionUpdate) {
        // Handle Errors first
       if let error = update.error {
           // Ignore cancellation errors, show others
           if !(error is CancellationError) {
                errorMessage = "Transcription Error: \(error.localizedDescription)"
                print("Received Transcription Error: \(error)")
           } else {
                print("Transcription task cancelled.")
           }
           // Ensure state reflects stopped processing on error
           isTranscribing = false
           isRecording = false // Recording should stop if transcription fails critically
           cancelOngoingTranscription() // Clean up dangling task if error occurs
       } else {
           // Clear error message if update is successful
           // Consider only clearing if the *last* operation was successful
           // errorMessage = nil // Might clear transient errors too quickly
       }

       // Update Transcription State (active processing status)
       isTranscribing = update.isTranscribing

       // Update Display Text based on mode (Eager vs. Standard)
       if settings.enableEagerDecoding && selectedTab == .stream {
            if !update.confirmedText.isEmpty || !update.hypothesisText.isEmpty || !update.isTranscribing { // Only update if relevant data changed or stopped
                 confirmedEagerText = update.confirmedText
                 hypothesisEagerText = update.hypothesisText
                 // `transcriptionText` could be a computed property or updated here if needed elsewhere
            }
            // Clear standard segment data when in eager mode
            confirmedSegments = []
            unconfirmedSegments = []
        } else {
           // Standard mode uses segments
           // This simple approach replaces segments entirely with each update.
           // More sophisticated logic could diff or append based on timestamps.
           confirmedSegments = update.segments.filter { segment in
               // Define 'confirmed' logic (e.g., based on presence in previous confirmed or timestamp)
               // Simple approach: if it was previously confirmed, keep it.
               confirmedSegments.contains(segment) || segment.end <= (confirmedSegments.last?.end ?? 0.0)
           }
           unconfirmedSegments = update.segments.filter { segment in
               segment.end > (confirmedSegments.last?.end ?? 0.0)
           }
            // `transcriptionText` could be computed or formatted here
            // transcriptionText = formatSegments(update.segments, withTimestamps: settings.enableTimestamps).joined(separator: "\n")
             
           // Clear eager text data when in standard mode
           confirmedEagerText = ""
           hypothesisEagerText = ""
        }
        
       // Update Decoder Preview Text
       decoderPreviewText = update.currentDecodingText

       // Update Performance Metrics
       if let newMetrics = update.metrics {
           metrics = newMetrics
       }
       
       // If the update indicates transcription has stopped, ensure recording state is also false
       if !update.isTranscribing {
           if isRecording {
               isRecording = false // Sync recording state if transcription stops
           }
            // Optionally clear decoder preview only when stopped?
            // decoderPreviewText = ""
       }
   }

    // MARK: - State Reset Functions

    // Resets only the state related to an ongoing transcription job
    private func resetTranscriptionState() {
        errorMessage = nil // Clear any active error messages
        transcriptionText = "" // Clear displayed text
        confirmedSegments = [] // Clear segments
        unconfirmedSegments = []
        confirmedEagerText = "" // Clear eager text
        hypothesisEagerText = ""
        decoderPreviewText = "" // Clear preview
        metrics = .init() // Reset performance metrics
        audioSignal = .init() // Reset audio levels visualization
        // Do NOT reset isRecording or isTranscribing here - they are managed by start/stop logic
    }
    
    // Resets broader state, often used when changing models or compute units
    private func resetState() {
        cancelOngoingTranscription() // Stop any active task
        // modelState should be set to .unloaded *before* calling resetState
        // modelState = .unloaded // This signals UI to allow loading
        downloadProgress = 0.0 // Reset progress bar
        isRecording = false // Ensure recording stops
        isTranscribing = false // Ensure transcription stops
        resetTranscriptionState() // Reset text, segments, metrics, etc.
    }

    // MARK: - Task Management

    // Ensures any active transcription task is cancelled safely
    private func cancelOngoingTranscription() {
        if currentTranscriptionTask != nil {
            print("Cancelling ongoing transcription task.")
            currentTranscriptionTask?.cancel()
            currentTranscriptionTask = nil
            // Service should handle its internal state upon cancellation or via stopStreamingTranscription
            // Explicitly update state here to ensure UI responsiveness
            if isTranscribing {
                isTranscribing = false
            }
            if isRecording { // If we cancel a task, associated recording should stop
                isRecording = false
                // Also tell the service to stop capture if it hasn't already
                transcriptionService.stopStreamingTranscription()
            }
        }
    }
    
    // MARK: - Formatting Helpers

    // Formats transcription segments into displayable strings
    private func formatSegments(_ segments: [TranscriptionSegment], withTimestamps: Bool) -> [String] {
        segments.map { segment in
            let timestampPrefix = withTimestamps ? "[\(String(format: "%.2f", segment.start)) → \(String(format: "%.2f", segment.end))] " : ""
            // Handle potential empty text segments gracefully
            return timestampPrefix + (segment.text.isEmpty ? "" : segment.text)
        }
    }

    // Helper to map WhisperKit timings to the ViewModel's metrics structure
     private func mapMetrics(_ timings: TranscriptionTimings?, totalAudioDuration: Double? = nil) -> TranscriptionUpdate.TranscriptionMetrics? {
        guard let timings = timings else { return nil }
        
         var calculatedMetrics = TranscriptionUpdate.TranscriptionMetrics(
             tokensPerSecond: timings.tokensPerSecond,
             realTimeFactor: timings.realTimeFactor,
             speedFactor: timings.speedFactor,
             firstTokenTime: max(0, timings.firstTokenTime - timings.pipelineStart), // Time relative to pipeline start
             pipelineStart: timings.pipelineStart, // Keep absolute start time if needed
             currentLag: timings.decodingLoop, // Map appropriate timing
             currentFallbacks: Int(timings.totalDecodingFallbacks),
             currentEncodingLoops: Int(timings.totalEncodingRuns),
//             currentDecodingLoops: Int(timings.totalDecodingRuns),
             totalInferenceTime: timings.fullPipeline
         )

         // Optionally recalculate RTF/Speed based on total buffer duration for streaming accuracy
         if let duration = totalAudioDuration, duration > 0, calculatedMetrics.totalInferenceTime > 0 {
            calculatedMetrics.realTimeFactor = calculatedMetrics.totalInferenceTime / duration
             calculatedMetrics.speedFactor = duration / calculatedMetrics.totalInferenceTime
         }
         
         return calculatedMetrics
     }

    // MARK: - Application Info Properties (Read-only)

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
    var deviceName: String {
        WhisperKit.deviceName() // Use WhisperKit's helper
    }
    var osVersion: String {
        #if os(iOS)
        UIDevice.current.systemVersion
        #elseif os(macOS)
        // Format macOS version nicely
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #else
        "N/A" // Fallback for other platforms if they exist
        #endif
    }
}
