//
//  PreiOS16NavigationView.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//

import SwiftUI

// MARK: - 1. Evolution of SwiftUI NavigationLinks

// Pre-iOS 16 Approach: Explicit Destination
struct PreiOS16NavigationView: View {
    var body: some View {
        NavigationView { // Note: NavigationView for older approach, NavigationStack for newer
            VStack {
                NavigationLink(destination: DetailView(message: "Explicit Destination")) { // Explicitly defining destination
                    Text("Go to Detail (Pre-iOS 16)")
                }
                .padding()
            }
            .navigationTitle("Pre-iOS 16 Nav")
        }
    }
}

// Post-iOS 16 Approach: Value-Based Navigation
struct PostiOS16NavigationView: View {
    enum NavigationValue: Hashable {
        case detail
    }

    @State private var path = NavigationPath() // Use NavigationPath for programmatic control

    var body: some View {
        NavigationStack(path: $path) { // Using NavigationStack
            VStack {
                NavigationLink("Go to Detail (Post-iOS 16)", value: NavigationValue.detail) // Pushing a value instead of a View
                    .padding()
            }
            .navigationDestination(for: NavigationValue.self) { value in  // Handler based on value type
                switch value {
                case .detail:
                    DetailView(message: "Value-Based Destination") // View is created here, only when needed
                }
            }
            .navigationTitle("Post-iOS 16 Nav")
        }
    }
}

struct DetailView: View {
    let message: String
    var body: some View {
        Text("Detail View: \(message)")
            .navigationTitle("Detail")
    }
}
// MARK: - Previews
struct EvolutionNavigationLinks_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PreiOS16NavigationView()
            Divider()
            PostiOS16NavigationView()
        }
    }
}
