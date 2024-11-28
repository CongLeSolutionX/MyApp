//
//  MeshGradientRetroColor3x3.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI




//Preview {
//    if #available(iOS 18.0, *) {
//            MeshGradient(columns: 8, rows: 8) { x, y in
//              Point(
//                  x: x,
//                  y: y,
//                  color: [
//                      Color(red: 255/255, green: 165/255, blue:   0/255),   // Bright Orange
//                      Color(red:   0/255, green: 150/255, blue: 255/255), // Electric Blue
//                      Color(red: 220/255, green:  20/255, blue:  60/255)  // Crimson
//                  ][Int(Double(x + y * 8) * 3 / 64) % 3 ] // Distribute colors evenly across the grid
//              )
//          }
//          .edgesIgnoringSafeArea(.all)
//    } else {
//        Text("MeshGradient requires iOS 18.0 or later.")
//    }
//}


// MARK: - "90s Neon" Gradient (Inspired by Arcade and Club Culture)
/// Colors: Hot Pink, Electric Blue, Lime Green, Bright Orange, and Black.
/// This palette brings the energy of 90s arcades and dance clubs.

#Preview("90s Neon Gradient") {
    if #available(iOS 18, *) {
        MeshGradient(width: 3, height: 2,
                     points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                        Color(red: 255/255, green: 105/255, blue: 180/255), // Hot Pink
                        Color(red: 0/255, green: 150/255, blue: 255/255), // Electric Blue
                        Color(red: 144/255, green: 238/255, blue: 144/255), // Lime Green
                        Color(red: 255/255, green: 165/255, blue: 0/255), // Bright Orange
                        Color.black, // Black
                        Color.white // White
                     ])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - "90s Grunge" Gradient
/// Colors: Muted tones of Olive Green, Dark Red, Charcoal Gray, Mustard Yellow, and a touch of Faded Denim Blue.
/// Inspired by the fashion and music scene of the time.
#Preview("90s Grunge Gradient") {
    if #available(iOS 18, *) {
        MeshGradient(width: 2, height: 3,
                     points: [
                        [0.0, 0.0],   [1.0, 0.0],
                        [0.0, 0.5],   [1.0, 0.5],
                        [0.0, 1.0],   [1.0, 1.0]
                     ],
                     colors: [
                        Color(red: 128/255, green: 128/255, blue:   0/255), // Olive Green
                        Color(red: 139/255, green:   0/255, blue:   0/255), // Dark Red
                        Color(red:  54/255, green:  69/255, blue:  79/255), // Charcoal Gray
                        Color(red: 255/255, green: 219/255, blue:  88/255), // Mustard Yellow
                        Color(red:  94/255, green: 134/255, blue: 193/255), // Faded Denim Blue
                        Color.black  // Black
                     ])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}


// MARK: - "90s Pastel" Gradient
/// Colors: Soft Pink, Light Teal, Lavender, Pale Yellow, Mint Green.
/// This palette reflects the softer side of 90s design, often seen in casual wear and interior design.
#Preview("90s Pastel Gradient") {
    if #available(iOS 18, *) {
        MeshGradient(width: 3, height: 2,
                     points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                        Color(red: 255/255, green: 182/255, blue: 193/255), // Soft Pink
                        Color(red: 128/255, green: 216/255, blue: 255/255), // Light Teal
                        Color(red: 230/255, green: 230/255, blue: 250/255), // Lavender
                        Color(red: 255/255, green: 255/255, blue: 224/255), // Pale Yellow
                        Color(red: 152/255, green: 255/255, blue: 152/255), // Mint Green
                        Color.white // White
                     ])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}


// MARK: - "90s Geometric" Gradient
/// Colors: Bright Primary Colors (Red, Blue, Yellow) and Black, White.
/// These were often contrasted in bold geometric patterns.
#Preview("90s Geometric Gradient") {
    if #available(iOS 18, *) {
        MeshGradient(width: 2, height: 2,
                     points: [
                        [0.0, 0.0], [1.0, 0.0],
                        [0.0, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                        Color(red: 1.0, green: 0.0, blue: 0.0),   // Red
                        Color(red: 0.0, green: 0.0, blue: 1.0),   // Blue
                        Color(red: 1.0, green: 1.0, blue: 0.0),   // Yellow
                        Color(red: 0.0, green: 0.0, blue: 0.0)    // Black
                     ])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}
