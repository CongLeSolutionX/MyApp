//
//  BookDetailView.swift
//  MyApp
//
//  Created by Cong Le on 3/12/25.
//

import SwiftUI

struct BookDetailView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State var book: Book2  // unified Book2 model

    @State private var continueReading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(book.coverImageName)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                    .shadow(radius: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    Text("by \(book.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress: \(book.currentPage) / \(book.totalPages) pages")
                        .font(.footnote)
                    ProgressView(value: Float(book.currentPage), total: Float(book.totalPages))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 8)
                        .clipShape(Capsule())
                }
                
                if !book.categories.isEmpty {
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
                }
                
                Button {
                    continueReading.toggle() // Toggle continue reading state
                } label: {
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
            leading: Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            },
            trailing: Button {
                book.isBookmarked.toggle()
            } label: {
                Image(systemName: book.isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundColor(.blue)
            }
        )
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookDetailView(book: Book2(title: "The Great Book", author: "John Doe", coverImageName: "bookCoverSample", rating: nil, currentPage: 120, totalPages: 300, categories: ["Fiction", "Adventure"], isBookmarked: false))
        }
    }
}
