//
//  RotatingColorWheelView.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//


import SwiftUI

/// A view that displays a segmented color wheel, capable of continuous rotation
/// and various customizations like segment count, size, donut shape, stroke,
/// and animation control.
struct RotatingColorWheel: View {

    // MARK: - Properties

    /// The array of colors to display in the wheel segments.
    let colors: [Color]

    /// The desired number of segments. If nil, defaults to the count of `colors`.
    /// If provided, colors will repeat or be truncated to match this count.
    let numberOfSegments: Int?

    /// The diameter of the color wheel.
    let wheelSize: CGFloat

    /// The duration (in seconds) for one full 360-degree rotation.
    let animationDuration: Double

    /// The radius of the inner hole, creating a donut shape. 0 means a full pie.
    let innerRadiusFraction: CGFloat // Fraction of the outer radius

    /// The width of the stroke line drawn around each segment. 0 means no stroke.
    let strokeWidth: CGFloat

    /// The color of the stroke line around segments.
    let strokeColor: Color

    /// Controls whether the wheel should be animating initially and can be toggled.
    @Binding var isAnimating: Bool

    /// The animation curve to use for the rotation (e.g., .linear, .easeInOut).
    let animationCurve: ((Double) -> Animation) // Function to create Animation

    /// Whether the rotation animation should reverse direction after each cycle.
    let autoreverses: Bool

    /// The current rotation angle of the wheel. Managed internally.
    @State private var rotationAngle: Angle = .zero

    // MARK: - Computed Properties

    /// The actual number of segments to draw, based on `numberOfSegments` or `colors.count`.
    private var actualNumberOfSegments: Int {
        max(1, numberOfSegments ?? colors.count) // Ensure at least 1 segment
    }

    /// The outer radius of the wheel.
    private var outerRadius: CGFloat {
        wheelSize / 2.0
    }

    /// The inner radius calculated from the fraction.
    private var actualInnerRadius: CGFloat {
        outerRadius * max(0, min(1, innerRadiusFraction)) // Clamp between 0 and 1
    }

    // MARK: - Initializers

    /// Creates a new RotatingColorWheel with specified configurations.
    ///
    /// - Parameters:
    ///   - colors: The array of colors for the segments. Defaults to a rainbow set.
    ///   - numberOfSegments: Optional explicit number of segments. Defaults to `colors.count`.
    ///   - wheelSize: The diameter of the wheel. Defaults to 100.
    ///   - animationDuration: Duration of one rotation. Defaults to 5.0 seconds.
    ///   - innerRadiusFraction: Fraction of the outer radius for the inner hole (0-1). Defaults to 0 (no hole).
    ///   - strokeWidth: Width of the border around segments. Defaults to 0 (no stroke).
    ///   - strokeColor: Color of the segment borders. Defaults to `.clear`.
    ///   - isAnimating: A binding to control the animation state. Defaults to a constant `true`.
    ///   - animationCurve: A closure providing the animation type based on duration. Defaults to `.linear`.
    ///   - autoreverses: Whether the animation reverses direction. Defaults to `false`.
    init(
        colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple],
        numberOfSegments: Int? = nil,
        wheelSize: CGFloat = 100,
        animationDuration: Double = 5.0,
        innerRadiusFraction: CGFloat = 0.0,
        strokeWidth: CGFloat = 0.0,
        strokeColor: Color = .clear,
        isAnimating: Binding<Bool> = .constant(true),
        animationCurve: @escaping (Double) -> Animation = { duration in .linear(duration: duration) },
        autoreverses: Bool = false
    ) {
        self.colors = colors.isEmpty ? [.gray] : colors // Handle empty colors array
        self.numberOfSegments = numberOfSegments
        self.wheelSize = wheelSize
        self.animationDuration = animationDuration
        self.innerRadiusFraction = innerRadiusFraction
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self._isAnimating = isAnimating // Use underscore for Binding initialization
        self.animationCurve = animationCurve
        self.autoreverses = autoreverses
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            ForEach(0..<actualNumberOfSegments, id: \.self) { index in
                SegmentShape(
                    segmentIndex: index,
                    totalSegments: actualNumberOfSegments,
                    outerRadius: outerRadius,
                    innerRadius: actualInnerRadius
                )
                .fill(segmentColor(for: index))
                .overlay(
                    // Add stroke overlay only if strokeWidth > 0
                    strokeWidth > 0 ?
                    SegmentShape(
                        segmentIndex: index,
                        totalSegments: actualNumberOfSegments,
                        outerRadius: outerRadius,
                        innerRadius: actualInnerRadius
                    )
                    .stroke(strokeColor, lineWidth: strokeWidth)
                    : nil // Use nil to avoid applying an empty overlay
                )
            }
        }
        .frame(width: wheelSize, height: wheelSize)
        .rotationEffect(rotationAngle)
        .accessibilityElement(children: .ignore) // Treat as single element
        .accessibilityLabel(Text("Rotating color wheel with \(actualNumberOfSegments) segments."))
        .onAppear(perform: triggerAnimationUpdate) // Trigger initial animation state
        .onChange(of: isAnimating) { // Use new syntax for iOS 14+
             triggerAnimationUpdate()
        }
         // Apply animation modifier *conditionally* based on isAnimating.
         // Note: Directly animating .rotationEffect often works better than toggling
         // the animation modifier itself for repeating animations. The onChange handles
         // starting/stopping the state change *that* drives the effect.
    }

    // MARK: - Helper Methods

    /// Gets the color for a specific segment index, cycling through the `colors` array.
    private func segmentColor(for index: Int) -> Color {
        guard !colors.isEmpty else { return .gray } // Should not happen due to init check, but safety
        return colors[index % colors.count]
    }

    /// Starts or stops the animation based on the `isAnimating` state.
    private func triggerAnimationUpdate() {
        if isAnimating {
            // Start animation: Set target angle with repeating animation context
             DispatchQueue.main.async { // Ensure state change happens on main thread
                 // Reset to 0 briefly before starting ensures it restarts if paused mid-way
                 self.rotationAngle = .zero
                 withAnimation(
                    animationCurve(animationDuration)
                    .repeatForever(autoreverses: autoreverses)
                 ) {
                    rotationAngle = .degrees(360)
                 }
             }
        } else {
            // Stop animation: Set angle to current value *without* repeating animation
             DispatchQueue.main.async { // Ensure state change happens on main thread
                 // Capture the current presentation value if possible (tricky with .repeatForever)
                 // For simplicity, just set it to zero or keep the current model value.
                 // Setting it without 'withAnimation' stops the driver.
                 let currentAngle = self.rotationAngle // Use the model value
                 self.rotationAngle = currentAngle // Apply without animation context
                 // Optionally reset to zero smoothly
                 // withAnimation(animationCurve(0.2)) { // Short animation to settle
                 //     self.rotationAngle = .zero
                 // }
            }
        }
    }
}

// MARK: - Segment Shape

/// A shape representing a single segment (arc or donut slice) of the color wheel.
struct SegmentShape: Shape {
    let segmentIndex: Int
    let totalSegments: Int
    let outerRadius: CGFloat
    let innerRadius: CGFloat

    // Calculate start and end angles for the segment
    var startAngle: Angle {
        .degrees(Double(segmentIndex) / Double(totalSegments) * 360.0)
    }
    var endAngle: Angle {
        .degrees(Double(segmentIndex + 1) / Double(totalSegments) * 360.0)
    }

    func path(in rect: CGRect) -> Path {
        // Center of the shape's coordinate space
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()

        if innerRadius <= 0 {
             // Full Pie Segment
             path.move(to: center)
             path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
             path.closeSubpath() // Line back to center
        } else if innerRadius < outerRadius {
            // Donut Segment
            // Calculate points on inner and outer arcs
            let startOuter = point(at: startAngle, radius: outerRadius, center: center)
            let endOuter = point(at: endAngle, radius: outerRadius, center: center)
            let startInner = point(at: startAngle, radius: innerRadius, center: center)
            let endInner = point(at: endAngle, radius: innerRadius, center: center)

            path.move(to: startInner) // Start at inner arc start
            path.addArc(center: center, radius: innerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false) // Inner arc edge
            path.addLine(to: endOuter) // Line from inner end to outer end
            path.addArc(center: center, radius: outerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true) // Outer arc edge (reversed angles, clockwise=true)
            path.closeSubpath() // Line from outer start to inner start
        }
        // Else (innerRadius >= outerRadius): Draw nothing or handle as error

        return path
    }

    /// Helper to calculate a point on the circumference.
    private func point(at angle: Angle, radius: CGFloat, center: CGPoint) -> CGPoint {
         let x = center.x + radius * cos(CGFloat(angle.radians))
         let y = center.y + radius * sin(CGFloat(angle.radians))
         return CGPoint(x: x, y: y)
     }
}

// MARK: - Preview Provider

struct RotatingColorWheel_Previews: PreviewProvider {
    // Use state in preview for interactive controls
    struct PreviewWrapper: View {
        @State private var isAnimating: Bool = true
        @State private var duration: Double = 5.0
        @State private var innerFraction: CGFloat = 0.0
        @State private var strokeW: CGFloat = 0.0

        var body: some View {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Default Wheel").font(.headline)
                    RotatingColorWheel(isAnimating: $isAnimating)

                    Text("Custom Colors & Segments").font(.headline)
                    RotatingColorWheel(
                        colors: [.cyan, .purple, .yellow, .black],
                        numberOfSegments: 8, // More segments than colors
                        wheelSize: 120,
                        isAnimating: $isAnimating
                    )

                    Text("Donut Style").font(.headline)
                    RotatingColorWheel(
                        colors: [.blue, .green, .orange],
                        wheelSize: 150,
                        innerRadiusFraction: 0.4, // Make a hole
                        isAnimating: $isAnimating
                    )

                    Text("With Stroke").font(.headline)
                    RotatingColorWheel(
                        colors: [.purple, .pink, .white, .gray],
                        wheelSize: 100,
                        innerRadiusFraction: 0.2,
                        strokeWidth: 2,
                        strokeColor: .black,
                        isAnimating: $isAnimating
                    )

                    Text("Static Wheel").font(.headline)
                    RotatingColorWheel(isAnimating: .constant(false)) // Non-interactive state for static

                    Text("EaseInOut Curve & Reverse").font(.headline)
                    RotatingColorWheel(
                        wheelSize: 80,
                        animationDuration: 2.0,
                        isAnimating: $isAnimating,
                        animationCurve: { d in .easeInOut(duration: d) },
                        autoreverses: true
                    )

                    Divider()

                    // --- Interactive Controls ---
                    Text("Controls").font(.title2)
                    Toggle("Animate", isOn: $isAnimating)

                     VStack {
                         Text("Donut Hole Fraction: \(innerFraction, specifier: "%.2f")")
                         Slider(value: $innerFraction, in: 0...0.8) // Max 0.8 to keep some wheel visible
                         RotatingColorWheel(innerRadiusFraction: innerFraction, isAnimating: .constant(true)) // Keep this one animating
                     }
                     .padding(.horizontal)

                     VStack {
                         Text("Stroke Width: \(strokeW, specifier: "%.1f")")
                         Slider(value: $strokeW, in: 0...5)
                         RotatingColorWheel(strokeWidth: strokeW, strokeColor: .black, isAnimating: .constant(true))
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}



