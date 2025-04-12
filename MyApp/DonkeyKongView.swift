//
//  DonkeyKongView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI

// Main View Container
struct DonkeyKongView: View {
    var body: some View {
        ZStack {
            // Background Color
            Color.black
                .edgesIgnoringSafeArea(.all)

            // Main Content Layout
            VStack(spacing: 0) {
                InfoBarView()
                    .padding(.top, 5) // Adjust padding as needed
                    .padding(.horizontal)

                Spacer() // Pushes game area down if needed, adjust layout

                GameAreaView()
                    .padding(.bottom) // Add some padding at the bottom

                Spacer() // Ensure content placement, adjust as needed
            }
        }
        // Apply a monospaced font globally if desired, or individually
        // .font(.system(.body, design: .monospaced))
    }
}

// Top Information Bar (Scores, Level)
struct InfoBarView: View {
    var body: some View {
        HStack {
            // Player 1 Score
            VStack(alignment: .leading) {
                Text("1UP")
                    .foregroundColor(.white)
                    .font(.custom("PixelEmulator", size: 18)) // Example Custom Font
                Text("000000")
                    .foregroundColor(.white)
                    .font(.custom("PixelEmulator", size: 18))
            }

            Spacer()

            // High Score
            VStack {
                Text("HIGH SCORE")
                    .foregroundColor(.red)
                    .font(.custom("PixelEmulator", size: 18))
                Text("000000")
                    .foregroundColor(.white)
                    .font(.custom("PixelEmulator", size: 18))
            }

            Spacer()

            // Level and Bonus Items
            VStack(alignment: .trailing) {
                Text("L=01")
                    .foregroundColor(.blue)
                    .font(.custom("PixelEmulator", size: 18))
                // Placeholder for Bonus Item indicators
                 HStack {
                    Image(systemName: "hammer.fill") // Example bonus item
                         .foregroundColor(.orange)
                         .font(.system(size: 16))
                    Text("0")
                         .foregroundColor(.orange)
                         .font(.custom("PixelEmulator", size: 16))
                 }
            }
        }
        .padding(.bottom, 10) // Space between info bar and game area
    }
}

// Represents the main game play area
struct GameAreaView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // --- Background Elements (Platforms, Ladders) ---
                VStack(spacing: geometry.size.height * 0.1) { // Adjust spacing dynamically
                    PlatformView(width: geometry.size.width * 0.9) // Top platform with DK
                    PlatformView(width: geometry.size.width * 0.8)
                    PlatformView(width: geometry.size.width * 0.9, isBroken: true, breakPosition: 0.3)
                    PlatformView(width: geometry.size.width * 0.85)
                    PlatformView(width: geometry.size.width * 0.95) // Bottom platform
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.55) // Center platforms vertically slightly offset

                // Example Ladders (Position manually or calculate based on platform positions)
                LadderView(height: geometry.size.height * 0.15)
                    .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.25)

                LadderView(height: geometry.size.height * 0.15, isBroken: true)
                    .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.45)

                 LadderView(height: geometry.size.height * 0.15)
                    .position(x: geometry.size.width * 0.6, y: geometry.size.height * 0.65)

                // --- Foreground Elements (Characters, Lives) ---
                // Placeholders - Position these precisely based on game state
                // Using simple shapes/text for representation

                 // Lives Indicator (Top Left)
                VStack {
                    CharacterPlaceholder(label: "M", color: .blue, size: 15)
                    CharacterPlaceholder(label: "M", color: .blue, size: 15)
                }
                .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.1)

                CharacterPlaceholder(label: "DK", color: .brown, size: 50)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.15) // Approx DK position

                CharacterPlaceholder(label: "P", color: .pink, size: 25)
                     .position(x: geometry.size.width * 0.65, y: geometry.size.height * 0.18) // Approx Princess position

                CharacterPlaceholder(label: "M", color: .red, size: 25)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.85) // Approx Mario start position

                 // Item Indicator (Near Mario Start)
                 HStack {
                    Image(systemName: "heart.fill") // Placeholder Item
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                      Text("0")
                         .foregroundColor(.red)
                         .font(.custom("PixelEmulator", size: 16))
                 }
                 .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.18)

            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        // Determine the desired aspect ratio for the game area
         .aspectRatio(3.0 / 4.0, contentMode: .fit) // Typical arcade aspect ratio approximation
    }
}

// Represents a single platform girder
struct PlatformView: View {
    let width: CGFloat
    var isBroken: Bool = false
    var breakPosition: CGFloat = 0.5 // 0.0 to 1.0

    var body: some View {
        GirderShape(isBroken: isBroken, breakPosition: breakPosition)
            .fill(Color.red) // Use the specific red color
            .frame(width: width, height: 15) // Adjust height as needed
    }
}

// Custom Shape for the girder
struct GirderShape: Shape {
    let isBroken: Bool
    let breakPosition: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let segmentWidth: CGFloat = 8 // Width of each 'pixel' segment
        let _: CGFloat = rect.height * 0.4 // Height of the triangles
        let numSegments = Int(rect.width / segmentWidth)

        // Draw top line
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))

        let breakStartSegment = Int(CGFloat(numSegments) * breakPosition) - 1
        let breakEndSegment = breakStartSegment + 2 // Approx break width

        // Draw jagged bottom edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.6)) // Start of bottom flat part

        for i in (0..<numSegments).reversed() {
            let xStart = CGFloat(i) * segmentWidth
            let xMid = xStart + segmentWidth / 2
            let xEnd = xStart + segmentWidth

            if isBroken && i >= breakStartSegment && i < breakEndSegment {
                 // Skip drawing the bottom part for broken section
                 path.addLine(to: CGPoint(x: xStart, y: rect.height * 0.6))
            } else {
                 // Draw triangle segment
                 path.addLine(to: CGPoint(x: xEnd, y: rect.height * 0.6))
                 path.addLine(to: CGPoint(x: xMid, y: rect.height)) // Point down
                 path.addLine(to: CGPoint(x: xStart, y: rect.height * 0.6))
            }
        }

        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.6)) // Connect back to start flat part

        path.closeSubpath()
        return path
    }
}

// Represents a ladder segment
struct LadderView: View {
    let height: CGFloat
    var isBroken: Bool = false

    var body: some View {
        HStack(spacing: 5) { // Space between the two side rails
            LadderRail(height: height)
            LadderRail(height: height, isBroken: isBroken)
        }
    }
}

struct LadderRail: View {
     let height: CGFloat
     var isBroken: Bool = false // Optional: make one side appear broken

     var body: some View {
         VStack(spacing: 5) {
             if isBroken {
                  Rectangle()
                       .fill(Color.white.opacity(0.8))
                       .frame(width: 5, height: height * 0.4) // Broken top part
                 Spacer() // Gap
                  Rectangle()
                       .fill(Color.white)
                       .frame(width: 5, height: height * 0.4) // Bottom part
             } else {
                  Rectangle()
                       .fill(Color.white)
                       .frame(width: 5, height: height)
             }
         }
         .frame(height: height)
     }
 }

// Placeholder for characters/items
struct CharacterPlaceholder: View {
    let label: String
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
            Text(label)
                .foregroundColor(.white)
                .font(.custom("PixelEmulator", size: size * 0.5)) // Adjust font size relative to circle
        }
    }
}

// Font Setup (Requires adding a pixel font file to your project)
// Example: Download a free pixel font like "Press Start 2P" or "Pixel Emulator"
// 1. Add the .ttf or .otf file to your Xcode project.
// 2. Ensure it's added to the "Copy Bundle Resources" build phase.
// 3. Add the font name to your Info.plist under "Fonts provided by application".
// 4. Use with `.font(.custom("FontNameExact", size: 18))`

// Preview Provider
struct DonkeyKongView_Previews: PreviewProvider {
    static var previews: some View {
        DonkeyKongView()
            .previewLayout(.fixed(width: 375, height: 667)) // Approximate phone screen size
    }
}
