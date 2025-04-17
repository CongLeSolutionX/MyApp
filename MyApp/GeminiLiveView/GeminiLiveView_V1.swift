////
////  GeminiLiveView.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//
//struct GeminiLiveView: View {
//
//    // State variables (optional for interaction, not needed for pure UI)
//    // @State private var isHolding = false
//
//    private let buttonSize: CGFloat = 60 // Define button size
//
//    var body: some View {
//        ZStack {
//            // 1. Background Color
//            Color(red: 0.1, green: 0.1, blue: 0.12) // Dark background
//                .ignoresSafeArea()
//
//            // 2. Bottom Gradient Overlay
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color.blue.opacity(0.5),
//                    Color.purple.opacity(0.5)
//                ]),
//                startPoint: .leading,
//                endPoint: .trailing
//            )
//            .frame(height: 350) // Adjust height as needed
//            .blur(radius: 100) // Soften the gradient
//            .blendMode(.softLight) // Blend mode for subtle effect
//            .opacity(0.7)
//            .frame(maxHeight: .infinity, alignment: .bottom) // Push to bottom
//            .allowsHitTesting(false) // Allow taps to pass through
//            .ignoresSafeArea()
//
//            // 3. Main Content VStack
//            VStack {
//                // 4. "Live" Indicator
//                HStack(spacing: 4) {
//                    Image(systemName: "waveform.path.ecg")
//                    Text("Live")
//                }
//                .font(.headline)
//                .foregroundColor(.white.opacity(0.9))
//                .padding(.top, 10) // Adjust padding from status bar
//
//                Spacer()
//
//                // 5. Instruction Text
//                Text("To interrupt Gemini,\ntap or start talking")
//                    .font(.title3)
//                    .fontWeight(.medium)
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40) // Add horizontal padding
//
//                Spacer()
//                Spacer() // Add more space to push buttons further down
//
//                // 6. Bottom Controls HStack
//                HStack(spacing: 60) { // Adjust spacing between buttons
//                    Spacer() // Push buttons towards center if needed
//
//                    // Hold Button
//                    VStack(spacing: 8) {
//                        Button(action: {
//                            // Action for Hold button
//                            print("Hold button tapped")
//                        }) {
//                            ZStack {
//                                Circle()
//                                    .fill(.gray.opacity(0.4)) // Dark gray background
//                                    .frame(width: buttonSize, height: buttonSize)
//
//                                Image(systemName: "pause.fill")
//                                    .font(.title2)
//                                    .foregroundColor(.white)
//                            }
//                        }
//                        Text("Hold")
//                            .font(.caption)
//                            .foregroundColor(.white)
//                    }
//
//                    // End Button
//                    VStack(spacing: 8) {
//                        Button(action: {
//                            // Action for End button
//                            print("End button tapped")
//                        }) {
//                            ZStack {
//                                Circle()
//                                    .fill(.red) // Red background
//                                    .frame(width: buttonSize, height: buttonSize)
//
//                                Image(systemName: "xmark")
//                                    .font(Font.title2.weight(.semibold)) // Slightly bolder X
//                                    .foregroundColor(.white)
//                            }
//                        }
//                        Text("End")
//                            .font(.caption)
//                            .foregroundColor(.white)
//                    }
//
//                    Spacer() // Push buttons towards center if needed
//                }
//                .padding(.bottom, 50) // Add padding from the bottom edge
//            }
//            .padding(.horizontal) // Add overall horizontal padding
//        }
//        .statusBar(hidden: false) // Ensure status bar is visible
//    }
//}
//
//// Preview Provider
//struct GeminiLiveView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeminiLiveView()
//            .preferredColorScheme(.dark) // Preview in dark mode
//    }
//}
