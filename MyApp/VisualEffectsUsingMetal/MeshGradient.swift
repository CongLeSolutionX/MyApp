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

// MARK: - Simple Tri-Color Blend
#Preview("Simple Tri-Color Blend") {
   if #available(iOS 18.0, *) {
        MeshGradient(
            width: 2,
            height: 2,
            points: [[0.0, 0.0],
                     [1.0, 0.0],
                     [0.0, 1.0],
                     [1.0, 1.0]],
            colors: [.red, .yellow, .red, .blue])
        .edgesIgnoringSafeArea(.all)
    } else {
        Text("MeshGradient requires iOS 18.0 or later.")
    }
}

// MARK: - Metallic Sheen
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

