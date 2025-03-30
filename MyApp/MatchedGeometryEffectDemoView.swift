//
//  MatchedGeometryEffectDemoView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// Main view demonstrating the matched geometry effect
struct MatchedGeometryExampleView: View {

    // 1. Create a namespace for the matching effect.
    //    This namespace defines the scope within which views can match.
    @Namespace private var animationNamespace

    // 2. State to toggle between the two visual representations.
    @State private var showDetail: Bool = false

    // 3. Define a consistent identifier for the conceptual element
    //    that is visually changing. This MUST be Hashable.
    private let sharedElementId = "shape"

    var body: some View {
        VStack(spacing: 30) {
            Spacer() // Push content towards center/top

            // 4. Conditionally display one of the two views based on state.
            if showDetail {
                // --- Detail (Large Rectangle) View ---
                RoundedRectangle(cornerRadius: 10)
                    .fill(.red)
                    .frame(width: 250, height: 200)
                    // 5a. Apply the matchedGeometryEffect modifier.
                    //     Use the same `id` and `namespace` as the circle view.
                    .matchedGeometryEffect(
                        id: sharedElementId,
                        in: animationNamespace,
                        properties: .frame, // Sync both position and size (default)
                        anchor: .center,    // Align centers during transition (default)
                        isSource: true      // This view provides the geometry in this state
                    )
                    .onTapGesture {
                        // 6a. Toggle state inside an animation block for smooth transition.
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            showDetail.toggle()
                        }
                    }

            } else {
                // --- Compact (Small Circle) View ---
                Circle()
                    .fill(.blue)
                    .frame(width: 100, height: 100)
                     // 5b. Apply the matchedGeometryEffect modifier.
                     //     Use the same `id` and `namespace` as the rectangle view.
                    .matchedGeometryEffect(
                        id: sharedElementId,
                        in: animationNamespace,
                        properties: .frame,
                        anchor: .center,
                        isSource: true // This view provides the geometry in this state
                    )
                    .onTapGesture {
                         // 6b. Toggle state inside an animation block for smooth transition.
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            showDetail.toggle()
                        }
                    }
            }

            Spacer() // Push content towards center/bottom

             // Alternative button to toggle state (optional)
            Button(showDetail ? "Show Circle" : "Show Rectangle") {
                 withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showDetail.toggle()
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("Matched Geometry") // Add a title if needed
    }
}

// Previews (optional, but helpful for development)
#Preview {
    NavigationView { // Wrap in NavigationView for title display
       MatchedGeometryExampleView()
    }
}
