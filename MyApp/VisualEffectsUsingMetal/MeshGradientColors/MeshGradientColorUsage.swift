//
//  MeshGradientColorUsage.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI


/// We can use these gradients just like any other `ShapeStyle` in `SwiftUI`.
/// For example, you can use them as a fill for a `Rectangle`, a `Circle`, or a `Text` view

// MARK: - Circle with gradient color
#Preview("Circle Shape Filled with gradient color") {
    if #available(iOS 18.0, *) {
        // TODO: Need to create a shared library for MeshGradient color
        let filledGradientColor = MeshGradient(
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
        
        let filledRetro80sColor = MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
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
        
        Circle()
            .fill(filledGradientColor)
            .frame(width: 200, height: 200)
        
        
        Spacer()
        
        Rectangle()
            .fill(filledRetro80sColor)
            .frame(width: 200, height: 200)
        
        Spacer()
       
        
        let lookBackward = Text("Look Backward")
            .customAttribute(EmphasisAttribute())
            .foregroundStyle(filledGradientColor)
            .bold()
        
        let thinkForward = Text("Think Forward")
            .customAttribute(EmphasisAttribute())
            .foregroundStyle(filledRetro80sColor)
            .bold()

        Text("\(lookBackward) \n to \n\(thinkForward)")
            .font(.system(.title, design: .rounded, weight: .semibold))
            .frame(width: 250)
            //.transition(TextTransition())
      

      
        Spacer()
        
    } else {
        // Fallback on earlier versions
    }
}

