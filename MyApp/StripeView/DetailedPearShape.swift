//
//  DetailedPearShape.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//
import SwiftUI

struct DetailedPearShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let w = rect.width
            let h = rect.height
            let minX = rect.minX
            let minY = rect.minY

            // Start near bottom center
            path.move(to: relativePoint(0.5, 1.0, in: rect))

            // Bottom Left bulge
            path.addCurve(to: relativePoint(0.05, 0.65, in: rect),
                          control1: relativePoint(0.2, 1.0, in: rect),
                          control2: relativePoint(0.0, 0.85, in: rect))

            // Left side curve up
            path.addCurve(to: relativePoint(0.3, 0.2, in: rect),
                          control1: relativePoint(0.08, 0.4, in: rect),
                          control2: relativePoint(0.15, 0.25, in: rect))

            // Left neck indent
             path.addCurve(to: relativePoint(0.45, 0.08, in: rect), // Left base of stem area
                           control1: relativePoint(0.38, 0.15, in: rect),
                           control2: relativePoint(0.4, 0.1, in: rect))

             // --- Stem ---
             // Left side of stem upward curve
             path.addCurve(to: relativePoint(0.48, 0.0, in: rect), // Top-leftish point of stem
                           control1: relativePoint(0.44, 0.05, in: rect),
                           control2: relativePoint(0.46, 0.01, in: rect))
             // Right side of stem downward curve
             path.addCurve(to: relativePoint(0.54, 0.09, in: rect), // Right base of stem area
                           control1: relativePoint(0.51, 0.01, in: rect),
                           control2: relativePoint(0.53, 0.05, in: rect))

             // --- Leaf ---
             // Going from stem base towards leaf base
             path.addQuadCurve(to: relativePoint(0.58, 0.06, in: rect), // Point where leaf starts underside
                           control: relativePoint(0.55, 0.07, in: rect))

             // Underside curve of leaf
             path.addCurve(to: relativePoint(0.85, 0.18, in: rect), // Leaf Tip approx
                           control1: relativePoint(0.65, 0.05, in: rect), // Control point pulling leaf out
                           control2: relativePoint(0.8, 0.08, in: rect)) // Control point shaping tip

             // Topside curve of leaf
             path.addCurve(to: relativePoint(0.52, 0.12, in: rect), // Back near stem top-right
                           control1: relativePoint(0.82, 0.22, in: rect), // Control shaping top curve
                           control2: relativePoint(0.65, 0.18, in: rect)) // Control pulling back to stem

            // Right neck indent - connecting from leaf/stem area
            path.addCurve(to: relativePoint(0.7, 0.25, in: rect),
                          control1: relativePoint(0.55, 0.15, in: rect), // Adjusted control point
                          control2: relativePoint(0.65, 0.2, in: rect))

            // Right side curve down
            path.addCurve(to: relativePoint(0.98, 0.65, in: rect),
                          control1: relativePoint(0.85, 0.35, in: rect),
                          control2: relativePoint(0.99, 0.5, in: rect))

            // Bottom Right bulge
            path.addCurve(to: relativePoint(0.5, 1.0, in: rect),
                          control1: relativePoint(0.95, 0.85, in: rect),
                          control2: relativePoint(0.8, 1.0, in: rect))

            path.closeSubpath()
        }
    }
}
