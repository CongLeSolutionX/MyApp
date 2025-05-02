//
//  ConscienceView_Periodic.swift
//  MyApp
//
//  Created by Cong Le on 5/2/25.
//

import SwiftUI
import Combine        // only needed for Timer publisher

// MARK: - Data Model
private struct Node: Identifiable {
    let id = UUID()
    var angle: Double
    var radius: CGFloat
}

// MARK: - View
public struct ConscienceView_Periodic: View {
    // stateful phase
    @State private var phase: Double = 0
    // nodes are constant
    private let nodes: [Node] = (0..<24).map {
        Node(angle: Double($0) / 24 * .pi * 2,
             radius: CGFloat.random(in: 120...180))
    }
    // 60 FPS timer
    private let tick = Timer
        .publish(every: 1/60, on: .main, in: .common)
        .autoconnect()

    public init() {}

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1/60)) { _ in
            Canvas { ctx, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                drawRotatingLattices(phase: phase, in: &ctx, center: center)
                drawEthicalNodes  (phase: phase, in: &ctx, center: center)
            }
            .background(Color.black)
        }
        .onReceive(tick) { _ in
            phase += 0.01          // advance state each frame
        }
    }
}

// MARK: - Drawing helpers
private extension ConscienceView_Periodic {
    func drawRotatingLattices(phase: Double,
                              in ctx: inout GraphicsContext,
                              center: CGPoint) {
        for ring in 1...5 {
            let steps = ring * 6
            var path = Path()
            for s in 0..<steps {
                let angle = phase / Double(ring)
                          + Double(s) / Double(steps) * .pi * 2
                let pt = CGPoint(
                    x: center.x + cos(angle) * CGFloat(ring) * 40,
                    y: center.y + sin(angle) * CGFloat(ring) * 40
                )
                s == 0 ? path.move(to: pt) : path.addLine(to: pt)
            }
            path.closeSubpath()
            ctx.stroke(path, with: .color(.cyan.opacity(0.3)), lineWidth: 1.2)
        }
    }

    func drawEthicalNodes(phase: Double,
                          in ctx: inout GraphicsContext,
                          center: CGPoint) {
        for node in nodes {
            let jitter = sin(phase + node.angle * 3) * 15
            let r = node.radius + jitter
            let pt = CGPoint(
                x: center.x + cos(node.angle) * r,
                y: center.y + sin(node.angle) * r
            )
            let rect = CGRect(x: pt.x - 6, y: pt.y - 6,
                              width: 12, height: 12)
            ctx.fill(Path(ellipseIn: rect), with: .color(.pink))
        }
    }
}

#Preview("ConscienceView Periodic"){
    ConscienceView_Periodic()
}
