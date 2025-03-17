//
//  LibraryView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct Book: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let imageName: String
}

struct LibraryView: View {
    @State private var searchText: String = ""

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
                        // Handle Collections action
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
                    .buttonStyle(PlainButtonStyle()) // Remove default button styling
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

                                Text("SAMPLE") // Sample Label
                                 .font(.caption)
                                 .padding(.top,2)
                                 .foregroundColor(.gray)

                                 HStack{
                                    Spacer()
                                    Image(systemName: "ellipsis.circle") // Added the circle
                                        .foregroundColor(.gray)
                                    }

                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10) // Reduce padding at the top

                }
                .searchable(text: $searchText) // Search Bar
            }
            .navigationBarHidden(true) // Hide default navigation bar

             // Tab Bar (Custom)
            .safeAreaInset(edge: .bottom){
                createTabBar()
            }
        }

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
        .padding(.vertical, 10) // Reduce padding at the top and bottom of the tab bar
        .background(Color(.systemGray6)) // Light gray background
        .foregroundColor(.gray)

    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .preferredColorScheme(.dark)
    }
}
