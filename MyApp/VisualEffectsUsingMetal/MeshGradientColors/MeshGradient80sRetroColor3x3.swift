//
//  MeshGradient80sRetroColor3x3.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI
import MarkdownUI

// MARK: - Retro 80s Gradient
/// Colors: Hot Pink, Teal, Electric Purple, Neon Yellow, Black, Sunset Orange, Miami Green, Synthwave Blue, Cyber Pink.
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
// MARK: - "Synthwave Dream" Gradient
/// Colors: Deep Indigo, Electric Blue, Hot Pink, Dark Purple, Magenta, Turquoise, Sunset Orange, Bright Yellow, Lavender.
#Preview("Synthwave Dream Gradient") {
    if #available(iOS 18, *) {
        MeshGradient(width: 3, height: 3,
                     points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                         Color(red:  75/255, green:   0/255, blue: 130/255),  // Deep Indigo
                         Color(red: 125/255, green: 249/255, blue: 255/255),  // Electric Blue
                         Color(red: 255/255, green: 105/255, blue: 180/255),   // Hot Pink
                         Color(red:  48/255, green:  25/255, blue:  52/255),  // Dark Purple
                         Color(red: 255/255, green:   0/255, blue: 255/255),   // Magenta
                         Color(red:  64/255, green: 224/255, blue: 208/255),   // Turquoise
                         Color(red: 255/255, green: 140/255, blue:   0/255),   // Sunset Orange
                         Color(red: 255/255, green: 255/255, blue:   0/255),   // Bright Yellow
                         Color(red: 230/255, green: 230/255, blue: 250/255)    // Lavender
                     ])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - "Miami Vice" Gradient
/// Colors: Aqua, Flamingo Pink, Peach, Light Teal, Off-White, Lavender, Ocean Blue, Gold, Lime Green.
#Preview("Miami Vice Gradient") {
    if #available(iOS 18, *) {
        MeshGradient(width: 3, height: 3,
                     points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                         Color(red:   0/255, green: 255/255, blue: 255/255), // Aqua
                         Color(red: 252/255, green: 116/255, blue: 253/255), // Flamingo Pink
                         Color(red: 255/255, green: 229/255, blue: 180/255), // Peach
                         Color(red: 160/255, green: 214/255, blue: 180/255), // Light Teal
                         Color(red: 248/255, green: 248/255, blue: 255/255), // Off-White
                         Color(red: 230/255, green: 230/255, blue: 250/255), // Lavender
                         Color(red:   0/255, green: 119/255, blue: 190/255), // Ocean Blue
                         Color(red: 255/255, green: 215/255, blue:   0/255), // Gold
                         Color(red: 144/255, green: 238/255, blue: 144/255)  // Lime Green
                     ])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - "Golden Sunrise" Gradient
/// Colors: Deep Gold, Amber, Yellow-Orange, Light Gold, Pale Yellow, Champagne, Copper, Bright Gold, Beige.
#Preview("Golden Sunrise Gradient") {
  if #available(iOS 18, *) {
      MeshGradient(width: 3, height: 3,
                   points: [
                      [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                      [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                      [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                   ],
                   colors: [
                       Color(red: 184/255, green: 134/255, blue:  11/255), // Deep Gold
                       Color(red: 255/255, green: 191/255, blue:   0/255), // Amber
                       Color(red: 255/255, green: 204/255, blue:   0/255), // Yellow-Orange
                       Color(red: 240/255, green: 230/255, blue: 140/255), // Light Gold
                       Color(red: 255/255, green: 255/255, blue: 224/255), // Pale Yellow
                       Color(red: 247/255, green: 231/255, blue: 206/255), // Champagne
                       Color(red: 184/255, green: 115/255, blue:  51/255), // Copper
                       Color(red: 255/255, green: 215/255, blue:   0/255), // Bright Gold
                       Color(red: 245/255, green: 245/255, blue: 220/255)  // Beige
                   ])
          .edgesIgnoringSafeArea(.all)
  } else {
      Text("MeshGradient requires iOS 18.0 or later.")
  }
}

// MARK: - "Mustard and Chrome" Gradient
/// Colors: Mustard Yellow, Chrome Yellow, Butter Yellow, Light Mustard, Cream, Warm Grey, Dark Mustard, Metallic Gold, Antique White.
#Preview("Mustard and Chrome Gradient") {
  if #available(iOS 18, *) {
      MeshGradient(width: 3, height: 3,
                   points: [
                      [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                      [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                      [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                   ],
                   colors: [
                        Color(red: 204/255, green: 172/255, blue:   0/255), // Mustard Yellow
                        Color(red: 224/255, green: 166/255, blue:  19/255), // Chrome Yellow
                        Color(red: 255/255, green: 255/255, blue: 153/255), // Butter Yellow
                        Color(red: 238/255, green: 221/255, blue: 130/255), // Light Mustard
                        Color(red: 255/255, green: 253/255, blue: 208/255), // Cream
                        Color(red: 128/255, green: 128/255, blue: 128/255), // Warm Grey
                        Color(red: 166/255, green: 124/255, blue:   0/255), // Dark Mustard
                        Color(red: 212/255, green: 175/255, blue:  55/255), // Metallic Gold
                        Color(red: 250/255, green: 235/255, blue: 215/255)  // Antique White
                   ])
          .edgesIgnoringSafeArea(.all)
  } else {
      Text("MeshGradient requires iOS 18.0 or later.")
  }
}

