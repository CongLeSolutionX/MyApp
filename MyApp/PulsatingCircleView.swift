//
//  PulsatingCircleView.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI
import Combine // Needed for Timer

// MARK: - Supporting Enums

/// Defines how the color change animation behaves.
enum ColorChangeMode {
    /// Color changes based on a separate timer interval.
    case timerBased(interval: Double)
    /// Color changes approximately once per pulse cycle (uses pulseDuration).
    case perPulse
    /// No automatic color change.
    case none
}

/// Defines the shape to be used for pulsation.
enum ShapeType {
    case circle
    case capsule
    case roundedRectangle(cornerRadius: CGFloat)
    // Future: Could add custom Path support
}

// MARK: - PulsatingView Implementation

/// A view that pulsates in size and optionally cycles through colors or displays a gradient.
struct PulsatingView<S: Shape>: View {

    // --- Configuration Parameters ---

    /// The shape to be animated.
    let shape: S

    /// The base size of the view before scaling.
    let baseSize: CGSize

    /// The minimum scale factor during pulsation.
    let minScale: CGFloat

    /// The maximum scale factor during pulsation.
    let maxScale: CGFloat

    /// The duration of one full pulse cycle (e.g., scale out and back in).
    let pulseDuration: Double

    /// The animation curve for the pulse scaling effect.
    let pulseAnimation: Animation

    /// Whether the pulse animation reverses direction each cycle.
    let pulseAutoreverses: Bool

    /// An array of colors to cycle through for the fill, if `gradient` is nil.
    let colors: [Color]

    /// An optional gradient to use for the fill (overrides `colors`).
    let gradient: Gradient?

    /// How the color should change over time.
    let colorChangeMode: ColorChangeMode

    /// The animation curve for the color transition (when applicable).
    let colorAnimation: Animation

    /// An initial delay before the animation starts.
    let initialDelay: Double

    /// Allows external control to start/stop the animation.
    @Binding var isAnimating: Bool

    // --- Internal State ---

    @State private var currentScale: CGFloat
    @State private var currentColorIndex: Int = 0
    @State private var colorTimer: Timer? = nil
    @State private var initialSetupDone = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // --- Initializer ---

    /// Creates a new PulsatingView.
    ///
    /// - Parameters:
    ///   - shape: The shape instance to animate (e.g., Circle(), Capsule()).
    ///   - baseSize: The reference size before scaling. Defaults to 100x100.
    ///   - minScale: Minimum scale factor. Defaults to 1.0.
    ///   - maxScale: Maximum scale factor. Defaults to 1.2.
    ///   - pulseDuration: Duration of one pulse cycle. Defaults to 1.5 seconds.
    ///   - pulseAnimation: Animation curve for scaling. Defaults to .easeInOut.
    ///   - pulseAutoreverses: Whether scaling animation reverses. Defaults to true.
    ///   - colors: Colors to cycle if `gradient` is nil. Defaults to [.blue].
    ///   - gradient: Optional gradient fill. Defaults to nil.
    ///   - colorChangeMode: How color changes. Defaults to .none.
    ///   - colorAnimation: Animation curve for color changes. Defaults to .linear.
    ///   - initialDelay: Delay before starting animation. Defaults to 0.0.
    ///   - isAnimating: Binding to externally control animation state. Defaults to .constant(true).
    init(
        shape: S,
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
        // Ensure colors array is not empty if gradient is nil
        self.colors = gradient == nil && colors.isEmpty ? [.gray] : colors
        self.gradient = gradient
        self.colorChangeMode = colorChangeMode
        self.colorAnimation = colorAnimation
        self.initialDelay = initialDelay
        self._isAnimating = isAnimating

        // Initialize state based on parameters
        _currentScale = State(initialValue: minScale)
    }

    // Convenience Initializer for ShapeType enum
    init(
        shapeType: ShapeType = .circle,
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
    ) where S == AnyShape { // Use AnyShape for flexibility
        self.shape = AnyShape(Self.shape(for: shapeType)) // Wrap the concrete shape
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

     // Helper to get shape from enum
    private static func shape(for type: ShapeType) -> any Shape {
         switch type {
         case .circle:
             return Circle()
         case .capsule:
             return Capsule()
         case .roundedRectangle(let cornerRadius):
             return RoundedRectangle(cornerRadius: cornerRadius)
         }
     }

    // --- Body ---

    var body: some View {
        shape // Use the injected shape
            .fill(fillStyle()) // Dynamic fill based on gradient or colors
            .frame(width: baseSize.width, height: baseSize.height) // Base frame
            .scaleEffect(currentScale) // Apply animated scaling
            // Apply scaling animation implicitly based on currentScale changes
            .animation(isAnimating && !reduceMotion ? pulseAnimation.repeatForever(autoreverses: pulseAutoreverses).delay(initialDelay) : .default.speed(0), value: currentScale)
            // Apply color transition animation (only matters if colorIndex changes)
            .animation(isAnimating && !reduceMotion ? colorAnimation : .default.speed(0), value: currentColorIndex)
            .onAppear {
                // Initial setup only once
                if !initialSetupDone {
                     currentScale = minScale // Ensure starting scale
                     initialSetupDone = true
                }
                if isAnimating {
                    startAnimations()
                }
            }
            .onDisappear {
                stopAnimations()
            }
            .onChange(of: isAnimating) {
                if isAnimating {
                    startAnimations()
                } else {
                    stopAnimations()
                }
            }
            .onChange(of: reduceMotion) {
                 if reduceMotion {
                     stopAnimations() // Stop if reduce motion is enabled
                 } else if isAnimating {
                     startAnimations() // Start if previously stopped by reduce motion
                 }
            }
    }

    // --- Helper Functions ---

    /// Determines the appropriate fill style (gradient or solid color).
    @ViewBuilder
    private func fillStyle() -> some ShapeStyle {
        if let gradient = gradient {
            LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            // Ensure index is valid even if colors array is modified externally (unlikely with let)
            colors[min(currentColorIndex, colors.count - 1)]
        }
    }

    /// Starts the pulsation and color change animations.
    private func startAnimations() {
        guard !reduceMotion else { return } // Don't animate if reduce motion is on

        // Use DispatchQueue for delay, ensuring it runs only once via isAnimating logic or onAppear
        // Schedule scale animation kickoff
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
             guard isAnimating else { return } // Check again after delay
             // Trigger the scaling animation by changing the state variable
            currentScale = maxScale
        }

        // Stop any existing color timer before starting a new one
        stopColorTimer()

        // Schedule new color timer based on mode
        scheduleColorTimer()
    }

    /// Stops animations and resets state.
    private func stopAnimations() {
        stopColorTimer()
        // Reset scale without animation to avoid jump if restarted
        withAnimation(.default.speed(0)) { // Effectively disable animation for reset
            currentScale = minScale
            // Optional: Reset color index? Depends on desired behavior when stopped.
            // currentColorIndex = 0
        }
    }

    /// Invalidates and releases the color timer.
    private func stopColorTimer() {
        colorTimer?.invalidate()
        colorTimer = nil
    }

    /// Creates and schedules the timer responsible for color changes.
    private func scheduleColorTimer() {
         guard isAnimating, !reduceMotion, !(gradient != nil || colors.count <= 1) else { return } // No timer needed for gradients, single colors, or if stopped/reduceMotion

        let interval: Double
        switch colorChangeMode {
            case .timerBased(let specificInterval):
                interval = max(0.1, specificInterval) // Ensure positive interval
            case .perPulse:
                interval = max(0.1, pulseDuration) // Sync with pulse duration
            case .none:
                return // No timer needed
        }

         // Ensure timer cleanup happened before scheduling a new one
         stopColorTimer()

        // Schedule timer after initial delay
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
            guard self.isAnimating else { return } // Re-check if animation was stopped during delay

            self.colorTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                if self.isAnimating { // Check if still animating when timer fires
                   self.updateColor()
                } else {
                    self.stopColorTimer() // Stop if animation binding turned false
                }
            }
             // Run immediately after delay for the first color change if needed in timer mode
            // Or just rely on the first timer fire. Let's rely on the timer fire for simplicity.
        }
    }

    /// Updates the current color index to the next one in the array.
    private func updateColor() {
        guard !colors.isEmpty else { return }
        currentColorIndex = (currentColorIndex + 1) % colors.count
        // The change to currentColorIndex triggers the implicit animation via .animation modifier
    }
}

// MARK: - AnyShape Wrapper (for Type Erasure in Initializer)

/// A type-erasing shape view.
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

// MARK: - Demo View

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
                    PulsatingView(shapeType: .circle) // Uses defaults
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
                     PulsatingView(
                         shapeType: .capsule,
                         baseSize: CGSize(width: 150, height: 80),
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
                     PulsatingView(
                        shapeType: .roundedRectangle(cornerRadius: 25),
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
                    PulsatingView(
                        shapeType: .circle,
                        pulseDuration: 1.0,
                        pulseAutoreverses: false,  // Only shrinks back instantly
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

// MARK: - Preview Provider

struct PulsatingView_Previews: PreviewProvider {
    static var previews: some View {
        PulsatingViewDemo()
    }
}
