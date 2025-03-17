//
//  ForYouWorkFlow.swift
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

// MARK: - Data (Sample Data for Demonstration)

let sampleTopics: [Topic] = [
    Topic(name: "Fernando", icon: "person.circle"),
    Topic(name: "Alex", icon: "person.circle"),
    Topic(name: "Sam", icon: "person.circle"),
    Topic(name: "Lee", icon: "person.circle"),
    Topic(name: "Accessibility", icon: "figure.walk"),
    Topic(name: "Android TV", icon: "tv"),
    Topic(name: "Android Auto", icon: "car"),
    Topic(name: "Architecture", icon: "building.columns"),
    Topic(name: "Android Studio", icon: "laptopcomputer"),
    Topic(name: "Compose", icon: "pencil.tip.crop.circle")
]

let sampleAuthor = Author(name: "Author", imageName: "person.circle.fill")

let sampleArticle = Article(
    title: "New Compose for Wear OS codelab",
    date: "January 1, 2021",
    author: sampleAuthor,
    url: "developer.android.com",
    imageName: "watchface",  // Placeholder.  Replace with actual asset name.
    topics: [
        Topic(name: "Topic", icon: "tag"),
        Topic(name: "Compose", icon: "pencil.tip.crop.circle"),
        Topic(name: "Events", icon: "calendar"),
        Topic(name: "Performance", icon: "speedometer")
    ],
    isBookmarked: false,
    updatesSinceLastViewed: 3
)

// MARK: - Main View

struct ForYouContentView: View {
    @State private var selectedTopics: Set<Topic> = []
    @State private var isShowingOnboarding = true // Start with onboarding
    @State private var selectedArticle: Article? = sampleArticle // For demonstration
    @State private var selectedTabIndex = 0

    var body: some View {
        NavigationView {
            ZStack {
                // Main Content View
                VStack {
                    // App Bar
                    AppBarView(selectedArticle: $selectedArticle)
                    
                    if isShowingOnboarding {
                        OnboardingView(topics: sampleTopics, selectedTopics: $selectedTopics) {
                            isShowingOnboarding = false
                        }
                    } else if let article = selectedArticle {
                        // Simplified Article View
                        ArticleView(article: article)
                        
                    }
                    else
                    {
                        // Placeholder for the main feed (empty in this example)
                        Spacer()
                        Text("Main feed content would go here.")
                        Spacer()
                    }
                    
                    // Tab Bar
                    
                    TabBarView(selectedIndex: $selectedTabIndex)
                }
                
            }
            
            .navigationBarHidden(true)
            .background(Color("background")) // Use named colors for better management
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
                selectedArticle = selectedArticle == nil ? sampleArticle : nil
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
    
    var body: some View {
        HStack {
            TabBarItem(index: 0, selectedIndex: $selectedIndex, icon: "house.fill", label: "For you")
            TabBarItem(index: 1, selectedIndex: $selectedIndex, icon: "play.rectangle.fill", label: "Episodes")
            TabBarItem(index: 2, selectedIndex: $selectedIndex, icon: "bookmark.fill", label: "Saved")
            TabBarItem(index: 3, selectedIndex: $selectedIndex, icon: "tag.fill", label: "Interests")
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

// MARK: - Preview
//
//struct ForYouContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForYouContentView()
//            .preferredColorScheme(.light)
//        
//        ForYouContentView()
//            .preferredColorScheme(.dark)
//    }
//}
