//
//  ContributionMatchView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// Define custom colors for easier reuse and management
extension Color {
    static let appDarkGreen = Color(red: 0.0, green: 0.15, blue: 0.1) // Approximate dark green
    static let appLimeGreen = Color(red: 0.7, green: 1.0, blue: 0.35) // Approximate lime green
}

struct ContributionMatchView: View {
    // State for page control (in a real app, this would likely come from a TabView or similar)
    @State private var currentPage = 1 // 0-indexed, so 1 is the middle dot

    var body: some View {
        ZStack {
            // Background Color
            Color.appDarkGreen
                .edgesIgnoringSafeArea(.all)

            // Main Content VStack
            VStack(spacing: 0) { // Use spacing: 0 and Spacers for more control

                Spacer(minLength: 20) // Add some space at the top

                // --- Placeholder Graphic Section ---
                // NOTE: This is a simplified representation.
                // Use Canvas API or an SVG/Image asset for the actual line drawing.
                HStack(alignment: .bottom, spacing: 40) {
                    VStack {
                        Text("IRA MATCH")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.appLimeGreen)
                        // Simple placeholder for the cylinder
                        ZStack {
                            Capsule()
                                .stroke(Color.appLimeGreen, lineWidth: 2)
                                .frame(width: 100, height: 180)

                            Image(systemName: "pencil.and.outline") // Placeholder for feather
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.appLimeGreen)
                                .offset(y: 40) // Position roughly inside

                             // Placeholder for rim ticks
                            Rectangle()
                                .stroke(Color.appLimeGreen, lineWidth: 2)
                                .frame(width: 110, height: 15)
                                .offset(y: -90)
                        }

                    }

                    ZStack {
                         Capsule()
                            .stroke(Color.appLimeGreen, lineWidth: 2)
                            .frame(width: 100, height: 150) // Slightly shorter
                         Text("THEM")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.appLimeGreen)
                    }

                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                // --- End Graphic Section ---

                Spacer(minLength: 30)

                // --- Text Section ---
                VStack(spacing: 15) {
                    Text("You contribute.\nWe match.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.appLimeGreen)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("Instantly get up to 3% extra on every dollar you contribute. Every year.")
                        .font(.body)
                        .foregroundColor(.gray.opacity(0.8)) // Slightly muted color
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                // --- End Text Section ---

                Spacer(minLength: 30)

                 // --- Page Control ---
                 HStack(spacing: 8) {
                     ForEach(0..<3) { index in
                         Circle()
                             .fill(index == currentPage ? Color.appLimeGreen : Color.gray.opacity(0.5))
                             .frame(width: 8, height: 8)
                     }
                 }
                 .padding(.bottom, 30)
                 // --- End Page Control ---

                Spacer() // Pushes the button towards the bottom

                // --- Get Started Button ---
                Button(action: {
                    // Action for the button
                    print("Get Started tapped!")
                }) {
                    Text("Get started")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appDarkGreen) // Dark text on light button
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appLimeGreen)
                        .cornerRadius(25) // Adjust for desired roundness
                }
                .padding(.horizontal, 20) // Give button side padding
                // --- End Button ---

                Spacer(minLength: 20) // Space before the bottom edge / above tab bar
            }
        }
        // It's good practice to set preferred color scheme if the design is strictly dark
         .preferredColorScheme(.dark)
    }
}

// Preview Provider for Canvas
struct ContributionMatchView_Previews: PreviewProvider {
    static var previews: some View {
        // Simulate being inside a TabView structure for realistic preview
        TabView {
            ContributionMatchView()
                .tabItem {
                    Label("Example", systemImage: "star") // Placeholder tab item
                }
        }
    }
}
