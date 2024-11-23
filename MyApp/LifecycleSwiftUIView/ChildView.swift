//
//  ChildView.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//

import SwiftUI

// MARK: - ChildView

struct ChildView: View {
    // State variable to demonstrate state changes within ChildView
    @State private var counter: Int = 0

    // Initialization
    init() {
        print("[ChildView] init called")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Child View")
                .font(.title)
                .padding()

            Text("Counter: \(counter)")
                .font(.headline)

            // Button to increment the counter
            Button(action: {
                counter += 1
                print("[ChildView] Counter incremented to \(counter)")
            }) {
                Text("Increment Counter")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.3))
        .cornerRadius(12)
        // onAppear Modifier
        .onAppear {
            print("[ChildView] onAppear called")
        }
        // onDisappear Modifier
        .onDisappear {
            print("[ChildView] onDisappear called")
        }
    }
}
