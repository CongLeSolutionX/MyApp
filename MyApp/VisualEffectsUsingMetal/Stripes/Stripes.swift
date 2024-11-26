//
//  Stripes.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//

/*
 Source: https://developer.apple.com/documentation/swiftui/creating-visual-effects-with-swiftui
Abstract:
An example of using the `Stripes` shader as a `ShapeStyle`.
*/

import SwiftUI

#Preview("Stripes") {
    VStack {
        let fill = ShaderLibrary.Stripes(
            .float(12),
            .colorArray([
                .red, .orange, .yellow, .green, .blue, .indigo
            ])
        )

        Circle().fill(fill)
    }
    .padding()
}

