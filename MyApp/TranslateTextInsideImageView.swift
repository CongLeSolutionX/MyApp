//
//  TranslateTextInsideImageView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// --- Data Model ---
struct Language: Identifiable, Equatable {
    let id = UUID()
    let code: String // e.g., "en", "es"
    let name: String // e.g., "English", "Spanish"

    static func == (lhs: Language, rhs: Language) -> Bool {
        lhs.id == rhs.id // Simple identity check for this example
    }
}

// --- Sample Data ---
let recentLanguages: [Language] = [
    .init(code: "en", name: "English"),
    .init(code: "es", name: "Spanish"),
    .init(code: "ja", name: "Japanese")
]

let allLanguages: [Language] = [
    .init(code: "af", name: "Afrikaans"),
    .init(code: "ak", name: "Akan"),
    .init(code: "sq", name: "Albanian"),
    .init(code: "am", name: "Amharic"),
    .init(code: "ar", name: "Arabic"),
    .init(code: "hy", name: "Armenian"),
    .init(code: "as", name: "Assamese"),
    .init(code: "ay", name: "Aymara"),
    .init(code: "az", name: "Azerbaijani"),
    // ... Add many more languages for a complete list
]

// --- Main View Structure ---

struct TranslateTextInsideImageView: View {
    @State private var showingLanguageSheet = false
    // Default to English, ensure it exists in recentLanguages for checkmark logic
    @State private var selectedLanguage: Language = recentLanguages.first ?? Language(code: "en", name: "English")

    var body: some View {
        ZStack(alignment: .top) {
            // 1. Placeholder for the Browser Content
            BrowserPlaceholderView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground)) // Simulate browser window background

            // 2. Google Lens Selection Button Overlay
            LensSelectionButton {
                showingLanguageSheet = true
            }
            .padding(.top, 20) // Position it near the top

        }
        .sheet(isPresented: $showingLanguageSheet) {
            // 3. Language Selection Sheet
            LanguageSelectionView(selectedLanguage: $selectedLanguage)
        }
        .frame(width: 800, height: 600) // Simulate a browser window size
        .navigationTitle("Google Lens Translate Demo") // For context if embedded in NavigationView
    }
}

// --- Helper Views ---

struct BrowserPlaceholderView: View {
    // Simple placeholder mimicking the magazine website
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Magazine Glam")
                .font(.largeTitle.weight(.bold))
            HStack {
                ForEach(["FASHION", "BEAUTY", "CULTURE", "LIVING"], id: \.self) { category in
                    Text(category).font(.caption).foregroundColor(.gray)
                }
            }
            Divider()
            Text("How To Give Your Old Clothes New Life")
                .font(.title2)
            Text("BY ELISA BECKETT | August 13, 2024")
                .font(.footnote)
                .foregroundColor(.gray)

            Image(systemName: "photo.artframe") // Placeholder for the image
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            Spacer() // Pushes content up
        }
        .padding()
    }
}

struct LensSelectionButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "camera.viewfinder")
                Text("Select text with Google Lens")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(.thinMaterial) // Gives a blurred background effect
            .foregroundColor(.primary)
            .cornerRadius(8)
            .shadow(radius: 3, y: 2)
        }
    }
}

// --- Language Selection Sheet View ---

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: Language
    @Environment(\.dismiss) var dismiss // To close the sheet

    var body: some View {
        NavigationView { // Using NavigationView for easy title bar
            List {
                Section("Recent languages") {
                    ForEach(recentLanguages) { lang in
                        LanguageRow(
                            language: lang,
                            isSelected: lang == selectedLanguage
                        ) {
                            selectedLanguage = lang
                            // Optionally dismiss after selection, or keep sheet open
                            // dismiss()
                        }
                    }
                }

                Section("All languages") {
                    ForEach(allLanguages) { lang in
                        LanguageRow(
                            language: lang,
                            isSelected: lang == selectedLanguage // Doesn't show checkmark unless selected
                        ) {
                             selectedLanguage = lang
                            // Optionally dismiss after selection
                            // dismiss()
                        }
                    }
                }
            }
            .listStyle(.insetGrouped) // Style similar to the screenshot's sections
            .navigationTitle("Translate to")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Placeholder - Back button might be automatic in some flows,
                    // or manually handled depending on presentation context.
                    // For a sheet, a "Done" or "Close" is more typical.
                    Button {
                       // Custom back action if needed, usually handled by NavigationView
                    } label: {
                        Image(systemName: "arrow.backward") // Matches screenshot icon
                    }
                     .disabled(true) // Simulate inactive back button in this context
                     .opacity(0.5)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss() // Close the sheet
                    } label: {
                        Image(systemName: "xmark") // Close icon
                             .foregroundColor(.secondary) // Subtle color
                    }
                }
            }
        }
         // Prevent NavigationView from taking over the full screen in the sheet context on iPad/Mac
        .navigationViewStyle(.stack)
    }
}

// --- Reusable Language Row ---

struct LanguageRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) { // Make the whole row tappable
            HStack {
                Text(language.name)
                    .foregroundColor(.primary) // Ensure text is readable
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor) // Use theme color for checkmark
                }
            }
            .contentShape(Rectangle()) // Ensure entire HStack area is tappable
        }
         // Remove default Button styling if needed, List handles row appearance
        .buttonStyle(.plain)
    }
}

// --- Preview ---
struct TranslateTextInsideImageView_Previews: PreviewProvider {
    static var previews: some View {
        TranslateTextInsideImageView()
            .preferredColorScheme(.light) // Match screenshot appearance
    }
}
