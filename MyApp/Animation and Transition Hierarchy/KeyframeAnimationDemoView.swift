//
//  KeyframeAnimationDemoView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI

// MARK: - Animatable Value Type

/// A simple struct holding animatable properties (e.g., position and scale)
/// to demonstrate KeyframeTrack.
struct AnimationProperties: Equatable, Animatable {
    var position: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero

    // Conformance to Animatable using AnimatablePair
    var animatableData: AnimatablePair<CGPoint.AnimatableData, AnimatablePair<CGFloat, Angle.AnimatableData>> {
        get {
            AnimatablePair(position.animatableData, AnimatablePair(scale, rotation.animatableData))
        }
        set {
            position.animatableData = newValue.first
            scale = newValue.second.first
            rotation.animatableData = newValue.second.second
        }
    }

    static func == (lhs: AnimationProperties, rhs: AnimationProperties) -> Bool {
        lhs.position == rhs.position && lhs.scale == rhs.scale && lhs.rotation == rhs.rotation
    }
}

// MARK: - Keyframe Animation Demonstration View

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct KeyframeAnimationDemoView: View {

    // --- State Variables ---
    @State private var triggerAnimation = false
    @State private var shapeProperties = AnimationProperties(position: CGPoint(x: 50, y: 50), scale: 1.0, rotation: .zero)
    @State private var linearValue: CGFloat = 0.0
    @State private var isRepeating = true // For the repeating animator

    // --- Body ---
    var body: some View {
        VStack(spacing: 30) {
            Text("Keyframe Animations Demo")
                .font(.title)

            // 1. Trigger-based Animator with KeyframeTrack (using AnimationProperties)
            triggerBasedAnimator

            Divider()

            // 2. Trigger-based LinearKeyframe Animator (animating CGFloat)
            linearAnimator

            Divider()

            // 3. Repeating Keyframe Animator (showing multiple tracks and keyframe types)
            repeatingAnimator

             Divider()

            // 4. Control Buttons
            controlButtons
        }
        .padding()
    }

    // --- Subviews for Demonstrations ---

    /// Demonstrates a trigger-based animation using KeyframeTrack for a struct.
    private var triggerBasedAnimator: some View {
        VStack {
            Text("Trigger-Based (Struct Properties)")
                .font(.headline)

            // The KeyframeAnimator View
            KeyframeAnimator(
                initialValue: AnimationProperties(position: CGPoint(x: 50, y: 50)), // Start position
                trigger: triggerAnimation // State variable to trigger animation
            ) { currentProperties in
                 // Content being animated
                 RoundedRectangle(cornerRadius: 10)
                    .fill(.blue)
                    .frame(width: 50, height: 50)
                    .scaleEffect(currentProperties.scale)
                    .rotationEffect(currentProperties.rotation)
                    .position(currentProperties.position) // Use position from animator

            } keyframes: { initialProperties in
                // Define Keyframes using KeyframeTrack for specific properties
                // Animate position using CubicKeyframes
                KeyframeTrack(\.position) {
                    CubicKeyframe(CGPoint(x: 150, y: 50), duration: 0.5) // Move right
                    CubicKeyframe(CGPoint(x: 150, y: 150), duration: 0.5) // Move down
                    CubicKeyframe(CGPoint(x: 50, y: 150), duration: 0.5) // Move left
                    CubicKeyframe(initialProperties.position, duration: 0.5) // Return to start
                }

                // Animate scale using SpringKeyframes
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.5, duration: 0.4, spring: .bouncy) // Scale up
                    SpringKeyframe(initialProperties.scale, duration: 0.4, spring: .smooth) // Scale down
                }
                
                // Animate rotation using LinearKeyframes
                KeyframeTrack(\.rotation) {
                    LinearKeyframe(.degrees(90), duration: 0.5)
                    LinearKeyframe(.degrees(0), duration: 0.5)
                    LinearKeyframe(.degrees(-90), duration: 0.5)
                     LinearKeyframe(initialProperties.rotation, duration: 0.5)
                }
            }
            .frame(height: 200) // Frame for the animator area
            .border(Color.gray, width: 1)
        }
    }

     /// Demonstrates LinearKeyframes animating a simple CGFloat.
    private var linearAnimator: some View {
        VStack {
             Text("Trigger-Based (Linear value)")
                 .font(.headline)

            KeyframeAnimator(
                initialValue: 0.0,
                trigger: triggerAnimation
            ) { value in
                // Content using the animated CGFloat
                 Capsule()
                     .fill(.green)
                     .frame(width: 100, height: 30)
                     .opacity(value) // Animate opacity linearly
                     .scaleEffect(1.0 + value * 0.5) // Scale linearly
            } keyframes: { _ in
                 // Define LinearKeyframes for the CGFloat
                 KeyframeTrack(\.self) { // \.self refers to the CGFloat itself
                     LinearKeyframe(1.0, duration: 1.0) // Fade in and scale up
                     LinearKeyframe(0.0, duration: 1.0) // Fade out and scale down
                 }
            }
             .frame(height: 50)
             .border(Color.gray, width: 1)
        }
    }

    /// Demonstrates a repeating animator using various keyframe types.
    private var repeatingAnimator: some View {
        VStack {
            Text("Repeating Animator (Mixed Keyframes)")
                .font(.headline)

            KeyframeAnimator(
                 initialValue: AnimationProperties(position: CGPoint(x: 100, y: 25)), // Use struct here too
                 repeating: isRepeating // Control repeating state
             ) { properties in
                 // Content being animated repeatedly
                 Image(systemName: "star.fill")
                     .foregroundStyle(.yellow)
                     .font(.system(size: 30))
                     .scaleEffect(properties.scale)
                     .rotationEffect(properties.rotation)
                     .position(properties.position)

             } keyframes: { initialProperties in
                 // Different track examples:
                 KeyframeTrack(\.position) {
                     // MoveKeyframe jumps instantly
                     MoveKeyframe(CGPoint(x: 50, y: 25))
                     // Cubic for smooth path
                     CubicKeyframe(CGPoint(x: 150, y: 75), duration: 1.0)
                     CubicKeyframe(initialProperties.position, duration: 1.0)
                 }
                 KeyframeTrack(\.scale) {
                    // Spring for bouncy effect
                     SpringKeyframe(1.5, duration: 0.8, spring: .snappy)
                     SpringKeyframe(initialProperties.scale, duration: 1.2, spring: .smooth)
                 }
                 KeyframeTrack(\.rotation) {
                    // Linear for constant speed rotation
                     LinearKeyframe(.degrees(180), duration: 1.0)
                     LinearKeyframe(initialProperties.rotation, duration: 1.0) // Rotate back
                 }
             }
             .frame(height: 100) // Frame for the animator area
             .border(Color.gray, width: 1)

             Toggle("Repeat Animation", isOn: $isRepeating.animation())
        }
    }

    /// Buttons to control the animations.
    private var controlButtons: some View {
        HStack {
            Button("Trigger Once") {
                // Add animation block to make the state change animated
                withAnimation {
                   triggerAnimation.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct KeyframeAnimationDemoView_Previews: PreviewProvider {
    static var previews: some View {
        KeyframeAnimationDemoView()
    }
}
