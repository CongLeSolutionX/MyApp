//
//  ColorMixingExample.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//


import SwiftUI

// --- Color Mixing ---

struct ColorMixingExample: View {
    var body: some View {
        VStack {
            Text("Mixing Red and Purple")
                .font(.headline)
            HStack {
                Color.red
                Color.red.mix(with: .purple, by: 0.2)
                Color.red.mix(with: .purple, by: 0.5) // Equal mix
                Color.red.mix(with: .purple, by: 0.8)
                Color.purple
            }
            .frame(height: 100)
        }
        .padding()
    }
}

#Preview("Color Mixing") {
    ColorMixingExample()
}
