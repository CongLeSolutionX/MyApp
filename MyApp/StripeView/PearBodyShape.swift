//
//  PearBodyShape.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//
import SwiftUI

struct PearBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Start bottom center
            path.move(to: relativePoint(0.5, 1.0, in: rect))

            // Bottom Left bulge (using points from Detailed version)
            path.addCurve(to: relativePoint(0.05, 0.65, in: rect),
                          control1: relativePoint(0.2, 1.0, in: rect),
                          control2: relativePoint(0.0, 0.85, in: rect))

            // Left side curve up
            path.addCurve(to: relativePoint(0.3, 0.2, in: rect),
                          control1: relativePoint(0.08, 0.4, in: rect),
                          control2: relativePoint(0.15, 0.25, in: rect))

            // Top curve (neck indent left to right) - Omitting Stem/Leaf
             path.addCurve(to: relativePoint(0.7, 0.25, in: rect), // To right neck indent
                           control1: relativePoint(0.4, 0.05, in: rect), // Control point shaping top left dip
                           control2: relativePoint(0.6, 0.08, in: rect)) // Control point shaping top right dip

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
