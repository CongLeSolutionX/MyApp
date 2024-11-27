//
//  VisualEffectss.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//

import SwiftUI


// MARK: Sine Wave Hue Shift
#Preview("Sine Wave Hue Shift") {
    ScrollView(.vertical) {
        VStack {
            ForEach(0 ..< 20) { _ in
                RoundedRectangle(cornerRadius: 24)
                    .fill(.purple)
                    .frame(height: 100)
                    .visualEffect { content, proxy in
                        let frame = proxy.frame(in: .scrollView(axis: .vertical))
                        let parentBounds = proxy
                            .bounds(of: .scrollView(axis: .vertical)) ??
                            .infinite

                        // The distance this view extends past the bottom edge
                        // of the scroll view.
                        let distance = min(0, frame.minY)

                        return content
                            .hueRotation(.degrees(frame.origin.y / 10 + Double(index) * 36))
                            .scaleEffect(1 + distance / 700)
                            .offset(y: -distance / 1.25)
                            .brightness(-distance / 400)
                            .blur(radius: -distance / 50)
                    }
            }
        }
        .padding()
    }
}
