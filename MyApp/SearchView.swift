//
//  SearchView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

// --- Data Models ---

struct Book: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let imageName: String // Assuming images are local assets
    let rating: Double
    let ratingCount: Int
    let price: String
    let isExpected: Bool = false // For simplicity, only one book is expected
    let expectedDate: String = ""
}

struct BookSection: Identifiable {
     let id = UUID()
     let title: String
     let subtitle: String
     let books: [Book]
}
// --- Dummy Data ---

// Create some mock data to populate the UI.  In a real app, this would come from a data source (e.g., API, Core Data).
let sampleBooks = [
    Book(title: "Onyx Storm", author: "Rebecca Yarros", imageName: "My-meme-microphone", rating: 4.6, ratingCount: 9100, price: "$14.99"),
    Book(title: "All Good People Here", author: "Ashley Flowers", imageName: "My-meme-original", rating: 4.2, ratingCount: 5500, price: "$12.99")
//    Book(title: "Robert Ludlum's The Bourne Escape", author: "Brian Freeman", imageName: "bourne_escape", rating: 0.0, ratingCount: 0, price: "$14.99", isExpected: true, expectedDate: "7/29/25")
]

let sampleComputerBooks = [
    Book(title: "Practical SQL", author: "Anthony DeBarros", imageName: "practical_sql", rating: 0.0, ratingCount: 0, price: ""),
    Book(title: "Foundations of Information Security", author: "Jason Andress", imageName: "foundations_of_information_security", rating: 0.0, ratingCount: 0, price: ""),
    Book(title: "CYBERNETICS", author: "Norbert Wiener", imageName: "cybernetics", rating: 0.0, ratingCount: 0, price: "")
]

let bookSections = [
    BookSection(title: "Discover", subtitle: "", books: sampleBooks),
    BookSection(title: "Computers & Internet", subtitle: "Here's what's trending in this genre.", books: sampleComputerBooks)
]
// --- Helper Views ---

// A reusable view to display a book cover image.
struct BookCoverImage: View {
    let imageName: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(8)
            .shadow(radius: 3)
    }
}

// A reusable view to display a book's details.
struct BookDetailView: View {
    let book: Book

    var body: some View {
        HStack(alignment: .top) {
            BookCoverImage(imageName: book.imageName, width: 60, height: 90) // Smaller image for the list

            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if !book.isExpected {
                  Text("\(book.ratingCount > 0 ? "2 Editions": "") \(book.rating > 0 ? "• ★ \(String(format: "%.1f", book.rating)) (\(book.ratingCount/1000))K)" : "")")
                       .font(.caption)
                       .foregroundColor(.secondary)
                }

                Spacer() // Push price to the bottom

                HStack{
                    Text(book.isExpected ? "Expected \(book.expectedDate)" : book.price)
                    .font(.headline)
                    .fontWeight(book.isExpected ? .regular : .bold)
                }
                
            }
            Spacer() // Pushes content to the left

        }
    }
}

// --- Main Content View ---

struct SearchView: View {
    @State private var searchText: String = "" // State for the search bar text
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // --- Search Bar ---
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Books & Audiobooks", text: $searchText)
                        Image(systemName: "mic.fill")
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding(.horizontal)

                   // --- Book Sections ---

                    ForEach(bookSections) { section in
                         Section(header:
                              VStack(alignment: .leading){
                              if !section.subtitle.isEmpty {
                                  HStack(alignment: .center){
                                       Image(systemName: "desktopcomputer")
                                       Text(section.title).font(.title)
                                  }
                                  Text(section.subtitle).font(.subheadline)
                              } else {
                                  Text(section.title).font(.largeTitle).bold()
                              }
                              
                         }.padding(.top)
                         )
                         {
                              if section.title == "Computers & Internet" {
                                   ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                             ForEach(section.books) { book in
                                                  BookCoverImage(imageName: book.imageName, width: 120, height: 180) // Larger images for horizontal scroll
                                             }
                                        }
                                   }
                              } else {
                                   ForEach(section.books){ book in
                                        BookDetailView(book: book).padding(.vertical, 4)
                                   }
                              }
                         }.padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Search") // Set the navigation bar title
            
            // --- Tab Bar ---
            // The TabView is usually outside the NavigationView to persist across different views.
        }
        .overlay(
           GeometryReader { geometry in
                VStack {
                    Spacer() // Pushes the TabView to the bottom
                    HStack {
                        Spacer()
                        TabButton(imageName: "house.fill", title: "Home")
                        Spacer()
                        TabButton(imageName: "books.vertical.fill", title: "Library")
                        Spacer()
                        TabButton(imageName: "bag.fill", title: "Book Store")
                        Spacer()
                        TabButton(imageName: "headphones.circle.fill", title: "Audiobooks")
                        Spacer()
                        TabButton(imageName: "magnifyingglass", title: "Search")
                        Spacer()
                    }
                    .padding(.top, 10)
                    .background(.thinMaterial) // Use a material background for better visual appearance
                   .frame(width: geometry.size.width) // Ensure the tab bar is full width
                }
            }.edgesIgnoringSafeArea(.bottom)
        )
    }
}
struct TabButton: View {
     let imageName: String
     let title: String
     var body: some View {
          VStack {
               Image(systemName: imageName)
                    .font(.title2)
               Text(title)
                    .font(.caption)
          }
          .foregroundColor(.secondary) // A more subtle color for unselected tabs
     }
}

// MARK: - Preview
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark) // Simulate dark mode
    }
}
