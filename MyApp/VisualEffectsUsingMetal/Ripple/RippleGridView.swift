//
//  RippleGridView.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//


import SwiftUI

struct RippleGridView: View {
    @State private var counters: [Int] = Array(repeating: 0, count: 9)
    @State private var origins: [CGPoint] = Array(repeating: .zero, count: 9)

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(0..<9) { index in
                Rectangle()
                    .fill(Color.orange)
                    .frame(height: 100)
                    .onPressingChanged { point in
                        if let point = point {
                            origins[index] = point
                            counters[index] += 1
                        }
                    }
                    .modifier(
                        RippleEffect(
                            at: origins[index],
                            trigger: counters[index]
                        )
                    )
            }
        }
        .padding()
    }
}

// MARK: - Previews
struct RippleGridView_Previews: PreviewProvider {
    static var previews: some View {
        RippleGridView()
    }
}
