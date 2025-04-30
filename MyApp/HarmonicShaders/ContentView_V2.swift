////
////  ContentView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/29/25.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    // MARK: - State Variables
//
//    // Animation parameters
//    @State private var speedMultiplier: Double = 1.0
//    @State private var amplitude: Float = 0.5 // Initial amplitude
//
//    // Animation time tracking
//    @State private var elapsedTime: Double = 0.0
//    private let updateInterval: Double = 0.016 // Approx 60 FPS
//
//    // State to track if the user is currently pressing the view
//    @State private var isInteracting: Bool = false
//
//    var body: some View {
//        // TimelineView drives the animation updates
//        TimelineView(.periodic(from: .now, by: updateInterval / speedMultiplier)) { context in
//            ZStack {
//                // 1. Invisible Background Layer for Shader & Gesture
//                Color.clear // Use Color.clear to fill space and catch gestures
//                    .ignoresSafeArea() // Cover the entire screen
//                    .background {
//                        // Apply the shader to the background
//                        Rectangle() // Base shape to draw the shader onto
//                            .ignoresSafeArea()
//                            .colorEffect(ShaderLibrary.default.harmonicColorEffect(
//                                .boundingRect, // Pass the view's bounding rectangle
//                                .float(6),     // waves count (constant)
//                                .float(elapsedTime), // animation clock time
//                                .float(amplitude),   // current amplitude
//                                .float(isInteracting ? 1.0 : 0.0) // mixCoeff based on interaction state
//                            ))
//                    }
//                    // Use DragGesture to detect press start and end precisely
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { _ in
//                                // This closure is called when the touch begins OR moves.
//                                // We only want to trigger the "press" animation once at the beginning.
//                                if !isInteracting {
//                                    isInteracting = true
//                                    // Animate TO the active state
//                                    withAnimation(.spring(duration: 0.3)) {
//                                        amplitude = 2.0
//                                        speedMultiplier = 2.0
//                                    }
//                                    // Optional: Trigger haptic feedback specifically on press *start*
//                                    // If you keep the .sensoryFeedback modifier below, this might be redundant.
//                                    // UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                                }
//                            }
//                            .onEnded { _ in
//                                // This closure is called when the touch ends (finger lifted).
//                                // Only trigger the "release" animation if we were interacting.
//                                if isInteracting {
//                                    isInteracting = false // Set state *before* animation for correct target values
//                                    // Animate BACK to the resting state
//                                    withAnimation(.spring(duration: 0.3)) {
//                                        amplitude = 0.5
//                                        speedMultiplier = 1.0
//                                    }
//                                }
//                            }
//                    )
//                     // Update elapsed time on each frame, driven by TimelineView
//                    .onChange(of: context.date) { _, _ in
//                         elapsedTime += updateInterval * speedMultiplier
//                     }
//                     // Add haptic feedback triggered by the *start* of interaction (change from false to true)
//                     // This ensures feedback happens once per press.
//                    .sensoryFeedback(.impact, trigger: isInteracting)
//
//
//                // 2. Your Actual UI Content (Example)
//                VStack {
//                    Spacer() // Push content down
//
//                    Text(isInteracting ? "Holding..." : "Hold Anywhere!")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundStyle(.white)
//                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
//                        .padding(.bottom, 50) // Add some padding from the bottom
//                        .animation(.easeInOut(duration: 0.1), value: isInteracting) // Smooth text change
//                    
//                    Image("My-meme-orange-microphone")
//                        .resizable()
//                        .frame(width: 280, height: 200)
//
//                }
//                .padding()
//                .allowsHitTesting(false) // Make UI content non-interactive so it doesn't block the background gesture
//
//            } // End ZStack
//        } // End TimelineView
//    } // End body
//}
//
//// MARK: - Preview
//
//#Preview {
//    ContentView()
//}
