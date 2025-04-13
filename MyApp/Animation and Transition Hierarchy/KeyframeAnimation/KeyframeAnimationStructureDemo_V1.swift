////
////  Keyframe Animation Structure.swift
////  MyApp
////
////  Created by Cong Le on 4/12/25.
////
//
//
//import SwiftUI
//
//// MARK: - Demo View Structure
//
///// A view demonstrating various keyframe animations.
//@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
//struct KeyframeAnimationStructureDemo: View {
//    // MARK: - State Variables
//    @State private var triggerAnimation: Bool = false // Triggers the main animation sequence
//    @State private var showRepeatingAnimation: Bool = false // Toggles the repeating animation example
//    @State private var rotationAngle: Angle = .zero // For repeating rotation
//
//    // Structure to hold animatable properties for multi-property demo
//    struct MultiProps: Animatable {
//        var scale: Double = 1.0
//        var rotation: Angle = .zero
//        var xOffset: Double = 0.0
//
//        // Conform to Animatable
//        var animatableData: AnimatablePair<Double, AnimatablePair<Angle.AnimatableData, Double>> {
//            get {
//                AnimatablePair(scale, AnimatablePair(rotation.animatableData, xOffset))
//            }
//            set {
//                scale = newValue.first
//                rotation.animatableData = newValue.second.first
//                xOffset = newValue.second.second
//            }
//        }
//    }
//    @State private var multiPropsValue = MultiProps() // State for multi-property demo
//
//    // MARK: - Body
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 40) {
//                Text("Keyframe Animations Demo")
//                    .font(.largeTitle)
//                    .padding(.bottom)
//
//                // --- Example 1: Single Property Animation (Offset) ---
//                VStack {
//                    Text("Single Property (Offset)").font(.headline)
//                    keyframeAnimator(
//                        initialValue: CGSize.zero, // Animate the offset (CGSize)
//                        trigger: triggerAnimation // Triggered by the button
//                    ) { content, currentOffset in
//                        // The view being animated
//                        content
//                            .offset(currentOffset) // Apply the animated offset
//                    } keyframes: { initialOffset in
//                        // Define the sequence of keyframes
//                        KeyframeTrack(\.width) { // Animate width (x-offset)
//                            LinearKeyframe(100, duration: 0.5) // Move right linearly
//                            CubicKeyframe(0, duration: 0.75, startVelocity: 50, endVelocity: -50) // Move back with cubic easing
//                            SpringKeyframe(-50, duration: 0.4, spring: .bouncy) // Overshoot left with a spring
//                            MoveKeyframe(0) // Instantly move back to center (implicitly takes remaining duration or minimum time)
//                        }
//                        KeyframeTrack(\.height) { // Animate height (y-offset) - simpler sequence
//                            CubicKeyframe(-50, duration: 0.6) // Move up
//                            SpringKeyframe(50, spring: .snappy) // Move down snappy
//                            LinearKeyframe(0, duration: 0.3)   // Move back to center y
//                        }
//                    } content: {
//                        // The content/view being animated
//                        Circle()
//                            .fill(.blue)
//                            .frame(width: 50, height: 50)
//                            .overlay(Text("X/Y").font(.caption).foregroundColor(.white))
//                    }
//                    .frame(height: 120) // Provide visual space for y-offset animation
//                }
//                .padding()
//                .border(Color.gray.opacity(0.5))
//
//                // --- Example 2: Multi-Property Animation (Scale, Rotation, Offset) ---
//                 VStack {
//                    Text("Multiple Properties").font(.headline)
//                    keyframeAnimator(
//                        initialValue: MultiProps(), // Animate our custom struct
//                        trigger: triggerAnimation
//                    ) { content, currentProps in
//                        // Apply multiple animated properties
//                        content
//                            .scaleEffect(currentProps.scale)
//                            .rotationEffect(currentProps.rotation)
//                            .offset(x: currentProps.xOffset)
//                    } keyframes: { initialProps in
//                        // Define tracks for each property
//                        KeyframeTrack(\.scale) {
//                             SpringKeyframe(1.5, spring: .bouncy) // Scale up bouncy
//                             CubicKeyframe(0.8, duration: 0.6)    // Scale down cubic
//                             LinearKeyframe(1.0, duration: 0.4)   // Scale back to normal linearly
//                        }
//                        KeyframeTrack(\.rotation) {
//                             LinearKeyframe(.degrees(90), duration: 0.5) // Rotate right linearly
//                             CubicKeyframe(.degrees(-45), duration: 0.8) // Rotate back past origin cubiclly
//                             SpringKeyframe(.zero, spring: .smooth(duration: 0.5)) // Rotate back to zero smoothly
//                        }
//                        KeyframeTrack(\.xOffset) {
//                            CubicKeyframe(50, duration: 0.7)      // Move right cubic
//                            LinearKeyframe(-50, duration: 0.5)    // Move left linear
//                            SpringKeyframe(0, spring:.snappy)     // Move back to center snappy
//                        }
//                    } content: {
//                        Rectangle()
//                            .fill(.purple)
//                            .frame(width: 60, height: 60)
//                            .overlay(Text("Multi").font(.caption).foregroundColor(.white))
//                    }
//                    .frame(height: 100) // Provide space
//                }
//                .padding()
//                .border(Color.gray.opacity(0.5))
//
//                // --- Example 3: Repeating Animation ---
//                VStack {
//                    Text("Repeating Animation (Rotation)").font(.headline)
//                    keyframeAnimator(
//                        initialValue: Angle.zero,
//                        repeating: showRepeatingAnimation // Controlled by the toggle
//                    ) { content, currentAngle in
//                        content
//                            .rotationEffect(currentAngle)
//                     } keyframes: { _ in // Initial value isn't strictly needed for repeating if starting from zero implicitly
//                        KeyframeTrack(\.self) { // Animate the Angle directly
//                            CubicKeyframe(.degrees(90), duration: 1.0)
//                            CubicKeyframe(.degrees(180), duration: 1.0)
//                            CubicKeyframe(.degrees(270), duration: 1.0)
//                            CubicKeyframe(.degrees(360), duration: 1.0) // End at 360 to seamlessly loop back to 0
//                        }
//                    } content: {
//                         Image(systemName: "arrow.triangle.2.circlepath")
//                             .font(.largeTitle)
//                             .foregroundColor(.green)
//                     }
//                    .frame(height: 80)
//                    Toggle("Repeat Animation", isOn: $showRepeatingAnimation.animation())
//                }
//                .padding()
//                .border(Color.gray.opacity(0.5))
//
//                // --- Control Button ---
//                Button("Trigger Animations") {
//                    // Toggle the state to trigger non-repeating animations
//                    triggerAnimation.toggle()
//                }
//                .padding(.top)
//                .buttonStyle(.borderedProminent)
//            }
//            .padding()
//        }
//    }
//}
//
//// MARK: - Preview
//
//@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
//#Preview {
//    KeyframeAnimationStructureDemoView()
//}
