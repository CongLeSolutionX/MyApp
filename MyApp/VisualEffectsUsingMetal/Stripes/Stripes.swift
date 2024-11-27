//
//  Stripes.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//

/*
Abstract:
An example of using the `Stripes` shader as a `ShapeStyle`.
*/

import SwiftUI
import Combine

struct AnimatedStripesViewTimeline: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
    let stripeWidth: Float = 32.0
    let animationDuration: Double = 5.0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60, paused: false)) { context in
            VStack {
                Circle()
                    .fill(ShaderLibrary.Stripes(
                        .float(stripeWidth),
                        .colorArray(shiftedColors(date: context.date))
                    ))
            }
            .padding()
            
            let lookBackward = Text("Look Backward")
                .customAttribute(EmphasisAttribute())
                .foregroundStyle(.pink)
                .bold()
            
            let thinkForward = Text("Think Forward")
                .customAttribute(EmphasisAttribute())
                .foregroundStyle(.pink)
                .bold()

            Text("\(lookBackward) to \(thinkForward)")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .frame(width: 250)
                .transition(TextTransition())
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


// MARK: - PREVIEWS


// MARK: - Modified Visual Effects


// MARK: Animated Stripes Using Timer
#Preview("AnimatedStripesViewTimer") {
    AnimatedStripesViewTimer()
}

// MARK: Animated Stripes using TimelineView
#Preview("Animated Stripes Timeline") {
    AnimatedStripesViewTimeline()
}

//MARK: Original effect
// Source: https://developer.apple.com/documentation/swiftui/creating-visual-effects-with-swiftui
#Preview("Stripes") {
    VStack {
        let fill = ShaderLibrary.Stripes(
            .float(12),
            .colorArray([
                .red, .orange, .yellow, .green, .blue, .indigo
            ])
        )

        Circle().fill(fill)
    }
    .padding()
}
