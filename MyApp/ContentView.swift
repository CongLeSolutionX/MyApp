////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
////
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//
//import SwiftUI
//
//// MARK: - Main Application Structure
//@main
//struct AnimationTransitionDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//
//// MARK: - Content View with Examples
//struct ContentView: View {
//    // MARK: State Variables for Demos
//    @State private var scaleEffectValue: CGFloat = 1.0
//    @State private var rotationAngle: Double = 0.0
//    @State private var showDetail: Bool = false
//    @State private var moveRight: Bool = false
//    @State private var counter: Int = 0
//    @State private var triggerKeyframes: Bool = false
//    @State private var keyframeOffset: CGFloat = 0
//    @State private var isRepeating: Bool = false
//    @State private var customAnimationProgress: Double = 0.0
//
//    // MARK: Body
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 30) {
//
//                    // --- 1. Basic Animation (`withAnimation`) ---
//                    SectionHeader(title: "1. Basic `withAnimation`")
//                    Circle()
//                        .fill(.blue)
//                        .frame(width: 50, height: 50)
//                        .scaleEffect(scaleEffectValue)
//                    Button("Toggle Scale (withAnimation)") {
//                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
//                            scaleEffectValue = (scaleEffectValue == 1.0) ? 1.5 : 1.0
//                        }
//                    }
//
//                    Divider()
//
//                    // --- 2. `.animation()` Modifier ---
//                    SectionHeader(title: "2. `.animation()` Modifier")
//                    Rectangle()
//                        .fill(.green)
//                        .frame(width: 100, height: 50)
//                        .rotationEffect(.degrees(rotationAngle))
//                        // Apply animation directly to the rotation effect when `rotationAngle` changes
//                        .animation(.easeInOut(duration: 1.0), value: rotationAngle)
//                    Button("Rotate (.animation)") {
//                         // No `withAnimation` needed here
//                        rotationAngle += 90
//                    }
//
//                     Divider()
//
//                    // --- 3. Animation Types & Modifiers ---
//                    SectionHeader(title: "3. Animation Types & Modifiers")
//                    VStack {
//                        // Linear Animation Example
//                        AnimatingShape(color: .orange, animation: .linear(duration: 1.5))
//                        // Repeating Animation Example
//                        AnimatingShape(color: .purple, animation: .easeInOut.repeatForever(autoreverses: true))
//                        // Delayed Animation Example
//                        AnimatingShape(color: .yellow, animation: .spring().delay(1.0))
//                         // Custom Speed
//                        AnimatingShape(color: .pink, animation: .easeInOut(duration: 2.0).speed(0.5))
//
//                    }
//
//                    Divider()
//
//                    // --- 4. Basic Transitions (`.transition()`) ---
//                    SectionHeader(title: "4. Basic Transitions")
//                    VStack {
//                        if showDetail {
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(.cyan)
//                                .frame(width: 150, height: 100)
//                                // `.opacity` fades in/out
//                                .transition(.opacity)
//                                // `.scale` grows/shrinks
//                                // .transition(.scale)
//                                // `.move` slides in/out from an edge
//                                // .transition(.move(edge: .leading))
//                        }
//                        Button("Toggle Detail View (Transition)") {
//                            withAnimation(.easeInOut(duration: 0.5)) {
//                                showDetail.toggle()
//                            }
//                        }
//                    }
//
//                    Divider()
//
//                    // --- 5. Asymmetric & Combined Transitions ---
//                    SectionHeader(title: "5. Asymmetric & Combined Transitions")
//                    VStack {
//                        if moveRight {
//                             Circle()
//                                .fill(.indigo)
//                                .frame(width: 50, height: 50)
//                                // Asymmetric: Different in/out transitions
//                                .transition(.asymmetric(insertion: .slide, removal: .opacity.combined(with: .scale(scale: 0.1))))
//                                // Combined: Multiple effects together
//                                // .transition(.move(edge: .trailing).combined(with: .opacity))
//                        }
//                        Button("Toggle Movement (Asymmetric/Combined)") {
//                            withAnimation(.bouncy) {
//                                moveRight.toggle()
//                            }
//                        }
//                    }
//
//
//                    Divider()
//
//                    // --- 6. Content Transitions (`.contentTransition()`) ---
//                     SectionHeader(title: "6. Content Transitions")
//                    Text("\(counter)")
//                        .font(.system(size: 40, weight: .bold, design: .rounded))
//                        .frame(width: 100, height: 50)
//                        .contentTransition(.numericText(countsDown: counter < Int.random(in: -5...5))) // Example of dynamic countsDown
//                        // .contentTransition(.interpolate) // Try this for non-numeric text
//                    Button("Increment Counter (Content)") {
//                        withAnimation(.smooth) {
//                            counter += 1
//                        }
//                     }
//
//                    Divider()
//
//                    // --- 7. Keyframe Animator ---
//                    // Diagram Reference: KeyframeAnimation section
//                    SectionHeader(title: "7. Keyframe Animator")
//                    HStack {
//                         Circle()
//                            .fill(.red)
//                            .frame(width: 30, height: 30)
//                            .offset(x: keyframeOffset)
//
//                         Spacer()
//
//                        KeyframeAnimator(initialValue: KeyframeValues(), trigger: triggerKeyframes) { value in
//                           Rectangle()
//                                .fill(.mint)
//                                .frame(width: 50, height: 50)
//                                .rotationEffect(value.angle)
//                                .scaleEffect(value.scale)
//                        } keyframes: { _ in // Start state doesn't matter for this example
//                            // Tracks animate properties of the KeyframeValues struct
//                             KeyframeTrack(\.angle) {
//                                 LinearKeyframe(.degrees(0), duration: 0.2)
//                                 CubicKeyframe(.degrees(90), duration: 0.5)
//                                 SpringKeyframe(.degrees(0), duration: 0.8, spring: .bouncy) // Target value, duration, spring type
//                             }
//                            KeyframeTrack(\.scale) {
//                                CubicKeyframe(1.0, duration: 0.2) // Start scale
//                                CubicKeyframe(1.5, duration: 0.5) // Scale up
//                                SpringKeyframe(1.0, spring: .snappy) // Scale back with spring
//                            }
//                             // Can also have keyframes that don't use tracks for simple values
////                             LinearKeyframe(CGFloat(0), duration: 0.2)
////                             CubicKeyframe(CGFloat(50), duration: 0.5)
////                             SpringKeyframe(CGFloat(0), spring: .bouncy)
//                        }
//
//                        Spacer()
//                    }
//                    Button("Trigger Keyframes") {
//                        triggerKeyframes.toggle()
//                    }
//
//                    Divider()
//
//                    // --- 8. Custom Animation ---
//                    // Diagram Reference: AnimationSystem -> CustomAnimation
//                    SectionHeader(title: "8. Custom Animation")
//                    Rectangle()
//                        .fill(Color.black)
//                        .frame(width: 100, height: 50)
//                        .modifier(ShakeEffect(progress: customAnimationProgress)) // Use a ViewModifier to apply
//                    Button("Trigger Custom Animation") {
//                         withAnimation(Animation(MyCustomSpringAnimation(duration: 1.0))) {
//                            customAnimationProgress = (customAnimationProgress == 0) ? 1 : 0
//                         }
//                     }
//
//
//                } // End Main VStack
//                .padding()
//            } // End ScrollView
//            .navigationTitle("Animations & Transitions")
//            .navigationBarTitleDisplayMode(.inline)
//        } // End NavigationView
//    }
//}
//
//// MARK: - Helper Views and Structs
//
//struct SectionHeader: View {
//    let title: String
//    var body: some View {
//        Text(title)
//            .font(.headline)
//            .padding(.bottom, 5)
//            .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
//// Helper for demoing different animation types
//struct AnimatingShape: View {
//    let color: Color
//    let animation: Animation
//    @State private var move = false
//
//    var body: some View {
//        Circle()
//            .fill(color)
//            .frame(width: 30, height: 30)
//            .offset(x: move ? 50 : -50)
//            .animation(animation, value: move)
//            .onAppear { move.toggle() } // Start animation on appear
//    }
//}
//
//// Example Values for Keyframe Animator
//struct KeyframeValues {
//    var angle: Angle = .zero
//    var scale: Double = 1.0
//}
//
//// --- Custom Animation Implementation ---
//// Diagram Reference: CustomAnimation Protocol, AnimationContext, AnimationState
//
//// 1. Define an optional State Key (if needed for complex state)
////    (Not strictly needed for this simple example, context directly usable)
//// private struct MyAnimationStateKey: AnimationStateKey {
////     typealias Value = Double // Example state type
////     static var defaultValue: Double = 0.0
//// }
//
//// 2. Define the Custom Animation struct
//struct MyCustomSpringAnimation: CustomAnimation {
//    let duration: TimeInterval
//
//    // Calculates the value based on time - simplified spring-like effect
//    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
//        if time > duration { return nil } // Signal animation completion
//
//        let p = time / duration // Progress (0 to 1)
//        // A simple custom curve - could be more complex (e.g., actual spring physics)
//        let customProgress = sin(p * .pi * 2 * 2) * exp(-p * 5) // Dampened sine wave like a spring
//
//        // We calculate the change needed and apply it based on the custom progress
//        let remaining = value // Target value is 'value' (assumes animating towards it from zero)
//        let currentMagnitude = remaining.magnitudeSquared * (1.0 - customProgress * customProgress) // simplified
//
//        // This is a rough approximation; proper spring physics would track velocity in context.
//        // We're scaling the *target* value based on the inverse of our custom progress curve's displacement.
//        // This isn't standard practice but demonstrates calculating a value.
//        // A real spring needs to consider velocity.
//        var result = value // Start with the target value
//        result.scale(by: 1.0 - abs(customProgress)) // Scale towards zero based on custom progress
//
//        // A proper implementation would often return 'value - remaining * customProgress'
//        // or something based on velocity and physics.
//        // Let's try a simpler scale effect based on progress directly:
//        var scaledResult = V.zero // Start from zero
//        scaledResult.scale(by: 1) // Needed for AnimatablePair, etc.
//        scaledResult = value // Target value
//        
//        // Simple wobble effect using sine wave: scale the difference from start(zero) to end(value)
//        let progressValue = 1.0 - cos(p * .pi / 2) // Ease out like curve
//        let wobble = sin(p * .pi * 4) * 0.1 * (1 - p) // Damped wobble
//        let finalProgress = progressValue + wobble
//
//        // Clamp finalProgress to avoid overshooting in this simple model
//        let clampedProgress = max(0.0, min(1.0, finalProgress))
//
//        // Interpolate from Zero to target 'value'
//        var interpolatedValue = V.zero
//        interpolatedValue.scale(by: 1.0 - clampedProgress) // Start point contribution
//        var targetContribution = value
//        targetContribution.scale(by: clampedProgress) // End point contribution
//        interpolatedValue += targetContribution
//
//        // Make sure magnitude doesn't exceed target (important for vectors)
//        if interpolatedValue.magnitudeSquared > value.magnitudeSquared && time > 0 {
//             return value // Clamp to target if overshooting (simple clamp)
//        }
//        
//        print("Custom Time: \(time), Custom Progress: \(customProgress)")
//
//        return interpolatedValue
//    }
//
//    // Optional: Implement velocity if needed for smooth transitions between animations
//    // func velocity<V>(...) -> V? { ... }
//
//    // Optional: Implement shouldMerge if this animation can smoothly take over
//    // from a previous instance of itself
//     func shouldMerge<V>(previous: Animation, value: V, time: TimeInterval, context: inout AnimationContext<V>) -> Bool where V : VectorArithmetic {
//         // Allow merging to preserve velocity if needed in a real scenario
//         return true // Simple merge for demonstration
//     }
//}
//
//// Helper ViewModifier to apply the custom animation's progress
//struct ShakeEffect: ViewModifier, Animatable {
//    var progress: Double // 0 = start, 1 = end
//
//     // Make the modifier animatable by using its progress property
//    var animatableData: Double {
//        get { progress }
//        set { progress = newValue }
//    }
//
//    func body(content: Content) -> some View {
//         // Apply effects based on the animatableData (progress)
//         // This example uses offset, but could be rotation, scale, etc.
//        content
//            .offset(x: sin(progress * .pi * 4) * 10) // Simple shake effect
//    }
//}
//
//// MARK: - Preview
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
