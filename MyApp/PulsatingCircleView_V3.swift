//
//  V3.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI
import Combine

// MARK: - Supporting Enums (Unchanged)

enum ColorChangeMode {
    case timerBased(interval: Double)
    case perPulse
    case none
}

enum ShapeType {
    case circle
    case capsule
    case roundedRectangle(cornerRadius: CGFloat)
}

// MARK: - PulsatingView Implementation

struct PulsatingView<S: Shape>: View { // Keep the generic constraint

    // --- Configuration Parameters ---
    let shape: S                     // Use the concrete shape type S
    let baseSize: CGSize
    let minScale: CGFloat
    let maxScale: CGFloat
    let pulseDuration: Double
    let pulseAnimation: Animation
    let pulseAutoreverses: Bool
    let colors: [Color]
    let gradient: Gradient?
    let colorChangeMode: ColorChangeMode
    let colorAnimation: Animation
    let initialDelay: Double
    @Binding var isAnimating: Bool

    // --- Internal State ---
    @State private var currentScale: CGFloat
    @State private var currentColorIndex: Int = 0
    @State private var colorTimer: Timer? = nil
    @State private var initialSetupDone = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // --- Main Initializer (Keep this one) ---
    // Make this public or internal as needed
    init(
        shape: S, // Expect a concrete shape
        baseSize: CGSize = CGSize(width: 100, height: 100),
        minScale: CGFloat = 1.0,
        maxScale: CGFloat = 1.2,
        pulseDuration: Double = 1.5,
        pulseAnimation: Animation = .easeInOut,
        pulseAutoreverses: Bool = true,
        colors: [Color] = [.blue],
        gradient: Gradient? = nil,
        colorChangeMode: ColorChangeMode = .none,
        colorAnimation: Animation = .linear,
        initialDelay: Double = 0.0,
        isAnimating: Binding<Bool> = .constant(true)
    ) {
        self.shape = shape
        self.baseSize = baseSize
        self.minScale = minScale
        self.maxScale = maxScale
        self.pulseDuration = pulseDuration
        self.pulseAnimation = pulseAnimation
        self.pulseAutoreverses = pulseAutoreverses
        self.colors = gradient == nil && colors.isEmpty ? [.gray] : colors
        self.gradient = gradient
        self.colorChangeMode = colorChangeMode
        self.colorAnimation = colorAnimation
        self.initialDelay = initialDelay
        self._isAnimating = isAnimating
        _currentScale = State(initialValue: minScale)
    }

    // --- REMOVE the convenience initializer with 'shapeType' ---

    // --- Static Factory Methods (NEW) ---

    // Factory for Circle
    static func circle(
        baseSize: CGSize = CGSize(width: 100, height: 100),
        minScale: CGFloat = 1.0, maxScale: CGFloat = 1.2,
        pulseDuration: Double = 1.5, pulseAnimation: Animation = .easeInOut, pulseAutoreverses: Bool = true,
        colors: [Color] = [.blue], gradient: Gradient? = nil,
        colorChangeMode: ColorChangeMode = .none, colorAnimation: Animation = .linear,
        initialDelay: Double = 0.0, isAnimating: Binding<Bool> = .constant(true)
    ) -> PulsatingView<Circle> { // Return specific type
        PulsatingView<Circle>(
            shape: Circle(), // Provide concrete shape
            baseSize: baseSize, minScale: minScale, maxScale: maxScale,
            pulseDuration: pulseDuration, pulseAnimation: pulseAnimation, pulseAutoreverses: pulseAutoreverses,
            colors: colors, gradient: gradient, colorChangeMode: colorChangeMode, colorAnimation: colorAnimation,
            initialDelay: initialDelay, isAnimating: isAnimating
        )
    }

    // Factory for Capsule
    static func capsule(
        baseSize: CGSize = CGSize(width: 150, height: 80), // Default suited for capsule
        minScale: CGFloat = 1.0, maxScale: CGFloat = 1.2,
        pulseDuration: Double = 1.5, pulseAnimation: Animation = .easeInOut, pulseAutoreverses: Bool = true,
        colors: [Color] = [.blue], gradient: Gradient? = nil,
        colorChangeMode: ColorChangeMode = .none, colorAnimation: Animation = .linear,
        initialDelay: Double = 0.0, isAnimating: Binding<Bool> = .constant(true)
    ) -> PulsatingView<Capsule> { // Return specific type
        PulsatingView<Capsule>(
            shape: Capsule(), // Provide concrete shape
            baseSize: baseSize, minScale: minScale, maxScale: maxScale,
            pulseDuration: pulseDuration, pulseAnimation: pulseAnimation, pulseAutoreverses: pulseAutoreverses,
            colors: colors, gradient: gradient, colorChangeMode: colorChangeMode, colorAnimation: colorAnimation,
            initialDelay: initialDelay, isAnimating: isAnimating
        )
    }

    // Factory for RoundedRectangle
    static func roundedRectangle(
        cornerRadius: CGFloat,
        baseSize: CGSize = CGSize(width: 100, height: 100),
        minScale: CGFloat = 1.0, maxScale: CGFloat = 1.2,
        pulseDuration: Double = 1.5, pulseAnimation: Animation = .easeInOut, pulseAutoreverses: Bool = true,
        colors: [Color] = [.blue], gradient: Gradient? = nil,
        colorChangeMode: ColorChangeMode = .none, colorAnimation: Animation = .linear,
        initialDelay: Double = 0.0, isAnimating: Binding<Bool> = .constant(true)
    ) -> PulsatingView<RoundedRectangle> { // Return specific type
        PulsatingView<RoundedRectangle>(
            shape: RoundedRectangle(cornerRadius: cornerRadius), // Provide concrete shape
            baseSize: baseSize, minScale: minScale, maxScale: maxScale,
            pulseDuration: pulseDuration, pulseAnimation: pulseAnimation, pulseAutoreverses: pulseAutoreverses,
            colors: colors, gradient: gradient, colorChangeMode: colorChangeMode, colorAnimation: colorAnimation,
            initialDelay: initialDelay, isAnimating: isAnimating
        )
    }

    // --- Body (FIXED Fill Application) ---

    var body: some View {
        // Apply fill conditionally within the body
        Group { // Group allows applying common modifiers after conditional view structure
            if let gradient = gradient {
                shape
                    .fill(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            } else {
                shape
                    .fill(colors[min(currentColorIndex, colors.count - 1)])
            }
        }
        // Apply common modifiers outside the conditional Group
        .frame(width: baseSize.width, height: baseSize.height) // Base frame
        .scaleEffect(currentScale) // Apply animated scaling
        .animation(isAnimating && !reduceMotion ? pulseAnimation.repeatForever(autoreverses: pulseAutoreverses).delay(initialDelay) : .default.speed(0), value: currentScale)
        .animation(isAnimating && !reduceMotion ? colorAnimation : .default.speed(0), value: currentColorIndex) // Color animation tied to index change
        .onAppear {
            if !initialSetupDone {
                 currentScale = minScale
                 initialSetupDone = true
            }
            if isAnimating {
                startAnimations()
            }
        }
        .onDisappear {
            stopAnimations()
        }
        .onChange(of: isAnimating) { animating in
            // Use new value directly
            if animating {
                startAnimations()
            } else {
                stopAnimations()
            }
        }
        .onChange(of: reduceMotion) { reduced in
             // Use new value directly
             if reduced {
                 stopAnimations()
             } else if isAnimating {
                 startAnimations()
             }
        }
    }

    // --- REMOVE fillStyle() function as it's no longer used ---

    // --- Helper Functions (startAnimations, stopAnimations, etc. - Keep As Is) ---

    private func startAnimations() {
        guard !reduceMotion else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
             guard isAnimating else { return }
            currentScale = maxScale
        }
        stopColorTimer()
        scheduleColorTimer()
    }

    private func stopAnimations() {
        stopColorTimer()
        withAnimation(.default.speed(0)) {
            currentScale = minScale
        }
    }

    private func stopColorTimer() {
        colorTimer?.invalidate()
        colorTimer = nil
    }

    private func scheduleColorTimer() {
         guard isAnimating, !reduceMotion, gradient == nil, colors.count > 1 else { return }

        let interval: Double
        switch colorChangeMode {
            case .timerBased(let specificInterval):
                interval = max(0.1, specificInterval)
            case .perPulse:
                interval = max(0.1, pulseDuration)
            case .none:
                return
        }
         stopColorTimer() // Ensure cleanup

        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
            guard self.isAnimating else { return }
            self.colorTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                 if self.isAnimating {
                    self.updateColor()
                 } else {
                    self.stopColorTimer()
                 }
            }
        }
    }

    private func updateColor() {
        guard !colors.isEmpty else { return }
        currentColorIndex = (currentColorIndex + 1) % colors.count
    }
}

// MARK: - AnyShape Wrapper (Keep As Is - Not used by PulsatingView directly anymore)

// Although PulsatingView doesn't use this convenience init anymore,
// AnyShape can still be useful elsewhere, so keep it if needed.
// If not needed elsewhere, you can remove it.
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path

    init<S: Shape>(_ wrapped: S) {
        _path = { rect in
            wrapped.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        return _path(rect)
    }
}

// MARK: - Demo View (UPDATED TO USE EXPLICIT GENERIC TYPES FOR STATIC CALLS) ---

struct PulsatingViewDemo: View {
    @State private var isAnimatingFirst = true
    @State private var isAnimatingThird = true

    let rainbowGradient = Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .red])
    let fireGradient = Gradient(colors: [.orange, .red, .yellow])

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Pulsating Views Demo").font(.title)

                // --- Use Case 1: Basic Circle ---
                VStack {
                    Text("Basic Blue Circle").font(.headline)
                    // Explicitly specify <Circle> before calling .circle
                    PulsatingView<Circle>.circle(isAnimating: $isAnimatingFirst)
                    Toggle("Animate Basic", isOn: $isAnimatingFirst)
                        .padding(.horizontal)
                }
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(10)

                // --- Use Case 2: Fast Pulsating Capsule (Rainbow Colors) ---
                 VStack {
                     Text("Fast Capsule - Rainbow Colors").font(.headline)
                     // Explicitly specify <Capsule> before calling .capsule
                     PulsatingView<Capsule>.capsule(
                         minScale: 0.8,
                         maxScale: 1.1,
                         pulseDuration: 0.5, // Faster pulse
                         pulseAnimation: .spring(response: 0.3, dampingFraction: 0.4), // Springy
                         colors: [.red, .orange, .yellow, .green, .blue, .purple],
                         colorChangeMode: .perPulse, // Change color each pulse
                         colorAnimation: .easeInOut(duration: 0.5) // Smoother color transition
                     )
                 }
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(10)

                // --- Use Case 3: Gradient Rounded Rectangle (Slow, Controlled) ---
                 VStack {
                     Text("Gradient Round Rect (Slow, Controlled)").font(.headline)
                     // Explicitly specify <RoundedRectangle> before calling .roundedRectangle
                     PulsatingView<RoundedRectangle>.roundedRectangle(
                        cornerRadius: 25,
                        baseSize: CGSize(width: 120, height: 120),
                        minScale: 1.0,
                        maxScale: 1.3,
                        pulseDuration: 3.0, // Slower pulse
                        pulseAnimation: .easeInOut,
                        gradient: fireGradient, // Use gradient fill
                        colorChangeMode: .none, // Gradient doesn't change
                        initialDelay: 1.0, // Start after 1 second
                        isAnimating: $isAnimatingThird // Bind to state
                     )
                     Toggle("Animate Gradient Rect", isOn: $isAnimatingThird)
                        .padding(.horizontal)
                 }
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(10)

                // --- Use Case 4: Non-Reversing Pulse (Specific Timer Color Change) ---
                 VStack {
                    Text("Non-Reversing Pulse").font(.headline)
                    // Explicitly specify <Circle> before calling .circle
                    PulsatingView<Circle>.circle(
                        pulseDuration: 1.0,
                        pulseAutoreverses: false, // Only shrinks back instantly
                        colors: [.cyan, .purple, .yellow],
                        colorChangeMode: .timerBased(interval: 0.75), // Custom interval
                        colorAnimation: .spring()
                    )
                 }
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(10)

            }
            .padding()
        }
    }
}
// MARK: - Preview Provider (Unchanged) ---

struct PulsatingView_Previews: PreviewProvider {
    static var previews: some View {
        PulsatingViewDemo()
    }
}
