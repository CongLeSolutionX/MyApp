//
//  SheetReusabilityView.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//
import SwiftUI

// MARK: - 9. Environmental Solutions - Destination View Pattern with Dependency Flow

// Mock Dependencies (Simplified for Example)
protocol HomeDependenciesProtocol {
    func homeMessage() -> String
    func page2Message() -> String
}

class MockHomeDependencies: HomeDependenciesProtocol {
    func homeMessage() -> String { "Hello from Home (DI)" }
    func page2Message() -> String { "Welcome to Page 2 (DI)" }
}

enum HomeDestinationsEnum: Hashable, Equatable, Identifiable { // HomeDestinations Enum - Delegates View Building
    case home
    case page2
    case pageN(Int) // Example with associated value
    case external // Example for cross-module - not implemented in this simplified example for brevity

    var id: Self { self }
}

// Private DestinationView Handles View Building & DI
private struct HomeDestinationsView: View { // Private DestinationView - Handles View Building & DI
    let destination: HomeDestinationsEnum
    @Environment(\.homeDependenciesResolver) var resolver: HomeDependenciesProtocol // 🌟 Accessing Environment for Dependencies

    var body: some View {
        switch destination {
        case .home:
            HomeContentView(viewModel: HomeContentViewModel(dependencies: resolver)) // 🌟 Dependency Injection into ViewModel
        case .page2:
            HomePage2View(viewModel: HomePage2ViewModel(dependencies: resolver))
        case .pageN(let pageNum):
            HomePageNView(pageNum: pageNum) // Example - No DI for PageN in this example
        case .external:
            Text("External View - Cross Module (Not Implemented in this example)")
        }
    }
}

extension HomeDestinationsEnum: NavigationDestinationProtocol { // Conformance to Protocol - Returns DestinationView
    var view: some View {
        HomeDestinationsView(destination: self) // 🌟 Delegating View Building to HomeDestinationsView!
    }
}


// View Models (Simplified) - requiring Dependencies
class HomeContentViewModel: ObservableObject {
    let message: String
    init(dependencies: HomeDependenciesProtocol) {
        self.message = dependencies.homeMessage()
    }
}
struct HomeContentView: View {
    @ObservedObject var viewModel: HomeContentViewModel
    var body: some View { Text("Home Content: \(viewModel.message)").navigationTitle("Home") }
}

class HomePage2ViewModel: ObservableObject {
    let message: String
    init(dependencies: HomeDependenciesProtocol) {
        self.message = dependencies.page2Message()
    }
}
struct HomePage2View: View {
    @ObservedObject var viewModel: HomePage2ViewModel
    var body: some View { Text("Page 2 Content: \(viewModel.message)").navigationTitle("Page 2") }
}

struct HomePageNView: View { // Example view - No dependency injection in this example for simplicity
    let pageNum: Int
    var body: some View { Text("Generic Page \(pageNum)").navigationTitle("Page \(pageNum)") }
}


// Environment Key and Extension for Dependency Injection
struct HomeDependenciesResolverKey: EnvironmentKey {
    static let defaultValue: HomeDependenciesProtocol = MockHomeDependencies()
}

extension EnvironmentValues {
    var homeDependenciesResolver: HomeDependenciesProtocol {
        get { self[HomeDependenciesResolverKey.self] }
        set { self[HomeDependenciesResolverKey.self] = newValue }
    }
}


struct EnvironmentalSolutionView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Home", value: HomeDestinationsEnum.home)
                NavigationLink("Page 2", value: HomeDestinationsEnum.page2)
                NavigationLink("Page N (3)", value: HomeDestinationsEnum.pageN(3))
                NavigationLink("External (Placeholder)", value: HomeDestinationsEnum.external)
            }
//            .navigationDestination(for: HomeDestinationsEnum.self) { destination in
//                destination // Using callAsFunction for direct enum view retrieval
//            }
            .navigationTitle("Environmental Destinations")
        }
        .environment(\.homeDependenciesResolver, MockHomeDependencies()) // 🌟 Providing Environment Dependency at Root View
    }
}

struct EnvironmentalSolution_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentalSolutionView()
    }
}
