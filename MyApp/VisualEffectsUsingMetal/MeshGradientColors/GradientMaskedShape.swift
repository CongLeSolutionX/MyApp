//
//  GradientMaskedShape.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import SwiftUI

// TODO: Mask shape using mesh gradient color
struct GradientMaskedShape: View {
    var body: some View {
        
        Image(systemName: "heart")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .mask {
                Color.red.opacity(0.5)
                Rectangle().opacity(0.3)
            }
    }
}

// MARK: - Preview
#Preview {
    GradientMaskedShape()
}
