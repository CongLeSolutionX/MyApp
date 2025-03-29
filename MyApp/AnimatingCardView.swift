//
//  AnimatingCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// MARK: - Data Model

struct CardInfo: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let description: String
    let buttonColorHex: String

    var buttonColor: Color {
        Color(hex: buttonColorHex)
    }
}

// MARK: - Sample Data (Local Storage Simulation)

let sampleCardData = CardInfo(
    number: "01",
    title: "Card",
    description: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Labore, totam velit? Iure nemo labore inventore?",
    buttonColorHex: "#2196f3" // Blue for the first card as per CSS
)

// MARK: - Main Application View

struct ContentView: View {
    var body: some View {
        ZStack {
            // Main container background
            Color(hex: "#232427").edgesIgnoringSafeArea(.all)

            // Display the Card
            CardView(info: sampleCardData)
                .padding(.horizontal, 20) // Give some horizontal space
        }
    }
}

// MARK: - Card View Component

struct CardView: View {
    let info: CardInfo
    @State private var isBoxHovering = false
    @State private var isButtonHovering = false

    // Constants matching CSS where possible
    let cardMinWidth: CGFloat = 320
    let cardHeight: CGFloat = 380
    let cardCornerRadius: CGFloat = 15
    let boxPadding: CGFloat = 20 // Padding inside the card to create the box inset
    let contentPadding: CGFloat = 20 // Padding inside the box for content

    var body: some View {
        ZStack {
            // --- Outer Card Layer (.container .card) ---
            // Simulating the base and complex shadows
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color(hex: "#2a2b2f").opacity(0.5)) // Base color slightly darker than container
                // Outer Shadows (Approximation of CSS)
                .shadow(color: .black.opacity(0.3), radius: 15, x: 5, y: 5) // Dark shadow (bottom-right)
                .shadow(color: .white.opacity(0.05), radius: 15, x: -5, y: -5) // Light shadow (top-left)

            // --- Inner Box Layer (.container .card .box) ---
            ZStack {
                // Inner box background
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .fill(Color(hex: "#2a2b2f"))
                    // Subtle highlight overlay (.box:before)
                    .overlay(
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.03))
                                .frame(width: cardMinWidth / 2) // Approx 50% width
                            Spacer()
                        }
                        .clipped() // Ensure overlay stays within bounds
                    )
                    .cornerRadius(cardCornerRadius) // Important: Apply corner radius *before* clipping if needed elsewhere
                    .clipped() // Clip the overlay content to the box bounds

                // Background Number (.heading) - Place behind content VStack
                Text(info.number)
                    .font(.system(size: 120, weight: .bold)) // Adjusted from 8rem
                    .foregroundColor(Color.white.opacity(0.05)) // Low opacity white
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.trailing, boxPadding)
                    .offset(y: -boxPadding * 2) // Adjust position as needed

                // --- Content Area (.container .card .box .content) ---
                VStack(spacing: 15) {
                    Spacer() // Push content down slightly if needed, or adjust spacing

                    // Title (.content .content in css)
                    Text(info.title)
                        .font(.system(size: 30, weight: .bold)) // Adjusted from 1.8rem
                        .foregroundColor(.white)
                        .zIndex(1) // Ensure it's above background number

                    // Description (p tag)
                    Text(info.description)
                        .font(.system(size: 16, weight: .light)) // Adjusted from 1rem
                        .fontWeight(.light)
                        .foregroundColor(Color.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .zIndex(1) // Ensure it's above background number

                    // Button (a tag)
                    Button {
                        // Action for "Read More"
                        print("Read More tapped for Card \(info.number)")
                    } label: {
                        Text("Read More")
                            .fontWeight(.medium)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(isButtonHovering ? Color.white : info.buttonColor)
                            .foregroundColor(isButtonHovering ? Color.black : Color.white)
                            .cornerRadius(5)
                            // Hover Shadow Change
                            .shadow(color: .black.opacity(isButtonHovering ? 0.6 : 0.2), radius: 10, y: 10)
                    }
                    .buttonStyle(.plain) // Removes default button styling
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.3)) { // Shorter animation for button
                            isButtonHovering = hovering
                        }
                    }
                    .padding(.top, 5) // Equivalent to margin-top: 20px (adjust padding)
                    .zIndex(1)

                    Spacer() // Push content up slightly if needed
                }
                .padding(contentPadding) // Padding for all content elements
            }
            // Padding creates the border/inset effect for the inner box
            .padding(boxPadding)
            // Apply hover effect offset to the inner box
            .offset(y: isBoxHovering ? -50 : 0)

        }
        // --- Card Framing and Hover Activation ---
        .frame(minWidth: cardMinWidth, idealHeight: cardHeight, maxHeight: cardHeight)
        .padding(30) // Margin around the card (.container margin: 30px)
        .onHover { hovering in
            // Apply animation to the box lifting effect
            withAnimation(.easeInOut(duration: 0.5)) {
                isBoxHovering = hovering
            }
        }
        // Explicitly animate the offset change based on hover state
        // Note: While .animation modifier is deprecated, implicit animations with .withAnimation are preferred.
        // However, sometimes an explicit modifier on the container is clearer.
        // Let's stick to .withAnimation inside onHover for modern practice.
    }
}

// MARK: - Color Extension for HEX Support

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

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            // Ensure preview has enough space and dark scheme
            .preferredColorScheme(.dark)
    }
}
