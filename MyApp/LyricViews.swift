//
//  LyricEditorLineView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//


import SwiftUI

// --- Programmatic Selection & Accessing Ranges ---

struct LyricEditorLineView: View {
    @State var lineText: String = "A whole new view world"
    @State var selection: TextSelection? = nil // Holds selection state

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Enter lyrics", text: $lineText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                // Bind the selection state
//                .textSelection(_selection)

            if let selection = selection {
                Text("Current Selection:")
                    .font(.headline)
                // Display the ranges (simple description)
                Text("Ranges: \(selection.hashValue)")
                // You could iterate through ranges and get substrings:
//                ForEach(selection.stringIndices(in: lineText), id: \.self) { range in
//                    Text("Selected Text: '\(lineText[range])'")
//                }
            } else {
                Text("No selection.")
            }

            HStack {
                Button("Select 'new'") {
                    if let range = lineText.range(of: "new") {
                        // Programmatically set selection
                        selection = TextSelection(range: range)
                    }
                }
                Button("Clear Selection") {
                    selection = nil
                }
            }
        }
        .padding()
    }
}

#Preview("Text Selection") {
    LyricEditorLineView()
}

// --- Search Field Focus ---

struct SongSearchView: View {
    @State private var searchText = ""
    @State private var searchIsPresented = false
    @FocusState private var isSearchFieldFocused: Bool // Focus state var

    let allSongs = ["Cupertino Dreamin'", "Smells Like Scene Spirit", "View Controller Blues", "Swift Charts Serenade"]
    var filteredSongs: [String] {
        searchText.isEmpty ? allSongs : allSongs.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredSongs, id: \.self) { song in
                Text(song)
            }
            .navigationTitle("Find Songs")
            .toolbar {
                // Only show button if search isn't focused
                if !isSearchFieldFocused {
                    Button("Start Search") {
                        searchIsPresented = true // Make sure search bar is visible
                        isSearchFieldFocused = true // Programmatically focus
                    }
                }
            }
            // Use searchable and bind focus state
            .searchable(text: $searchText, isPresented: $searchIsPresented, prompt: "Search by title")
            .searchFocused($isSearchFieldFocused) // Bind the focus state
        }
    }
}

#Preview("Search Focus") {
    SongSearchView()
}

// --- Text Suggestions ---

struct LyricCompletion: Identifiable {
    let id = UUID()
    let text: String
    var attributedCompletion: AttributedString {
        var str = AttributedString(text)
        str.foregroundColor = .blue // Example styling
        return str
    }
}

struct LyricSuggestionView: View {
    @State private var currentLine: String = "Living on a"
    let completions = [
        LyricCompletion(text: "prayer"),
        LyricCompletion(text: "view"),
        LyricCompletion(text: "callback"),
        LyricCompletion(text: "state change")
    ]

    // Filter suggestions based on current input (simple example)
    var filteredCompletions: [LyricCompletion] {
        completions.filter { $0.text.lowercased().hasPrefix(getLastWordPrefix()) }
    }

    func getLastWordPrefix() -> String {
        let words = currentLine.split { $0.isWhitespace }
        return words.last?.lowercased() ?? ""
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Finish the Lyric:")
            TextField("Enter line", text: $currentLine, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                 // Attach suggestions provider closure
//                .textInputSuggestions {
                     // Provide suggestions dynamically
                     ForEach(filteredCompletions) { completion in
                         Text(completion.attributedCompletion) // Display styled text
//                             .textInputCompletion(completion.text) // Text to insert
//                     }
                 }
        }
        .padding()
    }
}

#Preview("Text Suggestions") {
    LyricSuggestionView()
}
