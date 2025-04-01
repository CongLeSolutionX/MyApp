//
//  ShareSheetView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// MARK: - Share Target Data Structure
struct ShareTarget: Identifiable {
    let id = UUID()
    let iconName: String // SF Symbol name or Asset name
    let label: String
    let iconColor: Color? // Optional: Specific background color for the icon circle
    let isSFSymbol: Bool // Flag to differentiate SF Symbols from asset images

    // Example Initializer for SF Symbols
    init(sfSymbolName: String, label: String, iconBgColor: Color? = Color(.darkGray) ) {
        self.iconName = sfSymbolName
        self.label = label
        self.iconColor = iconBgColor
        self.isSFSymbol = true
    }

    // Example Initializer for Asset Images (like app logos)
    init(assetName: String, label: String, iconBgColor: Color? = nil) { // App icons often have their own color
        self.iconName = assetName
        self.label = label
        self.iconColor = iconBgColor
        self.isSFSymbol = false
    }
}

// MARK: - Share Sheet View Implementation
struct ShareSheetView: View {

    // Placeholder data for share targets (replace icons/colors as needed)
    let shareTargets: [ShareTarget] = [
        ShareTarget(sfSymbolName: "link", label: "Copy link"),
        ShareTarget(assetName: "facebook_logo", label: "Stories", iconBgColor: Color(red: 0.1, green: 0.48, blue: 0.96)), // Placeholder blue
        ShareTarget(assetName: "tiktok_logo", label: "TikTok", iconBgColor: .black), // Placeholder black
        ShareTarget(assetName: "whatsapp_logo", label: "WhatsApp", iconBgColor: Color(red: 0.15, green: 0.8, blue: 0.28)), // Placeholder green
        ShareTarget(assetName: "instagram_logo", label: "Stories", iconBgColor: nil), // Placeholder, needs gradient or asset
        ShareTarget(assetName: "messenger_logo", label: "Messages", iconBgColor: Color(red: 0, green: 0.5, blue: 1.0)), // Placeholder blue
        // Add more targets...
    ]

    @State private var selectedColorIndex: Int = 0 // To track selected color/style
    let backgroundColors: [Color] = [.clear, .gray.opacity(0.5), .black] // Example background options for circles

    var body: some View {
        ZStack {
             // Main Sheet Background (Very Dark)
            Color(red: 0.08, green: 0.08, blue: 0.09)
                .ignoresSafeArea()

            VStack(spacing: 0) { // No spacing between major sections

                // Optional: Add a grabber handle
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.vertical, 8)

                // 1. Content Preview Section
                contentPreview
                    .padding(.horizontal)
                    .padding(.bottom) // Space before share icons

                // 2. Share Actions Section
                shareActions

                Spacer() // Pushes content up if needed
            }
        }
        // Ensure text is readable on the dark background
        .foregroundColor(.white)
    }

    // MARK: - UI Components for Share Sheet

    private var contentPreview: some View {
        VStack {
            // Dark Green Rounded Background
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                     // Approximate dark green from screenshot
                    .fill(Color(red: 0.18, green: 0.25, blue: 0.18))

                // Black Card Content
                VStack(spacing: 8) { // Content inside the black card
                    Image("My-meme-microphone") // Replace with actual image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 10, trailing: 40)) // Adjust padding to size image

                    Text("để tôi ôm em bằng giai điệu này")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Text("CongLeSolutionX")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)

                    HStack {
                         // Replace "spotify_icon" with your actual asset name or find a suitable SF Symbol
                        Image("spotify_icon")
                            .resizable()
                            .renderingMode(.template) // Allows foregroundColor to tint it
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        Text("Spotify")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white) // Icon and text color
                    .padding(.bottom, 20)

                }
                .background(Color.black)
                .cornerRadius(10)
                .padding(20) // Padding between black card and green background
            }

             // Color/Style Selection Row
            HStack(spacing: 15) {
                // Example Color Circles
                styleCircle(index: 0, color: .clear, strokeColor: .white)
                styleCircle(index: 1, gradient: LinearGradient(colors: [.gray, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                styleCircle(index: 2, color: .black)

                Spacer()

                 // Edit Button
                Button {} label: {
                     Image(systemName: "square.and.pencil") // Or "pencil.tip.crop.circle" or similar
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 35, height: 35) // Match circle size
                         .background(
                             Circle()
                                .stroke(Color.gray, lineWidth: 1) // Subtle border like the first circle
                         )
                 }
            }
            .padding(.top) // Space below the green card
            .padding(.horizontal, 20) // Align with green card padding

        }
    }

    // Helper view for the style selection circles
    @ViewBuilder
    private func styleCircle(index: Int, color: Color? = nil, gradient: LinearGradient? = nil, strokeColor: Color = .gray) -> some View {
        Button {
            selectedColorIndex = index
        } label: {
            ZStack {
                if let gradient = gradient {
                    Circle()
                        .fill(gradient)
                } else if let color = color {
                     // Use clear fill for the outlined one
                    Circle()
                        .fill(color == .clear ? Color.black.opacity(0.01) : color) // Use near-clear for hit testing
                }

                // Add outline based on selection and type
                Circle()
                     .stroke(selectedColorIndex == index ? .white : strokeColor, lineWidth: selectedColorIndex == index ? 2 : 1)
            }
            .frame(width: 35, height: 35)
        }
    }

    private var shareActions: some View {
         ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 20) { // Align items to the top, add spacing
                ForEach(shareTargets) { target in
                    Button {
                        // --- ADD ACTION FOR EACH SHARE TARGET ---
                        print("Share to \(target.label)")
                        // e.g., copyToClipboard(), openFacebookStories(), etc.
                        // --- -------------------------------- ---
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                // Background circle if color is provided
                                if let bgColor = target.iconColor {
                                    Circle().fill(bgColor)
                                } else if !target.isSFSymbol {
                                    // Placeholder gradient/color for asset-based icons without explicit color
                                     // Attempting Instagram-like gradient
                                     if target.iconName.contains("instagram") {
                                         Circle().fill(
                                             RadialGradient(
                                                 gradient: Gradient(colors: [.yellow, .red, .purple]),
                                                 center: .center,
                                                 startRadius: 0,
                                                 endRadius: 30 // Adjust radius based on frame size
                                             )
                                         )
                                     } else {
                                         Circle().fill(Color(.darkGray)) // Default if no color specified
                                     }
                                } else {
                                     Circle().fill(Color(.darkGray)) // Default for SF Symbols
                                }

                                 // The Icon Image
                                if target.isSFSymbol {
                                     Image(systemName: target.iconName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(15) // Adjust padding inside the circle
                                        .foregroundColor(.white) // Color for SF Symbols
                                 } else {
                                     // Assume Assets for app logos
                                     Image(target.iconName) // Needs assets named e.g. "facebook_logo.png"
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(target.iconColor == .black ? 12 : 10) // Less padding if icon is complex (like TikTok)
                                }
                            }
                            .frame(width: 60, height: 60) // Size of the circular icon area
                            .clipShape(Circle()) // Ensure icon is contained

                            Text(target.label)
                                .font(.caption)
                                .foregroundColor(.gray) // Label color
                        }
                    }
                }
            }
            .padding(.horizontal) // Padding for the scroll view content
            .padding(.top) // Space above the icons
        }
         .frame(height: 100) // Give the scroll view a defined height
         .padding(.bottom, 30) // Space at the very bottom
    }
}

// MARK: - Share Sheet Preview
struct ShareSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheetView()
            .preferredColorScheme(.dark)
            .onAppear {
                // Add placeholder images to Assets:
                // album_art_placeholder.jpg
                // spotify_icon.png (ideally a template image)
                // facebook_logo.png
                // tiktok_logo.png
                // whatsapp_logo.png
                // instagram_logo.png
                // messenger_logo.png
            }
    }
}
