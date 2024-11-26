//
//  MeshGradient.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//

/*
Source: https://developer.apple.com/documentation/swiftui/creating-visual-effects-with-swiftui

Abstract:
A simple mesh gradient.
*/

import SwiftUI

#Preview {
    if #available(iOS 18.0, *) {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.8, 0.2], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ], colors: [
                .black, .black, .black,
                .blue, .blue, .blue,
                .green, .green, .green
            ])
        .edgesIgnoringSafeArea(.all)
    } else {
        // Fallback on earlier versions
        EmptyView()
            .background(Color.pink)
    }
}
