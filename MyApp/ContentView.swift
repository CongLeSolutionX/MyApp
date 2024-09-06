//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// Model: Represents a simple data item
struct Item: Identifiable {
    let id: UUID
    let name: String
}

// Custom Error Type for Simulated Network Errors
enum NetworkError: Error, LocalizedError {
    case serverError
    case noData

    var errorDescription: String? {
        switch self {
        case .serverError:
            return "Server encountered an error. Please try again later."
        case .noData:
            return "No data received. Please check your connection."
        }
    }
}

// ViewModel: Handles data fetching and state management
class ItemViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Asynchronous function to fetch items
    func fetchItems() async {
        DispatchQueue.main.async { self.isLoading = true }
        DispatchQueue.main.async { self.errorMessage = nil }

        do {
            let fetchedItems = try await fetchRemoteItems()
            DispatchQueue.main.async {
                self.items = fetchedItems
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // Simulated network call: Asynchronously fetches items with potential errors
    private func fetchRemoteItems() async throws -> [Item] {
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate network delay

        // Randomly simulate success or failure
        if Bool.random() {
            throw Bool.random() ? NetworkError.serverError : NetworkError.noData
        }

        // Simulate fetched data
        return [
            Item(id: UUID(), name: "Apple"),
            Item(id: UUID(), name: "Banana"),
            Item(id: UUID(), name: "Cherry")
        ]
    }
}

// ContentView: Displays the list of items and manages loading/error states
struct ContentView: View {
    @StateObject private var viewModel = ItemViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.items) { item in
                        Text(item.name)
                    }
                }
            }
            .navigationTitle("Items")
            .task {
                await viewModel.fetchItems()
            }
            .refreshable {
                await viewModel.fetchItems()
            }
        }
    }
}

// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}
