////
////  HarmonicButton.swift
////  MyApp
////
////  Created by Cong Le on 4/29/25.
////
//
//import SwiftUI
//
//// MARK: - Harmonic Button View
//
//struct HarmonicButton: View {
//    var body: some View {
//        Button(
//            action: {
//                // Action to perform when the button is tapped
//                print("Harmonic Button Tapped!")
//            },
//            label: {
//                // You can add text or other views here if desired
//                // Example: Text("Submit").foregroundColor(.white).bold()
//                // Keeping it empty to match the article's visual focus
//            }
//        )
//        .frame(width: 240.0, height: 70.0) // As defined in the article
//        .buttonStyle(HarmonicStyle())
//    }
//}
//
//// MARK: - Harmonic Button Style
//
//struct HarmonicStyle: ButtonStyle {
//    // State variables to control animation parameters
//    @State private var scale: CGFloat = 1.0
//    @State private var speedMultiplier: Double = 1.0
//    @State private var amplitude: Float = 0.5 // Initial amplitude
//
//    // State for tracking animation time
//    @State private var elapsedTime: Double = 0.0
//    private let updateInterval: Double = 0.016 // Approx 60 FPS
//
//    func makeBody(configuration: Configuration) -> some View {
//        // TimelineView drives the animation updates
//        TimelineView(.periodic(from: .now, by: updateInterval / speedMultiplier)) { context in
//            configuration.label // The button's label content (currently empty)
//                .spatialWrap(Capsule(), lineWidth: 1.0) // Apply the border effect
//                .background {
//                    Rectangle() // Base shape for the effect
//                        .colorEffect(ShaderLibrary.default.harmonicColorEffect(
//                            .boundingRect, // Pass the view's bounding rectangle
//                            .float(6),     // waves count (constant)
//                            .float(elapsedTime), // animation clock time
//                            .float(amplitude),   // current amplitude
//                            .float(configuration.isPressed ? 1.0 : 0.0) // press coefficient (mixCoeff)
//                        ))
//                }
//                .clipShape(Capsule()) // Clip the effect to the button shape
//                .scaleEffect(scale)  // Apply scaling based on pressed state
//                .onChange(of: context.date) { _, _ in
//                    // Update elapsed time on each frame, adjusted by speedMultiplier
//                    elapsedTime += updateInterval * speedMultiplier
//                }
//        }
//        // Monitor the button's pressed state
//        .onChange(of: configuration.isPressed) { _, newValue in
//            // Animate changes to state variables when pressed state changes
//            withAnimation(.spring(duration: 0.3)) {
//                amplitude = newValue ? 2.0 : 0.5 // Change amplitude
//                speedMultiplier = newValue ? 2.0 : 1.0 // Change animation speed
//                scale = newValue ? 0.95 : 1.0      // Change scale
//            }
//        }
//        // Add haptic feedback on press
//        .sensoryFeedback(.impact, trigger: configuration.isPressed)
//    }
//}
//
//// MARK: - Spatial Wrap View Modifier
//
//extension View {
//    @ViewBuilder
//    func spatialWrap(
//        _ shape: some InsettableShape,
//        lineWidth: CGFloat
//    ) -> some View {
//        self
//            .background {
//                // Apply a stroke with a gradient for the spatial border effect
//                shape
//                    .strokeBorder(
//                        LinearGradient(
//                            gradient: Gradient(stops: [
//                                .init(color: .white.opacity(0.4), location: 0.0),
//                                .init(color: .white.opacity(0.0), location: 0.4),
//                                .init(color: .white.opacity(0.0), location: 0.6),
//                                .init(color: .white.opacity(0.1), location: 1.0),
//                            ]),
//                            startPoint: .init(x: 0.16, y: -0.4), // Gradient coordinates from article
//                            endPoint: .init(x: 0.2, y: 1.5)
//                        ),
//                        style: .init(lineWidth: lineWidth)
//                    )
//            }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    ContentView() // Or directly preview HarmonicButton
//}
//
//// MARK: - Example Usage (in ContentView or similar)
//
//struct ContentView: View {
//    var body: some View {
//        ZStack {
//            // Add a background to better see the button
//            Color.black.ignoresSafeArea()
//            HarmonicButton()
//        }
//    }
//}
