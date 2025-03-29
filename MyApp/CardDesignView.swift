//
//  CardDesignView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//


import SwiftUI

// MARK: - Data Model

struct CardInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let author: String
    let date: String
    // Placeholder for actual image loading if needed later
    // let imageName: String? = nil
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Card View

struct CardView: View {
    let info: CardInfo
    @State private var isHovering = false // For hover effect simulation
    
    // Define colors based on CSS
    let cardBackground = Color(hex: "#212121")
    let shadowLight = Color(hex: "#272727")
    let shadowDark = Color(hex: "#1b1b1b")
    let imageBackground = Color(hex: "#313131")
    // Inset shadows are complex in standard SwiftUI, we'll skip precise duplication
    // let imageShadowLight = Color(hex: "#333333")
    // let imageShadowDark = Color(hex: "#2f2f2f")
    let titleColor = Color(hex: "#b2eccf")
    let bodyColor = Color(hex: "#B8B8B8") // rgb(184, 184, 184)
    let footerColor = Color(hex: "#B3B3B3")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Placeholder Area
            RoundedRectangle(cornerRadius: 15)
                .fill(imageBackground)
                .frame(minHeight: 170)
            // Attempt at inset shadow effect (simple approximation)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.black.opacity(0.2), lineWidth: 4)
                        .blur(radius: 3)
                        .offset(x: 2, y: 2)
                        .mask(RoundedRectangle(cornerRadius: 15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .blur(radius: 3)
                        .offset(x: -2, y: -2)
                        .mask(RoundedRectangle(cornerRadius: 15))
                )
            
            
            // Card Title
            Text(info.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(titleColor)
                .padding(.top, 15)
                .padding(.leading, 10)
            
            // Card Body
            Text(info.description)
                .font(.system(size: 15))
                .foregroundColor(bodyColor)
                .lineLimit(nil) // Allow multiple lines
                .padding(.top, 13)
                .padding(.leading, 10)
                .padding(.trailing, 10) // Ensure text doesn't touch the edge
            
            Spacer() // Pushes the footer down
            
            // Footer
            HStack {
                Spacer() // Pushes text to the right
                // Using AttributedString for bolding part of the text
                Text(footerAttributedString())
                    .font(.system(size: 13))
                    .foregroundColor(footerColor)
                    .padding(.trailing, 18) // Matches CSS margin-right (applied as padding here)
                
            }
            .padding(.top, 28) // Matches CSS margin-top
            .padding(.bottom, 0) // Matches CSS margin-bottom (implicitly via padding)
            
            
        }
        .padding(20) // Overall card padding
        .frame(width: 330, alignment: .leading) // Fixed width
        .frame(minHeight: 370) // Minimum height
        .background(cardBackground)
        .cornerRadius(20)
        // Outer Shadows (Neumorphic Style Approximation)
        .shadow(color: shadowDark, radius: 8, x: 5, y: 5)
        .shadow(color: shadowLight, radius: 8, x: -5, y: -5)
        .scaleEffect(isHovering ? 1.03 : 1.0) // Slight scale instead of translate for effect
        .offset(y: isHovering ? -10 : 0)    // Vertical lift effect
        .animation(.spring(), value: isHovering)
        // On macOS/iPadOS, .onHover modifier can be used.
        // For iOS, you might trigger this state via gestures like LongPress.
        // Example placeholder for hover trigger:
        .onTapGesture {
            // Simulate toggle hover for demo
            isHovering.toggle()
        }
        
        
    }
    
    // Helper to create attributed string for footer
    private func footerAttributedString() -> AttributedString {
        let part1 = AttributedString("Written by ")
        var authorName = AttributedString(info.author)
        authorName.font = .system(size: 13, weight: .bold) // Make author bold
        let part2 = AttributedString(" on \(info.date)")
        
        var combined = part1
        combined.append(authorName)
        combined.append(part2)
        return combined
    }
}

// MARK: - Content View

struct CardDesignView: View {
    // Sample Data (Local for now, load from UserDefaults/CoreData later)
    let sampleCard = CardInfo(
        title: "Card title",
        description: "Nullam ac tristique nulla, at convallis quam. Integer consectetur mi nec magna tristique, non lobortis.",
        author: "Cong Le",
        date: "03/28/25"
    )
    
    var body: some View {
        ZStack {
            // Ensure a dark background for the whole screen
            Color(hex: "#1E1E1E").edgesIgnoringSafeArea(.all)
            
            CardView(info: sampleCard)
        }
        .preferredColorScheme(.dark) // Enforce dark mode appearance
    }
}

// MARK: - Preview

#Preview {
    CardDesignView()
}
