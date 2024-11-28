//
//  MeshGradientColorUsage.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI


/// We can use these gradients just like any other `ShapeStyle` in `SwiftUI`.
/// For example, you can use them as a fill for a Rectangle, a Circle, or a Text view

// MARK: - Circle with gradient color
#Preview("Circle Shape Filled with gradient color") {
    if #available(iOS 18.0, *) {
        Circle()
            .fill(
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [SIMD2<Float>]([
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.8, 0.2], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]]),
                    colors: [Color]([
                        .black, .black, .black,
                        .blue, .blue, .blue,
                        .green, .green, .green
                    ]))
            )
            .frame(width: 200, height: 200)
    } else {
        // Fallback on earlier versions
    }
}
