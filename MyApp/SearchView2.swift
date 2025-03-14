//
//  SearchView.swift
//  MyApp
//
//  Created by Cong Le on 3/13/25.
//

import SwiftUI

// MARK: - Sample Data for Search
private let sampleSearchBooks: [Book] = [
    Book(title: "Swift Basics", author: "John Swift", coverImageName: "book.fill", currentPage: 0, totalPages: 150, categories: ["nil"]),
    Book(title: "Design Patterns in iOS", author: "Anne Dev", coverImageName: "book.fill", currentPage: 0, totalPages: 300, categories: ["nil"]),
    Book(title: "Networking with Combine", author: "Tom Combine", coverImageName: "book.fill", currentPage: 0, totalPages: 220, categories: ["nil"]),
    Book(title: "Core Data Mastery", author: "Emily Core", coverImageName: "book.fill", currentPage: 0, totalPages: 400, categories: ["nil"]),
    Book(title: "SwiftUI Advanced Layouts", author: "Morgan U", coverImageName: "book.fill", currentPage: 10, totalPages: 300, categories: ["nil"]),
]

// MARK: - Search View
struct SearchView: View {
    @State private var searchTerm: String = ""
    @State private var searchResults: [Book] = []

    var body: some View {
        NavigationStack {
            ZStack {
                // Background rectangle or any custom background layer
                Rectangle()
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                    .ignoresSafeArea()

                VStack {
                    // Search bar at the top
                    TextField("Search books...", text: $searchTerm, onCommit: {
                        performSearch()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchTerm) { _ in
                        // Optionally perform live searching:
                        // performSearch()
                    }

                    // Display horizontal scroll of results
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 16) {
                            ForEach(searchResults) { book in
                                BookCardView(book: book)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Search")
        }
        .onAppear {
            // Optionally load initial results or leave empty
            searchResults = sampleSearchBooks
        }
    }

    // MARK: - Search Logic
    private func performSearch() {
        // Filter sample data by searchTerm;
        // In production, call an API or a local database query here.
        let lowercasedTerm = searchTerm.lowercased()
        if !lowercasedTerm.isEmpty {
            searchResults = sampleSearchBooks.filter {
                $0.title.lowercased().contains(lowercasedTerm)
                || $0.author.lowercased().contains(lowercasedTerm)
            }
        } else {
            // If there's no search term, you could clear or set default items:
            searchResults = sampleSearchBooks
        }
    }
}

// MARK: - Preview
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}


import SwiftUI

// MARK: - Sample Onboarding Step Model
struct OnboardingStep {
    let imageName: String
    let title: String
    let description: String
}

private let sampleOnboardingSteps: [OnboardingStep] = [
    OnboardingStep(
        imageName: "books.vertical.fill",
        title: "Track Your Books",
        description: "Keep a record of all your books in one easy-to-use place."
    ),
    OnboardingStep(
        imageName: "magnifyingglass",
        title: "Search & Discover",
        description: "Find new books via online search with quick lookups."
    ),
    OnboardingStep(
        imageName: "book.closed.fill",
        title: "Stay Organized",
        description: "Keep notes, update progress, and manage your reading lists."
    )
]

// MARK: - OnboardingPage View
struct OnboardingPage: View {
    let step: OnboardingStep
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: step.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding()
            
            Text(step.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(step.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
}

// MARK: - OnboardingView
struct OnboardingView: View {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    
    @State private var currentIndex = 0
    
    // Example onboarding steps
    private let steps: [OnboardingStep] = sampleOnboardingSteps
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(0..<steps.count, id: \.self) { index in
                    OnboardingPage(step: steps[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            HStack {
                // Skip button
                Button(action: {
                    // Immediately finalize onboarding
                    isOnboardingComplete = true
                }, label: {
                    Text("Skip")
                        .foregroundColor(.blue)
                })
                .opacity(currentIndex < steps.count - 1 ? 1.0 : 0.0)
                
                Spacer()
                
                // Next / Get Started button
                Button(action: {
                    if currentIndex < steps.count - 1 {
                        // Move to the next page
                        currentIndex += 1
                    } else {
                        // Final page: complete onboarding
                        isOnboardingComplete = true
                    }
                }, label: {
                    Text(currentIndex < steps.count - 1 ? "Next" : "Get Started")
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .cornerRadius(8)
                })
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Integration with main app
// In a real app, you might place this logic in your @main App struct.

struct ContentView: View {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    
    var body: some View {
        if isOnboardingComplete {
            HomeScreenView()
        } else {
            OnboardingView()
        }
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
