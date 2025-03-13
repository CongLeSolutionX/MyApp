////
////  HomeScreenView.swift
////  MyApp
////
////  Created by Cong Le on 3/12/25.
////
//
//import SwiftUI
//
//// Sample data using the unified Book2 model
//let newGreatBooks: [Book2] = [
//    Book2(title: "SwiftUI in Action", author: "John Doe", coverImageName: "book1", rating: 4.5, currentPage: 0, totalPages: 300, categories: ["Tech"], isBookmarked: false),
//    Book2(title: "Modern iOS", author: "Jane Smith", coverImageName: "book2", rating: 4.0, currentPage: 0, totalPages: 250, categories: ["Programming"], isBookmarked: false)
//]
//
//let popularBooks: [Book2] = [
//    Book2(title: "Advanced Swift", author: "Albert Roe", coverImageName: "book3", rating: 4.8, currentPage: 0, totalPages: 320, categories: ["Development"], isBookmarked: false),
//    Book2(title: "Design Patterns in Swift", author: "Catherine Lee", coverImageName: "book4", rating: 4.2, currentPage: 0, totalPages: 280, categories: ["Architecture"], isBookmarked: false)
//]
//
//let currentlyReadingBooks: [Book2] = [
//    Book2(title: "iOS Development Essentials", author: "Michael Johnson", coverImageName: "book5", rating: nil, currentPage: 109, totalPages: 200, categories: ["Learning"], isBookmarked: false),
//    Book2(title: "App Architecture Patterns", author: "Susan Davis", coverImageName: "book6", rating: nil, currentPage: 50, totalPages: 150, categories: ["Learning"], isBookmarked: false)
//]
//
//struct HomeScreenView: View {
//    @State private var isSearching = false
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//
//                    SectionHeader(title: "New Great Books")
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 16) {
//                            ForEach(newGreatBooks) { book in
//                                NavigationLink(destination: BookDetailView(book: book)) {
//                                    BookCardView2(book: book)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//
//                    SectionHeader(title: "Popular")
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 16) {
//                            ForEach(popularBooks) { book in
//                                NavigationLink(destination: BookDetailView(book: book)) {
//                                    BookCardView2(book: book)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//
//                    SectionHeader(title: "Currently Reading")
//                    LazyVStack(spacing: 16) {
//                        ForEach(currentlyReadingBooks) { book in
//                            NavigationLink(destination: BookDetailView(book: book)) {
//                                CurrentlyReadingCard(book: book)
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .padding(.vertical)
//            }
//            .navigationTitle("Books")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        isSearching.toggle() // Toggle action for search functionality
//                    } label: {
//                        Image(systemName: "magnifyingglass")
//                    }
//                }
//            }
//        }
//    }
//}
//
//// Reusable UI Components
//struct SectionHeader: View {
//    let title: String
//    var body: some View {
//        Text(title)
//            .font(.title2)
//            .fontWeight(.bold)
//            .padding(.horizontal)
//    }
//}
//
//struct BookCardView2: View {
//    let book: Book2
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Image(book.coverImageName)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 120, height: 180)
//                .clipped()
//                .cornerRadius(8)
//            Text(book.title)
//                .font(.headline)
//                .lineLimit(2)
//            Text(book.author)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//        }
//        .frame(width: 120)
//        .contentShape(Rectangle()) // Ensures entire view is tappable without extra button style
//    }
//}
//
//struct CurrentlyReadingCard: View {
//    let book: Book2
//    var body: some View {
//        HStack(spacing: 16) {
//            Image(book.coverImageName)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 80, height: 120)
//                .clipped()
//                .cornerRadius(8)
//            VStack(alignment: .leading, spacing: 8) {
//                Text(book.title)
//                    .font(.headline)
//                    .lineLimit(2)
//                Text(book.author)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                ProgressView(value: Float(book.currentPage), total: Float(book.totalPages))
//                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
//                Text("Page \(book.currentPage)")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            Spacer()
//        }
//        .padding(.vertical, 8)
//        .contentShape(Rectangle())
//    }
//}
//
//struct HomeScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeScreenView()
//    }
//}
