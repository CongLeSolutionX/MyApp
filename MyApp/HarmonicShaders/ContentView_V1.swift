////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
//
//import SwiftUI
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//struct ContentView: View {
//    // MARK: - State Variables (Moved from HarmonicStyle)
//
//    // State variables to control animation parameters
//    @State private var speedMultiplier: Double = 1.0
//    @State private var amplitude: Float = 0.5 // Initial amplitude
//
//    // State for tracking animation time
//    @State private var elapsedTime: Double = 0.0
//    private let updateInterval: Double = 0.016 // Approx 60 FPS
//
//    // State to track interaction (replaces isPressed)
//    @State private var isInteracting: Bool = false
//    // Store the task to reset interaction state to avoid overlaps
//    @State private var interactionResetTask: Task<Void, Never>? = nil
//
//    var body: some View {
//        // TimelineView now drives the ContentView's background updates
//        TimelineView(.periodic(from: .now, by: updateInterval / speedMultiplier)) { context in
//            ZStack {
//                // 1. Invisible Background Layer for Shader & Gesture
//                Color.clear // Use Color.clear to fill space and catch gestures
//                    .ignoresSafeArea() // Make it cover the entire screen
//                    .background {
//                        // Apply the shader to the background
//                        Rectangle() // Base shape to draw the shader onto
//                            .ignoresSafeArea()
//                            .colorEffect(ShaderLibrary.default.harmonicColorEffect(
//                                .boundingRect, // Pass the view's bounding rectangle
//                                .float(6),     // waves count (constant)
//                                .float(elapsedTime), // animation clock time
//                                .float(amplitude),   // current amplitude
//                                .float(isInteracting ? 1.0 : 0.0) // press coefficient (mixCoeff) based on interaction state
//                            ))
//                    }
//                    // Detect taps anywhere on the background
//                    .gesture(
//                        TapGesture().onEnded {
//                            handleInteraction()
//                        }
//                    )
//                    // Monitor the TimelineView's date changes to update time
//                    .onChange(of: context.date) { _, _ in
//                        elapsedTime += updateInterval * speedMultiplier
//                    }
//                    // Add haptic feedback triggered by interaction state
//                    .sensoryFeedback(.impact, trigger: isInteracting)
//
//                // 2. Your Actual UI Content (Example)
//                // This content appears *on top* of the animated background
//                VStack {
//                    Spacer() // Push content down
//
//                    Text("Tap Anywhere!")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundStyle(.white)
//                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
//                        .padding(.bottom, 50) // Add some padding from the bottom
//
//                    // You could add other controls or views here
//                }
//                .padding()
//
//            } // End ZStack
//        } // End TimelineView
//    } // End body
//
//    // MARK: - Interaction Handling
//
//    private func handleInteraction() {
//        // Cancel any pending reset task
//        interactionResetTask?.cancel()
//
//        // Set interacting state to true immediately
//        isInteracting = true
//
//        // Animate the change in parameters
//        withAnimation(.spring(duration: 0.3)) {
//            amplitude = 2.0
//            speedMultiplier = 2.0
//            // Note: 'scale' doesn't apply to the whole view background easily, so omitted here
//        }
//
//        // Launch a new task to reset the interaction state after a delay
//        interactionResetTask = Task {
//            do {
//                try await Task.sleep(for: .milliseconds(350)) // Keep interaction state slightly longer than animation
//                // Check if the task was cancelled before resetting
//                guard !Task.isCancelled else { return }
//
//                // Animate back to the resting state
//                withAnimation(.spring(duration: 0.3)) {
//                    isInteracting = false
//                    amplitude = 0.5
//                    speedMultiplier = 1.0
//                }
//            } catch {
//                // Handle cancellation if needed, otherwise just return
//                 if !(error is CancellationError) {
//                     print("Interaction reset sleep interrupted: \(error)")
//                 }
//                // Ensure state is reset even if sleep fails/is cancelled prematurely
//                 Task { @MainActor in // Ensure UI updates on main thread
//                     if isInteracting { // Only reset if still interacting
//                          withAnimation(.spring(duration: 0.3)) {
//                               isInteracting = false
//                               amplitude = 0.5
//                               speedMultiplier = 1.0
//                          }
//                     }
//                 }
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    ContentView()
//}
