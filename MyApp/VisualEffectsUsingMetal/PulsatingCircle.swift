//
//  PulsatingCircle.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI

struct PulsatingCircle: View {
    @State private var colorIndex = 0
    @State private var scale: CGFloat = 1
    let colors: [Color] = [.red, .green, .blue, .yellow] // Example colors
    let animationDuration: Double = 1.5

    var body: some View {
        Circle()
            .fill(colors[colorIndex])
            .frame(width: 100 * scale, height: 100 * scale)
            .scaleEffect(scale)
            .animation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true))
            .onAppear {
                startPulsating()
                changeColor()
            }
    }

    func startPulsating() {
        withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
            scale = 1.2
        }
    }

    func changeColor() {
        Timer.scheduledTimer(withTimeInterval: animationDuration / Double(colors.count), repeats: true) { timer in
            withAnimation(.linear(duration: animationDuration / Double(colors.count))) {
                colorIndex = (colorIndex + 1) % colors.count
            }
        }
    }
}

#Preview {
    PulsatingCircle()
}
