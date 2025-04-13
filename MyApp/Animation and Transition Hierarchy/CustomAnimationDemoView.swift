////
////  CustomAnimationDemoView.swift
////  MyApp
////
////  Created by Cong Le on 4/12/25.
////
//
//import SwiftUI
//import Combine // Needed for VectorArithmetic conformance on some types indirectly
//
//// MARK: - Environment Key for Pausing
//
///// Defines an environment key to control whether animations should be paused.
//private struct AnimationPausedKey: EnvironmentKey {
//    static let defaultValue: Bool = false
//}
//
//extension EnvironmentValues {
//    /// Exposes the 'animationPaused' value in the environment.
//    /// Views can read this value using @Environment(\.animationPaused).
//    /// Custom animations can read it via AnimationContext.environment.
//    var animationPaused: Bool {
//        get { self[AnimationPausedKey.self] }
//        set { self[AnimationPausedKey.self] = newValue }
//    }
//}
//
//// MARK: - Animation State for Pausable Animation
//
///// Defines the state needed for the PausableAnimation.
///// Conforms to AnimationStateKey to be stored within AnimationState.
//private struct PausableState<Value: VectorArithmetic>: AnimationStateKey {
//    // Stores the effective time elapsed *before* the current pause started,
//    // OR stores the *total pause duration delta* calculated when resuming.
//    var interruptionTimeOrTotalPauseDelta: TimeInterval = 0.0
//    // Tracks whether the animation was paused during the *last* frame update.
//    var wasPaused: Bool = false
//
//    // Default state when the animation begins.
//    static var defaultValue: Self { .init() }
//}
//
//extension AnimationContext {
//    /// Provides convenient access to the PausableState within the AnimationContext's state.
//    fileprivate var pausableState: PausableState<Value> {
//        get { state[PausableState<Value>.self] }
//        set { state[PausableState<Value>.self] = newValue }
//    }
//}
//
//// MARK: - Custom Pausable Animation
//
///// A custom animation that wraps a base animation and allows it to be paused
///// based on an environment value (`\.animationPaused`).
//struct PausableAnimation<Base: CustomAnimation>: CustomAnimation {
//    /// The underlying base animation that performs the actual animation curve.
//    let base: Base
//
//    /// Conformance to Hashable (required by CustomAnimation). Assumes Base is Hashable.
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(base)
//    }
//
//    /// Conformance to Equatable (required by Hashable). Assumes Base is Equatable.
//    static func == (lhs: PausableAnimation<Base>, rhs: PausableAnimation<Base>) -> Bool {
//        lhs.base == rhs.base
//    }
//
//    /// Calculates the value of the animation at a specific time, considering pauses.
//    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
//
//        // 1. Get the desired pause state from the environment.
//        let environmentIsPaused = context.environment.animationPaused
//
//        // 2. Get the animation's current internal state.
//        var currentState = context.pausableState
//
//        // 3. Detect changes in the pause state compared to the last frame.
//        if environmentIsPaused != currentState.wasPaused {
//            if environmentIsPaused {
//                // --- Just Paused ---
//                // Calculate effective time *so far* and store it.
//                // `time` = total real time elapsed.
//                // `currentState.interruptionTimeOrTotalPauseDelta` = time origin adjustment from *previous* pauses/resumes.
//                let effectiveElapsedTimeBeforePause = time - currentState.interruptionTimeOrTotalPauseDelta
//                currentState.interruptionTimeOrTotalPauseDelta = effectiveElapsedTimeBeforePause
//                currentState.wasPaused = true
//            } else {
//                // --- Just Resumed ---
//                // Calculate the new time origin adjustment.
//                // `time` = total real time elapsed.
//                // `currentState.interruptionTimeOrTotalPauseDelta` = effective time elapsed *before* this pause started.
//                let newTimeOriginAdjustment = time - currentState.interruptionTimeOrTotalPauseDelta
//                currentState.interruptionTimeOrTotalPauseDelta = newTimeOriginAdjustment
//                currentState.wasPaused = false
//            }
//            // Store the updated internal state back into the context.
//            context.pausableState = currentState
//        }
//
//        // 4. Calculate the effective time to pass to the base animation.
//        let effectiveTime: TimeInterval
//        if currentState.wasPaused {
//            // If currently paused, use the stored effective time from when pause began.
//            effectiveTime = currentState.interruptionTimeOrTotalPauseDelta
//        } else {
//            // If running, subtract the accumulated pause delta from the real time.
//            effectiveTime = time - currentState.interruptionTimeOrTotalPauseDelta
//        }
//
//        // 5. Call the base animation with the calculated effective time.
//        // Need to pass the context down so the base animation can manage its own state.
//        let result = base.animate(value: value, time: effectiveTime, context: &context)
//
//        // If the base animation finishes (returns nil), reset our internal state too.
//        if result == nil {
//            context.pausableState = .defaultValue
//        }
//
//        // 6. Return the result from the base animation.
//        return result
//    }
//
//    /// Calculates the velocity, delegating to the base animation using the effective time.
//    func velocity<V>(value: V, time: TimeInterval, context: AnimationContext<V>) -> V? where V : VectorArithmetic {
//         // Calculate effective time same way as in animate() but without mutating state
//        let environmentIsPaused = context.environment.animationPaused
//        let currentState = context.pausableState
//        let effectiveTime = environmentIsPaused ? currentState.interruptionTimeOrTotalPauseDelta : time - currentState.interruptionTimeOrTotalPauseDelta
//
//        return base.velocity(value: value, time: effectiveTime, context: context)
//    }
//
//    /// Determines if this animation should merge with a previous one, delegating to the base animation.
//    func shouldMerge<V>(previous: Animation, value: V, time: TimeInterval, context: inout AnimationContext<V>) -> Bool where V : VectorArithmetic {
//        guard let previousPausable = previous.base as? PausableAnimation<Base> else {
//            // Cannot merge if the previous animation isn't the same PausableAnimation type.
//             context.pausableState = .defaultValue // Reset state if not merging
//            return false
//        }
//
//        // Delegate merging decision to the base animation.
//        let didMerge = base.shouldMerge(previous: Animation(previousPausable.base), value: value, time: time, context: &context)
//
//        // If the base animation didn't merge, reset our state too.
//        if !didMerge {
//            context.pausableState = .defaultValue
//        }
//        
//        // We return whatever the base animation decided. If it merged,
//        // the context's state (including our pausableState) should now
//        // reflect the merged state potentially updated by the base's shouldMerge.
//        return didMerge
//    }
//}
//
//// MARK: - Animation Extension
//
//extension Animation {
//    /// Creates a pausable animation based on the provided base animation.
//    /// It uses the `.animationPaused` environment value to control pausing.
//    ///
//    /// - Parameter baseAnimation: The underlying animation curve (e.g., .linear, .spring).
//    /// - Returns: An Animation instance wrapping the PausableAnimation.
//    static func pausable<Base: CustomAnimation>(basedOn baseAnimation: Base) -> Animation {
//        Animation(PausableAnimation(base: baseAnimation))
//    }
//
//    /// Creates a pausable animation based on a standard Animation definition.
//    /// It uses the `.animationPaused` environment value to control pausing.
//    ///
//    /// - Parameter baseAnimation: The underlying animation curve (e.g., .linear, .spring).
//    /// - Returns: An Animation instance wrapping the PausableAnimation.
//    static func pausable(basedOn baseAnimation: Animation) -> Animation {
//         // Note: Accessing `baseAnimation.base` directly assumes `Animation` stores its CustomAnimation base.
//         // This is how SwiftUI seems to work internally, but isn't officially documented.
//         // A more robust (but complex) solution might involve custom logic to extract
//         // the parameters from standard Animations if needed, or only supporting
//         // CustomAnimation bases directly. We'll proceed with the direct access for simplicity.
//        Animation(PausableAnimation(base: baseAnimation.base))
//    }
//}
//
//// MARK: - Demo View
//
//struct CustomAnimationDemoView: View {
//    @State private var scale: CGFloat = 1.0
//    @State private var triggerAnimation: Bool = false // To restart repeating animation
//    @State private var isPaused: Bool = false
//
//    // Define the base animation we want to pause
//    let baseAnimation = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
//
//    var body: some View {
//        VStack(spacing: 40) {
//            Text("Custom Pausable Animation")
//                .font(.title)
//
//            Circle()
//                .fill(.blue)
//                .frame(width: 100, height: 100)
//                .scaleEffect(scale)
//                // Apply the pausable animation wrapper
//                .animation(.pausable(basedOn: baseAnimation), value: scale)
//                // Note: The `scale` value changing triggers the *start*, but
//                // the pause is controlled by the environment value below.
//                // Using triggerAnimation ensures we restart the animation sequence
//                // if needed after pausing/unpausing in some scenarios, though
//                // ideally the base animation handles merging correctly.
//
//            Toggle("Pause Animation", isOn: $isPaused)
//
//            Button("Restart Animation") {
//                // Toggle the scale slightly to ensure the animation modifier picks up a change
//                // and resets its internal timer if necessary after unpausing.
//                scale = (scale == 1.0) ? 1.01 : 1.0
//                triggerAnimation.toggle() // Explicitly trigger a re-evaluation if needed
//            }
//        }
//        .padding()
//        // Provide the pause state to the environment for the animation to read
//        .environment(\.animationPaused, isPaused)
//        .onAppear {
//            // Start the animation sequence when the view appears
//             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Small delay to ensure setup
//                 scale = 0.5 // Change value to kick off animation
//            }
//        }
//        // Use onChange to restart the animation value change when unpausing,
//        // ensuring it resumes smoothly rather than jumping.
//        .onChange(of: isPaused) { _, newValue in
//            if !newValue { // Just Resumed
//                 // Slightly change the value to ensure the animation system re-evaluates
//                 // with the updated pause state.
//                 let temporaryScale = scale
//                 scale = temporaryScale + 0.0001 // Minimal change
//                 DispatchQueue.main.async {
//                     scale = temporaryScale // Restore immediately
//                 }
//            }
//         }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    CustomAnimationDemoView()
//}
