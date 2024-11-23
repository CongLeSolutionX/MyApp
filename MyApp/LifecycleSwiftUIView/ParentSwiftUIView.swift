//
//  ParentSwiftUIView.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//


import SwiftUI

// MARK: - ParentSwiftUIView

struct ParentSwiftUIView: View {
    // State variable to control the visibility of ChildSwiftUIView
    @State private var isChildVisible: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Parent SwiftUI View")
                .font(.largeTitle)
                .padding()

            // Button to toggle ChildSwiftUIView visibility
            Button(action: {
                isChildVisible.toggle()
            }) {
                Text(isChildVisible ? "Hide Child SwiftUI View" : "Show Child SwiftUI View")
                    .padding()
                    .background(isChildVisible ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // Conditionally display ChildSwiftUIView
            if isChildVisible {
                ChildSwiftUIView()
                    .transition(.slide) // Adding a transition for better visual effect
            }
        }
        .animation(.easeInOut, value: isChildVisible) // Animate the toggle
    }
}

// MARK: - Preview

struct ContentParentSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ParentSwiftUIView()
    }
}
