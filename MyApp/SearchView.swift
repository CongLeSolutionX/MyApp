//
//  SearchView.swift
//  MyApp
//
//  Created by Cong Le on 3/16/25.
//

import SwiftUI

// Custom Search Bar View
struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false // Track editing state

    var body: some View {
        HStack {
            // Back Button (only visible when editing)
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    // Dismiss the keyboard.  Important for good UX.
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "arrow.left")
                }
                .padding(.trailing, 4) // Add some spacing
            }

            // Search Field
            TextField("Search", text: $text, onEditingChanged: { editing in
                self.isEditing = editing
            })
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6)) // Light gray background
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)

                    if isEditing {
                        Button(action: {
                            self.text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .transition(.move(edge: .leading)) // Animate the appearance
            .animation(.easeInOut, value: isEditing) // Add animation

            // Optional: Cancel button (appears on the right when editing)
             if isEditing {
                 Button("Cancel") {
                     self.isEditing = false
                     self.text = ""
                     UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                 }
                 .padding(.leading, 4) // Consistent padding
             }
        }
        .padding(.horizontal) // Padding for the entire search bar
    }
}

// Data for Recent Searches
struct RecentSearch: Identifiable {
    let id = UUID()
    let term: String
}

// Main Content View
struct SearchView: View {
    @State private var searchText = ""
    @State private var recentSearches: [RecentSearch] = [
        RecentSearch(term: "jetpack compose"),
        RecentSearch(term: "games"),
        RecentSearch(term: "UI"),
        RecentSearch(term: "backstate"),
    ]
    
    @State var dummyText: String = "" //keep the keyboard open

    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Use spacing: 0 to remove extra space
                SearchBar(text: $searchText)
                
                List {
                    Section(header: Text("Recent searches").font(.subheadline)) {
                        ForEach(recentSearches) { search in
                            HStack {
                                Text(search.term)
                                Spacer()
                                Button(action: {
                                    // Handle deletion of the search term
                                    if let index = recentSearches.firstIndex(where: { $0.id == search.id }) {
                                        recentSearches.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "multiply.circle.fill") // x button
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: delete) // Enable swipe-to-delete
                    }
                }
                .listStyle(.plain) // Use plain list style for custom appearance
                
                //this is added to mimic the appearance of the keyboard
                TextField("", text: $dummyText)
            }
            .navigationTitle("Search")
            .background(Color(.systemGray6).opacity(0.3)) // Set background color for the entire view
        }
    }

    func delete(at offsets: IndexSet) {
        recentSearches.remove(atOffsets: offsets)
    }
}

// Preview Provider (for Xcode previews)
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
