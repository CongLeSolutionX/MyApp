////
////  HoverCardView.swift
////  MyApp
////
////  Created by Cong Le on 3/28/25.
////
//import SwiftUI
//
//// --- Data Model --- (Remains the same)
//struct CardInfo: Identifiable {
//    let id = UUID()
//    let title: String
//    let subtitle: String
//    let color: Color
//}
//
//// --- View for a Single Card ---
//struct CardView: View {
//    let card: CardInfo
//    // Shared state: ID of the card currently hovered over in the list.
//    @Binding var currentlyHoveredId: UUID?
//    // Local state: Is the pointer directly over *this* card?
//    @State private var isHoveringSelf = false
//
//    // --- Computed Properties for Effects ---
//    // Determines scale based on global and local hover state.
//    private var scaleValue: CGFloat {
//        if isHoveringSelf {
//            return 1.1 // Scale up when directly hovered
//        } else if currentlyHoveredId != nil {
//            // Scale down if *another* card is hovered (currentlyHoveredId is set, but not to self's ID)
//            return 0.9
//        } else {
//            return 1.0 // Default scale
//        }
//    }
//
//    // Determines blur based on global hover state.
//    private var blurValue: CGFloat {
//        // Blur if *another* card is hovered (and it's not this one).
//        // `currentlyHoveredId != nil` checks if *any* card is hovered.
//        // `!isHoveringSelf` ensures we don't blur the card being directly hovered.
//        if currentlyHoveredId != nil && !isHoveringSelf {
//             // You could also explicitly check `currentlyHoveredId != card.id`
//             // but `!isHoveringSelf` during a hover event achieves the same here.
//            return 10.0
//        } else {
//            return 0.0 // No blur otherwise
//        }
//    }
//
//    var body: some View {
//        VStack(spacing: 4) {
//            Text(card.title)
//                .font(.system(size: 20, weight: .bold))
//            Text(card.subtitle)
//                .font(.system(size: 14))
//        }
//        .foregroundColor(.white)
//        .frame(width: 250, height: 100)
//        .background(card.color)
//        .cornerRadius(10)
//        // **Apply Effects Directly**
//        .scaleEffect(scaleValue) // Apply scaling
//        .blur(radius: blurValue) // Apply blur
//        // **Crucial: Animation Modifier**
//        // This animation is triggered whenever `scaleValue` or `blurValue` changes.
//        // Since these values *depend* on `isHoveringSelf` AND `currentlyHoveredId`,
//        // changes in either state variable that affect the outcome will be animated.
//        // Using `currentlyHoveredId` as the explicit 'value' ensures the animation
//        // synchronizes across all cards when the shared hover state changes.
//        .animation(.easeInOut(duration: 0.4), value: currentlyHoveredId)
//        // Also animate changes driven purely by local hover (if needed, though
//        // the above usually covers it as currentlyHoveredId changes too).
//        // You could add: .animation(.easeInOut(duration: 0.4), value: isHoveringSelf)
//        // but often animating based on the shared state is sufficient and simpler.
//        .onHover { hovering in
//            // Update local state first
//            isHoveringSelf = hovering
//            // Update shared state
//            if hovering {
//                currentlyHoveredId = card.id
//            } else {
//                // Only clear the shared state if this card *was* the one being hovered.
//                // Prevents issues when moving mouse quickly between adjacent cards.
//                if currentlyHoveredId == card.id {
//                    currentlyHoveredId = nil
//                }
//            }
//        }
//    }
//}
//
//// --- Main Content View ---
//struct ContentView: View {
//    // Static card data (as before)
//    let cardData: [CardInfo] = [
//        CardInfo(title: "Important Tip", subtitle: "Remember this", color: Color(hex: "#f43f5e")), // Red
//        CardInfo(title: "Hover Me", subtitle: "Lorem Ipsum", color: Color(hex: "#3b82f6")),      // Blue
//        CardInfo(title: "Another Card", subtitle: "More details", color: Color(hex: "#22c55e"))   // Green
//    ]
//
//    // **The shared state variable that tracks the globally hovered card ID**
//    @State private var hoveredCardId: UUID? = nil
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
//            VStack(spacing: 15) {
//                ForEach(cardData) { card in
//                    // Pass the binding to the shared state down to each CardView
//                    CardView(card: card, currentlyHoveredId: $hoveredCardId)
//                    // **Note:** The animation modifier is now *inside* CardView,
//                    // which is generally cleaner as the view manages its own animations
//                    // based on the state it receives or owns.
//                }
//            }
//            // .padding() // Optional padding
//        }
//         // Ensure hover works reliably across the VStack area
//        .contentShape(Rectangle())
//        .onHover { hovering in
//            // If the mouse leaves the entire VStack area, clear the hover state.
//            if !hovering {
//                // Add a tiny delay to avoid clearing state when moving quickly
//                // between cards within the VStack.
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                    // Check if still hovering over a specific card *after* the delay.
//                    // If not (meaning the mouse truly left the VStack), clear the state.
//                    // This check might need refinement depending on exact behavior.
//                    // A simpler approach might be to just always clear, but this can
//                    // cause flickering if moving fast *between* cards.
//                    // For now, let's rely on the CardView's `onHover` logic primarily.
//                    // If issues persist, clearing state here when leaving the VStack
//                    // might be necessary, potentially without the delay.
//
//                    // Let's try the simpler approach first: when leaving the list, clear state
//                    // if hoveredCardId != nil { // Only clear if something *was* hovered
//                    //     hoveredCardId = nil
//                    // }
//                }
//            }
//        }
//    }
//}
//
//// --- Utility Extension --- (Remains the same)
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:(a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
//    }
//}
//
//#Preview {
//    ContentView()
//        .frame(minWidth: 400, minHeight: 450)
//}
////
////// --- App Entry Point --- (Remains the same)
////@main
////struct HoverCardApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////                .frame(minWidth: 400, minHeight: 450)
////        }
////    }
////}
