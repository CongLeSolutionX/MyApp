//
//  ExplicitDestination.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//

import SwiftUI

// MARK: - 10. Explicit Destinations - Direct Enum View Retrieval

enum HomeDestinations: Hashable, Equatable, Identifiable, View { // 🌟 Enum conforms to View DIRECTLY
    case home
    case page2
    case pageN(Int)
    case external // Placeholder

    var id: Self { self }

    var body: some View { // 🌟 View conformance - define view per case
        switch self {
        case .home:
            HomeContentView_Explicit(message: "Home View from Enum") // HomeContentView *from* Enum!
        case .page2:
            HomePage2View_Explicit(message: "Page 2 View from Enum")
        case .pageN(let pageNum):
            HomePageNView_Explicit(pageNum: pageNum)
        case .external:
            Text("External (from Enum View conformance)")
        }
    }

    @MainActor @ViewBuilder
    func callAsFunction() -> some View { // 🌟 callAsFunction() for DIRECT view retrieval from enum
        self // Return 'self' as 'View' because enum *is* View now!
    }
}

// Simplified Views for Explicit Destinations - No complex ViewModels or DI for clarity in this example
struct HomeContentView_Explicit: View {
    let message: String
    var body: some View { Text("Home Content - Explicit: \(message)").navigationTitle("Home (Enum)") }
}
struct HomePage2View_Explicit: View {
    let message: String
    var body: some View { Text("Page 2 Content - Explicit: \(message)").navigationTitle("Page 2 (Enum)") }
}
struct HomePageNView_Explicit: View {
    let pageNum: Int
    var body: some View { Text("Generic Page \(pageNum) - Explicit").navigationTitle("Page \(pageNum) (Enum)") }
}


struct ExplicitDestinationView: View {
    var body: some View {
        NavigationStack {
            // 🌟 Direct enum view retrieval - RootHomeView Code Context Equivalent
            HomeDestinations.home() // 🌟 HomeDestinations.home() - DIRECT enum view! - Root View from Enum!
                .navigationDestination(for: HomeDestinations.self) { destination in
                    destination() // Still need navigationDestination, but views are pre-built in enum
                }
            .navigationTitle("Explicit Destinations")
        }
    }
}

// MARK: Previews
struct ExplicitDestination_Previews: PreviewProvider {
    static var previews: some View {
        ExplicitDestinationView()
        HomeContentView_Explicit(message: "Home Content View Explicit")
        HomePage2View_Explicit(message: "Home Page 2 View Explicit")
        HomePageNView_Explicit(pageNum: 23)
    }
}
