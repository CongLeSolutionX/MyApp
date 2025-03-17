//
//  FeedView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI


// MARK: - Feed View
struct FeedView: View {
    @Binding var articles: [Article]
    @Binding var selectedArticle: Article?

    var body: some View {
        ScrollView {
            LazyVStack { // Use LazyVStack for performance with lists
                ForEach(articles) { article in
                    Button(action: {
                        selectedArticle = article
                    }) {
                        FeedItemView(article: article)
                    }
                    .buttonStyle(PlainButtonStyle()) // Remove button highlight
                    Divider()
                }
            }
        }
        .background(Color("surface"))
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var articles: [Article] = placeholderArticles
    @Previewable @State var selectedArticle: Article? = nil // No article selected initially
    FeedView(articles: $articles, selectedArticle: $selectedArticle)
    
}
