//
//  PearlStripeView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// MARK: Custom Pear Shape
// Define the pear shape using Path commands
struct PearShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height
        let minX = rect.minX
        let minY = rect.minY

        // Start at the bottom center indentation
        path.move(to: CGPoint(x: minX + w * 0.5, y: minY + h))

        // Bottom-left curve
        path.addCurve(to: CGPoint(x: minX, y: minY + h * 0.6),
                      control1: CGPoint(x: minX + w * 0.15, y: minY + h),
                      control2: CGPoint(x: minX, y: minY + h * 0.85))

        // Left side curve up to neck
        path.addCurve(to: CGPoint(x: minX + w * 0.4, y: minY + h * 0.15),
                      control1: CGPoint(x: minX, y: minY + h * 0.3),
                      control2: CGPoint(x: minX + w * 0.2, y: minY + h * 0.1))

        // Neck indent left side going towards stem
        path.addCurve(to: CGPoint(x: minX + w * 0.45, y: minY + h * 0.05),
                      control1: CGPoint(x: minX + w * 0.42, y: minY + h * 0.1),
                      control2: CGPoint(x: minX + w * 0.43, y: minY + h * 0.07))

        // ----- Stem -----
        // Left side of stem
         path.addCurve(to: CGPoint(x: minX + w * 0.4, y: minY + h * 0.02),
                       control1: CGPoint(x: minX + w * 0.43, y: minY + h * 0.03),
                       control2: CGPoint(x: minX + w * 0.41, y: minY + h * 0.025))
        // Top-left curve of stem
         path.addCurve(to: CGPoint(x: minX + w * 0.35, y: minY + h * 0.08), // Point where stem meets leaf
                       control1: CGPoint(x: minX + w * 0.36, y: minY + h * 0.015),
                       control2: CGPoint(x: minX + w * 0.34, y: minY + h * 0.04))

         // ----- Leaf -----
         // Bottom-left curve of leaf
         path.addCurve(to: CGPoint(x: minX + w * 0.5, y: minY + h * 0.01), // Top point of leaf
                       control1: CGPoint(x: minX + w * 0.38, y: minY + h * 0.04),
                       control2: CGPoint(x: minX + w * 0.45, y: minY + h * 0.0))
         // Top-right curve of leaf
         path.addCurve(to: CGPoint(x: minX + w * 0.6, y: minY + h * 0.06), // Point where leaf meets stem (right side)
                       control1: CGPoint(x: minX + w * 0.58, y: minY + h * 0.015),
                       control2: CGPoint(x: minX + w * 0.62, y: minY + h * 0.03))

        // ----- Stem (Right side joining Pear) -----
         // Curve from leaf back down right side of stem
         path.addCurve(to: CGPoint(x: minX + w * 0.55, y: minY + h * 0.08),
                       control1: CGPoint(x: minX + w * 0.61, y: minY + h * 0.08),
                       control2: CGPoint(x: minX + w * 0.58, y: minY + h * 0.09))

        // Neck indent right side
        path.addCurve(to: CGPoint(x: minX + w * 0.6, y: minY + h * 0.15),
                       control1: CGPoint(x: minX + w * 0.57, y: minY + h * 0.09),
                       control2: CGPoint(x: minX + w * 0.58, y: minY + h * 0.12))

        // Right side curve down
        path.addCurve(to: CGPoint(x: minX + w, y: minY + h * 0.6),
                      control1: CGPoint(x: minX + w * 0.8, y: minY + h * 0.1),
                     control2: CGPoint(x: minX + w, y: minY + h * 0.3))

        // Bottom-right curve
        path.addCurve(to: CGPoint(x: minX + w * 0.5, y: minY + h),
                      control1: CGPoint(x: minX + w, y: minY + h * 0.85),
                      control2: CGPoint(x: minX + w * 0.85, y: minY + h))

        path.closeSubpath() // Ensure the path is closed
        return path
    }
}

//MARK: Preview for Static Pear
#Preview("Stripes on Pear") {
    VStack {
        let fill = ShaderLibrary.Stripes(
            .float(12),
            .colorArray([
                .red, .orange, .yellow, .green, .blue, .indigo
            ])
        )

        PearShape() // Use PearShape instead of Circle
            .fill(fill)
            .aspectRatio(0.7, contentMode: .fit) // Adjust aspect ratio to look pear-like
    }
    .padding()
}
//
//// MARK: Animated Stripes View using Timer with Pear Shape
//struct AnimatedStripesViewTimer: View {
//    @State private var phase: Int = 0
//    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
//    let stripeWidth: Float = 12.0
//    let timerInterval: Double = 0.1
//
//    var body: some View {
//        VStack {
//            PearShape() // Use PearShape instead of Circle
//                .fill(stripedShader())
//                .aspectRatio(0.7, contentMode: .fit) // Adjust aspect ratio
//                .onReceive(Timer.publish(every: timerInterval, on: .main, in: .common).autoconnect()) { _ in
//                    // Animate faster or slower by changing how phase increments
//                    phase = (phase + 1) % (colors.count * Int(stripeWidth)) // Make animation smoother relative to stripe width
//                }
//        }
//        .padding()
//    }
//
//    private func stripedShader() -> some ShapeStyle {
//        // Adjust the y-position input to the shader based on phase for animation
//        // We map phase to a vertical offset
//        let verticalOffset = Float(phase % (colors.count * Int(stripeWidth))) / Float(colors.count)
//        
//        return ShaderLibrary.Stripes(
//            .float(stripeWidth),
//            .colorArray(colors), // Pass original colors
//             .float(verticalOffset) // Pass the offset to the shader
//        )
//    }
//
//    // We don't need to shift colors array anymore if offset is passed to shader
//    // private func shiftedColors() -> [Color] {
//    //     var shifted = colors
//    //     shifted.rotate(to: phase / Int(stripeWidth)) // Adjust rotation speed if needed
//    //     return shifted
//    // }
//}
//
//// Keep the Array extension as it is potentially useful, although not used in the modified shader approach above
//extension Array {
//    mutating func rotate(to shift: Int) {
//        let shift = shift % count
//        if shift < 0 {
//            let newShift = count + shift
//            self.rotate(to: newShift)
//        } else if shift > 0 { // avoid unnecessary work for shift = 0
//             let rotated = self.dropFirst(shift) + self.prefix(shift)
//             self = Array(rotated)
//        }
//    }
//}
//
//// MARK: Preview for Animated Pear
//#Preview("Animated Stripes Pear View using Timer") {
//    AnimatedStripesViewTimer()
//        .preferredColorScheme(.dark)
//}
