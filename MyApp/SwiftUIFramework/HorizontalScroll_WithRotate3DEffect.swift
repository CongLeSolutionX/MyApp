//
//  HorizontalScrollWithRotate3DEffect.swift
//  MyApp
//
//  Created by Cong Le on 11/28/24.
//

import SwiftUI

#Preview("Horizontal Scroll With Rotate 3D Effect") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            ForEach(0 ..< 5) { item in
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 30)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)), Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .rotation3DEffect(
                            Angle(
                                degrees: Double((geometry.frame(in: .global).minX - 20) / -20)
                            ),
                            axis: (x: 0, y: 1, z: 0),
                            anchor: .center,
                            anchorZ: 0.0,
                            perspective: 1.0
                        )
                }
                .frame(width: 300, height: 300)
            }
        }
        .padding()
    }
}
