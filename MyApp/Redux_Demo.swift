//
//  Redux_Demo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import SwiftUI
import Combine // Needed for Store's state publishing

// MARK: 1. State Definition
// Represents the entire state of the application. Should be a value type (struct).
// Must be Equatable if you want to perform optimizations like skipping updates
// if parts of the state haven't changed (though not strictly required by basic Redux).
struct AppState: Equatable {
    var counter: Int = 0
    var isLoading: Bool = false // Example state for async operations
    var message: String = "Initial Message"
}

// MARK: 2. Action Definition
// Actions describe *what* happened. They are the only way to trigger state changes.
// Typically implemented as structs or enums conforming to a base `Action` protocol.
protocol Action {}

struct IncrementCounterAction: Action {}
struct DecrementCounterAction: Action {}
struct AddToCounterAction: Action { // Action with a payload
    let value: Int
}
struct SetMessageAction: Action { // Another action with payload
    let newMessage: String
}

// Actions for asynchronous operation example
struct FetchDataAction: Action {} // Trigger the async work
struct SetLoadingAction: Action { // Indicate loading started/stopped
    let isLoading: Bool
}

// MARK: 3. Reducer Definition
// A pure function that takes the current state and an action, and returns the NEW state.
// It MUST NOT modify the existing state (immutability) and MUST NOT have side effects.
// Signature: (currentState: State, action: Action) -> newState: State
typealias Reducer<State> = (State, Action) -> State

func appReducer(state: AppState, action: Action) -> AppState {
    // Create a mutable copy to modify. This enforces immutability of the original 'state'.
    var newState = state

    print("[Reducer] Received action: \(action)")

    switch action {
    case is IncrementCounterAction:
        newState.counter += 1
        newState.message = "Counter Incremented"

    case is DecrementCounterAction:
        newState.counter -= 1
        newState.message = "Counter Decremented"

    case let addAction as AddToCounterAction:
        newState.counter += addAction.value
        newState.message = "Added \(addAction.value) to Counter"

    case let setMessageAction as SetMessageAction:
        newState.message = setMessageAction.newMessage

    case let setLoading as SetLoadingAction:
        newState.isLoading = setLoading.isLoading
        if setLoading.isLoading {
            newState.message = "Loading data..."
        } else {
            // Message might be set more specifically by the action completing the async work
            if newState.message == "Loading data..." { // Avoid overwriting success/error message
                newState.message = "Finished loading."
            }
        }

    // Note: FetchDataAction is handled by middleware, doesn't directly change state here.

    default:
        // If the action is not recognized, return the unchanged state.
        print("[Reducer] Action not handled: \(action)")
        break
    }

    print("[Reducer] New state: \(newState)")
    return newState
}

// MARK: 4. Middleware Definition
// Middleware intercepts actions BEFORE they reach the reducer.
// Used for side effects like logging, API calls, routing, etc.
// Signature: (state: State, action: Action, dispatch: @escaping DispatchFunction) -> Void
typealias DispatchFunction = (Action) -> Void
typealias Middleware<State> = (State, Action, @escaping DispatchFunction) -> Void

// Example: Logging Middleware
func loggingMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        print("--- Middleware: Logging ---")
        print("  Action: \(action)")
        print("  State BEFORE: \(state)")

        // IMPORTANT: Pass the action along to the next middleware or reducer
        dispatch(action)
        // Can also access state AFTER reducer runs if needed, but typically done via subscriptions
        print("--- Middleware: Logging End ---")
    }
}

// Example: Asynchronous Operation Middleware (simulates API call)
func asyncDataFetchingMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        // Only act on a specific action (FetchDataAction)
        guard action is FetchDataAction else {
            // If it's not the action we care about, pass it through immediately.
            dispatch(action)
            return
        }

        print("--- Middleware: Async Fetch ---")
        print("  Triggered by: FetchDataAction")

        // 1. Dispatch an action to indicate loading has started
        dispatch(SetLoadingAction(isLoading: true))

        // 2. Perform the async operation (e.g., network request)
        // Simulating a delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            // Simulate success/failure
            let success = Bool.random()

            // 3. Dispatch actions on the main thread upon completion
            DispatchQueue.main.async {
                if success {
                    let fetchedValue = Int.random(in: 100...200)
                    print("  Async Success! Fetched: \(fetchedValue)")
                    dispatch(AddToCounterAction(value: fetchedValue))
                    dispatch(SetMessageAction(newMessage: "Async data fetched: Added \(fetchedValue)"))
                } else {
                    print("  Async Failure!")
                    dispatch(SetMessageAction(newMessage: "Async data fetch failed!"))
                }
                // 4. Dispatch an action to indicate loading finished
                dispatch(SetLoadingAction(isLoading: false))
                print("--- Middleware: Async Fetch End ---")
            }
        }
        // Note: We DON'T call dispatch(action) for the original FetchDataAction itself,
        // because its purpose was solely to trigger this async workflow.
        // The workflow dispatches its own actions (SetLoading, AddToCounter, SetMessage).
    }
}


// MARK: 5. Store Definition
// The central hub holding the state, reducer, middleware, and dispatch logic.
// Often implemented as a class and uses Combine's @Published for easy SwiftUI integration.
final class Store<State>: ObservableObject {
    // @Published automatically notifies SwiftUI views when the state changes.
    @Published private(set) var state: State

    private let reducer: Reducer<State>
    private let middlewares: [Middleware<State>]

    // The dispatch function that ultimately runs the reducer and updates state
    private lazy var coreDispatch: DispatchFunction = { [weak self] action in
        guard let self = self else { return }
        // State updates MUST be on the main thread if UI is observing
        DispatchQueue.main.async {
            let newState = self.reducer(self.state, action)
            self.state = newState
        }
    }

    // The dispatch function exposed to the outside world, incorporating middleware
    lazy var dispatch: DispatchFunction = {
        // Start with the core dispatch function (reducer -> state update)
        var finalDispatcher = self.coreDispatch

        // Iterate through middleware in reverse order to build the chain:
        // dispatch(action) -> middleware[N] -> ... -> middleware[0] -> coreDispatch
        for middleware in self.middlewares.reversed() {
            let currentDispatcher = finalDispatcher // Capture the current link in the chain
            // Wrap the current dispatcher with the middleware
            finalDispatcher = { [weak self] action in
                guard let self = self else { return }
                // Call the middleware, passing the current state, action, and the next dispatcher in the chain
                middleware(self.state, action, currentDispatcher)
            }
        }
        return finalDispatcher
    }()

    init(initialState: State, reducer: @escaping Reducer<State>, middlewares: [Middleware<State>] = []) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
        print("[Store] Initialized. State: \(self.state)")
    }

    // Optional: Convenience for manual subscriptions outside SwiftUI
    func subscribe( NreceiveValue: @escaping (State) -> Void) -> AnyCancellable {
        $state.sink(receiveValue: receiveValue)
    }
}


// MARK: 6. SwiftUI View
// Example UI demonstrating how to connect to the store and dispatch actions.
struct ContentView: View {
    // Use @StateObject if the Store is created specifically for this view/subview hierarchy.
    // Use @EnvironmentObject if the Store is provided higher up in the view hierarchy (e.g., in the App struct).
    @StateObject var store: Store<AppState>

    var body: some View {
        VStack(spacing: 15) {
            Text("Redux Counter Example")
                .font(.title)

            Divider()

            // Display state
            Text("Current Count: \(store.state.counter)")
                .font(.headline)
            Text("Status: \(store.state.message)")
                .font(.caption)
                .foregroundColor(.gray)

            Divider()

            // Buttons to dispatch actions
            HStack {
                Button("Decrement") {
                    store.dispatch(DecrementCounterAction())
                }
                .buttonStyle(.bordered)

                Button("Increment") {
                    store.dispatch(IncrementCounterAction())
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Add 10") {
                store.dispatch(AddToCounterAction(value: 10))
            }
            .buttonStyle(.bordered)

            Button("Fetch Async Data (Simulated)") {
                store.dispatch(FetchDataAction())
            }
            .buttonStyle(.bordered)
            .tint(.purple)

            // Show loading indicator based on state
            if store.state.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                        .font(.footnote)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
    }
}

// MARK: 7. Application Entry Point
@main
struct ReduxExampleApp: App {
    // Create the single instance of the store for the entire application.
    // Inject the necessary components: initial state, the root reducer, and middleware.
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        middlewares: [
            loggingMiddleware(),         // Apply logging first
            asyncDataFetchingMiddleware()  // Then async handling
            // Add more middleware here if needed
        ]
    )

    var body: some Scene {
        WindowGroup {
            // Provide the store to the ContentView.
            // Using @StateObject in ContentView means we pass it directly.
            // If ContentView used @EnvironmentObject, you would use:
            // ContentView().environmentObject(store)
            //ContentView(store: store)
            ContentView(store: store)
        }
    }
}
