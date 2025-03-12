//
//  OnboardingView.swift
//  MyApp
//
//  Created by Cong Le on 3/12/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Playful Illustration
            Image("onboardingIllustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 300, maxHeight: 300)
                .padding()
            
            // Welcome Title
            Text("Welcome to Bookly!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
                .padding(.horizontal)
            
            // Description text
            Text("Discover new adventures in every book. Dive in and explore popular titles, curated recommendations, and more!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            // Get Started Button wrapped in a NavigationLink to transition to the home screen.
            NavigationLink(destination: HomeView()) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

// A placeholder HomeView to demonstrate navigation from the onboarding screen.
struct HomeView: View {
    var body: some View {
        Text("Home Screen")
            .font(.largeTitle)
            .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {  // Embedding in NavigationView to enable NavigationLink functionality
            OnboardingView()
        }
    }
}
