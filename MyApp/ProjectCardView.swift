//
//  ProjectCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/29/25.
//

import SwiftUI

// 1. Data Model for the Card
struct CardData: Identifiable {
    let id = UUID() // Conformance to Identifiable
    var title: String
    var subtitle: String
    var workCount: Int
    var progressPercentage: Double // Use Double for progress (0.0 to 1.0)
    var participantCount: Int // Total participants (including hidden ones)
    var visibleParticipantImages: [String] // System names or asset names for visible icons
}

// Helper for Hex Color initialization (Optional but convenient)
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
            (a, r, g, b) = (1, 1, 1, 0) // Default to clear
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

// 2. Card View Implementation
struct ProjectCardView: View {
    let data: CardData

    // Define Colors based on CSS/Image Analysis
    let mainColor = Color.black // --main-color
    let backgroundColor = Color(hex: "#EBD18D") // --bg-color
    let menuBackgroundColor = Color(hex: "#F6DB96")
    let progressBarTrackColor = Color.black.opacity(0.2) // Like #00000030

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Align content to the left

            // --- Top Row ---
            HStack {
                ParticipantView(
                    participantCount: data.participantCount,
                    visibleParticipantImages: data.visibleParticipantImages,
                    mainColor: mainColor
                )

                Spacer() // Pushes elements to sides

                MenuButton(backgroundColor: menuBackgroundColor, mainColor: mainColor)
            }
            .padding(.bottom, 50) // Space below top row (like margin-top on title)

            // --- Middle Content ---
            Text(data.title)
                .font(.system(size: 25, weight: .heavy)) // Heavy for visual boldness
                .foregroundColor(mainColor)
                .lineLimit(2) // Allow title to wrap if needed
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion

            Text(data.subtitle)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(mainColor)
                .padding(.top, 15) // Space below title
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion

            // --- Bottom Section ---
            Text("\(data.workCount) Works / \(Int(data.progressPercentage * 100))%")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(mainColor)
                .padding(.top, 50) // Space below subtitle

            ProgressView(value: data.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: mainColor))
                .frame(height: 4) // Match height from CSS
                .background(progressBarTrackColor) // Custom track color
                .clipShape(RoundedRectangle(cornerRadius: 2)) // Round corners for track and progress
                .padding(.top, 8) // Small space above progress bar
        }
        .padding(25) // Overall padding inside the card
        .background(backgroundColor) // Card background color
        .cornerRadius(20) // Rounded corners for the card
        .frame(width: 300) // Fixed width like in CSS
    }
}

// Helper View for Participants
struct ParticipantView: View {
    let participantCount: Int
    let visibleParticipantImages: [String]
    let mainColor: Color
    let iconSize: CGFloat = 40
    let overlap: CGFloat = -17 // How much icons overlap (adjust as needed)

    var body: some View {
        ZStack {
            // Calculate total participants to display (max 2 images + count bubble)
            let displayCount = min(visibleParticipantImages.count, 2) + 1

            ForEach(0..<displayCount, id: \.self) { index in
                Group {
                    if index == 0 {
                        // The "+N" bubble
                        ZStack {
                            Circle()
                                .fill(mainColor)
                                .frame(width: iconSize, height: iconSize)
                            Text("+\(max(0, participantCount - visibleParticipantImages.count))") // Show remaining count
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    } else if index - 1 < visibleParticipantImages.count {
                        // Visible participant images
                        ZStack {
                            Circle()
                                .fill(.white) // Placeholder background if image fails
                                .frame(width: iconSize, height: iconSize)
                                .overlay(
                                    Circle().stroke(mainColor.opacity(0.5), lineWidth: 1) // Optional border
                                )

                            Image(systemName: visibleParticipantImages[index - 1]) // Use actual images if available
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconSize * 0.8, height: iconSize * 0.8) // Slightly smaller icon within circle
                                .clipShape(Circle())
                                .foregroundColor(mainColor.opacity(0.8)) // Tint for system icons
                        }

                    }
                }
                // Apply offset based on index to create overlap
                .offset(x: CGFloat(index) * (iconSize + overlap))
                // Apply zIndex so the leftmost item (+N) is on top
                .zIndex(Double(displayCount - index))
            }
        }
         // Add padding on the right to prevent clipping if container is tight
        .padding(.trailing, CGFloat(displayCount - 1) * abs(overlap) * 0.5)
    }
}

// Helper View for Menu Button
struct MenuButton: View {
    let backgroundColor: Color
    let mainColor: Color
    let buttonSize: CGFloat = 40

    var body: some View {
        Button(action: {
            // Action for menu button tap
            print("Menu button tapped")
        }) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: buttonSize, height: buttonSize)

                Image(systemName: "ellipsis")
                    .font(.system(size: buttonSize * 0.4, weight: .bold))
                    .foregroundColor(mainColor)
            }
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button styling
    }
}

// 3. Content View for Displaying the Card
struct ContentView: View {
    // Example Data - Stored locally in @State for now
    @State private var cardInfo = CardData(
        title: "Web Design templates Selection",
        subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elitsed do eiusmod.",
        workCount: 135,
        progressPercentage: 0.45, // 45%
        participantCount: 5, // Total participants (e.g., 3 hidden + 2 visible)
        visibleParticipantImages: ["person.crop.circle.fill", "person.crop.circle.fill.badge.plus"] // Example SF Symbols
    )

    var body: some View {
        ZStack {
             Color.black.opacity(0.8).ignoresSafeArea() // Dark background for context
            ProjectCardView(data: cardInfo)
        }
    }
}

// 4. Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
