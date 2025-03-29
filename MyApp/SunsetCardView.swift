//
//  SunsetCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI
//
//// --- Main Application Structure (for single file execution) ---
//@main
//struct SunsetApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

// --- Main Content View (Hosting the Card) ---
struct ContentView: View {
    var body: some View {
        ZStack {
            // Background similar to the image's context
            Color.black.opacity(0.9).ignoresSafeArea()

            // Center the Sunset Card
            SunsetCardView()
        }
    }
}

// --- The Sunset Card View ---
struct SunsetCardView: View {
    // Define approximate colors based on the image and CSS hints
    let titleColor = Color(hex: "#ff4d7d") ?? .pink
    let bodyColor = Color(hex: "#ff8d79") ?? .orange
    let gradientStart = Color(hex: "#ca1eb3") ?? .purple
    let gradientMid = Color(hex: "#FD2E24") ?? .red
    let gradientEnd = Color(hex: "#FFD701") ?? .yellow

    // Define the gradient for the border
    var borderGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: gradientStart, location: 0.0),
                .init(color: gradientMid, location: 0.3), // Adjust stops as needed
                .init(color: gradientEnd, location: 0.7)  // Match 70% from CSS
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            // 1. Gradient Background (will act as the border)
            borderGradient

            // 2. Content Area with Material Background (Blurred Overlay)
            // We add padding *here* to reveal the gradient background underneath
            VStack(spacing: 20) { // Increased spacing for visual separation
                Spacer() // Push content down slightly if needed

                Text("Savor the\nsunset")
                    .font(.system(size: 36, weight: .bold)) // Approximate font size
                    .foregroundColor(titleColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4) // Adjust line spacing if needed

                Text("Enjoy life's little beauties")
                    .font(.system(size: 18)) // Approximate font size
                    .foregroundColor(bodyColor)
                    .multilineTextAlignment(.center)

                // 3. Sunset Image
                // IMPORTANT: Replace "sunset_graphic" with the actual name
                // of the image asset you add to your project's Assets.xcassets
                Image("sunset_graphic") // <<-- Add your image asset here!
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity) // Allow image to take available width
                    // .padding(.horizontal, -20) // If image needs to bleed slightly like svg margin

                 Spacer() // Push content up slightly if needed
            }
            .padding(25) // Inner padding for content from the material edge
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Let VStack fill the space
            .background(.ultraThinMaterial) // Apply the frosted glass effect
            .padding(5) // This padding reveals the gradient background, creating the border

        }
        // Apply the frame size from the CSS
        .frame(width: 250, height: 320)
        // Clip to ensure the content stays within the rounded bounds if corners were rounded
        // .clipShape(RoundedRectangle(cornerRadius: 5)) // Optional: Add slight corner radius
    }
}

// --- Preview Provider ---
struct SunsetCardView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark) // Preview with dark mode
    }
}

// --- Helper Extension for Hex Colors ---
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let length = hexSanitized.count
        let r, g, b, a: Double
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 { // handles #RRGGBBAA
             r = Double((rgb & 0xFF000000) >> 24) / 255.0
             g = Double((rgb & 0x00FF0000) >> 16) / 255.0
             b = Double((rgb & 0x0000FF00) >> 8) / 255.0
             a = Double(rgb & 0x000000FF) / 255.0
        } else if length == 3 { // handles #RGB
             let rNibble = (rgb & 0xF00) >> 8
             let gNibble = (rgb & 0x0F0) >> 4
             let bNibble = rgb & 0x00F
             r = Double(rNibble * 16 + rNibble) / 255.0
             g = Double(gNibble * 16 + gNibble) / 255.0
             b = Double(bNibble * 16 + bNibble) / 255.0
             a = 1.0
        } else {
            return nil // Invalid format
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

// --- Local Storage Placeholder ---
/*
   Note on Local Storage:
   The current design is static. If you wanted to make the text or image dynamic
   and save user preferences or choices locally, you could use:

   1. @State (for temporary view state)
   2. @AppStorage (for saving simple values like text strings or booleans to UserDefaults)
   3. Core Data or SwiftData (for more complex, structured data persistence)
   4. Storing/Retrieving image data from the file system (if the image itself was user-changeable)

   Example using @AppStorage for the title (if it were editable):

   struct SunsetCardView: View {
       @AppStorage("sunsetCardTitle") var cardTitle: String = "Savor the\nsunset"
       // ... rest of the view ...
       Text(cardTitle) // Use the AppStorage variable
           // ... modifiers ...
   }

   For this specific static design, local storage isn't directly applicable yet.
*/
