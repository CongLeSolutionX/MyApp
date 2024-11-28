//
//  MeshGradient80sRetroColor3x3.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI
import MarkdownUI

// MARK: - Retro 80s Gradient
#Preview("Retro 80s Gradient") {
    if #available(iOS 18, *) {
        MeshGradient(width: 3, height: 3,
                     points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                        Color(red: 255/255, green: 105/255, blue: 180/255), // Hot Pink
                        Color(red:   0/255, green: 128/255, blue: 128/255), // Teal
                        Color(red: 191/255, green:  64/255, blue: 191/255), // Electric Purple
                        Color(red: 255/255, green: 255/255, blue:   0/255), // Neon Yellow
                        Color(red:   0/255, green:   0/255, blue:   0/255), // Black
                        Color(red: 255/255, green: 140/255, blue:   0/255), // Sunset Orange
                        Color(red:  51/255, green: 255/255, blue: 153/255), // Miami Green
                        Color(red:   0/255, green: 127/255, blue: 255/255), // Synthwave Blue
                        Color(red: 255/255, green:   0/255, blue: 204/255)  // Cyber Pink
                     ])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}
