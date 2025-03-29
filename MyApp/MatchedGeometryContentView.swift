//
//  MatchedGeometryContentView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// Define a simple data structure for items if needed, or use simple views directly.
// For this demonstration, we'll just use basic Shapes and Text directly.

struct MatchedGeometryContentView: View {
    // 1. Define a namespace for the geometry effect.
    // This namespace groups elements whose geometry should be synchronized.
    @Namespace private var animationNamespace

    // 2. State variable to toggle between two views.
    @State private var showDetail: Bool = false

    // 3. Define a common identifier for the elements to be matched.
    // This ID must be Hashable. A simple String is often sufficient.
    let shapeId = "shapeTransition"

    var body: some View {
        VStack {
            Spacer() // Pushes content towards the center/top

            // Conditionally display one of two views based on the state.
            if showDetail {
                // --- Detail View ---
                VStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.blue)
                         // 4. Apply the matchedGeometryEffect modifier.
                         // Use the same ID and namespace as the other view.
                        .matchedGeometryEffect(id: shapeId, in: animationNamespace)
                        .frame(width: 300, height: 200)
                        .shadow(radius: 10)

                    Text("Detail View")
                        .font(.title)
                        .matchedGeometryEffect(id: "title_\(shapeId)", in: animationNamespace) // Optional: match text too


                    Text("More information appears here when the detail view is shown.")
                        .font(.body)
                        .padding()

                    Spacer() // Pushes button down
                    
                    Button("Close") {
                        // 5. Animate the state change.
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)) {
                             showDetail.toggle()
                        }
                    }
                     .padding(.bottom)

                }
                .frame(maxWidth: .infinity, maxHeight: 400) // Give detail view a container frame
                 .padding()
                 .background(Color(.systemGray6))
                 .cornerRadius(20)
                  .padding(.horizontal) // Add horizontal padding for detail view

            } else {
                // --- Thumbnail/Summary View ---
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                         .fill(.teal)
                         // 4. Apply the matchedGeometryEffect modifier.
                         // Use the same ID and namespace as the other view.
                        .matchedGeometryEffect(id: shapeId, in: animationNamespace)
                        .frame(width: 80, height: 80)


                    VStack(alignment: .leading) {
                        Text("Thumbnail")
                             .font(.headline)
                             .matchedGeometryEffect(id: "title_\(shapeId)", in: animationNamespace) // Optional: Match text too
                        Text("Tap for details")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                     }
                     Spacer() // Pushes content to the left
                }
                  .padding()
                  .background(Color(.systemGray6))
                  .cornerRadius(15)
                  .shadow(radius: 5)
                   .padding(.horizontal) // Add horizontal padding for thumbnail view
                   .onTapGesture {
                       // 5. Animate the state change.
                       withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)) {
                          showDetail.toggle()
                       }
                   }
            }

            Spacer() // Pushes content towards the center/bottom
        }
         // Ensure the overall stack takes up space and provides a background
         .frame(maxWidth: .infinity, maxHeight: .infinity)
//         .background(Color(.secondarySystemBackground))
         .background(Image(uiImage: UIImage(named: "My-meme-original")!))
    }
}

// #Preview { // Use #Preview for Xcode 15+ previews
//     MatchedGeometryContentView()
// }

// If using older Xcode versions for previews:
struct MatchedGeometryContentView_Previews: PreviewProvider {
   static var previews: some View {
        MatchedGeometryContentView()
   }
}
