//
//  MeshGradient.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//

/*
Source: https://developer.apple.com/documentation/swiftui/creating-visual-effects-with-swiftui

Abstract:
A collection of Mesh Gradient color
*/

import SwiftUI


// MARK: - Electric Blue
#Preview("Electric Blue") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 50/255, green: 205/255, blue: 50/255),   // Lime Green
                              Color(red: 80/255, green: 200/255, blue: 120/255),  // Emerald Green
                              Color(red: 80/255, green: 200/255, blue: 120/255),  // Emerald Green for blending
                              Color(red: 0/255, green: 100/255, blue: 0/255)])   // Dark Green
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - Cold Steel Gradient
/// A modern, industrial gradient combining various grays and blues to create a metallic effect,
/// evoking the feeling of steel or brushed metal.
/// Colors: Light Steel Blue, Dark Slate Gray, Silver, Medium Slate Blue
#Preview("Cold Steel") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 176/255, green: 196/255, blue: 222/255),
                              Color(red: 47/255, green: 79/255, blue: 79/255),
                              Color(red: 192/255, green: 192/255, blue: 192/255),
                              Color(red: 123/255, green: 104/255, blue: 238/255)])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}


// MARK: - "Royal Velvet" Gradient
/// This gradient combines rich purples and deep reds to create a luxurious and regal feeling.
/// Ideal for elements that need to convey sophistication and elegance.
/// Colors: Dark Purple, Wine Red, Royal Blue, Crimson
#Preview("Royal Velvet Gradient") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 48/255, green: 25/255, blue: 52/255),
                              Color(red: 114/255, green: 47/255, blue: 55/255),
                              Color(red: 65/255, green: 105/255, blue: 225/255),
                              Color(red: 220/255, green: 20/255, blue: 60/255)])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}


// MARK: - "Earthy Tones" Gradient
/// This gradient uses natural, muted colors to create a calm and organic feel.
/// It’s well-suited for backgrounds or UI elements that need to convey a sense of nature and grounding.
/// Colors:  Forest Green, Sandy Brown, Moss Green, Dark Oak
#Preview("Earthy Tones Gradient" ) {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 34/255, green: 139/255, blue: 34/255),
                              Color(red: 244/255, green: 164/255, blue: 96/255),
                              Color(red: 138/255, green: 154/255, blue: 91/255),
                              Color(red: 160/255, green: 82/255, blue: 45/255)])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}


// MARK: - "Neon Dreams" Gradient
/// A vibrant, high-energy gradient perfect for accents or elements that need to stand out.
/// It uses bright, saturated colors for a futuristic or cyberpunk aesthetic.
/// Colors: Hot Pink, Electric Blue, Neon Green, Bright Purple
#Preview("Neon Dreams Gradient") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 255/255, green: 105/255, blue: 180/255),
                              Color(red: 125/255, green: 249/255, blue: 255/255),
                              Color(red: 152/255, green: 255/255, blue: 152/255),
                              Color(red: 191/255, green: 0/255, blue: 255/255)])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - Sunset Gradient
/// This captures the warm colors of a sunset, blending shades of orange, yellow, pink, and a touch of purple.
/// Colors: Light Orange, Yellow, Pastel Pink, Bright Orange
#Preview("Sunset Gradient") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 255/255, green: 218/255, blue: 185/255),
                              Color(red: 255/255, green: 255/255, blue: 224/255),
                              Color(red: 255/255, green: 209/255, blue: 220/255),
                              Color(red: 255/255, green: 165/255, blue: 0/255)])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}
// MARK: - Sunset Gradient V2
/// This gradient mimics the warm, inviting colors of a sunset, transitioning from bright oranges to deep blues and purples.
/// It's great for creating a feeling of peace and tranquility.
/// Colors:  Bright Orange, Peach, Deep Sky Blue, Royal Purple
#Preview("Sunset Gradient V2") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 255/255, green: 153/255, blue: 0/255),
                              Color(red: 255/255, green: 229/255, blue: 180/255),
                              Color(red: 0/255, green: 191/255, blue: 255/255),
                              Color(red: 106/255, green: 13/255, blue: 173/255)])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}



// MARK: - "Subtle Monochrome" Gradient
/// This uses various shades of gray to create a subtle and modern gradient,
/// excellent for minimalist designs or as a base for other UI elements.
/// Colors: Light Gray, Dark Gray, Medium Gray, Very Light Gray
#Preview("Subtle Monochrome Gradient") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(white: 0.85), Color(white: 0.4),  Color(white: 0.6),Color(white: 0.94)])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}


// MARK: - Rose Gold Gradient
/// This combines muted pinks, light browns, and golden hues to achieve a sophisticated and luxurious rose gold effect.
/// Ideal for elegant UI elements or backgrounds.
/// Colors: Rose Pink, Light Brown, Gold, Light Pink
#Preview("Rose Gold Gradient") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 188/255, green: 143/255, blue: 143/255),
                              Color(red: 160/255, green: 82/255, blue: 45/255),
                              Color(red: 255/255, green: 215/255, blue: 0/255),
                              Color(red: 255/255, green: 182/255, blue: 193/255)])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }

}

// MARK: - Ocean Hues Gradient
/// This gradient employs various shades of blue and green to create a calming and refreshing effect, reminiscent of the ocean.
/// Colors: Light Teal, Turquoise, Deep Sea Green, Sky Blue
#Preview("Ocean Hues Gradient") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 0/255, green: 128/255, blue: 128/255),
                              Color(red: 64/255, green: 224/255, blue: 208/255),
                              Color(red: 48/255, green: 128/255, blue: 20/255),
                              Color(red: 135/255, green: 206/255, blue: 235/255)])
        .edgesIgnoringSafeArea(.all)

    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}


// MARK: - Twilight
/// This gradient evokes the feeling of dusk or twilight, blending deep blues, purples, and a touch of pink.
/// It’s great for backgrounds that need to convey depth and serenity.
/// Colors: Deep Indigo, Medium Purple, Pink, Dark Blue
#Preview("Twilight Gradient") {
    if #available(iOS 18.0, *) {
        MeshGradient(width: 2, height: 2,
                     points: [[0.0, 0.0], [1.0, 0.0],
                              [0.0, 1.0], [1.0, 1.0]],
                     colors: [Color(red: 25/255, green: 25/255, blue: 112/255),
                              Color(red: 147/255, green: 112/255, blue: 219/255),
                              Color(red: 255/255, green: 192/255, blue: 203/255),
                              Color(red: 0/255, green: 0/255, blue: 139/255)])
            .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - Simple Tri-Color Blend
/// This example creates a smooth transition between three distinct colors: red, yellow, and blue.
/// It's a basic yet visually appealing gradient.
/// The grid structure provides a subtle geometric feel.
/// Colors: Red, Yellow, Blue
#Preview("Simple Tri-Color Blend") {
   if #available(iOS 18.0, *) {
        MeshGradient(
            width: 2,
            height: 2,
            points: [SIMD2<Float>](arrayLiteral: [0.0, 0.0], [1.0, 0.0], [0.0, 1.0], [1.0, 1.0]),
            colors: [Color]([.red, .yellow, .red, .blue]))
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - Metallic Sheen
/// This gradient attempts to mimic the appearance of polished metal using shades of gray and silver,
/// creating a sense of depth and reflectivity.
/// Colors:  Dark Gray, Light Gray, White, Silver
#Preview("Metallic Sheen") {
    if #available(iOS 18.0, *) {
        MeshGradient(
            width: 2,
            height: 2,
            points: [[0.0, 0.0], [1.0, 0.0],[0.0, 1.0], [1.0, 1.0]],
            colors: [.gray, Color(white: 0.8), .white, .gray]) // Silver can be approximated with a light gray
        .edgesIgnoringSafeArea(.all)
    } else{
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - Earth Tone
/// This uses earthy colors like browns, greens, and tans to produce a natural and calming visual effect.
/// It's well-suited for backgrounds in nature-themed apps.
/// Colors:  Brown, Tan, Light Green, Dark Green
#Preview("Earth Tone") {
    if #available(iOS 18.0, *) {
        MeshGradient(
            width: 2,
            height: 2,
            points: [[0.0, 0.0], [1.0, 0.0],[0.0, 1.0], [1.0, 1.0]],
            colors: [.brown, Color(red: 210/255, green: 180/255, blue: 140/255), Color(red: 144/255, green: 238/255, blue: 144/255), .green])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}



//MARK: - Neon Glow
/// For a more vibrant, futuristic feel, this example uses bright, saturated colors that mimic a neon glow effect.
/// Good for creating accents or lively backgrounds.
/// Colors:  Magenta, Cyan, Yellow
//TODO: Not working yet
//#Preview("Neon Glow") {
//    if #available(iOS 18.0, *) {
//        MeshGradient(width: 3, height: 1,
//                     points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0]],
//                     colors: [.green, .cyan, .yellow])
//        .edgesIgnoringSafeArea(.all)
//    } else {
//        Text("MeshGradient requires iOS 18.0 or later.")
//    }
//}

// MARK: - Rainbow Spectrum
///This creates a more vibrant gradient by simulating a rainbow effect.
///It will transition through the classic rainbow colors: red, orange, yellow, green, blue, indigo, and violet.
///Colors: Red, Orange, Yellow, Green, Blue, Indigo, Violet
//TODO: Not working yet
//#Preview("Rainbow Spectrum") {
//    if #available(iOS 18.0, *) {
//        MeshGradient(
//            width: 7,
//            height: 1,
//            points: [[0.0, 0.0], [0.16, 0.0], [0.32, 0.0], [0.48, 0.0], [0.64, 0.0], [0.82, 0.0], [1.0, 0.0]],
//            colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple])
//            .edgesIgnoringSafeArea(.all)
//    } else {
//       Text("MeshGradient requires iOS 18.0 or later.")
//    }
//}
