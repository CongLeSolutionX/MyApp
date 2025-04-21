////
////  String Catalog Localization UI Design.swift
////  Alchemy_Models
////
////  Created by Cong Le on 4/20/25.
////
//
//import SwiftUI
//
//// MARK: - Models
//
//enum TranslationState: String, CaseIterable {
//    case new = "NEW", needsReview = "⚠️", translated = "✅", stale = "🗑"
//}
//
//struct StringEntry: Identifiable {
//    let id = UUID()
//    var key: String
//    var defaultValue: String
//    var translations: [String: String]    // languageCode: text
//    var state: TranslationState
//}
//
//// MARK: - Main View
//
//struct StringCatalogView: View {
//    // Sidebar state
//    @State private var selectedLanguage: String = "pt"  // Portuguese
//    @State private var languages: [String] = ["en", "pt", "uk"]
//    @State private var entries: [StringEntry] = SampleData.entries
//    @State private var filterText: String = ""
//    
//    var body: some View {
//        NavigationView {
//            sidebar
//            contentArea
//        }
//        .frame(minWidth: 900, minHeight: 600)
//    }
//    
//    // MARK: Sidebar
//    
//    var sidebar: some View {
//        List {
//            Section(header: Text("Languages")) {
//                Picker("Language", selection: $selectedLanguage) {
//                    ForEach(languages, id: \.self) { lang in
//                        Text(lang.uppercased()).tag(lang)
//                    }
//                }
//                .pickerStyle(.automatic)
//            }
//            Section(header: Text("Progress")) {
//                let total = entries.count
//                let done = entries.filter { $0.state == .translated }.count
//                ProgressView(value: Double(done), total: Double(total)) {
//                    Text("\(done)/\(total) translated")
//                }
//            }
//            Section {
//                Button(action: addManualString) {
//                    Label("Add Manual String", systemImage: "plus")
//                }
//            }
//        }
//        .listStyle(SidebarListStyle())
//    }
//    
//    // MARK: Content
//    
//    var contentArea: some View {
//        VStack(spacing: 0) {
//            toolbar
//            HStack(spacing: 0) {
//                stringList
//                Divider()
//                detailPanel
//            }
//        }
//    }
//    
//    var toolbar: some View {
//        HStack {
//            TextField("Filter keys…", text: $filterText)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .frame(maxWidth: 200)
//            
//            Spacer()
//            
//            Button(action: exportLocalizations) {
//                Label("Export", systemImage: "square.and.arrow.up")
//            }
//            Button(action: importLocalizations) {
//                Label("Import", systemImage: "square.and.arrow.down")
//            }
//        }
//        .padding(8)
//        .background(Color(.secondarySystemBackground))
//    }
//    
//    var stringList: some View {
//        List(filteredEntries) { entry in
//            HStack {
//                Text(entry.key).font(.subheadline)
//                Spacer()
//                Text(entry.defaultValue).foregroundColor(.secondary)
//                Spacer()
//                Text(entry.state.rawValue)
//            }
//            .contentShape(Rectangle())
//            .contextMenu {
//                Button("Mark as Reviewed") { markReviewed(entry) }
//                Divider()
//                Menu("Vary by") {
//                    Button("Device") { varyDevice(entry) }
//                    Button("Plural") { varyPlural(entry) }
//                }
//            }
//        }
//        .listStyle(PlainListStyle())
//        .frame(minWidth: 300)
//    }
//    
//    var detailPanel: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            if let entry = selectedEntry {
//                Text("Key: \(entry.key)")
//                    .font(.headline)
//                Text("Default:")
//                Text(entry.defaultValue)
//                    .padding(6)
//                    .background(Color(.darkText))
//                    .cornerRadius(4)
//                
//                Divider()
//                
//                Text("Translation (\(selectedLanguage.uppercased())):")
//                TextEditor(text: Binding(
//                    get: { entry.translations[selectedLanguage] ?? "" },
//                    set: { new in updateTranslation(entry, new) }
//                ))
//                .font(.body)
//                .border(Color.gray.opacity(0.5))
//                
//                Spacer()
//            } else {
//                Text("Select a string to view/edit")
//                    .italic().foregroundColor(.gray)
//                Spacer()
//            }
//        }
//        .padding()
//        .frame(minWidth: 350)
//    }
//    
//    // MARK: Computed
//    
//    private var filteredEntries: [StringEntry] {
//        guard !filterText.isEmpty else { return entries }
//        return entries.filter { $0.key.localizedCaseInsensitiveContains(filterText) }
//    }
//    
//    private var selectedEntry: StringEntry? {
//        // Simplified: pick first matching
//        filteredEntries.first { $0.state != .stale }
//    }
//    
//    // MARK: Actions
//    
//    private func addManualString() {
//        let new = StringEntry(
//            key: "manual.key.\(entries.count+1)",
//            defaultValue: "New manual string",
//            translations: [:],
//            state: .new
//        )
//        entries.append(new)
//    }
//    
//    private func exportLocalizations() {
//        /* Implement export logic */
//    }
//    private func importLocalizations() {
//        /* Implement import logic */
//    }
//    private func markReviewed(_ entry: StringEntry) {
//        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
//            entries[idx].state = .translated
//        }
//    }
//    private func varyDevice(_ entry: StringEntry) {
//        /* Open device-variation UI */
//    }
//    private func varyPlural(_ entry: StringEntry) {
//        /* Open plural-variation UI */
//    }
//    private func updateTranslation(_ entry: StringEntry, _ text: String) {
//        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
//            entries[idx].translations[selectedLanguage] = text
//            entries[idx].state = text.isEmpty ? .new : .translated
//        }
//    }
//}
//
//// MARK: - Sample Data
//
//struct SampleData {
//    static var entries: [StringEntry] = [
//        .init(key: "welcome.title", defaultValue: "Welcome to WWDC!", translations: ["pt": "Bem‑vindo ao WWDC!"], state: .translated),
//        .init(key: "tap.learnMore", defaultValue: "Tap to learn more.", translations: ["pt": "Toque para saber mais."], state: .translated),
//        .init(key: "birds.count", defaultValue: "%d birds visited", translations: ["pt": ""], state: .new),
//        .init(key: "yards.count", defaultValue: "%d yards", translations: ["pt": ""], state: .new)
//    ]
//}
//
//// MARK: - Preview
//
//struct StringCatalogView_Previews: PreviewProvider {
//    static var previews: some View {
//        StringCatalogView()
//    }
//}
