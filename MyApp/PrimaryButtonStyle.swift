//
//  PrimaryButtonStyle.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
