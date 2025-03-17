//
//  ArticleView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

// MARK: - Article View (Simplified)
struct ArticleView: View {
    let article: Article

    @State private var selectedSortOption = 0 // 0: Newest First, 1: Oldest First
    let sortOptions = ["Newest first", "Oldest first"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    // Filter Dropdown (using Picker)
                    Menu {
                        Picker(selection: $selectedSortOption, label: EmptyView()) {
                            ForEach(0..<sortOptions.count, id: \.self) { index in
                                Text(sortOptions[index]).tag(index)
                            }
                        }
                    } label: {
                        HStack {
                            Text(sortOptions[selectedSortOption])
                                .foregroundColor(Color("on-surface"))
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color("on-surface"))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("surface"))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("on-surface"), lineWidth: 1)
                        )
                    }

                    Spacer()

                    // Compact View Toggle
                    Button(action: {
                        // Toggle compact view
                    }) {
                        HStack {
                            Text("Compact view")
                                .foregroundColor(Color("on-surface"))
                            Image(systemName: "list.bullet") // Or any other suitable icon
                                .foregroundColor(Color("on-surface"))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("surface"))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("on-surface"), lineWidth: 1)
                        )
                    }
                }

                Divider()

                HStack{
                    Text("\(article.updatesSinceLastViewed) updates since you last vist")
                        .font(.caption).italic()
                        .foregroundColor(Color.red)
                    Spacer()
                    Button(action: {}){
                        Image(systemName: "xmark")
                            .foregroundColor(Color("on-surface"))
                    }
                }

                Image(article.imageName)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)

                HStack {
                    Image(systemName: article.author.imageName) // Use SF Symbol
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle()) // Clip to circle
                    Text(article.author.name)
                        .font(.caption)
                        .foregroundColor(Color("on-surface"))
                    Spacer()
                }

                Text(article.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("on-surface"))

                Text("\(article.date) • \(article.url)")
                    .font(.caption)
                    .foregroundColor(Color("on-surface"))

                Text("In this codelab, you can learn how Wear OS can work with Compose, what Wear OS specific composables are available, and more!") // Placeholder
                    .font(.body)
                    .foregroundColor(Color("on-surface"))
                    .padding(.bottom)

                // Topic Tags
                HStack {
                    ForEach(article.topics, id: \.self) { topic in
                        HStack{
                            Text(topic.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundColor(Color("on-surface"))
                                .background(Color("surface"))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("on-surface"), lineWidth: 1)
                                )

                        }

                    }
                    Button(action:{}){
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color("on-surface"))
                    }
                }
                .padding(.bottom)

            }
            .padding()
        }
        .background(Color("surface")) // Set background for the whole ArticleView
    }
}
// MARK: - Preview
#Preview {
    let article = Article(title: "Sample Article", date: "Change this date later", author: Author(name: "Cong Le", imageName: "keyboard"), url: "Change this url link later", imageName: "placeholderImage1", topics: [Topic(name: "Swift", icon: "computer")], isBookmarked: true, updatesSinceLastViewed: 4)
    
    
    ArticleView(article: article)
}
