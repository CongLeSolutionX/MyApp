//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}

// MARK: - Actors

actor Counter {
    private var value = 0
    func increment() -> Int {
        value += 1
        return value
    }
}

@MainActor
func updateUI(with value: Int) -> String {
    // Returns a string message that could be used to update a UI label
    return "UI updated with: \(value)"
}


// MARK: - Global Actor


@globalActor
final actor DataManager {
    static let shared = DataManager()
    private var cache: [String: Data] = [:]

    func fetchData(from source: String) async throws -> Data {
        if let cachedData = cache[source] {
            print("Returning cached data for \(source)")
            return cachedData
        }
        
        // Simulate a network fetch with delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate network delay with 2 seconds
        
        // Create sample data
        let fetchedData = Data("Data from \(source)".utf8)
        
        // Store in cache
        cache[source] = fetchedData
        
        print("Fetched and cached data for \(source)")
        return fetchedData
    }
}

// MARK: - async/await
func performAsyncTask(with data: Data) async throws -> String {
    // Simulate processing data
    try await Task.sleep(nanoseconds: 1_000_000_000)
    return String(decoding: data, as: UTF8.self)
}

// MARK: - Tasks
func startBackgroundTask() {
    Task {
        // Placeholder for background task
        print("Background Task executed")
    }
}

func cancellableTask(with message: String) {
        let task = Task {
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate a long-running operation
                print("Task completed: \(message)")
            } catch is CancellationError {
                print("Task cancelled: \(message)")
            }
        }
    Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch {
            }
            task.cancel()
    }
}

func prioritizedTask(with priority: TaskPriority, message: String) {
    Task(priority: priority) {
        // Placeholder for prioritized task
        print("Prioritized Task executed with priority \(priority): \(message)")
    }
}

// MARK: - Task Groups
func fetchMultipleData(from sources: [String]) async throws -> [Data] {
    try await withThrowingTaskGroup(of: Data.self) { group in
        for source in sources {
            group.addTask {
                try await DataManager.shared.fetchData(from: source)
            }
        }
        var results: [Data] = []
        for try await data in group {
            // Process data
            results.append(data)
        }
        return results
    }
}

// MARK: - Continuations
// Use with caution! Ensure single resume in each continuation to avoid memory leaks

func integrateWithLegacyCallback(completion: @escaping (String) -> Void) async -> String {
    await withCheckedContinuation { continuation in
        // Simulate legacy callback based API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion("Result from legacy API")
            continuation.resume(returning: "Completed integration")

        }
    }
}

// Example using withUnsafeContinuation (handle with EXTREME care):
func unsafeContinuationExample(completion: @escaping (String) -> Void) async -> String {
    await withUnsafeContinuation { continuation in
        // ... (Handle with caution – Ensure exactly one resume to avoid memory issues) ...
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion("Result from legacy API")
            continuation.resume(returning: "Completed unsafe integration")

        }
    }
}

// MARK: - Sendable
struct SendableStruct: Sendable {
      let value = "Sendable Value"
}

func sendableClosureExample() {
    let closure: @Sendable () -> Void = { print(SendableStruct().value)}
    
    // Example passing the Sendable closure to another function or Task
    Task { closure() }
}

// MARK: - Main View (Example usage)
struct ContentView: View {
    @State private var counterValue = 0
    @State private var fetchedData: String = ""
    @State private var uiUpdateMessage: String = "Welcome!"

    var body: some View {
        VStack {
            Text("Counter: \(counterValue)")

            Button("Increment Counter") {
                Task {
                    let newValue = await Counter().increment()
                    let message = updateUI(with: newValue)
                    counterValue = newValue // Update the view's state
                    uiUpdateMessage = message // Update message to display in UI
                }
            }
            
            Text(uiUpdateMessage) // Displays the UI update message
            
            Text("Fetched data: \(fetchedData)")
            Button("Fetch Data") {
                Task {
                    do {
                    let data = try await DataManager.shared.fetchData(from: "Example Source")
                    let result = try await performAsyncTask(with: data)
                    fetchedData = result
                        uiUpdateMessage = updateUI(with: 1) // Simulate a message update post-fetch
                    } catch {
                        print("Error fetching data: \(error)")
                    }
                }
            }
            
            Button("Start Background Task") {
                startBackgroundTask()
            }
            
            Button("Cancellable Task") {
                cancellableTask(with: "Test Message")
            }
            
            Button("Prioritized Task") {
                prioritizedTask(with: .high, message: "High Priority")
            }
            
            Button("Fetch Multiple Data") {
                Task {
                    do {
                        let datas = try await fetchMultipleData(from: ["Source 1", "Source 2", "Source 3"])

                        for data in datas {
                            print(String(decoding: data, as: UTF8.self))
                        }
                    } catch {
                         print("Error with task group : \(error)")
                    }
                }
            }
            Button("Checked Continuation") {
                Task {
                    let result = await integrateWithLegacyCallback { result in
                        print(result)
                    }
                    print(result)
                }
            }
        }
    }
}

// MARK: - Preview

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}

// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}
