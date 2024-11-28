//
//  AnimatedStripesView.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI
import Combine

struct AnimatedStripesViewTimeline: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
    let stripeWidth: Float = 32.0
    let animationDuration: Double = 5.0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { context in
            VStack {
                Circle()
                    .fill(ShaderLibrary.Stripes(
                        .float(stripeWidth),
                        .colorArray(shiftedColors(date: context.date))
                    ))
            }
            .padding()
            
            if #available(iOS 18.0, *) {
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
                    width: 3,
                    height: 3,
                    points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                             [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                             [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]],
                    colors: [Color(red: 184/255, green: 134/255, blue:  11/255), // Deep Gold
                             Color(red: 255/255, green: 191/255, blue:   0/255), // Amber
                             Color(red: 255/255, green: 204/255, blue:   0/255), // Yellow-Orange
                             Color(red: 240/255, green: 230/255, blue: 140/255), // Light Gold
                             Color(red: 255/255, green: 255/255, blue: 224/255), // Pale Yellow
                             Color(red: 247/255, green: 231/255, blue: 206/255), // Champagne
                             Color(red: 184/255, green: 115/255, blue:  51/255), // Copper
                             Color(red: 255/255, green: 215/255, blue:   0/255), // Bright Gold
                             Color(red: 245/255, green: 245/255, blue: 220/255)  // Beige
                            ]
                )
                
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
                
            } else {
                // Fallback on earlier versions
                
                let lookBackward = Text("Look Backward")
                    .customAttribute(EmphasisAttribute())
                    .foregroundStyle(.pink)
                    .bold()
                
                let thinkForward = Text("Think Forward")
                    .customAttribute(EmphasisAttribute())
                    .foregroundStyle(.pink)
                    .bold()
                
                Text("\(lookBackward) \n to \n \(thinkForward)")
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .frame(width: 250)
                    .transition(TextTransition())
            }
        }
    }
    
    func shiftedColors(date: Date) -> [Color] {
        var shifted: [Color] = []
        let timeElapsed = date.timeIntervalSinceReferenceDate
        let shiftAmount = Int((timeElapsed / animationDuration) * Double(colors.count)) % colors.count
        for i in 0..<colors.count {
            shifted.append(colors[(i + shiftAmount) % colors.count])
        }
        return shifted
    }
}

struct AnimatedStripesViewTimer: View {
    @State private var phase: Int = 0
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
    let stripeWidth: Float = 12.0
    let timerInterval: Double = 0.1
    
    var body: some View {
        VStack {
            Circle()
                .fill(stripedShader())
                .onReceive(Timer.publish(every: timerInterval, on: .main, in: .common).autoconnect()) { _ in
                    phase = (phase + 1) % colors.count
                }
        }
        .padding()
    }
    
    private func stripedShader() -> some ShapeStyle {
        ShaderLibrary.Stripes(
            .float(stripeWidth),
            .colorArray(shiftedColors())
        )
    }
    
    private func shiftedColors() -> [Color] {
        var shifted = colors
        shifted.rotate(to: phase)
        return shifted
    }
}

extension Array {
    mutating func rotate(to shift: Int) {
        let shift = shift % count
        if shift < 0 {
            let newShift = count + shift
            self.rotate(to: newShift)
        } else {
            let remaining = self.suffix(shift)
            let rotated = remaining + self.prefix(self.count - shift)
            self = Array(rotated)
        }
    }
}

// MARK: - Previews

// MARK: Animated Stripes Using Timer
#Preview("Animated Stripes View using Timeline") {
    AnimatedStripesViewTimeline()
}

// MARK: Animated Stripes using TimelineView
#Preview("Animated Stripes View using Timer") {
    AnimatedStripesViewTimer()
}
