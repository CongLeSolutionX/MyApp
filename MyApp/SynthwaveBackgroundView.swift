//
//  SynthwaveBackgroundView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct SynthwaveBackgroundView: View {
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.1, green: 0.05, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.3)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Perspective Grid
            SynthwaveGridView()

            // Sun
            SunView()
            
            // Synthwave Text (with outline effect)
            ZStack {
                Text("Synthwave")
                    .font(.custom("Pacifico-Regular", size: 48)) // Example font
                    .foregroundColor(.white)
                    .offset(x: 3, y: 3)
                 
                Text("Synthwave")
                    .font(.custom("Pacifico-Regular", size: 48))
                    .foregroundColor(Color(red: 0.2, green: 1, blue: 0.8))
                    .offset(x: 1, y: 1)
                 
                Text("Synthwave")
                    .font(.custom("Pacifico-Regular", size: 48)) // Example font
                    .foregroundColor(.yellow)

            }
            .shadow(color: .white.opacity(0.5), radius: 5, x: 0, y: 0) // Add a glow
            .offset(y: -20) // Position under the sun

        }
    }
}

struct SynthwaveGridView: View {
    var body: some View {
        Canvas { context, size in
            let gridSpacing: CGFloat = 20
            let perspectiveFactor: CGFloat = 0.8 // Adjust for perspective strength
            let numHorizontalLines = Int(size.height / gridSpacing)
            let numVerticalLines = Int(size.width / gridSpacing)

            // Horizontal lines (with perspective)
            for i in 0..<numHorizontalLines {
                let y = size.height - CGFloat(i) * gridSpacing * (1 + (1 - perspectiveFactor) * (CGFloat(i) / CGFloat(numHorizontalLines)))
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Color(red: 1, green: 0.2, blue: 0.8)), lineWidth: 1 + 2 * (CGFloat(i) / CGFloat(numHorizontalLines)))
                 // Add glow effect
                context.blendMode = .plusLighter
                context.addFilter(.blur(radius: 2))
            }

            // Vertical lines (straight)
            for i in 0..<numVerticalLines {
                let x = CGFloat(i) * gridSpacing
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Color(red: 1, green: 0.2, blue: 0.8)), lineWidth: 1)
                // Add glow effect
                context.blendMode = .plusLighter
                context.addFilter(.blur(radius: 1.5))
            }
        }
        .opacity(0.7) // Make grid slightly transparent
    }
}

struct SunView: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height * 0.3) // Position the sun
            let baseRadius = size.width * 0.3
            let segmentCount = 7
            let segmentGap: CGFloat = 8

            for i in 0..<segmentCount {
                let radius = baseRadius - CGFloat(i) * segmentGap
                var path = Path()
                path.addArc(center: center, radius: radius, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                context.stroke(path, with: .color(.yellow), lineWidth: segmentGap - 2)
                 
            }
            // Radial gradient fill
            let gradient = Gradient(colors: [.yellow, .orange, .yellow])
            context.fill(Path(ellipseIn: CGRect(x: center.x - baseRadius, y: center.y - baseRadius, width: baseRadius * 2, height: baseRadius * 2)), with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: baseRadius))
        }
        .offset(y: -50) // Adjust vertical position of the sun
    }
}
// MARK: - Previews
struct SynthwaveBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        SynthwaveBackgroundView()
            .previewDevice("iPhone 16") // Or any other device

        SynthwaveBackgroundView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
