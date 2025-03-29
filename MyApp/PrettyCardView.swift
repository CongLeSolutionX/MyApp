//
//  PrettyCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// Data structure to represent the tools/icons
struct ToolIcon: Identifiable {
    let id = UUID()
    let systemName: String // Using SF Symbols for simplicity
    let size: CGFloat
    let color: Color
}

// Main ContentView
struct ContentView: View {
    // State to hold the tool data (mimics local storage for this view instance)
    @State private var tools: [ToolIcon] = [
        ToolIcon(systemName: "applescript.fill", size: 32, color: .orange), // Placeholder for Ai
        ToolIcon(systemName: "cpu", size: 48, color: .white),             // Placeholder for second icon
        ToolIcon(systemName: "hexagon.fill", size: 64, color: .white),    // Placeholder for center icon (OpenAI)
        ToolIcon(systemName: "infinity", size: 48, color: .blue),       // Placeholder for Meta
        ToolIcon(systemName: "sparkle", size: 32, color: .cyan)        // Placeholder for last icon
    ]

    // State for potential animation
    @State private var animateLine = false

    var body: some View {
        ZStack {
            // Background (can be adjusted)
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.black.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Main Card View
            VStack(spacing: 0) { // Use spacing 0 and add padding manually where needed
                // Top section with icons and mask
                ZStack {
                    // Horizontal stack for the icons
                    HStack(spacing: 16) { // Adjust spacing as needed
                        ForEach(tools) { tool in
                            IconView(tool: tool)
                        }
                    }
                    .padding(.vertical, 60) // Padding to give space for the mask effect
                    // Apply the radial mask
                    .mask {
                        RadialGradient(
                            gradient: Gradient(colors: [.white, .white, .white, .white.opacity(0)]),
                            center: .center,
                            startRadius: 50, // Start fading further out
                            endRadius: 150  // Adjust radius for desired fade effect
                        )
                    }

                    // Vertical Line Gradient below the center icon
                    Rectangle()
                         .fill(
                             LinearGradient(
                                 gradient: Gradient(colors: [.clear, .cyan.opacity(0.8), .clear]),
                                 startPoint: .top,
                                 endPoint: .bottom
                             )
                         )
                         .frame(width: 1.5, height: 100) // Adjust height and width
                         .offset(y: 80) // Position below the center icon (adjust offset)
                         // Optional simple animation
                         .opacity(animateLine ? 0.6 : 1.0)
                         .scaleEffect(y: animateLine ? 1.05 : 1.0, anchor: .top)
                         .onAppear {
                              // Subtle continuous animation
                              withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                  animateLine.toggle()
                              }
                          }

                } // End ZStack for Icons + Line

                // Bottom Text Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Damn good card")
                        .font(.system(size: 20, weight: .semibold)) //.font(.headline).fontWeight(.semibold) is similar
                        .foregroundColor(.white)

                    Text("A card that showcases a set of tools that you use to create your product.")
                        .font(.system(size: 14, weight: .regular)) //.font(.subheadline) is similar
                        .foregroundColor(.white.opacity(0.7)) // Slightly dimmer white
                        .lineSpacing(4) // Add line spacing for readability
                }
                .padding(.horizontal, 24)
                .padding(.top, 20) // Space between icon area and text
                .padding(.bottom, 24) // Bottom padding for the card

            } // End Main VStack for Card Content
            .background(.ultraThinMaterial) // Frosted glass effect
            .cornerRadius(20) // Rounded corners for the card
            .overlay(
                // Subtle border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10) // Optional outer shadow
            .padding(30) // Padding around the card itself
            .frame(maxWidth: 400) // Max width similar to the HTML example

        } // End Outer ZStack
    }
}

// Reusable View for the Icons
struct IconView: View {
    let tool: ToolIcon

    var body: some View {
        ZStack {
            // Circle background with subtle inner shadow approximation (using multiple shadows)
            Circle()
                .fill(Color.white.opacity(0.03)) // Very subtle background
                // Approximating inset shadow with multiple layers:
                 .shadow(color: .white.opacity(0.1), radius: 3, x: 0, y: 1) // Inner highlight top
                 .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 10) // Outer drop shadow

            // The Icon itself
            Image(systemName: tool.systemName)
                .resizable()
                .scaledToFit()
                .foregroundColor(tool.color)
                .frame(width: tool.size * 0.5, height: tool.size * 0.5) // Icon size relative to circle
        }
        .frame(width: tool.size, height: tool.size) // Overall frame for the circle
    }
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}
