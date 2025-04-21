////
////  StringCatalogLocalizationUIDesign_V2.swift
////  Alchemy_Models
////
////  Created by Cong Le on 4/20/25.
////
//
//import SwiftUI
//
//// Represents a single localizable string entry for UI purposes
//struct LocalizableStringEntry: Identifiable, Hashable {
//    let id = UUID()
//    let key: String
//    let defaultValue: String
//    let comment: String?
//    let state: StringState
//    // Simplified representation of translations
//    let translations: [String: String] // Language Code -> Translation
//}
//
//// Represents the different states a string can be in
//enum StringState: String, CaseIterable, Identifiable {
//    case new = "New"
//    case needsReview = "Needs Review"
//    case stale = "Stale"
//    case reviewed = "Reviewed"
//
//    var id: String { self.rawValue }
//
//    var icon: String {
//        switch self {
//        case .new: return "circle.dashed"
//        case .needsReview: return "exclamationmark.triangle.fill"
//        case .stale: return "trash.fill" // Or "xmark.octagon.fill"
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
//}
//
//// Main View showcasing String Catalog concepts
//struct StringCatalogOverviewView: View {
//
//    // Sample data simulating entries in a catalog
//    let sampleEntries: [LocalizableStringEntry] = [
//        .init(key: "WelcomeMessage", defaultValue: "Welcome to My App!", comment: "Greeting shown on the main screen.", state: .reviewed, translations: ["pt": "Bem-vindo ao Meu App!", "uk": "Ласкаво просимо до Мого Додатку!"]),
//        .init(key: "TapToLearnMore", defaultValue: "Tap to learn more.", comment: "Instructional text on a button.", state: .needsReview, translations: ["pt": "Toque para saber mais.", "uk": "Натисніть, щоб дізнатися більше."]),
//        .init(key: "BirdCount", defaultValue: "There are %lld birds.", comment: "Displays the number of birds.", state: .new, translations: [:]),
//        .init(key: "OldFeatureString", defaultValue: "Use the old feature.", comment: "String related to a removed feature.", state: .stale, translations: ["pt": "Use o recurso antigo.", "uk": "Використовуйте стару функцію."])
//    ]
//
//    var body: some View {
//        NavigationView {
//            List {
//                // Introduction Section
//                Section("Core Concept") {
//                    FeatureRow(icon: "doc.text.fill", color: .blue, title: "String Catalog (.xcstrings)", description: "Centralized file replacing .strings and .stringsdict. Manages all localizable strings and translations. JSON-based and source-control friendly.")
//                    FeatureRow(icon: "arrow.triangle.2.circlepath.circle.fill", color: .green, title: "Automatic Sync", description: "Xcode automatically extracts strings from code, IB, and plists during build, keeping the catalog up-to-date.")
//                    FeatureRow(icon: "text.magnifyingglass", color: .purple, title: "Confidence", description: "Easily track translation progress and identify missing or outdated translations before shipping.")
//                }
//
//                // String Sources Section
//                Section("Sources of Localizable Strings") {
//                    SourceRow(icon: "swift", title: "SwiftUI", example: "Text(\"Hello, SwiftUI!\")")
//                    SourceRow(icon: "curlybraces", title: "Swift", example: "String(localized: \"MyModelString\")")
//                    SourceRow(icon: "curlybraces.square.fill", title: "Objective-C / C", example: "NSLocalizedString(@\"ObjCString\", ...)")
//                    SourceRow(icon: "hammer.fill", title: "Interface Builder", example: "UILabel text set in .xib/.storyboard")
//                    SourceRow(icon: "list.bullet", title: "Info.plist", example: "NSHumanReadableCopyright")
//                    SourceRow(icon: "square.grid.3x3.fill", title: "App Shortcuts", example: "Phrases for App Intents")
//                }
//
//                // Editor Features Section
//                Section("Editor Features") {
//                    // States Demo
//                    VStack(alignment: .leading) {
//                        Text("State Tracking").font(.headline)
//                        HStack(spacing: 15) {
//                            ForEach(StringState.allCases) { state in
//                                VStack {
//                                    Image(systemName: state.icon)
//                                        .foregroundColor(state.color)
//                                        .font(.title2)
//                                    Text(state.rawValue)
//                                        .font(.caption)
//                                        .multilineTextAlignment(.center)
//                                }
//                            }
//                        }
//                        .padding(.top, 5)
//                    }
//                    .padding(.vertical, 5)
//
//                    // Variations Demo
//                    FeatureRow(icon: "display.2", color: .indigo, title: "Vary by Device", description: "Provide different text for different platforms (e.g., 'Click' on Mac, 'Tap' on iOS).")
//                    FeatureRow(icon: "textformat.123", color: .teal, title: "Vary by Plural", description: "Handle singular, plural, and language-specific grammatical cases (e.g., '1 bird', '2 birds'). Supports substitutions for multiple arguments.")
//                    CodeSnippetView(code: """
//                    // Plural Variation Example (Simplified Representation)
//                    "BirdCount": {
//                      "one": "There is 1 bird.",
//                      "other": "There are %lld birds."
//                    }
//                    """)
//
//                    FeatureRow(icon: "slider.horizontal.3", color: .gray, title: "Filtering & Sorting", description: "Easily find specific strings or focus on strings needing attention.")
//                    FeatureRow(icon: "plus.circle.fill", color: .green, title: "Manual Strings", description: "Add strings not directly found in code (e.g., from a server).")
//                }
//
//                // Simulated Catalog Entries Section
//                Section("Simulated Catalog Entries") {
//                    ForEach(sampleEntries) { entry in
//                        HStack {
//                            Image(systemName: entry.state.icon)
//                                .foregroundColor(entry.state.color)
//                            VStack(alignment: .leading) {
//                                Text(entry.key).font(.headline).lineLimit(1)
//                                Text("\"\(entry.defaultValue)\"").font(.subheadline).foregroundColor(.gray)
//                                if let comment = entry.comment {
//                                    Text("Comment: \(comment)").font(.caption).italic().foregroundColor(.gray)
//                                }
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }
//                }
//
//                // Workflow Section
//                Section("Workflow") {
//                    FeatureRow(icon: "square.and.arrow.up.fill", color: .orange, title: "Export Localizations", description: "Generate Localization Catalogs (.xloc) containing XLIFF files for translators.")
//                    FeatureRow(icon: "square.and.arrow.down.fill", color: .orange, title: "Import Localizations", description: "Import translated XLIFF files back into the String Catalog.")
//                    FeatureRow(icon: "percent", color: .blue, title: "Progress Tracking", description: "Sidebar shows percentage completion for each language.")
//                }
//
//                // Migration Section
//                Section("Adoption & Migration") {
//                    FeatureRow(icon: "arrow.triangle.branch", color: .purple, title: "Coexistence", description: "String Catalogs can exist alongside legacy .strings/.stringsdict files.")
//                    FeatureRow(icon: "wand.and.rays", color: .yellow, title: "Migration Assistant", description: "Easily migrate existing .strings/.stringsdict files to the new format.")
//                    FeatureRow(icon: "shippingbox.fill", color: .brown, title: "New Projects/Packages", description: "Simple setup for localizing new projects or Swift Packages.")
//                 }
//
//            }
//            .listStyle(.insetGrouped) // Use insetGrouped for better section separation
//            .navigationTitle("String Catalog Features")
//        }
//    }
//}
//
//// Helper View for consistent feature rows
//struct FeatureRow: View {
//    let icon: String
//    let color: Color
//    let title: String
//    let description: String
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 15) {
//            Image(systemName: icon)
//                .font(.title2)
//                .foregroundColor(color)
//                .frame(width: 30) // Align icons
//            VStack(alignment: .leading) {
//                Text(title).font(.headline)
//                Text(description).font(.subheadline).foregroundColor(.gray)
//            }
//        }
//        .padding(.vertical, 5)
//    }
//}
//
//// Helper View for showing code source rows
//struct SourceRow: View {
//    let icon: String
//    let title: String
//    let example: String
//
//    var body: some View {
//        HStack(alignment: .top) {
//             Image(systemName: icon)
//                 .font(.title3)
//                 .foregroundColor(.secondary)
//                 .frame(width: 25) // Align icons
//            VStack(alignment: .leading) {
//                 Text(title).font(.body)
//                 Text(example)
//                     .font(.caption.monospaced())
//                     .foregroundColor(.gray)
//                     .padding(.top, 1)
//            }
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//// Helper View for displaying code snippets
//struct CodeSnippetView: View {
//    let code: String
//
//    var body: some View {
//        Text(code)
//            .font(.caption.monospaced())
//            .foregroundColor(.secondary)
//            .padding(8)
//            .background(Color.gray.opacity(0.1))
//            .cornerRadius(6)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.vertical, 4)
//    }
//}
//
//// Preview Provider
//struct StringCatalogOverviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        StringCatalogOverviewView()
//    }
//}
