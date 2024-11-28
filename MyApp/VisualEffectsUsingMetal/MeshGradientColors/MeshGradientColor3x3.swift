//
//  MeshGradientColor3x3.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI


// MARK: - MeshGradient
#Preview("MeshGradient") {
    if #available(iOS 18.0, *) {
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
        .edgesIgnoringSafeArea(.all)
    } else {
        // Fallback on earlier versions
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - "Berry Smoothie" Gradient
/// Colors: Raspberry, Strawberry,   Blueberry,  Cranberry,  Cream,  Blackberry,  Cherry,  Yogurt ,  Plum.
#Preview("Berry Smoothie Gradient") {
    if #available(iOS 18, *) {
        MeshGradient(width: 3, height: 3,
                     points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                     Color(red: 227/255, green: 11/255, blue: 92/255),   // Raspberry
                     Color(red: 252/255, green: 56/255, blue: 102/255),  // Strawberry
                     Color(red: 102/255, green: 105/255, blue: 221/255), // Blueberry
                     Color(red: 158/255, green:   0/255, blue:  63/255), // Cranberry
                     Color(red: 255/255, green: 253/255, blue: 208/255), // Cream
                     Color(red:  77/255, green:   0/255, blue:  51/255), // Blackberry
                     Color(red: 210/255, green:   4/255, blue:  45/255), // Cherry
                     Color(red: 240/255, green: 248/255, blue: 255/255), // Yogurt
                     Color(red: 142/255, green:  69/255, blue: 133/255)  // Plum
                     ])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}



// MARK: - "Ocean Sunset" Gradient
/// Colors: Sky Blue, Coral, Deep Sea Blue, Gold, Orange, Lavender, Peach, Royal Purple
#Preview("Ocean Sunset Gradient") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 3, height: 3,
                     points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                        Color(red: 135/255, green: 206/255, blue: 235/255),   // Sky Blue
                        Color(red: 255/255, green: 127/255, blue: 80/255),    // Coral
                        Color(red: 255/255, green: 215/255, blue: 0/255),     // Gold
                        Color(red: 135/255, green: 206/255, blue: 235/255),   // Sky Blue
                        Color(red:   0/255, green:  51/255, blue: 102/255),   // Deep Sea Blue
                        Color(red: 255/255, green: 165/255, blue:   0/255),     // Orange
                        Color(red: 230/255, green: 230/255, blue: 250/255),   // Lavender
                        Color(red: 120/255, green:  81/255, blue: 169/255),   // Royal Purple
                        Color(red: 255/255, green: 229/255, blue: 180/255)    // Peach
                     ])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}
// MARK: - Modern Art Gradient
/// Colors: Teal, Salmon,  Beige,  Light Coral,  Charcoal,  Lavender,  Mustard,  Sky Blue,  Dusty Rose
#Preview("Modern Art") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 3, height: 3,
                     points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                        Color(red:   0/255, green: 128/255, blue: 128/255),  // Teal
                        Color(red: 250/255, green: 128/255, blue: 114/255),  // Salmon
                        Color(red: 245/255, green: 245/255, blue: 220/255),  // Beige
                        Color(red: 240/255, green: 128/255, blue: 128/255),  // Light Coral
                        Color(red:  54/255, green:  54/255, blue:  54/255),  // Charcoal
                        Color(red: 230/255, green: 230/255, blue: 250/255),  // Lavender
                        Color(red: 255/255, green: 215/255, blue:   0/255),  // Mustard
                        Color(red: 135/255, green: 206/255, blue: 235/255),  // Sky Blue
                        Color(red: 188/255, green: 143/255, blue: 143/255)   // Dusty Rose
                     ])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - "Forest Canopy" Gradient
///Colors:  Light Green,  Moss Green,  Dark Green,  Sunlight Yellow,  Deep Forest Green,  Jade Green,  Forest Brown,  Emerald Green, Brown
#Preview("Forest Canopy Gradient") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 3, height: 3,
                     points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                     ],
                     colors: [
                        Color(red: 144/255, green: 238/255, blue: 144/255),  // Light Green
                        Color(red: 138/255, green: 154/255, blue:  91/255),  // Moss Green
                        Color(red:   0/255, green: 100/255, blue:   0/255),  // Dark Green
                        Color(red: 240/255, green: 230/255, blue: 140/255),  // Sunlight Yellow
                        Color(red:  34/255, green: 139/255, blue:  34/255),  // Deep Forest Green
                        Color(red:   0/255, green: 168/255, blue: 107/255),  // Jade Green
                        Color(red: 107/255, green:  66/255, blue:  38/255),  // Forest Brown
                        Color(red:  80/255, green: 200/255, blue: 120/255),  // Emerald Green
                        Color(red: 160/255, green:  82/255, blue:  45/255)   // Brown
                     ])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}
