//
//  CardView.swift
//  MyApp
//
//  Created by Cong Le on 11/29/24.
//
import SwiftUI

struct MagicCardView: View {
    @State private var isInteracting: Bool = false // Tracks interaction state

    var body: some View {
        ZStack {
            // Outer card border with dynamic properties based on interaction state
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#f7645b"), Color(hex: "#f7ba2b")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: isInteracting ? 20 : 4
                )
                .blur(radius: isInteracting ? 25 : 0)
                .opacity(isInteracting ? 0.7 : 1)
                .scaleEffect(isInteracting ? 1.1 : 1) // Slight scaling on interaction

            // Inner text label
            Text("Magic Card")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#f7ba2b"))
        }
        .frame(width: 190, height: 254) // Card dimensions
        .scaleEffect(isInteracting ? 1.05 : 1) // Slight scaling effect
        .shadow(color: Color(hex: "#f7645b").opacity(isInteracting ? 0.5 : 0), radius: isInteracting ? 30 : 0)
        .animation(.easeInOut(duration: 0.4), value: isInteracting) // Smooth animation
        
    }
}

// Utility for hex color codes
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        if hex.count == 6 {
            // RGB (24-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        } else {
            // Fallback to gray color for invalid hex input
            (r, g, b) = (128, 128, 128)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}





// MARK: - Preview
#Preview("Magic Card View") {
    MagicCardView()
}
