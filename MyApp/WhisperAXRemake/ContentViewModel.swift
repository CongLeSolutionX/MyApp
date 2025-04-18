//
//  ContentViewModel.swift
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

import Foundation
import SwiftUI // For Color
import Combine
import WhisperKit

@MainActor
class ContentViewModel: ObservableObject {
    
    // --- Services and Settings ---
    private let transcriptionService: TranscriptionServiceProtocol
    @ObservedObject var settings: AppSettings // Use observed object for settings
    
    // --- Published State for UI ---
    @Published var modelState: ModelState = .unloaded
    @Published var availableModels: [String] = []
    @Published var localModels: [String] = []
    @Published var downloadProgress: Double = 0.0
    @Published var modelFolderExists: Bool = false // Based on service's modelFolderURL
    
    @Published var isRecording: Bool = false
    @Published var isTranscribing: Bool = false // Reflects service activity
    @Published var transcriptionText: String = "" // Combined display text
    @Published var confirmedSegments: [TranscriptionSegment] = [] // For non-eager Text view
    @Published var unconfirmedSegments: [TranscriptionSegment] = [] // For non-eager Text view
    @Published var confirmedEagerText: String = "" // For eager display
    @Published var hypothesisEagerText: String = "" // For eager display
    @Published var decoderPreviewText: String = ""
    
    @Published var audioSignal = AudioSignalInfo()
    @Published var metrics = TranscriptionUpdate.TranscriptionMetrics()
    
    @Published var availableLanguages: [String] = Constants.languages.map { $0.key }.sorted() // Static for now
    @Published var audioDevices: [AudioDevice] = [] // macOS
    
    @Published var errorMessage: String? = nil // For displaying errors
    @Published var showSettingsSheet: Bool = false
    
    // UI Navigation State (Example)
    @Published var selectedTab: Tab = .transcribe // Use enum for type safety
    
    enum Tab: String, Identifiable, CaseIterable {
        case transcribe = "Transcribe"
        case stream = "Stream"
        var id: String { rawValue }
        var imageName: String {
            switch self {
            case .transcribe: return "book.pages"
            case .stream: return "waveform.badge.mic"
            }
        }
    }
    
    // --- Private State & Combine ---
    private var cancellables = Set<AnyCancellable>()
    private var currentTranscriptionTask: Task<Void, Never>?
    
    // --- Initialization ---
    init(transcriptionService: TranscriptionServiceProtocol = TranscriptionService(), settings: AppSettings = AppSettings()) {
        self.transcriptionService = transcriptionService
        self.settings = settings
        
        // Fetch initial data
        Task {
            await transcriptionService.fetchAvailableModels(repoName: settings.repoName)
        }
#if os(macOS)
        self.audioDevices = transcriptionService.getAudioDevices()
        if audioDevices.contains(where: { $0.name == settings.selectedAudioInput }) == false {
            settings.selectedAudioInput = audioDevices.first?.name ?? "No Audio Input" // Default if saved one isn't found
        }
#endif
        
        setupBindings()
    }
    
    // --- Combine Bindings ---
    private func setupBindings() {
        transcriptionService.modelStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$modelState)
        
        transcriptionService.downloadProgressPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$downloadProgress)
        
        transcriptionService.availableModelsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$availableModels)
        
        transcriptionService.localModelsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$localModels)
        
        transcriptionService.audioLevelPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$audioSignal)
        
        // Handle transcription updates
        transcriptionService.transcriptionUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.handleTranscriptionUpdate(update)
            }
            .store(in: &cancellables)
        
        // React to settings changes that require model reload
        settings.$selectedModel
            .dropFirst // Ignore initial value
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Selected model changed, resetting state.")
                self?.resetState() // Ensure model state goes to unloaded
                self?.modelState = .unloaded
            }
            .store(in: &cancellables)
        
        settings.$encoderComputeUnits
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.modelState = .unloaded } // Trigger reload via UI
            .store(in: &cancellables)
        
        settings.$decoderComputeUnits
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.modelState = .unloaded } // Trigger reload via UI
            .store(in: &cancellables)
        
        // Update modelFolderExists status
        transcriptionService.modelStatePublisher
            .map { _ in self.transcriptionService.modelFolderURL != nil } // Check after state changes
            .receive(on: DispatchQueue.main)
            .assign(to: &$modelFolderExists)
        
    }
    
    // MARK: - Intents (Called by the View)
    
    func loadSelectedModel() {
        guard modelState == .unloaded else { return }
        
        let modelToLoad = settings.selectedModel
        let computeOptions = settings.getComputeOptions()
        let repo = settings.repoName
        let storagePath = settings.modelStoragePath
        
        Task {
            do {
                resetState() // Reset transcription state before loading
                try await transcriptionService.loadModel(modelToLoad, from: repo, computeOptions: computeOptions, localModelPathBase: storagePath)
                // Model state is updated via publisher binding
            } catch {
                errorMessage = "Failed to load model: \(error.localizedDescription)"
                // modelState is set to .unloaded by service on error
            }
        }
    }
    
    func deleteSelectedModel() {
        guard localModels.contains(settings.selectedModel) else { return }
        let modelToDelete = settings.selectedModel
        let storagePath = settings.modelStoragePath
        
        do {
            try transcriptionService.deleteModel(modelToDelete, localModelPathBase: storagePath)
            // State updates (localModels, modelState) handled by publishers
            if settings.selectedModel == modelToDelete {
                // If the deleted model was selected, pick another default?
                settings.selectedModel = availableModels.first(where: { localModels.contains($0) }) ?? WhisperKit.recommendedModels().default
            }
        } catch {
            errorMessage = "Failed to delete model: \(error.localizedDescription)"
        }
    }
    
    func toggleRecording(isStream: Bool) async {
        cancelOngoingTranscription() // Cancel any existing file transcription task
        
        if isRecording {
            // Stop Recording
            Task {
                transcriptionService.stopStreamingTranscription()
                // isRecording and isTranscribing state updated via handleTranscriptionUpdate
            }
        } else {
            // Start Recording / Streaming
            guard modelState == .loaded else {
                errorMessage = "Model is not loaded."
                return
            }
            resetTranscriptionState() // Clear text, segments before starting new recording
            
            let options = await transcriptionService.currentDecodingOptions(from: settings)
            var deviceId: DeviceID? = nil
#if os(macOS)
            deviceId = audioDevices.first(where: { $0.name == settings.selectedAudioInput })?.id
#endif
            
            currentTranscriptionTask = Task {
                do {
                    isRecording = true // Immediate UI feedback
                    try await transcriptionService.startStreamingTranscription(deviceId: deviceId, options: options)
                    // isTranscribing state updated via handleTranscriptionUpdate
                } catch {
                    isRecording = false
                    // isTranscribing state updated via handleTranscriptionUpdate
                    errorMessage = "Failed to start recording: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func transcribeFile(url: URL) async {
        guard modelState == .loaded else {
            errorMessage = "Model is not loaded."
            return
        }
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "Permission denied for file access."
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        cancelOngoingTranscription() // Cancel streaming if active
        resetTranscriptionState() // Reset UI
        
        let options = await transcriptionService.currentDecodingOptions(from: settings)
        
        currentTranscriptionTask = Task {
            do {
                // isTranscribing state updated via handleTranscriptionUpdate
                try await transcriptionService.transcribeFile(path: url.path, options: options)
            } catch {
                // isTranscribing state updated via handleTranscriptionUpdate
                errorMessage = "Failed to transcribe file: \(error.localizedDescription)"
            }
        }
    }
    
    func openModelFolder() {
#if os(macOS)
        guard let url = transcriptionService.modelFolderURL else { return }
        NSWorkspace.shared.open(url)
#endif
    }
    
    func openRepoURL() {
        guard let url = URL(string: "https://huggingface.co/\(settings.repoName)") else { return }
#if os(macOS)
        NSWorkspace.shared.open(url)
#else
        UIApplication.shared.open(url)
#endif
    }
    
    func copyTranscriptionToClipboard() {
        let textToCopy: String
        if settings.enableEagerDecoding && selectedTab == .stream {
            textToCopy = confirmedEagerText + hypothesisEagerText
        } else {
            // Format segments with timestamps if enabled
            textToCopy = formatSegments(confirmedSegments + unconfirmedSegments, withTimestamps: settings.enableTimestamps)
                .joined(separator: "\n")
        }
        
#if os(iOS)
        UIPasteboard.general.string = textToCopy
#elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(textToCopy, forType: .string)
#endif
    }
    
    // MARK: - State Management & Updates
    
    private func handleTranscriptionUpdate(_ update: TranscriptionUpdate) {
        // Handle Errors
        if let error = update.error {
            // Only show error once, don't clear it automatically unless needed
            if !(error is CancellationError) { // Don't show cancellation errors
                errorMessage = "Transcription Error: \(error.localizedDescription)"
            }
        }
        
        // Update Transcription State
        isTranscribing = update.isTranscribing
        
        // Update Display Text based on mode and update content
        if settings.enableEagerDecoding && selectedTab == .stream {
            confirmedEagerText = update.confirmedText
            hypothesisEagerText = update.hypothesisText
            transcriptionText = confirmedEagerText + hypothesisEagerText // Combined for easy display if needed
            // Clear segment view data
            confirmedSegments = []
            unconfirmedSegments = []
        } else {
            // Standard mode uses segments
            // Need logic to diff segments or just take the full update if simpler
            // For now, split the received segments back into confirmed/unconfirmed
            // This assumes the service sends the combined list. A better approach
            // might be for the service to send separate confirmed/unconfirmed lists.
            let allSegments = update.segments
            let lastConfirmedTime = confirmedSegments.last?.end ?? 0.0
            
            // Rebuild confirmed/unconfirmed based on the latest full list from service
            // This is simpler than complex diffing for now
            confirmedSegments = allSegments.filter { $0.end <= lastConfirmedTime && confirmedSegments.contains($0) } // Keep existing confirmed
            unconfirmedSegments = allSegments.filter { $0.end > lastConfirmedTime } // Treat rest as potentially unconfirmed
            
            transcriptionText = formatSegments(allSegments, withTimestamps: settings.enableTimestamps).joined(separator: "\n")
            
            // Clear eager view data
            confirmedEagerText = ""
            hypothesisEagerText = ""
        }
        decoderPreviewText = update.currentDecodingText // Update preview
        
        // Update Metrics
        if let newMetrics = update.metrics {
            metrics = newMetrics
        }
        
        // Update recording status based on transcription status (stops if error occurs)
        if !update.isTranscribing {
            isRecording = false // Stop recording indicator if transcription stops unexpectedly
            cancelOngoingTranscription() // Clean up task
        }
    }
    
    // Called when starting a new recording or file transcription
    func resetTranscriptionState() {
        errorMessage = nil
        transcriptionText = ""
        confirmedSegments = []
        unconfirmedSegments = []
        confirmedEagerText = ""
        hypothesisEagerText = ""
        decoderPreviewText = ""
        metrics = .init() // Reset metrics
        audioSignal = .init() // Reset audio levels
        // Don't reset isRecording here, handled by toggleRecording
    }
    
    // Called when changing model or compute units requires full reset
    private func resetState() {
        cancelOngoingTranscription()
        modelState = .unloaded // Doesn't automatically trigger reload, view must call loadSelectedModel
        downloadProgress = 0.0
        isRecording = false
        resetTranscriptionState() // Reset text, segments, metrics
    }
    
    // Helper to cancel ongoing task
    private func cancelOngoingTranscription() {
        currentTranscriptionTask?.cancel()
        currentTranscriptionTask = nil
        // Ensure service also stops if it was streaming
        transcriptionService.stopStreamingTranscription()
        // Explicitly update transcribing state if task is cancelled externally
        if isTranscribing {
            isTranscribing = false
        }
        if isRecording { // If we cancel a task, recording should also stop
            isRecording = false
        }
    }
    
    // TODO: Implement formatSegments helper function (from original code or similar)
    private func formatSegments(_ segments: [TranscriptionSegment], withTimestamps: Bool) -> [String] {
        segments.map { segment in
            let timestampPrefix = withTimestamps ? "[\(String(format: "%.2f", segment.start)) --> \(String(format: "%.2f", segment.end))] " : ""
            return timestampPrefix + segment.text
        }
    }
    
    // --- App Info ---
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
    var deviceName: String {
        WhisperKit.deviceName()
    }
    var osVersion: String {
#if os(iOS)
        UIDevice.current.systemVersion
#elseif os(macOS)
        ProcessInfo.processInfo.operatingSystemVersionString
#endif
    }
}

