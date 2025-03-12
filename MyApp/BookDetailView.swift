//
//  BookDetailView.swift
//  MyApp
//
//  Created by Cong Le on 3/12/25.
//

import SwiftUI

// MARK: - Data Model
struct Book2: Identifiable {
    let id: Int
    let title: String
    let author: String
    let coverImageName: String // Name of the local asset image (or use URL image logic)
    let currentPage: Int
    let totalPages: Int
    let categories: [String]
    var isBookmarked: Bool
}

// MARK: - Book Detail View
struct BookDetailView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State var book: Book2

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Book cover image
                Image(book.coverImageName)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                    .shadow(radius: 4)
                
                // Title and Author
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    Text("by \(book.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Progress Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress: \(book.currentPage) / \(book.totalPages) pages")
                        .font(.footnote)
                    
                    // Using SwiftUI's ProgressView with custom styling
                    ProgressView(value: Float(book.currentPage), total: Float(book.totalPages))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 8)
                        .clipShape(Capsule())
                }
                
                // Category Tags (horizontal scroll)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(book.categories, id: \.self) { category in
                            Text(category)
                                .font(.caption)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
                
                // Continue Reading Button
                Button(action: {
                    // Add action to resume reading from the current page.
                }) {
                    Text("Continue Reading")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarTitle("Book Details", displayMode: .inline)
        .navigationBarItems(
            leading: Button(action: {
                // Dismiss or pop the view
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }),
            trailing: Button(action: {
                // Toggle bookmark state
                book.isBookmarked.toggle()
            }, label: {
                Image(systemName: book.isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundColor(.blue)
            })
        )
    }
}

// MARK: - Preview
struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookDetailView(book: Book2(id: 1,
                                      title: "The Great Book",
                                      author: "John Doe",
                                      coverImageName: "bookCoverSample", // ensure this asset exists
                                      currentPage: 120,
                                      totalPages: 300,
                                      categories: ["Fiction", "Literary", "Adventure"],
                                      isBookmarked: false))
        }
    }
}
