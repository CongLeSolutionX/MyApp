//
//  GradientButton.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI

struct GradientButton: View {
    var body: some View {
        if #available(iOS 18, *) {
            
            let filledRetro80sColor = MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
                colors: [
                    Color(red: 255/255, green: 105/255, blue: 180/255), // Hot Pink
                    Color(red:   0/255, green: 128/255, blue: 128/255), // Teal
                    Color(red: 191/255, green:  64/255, blue: 191/255), // Electric Purple
                    Color(red: 255/255, green: 255/255, blue:   0/255), // Neon Yellow
                    Color(red:   0/255, green:   0/255, blue:   0/255), // Black
                    Color(red: 255/255, green: 140/255, blue:   0/255), // Sunset Orange
                    Color(red:  51/255, green: 255/255, blue: 153/255), // Miami Green
                    Color(red:   0/255, green: 127/255, blue: 255/255), // Synthwave Blue
                    Color(red: 255/255, green:   0/255, blue: 204/255)  // Cyber Pink
                ])
            
            
            Button(action: {
                print("Button tapped!")
            }) {
                Text("Press Me")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(filledRetro80sColor)
                    )
            }
            .padding()
        } else {
            // Fallback to the previous versions
            Button {
                print("Button tapped!")
            } label: {
                Text("Press Me")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(.linearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GradientButton()
}
