//
//  BookDetailView.swift
//  MyApp
//
//  Created by Cong Le on 3/13/25.
//

import SwiftUI

// MARK: - Book Detail View
struct BookDetailView: View {
    // The Book instance passed in from the previous screen
    let book: Book

    // For demonstration purposes, you can track if a book is bookmarked
    @State private var isBookmarked: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Cover Image
                Image(systemName: book.coverImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .accessibilityLabel("Book cover: \(book.title)")

                // Title and Author
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.title)
                        .fontWeight(.semibold)
                        .accessibility(addTraits: .isHeader)

                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Book Progress
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reading Progress")
                        .font(.headline)

                    // Basic progress bar
                    ProgressView(value: Double(book.currentPage), total: Double(book.totalPages))
                        .progressViewStyle(.linear)
                    
                    // Optional page indicator
                    Text("Page \(book.currentPage) of \(book.totalPages)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Categories
                if !book.categories.isEmpty {
                    // Horizontal scroll for categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(book.categories, id: \.self) { category in
                                Text(category)
                                    .font(.footnote)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Continue Reading Button
                Button(action: {
                    // Example: You might navigate to a reading session or update progress
                }) {
                    Text("Continue Reading")
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Toggle bookmark state (placeholder implementation)
                    isBookmarked.toggle()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(isBookmarked ? "Bookmarked" : "Not bookmarked")
            }
        }
    }
}

// MARK: - Previews
struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            // Sample Book data
            BookDetailView(
                book: Book(
                    title: "Code Patterns",
                    author: "Sam Developer",
                    coverImageName: "book.cover.fill",
                    currentPage: 120,
                    totalPages: 500,
                    categories: ["nil"]
                )
            )
        }
    }
}
