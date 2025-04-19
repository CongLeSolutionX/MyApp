//
//  ColorDetailPreview.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

// MARK: - ColorDetailPreview.swift

import SwiftUI

struct ColorDetailPreview: View {
    let colorItem: ColorItem

    var body: some View {
        VStack(spacing: 10) {
            Text("Preview UI with Selected Color")
                .font(.headline)

            Button("Tap Me") {}
                .padding()
                .foregroundStyle(.white)
                .background(colorItem.color)
                .clipShape(Capsule())

            RoundedRectangle(cornerRadius: 12)
                .fill(colorItem.color)
                .frame(height: 100)
                .overlay(Text("Rounded Container")
                            .foregroundStyle(.white)
                            .bold()
                )

            Text("Label Preview")
                .padding()
                .background(Color.secondary.opacity(0.1))
                .foregroundStyle(colorItem.color)
        }
        .padding(.top, 15)
    }
}
