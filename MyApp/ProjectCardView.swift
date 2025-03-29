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
                ParticipantView( // Pass data to the helper view
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
                 // --- Correction: Apply modifiers correctly for track background ---
                .frame(height: 4) // Set height *before* background/clipShape
                .background(progressBarTrackColor) // Apply background for the track
                .clipShape(RoundedRectangle(cornerRadius: 2)) // Clip the *whole* ProgressView frame
                .padding(.top, 8) // Small space above progress bar
        }
        .padding(25) // Overall padding inside the card
        .background(backgroundColor) // Card background color
        .cornerRadius(20) // Rounded corners for the card
        .frame(width: 300) // Fixed width like in CSS
    }
}

// Helper View for Participants (Corrected)
struct ParticipantView: View {
    let participantCount: Int
    let visibleParticipantImages: [String]
    let mainColor: Color
    let iconSize: CGFloat = 40
    let overlap: CGFloat = -17 // How much icons overlap (adjust as needed)

    var body: some View {
        // Calculate total participants *slots* to display (max 2 images + count bubble/first icon)
        let displaySlots = min(visibleParticipantImages.count, 2) + 1
        // Calculate the actual number of hidden participants
        let hiddenCount = max(0, participantCount - visibleParticipantImages.count)

        ZStack {
             // Now displaySlots is in scope here
             ForEach(0..<displaySlots, id: \.self) { index in
                Group {
                    // Logic for first slot (index 0)
                    if index == 0 {
                        ZStack {
                             Circle()
                                 .fill(mainColor) // Base circle color (black)
                                 .frame(width: iconSize, height: iconSize)

                              // Show "+N" only if there are hidden participants
                             if hiddenCount > 0 {
                                 Text("+\(hiddenCount)")
                                     .font(.system(size: 16, weight: .medium))
                                     .foregroundColor(.white)
                             } else if !visibleParticipantImages.isEmpty {
                                 // If no hidden count, show the *first* visible participant here
                                 ZStack { // Use ZStack to overlay on the black circle if needed, or adjust fill
                                     Circle()
                                          .fill(.white) // White background for the icon
                                          .frame(width: iconSize, height: iconSize)
                                          .overlay( Circle().stroke(mainColor.opacity(0.5), lineWidth: 1))

                                      Image(systemName: visibleParticipantImages[0]) // Show first image
                                          .resizable()
                                          .scaledToFit()
                                          .frame(width: iconSize * 0.8, height: iconSize * 0.8)
                                          .clipShape(Circle())
                                          .foregroundColor(mainColor.opacity(0.8))
                                 }
                             }
                             // Else (no hidden count and no visible images) - shows just the black circle
                        }
                    }
                     // Logic for subsequent slots (index > 0)
                    // Check if slot corresponds to a visible image & avoid re-displaying image[0] if shown in first slot
                    else if index < visibleParticipantImages.count && (hiddenCount > 0 || index > 0) {
                         // Get the correct image index
                         let imageIndex = (hiddenCount > 0) ? index - 1 : index

                         if imageIndex < visibleParticipantImages.count { // Double check bounds
                               ZStack {
                                   Circle()
                                       .fill(.white) // Placeholder background
                                       .frame(width: iconSize, height: iconSize)
                                       .overlay(
                                           Circle().stroke(mainColor.opacity(0.5), lineWidth: 1) // Optional border
                                       )

                                   Image(systemName: visibleParticipantImages[imageIndex]) // Use actual images
                                       .resizable()
                                       .scaledToFit()
                                       .frame(width: iconSize * 0.8, height: iconSize * 0.8)
                                       .clipShape(Circle())
                                       .foregroundColor(mainColor.opacity(0.8))
                               }
                         }
                     }
                }
                 // Apply offset based on index to create overlap
                 .offset(x: CGFloat(index) * (iconSize + overlap))
                  // Apply zIndex so the leftmost item is on top
                 .zIndex(Double(displaySlots - index))
            }
        }
          // Add padding on the right to prevent clipping if container is tight
         .padding(.trailing, CGFloat(max(0, displaySlots - 1)) * abs(overlap))
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
        participantCount: 5, // Total participants (e.g., +3 hidden + 2 visible = 5)
        visibleParticipantImages: ["person.crop.circle.fill", "figure.stand"] // Example SF Symbols for 2 visible
        // If participantCount was 2, hiddenCount would be 0.
        // If participantCount was 3, hiddenCount would be 1 (+1 bubble and 2 visible icons).
    )

    // Example with participant count matching visible icons (no "+N" bubble)
//    @State private var cardInfo = CardData(
//        title: "App Development Planning",
//        subtitle: "Defining features and milestones for the next release cycle.",
//        workCount: 50,
//        progressPercentage: 0.90, // 90%
//        participantCount: 2, // Total participants = visible count
//        visibleParticipantImages: ["person.crop.square", "person.wave.2.fill"] // Example SF Symbols
//    )

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
