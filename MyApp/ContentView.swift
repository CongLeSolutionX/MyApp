//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}
import SwiftUI

// --- ViewModel ---
// Marked as @MainActor, so all its properties and methods
// require access from the main thread unless otherwise specified.
@MainActor
class ConcurrencyViewModel: ObservableObject {

    // @Published properties automatically notify SwiftUI views on the main actor
    // when they change. Accessing them MUST be done from the main actor.
    @Published var sessionData: String = "Initial Value"
    @Published var isLoading: Bool = false
    @Published var statusMessage: String = "Tap button to start"

    /// Simulates fetching/updating data from a background task.
    func updateDataFromBackground() {
        // We are currently on the MainActor because the function is called
        // from the SwiftUI Button action, which runs on the main thread.
        // So, updating isLoading and statusMessage here is safe.
        isLoading = true
        statusMessage = "Background task starting..."
        print("ViewModel: updateDataFromBackground() called (on MainActor).")

        // Launch an asynchronous Task. By default, this *might* run on a
        // background cooperative thread pool if not inheriting an actor context
        // that forces otherwise. It becomes a 'Sendable' context.
        Task {
            print("ViewModel: Background Task started.") // Simple print, no Thread.current
            do {
                // Simulate network call or heavy computation (2 seconds)
                try await Task.sleep(nanoseconds: 2_000_000_000)

                let newValue = "Updated Value (\(Date().formatted(date: .omitted, time: .standard)))"
                print("ViewModel: Background Task finished work, preparing UI update.")

                // --- THE SOLUTION ---
                // Explicitly dispatch the state mutation back to the MainActor's context.
                await MainActor.run {
                    // Now we are guaranteed to be executing on the main thread.
                    print("ViewModel: Executing MainActor.run block (on MainActor).") // Simple print
                    self.sessionData = newValue
                    self.statusMessage = "Update successful via MainActor.run!"
                    self.isLoading = false // Safe to update UI state here
                }

                print("ViewModel: Background Task exiting after MainActor.run.")

            } catch {
                 print("ViewModel: Error occurred in Background Task: \(error)")
                // If the background work itself fails, still update UI safely
                await MainActor.run {
                    print("ViewModel: Executing MainActor.run block for error (on MainActor).") // Simple print
                    self.statusMessage = "Error during background task: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

// --- SwiftUI View ---
struct ContentView: View {
    // Create and observe the ViewModel instance.
    // @StateObject ensures the ViewModel lives as long as the View needs it
    // and correctly handles the @MainActor context for updates.
    @StateObject private var viewModel = ConcurrencyViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Swift Concurrency Demo (Swift 6 Safe)")
                .font(.title)

            Divider()

            VStack {
                Text("Session Data (@MainActor Isolated):")
                    .font(.headline)
                // Displays the @Published sessionData from the ViewModel
                Text(viewModel.sessionData)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .padding()
                    .frame(minHeight: 60) // Ensure space for text
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                    .animation(.easeInOut, value: viewModel.sessionData) // Animate changes
            }

            VStack {
                Text("Status:")
                    .font(.headline)
                // Displays the status message from the ViewModel
                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(height: 40) // Allocate space
            }

            // Show a progress indicator while the background task is running
            if viewModel.isLoading {
                ProgressView("Working...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.vertical)
            } else {
                 // Placeholder to maintain layout stability
                 Color.clear.frame(height: 30).padding(.vertical) // Approx height of ProgressView + text
            }

            // Button to trigger the background update process
            Button {
                viewModel.updateDataFromBackground()
            } label: {
                Label("Update Data from Background Task", systemImage: "arrow.clockwise.circle")
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            // Disable the button while the task is running
            .disabled(viewModel.isLoading)

            Text("Tapping the button starts a Task. UI updates are dispatched back to the MainActor using `await MainActor.run { ... }` for safety.")
                 .font(.footnote)
                 .padding()
                 .background(Color.blue.opacity(0.1))
                 .cornerRadius(5)

        }
        .padding()
    }
}

//// --- Entry Point for Application ---
//@main
//struct ConcurrencyDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

// --- Optional: Preview Provider ---
#Preview {
    ContentView()
}
