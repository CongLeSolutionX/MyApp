//
//  PearShape.swift
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
