//
//  EnvironmentValuesDemoApp.swift
//  MyApp
//
//  Created by Cong Le on 4/24/25.
//


/*

 The code below demonstrates each technique discussed:

 1.  **Basic Custom Environment Value:** Using `@Entry` to create a settable value (`backgroundColor`).
 2.  **Read-Only Environment Value:** Using a computed property without `@Entry` (`readOnlyInfoText`).
 3.  **Accessing Other Environment Values (Read-Only):** Creating `dismissWithMessage` that internally uses `\.dismiss`.
 4.  **Accessing Other Environment Values (Read-Write):** Using `EnvironmentKey` (`DismissWithActionKey`) to create a settable action (`dismissWithAction`) that also calls `\.dismiss`.
 5.  **Accessing Custom Observable Objects:** Using a wrapper struct (`AddMessageAction`) initialized with an `@Observable` object (`MessageManager`) to perform actions (`addMessage`).
 6.  **Associating Multiple Functions:** Extending the wrapper struct (`AddMessageAction`) with multiple `callAsFunction` methods for different parameter types.

*/

import SwiftUI
import Observation // Required for @Observable

// MARK: - 1. Basic Custom Environment Value

extension EnvironmentValues {
    // Create: Extend EnvironmentValues, add @Entry var with default value.
    @Entry var backgroundColor: Color = .gray.opacity(0.3) // Default value
}

// MARK: - 2. Read-Only Environment Value

extension EnvironmentValues {
    // Create: Extend EnvironmentValues, add get-only computed property (NO @Entry).
    var readOnlyInfoText: String {
        get {
            // This value originates here and cannot be set via .environment()
            return "This info is read-only from the environment."
        }
    }
}

// MARK: - 3. Accessing Other Environment Values (Read-Only)

extension EnvironmentValues {
    // Create: get-only computed property accessing another value (`\.dismiss`)
    var dismissWithMessage: (String) -> Void {
        get {
            // Capture self to access other environment values inside the closure
            let dismissAction = self[keyPath: \.dismiss]
            return { message in
                print("Dismissing with message: \(message)")
                dismissAction() // Calls the original dismiss action
            }
        }
    }
}

// MARK: - 4. Accessing Other Environment Values (Read-Write)

// Create: Define an EnvironmentKey with a default value.
private struct DismissWithActionKey: EnvironmentKey {
    // Default action does nothing
    static let defaultValue: (Any?) -> Void = { _ in print("Default dismissWithAction called (no action set).") }
}

extension EnvironmentValues {
    // Create: Define computed property using the EnvironmentKey for get/set.
    var dismissWithAction: (Any?) -> Void {
        get {
            // Capture self to access both the custom action and the original dismiss
            let customAction = self[DismissWithActionKey.self]
            let dismissAction = self[keyPath: \.dismiss]
            return { params in
                print("DismissWithAction called.")
                // Execute the custom action set via .environment()
                customAction(params)
                // Also execute the original dismiss
                dismissAction()
            }
        }
        set {
            // Allows setting a new closure via .environment(\.dismissWithAction, newAction)
            self[DismissWithActionKey.self] = newValue
        }
    }
}

// MARK: - 5 & 6. Accessing Custom Observable & Multiple Functions

// Create: The Observable object
@Observable
class MessageManager {
    var messages: [String] = []

    func appendMessage(_ message: String) {
        print("MessageManager: Appending single message.")
        messages.append(message)
    }

    func appendMessages(_ newMessages: [String]) {
        print("MessageManager: Appending multiple messages.")
        messages.append(contentsOf: newMessages)
    }
}

// Create: The wrapper struct (like DismissAction)
@MainActor // Required for accessing Observable object potentially from non-main thread env value access
@preconcurrency // Indicate Sendable conformance is based on Swift 5 rules if needed
public struct AddMessageAction: Sendable { // Needs Sendable for Env use
    // Holds the *instance* of the Observable object, passed during initialization.
    // It's optional because the default init won't have it.
    var _manager: MessageManager?

    // Computed property to safely access the manager or crash if not set.
    // This ensures the environment value is properly configured before use.
    private var manager: MessageManager {
        guard let _manager else {
            // This error means .environment(\.addMessage, .init(_manager: managerInstance)) was NOT called
            fatalError("AddMessageAction requires a MessageManager instance. Ensure it's set in the environment.")
        }
        return _manager
    }

    // Function 1: callAsFunction for single message
    public func callAsFunction(_ message: String) {
        // Delegate the work to the actual manager instance
        manager.appendMessage(message)
    }

    // Function 2: callAsFunction for multiple messages (Demonstrates Step 6)
    public func callAsFunction(_ messages: [String]) {
        // Delegate the work to the actual manager instance
        manager.appendMessages(messages)
    }
}

// Create: Extend EnvironmentValues using the wrapper struct with @Entry
extension EnvironmentValues {
    // The default value is an empty action struct.
    // It MUST be replaced using .environment() with an instance containing the MessageManager.
    @Entry var addMessage: AddMessageAction = AddMessageAction()
}


// MARK: - SwiftUI Demo Views

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("1. Basic Environment Value", destination: BasicEnvValueDemo())
                NavigationLink("2. Read-Only Environment Value", destination: ReadOnlyEnvValueDemo())
                NavigationLink("3. Accessing Other (Read-Only)", destination: AccessOtherEnvValueDemo())
                NavigationLink("4. Accessing Other (Read-Write)", destination: ReadWriteAccessOtherDemo())
                NavigationLink("5 & 6. Accessing Observable / Multi-Function", destination: CustomObservableDemo())
            }
            .navigationTitle("EnvironmentValues Deep Dive")
        }
    }
}

// --- Demo 1: Basic ---
struct BasicEnvValueDemo: View {
    var body: some View {
        VStack {
            Text("Parent View (Sets Red Background)")
            BasicChildView()
                // Set: Use .environment(\.keyPath, value)
                .environment(\.backgroundColor, .red.opacity(0.4))
        }
        .padding()
        .navigationTitle("Basic")
    }
}

struct BasicChildView: View {
    var body: some View {
        // This view doesn't read the value, just passes it down
        Text("Child View (passes down)")
            .padding(.bottom)
        BasicGrandChildView()
    }
}

struct BasicGrandChildView: View {
    // Read: Use @Environment(\.keyPath)
    @Environment(\.backgroundColor) var backgroundColor

    var body: some View {
        Text("GrandChild receives background: \(backgroundColor.description)")
            .padding()
            .background(backgroundColor) // Use the value
            .border(Color.black)
    }
}

// --- Demo 2: Read-Only ---
struct ReadOnlyEnvValueDemo: View {
    // Read: Get the read-only value
    @Environment(\.readOnlyInfoText) var infoText

    var body: some View {
        VStack(alignment: .leading) {
            Text("This view reads a read-only value from the environment:")
                .font(.headline)
            Text(infoText)
                .padding()
                .background(Color.yellow.opacity(0.3))
                .border(Color.orange)

            Text("\nAttempting to set it would cause a compile-time error (cannot find key path setter).")
                .font(.caption)
                .italic()
                // .environment(\.readOnlyInfoText, "New Value") // <-- Compile Error!
        }
        .padding()
        .navigationTitle("Read-Only")
    }
}

// --- Demo 3: Access Other (Read-Only) ---
struct AccessOtherEnvValueDemo: View {
    @State private var showSheet = false
    var body: some View {
        Button("Show Sheet (Read-Only Dismiss)") {
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            SheetViewForReadOnlyDismiss()
        }
        .navigationTitle("Access Other (RO)")
    }
}

struct SheetViewForReadOnlyDismiss: View {
    // Read: Use the custom environment value
    @Environment(\.dismissWithMessage) var dismissWithMessage

    var body: some View {
        VStack(spacing: 20) {
            Text("This sheet uses a custom dismiss action.")
            Button("Dismiss with Message") {
                // Use: Call the custom action
                dismissWithMessage("Sheet was dismissed via custom action!")
            }
        }
    }
}

// --- Demo 4: Access Other (Read-Write) ---
struct ReadWriteAccessOtherDemo: View {
    @State private var showSheet = false

    // Define the custom action to be injected
    let customDismissLogic: (Any?) -> Void = { params in
        if let message = params as? String {
            print("--- Custom Action Executed: \(message) ---")
        } else {
            print("--- Custom Action Executed (No specific params) ---")
        }
    }

    var body: some View {
        Button("Show Sheet (Read-Write Dismiss)") {
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            SheetViewForReadWriteDismiss()
                // Set: Provide the custom logic via .environment()
                .environment(\.dismissWithAction, customDismissLogic)
        }
        .navigationTitle("Access Other (RW)")
    }
}

struct SheetViewForReadWriteDismiss: View {
    // Read: Get the environment value (which now includes our custom logic)
    @Environment(\.dismissWithAction) var dismissWithAction

    var body: some View {
        VStack(spacing: 20) {
            Text("This sheet uses a settable custom dismiss action.")
            Button("Dismiss with Custom Action") {
                // Use: Call the action. It will execute *both* our custom logic
                // provided via .environment() AND the original dismiss.
                dismissWithAction("Dismissed with custom params!")
            }
        }
    }
}

// --- Demo 5 & 6: Access Observable & Multi-Function ---
struct CustomObservableDemo: View {
    // Create the state for the Observable object instance
    @State var messageManager = MessageManager()
    @State private var showSheet = false

    var body: some View {
        VStack {
            Text("Message Log:")
                .font(.headline)
            List(messageManager.messages, id: \.self) { message in
                Text(message)
            }
            .frame(height: 150) // Limit height for demo
            .border(Color.mint)

            Button("Show Sheet (Observable Access)") {
                showSheet = true
            }
        }
        .padding()
        // IMPORTANT: We MUST initialize the action struct with the manager instance here.
        // This injects the specific `messageManager` into the environment action.
        .sheet(isPresented: $showSheet) {
            CustomObservableSheet()
                 // Set: Initialize the AddMessageAction with the specific manager instance
                .environment(\.addMessage, AddMessageAction(_manager: messageManager))
                // Note: We DO NOT need .environment(messageManager) here
                // because the action struct holds the reference.
        }
        .navigationTitle("Observable / Multi-Fn")
    }
}

struct CustomObservableSheet: View {
    // Read: Get the action struct instance from the environment
    @Environment(\.addMessage) var addMessage // This is an instance of AddMessageAction

    @State private var count: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("\(count) messages added via environment action.")

            Button("Add Single Message") {
                let message = "Msg #\(count)"
                // Use (Function 1): Call the action struct like a function (invokes first callAsFunction)
                addMessage(message) // Calls callAsFunction(_ message: String)
                count += 1
            }

            Button("Add Two Messages") {
                let messages = ["Msg #\(count)", "Msg #\(count + 1)"]
                 // Use (Function 2): Call with different parameters (invokes second callAsFunction)
                addMessage(messages) // Calls callAsFunction(_ messages: [String])
                count += 2
            }
        }
        .padding()
    }
}

#Preview("ContentView") {
    ContentView()
}

// MARK: - App Entry Point
//
//@main
//struct EnvironmentValuesDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
