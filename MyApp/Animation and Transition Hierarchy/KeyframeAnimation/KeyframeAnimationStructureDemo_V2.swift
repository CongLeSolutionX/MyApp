//
//  KeyframeAnimationStructureDemo_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//
import SwiftUI

// MARK: - Subview for Offset Animation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct OffsetAnimationView: View {
    @Binding var trigger: Bool // Bind to the trigger state in the parent

    var body: some View {
        VStack {
            Text("Single Property (Offset)").font(.headline)

            // Define the view content *first*
            Circle()
                .fill(.blue)
                .frame(width: 50, height: 50)
                .overlay(Text("X/Y").font(.caption).foregroundColor(.white))
                // THEN apply the keyframeAnimator modifier to it
                .keyframeAnimator(
                    initialValue: CGSize.zero, // Animate the offset (CGSize)
                    trigger: trigger           // Triggered by the parent's state
                ) { content, currentOffset in  // First trailing closure: Modifies the content
                    content
                        .offset(currentOffset) // Apply the animated offset
                } keyframes: { initialOffset in // Second trailing closure: Defines keyframes
                    KeyframeTrack(\.width) { // Animate width (x-offset)
                        LinearKeyframe(100, duration: 0.5)
                        CubicKeyframe(0, duration: 0.75, startVelocity: 50, endVelocity: -50)
                        SpringKeyframe(-50, duration: 0.4, spring: .bouncy)
                        MoveKeyframe(0)
                    }
                    KeyframeTrack(\.height) { // Animate height (y-offset)
                        CubicKeyframe(-50, duration: 0.6)
                        SpringKeyframe(50, spring: .snappy)
                        LinearKeyframe(0, duration: 0.3)
                    }
                } // End of keyframeAnimator modifier

            .frame(height: 120) // Provide visual space for y-offset animation
        }
        .padding()
        .border(Color.gray.opacity(0.5))
    }
}

// MARK: - Subview for Multi-Property Animation (Assumed Correct from previous response)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct MultiPropertyAnimationView: View {
     @Binding var trigger: Bool // Bind to the trigger state in the parent

     // Structure to hold animatable properties
     struct MultiProps: Animatable {
         var scale: Double = 1.0
         var rotation: Angle = .zero
         var xOffset: Double = 0.0

         var animatableData: AnimatablePair<Double, AnimatablePair<Angle.AnimatableData, Double>> {
             get { AnimatablePair(scale, AnimatablePair(rotation.animatableData, xOffset)) }
             set {
                 scale = newValue.first
                 rotation.animatableData = newValue.second.first
                 xOffset = newValue.second.second
             }
         }
     }

     var body: some View {
         VStack {
             Text("Multiple Properties").font(.headline)
             Rectangle() // The view content being animated
                 .fill(.purple)
                 .frame(width: 60, height: 60)
                 .overlay(Text("Multi").font(.caption).foregroundColor(.white))
                 // Apply the modifier TO the Rectangle
                 .keyframeAnimator(
                     initialValue: MultiProps(), // Animate our custom struct
                     trigger: trigger
                 ) { content, currentProps in // First trailing closure: Content modification
                     content
                         .scaleEffect(currentProps.scale)
                         .rotationEffect(currentProps.rotation)
                         .offset(x: currentProps.xOffset)
                 } keyframes: { initialProps in // Second trailing closure: Keyframe definition
                     KeyframeTrack(\.scale) {
                          SpringKeyframe(1.5, spring: .bouncy)
                          CubicKeyframe(0.8, duration: 0.6)
                          LinearKeyframe(1.0, duration: 0.4)
                     }
                     KeyframeTrack(\.rotation) {
                          LinearKeyframe(.degrees(90), duration: 0.5)
                          CubicKeyframe(.degrees(-45), duration: 0.8)
                          SpringKeyframe(.zero, spring: .smooth(duration: 0.5))
                     }
                     KeyframeTrack(\.xOffset) {
                         CubicKeyframe(50, duration: 0.7)
                         LinearKeyframe(-50, duration: 0.5)
                         SpringKeyframe(0, spring:.snappy)
                     }
                 }
             .frame(height: 100) // Provide space
         }
         .padding()
         .border(Color.gray.opacity(0.5))
     }
}

// MARK: - Subview for Repeating Animation (Assumed Correct from previous response)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct RepeatingRotationView: View {
     @Binding var showRepeatingAnimation: Bool // Bind to the repeating toggle state

     var body: some View {
         VStack {
             Text("Repeating Animation (Rotation)").font(.headline)
             Image(systemName: "arrow.triangle.2.circlepath") // The view content being animated
                  .font(.largeTitle)
                  .foregroundColor(.green)
                  // Apply the modifier TO the Image
                 .keyframeAnimator(
                     initialValue: Angle.zero,
                     repeating: showRepeatingAnimation // Controlled by the toggle
                 ) { content, currentAngle in // First trailing closure: Content modification
                     content
                         .rotationEffect(currentAngle)
                  } keyframes: { _ in // Second trailing closure: Keyframe definition
                     KeyframeTrack(\.self) {
                         CubicKeyframe(.degrees(90), duration: 1.0)
                         CubicKeyframe(.degrees(180), duration: 1.0)
                         CubicKeyframe(.degrees(270), duration: 1.0)
                         CubicKeyframe(.degrees(360), duration: 1.0)
                     }
                 }
             .frame(height: 80)
             Toggle("Repeat Animation", isOn: $showRepeatingAnimation.animation())
         }
         .padding()
         .border(Color.gray.opacity(0.5))
     }
}

// MARK: - Main Demo View (Using corrected subviews)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct KeyframeAnimationRefactoredView: View {
    // MARK: - State Variables
    @State private var triggerAnimation: Bool = false // Triggers the non-repeating animations
    @State private var showRepeatingAnimation: Bool = false // Toggles the repeating animation

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("Keyframe Animations Demo")
                    .font(.largeTitle)
                    .padding(.bottom)

                // Instantiate the subviews, passing bindings
                OffsetAnimationView(trigger: $triggerAnimation)
                MultiPropertyAnimationView(trigger: $triggerAnimation)
                RepeatingRotationView(showRepeatingAnimation: $showRepeatingAnimation)

                // --- Control Button ---
                Button("Trigger Non-Repeating Animations") {
                    // Toggle the state to trigger animations in subviews
                    triggerAnimation.toggle()
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

// MARK: - Preview
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    KeyframeAnimationRefactoredView()
}
