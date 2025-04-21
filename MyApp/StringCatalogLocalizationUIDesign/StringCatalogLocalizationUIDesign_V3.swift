////
////  StringCatalogLocalizationUIDesign_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/20/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models (Enhanced)
//
//// Represents a single localizable string entry, now mutable for state changes
//struct LocalizableStringEntry: Identifiable, Hashable {
//    let id = UUID() // Keep immutable for Identifiable stability
//    let key: String
//    var defaultValue: String // Can be edited? Potentially, but keep simple for now.
//    var comment: String?
//    var state: StringState
//    var translations: [String: String] // Language Code -> Translation (e.g., "pt", "uk")
//    var pluralForms: [String: String]? // e.g., ["one": "1 item", "other": "%lld items"]
//    var deviceVariations: [String: String]? // e.g., ["mac": "Click Here", "iphone": "Tap Here"]
//
//    // Helper to check if variations exist
//    var hasVariations: Bool {
//        (pluralForms != nil && !pluralForms!.isEmpty) || (deviceVariations != nil && !deviceVariations!.isEmpty)
//    }
//}
//
//// Represents the different states a string can be in
//enum StringState: String, CaseIterable, Identifiable, Comparable {
//    case new = "New"
//    case needsReview = "Needs Review"
//    case stale = "Stale"
//    case reviewed = "Reviewed"
//
//    var id: String { self.rawValue }
//
//    var icon: String {
//        switch self {
//        case .new: return "circle.dashed" // Empty circle often used for 'new'
//        case .needsReview: return "exclamationmark.triangle.fill"
//        case .stale: return "trash.fill"
//        case .reviewed: return "checkmark.circle.fill"
//        }
//    }
//
//    var color: Color {
//        switch self {
//        case .new: return .gray
//        case .needsReview: return .orange
//        case .stale: return .red
//        case .reviewed: return .green
//        }
//    }
//
//    // For Sorting by State
//    private var sortOrder: Int {
//        switch self {
//        case .needsReview: return 0 // Priority
//        case .new: return 1
//        case .reviewed: return 2
//        case .stale: return 3
//        }
//    }
//
//    static func < (lhs: StringState, rhs: StringState) -> Bool {
//        lhs.sortOrder < rhs.sortOrder
//    }
//}
//
//// Sorting options
//enum SortOption: String, CaseIterable, Identifiable {
//    case keyAscending = "Key (A-Z)"
//    case keyDescending = "Key (Z-A)"
//    case state = "State (Needs Review First)"
//    case defaultValue = "Default Value"
//
//    var id: String { self.rawValue }
//}
//
//// MARK: - Main Interactive View
//
//struct InteractiveStringCatalogView: View {
//
//    // --- State Variables ---
//    @State private var stringEntries: [LocalizableStringEntry] = sampleData // Main data source
//    @State private var filterText: String = ""
//    @State private var selectedStateFilter: StringState? = nil
//    @State private var sortOrder: SortOption = .state
//    @State private var showingAddSheet = false
//    @State private var showingVariationsSheetFor: LocalizableStringEntry? = nil
//    @State private var showingWorkflowAlert: (title: String, message: String)? = nil
//
//    // --- Computed Properties ---
//    private var filteredAndSortedEntries: [LocalizableStringEntry] {
//        // 1. Filter by Text
//        let textFiltered = stringEntries.filter { entry in
//            filterText.isEmpty ||
//            entry.key.localizedCaseInsensitiveContains(filterText) ||
//            entry.defaultValue.localizedCaseInsensitiveContains(filterText) ||
//            (entry.comment?.localizedCaseInsensitiveContains(filterText) ?? false)
//        }
//
//        // 2. Filter by State
//        let stateFiltered = textFiltered.filter { entry in
//            selectedStateFilter == nil || entry.state == selectedStateFilter
//        }
//
//        // 3. Sort
//        return stateFiltered.sorted { lhs, rhs in
//            switch sortOrder {
//            case .keyAscending:
//                return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
//            case .keyDescending:
//                return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedDescending
//            case .state:
//                if lhs.state != rhs.state {
//                    return lhs.state < rhs.state // Use Comparable conformance
//                } else {
//                    // Secondary sort by key if states are equal
//                    return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
//                }
//            case .defaultValue:
//                return lhs.defaultValue.localizedCaseInsensitiveCompare(rhs.defaultValue) == .orderedAscending
//            }
//        }
//    }
//
//    private var progressSummary: String {
//        let total = stringEntries.count
//        guard total > 0 else { return "No Strings" }
//        let reviewedCount = stringEntries.filter { $0.state == .reviewed }.count
//        let percentage = Int((Double(reviewedCount) / Double(total)) * 100)
//        return "\(percentage)% Reviewed (\(reviewedCount)/\(total))"
//    }
//
//    // --- Body ---
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                FilterSortControls(
//                    filterText: $filterText,
//                    selectedStateFilter: $selectedStateFilter,
//                    sortOrder: $sortOrder,
//                    progressSummary: progressSummary
//                )
//
//                List {
//                    // --- Dynamic Catalog Entries ---
//                    Section("Catalog Entries") {
//                        if filteredAndSortedEntries.isEmpty {
//                            Text("No matching strings found.")
//                                .foregroundColor(.secondary)
//                                .padding()
//                        } else {
//                            ForEach(filteredAndSortedEntries) { entry in
//                                StringEntryRow(entry: entry)
//                                    .onTapGesture {
//                                        // Optional: Show detail on tap if needed
//                                    }
//                                    .onLongPressGesture {
//                                        // Show variations on long press if they exist
//                                        if entry.hasVariations {
//                                            showingVariationsSheetFor = entry
//                                        }
//                                    }
//                                    .contextMenu {
//                                        // State Change Actions
//                                        ForEach(StringState.allCases) { state in
//                                            if entry.state != state {
//                                                Button {
//                                                    updateState(for: entry.id, to: state)
//                                                } label: {
//                                                    Label(state.rawValue, systemImage: state.icon)
//                                                }
//                                            }
//                                        }
//                                        Divider()
//                                        // Variations Action (alternative access)
//                                        if entry.hasVariations {
//                                            Button {
//                                                showingVariationsSheetFor = entry
//                                            } label: {
//                                                Label("View Variations", systemImage: "list.bullet.indent")
//                                            }
//                                        }
//                                        // Simulate "Mark as Stale" (Delete)
//                                        Button(role: .destructive) {
//                                             updateState(for: entry.id, to: .stale) // Or actually remove
//                                        } label: {
//                                             Label("Mark as Stale", systemImage: StringState.stale.icon)
//                                        }
//                                    }
//                             }
//                        }
//                    } // End Section: Catalog Entries
//
//                    // --- Static Explanatory Sections (Collapsed for brevity) ---
//                    DisclosureGroup("Core Concept") {
//                        StaticCoreConceptView()
//                    }
//                    DisclosureGroup("Sources of Strings") {
//                        StaticSourcesView()
//                    }
//                    DisclosureGroup("Editor Features Explained") {
//                        StaticEditorFeaturesView()
//                    }
//                     DisclosureGroup("Workflow") {
//                        StaticWorkflowView(
//                            exportAction: { simulateWorkflowAction(title: "Export Simulated", message: "Generated hypothetical .xloc file for translation.") },
//                            importAction: { simulateWorkflowAction(title: "Import Simulated", message: "Processed hypothetical translated .xliff file.") }
//                        )
//                    }
//                    DisclosureGroup("Adoption & Migration") {
//                           StaticAdoptionView(
//                              migrateAction: { simulateWorkflowAction(title: "Migration Simulated", message: "Simulated scanning for .strings files and converting them to the catalog.") }
//                          )
//                    }
//
//                } // End List
//                .listStyle(.plain) // Use plain style for tighter controls
//            }
//            .navigationTitle("String Catalog")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        showingAddSheet = true
//                    } label: {
//                        Label("Add String", systemImage: "plus")
//                    }
//                }
//            }
//            // --- Sheets and Alerts ---
//            .sheet(isPresented: $showingAddSheet) {
//                AddStringView(stringEntries: $stringEntries)
//            }
//            .sheet(item: $showingVariationsSheetFor) { entry in
//                VariationsDetailView(entry: entry)
//            }
////            .alert(item: $showingWorkflowAlert) { alertInfo in
////                Alert(title: Text(alertInfo.title), message: Text(alertInfo.message), dismissButton: .default(Text("OK")))
////            }
//        }
//    }
//
//    // --- Action Functions ---
//    private func updateState(for id: UUID, to newState: StringState) {
//        if let index = stringEntries.firstIndex(where: { $0.id == id }) {
//            stringEntries[index].state = newState
//        }
//    }
//
//    private func simulateWorkflowAction(title: String, message: String) {
//         showingWorkflowAlert = (title: title, message: message)
//    }
//}
//
//// MARK: - Helper Views
//
//// MARK: Filters and Sorting UI
//struct FilterSortControls: View {
//    @Binding var filterText: String
//    @Binding var selectedStateFilter: StringState?
//    @Binding var sortOrder: SortOption
//    let progressSummary: String
//
//    var body: some View {
//        VStack(spacing: 5) {
//            // Search Field
//            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.secondary)
//                TextField("Filter by Key, Value, Comment...", text: $filterText)
//                    .textFieldStyle(.plain).padding(.vertical, 4)
//                if !filterText.isEmpty {
//                    Button {
//                        filterText = ""
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.secondary)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 6)
//            .background(Color(.systemGray6))
//            .cornerRadius(8)
//            .padding(.horizontal)
//            .padding(.top, 8)
//
//            // State Filter & Sort Options
//            HStack {
//                // State Filter Menu
//                Menu {
//                    Button("All States") { selectedStateFilter = nil }
//                    ForEach(StringState.allCases) { state in
//                        Button { selectedStateFilter = state } label: {
//                            Label(state.rawValue, systemImage: state.icon)
//                        }
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: selectedStateFilter?.icon ?? "line.3.horizontal.decrease.circle")
//                            .foregroundColor(selectedStateFilter?.color ?? .secondary)
//                        Text(selectedStateFilter?.rawValue ?? "All States")
//                        Image(systemName: "chevron.down") // Indicate dropdown
//                            .imageScale(.small)
//                    }
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .padding(.vertical, 4)
//                    .padding(.horizontal, 8)
//                    .background(Color(.systemGray5))
//                    .clipShape(Capsule())
//                }
//
//                Spacer()
//
//                // Sort Order Menu
//                Menu {
//                    ForEach(SortOption.allCases) { option in
//                        Button(option.rawValue) { sortOrder = option }
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: "arrow.up.arrow.down.circle")
//                        Text("Sort: \(sortOrder.rawValue)")
//                         Image(systemName: "chevron.down")
//                             .imageScale(.small)
//                    }
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .padding(.vertical, 4)
//                    .padding(.horizontal, 8)
//                     .background(Color(.systemGray5))
//                    .clipShape(Capsule())
//                 }
//            }
//            .padding(.horizontal)
//
//            // Progress Summary
//            Text(progressSummary)
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .padding(.bottom, 8)
//
//             Divider()
//        }
//        .padding(.bottom, 5)
//    }
//}
//
//// MARK: Display Row for a String Entry
//struct StringEntryRow: View {
//    let entry: LocalizableStringEntry
//
//    var body: some View {
//        HStack(alignment: .top) {
//            Image(systemName: entry.state.icon)
//                .foregroundColor(entry.state.color)
//                .font(.title3)
//                .frame(width: 25) // Align icons vertically
//
//            VStack(alignment: .leading, spacing: 3) {
//                HStack {
//                    Text(entry.key).font(.headline).lineLimit(1)
//                    if entry.hasVariations {
//                         Image(systemName: "list.bullet.indent")
//                              .foregroundColor(.accentColor)
//                              .imageScale(.small)
//                    }
//                }
//                Text("\"\(entry.defaultValue)\"")
//                    .font(.subheadline)
//                    .foregroundColor(.primary)
//                    .lineLimit(2)
//                if let comment = entry.comment, !comment.isEmpty {
//                    Text("Comment: \(comment)").font(.caption).italic().foregroundColor(.gray)
//                }
//
//                // Simple translation display (optional)
//                if !entry.translations.isEmpty {
//                     HStack(spacing: 4) {
//                         ForEach(entry.translations.keys.sorted(), id: \.self) { langCode in
//                             Text(langCode.uppercased())
//                                 .font(.caption2)
//                                 .padding(.horizontal, 4)
//                                 .background(Color.blue.opacity(0.2))
//                                 .clipShape(Capsule())
//                         }
//                     }
//                     .padding(.top, 2)
//                }
//            }
//             Spacer() // Push content to the left
//        }
//        .padding(.vertical, 6)
//    }
//}
//
//// MARK: Sheet for Adding a New String
//struct AddStringView: View {
//    @Environment(\.dismiss) var dismiss
//    @Binding var stringEntries: [LocalizableStringEntry]
//
//    @State private var newKey: String = ""
//    @State private var newDefaultValue: String = ""
//    @State private var newComment: String = ""
//
//    var canAdd: Bool {
//        !newKey.trimmingCharacters(in: .whitespaces).isEmpty &&
//        !newDefaultValue.trimmingCharacters(in: .whitespaces).isEmpty &&
//        // Ensure key doesn't already exist (case sensitive check is fine here)
//        !stringEntries.contains(where: { $0.key == newKey.trimmingCharacters(in: .whitespaces) })
//    }
//
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Unique Key (e.g., Settings.Title)", text: $newKey)
//                     .autocorrectionDisabled()
//                    .textInputAutocapitalization(.never) // Keys are often specific case
//                TextField("Default Value (English)", text: $newDefaultValue)
//                TextField("Comment for Translator (Optional)", text: $newComment)
//
//                if !canAdd && !newKey.isEmpty && stringEntries.contains(where: { $0.key == newKey.trimmingCharacters(in: .whitespaces) }) {
//                     Text("Key already exists in the catalog.")
//                         .font(.caption)
//                         .foregroundColor(.red)
//                 }
//            }
//            .navigationTitle("Add Manual String")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Add") {
//                        addString()
//                        dismiss()
//                    }
//                    .disabled(!canAdd)
//                }
//            }
//        }
//    }
//
//    private func addString() {
//        guard canAdd else { return }
//        let entry = LocalizableStringEntry(
//            key: newKey.trimmingCharacters(in: .whitespaces),
//            defaultValue: newDefaultValue,
//            comment: newComment.isEmpty ? nil : newComment,
//            state: .new, // Manually added strings start as 'New'
//            translations: [:],
//            pluralForms: nil,
//            deviceVariations: nil
//        )
//        stringEntries.append(entry)
//    }
//}
//
//// MARK: Sheet for Viewing Variations
//struct VariationsDetailView: View {
//     @Environment(\.dismiss) var dismiss
//     let entry: LocalizableStringEntry
//
//     var body: some View {
//         NavigationView {
//             List {
//                 Section("Base String") {
//                     Text("Key: \(entry.key)").font(.headline)
//                     Text("Default: \"\(entry.defaultValue)\"")
//                     if let comment = entry.comment {
//                         Text("Comment: \(comment)").italic().foregroundColor(.gray)
//                     }
//                 }
//
//                 if let plurals = entry.pluralForms, !plurals.isEmpty {
//                      Section("Plural Variations") {
//                          ForEach(plurals.keys.sorted(), id: \.self) { category in
//                              HStack {
//                                  Text(category.capitalized)
//                                      .font(.caption)
//                                      .padding(.horizontal, 6)
//                                      .background(Color.teal.opacity(0.2))
//                                      .clipShape(Capsule())
//                                  Spacer()
//                                  Text("\"\(plurals[category]!)\"")
//                              }
//                          }
//                      }
//                 }
//
//                  if let devices = entry.deviceVariations, !devices.isEmpty {
//                      Section("Device Variations") {
//                          ForEach(devices.keys.sorted(), id: \.self) { category in
//                              HStack {
//                                  Text(category.capitalized)
//                                      .font(.caption)
//                                      .padding(.horizontal, 6)
//                                      .background(Color.indigo.opacity(0.2))
//                                      .clipShape(Capsule())
//                                  Spacer()
//                                  Text("\"\(devices[category]!)\"")
//                              }
//                          }
//                      }
//                 }
//
//                 if !entry.hasVariations {
//                      Text("No variations defined for this string.")
//                          .foregroundColor(.secondary)
//                  }
//             }
//             .navigationTitle("String Variations")
//             .toolbar {
//                   ToolbarItem(placement: .navigationBarTrailing) {
//                       Button("Done") { dismiss() }
//                   }
//               }
//         }
//     }
// }
//
// // MARK: - Static Explanatory Views (Placeholders)
// // Placeholder views for the static content from the previous example
// struct StaticCoreConceptView: View {
//      var body: some View {
//           VStack(alignment: .leading) {
//              FeatureRow(icon: "doc.text.fill", color: .blue, title: "String Catalog (.xcstrings)", description: "Centralized file replacing .strings and .stringsdict. Manages all localizable strings and translations. JSON-based and source-control friendly.")
//              FeatureRow(icon: "arrow.triangle.2.circlepath.circle.fill", color: .green, title: "Automatic Sync", description: "Xcode automatically extracts strings from code, IB, and plists during build, keeping the catalog up-to-date.")
//              FeatureRow(icon: "text.magnifyingglass", color: .purple, title: "Confidence", description: "Easily track translation progress and identify missing or outdated translations before shipping.")
//          }.padding(.vertical)
//      } }
// struct StaticSourcesView: View {
//     var body: some View {
//           VStack(alignment: .leading) {
//             SourceRow(icon: "swift", title: "SwiftUI", example: "Text(\"Hello, SwiftUI!\")")
//             SourceRow(icon: "curlybraces", title: "Swift", example: "String(localized: \"MyModelString\")")
//             SourceRow(icon: "curlybraces.square.fill", title: "Objective-C / C", example: "NSLocalizedString(@\"ObjCString\", ...)")
//             SourceRow(icon: "hammer.fill", title: "Interface Builder", example: "UILabel text set in .xib/.storyboard")
//             SourceRow(icon: "list.bullet", title: "Info.plist", example: "NSHumanReadableCopyright")
//             SourceRow(icon: "square.grid.3x3.fill", title: "App Shortcuts", example: "Phrases for App Intents")
//          }.padding(.vertical)
//     } }
// struct StaticEditorFeaturesView: View {
//     var body: some View {
//         VStack(alignment: .leading) {
//             Text("State Tracking Demonstrated Above").font(.headline).padding(.bottom, 5)
//             HStack(spacing: 15) { ForEach(StringState.allCases) { state in VStack { Image(systemName: state.icon).foregroundColor(state.color).font(.title3); Text(state.rawValue).font(.caption) } } }
//             Divider().padding(.vertical)
//             FeatureRow(icon: "display.2", color: .indigo, title: "Vary by Device", description: "Provide different text for different platforms (e.g., 'Click' on Mac, 'Tap' on iOS).")
//             FeatureRow(icon: "textformat.123", color: .teal, title: "Vary by Plural", description: "Handle singular, plural, and language-specific grammatical cases.")
//             CodeSnippetView(code: """
//             "ItemCount": {
//               "one": "1 item",
//               "other": "%lld items" // @_@lld@ for argument
//             }
//             """)
//             FeatureRow(icon: "slider.horizontal.3", color: .gray, title: "Filtering & Sorting", description: "Implemented above for dynamic searching and ordering.")
//             FeatureRow(icon: "plus.circle.fill", color: .green, title: "Manual Strings", description: "Use the '+' button to add strings not found in code.")
//        }.padding(.vertical)
//     }
// }
// struct StaticWorkflowView: View {
//      var exportAction: () -> Void
//     var importAction: () -> Void
//      var body: some View {
//          VStack(alignment: .leading) {
//             Button { exportAction() } label: { FeatureRow(icon: "square.and.arrow.up.fill", color: .orange, title: "Export Localizations", description: "Generate Localization Catalogs (.xloc) containing XLIFF files for translators.") }
//             Button { importAction() } label: { FeatureRow(icon: "square.and.arrow.down.fill", color: .orange, title: "Import Localizations", description: "Import translated XLIFF files back into the String Catalog.") }
//             FeatureRow(icon: "percent", color: .blue, title: "Progress Tracking", description: "Summary shown above the list.")
//         }.buttonStyle(.plain).padding(.vertical)
//      } }
// struct StaticAdoptionView: View {
//     var migrateAction: () -> Void
//     var body: some View {
//         VStack(alignment: .leading) {
//             FeatureRow(icon: "arrow.triangle.branch", color: .purple, title: "Coexistence", description: "String Catalogs can exist alongside legacy .strings/.stringsdict files.")
//             Button { migrateAction() } label: { FeatureRow(icon: "wand.and.rays", color: .yellow, title: "Migration Assistant", description: "Xcode can convert existing .strings/.stringsdict.") }
//             FeatureRow(icon: "shippingbox.fill", color: .brown, title: "New Projects/Packages", description: "Simple setup for localizing new projects or Swift Packages.")
//         }.buttonStyle(.plain).padding(.vertical)
//      } }
//
// // MARK: - Sample Data
//
//let sampleData: [LocalizableStringEntry] = [
//    .init(key: "WelcomeMessage", defaultValue: "Welcome to My App!", comment: "Greeting shown on the main screen.", state: .reviewed, translations: ["pt": "Bem-vindo ao Meu App!", "uk": "Ласкаво просимо до Мого Додатку!", "fr": "Bienvenue sur Mon App !"]),
//    .init(key: "TapToLearnMore", defaultValue: "Tap to learn more.", comment: "Instructional text on a button.", state: .needsReview, translations: ["pt": "Toque para saber mais.", "uk": "Натисніть, щоб дізнатися більше."]),
//    .init(key: "Settings.Title", defaultValue: "Settings", comment: "Title for the settings screen", state: .reviewed, translations: ["pt": "Configurações", "uk": "Налаштування"]),
//    .init(key: "Done", defaultValue: "Done", comment: "A common confirmation button label", state: .reviewed, translations: ["pt": "Feito", "uk": "Готово"]),
//    .init(key: "Cancel", defaultValue: "Cancel", comment: "A common cancellation button label", state: .reviewed, translations: ["pt": "Cancelar", "uk": "Скасувати"]),
//    .init(key: "ItemCount", defaultValue: "%lld items", comment: "Displays a count of items", state: .new, translations: [:], pluralForms: ["one": "1 item", "other": "%lld items"]),
//    .init(key: "DeleteConfirmation.Title", defaultValue: "Delete Item?", comment: "Alert title for deleting", state: .needsReview, translations: ["pt": "Excluir Item?"]),
//    .init(key: "DeleteConfirmation.Message", defaultValue: "Are you sure you want to permanently delete this item?", comment: "Alert message for deleting", state: .needsReview, translations: ["pt": "Tem certeza de que deseja excluir permanentemente este item?"]),
//    .init(key: "SubmitAction", defaultValue: "Submit", comment: "Button to submit a form", state: .new, translations: [:], deviceVariations: ["mac": "Submit Form", "iphone": "Send"]),
//    .init(key: "OldFeatureString", defaultValue: "Use the old feature.", comment: "String related to a removed feature.", state: .stale, translations: ["pt": "Use o recurso antigo.", "uk": "Використовуйте стару функцію."]),
//    .init(key: "Profile.EditButton", defaultValue: "Edit Profile", comment: "Button to navigate to profile editing", state: .reviewed, translations: ["uk": "Редагувати профіль"]),
//    .init(key: "NetworkError", defaultValue: "Could not connect to server.", comment: "Generic network error message", state: .new, translations: [:])
//]
//
//// MARK: - Reusable Components (from previous example)
//
//// Helper View for consistent feature rows
//struct FeatureRow: View { /* unchanged */
//    let icon: String; let color: Color; let title: String; let description: String
//    var body: some View { HStack(alignment: .top, spacing: 15) { Image(systemName: icon).font(.title3).foregroundColor(color).frame(width: 30); VStack(alignment: .leading) { Text(title).font(.headline); Text(description).font(.subheadline).foregroundColor(.gray) } }.padding(.vertical, 3) }
//}
//// Helper View for showing code source rows
//struct SourceRow: View { /* unchanged */
//    let icon: String; let title: String; let example: String
//    var body: some View { HStack(alignment: .top) { Image(systemName: icon).font(.title3).foregroundColor(.secondary).frame(width: 25); VStack(alignment: .leading) { Text(title).font(.body); Text(example).font(.caption.monospaced()).foregroundColor(.gray).padding(.top, 1) } }.padding(.vertical, 4) }
//}
//// Helper View for displaying code snippets
//struct CodeSnippetView: View { /* unchanged */
//    let code: String
//    var body: some View { Text(code).font(.caption.monospaced()).foregroundColor(.secondary).padding(8).background(Color.gray.opacity(0.1)).cornerRadius(6).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4) }
//}
//
//// Wrapper type for alert identifiable
//struct AlertInfo: Identifiable {
//    let id = UUID()
//    let title: String
//    let message: String
//}
//// Extend tuple to be identifiable (if used directly with .alert(item:))
//extension Optional where Wrapped == (title: String, message: String) {
//    var alertInfo: AlertInfo? {
//        guard let self = self else { return nil }
//        return AlertInfo(title: self.title, message: self.message)
//    }
//}
//
//extension Optional: @retroactive Identifiable where Wrapped == (title: String, message: String) {
//     public var id: String {
//         self?.title ?? "" // Simple identifiable based on title
//     }
// }
//
//// MARK: - Preview Provider
//
//struct InteractiveStringCatalogView_Previews: PreviewProvider {
//    static var previews: some View {
//        InteractiveStringCatalogView()
//    }
//}
