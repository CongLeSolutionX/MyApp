//
//  OnboardingView.swift
//  MyApp
//
//  Created by Cong Le on 3/12/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    // State variable to trigger navigation to HomeScreenView
    @State private var isHomeActive = false

    // Onboarding page data
    private let onboardingPages: [OnboardingPageData] = [
        OnboardingPageData(
            imageName: "onboardingIllustration1",
            title: "Welcome to Bookly!",
            description: "Explore a world of amazing books and take your reading journey to the next level."
        ),
        OnboardingPageData(
            imageName: "onboardingIllustration2",
            title: "Discover New Books",
            description: "Find new great books, popular titles, and hidden gems curated just for you."
        ),
        OnboardingPageData(
            imageName: "onboardingIllustration3",
            title: "Keep Track of Your Reading",
            description: "Monitor your progress and never lose your place with our seamless reading tracker."
        ),
        OnboardingPageData(
            imageName: "onboardingIllustration4",
            title: "Personalized Recommendations",
            description: "Receive recommendations based on your interests and reading habits."
        )
    ]

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPage(data: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()

                Button(action: {
                    if currentPage == onboardingPages.count - 1 {
                        // When on last page, trigger navigation to HomeScreenView
                        isHomeActive = true
                    } else {
                        // Otherwise, move to the next onboarding page
                        currentPage += 1
                    }
                }) {
                    Text(currentPage == onboardingPages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
                // Hidden NavigationLink that navigates to HomeScreenView when isHomeActive becomes true.
                NavigationLink(destination: HomeScreenView(), isActive: $isHomeActive) {
                    EmptyView()
                }
            }
            .padding()
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

// Data model for each onboarding page
struct OnboardingPageData {
    let imageName: String
    let title: String
    let description: String
}

// View representing a single onboarding page
struct OnboardingPage: View {
    let data: OnboardingPageData
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(data.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 300, maxHeight: 300)
                .padding()
            Text(data.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text(data.description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Spacer()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
