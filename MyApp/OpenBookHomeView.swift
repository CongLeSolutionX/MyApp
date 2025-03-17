//
//  OpenBookHomeView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

// MARK: - Data Models (Placeholders)

struct Book: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let rating: Double
    let isFree: Bool
    let details: String? // For "Currently Reading" section
}

// MARK: - View Components

// Reusable Book Cell for both "Popular" and "Currently Reading"
struct BookCell: View {
    let book: Book
    let isCurrentlyReading: Bool

    var body: some View {
        HStack(alignment: .top) {
            // Placeholder Image (Rounded Rectangle)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 90)

            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                Text("by \(book.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if isCurrentlyReading, let details = book.details  {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", book.rating))
                        .font(.caption)
                    
                    Spacer() // Push rating and free/continue to edges

                    if isCurrentlyReading {
                         Button("Continue") {
                            //Action
                         }
                         .buttonStyle(.borderedProminent)
                         .font(.caption)
                    } else {
                        Text(book.isFree ? "Free" : "Paid") // Show "Free" or "Paid
                            .font(.caption)
                            .foregroundColor(book.isFree ? .green : .red) // Different color
                    }

                }
                .padding(.top, 1)
            }
        }
        .padding(.vertical, 4) // Add some vertical padding
    }
}

// MARK: - Main View

struct OpenBookHomeView: View {
    // Sample Data (In a real app, this would come from a ViewModel)
    let popularBooks: [Book] = [
        Book(title: "The Whispers", author: "Ashley Audrain", rating: 4.9, isFree: true, details: nil),
        Book(title: "Banyan Moon", author: "Thao Thai", rating: 4.9, isFree: false, details: nil),
    ]

    let currentlyReadingBooks: [Book] = [
        Book(title: "Family Lore", author: "Elizabeth Acevedo", rating: 4.7, isFree: true, details: "BISAC3: FICTION: Literary - Page 235"),
        Book(title: "All the Gold Stars", author: "Rainesford Stauffer", rating: 4.7, isFree: true, details: "Page 109"),
    ]

    var body: some View {
        NavigationView { // For navigation title and potential navigation links
            ZStack { // Use ZStack to layer background image
                // Background Image (Placeholder)
                Image(systemName: "home") // Replace "background" with your actual asset name
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all) // Ensure it covers the whole screen
                    .blur(radius: 10) // Apply a blur effect
                
                // Main content with translucent background
                ScrollView {
                    VStack(alignment: .leading) {
                        // Header
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                            Spacer()
                            Image(systemName: "bell.badge")
                                .font(.title2)
                        }
                        .padding(.horizontal)

                        Text("New Day")
                            .font(.title2)
                            .padding(.horizontal)

                        Text("New Great Book")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // Popular Books Section
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Popular")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                                Button("See all") {
                                    // Action
                                }
                                .font(.subheadline)
                            }
                            .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(popularBooks) { book in
                                        BookCell(book: book, isCurrentlyReading: false)
                                            .frame(width: 250) // Set frame width
                                            .padding(.trailing, 8) // Add padding between
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)

                        // Currently Reading Section
                        VStack(alignment: .leading) {
                            Text("Currently reading")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            ForEach(currentlyReadingBooks) { book in
                                BookCell(book: book, isCurrentlyReading: true)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)

                        Spacer() // Push content to the top
                    }
                    .padding(.top) // Add padding at the top
                    .background(Color.white.opacity(0.8)) // Translucent background
                    .cornerRadius(20) // Rounded corners for the content area
                }
                
                // Tab Bar (Custom)
                VStack{
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "house.fill")
                            .font(.title2)
                        Spacer()
                        Image(systemName: "book.closed")
                            .font(.title2)
                        Spacer()
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 25)) // Rounded corners
                    .padding(.horizontal)
                }

            }
            .navigationBarHidden(true) // Hide the default navigation bar
        }
    }
}

// MARK: - Preview

struct OpenBookHomeView_Previews: PreviewProvider {
    static var previews: some View {
        OpenBookHomeView()
            .previewDevice("iPhone 14 Pro") // Or any other device
        OpenBookHomeView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
