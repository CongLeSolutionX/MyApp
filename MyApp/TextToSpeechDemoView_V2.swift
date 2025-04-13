////
////  TextToSpeechDemoView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import SwiftUI
//import AVFoundation // Needed for audio playback simulation
//
//// --- Data Models ---
//
//struct VoiceInfo: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let languageCode: String
//    // Add other parameters if needed (e.g., gender, type) from the JSON structure
//}
//
//struct DeviceInfo: Identifiable, Hashable {
//    let id: Int // Using Int to match typical audio device indices
//    let name: String
//}
//
//// Mock data based on the `talk.py --list-voices` output structure
//let mockLanguageVoices: [String: [String]] = [
//    "en-US": [
//        "English-US.Female-1", // Simplified naming for clarity
//        "English-US.Male-1",
//        "English-US.Female-2",
//        "Magpie-Multilingual.EN-US.Female.Female-1" // Example from command
//    ],
//    "es-ES": [
//        "Spanish-ES.Female-1",
//        "Spanish-ES.Male-1"
//    ],
//    "fr-FR": [
//        "French-FR.Female-1",
//        "French-FR.Male-1"
//    ]
//    // Add more languages and voices as needed
//]
//
//// Flatten the mock data into VoiceInfo objects
//let mockAvailableVoices: [VoiceInfo] = mockLanguageVoices.flatMap { langCode, voiceNames in
//    voiceNames.map { voiceName in
//        VoiceInfo(name: voiceName, languageCode: langCode)
//    }
//}.sorted { $0.languageCode < $1.languageCode || ($0.languageCode == $1.languageCode && $0.name < $1.name) }
//
//let mockAvailableLanguages: [String] = Array(mockLanguageVoices.keys).sorted()
//
//let mockOutputDevices: [DeviceInfo] = [
//    DeviceInfo(id: 0, name: "Default Output Device"),
//    DeviceInfo(id: 1, name: "Built-in Speakers"),
//    DeviceInfo(id: 2, name: "External Headphones"),
//    // Add more mock devices
//]
//
//// Represents the main state and logic of the TTS interaction
//@MainActor // Ensure UI updates happen on the main thread
//class TTSViewModel: ObservableObject {
//
//    // --- User Input & Configuration State ---
//    @Published var textToSynthesize: String = "This audio is generated from NVIDIA's text-to-speech model using a SwiftUI client."
//    @Published var selectedVoice: VoiceInfo? = mockAvailableVoices.first { $0.languageCode == "en-US"} // Default to first en-US voice
//    @Published var selectedLanguageCode: String = "en-US" {
//        didSet {
//            // Reset voice selection if the language changes and the current voice doesn't match
//            if selectedVoice?.languageCode != selectedLanguageCode {
//                selectedVoice = availableVoices.first { $0.languageCode == selectedLanguageCode }
//            }
//        }
//    }
//    @Published var quality: Int = 20
//    @Published var sampleRate: Int = 44100
//    @Published var encoding: String = "LINEAR_PCM" // Or "OGGOPUS"
//    @Published var outputFileName: String = "output.wav"
//    @Published var useStreaming: Bool = false
//    @Published var playAudio: Bool = true // Corresponds to --play-audio
//    @Published var saveToFile: Bool = true // Implicitly true if playAudio is false or if user wants both
//
//    // Simulating selecting an audio prompt file
//    @Published var audioPromptFileName: String? = nil // Display name of selected file
//
//    // Simulating selecting a custom dictionary file
//    @Published var customDictionaryFileName: String? = nil // Display name
//
//    // --- Connection State ---
//    @Published var serverAddress: String = "grpc.nvcf.nvidia.com:443"
//    @Published var useSSL: Bool = true
//    @Published var functionID: String = "877104f7-e885-42b9-8de8-f6e4c6303969" // Example from command
//    @Published var apiKey: String = "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" // Placeholder - Should be securely managed
//
//    // --- Data Sources ---
//    @Published var availableVoices: [VoiceInfo] = mockAvailableVoices // Use mock data
//    @Published var availableLanguages: [String] = mockAvailableLanguages
//    @Published var availableDevices: [DeviceInfo] = mockOutputDevices
//    @Published var selectedOutputDevice: DeviceInfo = mockOutputDevices.first! // Default device
//
//    // --- UI State ---
//    @Published var isSynthesizing: Bool = false
//    @Published var statusMessage: String = "Ready"
//    @Published var showingVoiceList: Bool = false
//    @Published var showingDeviceList: Bool = false
//    @Published var synthesisProgress: Double = 0.0 // For streaming simulation
//    @Published var timeToFirstAudio: Double? = nil // For streaming timing
//    @Published var totalSynthesisTime: Double? = nil // For batch timing
//
//    // --- Private State for Simulation ---
//    private var audioPlayer: AVAudioPlayer? // For playback simulation
//
//    // --- Filtered voices based on selected language ---
//    var filteredVoices: [VoiceInfo] {
//        availableVoices.filter { $0.languageCode == selectedLanguageCode }
//    }
//
//    // --- Actions ---
//
//    // Corresponds to --list-voices
//    func listVoices() {
//        // In a real app, this would fetch from the service
//        // Here, we just use the mock data and trigger the sheet
//        statusMessage = "Displaying available voices."
//        showingVoiceList = true
//    }
//
//    // Corresponds to --list-devices
//    func listDevices() {
//        // In a real app, this might use CoreAudio or other system APIs
//        // Here, we just use mock data and trigger the sheet
//        statusMessage = "Displaying available output devices."
//        showingDeviceList = true
//    }
//
//    func selectAudioPromptFile() {
//        // TODO: Implement actual file picker logic (e.g., using UIDocumentPickerViewController via UIViewControllerRepresentable or .fileImporter)
//        audioPromptFileName = "prompt_example.wav" // Simulate selection
//        statusMessage = "Selected audio prompt: \(audioPromptFileName!)"
//    }
//
//    func selectCustomDictionaryFile() {
//        // TODO: Implement actual file picker logic
//        customDictionaryFileName = "custom_dict.txt" // Simulate selection
//        statusMessage = "Selected custom dictionary: \(customDictionaryFileName!)"
//    }
//
//    // Corresponds to executing the main synthesis command
//    func synthesize() {
//        guard !textToSynthesize.isEmpty else {
//            statusMessage = "Error: Input text cannot be empty."
//            return
//        }
//        guard selectedVoice != nil else {
//            statusMessage = "Error: Please select a voice."
//            return
//        }
//        guard !serverAddress.isEmpty else {
//            statusMessage = "Error: Server address cannot be empty."
//            return
//        }
//        // Basic check, real validation would be more robust
//        guard functionID.count > 10 else {
//             statusMessage = "Error: Function ID seems invalid."
//            return
//        }
//         // In a real app, check API key validity if required externally
//        // guard !apiKey.isEmpty else {
//        //     statusMessage = "Error: API Key is required."
//        //     return
//        // }
//
//        isSynthesizing = true
//        statusMessage = useStreaming ? "Synthesizing (Streaming)..." : "Synthesizing (Batch)..."
//        synthesisProgress = 0.0
//        timeToFirstAudio = nil
//        totalSynthesisTime = nil
//
//        // --- Simulate Network Request & Processing ---
//        let startTime = Date()
//
//        Task { // Use Task for async simulation
//            do {
//                if useStreaming {
//                    // Simulate receiving chunks
//                    let chunkCount = 5
//                    for i in 1...chunkCount {
//                        try await Task.sleep(nanoseconds: UInt64.random(in: 200...600) * 1_000_000) // Simulate network latency & processing time per chunk
//
//                        // Simulate receiving audio data chunk
//                        let fakeAudioChunk = Data(repeating: UInt8.random(in: 0...255), count: 8192) // Fake data
//
//                        if i == 1 {
//                            timeToFirstAudio = Date().timeIntervalSince(startTime)
//                            await MainActor.run { // Ensure UI updates on main thread
//                                statusMessage = String(format: "Streaming: First audio received in %.3fs", timeToFirstAudio!)
//                            }
//                        }
//
//                        let progress = Double(i) / Double(chunkCount)
//                        await MainActor.run {
//                             self.synthesisProgress = progress
//                        }
//
//                        // Simulate processing the chunk (playing or saving)
//                        if playAudio {
//                            print("Simulating playback of chunk \(i)")
//                            // In a real app, append to a streaming buffer for AVAudioEngine or similar
//                        }
//                        if saveToFile {
//                           print("Simulating saving chunk \(i) to \(outputFileName)")
//                           // In a real app, append to wave file handle
//                        }
//                    }
//                      totalSynthesisTime = Date().timeIntervalSince(startTime)
//
//                    await MainActor.run {
//                         statusMessage = String(format: "Streaming finished in %.3fs.", totalSynthesisTime!)
//                           self.synthesisProgress = 1.0
//                    }
//
//                } else {
//                    // Simulate Batch Synthesis
//                    try await Task.sleep(nanoseconds: UInt64.random(in: 800...2500) * 1_000_000) // Simulate longer batch processing time
//
//                    totalSynthesisTime = Date().timeIntervalSince(startTime)
//
//                    // Simulate receiving the full audio data
//                    let fakeFullAudio = Data(repeating: UInt8.random(in: 0...255), count: 65536) // Larger fake data
//
//                     await MainActor.run {
//                          statusMessage = String(format: "Batch synthesis finished in %.3fs.", totalSynthesisTime!)
//                           self.synthesisProgress = 1.0 // Indicate completion
//                     }
//
//                    if playAudio {
//                        simulatePlayback(audioData: fakeFullAudio)
//                    }
//                    if saveToFile {
//                         simulateSaveToFile(audioData: fakeFullAudio)
//                    }
//                }
//
//            } catch {
//                await MainActor.run {
//                      statusMessage = "Error during synthesis simulation: \(error.localizedDescription)"
//                }
//            }
//
//            // --- Final State Update ---
//            await MainActor.run {
//                 isSynthesizing = false
//                 // Keep the final status message unless an error occurred
//            }
//        }
//    }
//
//    // --- Simulation Helpers (Replace with actual implementations) ---
//
//    private func simulatePlayback(audioData: Data) {
//        statusMessage = "Simulating audio playback..."
//        print("Attempting to simulate playback of \(audioData.count) bytes.")
//        // In a real app, use AVAudioPlayer or AVAudioEngine
//        // This is a very basic simulation using AVAudioPlayer with fake data
//        do {
//           // Note: Playing raw PCM data directly like this usually requires
//           // a proper header or using AVAudioEngine with buffer formats.
//           // This will likely fail or produce noise if run directly.
//           // For UI demonstration purposes, just print.
//           // audioPlayer = try AVAudioPlayer(data: audioData) // This would need format info
//           // audioPlayer?.play()
//            statusMessage = "Playback simulated (check console)."
//        } catch {
//            statusMessage = "Error: Playback simulation failed: \(error.localizedDescription)"
//            print("Playback simulation error: \(error)")
//        }
//    }
//
//    private func simulateSaveToFile(audioData: Data) {
//        statusMessage = "Simulating save to \(outputFileName)..."
//        print("Simulating saving \(audioData.count) bytes to \(outputFileName)")
//        // In a real app, use Wave file writing logic or save raw data
//        // For demonstration, we just update the status
//        statusMessage = "Simulated saving to \(outputFileName)."
//    }
//}
//
//// --- SwiftUI Views ---
//
//struct TextToSpeechDemoView: View {
//    @StateObject private var viewModel = TTSViewModel()
//
//    var body: some View {
//        NavigationView {
//            Form {
//                // --- Input Text ---
//                Section("Input Text") {
//                    TextEditor(text: $viewModel.textToSynthesize)
//                        .frame(height: 150)
//                        .border(Color.gray.opacity(0.5)) // Make it visible
//                }
//
//                // --- Core Synthesis Configuration ---
//                Section("Synthesis Configuration") {
//                    // Language Selection
//                    Picker("Language", selection: $viewModel.selectedLanguageCode) {
//                        ForEach(viewModel.availableLanguages, id: \.self) { langCode in
//                            Text(Locale.current.localizedString(forLanguageCode: langCode) ?? langCode).tag(langCode)
//                        }
//                    }
//
//                    // Voice Selection (filtered by language)
//                    Picker("Voice", selection: $viewModel.selectedVoice) {
//                        ForEach(viewModel.filteredVoices, id: \.self) { voice in
//                            Text(voice.name).tag(voice as VoiceInfo?) // Tag as optional
//                        }
//                    }
//                    .disabled(viewModel.filteredVoices.isEmpty) // Disable if no voices for language
//
//                    // Quality Slider (Example)
//                    HStack {
//                         Text("Quality")
//                         Slider(value: Binding(
//                            get: { Double(viewModel.quality) },
//                            set: { viewModel.quality = Int($0) }
//                         ), in: 1...100, step: 1) // Adjust range as needed
//                        Text("\(viewModel.quality)")
//                             .frame(width: 40, alignment: .trailing)
//                    }
//
//                    // Sample Rate Picker (Example)
//                    Picker("Sample Rate (Hz)", selection: $viewModel.sampleRate) {
//                        Text("22050").tag(22050)
//                        Text("44100").tag(44100)
//                        Text("48000").tag(48000)
//                    }
//                    .pickerStyle(.segmented) // Example style
//
//                     // Encoding Picker (Example)
//                    Picker("Encoding", selection: $viewModel.encoding) {
//                        Text("PCM").tag("LINEAR_PCM")
//                        Text("Opus").tag("OGGOPUS")
//                    }
//                    .pickerStyle(.segmented)
//
//                }
//
//                // --- Advanced Options / Files ---
//                Section("Advanced Options") {
//                    HStack {
//                        Text("Audio Prompt:")
//                        Spacer()
//                        Button(viewModel.audioPromptFileName ?? "Select File...") {
//                            viewModel.selectAudioPromptFile()
//                        }
//                    }
//
//                    HStack {
//                        Text("Custom Dictionary:")
//                        Spacer()
//                        Button(viewModel.customDictionaryFileName ?? "Select File...") {
//                             viewModel.selectCustomDictionaryFile()
//                         }
//                     }
//                }
//
//                // --- Output Options ---
//                Section("Output") {
//                    TextField("Output Filename", text: $viewModel.outputFileName)
//                     .autocorrectionDisabled()
//                     #if os(iOS)
//                     .textInputAutocapitalization(.never)
//                     #endif
//
//                    Toggle("Stream Synthesis", isOn: $viewModel.useStreaming)
//                     .tint(.orange) // Example color
//
//                    Toggle("Play Audio", isOn: $viewModel.playAudio)
//                    Toggle("Save to File", isOn: $viewModel.saveToFile)
//
//                    // Output Device Selection
//                     Picker("Output Device", selection: $viewModel.selectedOutputDevice) {
//                         ForEach(viewModel.availableDevices, id: \.self) { device in
//                            Text("\(device.name) (ID: \(device.id))").tag(device)
//                         }
//                     }
//                      // Button to trigger listing (optional if Picker is sufficient)
//                     Button("List Devices...") { viewModel.listDevices() }
//
//                }
//
//                // --- Connection Settings (Optional Section) ---
//                 Section("Connection") {
//                     TextField("Server Address", text: $viewModel.serverAddress)
//                      .autocorrectionDisabled()
//                      #if os(iOS)
//                      .textInputAutocapitalization(.never)
//                      #endif
//                     Toggle("Use SSL", isOn: $viewModel.useSSL)
//                      TextField("Function ID", text: $viewModel.functionID)
//                       .autocorrectionDisabled()
//                       #if os(iOS)
//                       .textInputAutocapitalization(.never)
//                       #endif
//                      SecureField("API Key (Optional)", text: $viewModel.apiKey) // Use SecureField
//                 }
//
//                // --- Action Button & Status ---
//                Section {
//                    Button(action: viewModel.synthesize) {
//                        HStack {
//                            Spacer()
//                            if viewModel.isSynthesizing {
//                                ProgressView()
//                                Text("Synthesizing...")
//                            } else {
//                                Image(systemName: "speaker.wave.2.fill")
//                                Text("Synthesize")
//                            }
//                            Spacer()
//                        }
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .disabled(viewModel.isSynthesizing || viewModel.textToSynthesize.isEmpty || viewModel.selectedVoice == nil)
//
//                    // Status Display
//                    VStack(alignment: .leading) {
//                        Text("Status: \(viewModel.statusMessage)")
//                            .font(.footnote)
//                            .foregroundColor(.secondary)
//
//                       if viewModel.isSynthesizing && viewModel.useStreaming {
//                           ProgressView(value: viewModel.synthesisProgress)
//                               .progressViewStyle(.linear)
//                        }
//
//                       if let tta = viewModel.timeToFirstAudio {
//                            Text(String(format: "Time to First Audio: %.3f s", tta))
//                               .font(.caption)
//                               .foregroundColor(.blue)
//                        }
//                       if let tst = viewModel.totalSynthesisTime {
//                           Text(String(format: "Total Time: %.3f s", tst))
//                               .font(.caption)
//                               .foregroundColor(.green)
//                       }
//                    }
//                    .padding(.top, 5)
//                }
//            }
//            .navigationTitle("Riva TTS Client")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("List Voices") {
//                        viewModel.listVoices()
//                    }
//                    .disabled(viewModel.isSynthesizing)
//                }
//            }
//            // Sheets for displaying lists
//            .sheet(isPresented: $viewModel.showingVoiceList) {
//                VoiceListView(voices: viewModel.availableVoices)
//            }
//            .sheet(isPresented: $viewModel.showingDeviceList) {
//                DeviceListView(devices: viewModel.availableDevices)
//            }
//        }
//        #if os(macOS)
//        .frame(minWidth: 500, minHeight: 600) // Set a reasonable minimum size for macOS
//         #endif
//
//    }
//}
//
//// --- Helper Views for Lists ---
//
//struct VoiceListView: View {
//    let voices: [VoiceInfo]
//    @Environment(\.dismiss) var dismiss
//
//    var groupedVoices: [String: [VoiceInfo]] {
//        Dictionary(grouping: voices, by: { $0.languageCode })
//    }
//
//    var sortedLanguageCodes: [String] {
//        groupedVoices.keys.sorted()
//    }
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(sortedLanguageCodes, id: \.self) { langCode in
//                    Section(header: Text(Locale.current.localizedString(forLanguageCode: langCode) ?? langCode)) {
//                        ForEach(groupedVoices[langCode]!, id: \.self) { voice in
//                            Text(voice.name)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Available Voices")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") { dismiss() }
//                }
//            }
//        }
//    }
//}
//
//struct DeviceListView: View {
//    let devices: [DeviceInfo]
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        NavigationView {
//            List(devices) { device in
//                Text("\(device.name) (ID: \(device.id))")
//            }
//            .navigationTitle("Available Output Devices")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") { dismiss() }
//                }
//            }
//        }
//    }
//}
//
//#Preview("DeviceListView") {
//    DeviceListView(devices: [DeviceInfo(id: 2, name: "Demo Device")])
//}
//
////// --- App Entry Point ---
////
//// struct RivaTTSApp: App {
////     var body: some Scene {
////         WindowGroup {
////             TextToSpeechDemoView()
////         }
////     }
//// }
