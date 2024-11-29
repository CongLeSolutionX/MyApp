//
//  CardView.swift
//  MyApp
//
//  Created by Cong Le on 11/29/24.
//
import SwiftUI

struct CardView: View {
    @State private var isHovered: Bool = false // Track hover state

    var body: some View {
        ZStack {
            // Background blur effect
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#f7ba2b"), Color(hex: "#ea5358")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .scaleEffect(0.8)
                .blur(radius: isHovered ? 0 : 25) // Blur effect based on hover
                .opacity(isHovered ? 0 : 1) // Hide the blur effect on hover
                .animation(.easeInOut(duration: 0.5), value: isHovered)

            // Card foreground
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#f7ba2b")) // Primary gradient background
                .overlay(
                    Text("Card Info")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isHovered ? Color(hex: "#f7ba2b") : Color(hex: "#181818"))
                        .animation(.easeInOut(duration: 1), value: isHovered) // Smooth text color transition
                )
                .frame(width: 190, height: 254)
                .shadow(radius: 10) // Add slight shadow for realism
        }
        .frame(width: 190, height: 254) // Explicit frame for card dimensions
        .onHover { hovering in
            self.isHovered = hovering
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
    CardView()
}
