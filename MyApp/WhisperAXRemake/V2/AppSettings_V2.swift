////
////  AppSettings.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//import WhisperKit // For ChunkingStrategy, MLComputeUnits
//import CoreML
//
//// Centralized place for AppStorage-backed settings
//class AppSettings: ObservableObject {
//    @AppStorage("selectedAudioInput") var selectedAudioInput: String = "No Audio Input" // macOS only
//    @AppStorage("selectedModel") var selectedModel: String = WhisperKit.recommendedModels().default
//    @AppStorage("selectedTab") var selectedTab: String = "Transcribe" // Or manage tab state differently
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
//    @AppStorage("realtimeDelayInterval") var realtimeDelayInterval: Double = 1
//    @AppStorage("tokenConfirmationsNeeded") var tokenConfirmationsNeeded: Double = 2
//
//    // Strategy & Compute
//    @AppStorage("useVAD") var useVAD: Bool = true // Consider merging into chunking strategy?
//    @AppStorage("chunkingStrategy") var chunkingStrategy: ChunkingStrategy = .vad
//    @AppStorage("encoderComputeUnits") var encoderComputeUnits: MLComputeUnits = .cpuAndNeuralEngine
//    @AppStorage("decoderComputeUnits") var decoderComputeUnits: MLComputeUnits = .cpuAndNeuralEngine
//    @AppStorage("concurrentWorkerCount") var concurrentWorkerCount: Double = 4
//
//    // Helper function
//    func getComputeOptions() -> ModelComputeOptions {
//          // Original code didn't use separate mel/prefill compute units, assuming same as encoder/decoder
//         return ModelComputeOptions(
//             melCompute: encoderComputeUnits, // Or make distinct if needed
//             audioEncoderCompute: encoderComputeUnits,
//             textDecoderCompute: decoderComputeUnits,
//             prefillCompute: decoderComputeUnits // Or make distinct if needed
//         )
//     }
//}
