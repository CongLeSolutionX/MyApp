//
//  Stripes.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//

/*
 Source: https://developer.apple.com/documentation/swiftui/creating-visual-effects-with-swiftui
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


// MARK: - Previews


// MARK: - Modified effect

// MARK: Animated Stripes using TimelineView
#Preview("Animated Stripes Timeline") {
    AnimatedStripesViewTimeline()
}

//MARK: Original effect
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
