//
//  CardView.swift
//  MyApp
//
//  Created by Cong Le on 11/29/24.
//
import SwiftUI

struct MagicCardView: View {
    @State private var isHovered: Bool = false // Tracks hover interaction
    
    var body: some View {
        ZStack {
            // Glowing shadow effect
            if isHovered {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#f7645b"), Color(hex: "#f7ba2b")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 20
                    )
                    .blur(radius: 25)
                    .opacity(0.7)
                    .scaleEffect(isHovered ? 1.1 : 1) // Slight scaling on hover
            }
            
            // Outer card border
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#f7645b"), Color(hex: "#f7ba2b")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 4
                )
            
            // Inner text label
            Text("Magic Card")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#f7ba2b"))
        }
        .frame(width: 190, height: 254) // Card dimensions
        .scaleEffect(isHovered ? 1.05 : 1) // Slight scaling effect
        .shadow(color: isHovered ? Color(hex: "#f7645b").opacity(0.5) : .clear, radius: 30, x: 0, y: 0)
        .animation(.easeInOut(duration: 0.4), value: isHovered) // Smooth animation
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
    }
}

// Utility for hex color codes
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1 // Skip the "#"

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}



// MARK: - Preview
#Preview("Card View") {
    MagicCardView()
}
