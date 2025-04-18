////
////  SettingsView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//// SettingsView.swift
//import SwiftUI
//import WhisperKit // For Enums
//
//struct SettingsView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//    @Environment(\.dismiss) var dismiss // To close the sheet
//
//    var body: some View {
//        NavigationView { // For title and close button on iOS
//            Form { // Using Form for standard settings layout
//                Section("General") {
//                    Toggle("Show Timestamps", isOn: $settings.enableTimestamps)
//                    Toggle("Special Characters", isOn: $settings.enableSpecialCharacters)
//                    Toggle("Show Decoder Preview", isOn: $settings.enableDecoderPreview)
//                }
//
//                Section("Prefill Options") {
//                    Toggle("Prompt Prefill", isOn: $settings.enablePromptPrefill)
//                    Toggle("Cache Prefill", isOn: $settings.enableCachePrefill)
//                }
//                
//                Section("Strategy & Performance") {
//                    Picker("Chunking Strategy", selection: $settings.chunkingStrategy) {
//                        Text("None").tag(ChunkingStrategy.none)
//                        Text("VAD").tag(ChunkingStrategy.vad)
//                    }
//                    .pickerStyle(.segmented) // Example style
//
//                    Stepper("Concurrent Workers: \(Int(settings.concurrentWorkerCount))", value: $settings.concurrentWorkerCount, in: 0...32, step: 1)
//                      Text("(0 uses max available)").font(.caption).foregroundColor(.secondary)
//                }
//
//                Section("Decoding Parameters") {
//                     // Add sliders and steppers for other settings like temperature, fallbacks etc.
//                     // Example:
//                     HStack {
//                         Text("Temperature")
//                         Slider(value: $settings.temperatureStart, in: 0...1, step: 0.1)
//                         Text(String(format: "%.1f", settings.temperatureStart))
//                     }
//                     // ... Add others similarly ...
//                 }
//                 
//                Section("Streaming") {
//                     Toggle("Use VAD (Voice Activity Detection)", isOn: $settings.useVAD) // Link to VAD setting
//                     HStack {
//                         Text("Silence Threshold")
//                         Slider(value: $settings.silenceThreshold, in: 0...1, step: 0.05)
//                         Text(String(format: "%.2f", settings.silenceThreshold))
//                     }
//                     HStack {
//                         Text("Realtime Delay (s)")
//                         Slider(value: $settings.realtimeDelayInterval, in: 0...5, step: 0.5)
//                         Text(String(format: "%.1f", settings.realtimeDelayInterval))
//                     }
//                 }
//                 
//                 Section("Experimental") {
//                    Toggle("Eager Streaming Mode", isOn: $settings.enableEagerDecoding)
//                     if settings.enableEagerDecoding {
//                         HStack {
//                             Text("Token Confirmations")
//                             Slider(value: $settings.tokenConfirmationsNeeded, in: 1...10, step: 1)
//                             Text("\(Int(settings.tokenConfirmationsNeeded))")
//                         }
//                     }
//                 }
//
//            }
//            .navigationTitle("Advanced Settings")
//            #if os(iOS)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") { dismiss() }
//                }
//            }
//            #else // macOS needs explicit close button if in sheet
//             .toolbar {
//                 ToolbarItem(placement: .confirmationAction) {
//                     Button("Done") { dismiss() }
//                 }
//               }
//             .frame(minWidth: 400, minHeight: 400) // Set size for macOS sheet
//            #endif
//        }
//    }
//}
//
//// Add InfoButton view struct from original code if needed
