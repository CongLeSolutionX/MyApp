//
//  StringCatalogLocalizationUIDesign_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/20/25.
//

import SwiftUI

// MARK: - Data Models (Enhanced) - Unchanged
struct LocalizableStringEntry: Identifiable, Hashable {
    let id = UUID()
    let key: String
    var defaultValue: String
    var comment: String?
    var state: StringState
    var translations: [String: String] // Language Code -> Translation (e.g., "pt", "uk", "vi")
    var pluralForms: [String: String]?
    var deviceVariations: [String: String]?

    var hasVariations: Bool {
        (pluralForms != nil && !pluralForms!.isEmpty) || (deviceVariations != nil && !deviceVariations!.isEmpty)
    }
}

enum StringState: String, CaseIterable, Identifiable, Comparable {
    // ... (cases, icon, color, sortOrder, Comparable conformance remain the same)
    case new = "New"
    case needsReview = "Needs Review"
    case stale = "Stale"
    case reviewed = "Reviewed"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .new: return "circle.dashed"
        case .needsReview: return "exclamationmark.triangle.fill"
        case .stale: return "trash.fill"
        case .reviewed: return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .new: return .gray
        case .needsReview: return .orange
        case .stale: return .red
        case .reviewed: return .green
        }
    }

    private var sortOrder: Int {
        switch self {
        case .needsReview: return 0
        case .new: return 1
        case .reviewed: return 2
        case .stale: return 3
        }
    }

    static func < (lhs: StringState, rhs: StringState) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    // ... (cases remain the same)
    case keyAscending = "Key (A-Z)"
    case keyDescending = "Key (Z-A)"
    case state = "State (Needs Review First)"
    case defaultValue = "Default Value"

    var id: String { self.rawValue }
}

// MARK: - Main Interactive View - Unchanged
struct InteractiveStringCatalogView: View {
    // ... (State, Computed Properties, Body, Action Functions remain the same)
    @State private var stringEntries: [LocalizableStringEntry] = sampleData // Main data source
    @State private var filterText: String = ""
    @State private var selectedStateFilter: StringState? = nil
    @State private var sortOrder: SortOption = .state
    @State private var showingAddSheet = false
    @State private var showingVariationsSheetFor: LocalizableStringEntry? = nil
    @State private var showingWorkflowAlert: AlertInfo? = nil // Use AlertInfo

    // --- Computed Properties ---
    private var filteredAndSortedEntries: [LocalizableStringEntry] {
         // ... (Filtering and Sorting logic remains the same)
        // 1. Filter by Text
        let textFiltered = stringEntries.filter { entry in
            filterText.isEmpty ||
            entry.key.localizedCaseInsensitiveContains(filterText) ||
            entry.defaultValue.localizedCaseInsensitiveContains(filterText) ||
            (entry.comment?.localizedCaseInsensitiveContains(filterText) ?? false) ||
            // Also filter by translation values
            entry.translations.values.contains { $0.localizedCaseInsensitiveContains(filterText) }
        }

        // 2. Filter by State
        let stateFiltered = textFiltered.filter { entry in
            selectedStateFilter == nil || entry.state == selectedStateFilter
        }

        // 3. Sort
        return stateFiltered.sorted { lhs, rhs in
            switch sortOrder {
            case .keyAscending:
                return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
            case .keyDescending:
                return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedDescending
            case .state:
                if lhs.state != rhs.state {
                    return lhs.state < rhs.state // Use Comparable conformance
                } else {
                    // Secondary sort by key if states are equal
                    return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
                }
            case .defaultValue:
                return lhs.defaultValue.localizedCaseInsensitiveCompare(rhs.defaultValue) == .orderedAscending
            }
        }
    }

    private var progressSummary: String {
        // ... (Progress calculation remains the same)
       let total = stringEntries.count
        guard total > 0 else { return "No Strings" }
        let reviewedCount = stringEntries.filter { $0.state == .reviewed }.count
        let percentage = Int((Double(reviewedCount) / Double(total)) * 100)
        return "\(percentage)% Reviewed (\(reviewedCount)/\(total))"
    }

    var body: some View {
        // --- Navigation ---
        NavigationView {
            VStack(spacing: 0) {
                FilterSortControls(
                    filterText: $filterText,
                    selectedStateFilter: $selectedStateFilter,
                    sortOrder: $sortOrder,
                    progressSummary: progressSummary
                )

                List {
                     // --- Dynamic Entries ---
                     Section("Catalog Entries") {
                         if filteredAndSortedEntries.isEmpty {
                              Text("No matching strings found.") // Add translation if needed for the app UI itself
                                  .foregroundColor(.secondary)
                                  .padding()
                         } else {
                             ForEach(filteredAndSortedEntries) { entry in
                                 StringEntryRow(entry: entry)
                                    .onTapGesture { /* Optional action */ }
                                    .onLongPressGesture { if entry.hasVariations { showingVariationsSheetFor = entry } }
                                     .contextMenu {
                                         // State Change Actions
                                         ForEach(StringState.allCases) { state in
                                             if entry.state != state {
                                                 Button { updateState(for: entry.id, to: state) } label: { Label(state.rawValue, systemImage: state.icon) }
                                             }
                                         }
                                         Divider()
                                         if entry.hasVariations {
                                             Button { showingVariationsSheetFor = entry } label: { Label("View Variations", systemImage: "list.bullet.indent") }
                                         }
                                         Button(role: .destructive) { updateState(for: entry.id, to: .stale) } label: { Label("Mark as Stale", systemImage: StringState.stale.icon) }
                                     }
                             } // End ForEach
                         } // End Else
                     } // End Section: Catalog Entries

                     // --- Static Sections ---
                    DisclosureGroup("Core Concept") { StaticCoreConceptView() }
                    DisclosureGroup("Sources of Strings") { StaticSourcesView() }
                    DisclosureGroup("Editor Features Explained") { StaticEditorFeaturesView() }
                    DisclosureGroup("Workflow") {
                        StaticWorkflowView(
                             exportAction: { simulateWorkflowAction(title: "Export Simulated", message: "Generated hypothetical .xloc file for translation.") },
                             importAction: { simulateWorkflowAction(title: "Import Simulated", message: "Processed hypothetical translated .xliff file.") }
                         )
                    }
                     DisclosureGroup("Adoption & Migration") {
                        StaticAdoptionView(
                           migrateAction: { simulateWorkflowAction(title: "Migration Simulated", message: "Simulated scanning for .strings files and converting them to the catalog.") }
                       )
                     }

                 } // End List
                 .listStyle(.plain)
            } // End VStack
            .navigationTitle("String Catalog") // Needs localization if app UI is localized
            .toolbar {
                   ToolbarItem(placement: .navigationBarTrailing) {
                       Button { showingAddSheet = true } label: { Label("Add String", systemImage: "plus") }
                   }
               }
            .sheet(isPresented: $showingAddSheet) {
                   AddStringView(stringEntries: $stringEntries)
               }
            .sheet(item: $showingVariationsSheetFor) { entry in
                   VariationsDetailView(entry: entry)
               }
            .alert(item: $showingWorkflowAlert) { alertInfo in // Use the item modifier with AlertInfo
                 Alert(title: Text(alertInfo.title), message: Text(alertInfo.message), dismissButton: .default(Text("OK")))
             }
        } // End NavigationView
    }

    // --- Action Functions ---
  private func updateState(for id: UUID, to newState: StringState) { /* ... unchanged */
        if let index = stringEntries.firstIndex(where: { $0.id == id }) {
            stringEntries[index].state = newState
        }
    }

    private func simulateWorkflowAction(title: String, message: String) { /* ... unchanged */
         showingWorkflowAlert = AlertInfo(title: title, message: message) // Create AlertInfo
    }
}

// MARK: - Helper Views - Unchanged
struct FilterSortControls: View { /* ... unchanged */
     @Binding var filterText: String
     @Binding var selectedStateFilter: StringState?
     @Binding var sortOrder: SortOption
     let progressSummary: String
     // Body remains the same
     var body: some View {
         VStack(spacing: 5) {
             HStack { /* Search Field */
                 Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                 TextField("Filter by Key, Value, Comment...", text: $filterText) // Localize placeholder if UI is localized
                     .textFieldStyle(.plain).padding(.vertical, 4)
                 if !filterText.isEmpty { Button { filterText = "" } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.secondary) }.buttonStyle(.plain) }
             }.padding(.horizontal).padding(.vertical, 6).background(Color(.systemGray6)).cornerRadius(8).padding(.horizontal).padding(.top, 8)

             HStack { /* State & Sort Menus */
                 Menu { Button("All States") { selectedStateFilter = nil }; ForEach(StringState.allCases) { state in Button { selectedStateFilter = state } label: { Label(state.rawValue, systemImage: state.icon) } } } label: { HStack { Image(systemName: selectedStateFilter?.icon ?? "line.3.horizontal.decrease.circle").foregroundColor(selectedStateFilter?.color ?? .secondary); Text(selectedStateFilter?.rawValue ?? "All States"); Image(systemName: "chevron.down").imageScale(.small) }.font(.caption).foregroundColor(.secondary).padding(.vertical, 4).padding(.horizontal, 8).background(Color(.systemGray5)).clipShape(Capsule()) }
                 Spacer()
                 Menu { ForEach(SortOption.allCases) { option in Button(option.rawValue) { sortOrder = option } } } label: { HStack { Image(systemName: "arrow.up.arrow.down.circle"); Text("Sort: \(sortOrder.rawValue)"); Image(systemName: "chevron.down").imageScale(.small) }.font(.caption).foregroundColor(.secondary).padding(.vertical, 4).padding(.horizontal, 8).background(Color(.systemGray5)).clipShape(Capsule()) }
             }.padding(.horizontal)

             Text(progressSummary).font(.caption).foregroundColor(.secondary).padding(.bottom, 8)
             Divider()
         }.padding(.bottom, 5)
      }
 }
struct StringEntryRow: View { /* ... unchanged */
    let entry: LocalizableStringEntry
    // Body remains the same, displays "VI" automatically
    var body: some View { HStack(alignment: .top) { Image(systemName: entry.state.icon).foregroundColor(entry.state.color).font(.title3).frame(width: 25); VStack(alignment: .leading, spacing: 3) { HStack { Text(entry.key).font(.headline).lineLimit(1); if entry.hasVariations { Image(systemName: "list.bullet.indent").foregroundColor(.accentColor).imageScale(.small) } }; Text("\"\(entry.defaultValue)\"").font(.subheadline).foregroundColor(.primary).lineLimit(2); if let comment = entry.comment, !comment.isEmpty { Text("Comment: \(comment)").font(.caption).italic().foregroundColor(.gray) }; if !entry.translations.isEmpty { HStack(spacing: 4) { ForEach(entry.translations.keys.sorted(), id: \.self) { langCode in Text(langCode.uppercased()).font(.caption2).padding(.horizontal, 4).background(languageColor(langCode).opacity(0.2)).clipShape(Capsule()) } }.padding(.top, 2) } }; Spacer() }.padding(.vertical, 6) }
     // Helper to give languages different colors (optional)
    private func languageColor(_ code: String) -> Color {
        switch code.lowercased() {
            case "pt": return .green
            case "uk": return .blue
            case "fr": return .purple
            case "vi": return .red // Assign a color for Vietnamese
            default: return .gray
        }
    }
}
struct AddStringView: View { /* ... unchanged */
    // Logic remains the same, user adds Default Value (EN)
    @Environment(\.dismiss) var dismiss
    @Binding var stringEntries: [LocalizableStringEntry]
    @State private var newKey: String = ""
    @State private var newDefaultValue: String = ""
    @State private var newComment: String = ""
    var canAdd: Bool { !newKey.trimmingCharacters(in: .whitespaces).isEmpty && !newDefaultValue.trimmingCharacters(in: .whitespaces).isEmpty && !stringEntries.contains(where: { $0.key == newKey.trimmingCharacters(in: .whitespaces) }) }
    // Body remains the same
    var body: some View { NavigationView { Form { TextField("Unique Key (e.g., Settings.Title)", text: $newKey).autocorrectionDisabled().textInputAutocapitalization(.never); TextField("Default Value (English)", text: $newDefaultValue); TextField("Comment for Translator (Optional)", text: $newComment); if !canAdd && !newKey.isEmpty && stringEntries.contains(where: { $0.key == newKey.trimmingCharacters(in: .whitespaces) }) { Text("Key already exists.").font(.caption).foregroundColor(.red) } }.navigationTitle("Add Manual String").toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }; ToolbarItem(placement: .navigationBarTrailing) { Button("Add") { addString(); dismiss() }.disabled(!canAdd) } } } }
    private func addString() { guard canAdd else { return }; let entry = LocalizableStringEntry(key: newKey.trimmingCharacters(in: .whitespaces), defaultValue: newDefaultValue, comment: newComment.isEmpty ? nil : newComment, state: .new, translations: [:], pluralForms: nil, deviceVariations: nil); stringEntries.append(entry) }
}
struct VariationsDetailView: View {  /* ... unchanged */
    // Logic remains the same, displays variations based on entry data
     @Environment(\.dismiss) var dismiss
     let entry: LocalizableStringEntry
     // Body displays plural/device variations regardless of language
     var body: some View { NavigationView { List { Section("Base String") { Text("Key: \(entry.key)").font(.headline); Text("Default: \"\(entry.defaultValue)\""); if let comment = entry.comment { Text("Comment: \(comment)").italic().foregroundColor(.gray) } }; if let plurals = entry.pluralForms, !plurals.isEmpty { Section("Plural Variations") { ForEach(plurals.keys.sorted(), id: \.self) { category in HStack { Text(category.capitalized).font(.caption).padding(.horizontal, 6).background(Color.teal.opacity(0.2)).clipShape(Capsule()); Spacer(); Text("\"\(plurals[category]!)\"") } } } }; if let devices = entry.deviceVariations, !devices.isEmpty { Section("Device Variations") { ForEach(devices.keys.sorted(), id: \.self) { category in HStack { Text(category.capitalized).font(.caption).padding(.horizontal, 6).background(Color.indigo.opacity(0.2)).clipShape(Capsule()); Spacer(); Text("\"\(devices[category]!)\"") } } } }; if !entry.hasVariations { Text("No variations defined.").foregroundColor(.secondary) } }.navigationTitle("String Variations").toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } } } } }
}

// MARK: - Static Explanatory Views (Placeholders) - Unchanged
// Note: The text within these views is *not* localized in this example.
struct StaticCoreConceptView: View { /* unchanged */ var body: some View { VStack(alignment: .leading) { FeatureRow(icon: "doc.text.fill", color: .blue, title: "String Catalog (.xcstrings)", description: "Centralized file replacing .strings/.stringsdict..."); FeatureRow(icon: "arrow.triangle.2.circlepath.circle.fill", color: .green, title: "Automatic Sync", description: "Xcode automatically extracts strings..."); FeatureRow(icon: "text.magnifyingglass", color: .purple, title: "Confidence", description: "Easily track translation progress...") }.padding(.vertical) } }
struct StaticSourcesView: View { /* unchanged */ var body: some View { VStack(alignment: .leading) { SourceRow(icon: "swift", title: "SwiftUI", example: "Text(\"Hello, SwiftUI!\")"); SourceRow(icon: "curlybraces", title: "Swift", example: "String(localized: \"MyModelString\")"); SourceRow(icon: "curlybraces.square.fill", title: "Objective-C / C", example: "NSLocalizedString(@\"ObjCString\", ...)"); SourceRow(icon: "hammer.fill", title: "Interface Builder", example: "UILabel text set in .xib/.storyboard"); SourceRow(icon: "list.bullet", title: "Info.plist", example: "NSHumanReadableCopyright"); SourceRow(icon: "square.grid.3x3.fill", title: "App Shortcuts", example: "Phrases for App Intents") }.padding(.vertical) } }
struct StaticEditorFeaturesView: View { /* unchanged */ var body: some View { VStack(alignment: .leading) { Text("State Tracking Demonstrated Above").font(.headline).padding(.bottom, 5); HStack(spacing: 15) { ForEach(StringState.allCases) { state in VStack { Image(systemName: state.icon).foregroundColor(state.color).font(.title3); Text(state.rawValue).font(.caption) } } }; Divider().padding(.vertical); FeatureRow(icon: "display.2", color: .indigo, title: "Vary by Device", description: "Provide different text for different platforms..."); FeatureRow(icon: "textformat.123", color: .teal, title: "Vary by Plural", description: "Handle singular, plural, and language-specific cases."); CodeSnippetView(code: "\"ItemCount\": { \"one\": \"1 item\", \"other\": \"%lld items\" }"); FeatureRow(icon: "slider.horizontal.3", color: .gray, title: "Filtering & Sorting", description: "Implemented above..."); FeatureRow(icon: "plus.circle.fill", color: .green, title: "Manual Strings", description: "Use the '+' button to add strings...") }.padding(.vertical) } }
struct StaticWorkflowView: View { /* unchanged */ var exportAction: () -> Void; var importAction: () -> Void; var body: some View { VStack(alignment: .leading) { Button { exportAction() } label: { FeatureRow(icon: "square.and.arrow.up.fill", color: .orange, title: "Export Localizations", description: "Generate Localization Catalogs (.xloc)...") }; Button { importAction() } label: { FeatureRow(icon: "square.and.arrow.down.fill", color: .orange, title: "Import Localizations", description: "Import translated XLIFF files...") }; FeatureRow(icon: "percent", color: .blue, title: "Progress Tracking", description: "Summary shown above the list.") }.buttonStyle(.plain).padding(.vertical) } }
struct StaticAdoptionView: View { /* unchanged */ var migrateAction: () -> Void; var body: some View { VStack(alignment: .leading) { FeatureRow(icon: "arrow.triangle.branch", color: .purple, title: "Coexistence", description: "String Catalogs can exist alongside legacy files."); Button { migrateAction() } label: { FeatureRow(icon: "wand.and.rays", color: .yellow, title: "Migration Assistant", description: "Xcode can convert existing .strings/.stringsdict.") }; FeatureRow(icon: "shippingbox.fill", color: .brown, title: "New Projects/Packages", description: "Simple setup for localizing new projects...") }.buttonStyle(.plain).padding(.vertical) } }

// MARK: - Reusable Components (from previous example) - Unchanged
struct FeatureRow: View { let icon: String; let color: Color; let title: String; let description: String; var body: some View { HStack(alignment: .top, spacing: 15) { Image(systemName: icon).font(.title3).foregroundColor(color).frame(width: 30); VStack(alignment: .leading) { Text(title).font(.headline); Text(description).font(.subheadline).foregroundColor(.gray) } }.padding(.vertical, 3) } }
struct SourceRow: View { let icon: String; let title: String; let example: String; var body: some View { HStack(alignment: .top) { Image(systemName: icon).font(.title3).foregroundColor(.secondary).frame(width: 25); VStack(alignment: .leading) { Text(title).font(.body); Text(example).font(.caption.monospaced()).foregroundColor(.gray).padding(.top, 1) } }.padding(.vertical, 4) } }
struct CodeSnippetView: View { let code: String; var body: some View { Text(code).font(.caption.monospaced()).foregroundColor(.secondary).padding(8).background(Color.gray.opacity(0.1)).cornerRadius(6).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4) } }
struct AlertInfo: Identifiable { let id = UUID(); let title: String; let message: String } // Use this struct for alert item

// MARK: - Sample Data (UPDATED with Vietnamese - "vi")

let sampleData: [LocalizableStringEntry] = [
    .init(key: "WelcomeMessage", defaultValue: "Welcome to My App!", comment: "Greeting shown on the main screen.", state: .reviewed, translations: ["pt": "Bem-vindo ao Meu App!", "uk": "Ласкаво просимо до Мого Додатку!", "fr": "Bienvenue sur Mon App !", "vi": "Chào mừng đến với Ứng dụng của tôi!"]), // Added vi
    .init(key: "TapToLearnMore", defaultValue: "Tap to learn more.", comment: "Instructional text on a button.", state: .needsReview, translations: ["pt": "Toque para saber mais.", "uk": "Натисніть, щоб дізнатися більше.", "vi": "Nhấn để tìm hiểu thêm."]), // Added vi
    .init(key: "Settings.Title", defaultValue: "Settings", comment: "Title for the settings screen", state: .reviewed, translations: ["pt": "Configurações", "uk": "Налаштування", "vi": "Cài đặt"]), // Added vi
    .init(key: "Done", defaultValue: "Done", comment: "A common confirmation button label", state: .reviewed, translations: ["pt": "Feito", "uk": "Готово", "vi": "Xong"]), // Added vi
    .init(key: "Cancel", defaultValue: "Cancel", comment: "A common cancellation button label", state: .reviewed, translations: ["pt": "Cancelar", "uk": "Скасувати", "vi": "Hủy"]), // Added vi
    //.init(key: "ItemCount", defaultValue: "%lld items", comment: "Displays a count of items", state: .new, translations: ["vi": "%lld mục"], pluralForms: ["one": "1 item", "other": "%lld items", "vi": ["one": "1 mục", "other": "%lld mục"]]), // Added vi entry and vi plural forms
    .init(key: "DeleteConfirmation.Title", defaultValue: "Delete Item?", comment: "Alert title for deleting", state: .needsReview, translations: ["pt": "Excluir Item?", "vi": "Xóa mục?"]), // Added vi
    .init(key: "DeleteConfirmation.Message", defaultValue: "Are you sure you want to permanently delete this item?", comment: "Alert message for deleting", state: .needsReview, translations: ["pt": "Tem certeza de que deseja excluir permanentemente este item?", "vi": "Bạn có chắc chắn muốn xóa vĩnh viễn mục này không?"]), // Added vi
    .init(key: "SubmitAction", defaultValue: "Submit", comment: "Button to submit a form", state: .new, translations: ["vi": "Gửi"], deviceVariations: ["mac": "Submit Form", "iphone": "Send"]), // Added vi base translation
    .init(key: "OldFeatureString", defaultValue: "Use the old feature.", comment: "String related to a removed feature.", state: .stale, translations: ["pt": "Use o recurso antigo.", "uk": "Використовуйте стару функцію.", "vi": "Sử dụng tính năng cũ."]), // Added vi
    .init(key: "Profile.EditButton", defaultValue: "Edit Profile", comment: "Button to navigate to profile editing", state: .reviewed, translations: ["uk": "Редагувати профіль", "vi": "Chỉnh sửa hồ sơ"]), // Added vi
    .init(key: "NetworkError", defaultValue: "Could not connect to server.", comment: "Generic network error message", state: .new, translations: ["vi": "Không thể kết nối đến máy chủ."]) // Added vi
]

// MARK: - Preview Provider

struct InteractiveStringCatalogView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveStringCatalogView()
            // Optional: Force a specific locale for preview testing
             .environment(\.locale, .init(identifier: "vi"))
    }
}
