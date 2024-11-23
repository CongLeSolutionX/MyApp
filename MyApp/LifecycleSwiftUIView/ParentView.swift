//
//  ParentView.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//

import SwiftUI

// MARK: - ParentView

struct ParentView: View {
    // State variable to control the visibility of ChildView
    @State private var isChildVisible: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Parent View")
                .font(.largeTitle)
                .padding()

            // Button to toggle ChildView visibility
            Button(action: {
                isChildVisible.toggle()
            }) {
                Text(isChildVisible ? "Hide Child View" : "Show Child View")
                    .padding()
                    .background(isChildVisible ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // Conditionally display ChildView
            if isChildVisible {
                ChildView()
                    .transition(.slide) // Adding a transition for better visual effect
            }
        }
        .animation(.easeInOut, value: isChildVisible) // Animate the toggle
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
    }
}
