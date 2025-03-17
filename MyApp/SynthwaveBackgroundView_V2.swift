//
//  SynthwaveBackgroundView_V2.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct SynthwaveBackgroundView_V2<Content: View>: View {
    @ViewBuilder let content: Content // Customizable content

    var body: some View {
        ZStack {
            LinearGradient(gradient: backgroundGradient, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollingGridView()
            PulsingSunView()
            content // Place the user-provided content
                .shadow(color: .white.opacity(0.5), radius: 5, x: 0, y: 0)
                .offset(y: -20)
        }
    }
    
    private var backgroundGradient: Gradient {
          Gradient(colors: [
              Color(red: 0.1, green: 0.05, blue: 0.2),
              Color(red: 0.2, green: 0.1, blue: 0.3)
          ])
      }
}

struct PulsingSunView: View {
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        SunShape()
            .fill(RadialGradient(gradient: sunGradient, center: .center, startRadius: 0, endRadius: 150 * pulse))
            .frame(width: 300, height: 300)
            .offset(y: -50)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulse = 1.05
                }
            }
    }

    private var sunGradient: Gradient {
        Gradient(colors: [.yellow, .orange, .yellow])
    }
}

struct SunShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = rect.width * 0.5
        let segmentCount = 7
        let segmentGap: CGFloat = 8

        for i in 0..<segmentCount {
            let radius = baseRadius - CGFloat(i) * segmentGap
            path.addArc(center: center, radius: radius, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        }
        return path
    }
}

struct ScrollingGridView: View {
    @State private var verticalOffset: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let gridSpacing: CGFloat = 20
            let perspectiveFactor: CGFloat = 0.8
            let numHorizontalLines = Int(size.height / gridSpacing)
            let numVerticalLines = Int(size.width / gridSpacing)

             // Horizontal lines (with perspective and scrolling)
             for i in 0..<numHorizontalLines {
                 let y = size.height - CGFloat(i) * gridSpacing * (1 + (1 - perspectiveFactor) * (CGFloat(i) / CGFloat(numHorizontalLines))) + verticalOffset
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
        .drawingGroup() // KEY OPTIMIZATION: Render as a single drawing operation
        .opacity(0.7)
        .onAppear {
            withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                verticalOffset = -40 // Adjust for scrolling distance and direction
            }
        }
    }
}
// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SynthwaveBackgroundView_V2 { // Now we can put *any* content here
            Text("Synthwave")
                .font(.custom("Pacifico-Regular", size: 48))
                .foregroundColor(.yellow)
                .overlay(
                                Text("Synthwave")
                                    .font(.custom("Pacifico-Regular", size: 48))
                                    .foregroundColor(Color(red: 0.2, green: 1, blue: 0.8))
                                    .offset(x: 2, y: 2)  // Create an outline effect
                            )
        }
        .previewDevice("iPhone 14")

        SynthwaveBackgroundView_V2 {
            Image(systemName: "music.note") // Example: Put an image instead of text
                .font(.system(size: 60))
                .foregroundColor(.white)
        }
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
