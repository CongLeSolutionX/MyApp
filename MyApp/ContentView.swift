//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct ContentView: View {
    @State private var counterValue = 0
    @State private var fetchedData: Data?
    @State private var dataFetched = ""
    @State private var error: Error? // State to hold the error
    @State private var asyncWrapperResult: Int?
    @State private var unsafeContinuationResult: String?
    
    var body: some View {
        VStack {
            UIKitViewControllerWrapper() // Placeholder for UIViewController integration if needed
                .edgesIgnoringSafeArea(.all)
                .frame(height: 200)
            
            Text("Counter: \(counterValue)")
                .padding()
                .task {
                    await updateCounter()
                }
            
//            Text("Fetched Data: \(dataFetched)")
//                .padding()
//                .task {
//                    await usingFetchedData()
//                }
            
            Text("Async Wrapper Result: \(asyncWrapperResult.map(String.init) ?? "N/A")")
                .padding()
                .task {
                    await executeAsyncWrapper()
                }
            
            Text("Unsafe Continuation Result: \(unsafeContinuationResult ?? "N/A")")
                .padding()
                .task {
                    await executeUnsafeContinuation()
                }
            
            Button("Perform Database Operation") {
                Task {
                    await performDatabaseOperation()
                }
            }
            .padding()
            
            Button("Fetch Data Concurrently") {
                Task {
                    await sampleCode()
                }
            }
            .padding()
        }
        
    }
    
    // MARK: - Counter functions
    
    func updateCounter() async {
        let counter = Counter()
        await counter.increment()
        counterValue = await counter.getValue()
    }
    
    // MARK: - Data fetching functions
    
//    func usingFetchedData() async {
//        dataFetched = await fetchData().description
//    }
//    
//    
//    func fetchData() async -> Data {
//        // Simulate fetching data from a network
//        await Task.sleep(nanoseconds: 1 * 1_000_000_000) // Sleep for 1 second
//        return Data([0, 1, 2, 3])
//    }
    
    
    
    // MARK: - Async wrapper and unsafe continuation functions
    
    func executeAsyncWrapper() async {
        do {
            asyncWrapperResult = try await asyncWrapper()
        } catch {
            print("Error in asyncWrapper: \(error)")
        }
        
    }
    
    func executeUnsafeContinuation() async {
        unsafeContinuationResult = await unsafeContinuationExample { result in
            print("Unsafe Continuation Result (from callback): \(result)")
        }
        
        
    }
    
    // MARK: - Async Operation and Wrapper
    
    func asyncOperation(completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            completion(.success(42))
        }
    }
    
    func asyncWrapper() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            asyncOperation { result in
                continuation.resume(with: result)
            }
        }
    }
    
    
    func unsafeContinuationExample(completion: @escaping (String) -> Void) async -> String {
        return await withUnsafeContinuation { continuation in
            completion("Operation result")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                continuation.resume(returning: "Completed unsafe integration")
            }
        }
    }
    
    
    // MARK: - DatabaseActor and other functions (from previous response)
    
    @globalActor
    actor DatabaseActor {
        static let shared = DatabaseActor()
        private var dataStore = [String: Any]() // Example of a data store
        
        func saveData(key: String, value: Any) async {
            dataStore[key] = value
        }
        
        func fetchData(forKey key: String) async -> Any? {
            return dataStore[key]
        }
    }
    
    @DatabaseActor func performDatabaseOperation() async {
        await DatabaseActor.shared.saveData(key: "exampleKey", value: 42)
    }
    
    func sampleCode() async {
        let sources: [URL] = [
            URL(string: "https://example.com/api/data1")!,
            URL(string: "https://example.com/api/data2")!,
        ]
        
        do {
            // Use a task group to download data concurrently
            let results = try await withThrowingTaskGroup(of: Data.self) { group in
                for source in sources {
                    group.addTask {
                        return try await DataManager.shared.fetchData(from: source)
                    }
                }
                var collectedData: [Data] = []
                for try await data in group {
                    collectedData.append(data)
                }
                return collectedData
            }
            print("Fetched data: \(results)")
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}

// MARK: - DataManager and other structs (from previous response)

actor Counter {
    private var value = 0
    
    func increment() async {
        value += 1
    }
    
    func getValue() async -> Int {
        return value
    }
}


struct MyData: Sendable {
    let value: Int
}

enum DataError: Error {
    case networkError
    case invalidData
}


class DataManager {
    static let shared = DataManager()
    
    // Concurrent queue for thread safety with barrier for writes
    private let queue = DispatchQueue(label: "com.example.DataManager.concurrentQueue", attributes: .concurrent)
    
    // Private data store
    private var _someData: [String] = []
    
    private init() {
        // Prevent instantiation from outside
    }
    
    // Method to add data, using a barrier to ensure safe writes
    func addData(item: String) {
        queue.async(flags: .barrier) {
            self._someData.append(item)
        }
    }
    
    // Method to retrieve data safely
    func getData() -> [String] {
        return queue.sync {
            return _someData
        }
    }
    
    // Method to safely clear all data
    func clearData() {
        queue.async(flags: .barrier) {
            self._someData.removeAll()
        }
    }
    
    // Asynchronous method to fetch data from a given source
    func fetchData(from source: URL) async throws -> Data {
        // Simulating a network call or data fetching process
        let (data, response) = try await URLSession.shared.data(from: source)
        
        // Check if response is valid
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
}

// MARK: - Preview

#Preview {
    ContentView()
}
