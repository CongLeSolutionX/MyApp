//
//  IntroBankCardView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// Define custom colors based on the screenshot
extension Color {
    static let rhBlack = Color(red: 0.05, green: 0.05, blue: 0.05) // Approximation
    static let rhGold = Color(red: 0.8, green: 0.65, blue: 0.3) // Approximation
    static let rhBeige = Color(red: 0.94, green: 0.92, blue: 0.88) // Approximation
    static let rhButtonDark = Color(red: 0.15, green: 0.15, blue: 0.1) // Approximation
    static let rhButtonTextGold = Color(red: 0.9, green: 0.8, blue: 0.5) // Approximation
    static let rhSerifText = Color(red: 0.95, green: 0.93, blue: 0.90) // Off-white for header
    static let rhBodyText = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark grey for body
    static let rhSubtleText = Color(red: 0.4, green: 0.4, blue: 0.4) // Lighter grey
}

struct RobinhoodGoldCardView: View {
    var body: some View {
        // ZStack allows layering the gradient background under the content
        ZStack {
            // Background Gradient (Approximation)
            LinearGradient(
                gradient: Gradient(colors: [.rhBlack, .rhBlack.opacity(0.8), .rhButtonDark.opacity(0.6)]),
                startPoint: .top,
                endPoint: .center // Stops gradient partway down
            )
            .edgesIgnoringSafeArea(.all) // Extend gradient behind status bar

            ScrollView {
                VStack(spacing: 0) { // No default spacing, control manually
                    // Top Bar with Close Button
                    HStack {
                        Button {
                            // Action to dismiss the view
                            print("Close button tapped")
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3.weight(.medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer() // Pushes button to the left
                    }
                    .padding(.horizontal)
                    .padding(.top, 10) // Adjust top padding as needed

                    // Header Text Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Robinhood Gold Card")
                                .font(.headline)
                                .foregroundColor(Color.rhSerifText.opacity(0.9))

                            // Placeholder for the feather icon
                            Image(systemName: "leaf.fill") // System icon placeholder
                                .font(.caption)
                                .foregroundColor(Color.rhSerifText.opacity(0.7))
                        }

                        Text("3% cash back\nacross the board")
                            // Using system Serif font as placeholder
                            // For exact match, load a custom font (e.g., Garamond, Times New Roman variant)
                            .font(.system(size: 40, weight: .medium, design: .serif))
                            .foregroundColor(Color.rhSerifText)
                            .lineSpacing(4) // Adjust line spacing if needed
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 30) // Space before the card

                    // Card Placeholder
                    ZStack {
                        // Card Shape
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.rhGold)
                            .frame(height: 200) // Adjust height as needed
                            .shadow(color: .black.opacity(0.4), radius: 15, y: 10) // Shadow effect

                        // Card Details (Placeholders)
                        HStack {
                             // Chip Placeholder
                             RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 40, height: 30)
                                .overlay(
                                     RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                )
                             Spacer()
                        }
                        .padding(.leading, 25)
                        .padding(.top, -80) // Position chip

                        HStack {
                            Spacer()
                            // Feather Logo Placeholder
                            Image(systemName: "leaf.fill") // Use same placeholder
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, -70) // Position logo
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20) // Space after the card

                    // Benefit Description Section
                    VStack(spacing: 15) {
                        Text("That's right—earn 3% cash back\non all categories.")
                            .font(.title2.weight(.medium))
                            .foregroundColor(Color.rhBodyText)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 5) {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.rhSubtleText)
                            Text("Terms apply")
                                .font(.footnote)
                                .foregroundColor(Color.rhSubtleText)
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity) // Ensures background spans width
                    .background(Color.rhBeige) // Set the beige background for this section

                    // Divider
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                        .padding(.top, 30) // Space before info columns

                    // Info Columns Section
                    HStack(alignment: .top, spacing: 20) {
                        InfoColumn(title: "MATERIAL", value: "Stainless steel")
                        Spacer()
                        InfoColumn(title: "WEIGHT", value: "17 grams")
                        Spacer()
                        InfoColumn(title: "VISA", value: "Signature", isLogo: true) // Placeholder for logo
                    }
                    .padding(.horizontal, 25) // More padding for columns
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.rhBeige) // Continue beige background

                    Spacer(minLength: 30) // Pushes button down if content is short

                    // Continue Button
                    Button {
                        // Action for continue
                        print("Continue button tapped")
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(Color.rhButtonTextGold)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity) // Make button full width (within padding)
                            .background(Color.rhButtonDark)
                            .clipShape(Capsule()) // Rounded corners
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20) // Space from bottom edge
                    .background(Color.rhBeige) // Continue beige background
                }
            }
        }
        .background(Color.rhBeige.edgesIgnoringSafeArea(.all)) // Base background for scrolling area
        .preferredColorScheme(.dark) // Hint to system for status bar style if needed
    }
}

// Reusable View for the Info Columns
struct InfoColumn: View {
    let title: String
    let value: String
    var isLogo: Bool = false // Flag for VISA logo placeholder

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            if isLogo {
                // Placeholder for VISA logo - Use Text for now
                Text("VISA")
                    .font(.system(size: 20, weight: .bold, design: .default)) // Basic styling
                    .foregroundColor(Color.rhBodyText) // Or load actual image
            } else {
                 Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color.rhSubtleText)
                    .kerning(1.0) // Add letter spacing like the design
            }

            Text(value)
                .font(.subheadline)
                .foregroundColor(Color.rhBodyText)
        }
        .frame(minWidth: 70) // Ensure columns have some minimum width
    }
}

// Preview Provider
struct RobinhoodGoldCardView_Previews: PreviewProvider {
    static var previews: some View {
        RobinhoodGoldCardView()
    }
}
