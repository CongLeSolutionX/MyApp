//
//  FeedItemView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//
import SwiftUI


// MARK: - Feed Item View (for list in FeedView)
struct FeedItemView: View {
    let article: Article

    var body: some View {
        HStack(alignment: .top) {
            Image(article.imageName)
                .resizable()
                .scaledToFill() // Use scaledToFill for consistent aspect ratio
                .frame(width: 100, height: 100)
                .clipped() // Clip to bounds after scaling
                .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(Color("on-surface"))
                    .lineLimit(2) // Limit to 2 lines for preview
                Text("\(article.date) • \(article.author.name)")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
            Spacer() // Push content to the left
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
// MARK: - Preview
#Preview {
    FeedItemView(article: .init(title: "Test Article", date: "1d ago", author: .init(name: "Test Author", imageName: "house"), url: "https://example.com", imageName: "placeholderImage3", topics: [], isBookmarked: false, updatesSinceLastViewed: 0))
}
