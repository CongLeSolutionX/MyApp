//
//  HomeScreenView.swift
//  MyApp
//
//  Created by Cong Le on 3/12/25.
//

import SwiftUI

// MARK: - Data Model

struct Book2: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let coverImageName: String // Name of the image asset in your project
    let rating: Double?        // Optional rating property
}

// Sample data for each section
let newGreatBooks: [Book2] = [
    Book2(title: "SwiftUI in Action", author: "John Doe", coverImageName: "book1", rating: 4.5),
    Book2(title: "Modern iOS", author: "Jane Smith", coverImageName: "book2", rating: 4.0)
]

let popularBooks: [Book2] = [
    Book2(title: "Advanced Swift", author: "Albert Roe", coverImageName: "book3", rating: 4.8),
    Book2(title: "Design Patterns in Swift", author: "Catherine Lee", coverImageName: "book4", rating: 4.2)
]

let currentlyReadingBooks: [Book2] = [
    Book2(title: "iOS Development Essentials", author: "Michael Johnson", coverImageName: "book5", rating: nil),
    Book2(title: "App Architecture Patterns", author: "Susan Davis", coverImageName: "book6", rating: nil)
]

// MARK: - Main/Home Screen Implementation

struct HomeScreenView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: New Great Book Section
                    SectionHeader(title: "New Great Book")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(newGreatBooks) { book in
                                BookCardView2(book: book)
                            }
                        }
                        .padding(.horizontal)
                        .background(Color.red.opacity(0.5))
                    }
                    
                    // MARK: Popular Section
                    SectionHeader(title: "Popular")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(popularBooks) { book in
                                BookCardView2(book: book)
                            }
                        }
                        .padding(.horizontal)
                        .background(Color.orange.opacity(0.5))
                    }
                    
                    // MARK: Currently Reading Section
                    SectionHeader(title: "Currently Reading")
                    VStack(spacing: 16) {
                        ForEach(currentlyReadingBooks) { book in
                            CurrentlyReadingCard(book: book)
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.yellow.opacity(0.5))
                }
                .padding(.vertical)
            }
            .navigationTitle("Books")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add your search action here
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
    }
}

// MARK: - Reusable UI Components

// Section header view to display section titles
struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal)
    }
}

// View for displaying a book in horizontal scrolling sections ("New Great Book" and "Popular")
struct BookCardView2: View {
    let book: Book2
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Replace "book.coverImageName" with the appropriate asset name in your Assets catalog
            Image(book.coverImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 180)
                .clipped()
                .cornerRadius(8)
                .background(Color.gray.opacity(0.2))
            Text(book.title)
                .font(.headline)
                .lineLimit(2)
            Text(book.author)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
    }
}

// View for displaying a currently reading book with additional details (e.g., a progress bar, current page)
struct CurrentlyReadingCard: View {
    let book: Book2
    var body: some View {
        HStack(spacing: 16) {
            Image(book.coverImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 120)
                .clipped()
                .cornerRadius(8)
                .background(Color.gray.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Simulated progress view; in a real app, the progress value would be dynamic.
                ProgressView(value: 0.5)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                
                Text("Page 109")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
