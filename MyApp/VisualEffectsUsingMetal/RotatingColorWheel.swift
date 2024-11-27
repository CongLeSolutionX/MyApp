//
//  RotatingColorWheel.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI

struct RotatingColorWheel: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
    let numberOfSegments: Int = 7
    let animationDuration: Double = 5.0

    @State private var rotationAngle: Angle = .zero

    var body: some View {
        ZStack {
            ForEach(0..<numberOfSegments, id: \.self) { index in
                let startAngle = Double(index) / Double(numberOfSegments) * 360.0
                let endAngle = Double(index + 1) / Double(numberOfSegments) * 360.0
                Path { path in
                    path.move(to: CGPoint(x: 50, y: 50))
                    path.addArc(center: CGPoint(x: 50, y: 50), radius: 50, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
                    path.closeSubpath()
                }
                .fill(colors[index % colors.count])
            }
        }
        .frame(width: 100, height: 100)
        .rotationEffect(rotationAngle)
        .onAppear {
            withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                rotationAngle = .degrees(360)
            }
        }
    }
}
//MARK: - Previews
#Preview {
    RotatingColorWheel()
}
