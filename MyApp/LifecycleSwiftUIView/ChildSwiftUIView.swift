//
//  ChildSwiftUIView.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//


import SwiftUI

// MARK: - ChildSwiftUIView

struct ChildSwiftUIView: View {
    // State variable to demonstrate state changes within ChildSwiftUIView
    @State private var counter: Int = 0

    // Initialization
    init() {
        print("[ChildSwiftUIView] init called")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Child SwiftUI View")
                .font(.title)
                .padding()

            Text("Counter: \(counter)")
                .font(.headline)

            // Button to increment the counter
            Button(action: {
                counter += 1
                print("[ChildSwiftUIView] Counter incremented to \(counter)")
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
            print("[ChildSwiftUIView] onAppear called")
        }
        // onDisappear Modifier
        .onDisappear {
            print("[ChildSwiftUIView] onDisappear called")
        }
    }
}
