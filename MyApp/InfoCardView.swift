//
//  InfoCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/29/25.
//

import SwiftUI

// Define the data structure for list items (Local Storage)
struct FeatureItem: Identifiable {
    let id = UUID()
    let text: String
}

// Define custom colors inspired by the CSS variables
extension Color {
    static let cardBackground = Color(hue: 240/360, saturation: 0.15, brightness: 0.09)
    static let paragraphText = Color(white: 0.83)
    static let lineSeparator = Color(hue: 240/360, saturation: 0.09, brightness: 0.17)
    static let primaryPurple = Color(hue: 266/360, saturation: 0.92, brightness: 0.58)

    // Button Gradient Colors
    static let buttonGradientStart = Color(red: 94/255, green: 58/255, blue: 238/255)
    static let buttonGradientEnd = Color(red: 197/255, green: 107/255, blue: 240/255)

    // Background Gradient Overlay Colors (Approximation)
    static let backgroundGradient1 = Color(red: 90/255, green: 40/255, blue: 200/255).opacity(0.6) // Purple
    static let backgroundGradient2 = Color(red: 200/255, green: 100/255, blue: 240/255).opacity(0.4) // Lighter Purple/Pink
    static let backgroundGradient3 = Color(red: 240/255, green: 150/255, blue: 250/255).opacity(0.5) // Pinkish
}

struct ContentView: View {
    // Local data for the feature list
    let features: [FeatureItem] = [
        FeatureItem(text: "10 Launch Weeks"),
        FeatureItem(text: "10 Influencers Post"),
        FeatureItem(text: "100.000 Views"),
        FeatureItem(text: "10 Reddit Posts"),
        FeatureItem(text: "2 Hours Marketing Consultation")
    ]

    // State for the rotating border effect (optional enhancement)
    @State private var isRotating = false

    var body: some View {
        ZStack {
            // Background Color
            Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all) // Simple background for context

            // --- Card Start ---
            ZStack {
                // Base Card Shape & Background Color
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .frame(width: 304) // Approx 19rem * 16px/rem

                // Background Gradient Effects (Approximation of radial gradients)
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.backgroundGradient3.opacity(0.5), Color.cardBackground.opacity(0.1)]),
                            center: .bottomTrailing,
                            startRadius: 50,
                            endRadius: 350
                        )
                    )
                    .frame(width: 304)
                     .blur(radius: 50) // Blur to soften the effect

                RoundedRectangle(cornerRadius: 16)
                     .fill(
                         RadialGradient(
                            gradient: Gradient(colors: [Color.backgroundGradient1.opacity(0.6), Color.cardBackground.opacity(0.1)]),
                             center: UnitPoint(x: 0.1, y: 0.8),
                             startRadius: 30,
                             endRadius: 300
                         )
                     )
                     .frame(width: 304)
                     .blur(radius: 60)

                // Content VStack
                VStack(alignment: .leading, spacing: 16) { // Approx 1rem gap
                    // Title and Paragraph
                    VStack(alignment: .leading, spacing: 4) { // Approx 0.25rem gap
                        Text("Explosive Growth")
                            .font(.system(size: 20, weight: .semibold)) // Adjusted size slightly
                            .foregroundColor(.white)

                        Text("Perfect for your next content, leave to us and enjoy the result!")
                            .font(.system(size: 12)) // Approx 0.5rem * 1.5 scaling -> ~12pt
                            .foregroundColor(.paragraphText)
                            .frame(maxWidth: .infinity, alignment: .leading) // Allow text wrap
                            .lineLimit(nil) // Allow multiple lines
                    }
                    .frame(width: 304 * 0.70) // Approx 65% width constraint

                    // Line Separator
                    Rectangle()
                        .fill(Color.lineSeparator)
                        .frame(height: 1) // Approx 0.1rem

                    // Feature List
                    VStack(alignment: .leading, spacing: 8) { // Approx 0.5rem gap
                        ForEach(features) { feature in
                            HStack(spacing: 8) { // Approx 0.5rem gap
                                ZStack {
                                    Circle()
                                        .fill(Color.primaryPurple)
                                        .frame(width: 20, height: 20) // Approx 1rem + adjustment
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10, height: 10) // Approx 0.75rem
                                        .foregroundColor(Color.cardBackground) // Match dark fill
                                        .fontWeight(.bold)
                                }

                                Text(feature.text)
                                    .font(.system(size: 14)) // Approx 0.75rem -> 14pt
                                    .foregroundColor(.white)
                            }
                        }
                    }

                    // Button
                    Button(action: {
                        // Action for booking a call
                        print("Book a Call button tapped")
                    }) {
                        Text("Book a Call")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity) // Full width
                            .padding(.vertical, 10) // Approx 0.5rem padding
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.buttonGradientStart, Color.buttonGradientEnd]),
                                    startPoint: .top, // Adjusted gradient direction slightly
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                            // Approximation of the inset white shadow from bottom
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1) // Subtle outline
                                    .blur(radius: 2)
                                    .offset(y: 1) // Slightly offset down
                                    .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: -3) // Glow effect from bottom up
                            )
                    }
                     .buttonStyle(.plain) // Removes default button styling

                }
                .padding(16) // Approx 1rem padding
                .frame(width: 304) // Match parent width

                // --- Border Effects ---

                // 1. Static Gradient Border Background (Approximation of card__border)
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1 // Keep it subtle
                    )
                    .frame(width: 304, height: calculateCardHeight()) // Match size dynamically if possible or estimate

                 // 2. Animated "Rotating" Highlight (Approximation of card__border::before)
                 //    This is complex; using AngularGradient for a *static* shimmer effect.
                 RoundedRectangle(cornerRadius: 16)
                     .stroke(
                         AngularGradient(
                             gradient: Gradient(colors: [
                                 Color.primaryPurple.opacity(0.8),
                                 Color.buttonGradientEnd.opacity(0.9),
                                 Color.primaryPurple.opacity(0.8),
                                 Color.white.opacity(0.1), // Fades out
                                 Color.white.opacity(0.1), // Fades out
                                 Color.primaryPurple.opacity(0.8) // Completes circle
                             ]),
                             center: .center,
                             startAngle: .degrees(isRotating ? 0 : 180), // Animate start angle
                             endAngle: .degrees(isRotating ? 360 : 540)
                         ),
                         lineWidth: 2 // Slightly thicker highlight
                     )
                     .frame(width: 304, height: calculateCardHeight()) // Match size
                     .blur(radius: 3) // Soften the rotating highlight
                    // Uncomment for animation - performance impact needs testing
                      .onAppear {
                          withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                              isRotating.toggle()
                          }
                      }

                // 3. Top Inset Glow (Approximation of box-shadow inset)
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white.opacity(0.15), location: 0), // Brighter at top
                                .init(color: Color.white.opacity(0.0), location: 0.15) // Fade out quickly
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 304, height: calculateCardHeight() * 0.4) // Affect top part
                    .mask(RoundedRectangle(cornerRadius: 16).frame(width: 304)) // Mask to shape
                    .allowsHitTesting(false) // Let clicks pass through
                    .frame(width: 304, height: calculateCardHeight(), alignment: .top) // Align overlay

            }
            // Apply a subtle outer shadow to the whole card ZStack if needed
             .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

            // --- Card End ---
        }
    }

    // Helper to estimate card height for border overlays
    // This is tricky without geometry reader; adjust based on content.
    private func calculateCardHeight() -> CGFloat {
       // Estimate based on spacing, text lines, list items, button height etc.
       // This is an approximation. A GeometryReader would be more precise.
       let titleHeight: CGFloat = 25 // Approx
       let paragraphHeight: CGFloat = 30 // Approx (2 lines)
       let lineheight: CGFloat = 1
       let listItemsHeight: CGFloat = CGFloat(features.count) * (14 + 8) // Font size + spacing
       let checkmarkHeightAdjustment: CGFloat = 6 * CGFloat(features.count) // Check overlaps a bit
       let buttonHeight: CGFloat = 40 // Approx (padding + text)
       let verticalPadding: CGFloat = 16 * 2
       let spacing: CGFloat = 16 * 3 // 3 main gaps

        return titleHeight + paragraphHeight + lineheight + listItemsHeight - checkmarkHeightAdjustment + buttonHeight + verticalPadding + spacing + 10 // Add some buffer
    }
}

#Preview {
    ContentView()
}
