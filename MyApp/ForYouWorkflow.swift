//
//  ForYouWorkflow.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//
import SwiftUI

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

// MARK: - Preview

struct ForYouContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouContentView()
            .preferredColorScheme(.light)

        ForYouContentView()
            .preferredColorScheme(.dark)
    }
}
