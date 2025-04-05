//
//  SmartCorrecrionAndAssistantView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
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

// Enum for Vietnamese Dialects (for Prediction/Correction preference)
enum VietnameseDialect: String, CaseIterable, Identifiable {
    case neutral = "Neutral / Default"
    case northern = "Northern (Hanoi)"
    case central = "Central (Hue)"
    case southern = "Southern (Saigon)"

    var id: String { self.rawValue }
}

// Enum for Correction Aggressiveness
enum CorrectionAggressiveness: String, CaseIterable, Identifiable {
    case low = "Low"         // Only correct highly confident typos
    case medium = "Medium"     // Balance correction and user intent (Default)
    case high = "High"        // Correct more aggressively, may change intended words

    var id: String { self.rawValue }

    var description: String {
        switch self {
        case .low: return "Corrects only the most obvious typos (e.g., 'hte' -> 'the'). Least likely to change intended words."
        case .medium: return "Balances correcting common misspellings with preserving user intent. Recommended default."
        case .high: return "Corrects more frequently, relying heavily on context and word probability. May sometimes change correctly typed words."
        }
    }
}


// Struct for Vietnamese Voice Option (if distinguishable)
struct VietnameseVoiceOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let identifier: String
}

// MARK: - Vietnamese Input Settings View

struct VietnameseInputSettingsView: View {

    // Internal constants for UserDefaults keys
    private let customDictionaryKey = "userCustomDictionary_vi"

    // --- Keyboard Settings ---
    @AppStorage("settings_vietnameseKeyboardLayout") private var selectedKeyboardLayout: VietnameseKeyboardLayout = .telex
    @AppStorage("settings_vietnameseAccentMarking") private var accentMarkingStyle: AccentMarkingStyle = .automatic

    // --- Prediction & Correction Intelligence ---
    @AppStorage("settings_vietnameseWordPrediction") private var enableWordPrediction: Bool = true
    @AppStorage("settings_vietnameseAutoCorrection") private var enableAutoCorrection: Bool = true // Often linked to system keyboard settings
    @AppStorage("settings_vietnameseCorrectionAggressiveness") private var correctionAggressiveness: CorrectionAggressiveness = .medium // New Setting
    @AppStorage("settings_vietnameseDialectPreference") private var dialectPreference: VietnameseDialect = .neutral
    @AppStorage("settings_vietnameseToneCorrectionAssist") private var enableToneCorrectionAssist: Bool = false
    @AppStorage("settings_vietnameseHomophoneDisambiguation") private var enableHomophoneSuggestions: Bool = true // Setting to control homophone UI

    // --- Custom User Dictionary (Using UserDefaults for this example) ---
    // In a real app, consider CoreData, Realm, CloudKit, or a separate file store for scalability.
    @State private var customDictionary: [String] = [] // Loaded from UserDefaults onAppear
    @State private var newWord: String = ""
    @State private var showingAddWordErrorAlert = false
    @State private var addWordErrorMessage = ""
    @State private var dictionarySearchText: String = "" // For filtering the list

    // Filtered dictionary based on search text
    var filteredDictionary: [String] {
        if dictionarySearchText.isEmpty {
            return customDictionary
        } else {
            // Simple case-insensitive prefix search
            return customDictionary.filter { $0.lowercased().hasPrefix(dictionarySearchText.lowercased()) }
        }
    }

    // --- Voice Settings (Optional: Only if specific VI voices are needed beyond general settings) ---
    @AppStorage("settings_vietnameseSpecificVoiceIdentifier") private var specificVietnameseVoiceIdentifier: String = ""
    let availableVietnameseVoices: [VietnameseVoiceOption] = AVSpeechSynthesisVoice.speechVoices()
        .filter { $0.language.starts(with: "vi-") }
        .map { VietnameseVoiceOption(name: $0.name, identifier: $0.identifier) }
        .sorted { $0.name < $1.name }

    var body: some View {
        Form {
            // Section: Keyboard Layout & Input Method
            Section("Keyboard Layout & Input") {
                Picker("Keyboard Layout", selection: $selectedKeyboardLayout) {
                    ForEach(VietnameseKeyboardLayout.allCases) { layout in
                        Text(layout.rawValue).tag(layout)
                    }
                }
                Text("Select input method (Telex/VNI requires a custom keyboard extension or system support).")
                     .font(.caption)
                     .foregroundColor(.gray)

                // Accent marking style might be controlled by the specific keyboard implementation
                // Picker("Accent Marking", selection: $accentMarkingStyle) {
                //     ForEach(AccentMarkingStyle.allCases) { style in
                //         Text(style.rawValue).tag(style)
                //     }
                // }
                // Text("This setting may depend on the active keyboard.")
                //     .font(.caption)
                //     .foregroundColor(.gray)
            }

            // Section: Prediction & Correction Intelligence
            Section("Prediction & Correction Intelligence") {
                Toggle("Enable Word Prediction", isOn: $enableWordPrediction)
                 Text("Show suggestions above the keyboard as you type.")
                     .font(.caption)
                     .foregroundColor(.gray)

                Toggle("Enable Auto-Correction", isOn: $enableAutoCorrection)
                 Text("Automatically fix likely typos and spelling errors.")
                     .font(.caption)
                     .foregroundColor(.gray)

                // Correction Aggressiveness Setting (New)
                VStack(alignment: .leading, spacing: 5) {
                    Picker("Correction Aggressiveness", selection: $correctionAggressiveness) {
                        ForEach(CorrectionAggressiveness.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    Text(correctionAggressiveness.description) // Provide description based on enum
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4) // Add some padding within the form row

                // Dialect Preference
                 Picker("Preferred Dialect (Suggestions)", selection: $dialectPreference) {
                     ForEach(VietnameseDialect.allCases) { dialect in
                         Text(dialect.rawValue).tag(dialect)
                     }
                 }
                 Text("Influences word prediction and correction to favor terms common in a specific region.\n(Requires a dialect-aware prediction engine and dictionary).")
                    .font(.caption)
                    .foregroundColor(.gray)

                 // Tone Correction Assistance
                 Toggle("Tone Correction Assistance", isOn: $enableToneCorrectionAssist)
                 Text("Experimental: Suggest likely tone marks for words typed without them, or flag potentially incorrect tones.\n(Requires advanced analysis).")
                    .font(.caption)
                    .foregroundColor(.gray)

                 // Homophone Disambiguation Control
                 Toggle("Suggest Homophones", isOn: $enableHomophoneSuggestions)
                  Text("When typing words like 'la', show options ('là', 'lá', 'lạ') in the suggestion bar.\n(Requires a dictionary tagged with homophone groups).")
                     .font(.caption)
                     .foregroundColor(.gray)

                 // Note about Undo: Usually a runtime UI element, not a setting.
                 Text("Note: Undoing a correction is typically handled via a temporary button that appears after a correction occurs.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }

            // Section: Custom User Dictionary
            Section("Custom Dictionary") {
                 Text("Add or remove words to improve prediction and prevent incorrect corrections for names, slang, or technical terms.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)

                 // --- Dictionary Management UI ---
                 HStack {
                     TextField("Enter word to add", text: $newWord)
                         .disableAutocorrection(true)
                         .autocapitalization(.none)
                         .onSubmit(addWordToDictionary) // Allow adding via return key
                     Button {
                         addWordToDictionary()
                     } label: {
                         Image(systemName: "plus.circle.fill")
                             .foregroundColor(.green)
                     }
                     .disabled(newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                 }

                 // Search field for larger dictionaries
                 TextField("Search Dictionary", text: $dictionarySearchText)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(.top, 5)

                 // List of custom words (filtered)
                 if customDictionary.isEmpty {
                     Text("No custom words added yet.")
                         .foregroundColor(.gray)
                         .padding(.vertical)
                 } else if filteredDictionary.isEmpty && !dictionarySearchText.isEmpty {
                     Text("No words found matching '\(dictionarySearchText)'.")
                         .foregroundColor(.gray)
                         .padding(.vertical)
                 } else {
                     // Use a List for dynamic content and built-in swipe-to-delete
                      List {
                          ForEach(filteredDictionary, id: \.self) { word in
                              Text(word)
                          }
                          .onDelete(perform: removeWordFromDictionaryWithFilter) // Use filtered indices
                      }
                      // Adjust list style or height if needed for larger lists
                      // .frame(minHeight: 100, maxHeight: 300) // Example height constraint
                 }
            }
            .alert("Invalid Word", isPresented: $showingAddWordErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(addWordErrorMessage)
            }


            // Section: Voice Feedback (Optional - Placeholder remains the same)
            /*
            Section("Voice Feedback (Vietnamese)") {
                ...
            }
            */

            // Section: Information/Help
            Section("Help") {
                 NavigationLink("How to add Vietnamese Keyboards") {
                     Text("""
                     To use different Vietnamese input methods (Telex, VNI):
                     1. Open device **Settings** > **General** > **Keyboard** > **Keyboards**.
                     2. Select **Add New Keyboard...** and choose **Vietnamese**. Pick your layout.
                     3. *Alternatively*, if this app provides a *custom keyboard extension*, enable it here after installation.
                     """)
                     .padding()
                     .navigationTitle("Add Keyboard Help")
                 }
                 NavigationLink("Prediction & Correction Details") {
                      Text("""
                      **Word Prediction & Correction:** Uses a combination of the standard iOS dictionary and your Custom Dictionary.
                      **Dialect Preference:** Attempts to bias suggestions towards regional terms. Accuracy depends on the prediction engine's capabilities.
                      **Tone Assistance:** An experimental feature to help with Vietnamese tones. May not always be correct.
                      **Homophone Suggestions:** Helps distinguish words that sound alike but have different meanings or tones (e.g., 'ma', 'má', 'mà', 'mạ'). Requires a well-tagged dictionary.
                      **Correction Aggressiveness:** Controls how readily the system changes your typing. 'Low' is safest, 'High' fixes more but might over-correct.
                      """)
                          .padding()
                          .navigationTitle("Assistance Features")
                 }
            }
        }
        .navigationTitle("Vietnamese Input")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadDictionary) // Load when the view appears
        // onDisappear could potentially save, but saving after each modification is safer
    }

    // --- Custom Dictionary Logic (Enhanced for UserDefaults) ---

    private func loadDictionary() {
        print("[Dictionary] Loading from UserDefaults...")
        // Retrieve the array from UserDefaults, default to empty array if not found
        customDictionary = UserDefaults.standard.stringArray(forKey: customDictionaryKey) ?? []
        print("[Dictionary] Loaded \(customDictionary.count) words.")
    }

    private func saveDictionary() {
        print("[Dictionary] Saving \(customDictionary.count) words to UserDefaults...")
        // Sort before saving to maintain order and simplify diffs/merges if needed elsewhere
        customDictionary.sort()
        // Persist the current state of the dictionary to UserDefaults
        UserDefaults.standard.set(customDictionary, forKey: customDictionaryKey)
        print("[Dictionary] Save complete.")
    }

    private func addWordToDictionary() {
        let trimmedWord = newWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedWord.isEmpty else {
            addWordErrorMessage = "Word cannot be empty."
            showingAddWordErrorAlert = true
            return
        }
         // Basic check for numbers or excessive symbols (adjust regex as needed)
         let allowedCharacters = CharacterSet.letters.union(.decimalDigits).union(CharacterSet(charactersIn: "'/-")) // Allow letters, numbers, apostrophe, slash, hyphen
         guard trimmedWord.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
             addWordErrorMessage = "Word contains invalid characters."
             showingAddWordErrorAlert = true
             return
         }
         guard !customDictionary.contains(where: { $0.caseInsensitiveCompare(trimmedWord) == .orderedSame }) else {
             addWordErrorMessage = "'\(trimmedWord)' is already in the dictionary."
             showingAddWordErrorAlert = true
             newWord = "" // Clear input even if duplicate
             return
         }

        // Add word and save
        customDictionary.append(trimmedWord)
        saveDictionary() // Save changes immediately
        newWord = "" // Clear input field
        print("[Dictionary] Added word: \(trimmedWord).")
    }

    // Handles deletion when the list is potentially filtered
    private func removeWordFromDictionaryWithFilter(at offsets: IndexSet) {
        // 1. Get the actual words to remove from the *filtered* list based on the offsets
        let wordsToRemove = offsets.map { filteredDictionary[$0] }

        // 2. Remove these specific words from the *main* dictionary array
        customDictionary.removeAll { word in wordsToRemove.contains(word) }

        // 3. Save the updated main dictionary
        saveDictionary()
        print("[Dictionary] Removed words: \(wordsToRemove).")
    }
}

// MARK: - Preview Provider

struct VietnameseInputSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VietnameseInputSettingsView()
                .onAppear {
                    // Setup initial UserDefaults for preview consistency
                    let previewKey = "userCustomDictionary_vi" // Match the key used in the view
                    let initialWords = ["phở bò", "bún chả", "cà phê sữa đá", "áo dài", "xích lô"]
                    UserDefaults.standard.set(initialWords, forKey: previewKey)
                    print("[Preview] Set initial UserDefaults dictionary.")

                    // Set other defaults for preview if needed
                    UserDefaults.standard.set(CorrectionAggressiveness.medium.rawValue, forKey: "settings_vietnameseCorrectionAggressiveness")
                    UserDefaults.standard.set(VietnameseDialect.neutral.rawValue, forKey: "settings_vietnameseDialectPreference")
                }
        }
        .preferredColorScheme(.dark)
    }
}
