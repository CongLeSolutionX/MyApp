//
//  CustomAnimationDemoView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI
import Combine // Needed for VectorArithmetic conformance on some types indirectly

// MARK: - Environment Key for Pausing

/// Defines an environment key to control whether animations should be paused.
private struct AnimationPausedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// Exposes the 'animationPaused' value in the environment.
    /// Views can read this value using @Environment(\.animationPaused).
    /// Custom animations can read it via AnimationContext.environment.
    var animationPaused: Bool {
        get { self[AnimationPausedKey.self] }
        set { self[AnimationPausedKey.self] = newValue }
    }
}

// MARK: - Animation State for Pausable Animation

/// Defines the state needed for the PausableAnimation.
/// Conforms to AnimationStateKey to be stored within AnimationState.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct PausableState<Value: VectorArithmetic>: AnimationStateKey {
    // Stores the effective time elapsed *before* the current pause started,
    // OR stores the *total pause duration delta* calculated when resuming.
    var interruptionTimeOrTotalPauseDelta: TimeInterval = 0.0
    // Tracks whether the animation was paused during the *last* frame update.
    var wasPaused: Bool = false

    // Default state when the animation begins.
    static var defaultValue: Self { .init() }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension AnimationContext {
    /// Provides convenient access to the PausableState within the AnimationContext's state.
    fileprivate var pausableState: PausableState<Value> {
        get { state[PausableState<Value>.self] }
        set { state[PausableState<Value>.self] = newValue }
    }
}

// MARK: - Custom Pausable Animation (Specific to wrapping standard Animation)

/// A custom animation that wraps a **standard** `Animation` struct and allows
/// it to be paused based on an environment value (`\.animationPaused`).
/// This specific version works because `Animation` itself conforms to `CustomAnimation` in iOS 17+.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct PausableStandardAnimation: CustomAnimation {
    /// The underlying base animation that performs the actual animation curve.
    let base: Animation // Store the standard Animation struct itself

    /// Conformance to Hashable (required by CustomAnimation).
    func hash(into hasher: inout Hasher) {
        hasher.combine(base)
    }

    /// Conformance to Equatable (required by Hashable).
    static func == (lhs: PausableStandardAnimation, rhs: PausableStandardAnimation) -> Bool {
        lhs.base == rhs.base
    }

    /// Calculates the value of the animation at a specific time, considering pauses.
    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {

        // 1. Get the desired pause state from the environment.
        let environmentIsPaused = context.environment.animationPaused

        // 2. Get the animation's current internal state.
        var currentState = context.pausableState

        // 3. Detect changes in the pause state compared to the last frame.
        if environmentIsPaused != currentState.wasPaused {
            if environmentIsPaused {
                // --- Just Paused ---
                let effectiveElapsedTimeBeforePause = time - currentState.interruptionTimeOrTotalPauseDelta
                currentState.interruptionTimeOrTotalPauseDelta = effectiveElapsedTimeBeforePause
                currentState.wasPaused = true
            } else {
                // --- Just Resumed ---
                let newTimeOriginAdjustment = time - currentState.interruptionTimeOrTotalPauseDelta
                currentState.interruptionTimeOrTotalPauseDelta = newTimeOriginAdjustment
                currentState.wasPaused = false
            }
            // Store the updated internal state back into the context.
            context.pausableState = currentState
        }

        // 4. Calculate the effective time to pass to the base animation.
        let effectiveTime: TimeInterval
        if currentState.wasPaused {
            effectiveTime = currentState.interruptionTimeOrTotalPauseDelta
        } else {
            effectiveTime = time - currentState.interruptionTimeOrTotalPauseDelta
        }

        // 5. Call the base animation's animate method directly (since Animation conforms).
        let result = base.animate(value: value, time: effectiveTime, context: &context)

        // Reset state if base animation finishes
        if result == nil {
             context.pausableState = .defaultValue // Reset our specific state
        }

        // 6. Return the result from the base animation.
        return result
    }

    /// Calculates the velocity, delegating to the base animation using the effective time.
    func velocity<V>(value: V, time: TimeInterval, context: AnimationContext<V>) -> V? where V : VectorArithmetic {
        let environmentIsPaused = context.environment.animationPaused
        let currentState = context.pausableState
        let effectiveTime = environmentIsPaused ? currentState.interruptionTimeOrTotalPauseDelta : time - currentState.interruptionTimeOrTotalPauseDelta

        // Delegate directly to the stored Animation struct
        return base.velocity(value: value, time: effectiveTime, context: context)
    }

    /// Determines if this animation should merge with a previous one, delegating to the base animation.
     func shouldMerge<V>(previous: Animation, value: V, time: TimeInterval, context: inout AnimationContext<V>) -> Bool where V : VectorArithmetic {
         // If the previous animation was also wrapped in our PausableStandardAnimation
         // we need to extract *its* base Animation to pass to our base Animation's merge check.
         let previousBaseAnimation: Animation
         if let previousPausable = previous.base as? PausableStandardAnimation {
             previousBaseAnimation = previousPausable.base
         } else {
             // If the previous wasn't our pausable wrapper, we use it directly.
             previousBaseAnimation = previous
         }

         // Delegate the merge decision to our stored base Animation, passing the appropriate
         // previous animation (extracted or direct).
         let didMerge = base.shouldMerge(previous: previousBaseAnimation, value: value, time: time, context: &context)

         // If the base animation decided *not* to merge, reset our pause-related state.
         // If it *did* merge, the context now contains the merged state from the base,
         // and we should *also* adopt the pause state from the context (which should have
         // been updated by the previous PausableStandardAnimation if applicable, although
         // this detail depends on precise SwiftUI internals of how context state is passed
         // during merging - assuming here the context is updated appropriately).
         // It's generally safer to reset state if not merging.
         if !didMerge {
              context.pausableState = .defaultValue
         }

         return didMerge
     }
}

// MARK: - Animation Extension

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension Animation {
    /// Creates a pausable animation based on a standard Animation definition.
    /// It uses the `.animationPaused` environment value to control pausing.
    ///
    /// - Parameter baseAnimation: The underlying animation curve (e.g., .linear, .spring).
    /// - Returns: An Animation instance wrapping the PausableAnimation.
    static func pausable(basedOn baseAnimation: Animation) -> Animation {
        // Use the specific PausableStandardAnimation struct which takes an Animation directly
        Animation(PausableStandardAnimation(base: baseAnimation))
    }

    // You might still want the generic overload if you have other CustomAnimation types
    // you want to make pausable, which are *not* standard Animation structs.
    /// Creates a pausable animation based on a custom animation type.
    static func pausable<Base: CustomAnimation>(basedOn baseAnimation: Base) -> Animation {
         // This version requires a new generic PausableAnimation<Base>,
         // different from PausableStandardAnimation. If only standard animations
         // need pausing, you might omit this.
         // Ensure PausableAnimation<Base> exists and implements the logic correctly.
         // For now, we will assume the main use case is pausing standard Animations
         // and comment this out unless a generic version `PausableAnimation<Base>` is also defined.
         // return Animation(PausableAnimation<Base>(base: baseAnimation)) // Requires generic PausableAnimation

         // If you only defined PausableStandardAnimation, you might return that,
         // though it's less type-safe as it assumes Base IS an Animation struct:
          if let concreteAnimation = baseAnimation as? Animation {
              return Animation(PausableStandardAnimation(base: concreteAnimation))
          } else {
              // Fallback or error handling needed if Base is not directly castable to Animation
              // Maybe just return the original if it can't be wrapped?
              print("Warning: Cannot create pausable wrapper for non-standard CustomAnimation type \(type(of: baseAnimation)) directly. Returning original.")
              return Animation(baseAnimation) // Or handle differently
          }
    }
}

// MARK: - Demo View (iOS 17+)

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct CustomAnimationDemoView: View {
    @State private var scale: CGFloat = 1.0
    @State private var isPaused: Bool = false

    // Define the base animation we want to pause
    let baseAnimation = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)

    var body: some View {
        VStack(spacing: 40) {
            Text("Custom Pausable Animation (iOS 17+)")
                .font(.title)

            Circle()
                .fill(.blue)
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                // Apply the pausable animation wrapper
                .animation(.pausable(basedOn: baseAnimation), value: scale)

            Toggle("Pause Animation", isOn: $isPaused)

            Button("Restart Animation") {
                 // Reset scale to trigger animation restart logic clearly
                 scale = 1.1 // Go to a definite start state
                 DispatchQueue.main.async {
                     withAnimation(.pausable(basedOn: baseAnimation)) {
                          scale = 0.5 // Animate to the target state
                     }
                 }
            }
        }
        .padding()
        // Provide the pause state to the environment for the animation to read
        .environment(\.animationPaused, isPaused)
        .onAppear {
            // Start the animation sequence when the view appears
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Ensure view is ready
                  withAnimation(.pausable(basedOn: baseAnimation)) {
                        scale = 0.5 // Change value to kick off animation
                  }
            }
        }
         // onChange might still be useful sometimes, but `shouldMerge` and the animation
         // modifier observing `value` should handle restarts/resumes more robustly now.
         // Leaving it out for cleaner demonstration unless specific issues arise.
    }
}

// MARK: - Preview

#Preview {
    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
        CustomAnimationDemoView()
    } else {
        Text("Requires iOS 17 / macOS 14 / tvOS 17 / watchOS 10 or later")
    }
}
