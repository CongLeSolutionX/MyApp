//
//  CutomInputLanguageScreen.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//

import SwiftUI
import AVFoundation // For voice selection if needed

// MARK: - Vietnamese Input Specific Data Structures

// Enum for Vietnamese Keyboard Layouts
enum VietnameseKeyboardLayout: String, CaseIterable, Identifiable {
    case telex = "Telex"
    case vni = "VNI"
    case standard = "Standard" // Built-in iOS Vietnamese

    var id: String { self.rawValue }
}

// Enum for Accent Marking Style
enum AccentMarkingStyle: String, CaseIterable, Identifiable {
    case automatic = "Automatic" // Typically default
    case manual = "Manual" // Less common, might depend on keyboard

    var id: String { self.rawValue }
}

// Struct for Vietnamese Voice Option (if distinguishable)
struct VietnameseVoiceOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let identifier: String
}

// MARK: - Vietnamese Input Settings View

struct VietnameseInputSettingsView: View {

    // --- Keyboard Settings ---
    @AppStorage("settings_vietnameseKeyboardLayout") private var selectedKeyboardLayout: VietnameseKeyboardLayout = .telex
    @AppStorage("settings_vietnameseAccentMarking") private var accentMarkingStyle: AccentMarkingStyle = .automatic

    // --- Prediction & Correction ---
    @AppStorage("settings_vietnameseWordPrediction") private var enableWordPrediction: Bool = true
    @AppStorage("settings_vietnameseAutoCorrection") private var enableAutoCorrection: Bool = true // Often linked to system keyboard settings

    // --- Voice Settings (Optional: Only if specific VI voices are needed beyond general settings) ---
    // Note: Usually the main voice setting covers this if a Vietnamese voice is selected there.
    // This is a placeholder if you needed *separate* voice config *just* for VN input feedback.
    @AppStorage("settings_vietnameseSpecificVoiceIdentifier") private var specificVietnameseVoiceIdentifier: String = ""
    // Filter available voices for Vietnamese
    let availableVietnameseVoices: [VietnameseVoiceOption] = AVSpeechSynthesisVoice.speechVoices()
        .filter { $0.language.starts(with: "vi-") } // Filter specifically for Vietnamese
        .map { VietnameseVoiceOption(name: $0.name, identifier: $0.identifier) }
        .sorted { $0.name < $1.name }

    var body: some View {
        // Use Form for standard settings appearance
        Form {
            // Section: Keyboard Layout & Input Method
            Section("Keyboard Layout & Input") {
                Picker("Keyboard Layout", selection: $selectedKeyboardLayout) {
                    ForEach(VietnameseKeyboardLayout.allCases) { layout in
                        Text(layout.rawValue).tag(layout)
                    }
                }
                // Note: Actual keyboard switching is handled at the iOS system level.
                // This setting is for app-level knowledge or potentially custom keyboards.
                Text("Select your preferred input method. Note: You may need to enable the corresponding keyboard in iOS Settings > General > Keyboard > Keyboards.")
                     .font(.caption)
                     .foregroundColor(.gray)

                Picker("Accent Marking", selection: $accentMarkingStyle) {
                    ForEach(AccentMarkingStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                Text("Choose how accents are placed (often determined by the selected keyboard layout).")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Section: Typing Assistance
            Section("Typing Assistance") {
                Toggle("Enable Word Prediction", isOn: $enableWordPrediction)
                Text("Suggest words as you type.")
                    .font(.caption)
                    .foregroundColor(.gray)

                Toggle("Enable Auto-Correction", isOn: $enableAutoCorrection)
                Text("Automatically correct spelling errors. Relies on system keyboard settings.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            /// Section: Voice Feedback (Optional - If needed)
            // This section allow you to use a *separate* voice
            // setting specifically for Vietnamese input feedback within the app,
            // distinct from the main app's output voice.
          
            Section("Voice Feedback (Vietnamese)") {
                if availableVietnameseVoices.isEmpty {
                    Text("No specific Vietnamese voices found on this device.")
                        .foregroundColor(.gray)
                } else {
                    Picker("Feedback Voice", selection: $specificVietnameseVoiceIdentifier) {
                        Text("Default App Voice").tag("") // Option to use the main setting
                        ForEach(availableVietnameseVoices) { voice in
                            Text(voice.name).tag(voice.identifier)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    Text("Select a voice for reading back Vietnamese text within the app, if different from the main setting.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Section: Information/Help
            Section("Help") {
                 NavigationLink("How to add Vietnamese Keyboards") {
                     // Simple view with instructions or link
                     Text("""
                     To add Vietnamese keyboards to your device:
                     1. Open **Settings**.
                     2. Go to **General** > **Keyboard**.
                     3. Tap **Keyboards** > **Add New Keyboard...**.
                     4. Select **Vietnamese** and choose your preferred layout (Telex, VNI, or Standard).
                     """)
                     .padding()
                     .navigationTitle("Add Keyboard Help")
                 }
            }
        }
        .navigationTitle("Vietnamese Input") // Set the title for this specific settings screen
        .navigationBarTitleDisplayMode(.inline) // Keep title inline
    }
}

// MARK: - Preview Provider

struct VietnameseInputSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for preview context
            VietnameseInputSettingsView()
        }
        .preferredColorScheme(.dark) // Preview in dark mode
    }
}
