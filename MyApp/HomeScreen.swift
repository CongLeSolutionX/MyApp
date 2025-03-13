//
//  HomeScreen.swift
//  MyApp
//
//  Created by Cong Le on 3/13/25.
//

import SwiftUI

// MARK: - Simple Book Model (Example)
struct Book: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let coverImageName: String
    var currentPage: Int
    var totalPages: Int
    let categories: [String]
}

// MARK: - Example Data
private let sampleNewGreatBooks = [
    Book(title: "Mystery in the Woods", author: "Jane Bird", coverImageName: "book.cover.fill", currentPage: 0, totalPages: 320, categories: ["nil"]),
    Book(title: "Lake of Dreams", author: "Mark West", coverImageName: "book.cover.fill", currentPage: 0, totalPages: 280, categories: ["nil"]),
]

private let samplePopularBooks = [
    Book(title: "Adventures of Time", author: "Tommy Lake", coverImageName: "book.cover.fill", currentPage: 0, totalPages: 400, categories: ["nil"]),
    Book(title: "Ocean at Twilight", author: "Stella Ocean", coverImageName: "book.cover.fill", currentPage: 0, totalPages: 310, categories: ["nil"]),
]

private let sampleCurrentlyReading = [
    Book(title: "Code Patterns", author: "Sam Developer", coverImageName: "book.cover.fill", currentPage: 120, totalPages: 500, categories: ["nil"]),
    Book(title: "SwiftUI In-Depth", author: "Morgan Swift", coverImageName: "book.cover.fill", currentPage: 50, totalPages: 250, categories: ["nil"]),
]

// MARK: - Section Header View (Example)
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .bold()
            .padding(.horizontal)
            .padding(.top, 16)
            .accessibility(addTraits: .isHeader)
    }
}

// MARK: - Book Card View (Example)
struct BookCardView: View {
    let book: Book
    var showProgress: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: book.coverImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 120)
                .cornerRadius(4)
                .background(Color.gray.opacity(0.2))
            
            Text(book.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(book.author)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            if showProgress {
                ProgressView(value: Double(book.currentPage), total: Double(book.totalPages))
                    .padding(.top, 4)
            }
        }
        .frame(width: 120)
        .padding()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Home Screen View
struct HomeScreenView: View {
    // Example data arrays
    let newGreatBooks: [Book] = sampleNewGreatBooks
    let popularBooks: [Book] = samplePopularBooks
    let currentlyReading: [Book] = sampleCurrentlyReading
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // New Great Books
                SectionHeader(title: "New Great Books")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(newGreatBooks) { book in
                            BookCardView(book: book)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Popular
                SectionHeader(title: "Popular")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(popularBooks) { book in
                            BookCardView(book: book)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Currently Reading
                SectionHeader(title: "Currently Reading")
                LazyVStack(spacing: 12) {
                    ForEach(currentlyReading) { book in
                        BookCardView(book: book, showProgress: true)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Home")
            .toolbar {
                // Search button in the navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Handle search action
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibilityLabel("Search Books")
                }
            }
        }
    }
}

// MARK: - Preview
struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
