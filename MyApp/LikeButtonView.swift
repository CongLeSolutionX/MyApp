////
////  LikeButtonView.swift
////  MyApp
////
////  Created by Cong Le on 3/28/25.
////
//
//import SwiftUI
//
//// Represents the main view containing the like button
//struct ContentView: View {
//    var body: some View {
//        // Center the button on the screen with a dark background for contrast
//        ZStack {
//            Color.black.ignoresSafeArea() // Match the image background
//            LikeButtonView()
//        }
//    }
//}
//
//// The Like Button View implementation
//struct LikeButtonView: View {
//    // State variables to manage the button's appearance and animation
//    @State private var isLiked: Bool = false // Tracks if liked or not
//    @State private var isAnimating: Bool = false // Controls the heartbeat animation trigger
//    @State private var isPressed: Bool = false // Simulates press state for scaling effect
//
//    // Constants for styling, derived from CSS
//    private let buttonBackgroundColor = Color(red: 232/255, green: 232/255, blue: 232/255) // #e8e8e8
//    private let hoverBackgroundColor = Color(red: 238/255, green: 238/255, blue: 238/255) // #eee
//    private let baseBorderColor = Color(red: 255/255, green: 226/255, blue: 226/255) // #ffe2e2 - Initial border
//    private let heartColor = Color(red: 255/255, green: 110/255, blue: 110/255) // rgb(255, 110, 110)
//    private let borderWidth: CGFloat = 9
//    private let cornerRadius: CGFloat = 35
//    private let heartSize: CGFloat = 40 // Adjust size as needed
//
//    // Animation for the heartbeat effect
//    private var heartbeatAnimation: Animation {
//        Animation.interpolatingSpring(stiffness: 170, damping: 5) // A springy feel
//                 .repeatForever(autoreverses: false) // Loop the beat
//    }
//
//    // Animation for the button scale effect (bounce)
//    private var scaleAnimation: Animation {
//         // Mimic the cubic-bezier(.68,-0.55,.27,2.5) - bouncy effect
//        .interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 5)
//    }
//    
//    // Default ease-in-out animation for other transitions
//    private var defaultAnimation: Animation {
//        .easeInOut(duration: 0.4) // Match the 400ms from CSS
//    }
//
//    var body: some View {
//        // Using a Button for semantic correctness and accessibility
//        Button(action: {
//            // Toggle the liked state with animation
//            withAnimation(defaultAnimation) {
//                 isLiked.toggle()
//            }
//            // Trigger the heartbeat animation if liked
//            if isLiked {
//                 // Use a slight delay to start animation after the fill appears
//                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                     isAnimating = true
//                 }
//             } else {
//                 isAnimating = false
//             }
//        }) {
//            ZStack {
//                // Empty Heart (Outline)
//                Image(systemName: "heart")
//                    .font(.system(size: heartSize, weight: .regular)) // Adjust weight if needed
//                    .foregroundColor(heartColor)
//                    .opacity(isLiked ? 0 : 1) // Fade out when liked
//
//                // Filled Heart
//                Image(systemName: "heart.fill")
//                    .font(.system(size: heartSize, weight: .regular))
//                    .foregroundColor(heartColor)
//                    .opacity(isLiked ? 1 : 0) // Fade in when liked
//                    // Apply heartbeat scaling animation only when liked and animating
//                    .scaleEffect(isAnimating ? 1.15 : 1.0)
//                    .animation(isAnimating ? heartbeatAnimation : .default, value: isAnimating) // Attach repeating animation
//            }
//            .padding(EdgeInsets(top: 20, leading: 22, bottom: 20, trailing: 22)) // Match CSS padding
//            .background(isPressed ? hoverBackgroundColor : buttonBackgroundColor) // Change background on press
//            .cornerRadius(cornerRadius)
//            // Simulating inner shadow is tricky. Using outer shadow + stroke for approximation.
//             .overlay(
//                 RoundedRectangle(cornerRadius: cornerRadius)
//                    .stroke(baseBorderColor, lineWidth: borderWidth) // Border
//             )
//             // Inner shadow requires masking or layering differently.
//             // Let's use an outer shadow that mimics the top-biased inset feel somewhat.
//             .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: -2) // Approximation of inset shadow
//             .shadow(color: .white.opacity(0.4), radius: 2, x: 0, y: 2) // Optional bottom highlight for more depth
//        }
//         .scaleEffect(isPressed ? 1.05 : 1.0) // Scale up on press
//         .animation(scaleAnimation, value: isPressed) // Apply bouncy scale animation
//         .pressAction(onPress: { // Custom modifier to handle press state
//              withAnimation(scaleAnimation) {
//                 isPressed = true
//              }
//         }, onRelease: {
//             withAnimation(scaleAnimation) {
//                isPressed = false
//             }
//         })
//         .buttonStyle(PlainButtonStyle()) // Remove default button styling
//         .animation(defaultAnimation, value: isLiked) // Animate changes related to isLiked state (opacity, etc.)
//
//    }
//}
//
//// Helper extension for press and release actions (simulates hover/active)
//extension View {
//    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
//        self.gesture(
//            DragGesture(minimumDistance: 0)
//                .onChanged { _ in onPress() }
//                .onEnded { _ in onRelease() }
//        )
//    }
//}
//
//// Preview Provider for Xcode Canvas
//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//#endif
