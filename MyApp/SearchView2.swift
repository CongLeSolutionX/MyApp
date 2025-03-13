//
//  SearchView.swift
//  MyApp
//
//  Created by Cong Le on 3/13/25.
//

import SwiftUI

// MARK: - Sample Data for Search
private let sampleSearchBooks: [Book] = [
    Book(title: "Swift Basics", author: "John Swift", coverImageName: "book.fill", currentPage: 0, totalPages: 150, categories: ["nil"]),
    Book(title: "Design Patterns in iOS", author: "Anne Dev", coverImageName: "book.fill", currentPage: 0, totalPages: 300, categories: ["nil"]),
    Book(title: "Networking with Combine", author: "Tom Combine", coverImageName: "book.fill", currentPage: 0, totalPages: 220, categories: ["nil"]),
    Book(title: "Core Data Mastery", author: "Emily Core", coverImageName: "book.fill", currentPage: 0, totalPages: 400, categories: ["nil"]),
    Book(title: "SwiftUI Advanced Layouts", author: "Morgan U", coverImageName: "book.fill", currentPage: 10, totalPages: 300, categories: ["nil"]),
]

// MARK: - Search View
struct SearchView: View {
    @State private var searchTerm: String = ""
    @State private var searchResults: [Book] = []

    var body: some View {
        NavigationStack {
            ZStack {
                // Background rectangle or any custom background layer
                Rectangle()
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                    .ignoresSafeArea()

                VStack {
                    // Search bar at the top
                    TextField("Search books...", text: $searchTerm, onCommit: {
                        performSearch()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchTerm) { _ in
                        // Optionally perform live searching:
                        // performSearch()
                    }

                    // Display horizontal scroll of results
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 16) {
                            ForEach(searchResults) { book in
                                BookCardView(book: book)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Search")
        }
        .onAppear {
            // Optionally load initial results or leave empty
            searchResults = sampleSearchBooks
        }
    }

    // MARK: - Search Logic
    private func performSearch() {
        // Filter sample data by searchTerm;
        // In production, call an API or a local database query here.
        let lowercasedTerm = searchTerm.lowercased()
        if !lowercasedTerm.isEmpty {
            searchResults = sampleSearchBooks.filter {
                $0.title.lowercased().contains(lowercasedTerm)
                || $0.author.lowercased().contains(lowercasedTerm)
            }
        } else {
            // If there's no search term, you could clear or set default items:
            searchResults = sampleSearchBooks
        }
    }
}

// MARK: - Preview
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
