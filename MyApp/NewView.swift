////
////  NewView.swift
////  MyApp
////
////  Created by Cong Le on 4/5/25.
////
//
//import SwiftUI
//import Combine // For ObservableObject
//import AVFoundation // For voice selection if needed
//
//// MARK: - Prediction & Correction Data Structures (Diagram 4)
//
//// Enum for Dialect Tags
//enum DialectTag: String, CaseIterable, Identifiable, Codable {
//    case north = "North"
//    case central = "Central"
//    case south = "South"
//    case universal = "Universal" // Default/neutral
//
//    var id: String { self.rawValue }
//}
//
//// Enum for Vocabulary Types
//enum VocabularyType: String, CaseIterable, Identifiable, Codable {
//    case standard = "Standard"
//    case properNounPerson = "Person Name"
//    case properNounPlace = "Place Name"
//    case loanword = "Loanword"
//    case slang = "Slang"
//    case userAdded = "User Added"
//    case learned = "Learned" // (Future Use)
//
//    var id: String { self.rawValue }
//}
//
//// Structure for a Custom Dictionary Entry
//struct DictionaryEntry: Identifiable, Codable, Hashable {
//    var id = UUID() // Use UUID for Identifiable conformance
//    var word: String
//    var frequency: Int = 1 // Default frequency
//    var dialectTags: [DialectTag] = [.universal] // Default tag
//    var vocabType: VocabularyType = .userAdded // Default type
//    var lastUsed: Date? = nil // Optional
//    var dateAdded: Date = Date()
//    var userNotes: String? = nil // Optional
//
//    // Basic initializer
//    init(word: String, dialectTags: [DialectTag] = [.universal], vocabType: VocabularyType = .userAdded, frequency: Int = 1, notes: String? = nil) {
//        self.word = word
//        self.dialectTags = dialectTags
//        self.vocabType = vocabType
//        self.frequency = frequency
//        self.userNotes = notes
//        self.dateAdded = Date()
//    }
//}
//
//// MARK: - Mock Custom Dictionary Manager (Handles Local Data)
//
//class CustomDictionaryManager: ObservableObject {
//    @Published var customWords: [DictionaryEntry] = [] // The source of truth
//
//    // Key for UserDefaults persistence
//    private let dictionaryStorageKey = "customVietnameseDictionary_v1"
//
//    init() {
//        loadDictionary()
//    }
//
//    // Load from UserDefaults (or initialize with mock data)
//    private func loadDictionary() {
//        if let data = UserDefaults.standard.data(forKey: dictionaryStorageKey) {
//            do {
//                let decoder = JSONDecoder()
//                customWords = try decoder.decode([DictionaryEntry].self, from: data)
//                print("[DictManager] Loaded \(customWords.count) words from UserDefaults.")
//                return
//            } catch {
//                print("[DictManager] Error decoding custom dictionary: \(error). Using mock data.")
//            }
//        }
//
//        // Initialize with some mock data if loading fails or no data exists
//        print("[DictManager] Initializing with mock dictionary data.")
//        customWords = [
//            DictionaryEntry(word: "phở", dialectTags: [.north, .universal], vocabType: .standard),
//            DictionaryEntry(word: "Sài Gòn", dialectTags: [.south], vocabType: .properNounPlace),
//            DictionaryEntry(word: "tivi", dialectTags: [.universal], vocabType: .loanword, frequency: 5),
//            DictionaryEntry(word: "được", dialectTags: [.universal], vocabType: .standard, frequency: 10),
//            DictionaryEntry(word: "dzui", dialectTags: [.south, .central], vocabType: .slang, notes: "Informal 'vui'")
//        ]
//        saveDictionary() // Save the initial mock data
//    }
//
//    // Save to UserDefaults
//    private func saveDictionary() {
//        do {
//            let encoder = JSONEncoder()
//            let data = try encoder.encode(customWords)
//            UserDefaults.standard.set(data, forKey: dictionaryStorageKey)
//            print("[DictManager] Saved \(customWords.count) words to UserDefaults.")
//        } catch {
//            print("[DictManager] Error encoding custom dictionary: \(error)")
//        }
//    }
//
//    // --- CRUD Operations ---
//
//    func addWord(_ entry: DictionaryEntry) {
//        // Basic check to prevent exact duplicates
//        if !customWords.contains(where: { $0.word.lowercased() == entry.word.lowercased() }) {
//            customWords.append(entry)
//            saveDictionary()
//            print("[DictManager] Added word: '\(entry.word)'")
//        } else {
//            print("[DictManager] Word '\(entry.word)' already exists. Not adding.")
//            // Optionally, update frequency or merge tags here if needed
//        }
//    }
//
//    func removeWord(at offsets: IndexSet) {
//         let removedWords = offsets.map { customWords[$0].word }.joined(separator: ", ")
//         customWords.remove(atOffsets: offsets)
//         saveDictionary()
//         print("[DictManager] Removed words: \(removedWords)")
//    }
//
//    func removeWord(entry: DictionaryEntry) {
//        if let index = customWords.firstIndex(where: { $0.id == entry.id }) {
//            removeWord(at: IndexSet(integer: index))
//        } else {
//             print("[DictManager] Could not find word with ID \(entry.id) to remove.")
//        }
//    }
//
//
//    // Placeholder for update - requires more UI
//    func updateWord(_ entry: DictionaryEntry) {
//        guard let index = customWords.firstIndex(where: { $0.id == entry.id }) else {
//            print("[DictManager] Word with ID \(entry.id) not found for update.")
//            return
//        }
//        customWords[index] = entry
//        saveDictionary()
//        print("[DictManager] Updated word: '\(entry.word)'")
//    }
//
//    // --- Query Operations (Placeholders for Prediction/Correction Logic) ---
//
//    // Get words starting with a prefix (simplified)
//    func getPotentialCompletions(prefix: String, context: String?) -> [DictionaryEntry] {
//        guard !prefix.isEmpty else { return [] }
//        let lowerPrefix = prefix.lowercased()
//        // Simple filtering and sorting by frequency (descending)
//        return customWords
//            .filter { $0.word.lowercased().hasPrefix(lowerPrefix) }
//            .sorted { $0.frequency > $1.frequency } // Higher frequency first
//        // In a real app: consider context, dialect, recency etc.
//    }
//
//     // Check if a word exists (case-insensitive)
//    func lookupWord(_ word: String) -> DictionaryEntry? {
//         let lowerWord = word.lowercased()
//         return customWords.first { $0.word.lowercased() == lowerWord }
//     }
//}
//
//// Enum for Vietnamese Keyboard Layouts
//enum VietnameseKeyboardLayout: String, CaseIterable, Identifiable {
//    case telex = "Telex"
//    case vni = "VNI"
//    case standard = "Standard" // Built-in iOS Vietnamese
//
//    var id: String { self.rawValue }
//}
//
//// Enum for Accent Marking Style
//enum AccentMarkingStyle: String, CaseIterable, Identifiable {
//    case automatic = "Automatic" // Typically default
//    case manual = "Manual" // Less common, might depend on keyboard
//
//    var id: String { self.rawValue }
//}
//// Struct for Vietnamese Voice Option (if distinguishable)
//struct VietnameseVoiceOption: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let identifier: String
//}
//
//
//// MARK: - Vietnamese Input Settings View (Extended)
//
//struct VietnameseInputSettingsView: View {
//
//    // --- Existing Keyboard Settings ---
//    @AppStorage("settings_vietnameseKeyboardLayout") private var selectedKeyboardLayout: VietnameseKeyboardLayout = .telex
//    @AppStorage("settings_vietnameseAccentMarking") private var accentMarkingStyle: AccentMarkingStyle = .automatic
//
//    // --- NEW: Prediction & Correction Settings (Diagram 4: PredictionSettings) ---
//    @AppStorage("settings_prediction_isPredictionEnabled") private var isPredictionEnabled: Bool = true
//    @AppStorage("settings_prediction_isCorrectionEnabled") private var isCorrectionEnabled: Bool = true
//    @AppStorage("settings_prediction_useCustomDictionary") private var useCustomDictionary: Bool = true
//    @AppStorage("settings_prediction_learnFromInput") private var learnFromInput: Bool = false // Default to off for privacy/simplicity
//    @AppStorage("settings_prediction_preferredDialect_raw") private var preferredDialectRaw: String = DialectTag.universal.rawValue
//    // Note on enabledVocabTypes: Storing array in AppStorage is tricky. UserDefaults is better.
//    // Using simple toggles for common types for now.
//    @AppStorage("settings_prediction_enableSlang") private var enableSlang: Bool = false
//    @AppStorage("settings_prediction_enableLoanwords") private var enableLoanwords: Bool = true
//
//    // Computed property for preferred Dialect
//    var preferredDialect: DialectTag {
//        get { DialectTag(rawValue: preferredDialectRaw) ?? .universal }
//        set { preferredDialectRaw = newValue.rawValue }
//    }
//
//
//    // --- Dictionary Manager State ---
//    @StateObject private var dictionaryManager = CustomDictionaryManager()
//
//    // --- Existing Voice Settings (Optional) ---
//    @AppStorage("settings_vietnameseSpecificVoiceIdentifier") private var specificVietnameseVoiceIdentifier: String = ""
//    let availableVietnameseVoices: [VietnameseVoiceOption] = AVSpeechSynthesisVoice.speechVoices()
//        .filter { $0.language.starts(with: "vi-") }
//        .map { VietnameseVoiceOption(name: $0.name, identifier: $0.identifier) }
//        .sorted { $0.name < $1.name }
//
//
//    var body: some View {
//        Form {
//            // Section: Keyboard Layout & Input Method (Unchanged)
//            Section("Keyboard Layout & Input") {
//                Picker("Keyboard Layout", selection: $selectedKeyboardLayout) {
//                    ForEach(VietnameseKeyboardLayout.allCases) { layout in
//                        Text(layout.rawValue).tag(layout)
//                    }
//                }
//                Text("Select your preferred input method. Note: You may need to enable the corresponding keyboard in iOS Settings > General > Keyboard > Keyboards.")
//                     .font(.caption)
//                     .foregroundColor(.gray)
//
//                Picker("Accent Marking", selection: $accentMarkingStyle) {
//                    ForEach(AccentMarkingStyle.allCases) { style in
//                        Text(style.rawValue).tag(style)
//                    }
//                }
//                Text("Choose how accents are placed (often determined by the selected keyboard layout).")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//
//            // --- NEW: Section: Prediction & Correction ---
//            Section("Prediction & Correction") {
//                Toggle("Enable Word Prediction", isOn: $isPredictionEnabled)
//                Toggle("Enable Auto-Correction", isOn: $isCorrectionEnabled)
//                Toggle("Use Custom Dictionary", isOn: $useCustomDictionary)
//                    .onChange(of: useCustomDictionary) { newValue in
//                        print("[Settings] Use Custom Dictionary toggled to: \(newValue)")
//                        // Placeholder: Prediction/Correction logic would now use/ignore dictionaryManager
//                    }
//                Toggle("Learn from Typing (Future)", isOn: $learnFromInput)
//                     .disabled(true) // Disabled for now
//                     .foregroundColor(.gray)
//                Text("Automatically add new words you type frequently (requires careful implementation).")
//                     .font(.caption)
//                     .foregroundColor(.gray)
//
//                 Picker("Preferred Dialect", selection: $preferredDialect) {
//                     ForEach(DialectTag.allCases) { dialect in
//                         Text(dialect.rawValue).tag(dialect)
//                     }
//                 }
//                 Text("Prioritize suggestions from a specific region.")
//                     .font(.caption)
//                     .foregroundColor(.gray)
//
//                // Simplified Vocab Type handling
//                 Toggle("Suggest Slang/Informal Words", isOn: $enableSlang)
//                 Toggle("Recognize Common Loanwords", isOn: $enableLoanwords)
//
//                 // Navigation to Dictionary Management Screen
//                 NavigationLink("Manage Custom Dictionary (\(dictionaryManager.customWords.count))") {
//                     ManageCustomDictionaryView()
//                         .environmentObject(dictionaryManager) // Pass manager down
//                 }
//
//            }
//
//            // Section: Voice Feedback (Optional - Unchanged)
//             /*
//             Section("Voice Feedback (Vietnamese)") { ... }
//             */
//
//            // Section: Help (Unchanged)
//            Section("Help") {
//                 NavigationLink("How to add Vietnamese Keyboards") {
//                    Text("""
//                    To add Vietnamese keyboards to your device:
//                    1. Open **Settings**.
//                    2. Go to **General** > **Keyboard**.
//                    3. Tap **Keyboards** > **Add New Keyboard...**.
//                    4. Select **Vietnamese** and choose your preferred layout (Telex, VNI, or Standard).
//                    """)
//                    .padding()
//                    .navigationTitle("Add Keyboard Help")
//                 }
//            }
//        }
//        .navigationTitle("Vietnamese Input")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            // Optional: Trigger logic when settings view appears
//            print("[Settings View] VietnameseInputSettingsView Appeared.")
//             let exampleCompletions = dictionaryManager.getPotentialCompletions(prefix: "dz", context: nil)
//             print("[Settings View] Example completions for 'dz': \(exampleCompletions.map { $0.word })")
//             if let lookup = dictionaryManager.lookupWord("Phở") {
//                 print("[Settings View] Lookup 'Phở' found: \(lookup)")
//             } else {
//                 print("[Settings View] Lookup 'Phở' not found.")
//             }
//        }
//    }
//}
//
//// MARK: - Manage Custom Dictionary View
//
//struct ManageCustomDictionaryView: View {
//    @EnvironmentObject var dictionaryManager: CustomDictionaryManager // Get manager from environment
//    @State private var showingAddWordSheet = false
//    @State private var wordToDelete: DictionaryEntry? = nil // For confirmation alert
//
//    var body: some View {
//        List {
//            ForEach(dictionaryManager.customWords) { entry in
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text(entry.word).font(.headline)
//                        Text("(\(entry.vocabType.rawValue)) - Freq: \(entry.frequency) - Dialects: \(entry.dialectTags.map {$0.rawValue}.joined(separator: ", "))")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                         if let notes = entry.userNotes, !notes.isEmpty {
//                             Text("Notes: \(notes)")
//                                 .font(.caption2)
//                                 .italic()
//                                 .foregroundColor(.orange)
//                         }
//                    }
//                    Spacer()
//                    // Add Edit Button (Placeholder Action)
//                    Button {
//                        print("[Dict Manage] Edit tapped for \(entry.word) (Placeholder)")
//                        // Present edit sheet or navigate
//                    } label: {
//                        Image(systemName: "pencil.circle")
//                    }
//                    .buttonStyle(.borderless) // Makes it look better in a list row
//
//                 }
//                  // Enable swipe-to-delete
//                  .swipeActions(edge: .trailing) {
//                       Button(role: .destructive) {
//                           print("[Dict Manage] Delete action swiped for \(entry.word)")
//                           self.wordToDelete = entry // Set for confirmation
//                       } label: {
//                            Label("Delete", systemImage: "trash.fill")
//                       }
//                  }
//            }
//            .onDelete(perform: deleteWordFromList) // Alternative delete method
//        }
//        .navigationTitle("Custom Dictionary")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    showingAddWordSheet = true
//                } label: {
//                    Label("Add Word", systemImage: "plus.circle.fill")
//                }
//            }
//        }
//        .sheet(isPresented: $showingAddWordSheet) {
//            AddWordView()
//                .environmentObject(dictionaryManager) // Pass manager to sheet
//        }
//         // Confirmation alert for swipe deletion
//         .alert("Delete Word?", isPresented: Binding(
//             get: { wordToDelete != nil },
//             set: { if !$0 { wordToDelete = nil } } // Clear on dismiss
//         ), presenting: wordToDelete) { entryToDelete in
//              Button("Delete '\(entryToDelete.word)'", role: .destructive) {
//                   dictionaryManager.removeWord(entry: entryToDelete)
//                   wordToDelete = nil
//              }
//              Button("Cancel", role: .cancel) {
//                   wordToDelete = nil
//              }
//         } message: { entryToDelete in
//              Text("Are you sure you want to delete the word '\(entryToDelete.word)'? This cannot be undone.")
//         }
//    }
//
//    // Required for List's onDelete modifier
//    private func deleteWordFromList(at offsets: IndexSet) {
//         // If you need confirmation here too, you'd need a more complex setup
//         // For simplicity, this directly calls the remove function.
//         // Consider using swipe actions with confirmation instead for better UX.
//         print("[Dict Manage] onDelete modifier called for offsets: \(offsets)")
//         dictionaryManager.removeWord(at: offsets)
//     }
//}
//
//// MARK: - Add Word View (Simple Sheet)
//
//struct AddWordView: View {
//    @EnvironmentObject var dictionaryManager: CustomDictionaryManager
//    @Environment(\.dismiss) var dismiss // To close the sheet
//
//    @State private var newWord: String = ""
//    @State private var selectedDialects: Set<DialectTag> = [.universal]
//    @State private var selectedVocabType: VocabularyType = .userAdded
//    @State private var notes: String = ""
//
//    // Simple validation
//    var isWordValid: Bool {
//        !newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//    }
//
//    var body: some View {
//        NavigationView { // Embed in NavigationView for title and buttons
//            Form {
//                Section("New Word Details") {
//                    TextField("Word", text: $newWord)
//                         .autocorrectionDisabled() // Often desired for dictionary input
//
//                    // Multi-selector for Dialects (Example using simple buttons)
//                     VStack(alignment: .leading) {
//                         Text("Dialect(s)")
//                         ScrollView(.horizontal, showsIndicators: false) {
//                             HStack {
//                                 ForEach(DialectTag.allCases) { dialect in
//                                     Button {
//                                         toggleDialect(dialect)
//                                     } label: {
//                                         Text(dialect.rawValue)
//                                             .padding(.horizontal, 10)
//                                             .padding(.vertical, 5)
//                                             .background(selectedDialects.contains(dialect) ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
//                                             .foregroundColor(.white)
//                                             .cornerRadius(8)
//                                     }
//                                 }
//                             }
//                         }
//                     }
//
//
//                    Picker("Vocabulary Type", selection: $selectedVocabType) {
//                        ForEach(VocabularyType.allCases) { type in
//                            Text(type.rawValue).tag(type)
//                        }
//                    }
//
//                    TextField("Notes (Optional)", text: $notes, axis: .vertical)
//                        .lineLimit(3...)
//                }
//            }
//            .navigationTitle("Add Custom Word")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Add") {
//                        addAndDismiss()
//                    }
//                    .disabled(!isWordValid) // Disable if word is empty
//                }
//            }
//        }
//    }
//
//    private func toggleDialect(_ dialect: DialectTag) {
//         if selectedDialects.contains(dialect) {
//              // Ensure at least one dialect remains, defaulting to universal if needed
//              if selectedDialects.count > 1 {
//                  selectedDialects.remove(dialect)
//              } else if dialect != .universal { // Prevent removing the last non-universal tag if universal isn't selected
//                selectedDialects.remove(dialect)
//                selectedDialects.insert(.universal) // Add universal back if it was the only one left
//            }
//              // If only universal is selected, don't allow removing it this way
//         } else {
//             selectedDialects.insert(dialect)
//             // Optional: If adding a specific dialect, remove universal if desired
//             if dialect != .universal && selectedDialects.contains(.universal) && selectedDialects.count > 1 {
//                 selectedDialects.remove(.universal)
//             }
//         }
//         // Ensure universal is present if set is empty after toggle logic
//         if selectedDialects.isEmpty {
//              selectedDialects.insert(.universal)
//         }
//     }
//
//
//    private func addAndDismiss() {
//        guard isWordValid else { return }
//        let entry = DictionaryEntry(
//            word: newWord.trimmingCharacters(in: .whitespacesAndNewlines),
//            dialectTags: Array(selectedDialects),
//            vocabType: selectedVocabType,
//            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
//        )
//        dictionaryManager.addWord(entry)
//        dismiss()
//    }
//}
//
//
//// MARK: - Preview Providers
//
//struct VietnameseInputSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            VietnameseInputSettingsView()
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//
//struct ManageCustomDictionaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ManageCustomDictionaryView()
//                .environmentObject(CustomDictionaryManager()) // Provide a manager for preview
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//
//struct AddWordView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddWordView()
//            .environmentObject(CustomDictionaryManager()) // Provide manager for preview
//            .preferredColorScheme(.dark)
//    }
//}
