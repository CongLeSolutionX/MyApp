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
            Image("onboardingIllustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 300)
                .padding()
            Text("Welcome to Bookly!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text("Discover new adventures in every book. Dive in and explore popular titles and curated recommendations!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Spacer()
            NavigationLink(destination: HomeScreenView()) {
                Text("Get Started")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
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

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingView()
        }
    }
}
