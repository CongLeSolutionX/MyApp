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
    let animationDuration: TimeInterval = 0.5 // CSS transition duration

    var body: some View {
        ZStack { // Main ZStack for the entire card
            // --- Outer Card Layer (.container .card) ---
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color(hex: "#2a2b2f").opacity(0.5))
                .shadow(color: .black.opacity(0.3), radius: 15, x: 5, y: 5)
                .shadow(color: .white.opacity(0.05), radius: 15, x: -5, y: -5)

            // --- Inner Box Layer (.container .card .box) ---
            ZStack { // ZStack for the inner box and its content
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .fill(Color(hex: "#2a2b2f"))
                    .overlay(
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.03))
                                .frame(width: cardMinWidth / 2)
                            Spacer()
                        }
                        .clipped()
                    )
                    .cornerRadius(cardCornerRadius)
                    .clipped()

                Text(info.number)
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.05))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.trailing, 30) // Increased padding slightly
                    .offset(y: -15) // Adjusted offset slightly

                VStack(spacing: 15) {
                    Spacer()

                    Text(info.title)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .zIndex(1)

                    Text(info.description)
                        .font(.system(size: 16, weight: .light))
                        .fontWeight(.light)
                        .foregroundColor(Color.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .zIndex(1)

                    Button {
                        print("Read More tapped for Card \(info.number)")
                    } label: {
                        Text("Read More")
                            .fontWeight(.medium)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(isButtonHovering ? Color.white : info.buttonColor)
                            .foregroundColor(isButtonHovering ? Color.black : Color.white)
                            .cornerRadius(5)
                            .shadow(color: .black.opacity(isButtonHovering ? 0.6 : 0.2), radius: 10, y: 10)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isButtonHovering = hovering
                        }
                    }
                    .padding(.top, 5)
                    .zIndex(1) // Explicit zIndex often helps with layering complex views

                    Spacer()
                }
                .padding(contentPadding)
            }
            .padding(boxPadding)
            .offset(y: isBoxHovering ? -50 : 0) // This offset is animated by the state change

        }
        // --- Card Framing and Interaction Triggers ---
        .frame(minWidth: cardMinWidth, idealHeight: cardHeight, maxHeight: cardHeight)
        .padding(30) // Margin around the card
        // --- Hover Modifier (for platforms with pointers) ---
        .onHover { hovering in
            // Animate the state change based on hover
            withAnimation(.easeInOut(duration: animationDuration)) {
                isBoxHovering = hovering
            }
        }
        // --- Tap Modifier (for touch platforms) ---
        .onTapGesture {
            // Trigger the animation upwards
            withAnimation(.easeInOut(duration: animationDuration)) {
                isBoxHovering = true
            }
            // Schedule the animation back down after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.1) { // Wait for animation + tiny buffer
                 withAnimation(.easeInOut(duration: animationDuration)) {
                    // Only set back to false if it hasn't been triggered again by hover
                    // Note: This simple logic might have edge cases if tap and hover interleave rapidly.
                    // For basic use, it should be fine.
                    isBoxHovering = false
                 }
            }
         }
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
            .preferredColorScheme(.dark)
            // To test tap easily in preview on macOS, you might need to run on a simulator/device.
            // Previews might favor hover.
            .previewLayout(.sizeThatFits) // Adjust preview layout if needed
            .padding(50) // Ensure container background shows around the card
    }
}
