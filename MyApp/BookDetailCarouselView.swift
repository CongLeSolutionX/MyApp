//
//  BookDetailCarouselView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//


import SwiftUI

struct BookCardView: View {
    let book: BookForBookDetailCarouselView // Model for book data

    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.6, blue: 0.2), Color(red: 0.5, green: 0.3, blue: 0.1)]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading) {
                // Book Cover Image
                Image(book.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 225) // Smaller for card
                    .padding(.top)
                    .frame(maxWidth: .infinity)

                // Book Title (with link)
                Button(action: {
                    // Handle link action
                }) {
                    Text(book.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2) // Limit title to 2 lines
                        .multilineTextAlignment(.center)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)

                }
                .padding(.top, 2)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)

                // Book Description (Shortened)
                Text(book.shortDescription)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3) // Limit description
                    .padding(.top, 1)
                    .padding(.horizontal)

                // Action Buttons (Sample and Price)
                HStack {
                    Button(action: {
                        // Handle sample action
                    }) {
                        Text("Sample")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(16)
                    }

                    Spacer()

                    Button(action: {
                        // Handle purchase action
                    }) {
                        Text("$\(book.price, specifier: "%.2f")")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .frame(width: 250, height: 400) // Card dimensions
        .cornerRadius(20) // Rounded corners for the card
        .shadow(radius: 5) // Add a shadow
    }
}

struct BookCarouselView: View {
    let books: [BookForBookDetailCarouselView]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(books) { book in
                    BookCardView(book: book)
                }
            }
            .padding()
        }
    }
}

// --- Data Model and Sample Data ---

struct BookForBookDetailCarouselView: Identifiable {
    let id = UUID()
    let title: String
    let shortDescription: String
    let imageName: String
    let price: Double
    // Add more properties as needed (author, full description, etc.)
}

let sampleBooks = [
    BookForBookDetailCarouselView(title: "Python Essentials 1", shortDescription: "The Official OpenEDG Python Institute beginners course...", imageName: "bookCover", price: 19.99),
    BookForBookDetailCarouselView(title: "Swift Fundamentals", shortDescription: "Learn the basics of Swift programming.", imageName: "bookCover2", price: 24.99), //  Add bookCover2 image
    BookForBookDetailCarouselView(title: "Data Structures", shortDescription: "A comprehensive guide to data structures.", imageName: "bookCover3", price: 29.99), //  Add bookCover3 image
    BookForBookDetailCarouselView(title: "iOS Development", shortDescription: "Build your first iOS app.", imageName: "bookCover4", price: 34.99),  // Add bookCover4 image
    BookForBookDetailCarouselView(title: "Machine Learning", shortDescription: "Introduction to machine learning concepts.", imageName: "bookCover5", price: 39.99) //  Add bookCover5 image
]

// --- Main View with Tab Bar (Modified) ---
struct BookDetailCarouselView: View {
    var body: some View {
        NavigationView { // Add NavigationView
            ZStack {
                // Background (same as before)
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.6, blue: 0.2), Color(red: 0.5, green: 0.3, blue: 0.1)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                   // Top Navigation Buttons (placed in HStack for correct layout)
                    HStack {
                        Button(action: {
                            // Handle close action
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                        Button(action: {
                            // Handle add action
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding()
                        }
                        Button(action: {
                            // Handle more options action
                        }) {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.horizontal)

                    // Book Carousel
                    BookCarouselView(books: sampleBooks)
                    
                    Spacer() //push the tab bar to the bottom.

                    // Tab Bar (same as before)
                    HStack {
                        Button(action: {  }) {
                            VStack { Image(systemName: "house.fill"); Text("Home") } .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        Button(action: {  }) {
                            VStack { Image(systemName: "books.vertical.fill"); Text("Library") } .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        Button(action: {  }) {
                            VStack { Image(systemName: "bag.fill"); Text("Book Store") } .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        Button(action: {  }) {
                            VStack { Image(systemName: "headphones"); Text("Audiobooks") } .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        Button(action: {  }) {
                            VStack{ Image(systemName: "magnifyingglass"); Text("Search") } .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 10)
                    .background(Color.black.opacity(0.8))
                }
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarHidden(true) // Hide the default navigation bar
            }
        }
    }
}

// MARK: - Preview
struct BookDetailCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailCarouselView()
            .previewDevice("iPhone 14 Pro")
        
        BookDetailCarouselView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
