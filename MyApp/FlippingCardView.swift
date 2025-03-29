////
////  FlippingCardView.swift
////  MyApp
////
////  Created by Cong Le on 3/28/25.
////
//
//import SwiftUI
//
//// MARK: - Main Application Structure
//
////@main
////struct FlipCardApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
//
//// MARK: - Content View
//
//struct ContentView: View {
//    var body: some View {
//        ZStack {
//            // Background color to better see the card
//            Color.gray.opacity(0.2).ignoresSafeArea()
//
//            FlipCardView()
//        }
//    }
//}
//
//// MARK: - Flip Card View
//
//struct FlipCardView: View {
//    @State private var isFlipped = false
//
//    let cardWidth: CGFloat = 190
//    let cardHeight: CGFloat = 254
//    let animationDuration: Double = 0.8
//
//    var body: some View {
//        ZStack { // This ZStack acts like flip-card-inner
//            CardFront(width: cardWidth, height: cardHeight)
//                // Rotate the front view away when flipped
//                .rotation3DEffect(
//                    .degrees(isFlipped ? 180 : 0),
//                    axis: (x: 0.0, y: 1.0, z: 0.0)
//                )
//                // Explicitly hide when rotated away to prevent potential tap issues
//                .opacity(isFlipped ? 0 : 1)
//
//            CardBack(width: cardWidth, height: cardHeight)
//                // Start the back view rotated 180 degrees, then rotate it into view
//                .rotation3DEffect(
//                    .degrees(isFlipped ? 0 : -180), // Rotate from -180 to 0
//                    axis: (x: 0.0, y: 1.0, z: 0.0)
//                )
//                 // Explicitly hide when rotated away
//                .opacity(isFlipped ? 1 : 0)
//        }
//        .frame(width: cardWidth, height: cardHeight)
//        .onTapGesture {
//            withAnimation(.easeInOut(duration: animationDuration)) {
//                isFlipped.toggle()
//            }
//        }
//         // Apply perspective effect implicitly via rotation3DEffect
//         // Apply hover effect (if needed for macOS/iPadOS - tap is primary here)
//    }
//}
//
//// MARK: - Card Face Components
//
//// Helper struct for common card face styling
//struct CardFace<Content: View>: View {
//    let width: CGFloat
//    let height: CGFloat
//    let background: AnyView // Use AnyView to accept different gradient types
//    let cornerRadius: CGFloat = 16 // Approx 1rem
//    let borderColor: Color = .orange //.coral
//    let borderWidth: CGFloat = 1
//    let shadowColor: Color = .black.opacity(0.2)
//    let shadowRadius: CGFloat = 8
//    let shadowY: CGFloat = 4 // Match CSS shadow offset
//
//    @ViewBuilder let content: Content
//
//    var body: some View {
//        ZStack {
//            background
//                .cornerRadius(cornerRadius)
//
//            content
//        }
//        .frame(width: width, height: height)
//        .overlay(
//            RoundedRectangle(cornerRadius: cornerRadius)
//                .stroke(borderColor, lineWidth: borderWidth)
//        )
//        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
//    }
//}
//
//// Specific Front Card View
//struct CardFront: View {
//    let width: CGFloat
//    let height: CGFloat
//
//    // Approximate CSS Gradient:
//    // linear-gradient(120deg, bisque 60%, rgb(255, 231, 222) 88%,
//    // rgb(255, 211, 195) 40%, rgba(255, 127, 80, 0.603) 48%);
//    // Note: CSS gradient stops can overlap strangely. We'll simplify.
//    let frontGradient = LinearGradient(
//        gradient: Gradient(stops: [
//            // Approximate Bisque (FFE4C4) and Coral variations
//            .init(color: Color(red: 1.0, green: 0.89, blue: 0.80), location: 0.0), // Lighter bisque start
//            .init(color: Color(red: 1.0, green: 0.80, blue: 0.70), location: 0.6), // Darker bisque/light coral
//            .init(color: Color.orange.opacity(0.8), location: 0.9), // Coral towards end
//            .init(color: Color.orange.opacity(0.6), location: 1.0)   // More transparent coral end
//        ]),
//        startPoint: .topLeading, // Approximates 120deg
//        endPoint: .bottomTrailing
//    )
//
//    var body: some View {
//        CardFace(width: width, height: height, background: AnyView(frontGradient)) {
//            VStack(spacing: 8) {
//                Text("FLIP CARD")
//                    // Approximation of 1.5em and weight 900
//                    .font(.system(size: 28, weight: .heavy))
//                    .foregroundColor(.orange)
//
//                Text("Tap Me") // Changed from "Hover Me" for touch devices
//                    .font(.headline)
//                    .fontWeight(.medium)
//                    .foregroundColor(.orange.opacity(0.9))
//            }
//            .padding() // Add some padding inside the card face
//        }
//    }
//}
//
//// Specific Back Card View
//struct CardBack: View {
//    let width: CGFloat
//    let height: CGFloat
//
//    // Approximate CSS Gradient:
//    // linear-gradient(120deg, rgb(255, 174, 145) 30%, coral 88%,
//    // bisque 40%, rgb(255, 185, 160) 78%);
//     // Again, simplifying overlapping stops.
//     let backGradient = LinearGradient(
//        gradient: Gradient(stops: [
//            // Mix of Coral and Bisque-like colors
//            .init(color: Color(red: 1.0, green: 0.68, blue: 0.57), location: 0.0), // Light Coral Start
//            .init(color: Color.orange, location: 0.4), // Coral Middle
//            .init(color: Color(red: 1.0, green: 0.89, blue: 0.80).opacity(0.8), location: 0.7), // Bisque-like tone
//            .init(color: Color(red: 1.0, green: 0.72, blue: 0.63), location: 1.0) // Medium Coral End
//        ]),
//        startPoint: .topLeading, // Approximates 120deg
//        endPoint: .bottomTrailing
//    )
//
//    var body: some View {
//        CardFace(width: width, height: height, background: AnyView(backGradient)) {
//            VStack(spacing: 8) {
//                Text("BACK SIDE")
//                      .font(.system(size: 28, weight: .heavy))
//                      .foregroundColor(.white)
//
//                Text("Content Here")
//                    .font(.headline)
//                    .fontWeight(.medium)
//                    .foregroundColor(.white.opacity(0.9))
//            }
//            .padding()
//        }
//    }
//}
//
//// MARK: - Previews (Optional but Recommended)
//
//#Preview {
//    ContentView()
//}
