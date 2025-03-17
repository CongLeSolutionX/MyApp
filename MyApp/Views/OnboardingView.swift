//
//  OnboardingView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

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

// MARK: -  Preview
#Preview {
    OnboardingView(topics: [], selectedTopics: .constant([]), onDone: { })
}
