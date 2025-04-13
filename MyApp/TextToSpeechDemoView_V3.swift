//
//  TextToSpeechDemoView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import AVFoundation // Still needed for audio simulation context
import UniformTypeIdentifiers // Needed for .fileImporter

// --- Data Models (Unchanged) ---

struct VoiceInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let languageCode: String
    // Add other parameters if needed
}

struct DeviceInfo: Identifiable, Hashable {
    let id: Int
    let name: String
}

// --- Mock Data (Unchanged) ---
let mockLanguageVoices: [String: [String]] = [
    "en-US": [
        "English-US.Female-1",
        "English-US.Male-1",
        "English-US.Female-2",
        "Magpie-Multilingual.EN-US.Female.Female-1"
    ],
    "en-GB": [
        "English-GB.Female-1",
        "English-GB.Male-1"
    ],
    "es-ES": [
        "Spanish-ES.Female-1",
        "Spanish-ES.Male-1"
    ],
    "fr-FR": [
        "French-FR.Female-1",
        "French-FR.Male-1"
    ]
]

let mockAvailableVoices: [VoiceInfo] = mockLanguageVoices.flatMap { langCode, voiceNames in
    voiceNames.map { voiceName in
        VoiceInfo(name: voiceName, languageCode: langCode)
    }
}.sorted { $0.languageCode < $1.languageCode || ($0.languageCode == $1.languageCode && $0.name < $1.name) }

let mockAvailableLanguages: [String] = Array(mockLanguageVoices.keys).sorted()

let mockOutputDevices: [DeviceInfo] = [
    DeviceInfo(id: 0, name: "Default System Output"),
    DeviceInfo(id: 1, name: "MacBook Pro Speakers"),
    DeviceInfo(id: 2, name: "AirPods Pro"),
    DeviceInfo(id: 3, name: "External Monitor Audio"),
]

// --- View Model ---
@MainActor // Ensure all UI updates published from here are on the main thread
class TTSViewModel: ObservableObject {

    // --- User Input & Configuration State ---
    @Published var textToSynthesize: String = "This audio is generated from NVIDIA's text-to-speech model using a SwiftUI client."
    @Published var selectedVoice: VoiceInfo? // Initialize as nil, let user pick or default later
    @Published var selectedLanguageCode: String = "en-US" {
        didSet {
            // Automatically select the first available voice for the new language
            if oldValue != selectedLanguageCode {
                 selectedVoice = availableVoices.first { $0.languageCode == selectedLanguageCode }
                 statusMessage = "Switched language. Selected default voice for \(selectedLanguageCode)."
            }
        }
    }
    @Published var quality: Int = 40 // Example default
    @Published var sampleRate: Int = 44100 // Default standard rate
    @Published var encoding: String = "LINEAR_PCM" // Default PCM
    @Published var outputFileName: String = "output.wav" {
        didSet {
            // Basic validation: ensure filename ends appropriately based on encoding
            if encoding == "LINEAR_PCM" && !outputFileName.lowercased().hasSuffix(".wav") {
                // Suggest .wav if PCM is selected
                // statusMessage = "Suggestion: Use .wav extension for PCM encoding."
                // Or auto-correct: outputFileName += ".wav"
            } else if encoding == "OGGOPUS" && !outputFileName.lowercased().hasSuffix(".ogg") {
                 // Suggest .ogg if Opus is selected
                 // statusMessage = "Suggestion: Use .ogg extension for Opus encoding."
                 // Or auto-correct: outputFileName += ".ogg"
            }
        }
    }
    @Published var useStreaming: Bool = false
    @Published var playAudio: Bool = true
    @Published var saveToFile: Bool = false // Default to not saving unless requested

    @Published var audioPromptFileURL: URL? = nil // Store the URL from file picker
    var audioPromptFileName: String? { audioPromptFileURL?.lastPathComponent } // Display name

    @Published var customDictionaryFileURL: URL? = nil // Store the URL
    var customDictionaryFileName: String? { customDictionaryFileURL?.lastPathComponent }  // Display name

    // --- Connection State ---
    @Published var serverAddress: String = "grpc.nvcf.nvidia.com:443" // Default Riva endpoint
    @Published var useSSL: Bool = true
    @Published var functionID: String = "YOUR_FUNCTION_ID_HERE" // Placeholder - User must fill
    @Published var apiKey: String = "" // Placeholder - Should be securely managed if needed

    // --- Data Sources ---
    @Published var availableVoices: [VoiceInfo] = mockAvailableVoices
    @Published var availableLanguages: [String] = mockAvailableLanguages
    @Published var availableDevices: [DeviceInfo] = mockOutputDevices
    @Published var selectedOutputDevice: DeviceInfo = mockOutputDevices.first! // Sensible default

    // --- UI State ---
    @Published var isSynthesizing: Bool = false
    @Published var statusMessage: String = "Ready. Please configure and Synthesize."
    @Published var showingVoiceList: Bool = false
    @Published var showingDeviceList: Bool = false
    @Published var synthesisProgress: Double = 0.0
    @Published var timeToFirstAudio: Double? = nil
    @Published var totalSynthesisTime: Double? = nil

    // --- Private State for Simulation ---
    private var audioPlayer: AVAudioPlayer? // Keep for playback simulation context

    // --- Computed Properties ---
    var filteredVoices: [VoiceInfo] {
        availableVoices.filter { $0.languageCode == selectedLanguageCode }
    }

    // --- Initializer ---
     init() {
         // Set a default voice on initialization
         selectedVoice = availableVoices.first { $0.languageCode == selectedLanguageCode }
         if selectedVoice == nil { // Fallback if default language has no voices
             selectedLanguageCode = availableLanguages.first ?? ""
             selectedVoice = availableVoices.first { $0.languageCode == selectedLanguageCode }
         }
          statusMessage = "Ready. Default voice selected for \(selectedLanguageCode)."
     }

    // --- Actions ---

    func listVoices() {
        // Simulate fetching/updating voice list if needed (not necessary with mock data)
        // In a real app: Perform API call to get voices
        statusMessage = "Displaying available voices..."
        showingVoiceList = true
    }

    func listDevices() {
        // Simulate fetching/updating device list (could use CoreAudio in a real app)
        statusMessage = "Displaying available output devices..."
        showingDeviceList = true
    }

    // Called from the .fileImporter completion handler
    func handleSelectedAudioPrompt(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            // IMPORTANT: Access security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                statusMessage = "Error: Failed to access audio prompt file."
                print("Failed to start accessing security-scoped resource: \(url)")
                return
            }
            // Store the URL - remember to stop accessing it later if needed
            // For TTS, you might read it immediately, or keep the URL
             audioPromptFileURL = url
            statusMessage = "Selected audio prompt: \(url.lastPathComponent)"
            // url.stopAccessingSecurityScopedResource() // If read immediately
        case .failure(let error):
            statusMessage = "Error selecting audio prompt: \(error.localizedDescription)"
            print("File import error: \(error)")
        }
    }

    func handleSelectedDictionary(result: Result<URL, Error>) {
         switch result {
         case .success(let url):
              guard url.startAccessingSecurityScopedResource() else {
                  statusMessage = "Error: Failed to access dictionary file."
                 print("Failed to start accessing security-scoped resource: \(url)")
                  return
              }
             customDictionaryFileURL = url
             statusMessage = "Selected custom dictionary: \(url.lastPathComponent)"
             // url.stopAccessingSecurityScopedResource() // If read immediately
         case .failure(let error):
             statusMessage = "Error selecting dictionary file: \(error.localizedDescription)"
             print("File import error: \(error)")
         }
     }

    func synthesize() {
        // --- Input Validation ---
        guard !textToSynthesize.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            statusMessage = "Error: Input text cannot be empty."
            return
        }
        guard let voice = selectedVoice else {
            statusMessage = "Error: Please select a voice."
            return
        }
        guard !serverAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            statusMessage = "Error: Server address cannot be empty."
            return
        }
        if functionID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || functionID == "YOUR_FUNCTION_ID_HERE" {
            statusMessage = "Error: Function ID is required."
            return
        }
        // API Key validation depends on the service requirements
        // guard !apiKey.isEmpty else {
        //     statusMessage = "Error: API Key is required."
        //     return
        // }
        if saveToFile && outputFileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              statusMessage = "Error: Output filename cannot be empty when 'Save to File' is enabled."
            return
        }

        // --- Reset State & Start ---
        isSynthesizing = true
        statusMessage = useStreaming ? "Synthesizing (Streaming)..." : "Synthesizing (Batch)..."
        synthesisProgress = 0.0
        timeToFirstAudio = nil
        totalSynthesisTime = nil
        let startTime = Date()

        // --- Simulate Network Request & Processing ---
        Task { // Use Task for async simulation
            do {
                 // Construct the simulated command arguments for clarity
                var commandArgs: [String] = [
                      "--server", serverAddress,
                       "--func-id", functionID,
                       "--language-code", selectedLanguageCode,
                       "--voice", voice.name,
                       "--sample-rate", String(sampleRate),
                       "--quality", String(quality),
                       "--encoding", encoding
                   ]
                  if useSSL { commandArgs.append("--ssl") }
                   if useStreaming { commandArgs.append("--streaming") }
                 if playAudio { commandArgs.append("--play-audio") }
                 if saveToFile { commandArgs += ["--output", outputFileName] }
                  if let promptURL = audioPromptFileURL { commandArgs += ["--audio-prompt", promptURL.path] } // Use path for simulation display
                   if let dictURL = customDictionaryFileURL { commandArgs += ["--custom-dictionary", dictURL.path] }
                    if !apiKey.isEmpty { commandArgs += ["--api-key", "********"] } // Mask API key
                  commandArgs.append("\"\(textToSynthesize.prefix(30))...\"") // Add truncated text

                 print("--- Simulating TTS Request ---")
                 print("Command: talk.py \(commandArgs.joined(separator: " "))")
                 print("-----------------------------")

                if useStreaming {
                    // Simulate Streaming
                    statusMessage = "Connecting (Streaming)..."
                    try await Task.sleep(nanoseconds: UInt64.random(in: 50...200) * 1_000_000) // Initial connection delay

                    let chunkCount = 10 // More chunks for better progress simulation
                    for i in 1...chunkCount {
                        try await Task.sleep(nanoseconds: UInt64.random(in: 50...150) * 1_000_000) // Simulate network latency & processing time per chunk

                        // Simulate receiving audio data chunk
                        let fakeAudioChunk = Data(repeating: UInt8.random(in: 0...255), count: 4096)

                        if i == 1 { // First chunk received
                            let tta = Date().timeIntervalSince(startTime)
                             await MainActor.run {
                                timeToFirstAudio = tta
                                statusMessage = String(format: "Streaming: First audio (%.3fs). Playing: %d, Saving: %d", tta, playAudio ? 1:0, saveToFile ? 1:0)
                            }
                        }

                        // Update progress
                        let progress = Double(i) / Double(chunkCount)
                         await MainActor.run { self.synthesisProgress = progress }

                        // Simulate processing the chunk
                        if playAudio {
                            // print("Simulating playback of streaming chunk \(i)") // Console log can be noisy
                        }
                        if saveToFile {
                            // print("Simulating saving streaming chunk \(i) to \(outputFileName)")
                        }
                    }
                     let tst = Date().timeIntervalSince(startTime)
                    await MainActor.run { // Final streaming update
                        totalSynthesisTime = tst
                         statusMessage = String(format: "Streaming finished in %.3fs. Played: %d, Saved: %d", tst, playAudio ? 1:0, saveToFile ? 1:0)
                           self.synthesisProgress = 1.0
                    }

                } else {
                    // Simulate Batch Synthesis
                    statusMessage = "Processing (Batch)..."
                    try await Task.sleep(nanoseconds: UInt64.random(in: 500...1800) * 1_000_000) // Simulate longer batch processing time

                    let tst = Date().timeIntervalSince(startTime)

                    // Simulate receiving the full audio data
                    let fakeFullAudio = Data(repeating: UInt8.random(in: 0...255), count: Int.random(in: 50000...200000)) // Variable size

                    // Simulate processing
                    var actionsTaken: [String] = []
                    if playAudio {
                        simulatePlayback(audioData: fakeFullAudio) // Updates status internally
                        actionsTaken.append("Played")
                    }
                    if saveToFile {
                         simulateSaveToFile(audioData: fakeFullAudio) // Updates status internally
                         actionsTaken.append("Saved")
                    }

                     await MainActor.run { // Final batch update
                          totalSynthesisTime = tst
                           self.synthesisProgress = 1.0 // Indicate completion
                          if actionsTaken.isEmpty {
                              statusMessage = String(format: "Batch synthesis finished in %.3fs. No output action selected.", tst)
                          } else {
                               statusMessage = String(format: "Batch synthesis finished in %.3fs. Actions: [%@]", tst, actionsTaken.joined(separator: ", "))
                           }
                     }
                }

            } catch {
                // Simulate an error condition
                 await MainActor.run {
                      statusMessage = "Simulation Error: \(error.localizedDescription)"
                }
            }

            // --- Cleanup ---
            // Ensure security scoped resources are released if they were kept open
            // We stored the URL, so maybe we don't need to stop yet, but good practice:
             if let url = audioPromptFileURL, url.isFileURL { url.stopAccessingSecurityScopedResource() }
             if let url = customDictionaryFileURL, url.isFileURL { url.stopAccessingSecurityScopedResource() }

            await MainActor.run {
                 isSynthesizing = false
                 // Keep the final status message unless an error occurred
            }
        }
    }

    // --- Simulation Helpers (Update status directly) ---

    private func simulatePlayback(audioData: Data) {
         // Don't change the main status, just log
        print("Simulating audio playback of \(audioData.count) bytes using device: \(selectedOutputDevice.name)")
        // statusMessage = "Simulating audio playback..." // Avoid overriding final batch message
    }

    private func simulateSaveToFile(audioData: Data) {
          // Don't change the main status, just log
        print("Simulating saving \(audioData.count) bytes to \(outputFileName) (Encoding: \(encoding))")
        // statusMessage = "Simulating save to \(outputFileName)..." // Avoid overriding final batch message
    }
}

// --- SwiftUI Views ---

struct TextToSpeechDemoView: View {
    @StateObject private var viewModel = TTSViewModel()

    // State for file importers
    @State private var showingAudioPromptImporter: Bool = false
    @State private var showingDictionaryImporter: Bool = false

    var body: some View {
        NavigationView {
            Form {
                // --- Input Text ---
                Section("Input Text") {
                    TextEditor(text: $viewModel.textToSynthesize)
                        .frame(height: 150)
                        .border(Color.gray.opacity(0.3))
                        .font(.body)
                }

                // --- Core Synthesis Configuration ---
                Section("Synthesis Configuration") {
                    Picker("Language", selection: $viewModel.selectedLanguageCode) {
                        ForEach(viewModel.availableLanguages, id: \.self) { langCode in
                            Text(Locale.current.localizedString(forLanguageCode: langCode) ?? langCode).tag(langCode)
                        }
                    }

                    Picker("Voice", selection: $viewModel.selectedVoice) {
                         Text("Select a Voice").tag(nil as VoiceInfo?) // Placeholder
                        ForEach(viewModel.filteredVoices, id: \.self) { voice in
                            Text(voice.name).tag(voice as VoiceInfo?)
                        }
                    }
                    .disabled(viewModel.filteredVoices.isEmpty)

                    HStack {
                         Text("Quality")
                         Slider(value: Binding(
                            get: { Double(viewModel.quality) },
                            set: { viewModel.quality = Int($0) }
                         ), in: 1...100, step: 1)
                        Text("\(viewModel.quality)")
                             .frame(width: 40, alignment: .trailing)
                             .monospacedDigit()
                    }

                    Picker("Sample Rate (Hz)", selection: $viewModel.sampleRate) {
                        Text("22050").tag(22050)
                        Text("44100").tag(44100)
                        Text("48000").tag(48000)
                    }
                    .pickerStyle(.segmented)

                    Picker("Encoding", selection: $viewModel.encoding) {
                        Text("PCM (.wav)").tag("LINEAR_PCM")
                        Text("Opus (.ogg)").tag("OGGOPUS")
                    }
                    .pickerStyle(.segmented)
                     .onChange(of: viewModel.encoding) { _ in
                          // Trigger filename validation/suggestion when encoding changes
                         let currentFilename = viewModel.outputFileName
                         viewModel.outputFileName = currentFilename
                     }
                }

                // --- Advanced Options / Files ---
                Section("Advanced Options") {
                     HStack {
                         Text("Audio Prompt:")
                         Spacer()
                         Button {
                             showingAudioPromptImporter = true
                         } label: {
                             // Display selected filename, or default text
                             Text(viewModel.audioPromptFileName ?? "Select File...")
                                .lineLimit(1)
                                .truncationMode(.middle)
                         }
                     }

                     HStack {
                          Text("Custom Dictionary:")
                          Spacer()
                          Button {
                              showingDictionaryImporter = true
                          } label: {
                              Text(viewModel.customDictionaryFileName ?? "Select File...")
                                 .lineLimit(1)
                                 .truncationMode(.middle)
                          }
                      }
                }

                // --- Output Options ---
                Section("Output") {
                    HStack {
                        Text("Filename:")
                        TextField("output.wav / output.ogg", text: $viewModel.outputFileName)
                              .autocorrectionDisabled()
                              #if os(iOS)
                              .textInputAutocapitalization(.never)
                              #endif
                              .textFieldStyle(.roundedBorder)
                              .disabled(!viewModel.saveToFile) // Disable if not saving
                              .opacity(viewModel.saveToFile ? 1.0 : 0.5) // Dim if not saving
                    }

                    Toggle("Stream Synthesis (Real-time)", isOn: $viewModel.useStreaming)
                     .tint(.orange)

                    Toggle("Play Audio After Synthesis", isOn: $viewModel.playAudio)
                       .tint(.green)

                    Toggle("Save Audio to File", isOn: $viewModel.saveToFile)
                       .tint(.blue)

                     HStack {
                          Text("Playback Device:")
                          Spacer()
                          Picker("Output Device", selection: $viewModel.selectedOutputDevice) {
                              ForEach(viewModel.availableDevices, id: \.self) { device in
                                 Text("\(device.name)").tag(device) // Keep it shorter
                              }
                          }
                         .labelsHidden() // Hide the default picker label if desired
                          // Button to trigger listing (optional if Picker is sufficient)
                          Button { viewModel.listDevices() } label: {
                              Image(systemName: "list.bullet")
                          }.padding(.leading, 5)
                     }
                     .disabled(!viewModel.playAudio) // Disable if not playing
                     .opacity(viewModel.playAudio ? 1.0 : 0.5) // Dim if not playing

                }

                // --- Connection Settings ---
                 Section("Connection") {
                     TextField("Server Address (e.g., grpc.nvcf.nvidia.com:443)", text: $viewModel.serverAddress)
                         .autocorrectionDisabled()
                          #if os(iOS)
                          .textInputAutocapitalization(.never)
                         #endif
                          .textFieldStyle(.roundedBorder)

                     Toggle("Use SSL/TLS", isOn: $viewModel.useSSL)

                      TextField("NVIDIA Function ID", text: $viewModel.functionID)
                             .autocorrectionDisabled()
                             #if os(iOS)
                             .textInputAutocapitalization(.never)
                             #endif
                              .textFieldStyle(.roundedBorder)

                      SecureField("API Key (If Required by Function)", text: $viewModel.apiKey)
                           .textFieldStyle(.roundedBorder)
                 }

                // --- Action Button & Status ---
                Section {
                    Button(action: viewModel.synthesize) {
                        HStack {
                            Spacer()
                            if viewModel.isSynthesizing {
                                ProgressView()
                                    .padding(.trailing, 5)
                                Text(viewModel.useStreaming ? "Streaming..." : "Synthesizing...")
                            } else {
                                Image(systemName: "waveform.and.mic")
                                Text("Synthesize Audio")
                            }
                            Spacer()
                        }
                         .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isSynthesizing || viewModel.textToSynthesize.isEmpty || viewModel.selectedVoice == nil || viewModel.functionID.isEmpty || viewModel.functionID == "YOUR_FUNCTION_ID_HERE")

                    VStack(alignment: .leading, spacing: 5) {
                         Text(viewModel.statusMessage)
                            .font(.caption)
                            .foregroundColor(viewModel.statusMessage.lowercased().contains("error") ? .red : .secondary)

                        // Only show progress bar when actively synthesizing
                       if viewModel.isSynthesizing {
                           ProgressView(value: viewModel.synthesisProgress)
                               .progressViewStyle(.linear)
                               .animation(.linear, value: viewModel.synthesisProgress) // Animate progress changes
                        }

                       if let tta = viewModel.timeToFirstAudio {
                            Text(String(format: "Time to First Audio: %.3f s", tta))
                               .font(.caption2)
                               .foregroundColor(.blue)
                        }
                       if let tst = viewModel.totalSynthesisTime {
                           Text(String(format: "Total Synthesis Time: %.3f s", tst))
                               .font(.caption2)
                               .foregroundColor(.green)
                       }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Riva TTS SwiftUI Client")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.listVoices()
                    } label: {
                         Label("List Voices", systemImage: "list.bullet.rectangle")
                     }
                    .disabled(viewModel.isSynthesizing)
                }
            }
            // Modifiers for File Importers
            .fileImporter(
                isPresented: $showingAudioPromptImporter,
                 allowedContentTypes: [UTType.audio], // Allow common audio types
                 allowsMultipleSelection: false
             ) { result in
                 viewModel.handleSelectedAudioPrompt(result: result)
             }
             .fileImporter(
                 isPresented: $showingDictionaryImporter,
                 allowedContentTypes: [UTType.plainText, UTType.json, UTType.xml], // Allow text-based dicts
                 allowsMultipleSelection: false
             ) { result in
                 viewModel.handleSelectedDictionary(result: result)
             }

            // Sheets for displaying lists
            .sheet(isPresented: $viewModel.showingVoiceList) {
                VoiceListView(voices: viewModel.availableVoices)
            }
            .sheet(isPresented: $viewModel.showingDeviceList) {
                DeviceListView(devices: viewModel.availableDevices)
            }
        }
        #if os(macOS)
        .frame(minWidth: 550, minHeight: 700) // Adjusted size for better layout
         #endif
    }
}

// --- Helper Views for Lists (Refined for clarity) ---

struct VoiceListView: View {
    let voices: [VoiceInfo]
    @Environment(\.dismiss) var dismiss

    // Group voices by language for sections
    var groupedVoices: [String: [VoiceInfo]] {
        Dictionary(grouping: voices, by: { $0.languageCode })
    }

    var sortedLanguageCodes: [String] {
        groupedVoices.keys.sorted {
            // Sort languages by their localized names
             let name1 = Locale.current.localizedString(forLanguageCode: $0) ?? $0
             let name2 = Locale.current.localizedString(forLanguageCode: $1) ?? $1
             return name1.localizedStandardCompare(name2) == .orderedAscending
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(sortedLanguageCodes, id: \.self) { langCode in
                    Section(header: Text(Locale.current.localizedString(forLanguageCode: langCode) ?? langCode)) {
                        ForEach(groupedVoices[langCode] ?? [], id: \.self) { voice in
                            VStack(alignment: .leading) {
                                 Text(voice.name).font(.headline)
                                // Add more details if available (e.g., gender)
                                // Text("Gender: \(voice.gender ?? "N/A")").font(.caption).foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped) // More modern list style
            .navigationTitle("Available Voices")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { // Use confirmationAction for "Done"
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct DeviceListView: View {
    let devices: [DeviceInfo]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(devices) { device in
                 HStack {
                    Image(systemName: device.name.lowercased().contains("speaker") ? "speaker.wave.2.fill" :
                                     device.name.lowercased().contains("headphone") || device.name.lowercased().contains("airpods") ? "headphones" :
                                     "hifispeaker.and.appletv") // Generic fallback icon
                    Text("\(device.name)")
                    Spacer()
                     Text("(ID: \(device.id))").font(.caption).foregroundColor(.gray)
                 }
            }
            .listStyle(.plain)
            .navigationTitle("Available Output Devices")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// --- App Entry Point (Unchanged) ---
//@main // Uncomment if this is the main App file
// struct RivaTTSApp: App {
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//         }
//     }
// }
