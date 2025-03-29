//
//  HoverCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// --- Data Model ---
// Represents the information needed for each card.
// Identifiable is needed for ForEach loops.
struct CardInfo: Identifiable {
    let id = UUID() // Unique identifier for each card
    let title: String
    let subtitle: String
    let color: Color
}

// --- View for a Single Card ---
// Encapsulates the appearance and hover logic for one card.
struct CardView: View {
    let card: CardInfo
    // Binding to the state variable in the parent view that tracks
    // the ID of the card currently being hovered over *anywhere* in the list.
    @Binding var currentlyHoveredId: UUID?
    
    // Local state to track if the mouse is directly over *this specific* card.
    @State private var isHoveringSelf = false
    
    var body: some View {
        // VStack arranges the text vertically inside the card.
        VStack(spacing: 4) { // Small spacing between title and subtitle
            Text(card.title)
            // Approximating '1em' bold font size
                .font(.system(size: 20, weight: .bold))
            Text(card.subtitle)
            // Approximating '0.7em' font size
                .font(.system(size: 14))
        }
        .foregroundColor(.white) // Set text color
        .frame(width: 250, height: 100) // Set fixed dimensions
        .background(card.color) // Set background color
        .cornerRadius(10) // Apply rounded corners
        .scaleEffect(scaleValue) // Apply dynamic scaling based on hover state
        .blur(radius: blurValue) // Apply dynamic blur based on hover state
        .onHover { hovering in
            // Update this card's local hover state
            isHoveringSelf = hovering
            
            // Update the parent view's shared state about which card ID is hovered.
            // If hovering starts on this card, set the shared ID to this card's ID.
            // If hovering stops *specifically on this card*, clear the shared ID *only if*
            // this card was the one being tracked. This prevents clearing when moving
            // quickly between adjacent cards.
            if hovering {
                currentlyHoveredId = card.id
            } else {
                if currentlyHoveredId == card.id {
                    currentlyHoveredId = nil
                }
            }
        }
    }
    
    // Computed property to determine the scale factor based on hover state.
    private var scaleValue: CGFloat {
        if isHoveringSelf {
            return 1.1 // Scale up if hovering directly over this card
        } else if currentlyHoveredId != nil {
            // If *another* card is being hovered (currentlyHoveredId is set, but not to self), scale down.
            return 0.9
        } else {
            return 1.0 // Default scale if no card is hovered
        }
    }
    
    // Computed property to determine the blur radius based on hover state.
    private var blurValue: CGFloat {
        // Blur this card if another card is being hovered (and it's not this one).
        if !isHoveringSelf && currentlyHoveredId != nil {
            return 10.0
        } else {
            return 0.0 // No blur otherwise
        }
    }
}

// --- Main Content View ---
// Holds the list of cards and the shared hover state.
struct ContentView: View {
    // Static data for the cards. This acts as "local storage for now".
    // Could be replaced with data loaded from UserDefaults, AppStorage, etc. later.
    let cardData: [CardInfo] = [
        CardInfo(title: "Important Tip", subtitle: "Remember this", color: Color(hex: "#f43f5e")), // Red
        CardInfo(title: "Hover Me", subtitle: "Lorem Ipsum", color: Color(hex: "#3b82f6")),      // Blue
        CardInfo(title: "Another Card", subtitle: "More details", color: Color(hex: "#22c55e"))   // Green
    ]
    
    // State variable shared across all CardViews via binding.
    // Tracks the ID of the card currently being hovered. Nil if no card is hovered.
    @State private var hoveredCardId: UUID? = nil
    
    var body: some View {
        // ZStack layers the content on top of a background color.
        ZStack {
            // Background color matching the image's dark theme.
            Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
            
            // VStack arranges the cards vertically with spacing.
            VStack(spacing: 15) { // Matches the 'gap: 15px'
                // Loop through the card data to create CardView instances.
                ForEach(cardData) { card in
                    CardView(card: card, currentlyHoveredId: $hoveredCardId)
                    // Apply animation smoothly when the hoveredCardId changes.
                    // The 'value' parameter ensures animation triggers only on changes to that specific state.
                    // This applies the 400ms transition from the CSS.
                        .animation(.easeInOut(duration: 0.4), value: hoveredCardId)
                }
            }
            // Optional: Add padding around the VStack if needed
            // .padding()
        }
    }
}

// --- Utility Extension ---
// Adds an initializer to Color to accept hex strings (like CSS).
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit) e.g., "FFF"
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit) e.g., "FFFFFF"
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit) e.g., "FFFFFFFF"
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: // Default to black if invalid hex
            (a, r, g, b) = (255, 0, 0, 0)
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

#Preview {
    ContentView()
    // Set a preferred initial window size for macOS if desired
    // This is not strictly necessary but helps for desktop testing.
//        .frame(minWidth: 400, minHeight: 450) // Adjusted minHeight to better fit content + padding
}

// --- App Entry Point ---
// Defines the main application structure.
//@main
//struct HoverCardApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                 // Set a preferred initial window size for macOS if desired
//                 // This is not strictly necessary but helps for desktop testing.
//                .frame(minWidth: 400, minHeight: 450) // Adjusted minHeight to better fit content + padding
//        }
//        // Optional: Style the window for macOS if needed
//        // .windowStyle(.hiddenTitleBar)
//    }
//}
