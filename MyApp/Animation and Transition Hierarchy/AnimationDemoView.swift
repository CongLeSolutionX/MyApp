//
//  AnimationDemoView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI

// MARK: - Main Content View

struct AnimationDemoView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Easing Animations") {
                    NavigationLink("Easing Demo", destination: EasingAnimationDemo())
                }
                Section("Spring Animations") {
                    NavigationLink("Spring Demo", destination: SpringAnimationDemo())
                    NavigationLink("iOS 17 Spring Demo", destination: iOS17SpringAnimationDemo()) // Requires iOS 17+
                }
                Section("Timing Curve") {
                     NavigationLink("Timing Curve Demo", destination: TimingCurveDemo())
                }
               Section("Animation Modifiers") {
                    NavigationLink("Delay Demo", destination: DelayDemo())
                    NavigationLink("Speed Demo", destination: SpeedDemo())
                    NavigationLink("Repeat Demo", destination: RepeatDemo())
                }
                 Section("Triggering Animations") {
                    NavigationLink("withAnimation Demo", destination: WithAnimationDemo())
                    NavigationLink(".animation Modifier Demo", destination: AnimationWithValueDemo())
                    NavigationLink("Binding Animation Demo", destination: BindingAnimationDemo())
                }
                 Section("Custom Animations (iOS 17+)") {
                    NavigationLink("Custom Animation Demo", destination: CustomAnimationDemo()) // Requires iOS 17+
                }
            }
            .navigationTitle("Animation Demos")
        }
    }
}

// MARK: - Helper Views

struct AnimatedSquare: View {
    let color: Color
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 50, height: 50)
    }
}

// MARK: - Easing Animations Demo

struct EasingAnimationDemo: View {
    @State private var move = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Tap button to animate").font(.headline)

            VStack(alignment: .leading) {
                Text(".default / .spring (iOS 17+ default)")
                AnimatedSquare(color: .blue)
                    .offset(x: move ? 150 : -150)
                    .animation(.default, value: move)

                Text(".linear(duration: 1)")
                AnimatedSquare(color: .green)
                    .offset(x: move ? 150 : -150)
                    .animation(.linear(duration: 1), value: move)

                Text(".easeIn(duration: 1)")
                AnimatedSquare(color: .orange)
                    .offset(x: move ? 150 : -150)
                    .animation(.easeIn(duration: 1), value: move)

                Text(".easeOut(duration: 1)")
                AnimatedSquare(color: .purple)
                    .offset(x: move ? 150 : -150)
                    .animation(.easeOut(duration: 1), value: move)

                Text(".easeInOut(duration: 1)")
                AnimatedSquare(color: .red)
                    .offset(x: move ? 150 : -150)
                    .animation(.easeInOut(duration: 1), value: move)
            }

            Button("Animate Easing Variations") {
                // No need for withAnimation here due to .animation modifier
                 move.toggle()
            }
            .padding(.top)
        }
        .navigationTitle("Easing Animations")
    }
}

// MARK: - Spring Animations Demo

struct SpringAnimationDemo: View {
    @State private var scale: CGFloat = 1.0
    @State private var response: Double = 0.55 // Default spring response
    @State private var damping: Double = 0.825 // Default spring dampingFraction
    @State private var blend: Double = 0.0 // Default spring blendDuration

    var body: some View {
        VStack(spacing: 20) {
            Text("Spring parameters affect bounce and duration.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            AnimatedSquare(color: .cyan)
                .scaleEffect(scale)
                 // Using .spring with parameters directly
                .animation(.spring(response: response,
                                    dampingFraction: damping,
                                    blendDuration: blend),
                           value: scale)

            VStack {
                 Text("Response: \(response, specifier: "%.2f") (Lower is faster/stiffer)")
                 Slider(value: $response, in: 0.1...1.0)
                 Text("Damping Fraction: \(damping, specifier: "%.2f") (Lower is bouncier)")
                 Slider(value: $damping, in: 0.1...1.0)
                Text("Blend Duration: \(blend, specifier: "%.2f") (Smooths transitions)")
                Slider(value: $blend, in: 0.0...1.0)
            }
            .padding()

             Text(".interactiveSpring()")
            AnimatedSquare(color: .yellow)
                .scaleEffect(scale)
                .animation(.interactiveSpring, value: scale) // Common for UI interactions

            Button("Animate Spring") {
                // No withAnimation needed
                scale = (scale == 1.0) ? 1.5 : 1.0
            }
            .padding(.top)
        }
        .navigationTitle("Spring Animations")
    }
}

// MARK: - iOS 17 Named Spring Animations Demo

struct iOS17SpringAnimationDemo: View {
    @State private var moveSmooth = false
    @State private var moveSnappy = false
    @State private var moveBouncy = false

    var body: some View {
        VStack(spacing: 30) {
           Text("`.smooth`").font(.caption)
            AnimatedSquare(color: .indigo)
                .offset(x: moveSmooth ? 100 : -100)
                .animation(.smooth, value: moveSmooth)

            Text("`.snappy`").font(.caption)
            AnimatedSquare(color: .teal)
                .offset(x: moveSnappy ? 100 : -100)
                .animation(.snappy(duration: 0.4, extraBounce: 0.1), value: moveSnappy)

            Text("`.bouncy`").font(.caption)
             AnimatedSquare(color: .pink)
                .offset(x: moveBouncy ? 100 : -100)
                .animation(.bouncy, value: moveBouncy)

            Button("Animate Named Springs") {
                 moveSmooth.toggle()
                 moveSnappy.toggle()
                 moveBouncy.toggle()
            }
            .padding(.top)
        }
        .navigationTitle("iOS 17+ Named Springs")
    }
}

// MARK: - Timing Curve Demo

struct TimingCurveDemo: View {
    @State private var scale: CGFloat = 1.0

    // Fast start, slow middle, fast end
    let fastSlowFast = Animation.timingCurve(0.1, 0.9, 0.9, 0.1, duration: 1.5)
    // Slow start, fast middle, slow end (similar to easeInOut but custom)
    let slowFastSlow = Animation.timingCurve(0.6, 0, 0.4, 1, duration: 1.5)

    var body: some View {
        VStack(spacing: 30) {
            Text("Tap button to animate").font(.headline)

            VStack(alignment: .leading) {
                Text("Fast-Slow-Fast Curve")
                 AnimatedSquare(color: .orange)
                    .scaleEffect(scale)
                    .animation(fastSlowFast, value: scale)

                Text("Slow-Fast-Slow Curve")
                 AnimatedSquare(color: .mint)
                    .scaleEffect(scale)
                    .animation(slowFastSlow, value: scale)
             }

            Button("Animate Timing Curves") {
                scale = (scale == 1.0) ? 1.5 : 1.0
            }
            .padding(.top)
        }
        .navigationTitle("Timing Curve")
    }
}

// MARK: - Delay Demo

struct DelayDemo: View {
    @State private var move1 = false
    @State private var move2 = false

    var body: some View {
        VStack(spacing: 30) {
            Text("One square starts 0.5s later").font(.headline)

            HStack {
                AnimatedSquare(color: .red)
                    .offset(y: move1 ? -100 : 100)
                    .animation(.easeInOut(duration: 1), value: move1) // No delay

                AnimatedSquare(color: .blue)
                    .offset(y: move2 ? -100 : 100)
                    .animation(.easeInOut(duration: 1).delay(0.5), value: move2) // 0.5s delay
            }

            Button("Animate with Delay") {
                move1.toggle()
                move2.toggle()
            }
        }
        .navigationTitle("Delay Modifier")
    }
}

// MARK: - Speed Demo

struct SpeedDemo: View {
    @State private var move1 = false
    @State private var move2 = false

    let baseAnimation = Animation.easeInOut(duration: 2.0) // Base duration 2s

    var body: some View {
        VStack(spacing: 30) {
            Text("Compare speeds (Normal vs 2x)").font(.headline)

            HStack {
                 VStack {
                    Text("Normal (2s)")
                    AnimatedSquare(color: .green)
                        .offset(y: move1 ? -100 : 100)
                        .animation(baseAnimation, value: move1) // Normal speed
                 }
                Spacer()
                VStack {
                    Text("Speed 2x (1s)")
                    AnimatedSquare(color: .purple)
                        .offset(y: move2 ? -100 : 100)
                        .animation(baseAnimation.speed(2.0), value: move2) // 2x speed (1s total)
                }
             }
            .padding(.horizontal, 50)

            Button("Animate Speeds") {
                move1.toggle()
                move2.toggle()
            }
        }
        .navigationTitle("Speed Modifier")
    }
}

// MARK: - Repeat Demo

struct RepeatDemo: View {
    @State private var rotate1 = false
    @State private var rotate2 = false
    @State private var rotate3 = false

    var body: some View {
        VStack(spacing: 40) {
            Text("Repeat Animations").font(.headline)

            VStack {
                Text("Repeat 3 times (autoreverses)")
                 AnimatedSquare(color: .orange)
                    .rotationEffect(rotate1 ? .degrees(90) : .degrees(0))
                     // Repeats 3 forward/backward cycles
                    .animation(.linear(duration: 0.5).repeatCount(3, autoreverses: true), value: rotate1)
            }

             VStack {
                 Text("Repeat Forever (no autoreverse)")
                AnimatedSquare(color: .cyan)
                    .rotationEffect(rotate2 ? .degrees(360) : .degrees(0))
                     // Spins continuously clockwise
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotate2)
            }

            VStack {
                Text("Repeat Forever (autoreverses)")
                AnimatedSquare(color: .pink)
                    .rotationEffect(rotate3 ? .degrees(90) : .degrees(-90))
                    // Swings back and forth continuously
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: rotate3)
            }

            Button("Trigger Repeats") {
                rotate1.toggle()
                // Toggle forever ones just once to start
                if !rotate2 { rotate2 = true }
                if !rotate3 { rotate3 = true }
            }
            .padding(.top)
        }
        .navigationTitle("Repeat Modifiers")
    }
}

// MARK: - withAnimation Demo

struct WithAnimationDemo: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 30) {
            Text("Tap button to trigger explicit animation").font(.headline)

            AnimatedSquare(color: .red)
                .scaleEffect(scale)
             // Note: No .animation modifier needed here

            Button("Animate withAnimation") {
                withAnimation(.spring()) { // Explicitly wrap state change
                    scale = (scale == 1.0) ? 1.5 : 1.0
                }
            }
        }
        .navigationTitle("withAnimation")
    }
}

// MARK: - Animation with Value Demo

struct AnimationWithValueDemo: View {
    @State private var offsetValue: CGFloat = 0

    var body: some View {
        VStack(spacing: 30) {
            Text("Animation tied to 'offsetValue' changes").font(.headline)

            AnimatedSquare(color: .blue)
                .offset(x: offsetValue)
                .animation(.easeInOut, value: offsetValue) // Animates ONLY when offsetValue changes

             Button("Change Offset") {
                 // No withAnimation needed here, .animation(:value:) handles it
                 offsetValue = (offsetValue == 0) ? 100 : 0
            }
        }
        .navigationTitle(".animation(:value:)")
    }
}

// MARK: - Binding Animation Demo

struct BindingAnimationDemo: View {
    @State private var isToggled = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Toggle animates its state change").font(.headline)

            // Apply animation directly to the binding
            Toggle("Animated Toggle", isOn: $isToggled.animation(.spring()))

            Text("Toggle State: \(isToggled ? "ON" : "OFF")")
                .padding()
                .background(isToggled ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                .cornerRadius(8)
                 // This animation applies to the background change,
                 // independent of the toggle's binding animation.
                .animation(.easeInOut, value: isToggled)

        }
        .padding()
        .navigationTitle("Binding Animation")
    }
}

// MARK: - Custom Animation Demo (iOS 17+)

// Define a simple custom animation (Example: A simple overshoot)
// Requires iOS 17+
struct OvershootAnimation: CustomAnimation {
    let duration: TimeInterval
    let overshoot: Double // e.g., 1.2 for 20% overshoot

    // Note: This is a simplified example and not a physically accurate overshoot spring
    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
        guard time >= 0 else { return value.scaled(by: 0) } // Start at zero value
        guard time < duration else { return nil } // Animation finished, return final value

        let progress = time / duration
        var scaleFactor: Double

        if progress < 0.7 {
            // Go past the target
            let overshootProgress = progress / 0.7
            scaleFactor = easeOutValue(overshootProgress) * overshoot
        } else {
             // Come back to the target
            let returnProgress = (progress - 0.7) / 0.3
            let currentOvershootValue = easeOutValue(1.0) * overshoot // Value at time 0.7
             let targetValue: Double = 1.0
            scaleFactor = currentOvershootValue + (targetValue - currentOvershootValue) * easeInValue(returnProgress)
        }

        return value.scaled(by: scaleFactor)
     }

    // Helper easing functions (simplified)
    private func easeOutValue(_ t: Double) -> Double {
        return sin(t * .pi / 2.0)
    }
     private func easeInValue(_ t: Double) -> Double {
         return 1.0 - cos(t * .pi / 2.0)
     }
}

// Extend Animation to make using the custom one easier
// Requires iOS 17+
extension Animation {
    static func overshoot(duration: TimeInterval = 0.6, amount: Double = 1.15) -> Animation {
         Animation(OvershootAnimation(duration: duration, overshoot: amount))
    }
}

// View using the custom animation
// Requires iOS 17+
struct CustomAnimationDemo: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 30) {
            Text("Tap to trigger custom 'Overshoot' animation").font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            AnimatedSquare(color: .purple)
                .scaleEffect(scale)
                .animation(.overshoot(), value: scale) // Use the custom animation

            Button("Animate Custom") {
                scale = (scale == 1.0) ? 1.5 : 1.0
            }
        }
        .navigationTitle("Custom Animation (iOS 17+)")
     }
}

// MARK: - Preview

struct AnimationDemoView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationDemoView()
    }
}
