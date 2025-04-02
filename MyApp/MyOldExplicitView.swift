//
//  MyOldExplicitView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//


import SwiftUI

// In Swift 5 mode (or earlier), you might have done this explicitly sometimes:
@MainActor // Explicit annotation (often redundant now for Views in Swift 6 mode)
struct MyOldExplicitView: View {
    @State private var counter = 0

    var body: some View {
        VStack {
            Text("Counter: \(counter)")
            Button("Increment") {
                 // This closure inherits MainActor isolation from the View
                 counter += 1
            }
        }
        .task {
            // Background task might need explicit MainActor switching for UI updates
            // await someBackgroundWork()
            // await MainActor.run { /* Update UI */ } // Still needed if coming from non-MainActor task
        }
    }
}

// In Swift 6 mode, the @MainActor on MyOldExplicitView is usually unnecessary
// because the View protocol itself imposes this requirement.

struct MyImplicitView: View { // No explicit @MainActor needed here
     @State private var message = "Hello"

     var body: some View {
         Text(message) // Guaranteed to run on main actor
        .onTapGesture {
            // Task inherits MainActor context from View's body execution
            Task {
                await updateMessageFromServer()
            }
        }
     }

    // Assume this function might do background work but needs to update UI
    func updateMessageFromServer() async {
        // let fetchedMessage = await fetchFromServer() // Non-main actor potentially
        // await MainActor.run { // Switch back if fetchFromServer wasn't @MainActor
        //    self.message = fetchedMessage
        // }
        // If fetchFromServer *was* marked @MainActor, the switch isn't needed.
         self.message = "Updated!" // If already on main actor, this is fine.
    }
}

#Preview {
    VStack {
        MyOldExplicitView()
        MyImplicitView()
    }
}

// Key Takeaway: Marking your View structs explicitly with @MainActor is
// generally not required when building for Swift 6, as the View protocol
// now handles this. However, understanding actor isolation is still crucial
// when dealing with background tasks or models not isolated to the main actor.
