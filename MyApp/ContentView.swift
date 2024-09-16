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
                FetchButton {
                    Task {
                        await viewModel.fetchItems()
                    }
                }
                
                Spacer(minLength: 20) // Ensure spacing to maintain layout consistency
                
                if viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                } else {
                    ItemListView(items: viewModel.items)
                }
                
                // Add sufficient space to keep the button position consistent
                Spacer()
            }
            .navigationTitle("Items")
            .alert(isPresented: $viewModel.showAlert) {
                makeAlert()
            }
        }
    }

    private func makeAlert() -> Alert {
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

// MARK: - FetchButton Component
struct FetchButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Load Items")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.bottom, 10)
    }
}

// MARK: - LoadingView Component
struct LoadingView: View {
    var body: some View {
        ProgressView("Loading...")
    }
}


// MARK: - ErrorView Component
struct ErrorView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .padding()
    }
}

// MARK: - ItemListView Component
struct ItemListView: View {
    let items: [Item] // Make sure `Item` conforms to `Identifiable`
    
    var body: some View {
        List(items) { item in
            Text(item.name)
        }
    }
}


// MARK: - Preview
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
