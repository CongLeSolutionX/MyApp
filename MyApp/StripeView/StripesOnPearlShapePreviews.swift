//
//  StripesOnPearlShapePreviews.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//
import SwiftUI

#Preview("Pear Shapes") {
    VStack(spacing: 20) {
        Text("Detailed Pear")
        DetailedPearShape()
            .fill(Color.green.opacity(0.7))
            .overlay(DetailedPearShape().stroke(Color.black, lineWidth: 1))
            .aspectRatio(0.7, contentMode: .fit)
            .frame(height: 150)

        Text("Stylized Pear")
        StylizedPearShape()
            .fill(Color.yellow.opacity(0.7))
            .overlay(StylizedPearShape().stroke(Color.black, lineWidth: 1))
            .aspectRatio(0.7, contentMode: .fit)
            .frame(height: 150)

        Text("Pear Body Only")
        PearBodyShape()
            .fill(Color.orange.opacity(0.7))
            .overlay(PearBodyShape().stroke(Color.black, lineWidth: 1))
            .aspectRatio(0.7, contentMode: .fit)
            .frame(height: 150)
    }
    .padding()
}



//MARK: - Preview for Static Pear
#Preview("Stripes on Pear") {
    VStack {
        let fill = ShaderLibrary.Stripes(
            .float(12),
            .colorArray([
                .red, .orange, .yellow, .green, .blue, .indigo
            ])
        )

        StylizedPearShape()
        //DetailedPearShape()
        //PearShape()
        //PearBodyShape()
            .fill(fill)
            .aspectRatio(0.7, contentMode: .fit) // Adjust aspect ratio to look pear-like
    }
    .padding()
}
