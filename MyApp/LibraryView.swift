//
//  LibraryView.swift
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
    let imageName: String
}

struct CollectionItem: Identifiable {
    let id = UUID()
    let title: String
    let count: Int?
    let iconName: String
}

// --- Views ---

struct CollectionsView: View {
    @Environment(\.presentationMode) var presentationMode  // To dismiss the view

    let collections: [CollectionItem] = [
        CollectionItem(title: "Want to Read", count: nil, iconName: "arrow.right.circle"),
        CollectionItem(title: "Finished", count: 9, iconName: "checkmark.circle"),
        CollectionItem(title: "Books", count: 29, iconName: "book.closed"),
        CollectionItem(title: "Audiobooks", count: nil, iconName: "headphones"),
        CollectionItem(title: "PDFs", count: 9, iconName: "doc.text"),
        CollectionItem(title: "My Samples", count: 10, iconName: "doc.richtext"),
        CollectionItem(title: "Downloaded", count: 14, iconName: "icloud.and.arrow.down"),
        CollectionItem(title: "My Books", count: 25, iconName: "books.vertical"),
        CollectionItem(title: "New Collection...", count: nil, iconName: "plus.circle") // Added "New Collection..."
    ]

    var body: some View {
        NavigationView { // Use NavigationView
            List {
                ForEach(collections) { collection in
                    HStack {
                        Image(systemName: collection.iconName)
                            .foregroundColor(.gray)  // Set icon color
                        Text(collection.title)
                        Spacer()
                        if let count = collection.count {
                            Text("\(count)")
                                .foregroundColor(.gray)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Collections")
            .navigationBarTitleDisplayMode(.large)
             .toolbar { // Use .toolbar for correct placement
                ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left") // Back arrow
                                Text("Library")
                            }
                        }
                    }
                ToolbarItem(placement: .navigationBarTrailing) { // Edit button
                        Button("Edit") {
                            // Handle edit action
                        }
                }
            }
            .listStyle(PlainListStyle())  // Use PlainListStyle to remove extra padding
        }
    .navigationViewStyle(StackNavigationViewStyle()) // Avoid Double Column on iPad
    }
}

struct LibraryView: View {
    @State private var searchText: String = ""
    @State private var showingCollections = false // State to control sheet presentation

    let books: [Book] = [
        Book(title: "The Alignment Problem", author: "Brian Christian", imageName: "My-meme-heineken"),
        Book(title: "SwiftUI for Dummies", author: "Wei-Meng Lee", imageName: "My-meme-red-wine-glass"),
        Book(title: "Starter's Guide", author: "Roelf Sluman", imageName: "My-meme-cordyceps"),
        Book(title: "Apple Style Guide", author: "October 2022", imageName: "My-meme-microphone"),
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Title
                    Text("Library")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 20)

                    // Collections Button
                    Button(action: {
                        showingCollections = true // Show the sheet
                    }) {
                        HStack {
                            Image(systemName: "folder")
                            Text("Collections")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)

                    // Book Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(books) { book in
                            VStack(alignment: .leading) {
                                Image(book.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(8)
                                    .shadow(radius: 4)

                                Text("SAMPLE")
                                    .font(.caption)
                                    .padding(.top, 2)
                                    .foregroundColor(.gray)

                                HStack {
                                    Spacer()
                                    Image(systemName: "ellipsis.circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .searchable(text: $searchText)
            }
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                createTabBar()
            }
            .sheet(isPresented: $showingCollections) {
                CollectionsView() // Present the CollectionsView as a sheet
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // For iPad support

    }
    func createTabBar() -> some View{
        HStack {
            Button(action: {
                // Handle Home action
            }) {
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            }

            Spacer()

            Button(action: {
                // Handle Library action
            }) {
                VStack {
                    Image(systemName: "books.vertical.fill") // Changed icon for Library
                    Text("Library")
                }
            }

            Spacer()

            Button(action: {
                // Handle Book Store action
            }) {
                VStack {
                    Image(systemName: "bag.fill") // Changed icon for Book Store
                    Text("Book Store")
                }
            }

            Spacer()

            Button(action: {
                // Handle Audiobooks action
            }) {
                VStack {
                    Image(systemName: "headphones")
                    Text("Audiobooks")
                }
            }
            Spacer()

            Button(action: {
                // Handle Search action
            }) {
                VStack{
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .foregroundColor(.gray)

    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .preferredColorScheme(.dark)
        
        CollectionsView()
    }
}
