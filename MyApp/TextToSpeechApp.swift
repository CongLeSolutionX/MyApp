//
//  TextToSpeechApp.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import AVFoundation // Needed for audio playback

// --- Data Model ---

// Represents a single voice available for TTS
struct Voice: Identifiable, Hashable {
    let id = UUID() // Unique identifier for SwiftUI lists/pickers
    let name: String // e.g., "Magpie-Multilingual.EN-US.Female.Female-1"
    let languageCode: String // e.g., "en-US"
    let description: String // User-friendly display name

    // Example factory method to create voices easily
    static func create(name: String, languageCode: String) -> Voice {
        // Simple logic to make the name slightly more readable for the Picker
        let friendlyNameParts = name.components(separatedBy: ".")
        let description = friendlyNameParts.dropFirst().joined(separator: " ") // Skip "Magpie-Multilingual"
        return Voice(name: name, languageCode: languageCode, description: description.isEmpty ? name : description)
    }
}

// --- ViewModel / State Management ---

// Manages the app's state and logic
class SynthesisViewModel: ObservableObject {
    // --- Published Properties (UI State) ---
    @Published var inputText: String = "This audio is generated from text to speech."
    @Published var availableVoices: [Voice] = []
    @Published var selectedVoiceId: UUID? = nil // Use UUID for stable selection
    @Published var isSynthesizing: Bool = false // To show activity indicator
    @Published var synthesisMessage: String = "" // Feedback to user
    @Published var showVoiceList: Bool = false // To toggle voice list visibility

    // --- Audio Playback State ---
    @Published var isPlaying: Bool = false
    private var audioPlayer: AVAudioPlayer?
    var synthesizedAudioURL: URL? // Stores the URL of the "generated" audio

    // --- User Defaults Keys ---
    private let selectedVoiceNameKey = "selectedVoiceName"

    // --- Initialization ---
    init() {
        loadVoices()
        loadSelectedVoicePreference()
        setupAudioSession() // Configure audio playback settings
    }

    // --- Core Logic Methods ---

    // Simulates loading the list of available voices
    // In a real app, this would involve a network request (like the Python script's --list-voices)
    func loadVoices() {
        // Hardcoded example voices based on the Python script's example output structure
        // Grouped by language code for potential future organization
        let ttsModels: [String: [String]] = [
            "en-US": [
                "Magpie-Multilingual.EN-US.Female.Female-1",
                "Magpie-Multilingual.EN-US.Male.Male-1",
                "FastPitch.EN-US.Female.Female-1",
                "FastPitch.EN-US.Male.Male-1"
            ],
            "es-US": [
                "Magpie-Multilingual.ES-US.Female.Female-1",
                "Magpie-Multilingual.ES-US.Male.Male-1"
            ],
            "fr-FR": [
                "Magpie-Multilingual.FR-FR.Female.Female-1",
                "Magpie-Multilingual.FR-FR.Male.Male-1"
            ]
            // Add more languages and voices as needed
        ]

        var loadedVoices: [Voice] = []
        for (languageCode, voiceNames) in ttsModels {
            for name in voiceNames {
                loadedVoices.append(Voice.create(name: name, languageCode: languageCode))
            }
        }

        self.availableVoices = loadedVoices.sorted { $0.description < $1.description } // Sort alphabetically

        // Set default selection if none exists or the saved one isn't valid anymore
        if selectedVoiceId == nil || !availableVoices.contains(where: { $0.id == selectedVoiceId }) {
            selectedVoiceId = self.availableVoices.first?.id
        }
        
        // Ensure selection consistency after loading
         if let currentSelectedVoiceName = UserDefaults.standard.string(forKey: selectedVoiceNameKey) {
             selectedVoiceId = availableVoices.first { $0.name == currentSelectedVoiceName }?.id ?? availableVoices.first?.id
         } else {
             selectedVoiceId = availableVoices.first?.id
         }

        // Persist the initial default if nothing was loaded
        if let voice = selectedVoice {
             saveSelectedVoicePreference(voice: voice)
        }
    }

    // Computed property to get the currently selected Voice object
    var selectedVoice: Voice? {
        availableVoices.first { $0.id == selectedVoiceId }
    }

    // Simulates the synthesis process
    func synthesizeAudio() {
        guard let selectedVoice = selectedVoice else {
            synthesisMessage = "❌ Error: No voice selected."
            return
        }
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            synthesisMessage = "⚠️ Warning: Input text cannot be empty."
            return
        }

        print("--- Synthesis Request ---")
        print("Text: \(inputText)")
        print("Voice: \(selectedVoice.name)")
        print("Language Code: \(selectedVoice.languageCode)")
        print("-------------------------")

        isSynthesizing = true
        synthesisMessage = "🗣️ Synthesizing audio..."

        // **Placeholder:** Simulate network delay and audio file generation
        // In a real app, this is where the call to the NVIDIA Riva service would happen.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }

            // Simulate saving the audio file locally
            let simulatedFileName = "synthesized_audio.wav" // Example file name
            // In a real app, you'd save the actual received audio data to a file in Documents or Cache directory.
            // For this simulation, we'll point to a placeholder file in the app bundle.
            if let placeholderUrl = Bundle.main.url(forResource: "placeholder_audio", withExtension: "m4a") { // Use a placeholder audio
                 self.synthesizedAudioURL = placeholderUrl
                 self.synthesisMessage = "✅ Audio 'generated' successfully! Ready to play."
                 print("Simulated: Audio saved to temporary location: \(placeholderUrl.path)")

            } else {
                 self.synthesisMessage = "❌ Error: Placeholder audio file not found in bundle."
                 print("Error: Could not find placeholder_audio.m4a in the app bundle.")
                 self.synthesizedAudioURL = nil
            }

            self.isSynthesizing = false
        }
    }

    // --- Audio Playback Methods ---

    func playOrStopAudio() {
        if isPlaying {
            stopAudio()
        } else {
            playAudio()
        }
    }

    private func playAudio() {
        guard let url = synthesizedAudioURL else {
            synthesisMessage = "⚠️ No audio file available to play."
            print("Playback Error: No audio file URL set.")
            return
        }

        guard !isSynthesizing else {
             synthesisMessage = "⚠️ Please wait for synthesis to complete."
             return
        }

        do {
            // Stop any existing playback before starting new
            if audioPlayer?.isPlaying == true {
                audioPlayer?.stop()
            }
             // Ensure the player has an up-to-date URL before playing
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self // Set delegate to handle playback finishing
            audioPlayer?.prepareToPlay()

            if audioPlayer?.play() == true {
                isPlaying = true
                synthesisMessage = "▶️ Playing audio..."
                 print("Playback started for: \(url.path)")
            } else {
                synthesisMessage = "❌ Error: Could not start audio playback."
                print("Playback Error: player.play() returned false.")
                isPlaying = false
            }
        } catch {
            synthesisMessage = "❌ Error: Failed to load audio player - \(error.localizedDescription)"
            print("Playback Error: Failed to initialize AVAudioPlayer: \(error)")
            synthesizedAudioURL = nil // Invalidate URL if loading failed
            isPlaying = false
        }
    }

    func stopAudio() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            print("Playback stopped.")
        }
        audioPlayer = nil // Release the player instance
        isPlaying = false
        synthesisMessage = "⏹️ Playback stopped."
    }

    private func setupAudioSession() {
        // Configure the audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
             print("Audio session configured for playback.")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
            synthesisMessage = "Warning: Could not configure audio session."
        }
    }

    // --- Persistence ---

    func saveSelectedVoicePreference(voice: Voice) {
        UserDefaults.standard.set(voice.name, forKey: selectedVoiceNameKey)
         print("Saved voice preference: \(voice.name)")
    }

    private func loadSelectedVoicePreference() {
          guard let savedName = UserDefaults.standard.string(forKey: selectedVoiceNameKey) else {
              print("No saved voice preference found.")
              return
          }
         print("Loaded voice preference: \(savedName)")
         // Find the voice ID corresponding to the saved name AFTER voices are loaded
         // This is handled within loadVoices() to ensure the list exists first
    }

    // --- UI Interaction ---
    func toggleVoiceList() {
        showVoiceList.toggle()
        if showVoiceList {
            synthesisMessage = "📜 Voice list shown."
        } else {
             synthesisMessage = "" // Clear message when hiding list
        }
    }
}

// --- Make ViewModel conform to AVAudioPlayerDelegate ---
extension SynthesisViewModel: AVAudioPlayerDelegate {
    func isEqual(_ object: Any?) -> Bool {
        return true
    }
    
    var hash: Int {
        return 0
    }
    
    var superclass: AnyClass? {
        return nil
    }
    
    func `self`() -> Self {
        return self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func isProxy() -> Bool {
        return true
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        return true
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        return true
    }
    
    var description: String {
        return ""
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false // Update state when playback finishes naturally
        if flag {
             synthesisMessage = "✅ Playback finished."
             print("Playback finished successfully.")
        } else {
             synthesisMessage = "⚠️ Playback stopped unexpectedly."
             print("Playback finished unsuccessfully.")
        }
        // Optionally release the player here if not needed immediately after
         // audioPlayer = nil
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        synthesisMessage = "❌ Error during playback: \(error?.localizedDescription ?? "Unknown error")"
        print("Playback Decode Error: \(String(describing: error))")
        audioPlayer = nil // Release player on error
         synthesizedAudioURL = nil // Invalidate potentially corrupt URL
    }
}

// --- SwiftUI View ---

struct TextToSpeechApp_ContentView: View {
    // Use @StateObject for the ViewModel lifecycle tied to the View
    @StateObject private var viewModel = SynthesisViewModel()

    var body: some View {
        NavigationView {
            Form {
                // --- Input Section ---
                Section(header: Text("Input Text")) {
                    // Use TextEditor for multi-line input
                    TextEditor(text: $viewModel.inputText)
                        .frame(height: 150) // Give it a reasonable height
                        .border(Color.gray.opacity(0.2)) // Subtle border
                        .accessibilityLabel("Input text for speech synthesis")
                }

                // --- Configuration Section ---
                Section(header: Text("Configuration")) {
                    Picker("Select Voice", selection: $viewModel.selectedVoiceId) {
                        // Ensure voices are loaded before rendering picker options
                        ForEach(viewModel.availableVoices) { voice in
                            Text(voice.description).tag(voice.id as UUID?) // Use voice ID for tag
                        }
                    }
                    .onChange(of: viewModel.selectedVoiceId) { _ in
                         // Save preference when selection changes
                          if let voice = viewModel.selectedVoice {
                              viewModel.saveSelectedVoicePreference(voice: voice)
                          }
                     }
                    .accessibilityHint("Choose the voice model for synthesis")

                    // Button to show/hide the full voice list (optional)
                    Button(viewModel.showVoiceList ? "Hide Available Voices" : "Show Available Voices") {
                         viewModel.toggleVoiceList()
                    }
                     .accessibilityHint(viewModel.showVoiceList ? "Collapses the list of all voices" : "Expands the list of all voices")
                }

                 // --- Optional Voice List Display ---
                 if viewModel.showVoiceList {
                     Section(header: Text("Available Voices")) {
                         List(viewModel.availableVoices) { voice in
                             HStack {
                                 Text(voice.description)
                                 Spacer()
                                 Text(voice.languageCode)
                                     .font(.caption)
                                     .foregroundColor(.gray)
                             }
                         }
                          .frame(height: 200) // Limit height of the list
                     }
                 }

                // --- Action Section ---
                Section(header: Text("Actions")) {
                    // Synthesis Button
                    Button {
                        viewModel.synthesizeAudio()
                    } label: {
                        HStack {
                            Image(systemName: "waveform.path.ecg")
                            Text("Synthesize Audio")
                            if viewModel.isSynthesizing {
                                Spacer() // Push spinner to the right
                                ProgressView() // Show activity indicator
                                    .scaleEffect(0.8) // Make spinner slightly smaller
                            }
                        }
                    }
                    .disabled(viewModel.isSynthesizing) // Disable while working
                    .accessibilityHint("Starts the text-to-speech conversion")

                   // Playback Button (conditional)
                    if viewModel.synthesizedAudioURL != nil {
                         Button {
                              viewModel.playOrStopAudio()
                              // Hide keyboard if needed - requires a way to track focus state
                              // UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                         } label: {
                             HStack {
                                  Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                                  Text(viewModel.isPlaying ? "Stop Playback" : "Play Synthesized Audio")
                             }
                         }
                         .disabled(viewModel.isSynthesizing) // Can't play while still synthesizing
                         .accessibilityHint(viewModel.isPlaying ? "Stops the audio playback" : "Plays the generated audio")
                    }
                }

                // --- Status Section ---
                Section(header: Text("Status")) {
                    Text(viewModel.synthesisMessage.isEmpty ? "Ready" : viewModel.synthesisMessage)
                        .foregroundColor(messageColor)
                        .font(.callout)
                        .frame(minHeight: 30) // Ensure space for messages
                         .accessibilityLabel("Status message")
                         .accessibilityValue(viewModel.synthesisMessage.isEmpty ? "Ready" : viewModel.synthesisMessage)
                }
            }
            .navigationTitle("Text-to-Speech")
            .onAppear {
                 // Initial setup if needed, though most is in ViewModel's init
                 print("ContentView appeared.")
             }
            .onDisappear {
                 // Clean up audio player if view disappears while playing
                 viewModel.stopAudio()
                  print("ContentView disappeared, stopping audio.")
             }
        }
         // Use navigationViewStyle on iPad if needed
         // .navigationViewStyle(.stack)
    }

     // Helpercomputed property for message color
      private var messageColor: Color {
          if viewModel.synthesisMessage.contains("Error") {
              return .red
          } else if viewModel.synthesisMessage.contains("Warning") {
                return .orange
          } else if viewModel.synthesisMessage.contains("✅") || viewModel.synthesisMessage.contains("▶️") {
                return .green
          } else {
              return .secondary // Default color
          }
      }
}

#Preview("TextToSpeechApp_ContentView") {
    TextToSpeechApp_ContentView()
}

// --- App Entry Point ---
//
//@main
//struct TextToSpeechApp: App {
//    var body: some Scene {
//        WindowGroup {
//            TextToSpeechApp_ContentView()
//        }
//    }
//}
