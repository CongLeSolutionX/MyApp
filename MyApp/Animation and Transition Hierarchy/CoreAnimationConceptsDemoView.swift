//
//  CoreAnimationConceptsDemoView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI

// MARK: - Core Protocols (Illustrative - Not Redefining)

/*
// --- Protocol: AdditiveArithmetic (From Swift Standard Library) ---
// Represents types that support addition, subtraction, and have a zero value.
protocol AdditiveArithmetic {
    static var zero: Self { get }
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    // ... other requirements
}

// --- Protocol: VectorArithmetic (From SwiftUI) ---
// Extends AdditiveArithmetic for animation interpolation.
// Requires scalar multiplication and magnitude calculation.
protocol VectorArithmetic: AdditiveArithmetic {
    mutating func scale(by rhs: Double)
    var magnitudeSquared: Double { get }
}

// --- Protocol: Animatable (From SwiftUI) ---
// Defines how a type's properties can be animated.
// Requires an associated type 'AnimatableData' that conforms to VectorArithmetic.
protocol Animatable {
    associatedtype AnimatableData: VectorArithmetic
    var animatableData: AnimatableData { get set }
}
*/

// MARK: - Custom Animatable Struct Example

/// A simple struct holding data we want to animate.
struct AnimatableCircleProperties {
    var scale: CGFloat = 1.0
    var brightness: Double = 0.5 // Represents a brightness factor (0.0 to 1.0)

    /// Explicitly define non-animatable conformance to Equatable if needed for @State changes.
    static func == (lhs: AnimatableCircleProperties, rhs: AnimatableCircleProperties) -> Bool {
        lhs.scale == rhs.scale && lhs.brightness == rhs.brightness
    }
}

/// Make our custom struct conform to Animatable.
extension AnimatableCircleProperties: Animatable {
    /// **AnimatableData:**
    /// The type that SwiftUI uses to interpolate between states during an animation.
    /// It *must* conform to `VectorArithmetic`.
    /// We use `AnimatablePair` to combine multiple animatable properties.
    typealias AnimatableData = AnimatablePair<CGFloat, Double> // Pair of Scale (CGFloat) and Brightness (Double)

    /// **animatableData:**
    /// A computed property that maps the struct's properties to/from its `AnimatableData` representation.
    /// SwiftUI reads this to get the current value and sets it during interpolation.
    var animatableData: AnimatableData {
        get {
            // Map struct properties TO AnimatableData (AnimatablePair)
            AnimatablePair(scale, brightness)
        }
        set {
            // Map AnimatableData (AnimatablePair) back TO struct properties
            scale = newValue.first      // CGFloat for scale
            brightness = newValue.second // Double for brightness
        }
    }
}

// MARK: - SwiftUI View Using the Custom Animatable Struct

struct CoreAnimationConceptsDemoView: View {
    @State private var circleProps = AnimatableCircleProperties(scale: 0.5, brightness: 0.2)
    @State private var animateToggle = false

    var body: some View {
        VStack(spacing: 30) {
            Text("SwiftUI Animation Fundamentals")
                .font(.title2)
                .padding(.bottom)
            
            // Visual representation using the animatable state
            Circle()
                .fill(Color(white: circleProps.brightness)) // Use brightness
                .scaleEffect(circleProps.scale) // Use scale
                .frame(width: 100, height: 100)
                .shadow(radius: 5)
                // Apply animation to the Circle whenever circleProps changes
               // .animation(animateToggle ? .easeInOut(duration: 1.0) : .default , value: circleProps)

            Button("Animate Properties") {
                 let newScale: CGFloat = circleProps.scale < 1.0 ? 1.2 : 0.5
                 let newBrightness: Double = circleProps.brightness < 0.9 ? 0.9 : 0.2
                // No need for withAnimation here because .animation modifier is used above
                // and monitors changes to `circleProps`.
                circleProps = AnimatableCircleProperties(scale: newScale, brightness: newBrightness)
                
                // Toggle this to ensure animation runs even if props cycle back to original values
                // (Not strictly needed if props always change, but good practice for toggles)
                animateToggle.toggle()
            }
            .buttonStyle(.borderedProminent)

            Divider()

            VStack(alignment: .leading) {
                Text("Key Concepts:")
                    .font(.headline)
                Text("• **Animatable:** Protocol requiring `animatableData`.")
                Text("• **VectorArithmetic:** Protocol for `animatableData`. Needs `+, -, zero, scale(by:), magnitudeSquared`.")
                Text("• **animatableData:** Computed property mapping view state <-> VectorArithmetic type.")
                Text("• **AnimatablePair:** Combines two `VectorArithmetic` types into one.")
                Text("• **Built-in:** `CGFloat`, `Double`, `CGPoint`, `CGSize`, `CGRect`, `Angle`, `Color.Resolved` (iOS 17+) are `Animatable`.")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
    }
}

// MARK: - Preview
struct CoreAnimationConceptsDemoView_Previews: PreviewProvider {
    static var previews: some View {
        CoreAnimationConceptsDemoView()
    }
}

// MARK: - Notes on Built-in Conformances (Not Code, Just Explanation)

/*
// SwiftUI provides built-in Animatable conformance for many common types:

// 1. Primitive Numeric Types (via VectorArithmetic):
//    - CGFloat, Double, Float

// 2. Core Graphics Geometry Types (via AnimatablePair and CGFloat):
//    - CGPoint: AnimatableData = AnimatablePair<CGFloat, CGFloat>
//    - CGSize:  AnimatableData = AnimatablePair<CGFloat, CGFloat>
//    - CGRect:  AnimatableData = AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData>

// 3. SwiftUI Specific Types:
//    - Angle: AnimatableData = Double (representing radians)
//    - UnitPoint: AnimatableData = AnimatablePair<CGFloat, CGFloat> // (Less common to animate directly)
//    - EdgeInsets: AnimatableData = AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>> // (Less common)

// 4. Colors (iOS 17+):
//    - Color.Resolved: AnimatableData = AnimatablePair<Float, AnimatablePair<Float, AnimatablePair<Float, Float>>> (RGBA components)

// 5. Others:
//    - EmptyAnimatableData: Conforms to VectorArithmetic, used when a type has no animatable properties.
*/
