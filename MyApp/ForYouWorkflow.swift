//
//  ForYouWorkflow.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//
import SwiftUI

// MARK: - Models

struct Topic: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbol name
    var isSelected: Bool = false
}

struct Author: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let author: Author
    let url: String
    let imageName: String
    let topics: [Topic]
    let isBookmarked: Bool
    let updatesSinceLastViewed: Int
}

// MARK: - Data (Placeholder and Fake Data)

let placeholderTopics: [Topic] = [
    Topic(name: "Technology", icon: "laptopcomputer"),
    Topic(name: "Design", icon: "paintpalette"),
    Topic(name: "Gaming", icon: "gamecontroller"),
    Topic(name: "Mobile", icon: "iphone"),
    Topic(name: "Web Dev", icon: "globe"),
    Topic(name: "AI", icon: "brain"),
    Topic(name: "Data Science", icon: "chart.bar"),
    Topic(name: "UX/UI", icon: "person.crop.artframe"),
    Topic(name: "Cloud", icon: "cloud"),
    Topic(name: "Security", icon: "shield")
]

let placeholderAuthor = Author(name: "Jane Doe", imageName: "person.circle.fill") // SF Symbol

let placeholderArticles: [Article] = [
    Article(
        title: "The Future of Mobile Development",
        date: "March 15, 2024",
        author: placeholderAuthor,
        url: "example.com/article1",
        imageName: "placeholderImage1", // Replace with actual asset name
        topics: [
            placeholderTopics[0],
            placeholderTopics[3],
            placeholderTopics[4]
        ],
        isBookmarked: false,
        updatesSinceLastViewed: 2
    ),
    Article(
        title: "AI-Powered Design Tools",
        date: "March 10, 2024",
        author: Author(name: "John Smith", imageName: "person.circle.fill"),
        url: "example.com/article2",
        imageName: "placeholderImage2", // Replace with actual asset name
        topics: [
            placeholderTopics[1],
            placeholderTopics[5],
            placeholderTopics[7]
        ],
        isBookmarked: true,
        updatesSinceLastViewed: 5
    ),
    Article(
        title: "Mastering Cloud Security",
        date: "February 28, 2024",
        author: placeholderAuthor,
        url: "example.com/article3",
        imageName: "placeholderImage3",
        topics: [
            placeholderTopics[8],
            placeholderTopics[9]
        ],
        isBookmarked: false,
        updatesSinceLastViewed: 0
    )
]

// MARK: - Main View

struct ForYouContentView: View {
    @State private var selectedTopics: Set<Topic> = []
    @State private var isShowingOnboarding = true // Start with onboarding
    @State private var selectedArticle: Article? = nil // No article selected initially
    @State private var selectedTabIndex = 0
    @State private var articles: [Article] = placeholderArticles  // Use placeholder articles

    var body: some View {
        NavigationView {
            ZStack {
                // Main Content View
                VStack {
                    // App Bar
                    AppBarView(selectedArticle: $selectedArticle)

                    if isShowingOnboarding {
                        OnboardingView(topics: placeholderTopics, selectedTopics: $selectedTopics) {
                            isShowingOnboarding = false
                        }
                    } else {
                        // Main Feed (using placeholder articles)
                        if selectedTabIndex == 0 { // "For you" tab
                            // Show ArticleView if an article is selected, otherwise show the feed
                            if let article = selectedArticle {
                                ArticleView(article: article)
                            } else {
                                FeedView(articles: $articles, selectedArticle: $selectedArticle)
                            }
                        }
                         else { // Placeholder content for other tabs
                            Spacer()
                            Text(tabBarTitle(for: selectedTabIndex))
                                .foregroundColor(Color("on-surface"))
                            Spacer()
                        }
                    }

                    // Tab Bar
                    TabBarView(selectedIndex: $selectedTabIndex)
                }
            }
            .navigationBarHidden(true)
            .background(Color("background")) // Use named colors for better management
        }
    }
    
    private func tabBarTitle(for index: Int) -> String {
            switch index {
            case 1: return "Episodes Content"
            case 2: return "Saved Content"
            case 3: return "Interests Content"
            default: return ""
            }
        }
}

// MARK: - AppBarView

struct AppBarView: View {
    @Binding var selectedArticle: Article?

    var body: some View{
        HStack {
            Button(action: {
                // Handle search action
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("on-surface"))
            }

            Spacer()

            Text("Now in Android")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("on-surface"))

            Spacer()

            Button(action: {
                selectedArticle = selectedArticle == nil ? placeholderArticles.first : nil
            }) {
                Image(systemName: "person.circle")
                    .foregroundColor(Color("on-surface"))
            }
        }
        .padding()
        .background(Color("surface"))
    }
}

// MARK: - Tab Bar View
struct TabBarView: View {
    @Binding var selectedIndex: Int
    
    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "For you"),
        ("play.rectangle.fill", "Episodes"),
        ("bookmark.fill", "Saved"),
        ("tag.fill", "Interests")
    ]

    var body: some View {
        HStack {
            ForEach(tabs.indices, id: \.self) { index in
                TabBarItem(
                    index: index,
                    selectedIndex: $selectedIndex,
                    icon: tabs[index].icon,
                    label: tabs[index].label
                )
            }
        }
        .padding(.vertical, 8)
        .background(Color("background"))
        .frame(maxWidth: .infinity)
    }
}

struct TabBarItem: View {
    let index: Int
    @Binding var selectedIndex: Int
    let icon: String
    let label: String

    var body: some View {
        Button(action: {
            selectedIndex = index
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20)) // Adjust size as needed
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(selectedIndex == index ? Color("primary-container") : Color("on-surface"))
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    let topics: [Topic]
    @Binding var selectedTopics: Set<Topic>
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("What are you interested in?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                    .foregroundColor(Color("on-surface"))

                Text("Updates from interests you follow will appear here. Follow some things to get started.")
                    .foregroundColor(Color("on-surface"))
                    .padding(.bottom)

                // Topic Selection (using a flexible grid)
                TopicGridView(topics: topics, selectedTopics: $selectedTopics)

                Button(action: onDone) {
                    Text("Done")
                        .fontWeight(.bold)
                        .foregroundColor(Color("on-primary-container"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("primary-container"))
                        .cornerRadius(8)
                }
                .padding(.vertical)

                Button(action: {
                    // Placeholder for "Browse topics"
                }) {
                    Text("Browse topics")
                        .foregroundColor(Color("on-surface"))
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .background(Color("surface")) // Consistent background
    }
}

// MARK: - Flexible Topic Grid View

struct TopicGridView: View {
    let topics: [Topic]
    @Binding var selectedTopics: Set<Topic>
    @State private var availableWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(topics, id: \.self) { topic in
                TopicItemView(topic: topic, isSelected: selectedTopics.contains(topic)) {
                    if selectedTopics.contains(topic) {
                        selectedTopics.remove(topic)
                    } else {
                        selectedTopics.insert(topic)
                    }
                }
                .padding(4)
                .alignmentGuide(.leading, computeValue: { d in
                    if (abs(width - d.width) > geometry.size.width) {
                        width = 0
                        height -= d.height
                    }
                    let result = width
                    if topic == self.topics.last! {
                        width = 0 //last item
                    } else {
                        width -= d.width
                    }
                    return result
                })
                .alignmentGuide(.top, computeValue: {d in
                    let result = height
                    if topic == self.topics.last! {
                        height = 0 // last item
                    }
                    return result
                })
            }
        }
    }
}

// MARK: - Topic Item View

struct TopicItemView: View {
    let topic: Topic
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: topic.icon)
                Text(topic.name)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(isSelected ? Color("inverse-on-surface") : Color("on-surface"))
            .background(isSelected ? Color("inverse-surface") : Color("surface"))
            .cornerRadius(20) // Rounded corners for the "chip" style
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("on-surface"), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

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

struct ForYouContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouContentView()
            .preferredColorScheme(.light)

        ForYouContentView()
            .preferredColorScheme(.dark)
    }
}
