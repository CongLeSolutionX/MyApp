//
//  ColorWave.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//
import SwiftUI

struct ColorWave: View {
    @State private var phase: CGFloat = 0
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    let animationDuration: Double = 20

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<colors.count, id: \.self) { index in
                    Rectangle()
                        .fill(colors[index])
                      .frame(width: geometry.size.width / CGFloat(colors.count), height: geometry.size.height)
                        .offset(x: waveOffset(for: index, in: geometry.size.width))

                }
            }
             .onAppear{
                withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses:false)){
                    phase = 2 * .pi
                   }
               }
        }

    }

    func waveOffset(for index: Int, in width: CGFloat) -> CGFloat {
        let segmentWidth = width / CGFloat(colors.count)
        let offset = CGFloat(index) * segmentWidth - CGFloat(colors.count) * segmentWidth / 2
        return offset + sin((phase + CGFloat(index) * 2 * .pi / CGFloat(colors.count))) * segmentWidth
    }
}

#Preview {
    ColorWave()
}
