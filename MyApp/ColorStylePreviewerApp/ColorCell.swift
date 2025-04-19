//
//  ColorCell.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

// MARK: - ColorCell.swift

import SwiftUI

struct ColorCell: View {
    let colorItem: ColorItem
    var onTap: () -> Void

    var body: some View {
        VStack {
            Rectangle()
                .fill(colorItem.color)
                .frame(height: 70)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
            Text(colorItem.name)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .onTapGesture {
            onTap()
        }
    }
}
