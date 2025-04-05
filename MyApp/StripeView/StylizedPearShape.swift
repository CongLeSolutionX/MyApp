//
//  StylizedPearShape.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//
import SwiftUI

// Helper function to make coordinate definition cleaner
// Calculates point based on percentage of width/height from minX/minY
func relativePoint(_ xPercent: CGFloat, _ yPercent: CGFloat, in rect: CGRect) -> CGPoint {
    return CGPoint(x: rect.minX + rect.width * xPercent,
                   y: rect.minY + rect.height * yPercent)
}



struct StylizedPearShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Start bottom center
            path.move(to: relativePoint(0.5, 1.0, in: rect))

            // Bottom Left
            path.addCurve(to: relativePoint(0.0, 0.6, in: rect),
                          control1: relativePoint(0.15, 1.0, in: rect),
                          control2: relativePoint(0.0, 0.8, in: rect))

            // Left side up
            path.addCurve(to: relativePoint(0.4, 0.15, in: rect),
                          control1: relativePoint(0.0, 0.3, in: rect),
                          control2: relativePoint(0.2, 0.1, in: rect))

            // Left neck / stem base
            path.addQuadCurve(to: relativePoint(0.47, 0.05, in: rect), // Stem left base
                           control: relativePoint(0.43, 0.08, in: rect))

            // --- Stem ---
            path.addCurve(to: relativePoint(0.53, 0.05, in: rect), // Stem right base
                           control1: relativePoint(0.48, -0.02, in: rect), // Control stem top left
                           control2: relativePoint(0.52, -0.02, in: rect))  // Control stem top right

             // --- Leaf (Simplified) ---
            path.addCurve(to: relativePoint(0.8, 0.2, in: rect), // Leaf Tip approx
                           control1: relativePoint(0.6, 0.0, in: rect), // Control leaf outward
                           control2: relativePoint(0.85, 0.05, in: rect)) // Control leaf tip shape

             path.addCurve(to: relativePoint(0.55, 0.13, in: rect), // Back near stem right
                           control1: relativePoint(0.75, 0.25, in: rect), // Control leaf upper curve
                           control2: relativePoint(0.6, 0.18, in: rect)) // Control leaf back towards stem

            // Right neck / stem base join
            path.addQuadCurve(to: relativePoint(0.6, 0.15, in: rect),
                           control: relativePoint(0.57, 0.08, in: rect))

            // Right side down
            path.addCurve(to: relativePoint(1.0, 0.6, in: rect),
                          control1: relativePoint(0.8, 0.1, in: rect),
                          control2: relativePoint(1.0, 0.3, in: rect))

            // Bottom Right
            path.addCurve(to: relativePoint(0.5, 1.0, in: rect),
                          control1: relativePoint(1.0, 0.8, in: rect),
                          control2: relativePoint(0.85, 1.0, in: rect))

            path.closeSubpath()
        }
    }
}
