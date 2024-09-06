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
@MainActor
class ItemViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var showRetry: Bool = false

    // Asynchronous function to fetch items
    func fetchItems() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedItems = try await fetchRemoteItems()
            items = fetchedItems
            alertMessage = "Data fetched successfully!"
            showRetry = false
            showAlert = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            alertMessage = errorMessage ?? "An unknown error occurred."
            showRetry = true
            showAlert = true
            isLoading = false
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
            .alert(isPresented: $viewModel.showAlert) {
                if viewModel.showRetry {
                    return Alert(
                        title: Text("Network Error"),
                        message: Text(viewModel.alertMessage),
                        primaryButton: .default(Text("Retry")) {
                            Task {
                                await viewModel.fetchItems()
                            }
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                } else {
                    return Alert(
                        title: Text("Success"),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}
