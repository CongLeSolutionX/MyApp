//
//  RippleEffect_IndependentStateVariables.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//


import SwiftUI

struct RippleEffectOnMultipleUIComponentsWithIndependentStateVariablesView: View {
    // Separate state variables for each view
    @State private var counterButton: Int = 0
    @State private var originButton: CGPoint = .zero

    @State private var counterImage: Int = 0
    @State private var originImage: CGPoint = .zero

    @State private var counterRectangle: Int = 0
    @State private var originRectangle: CGPoint = .zero

    var body: some View {
        VStack(spacing: 40) {
            // Ripple on a Text Button
            Button(action: {
                // Button action
            }) {
                Text("Press Me")
                    .font(.title)
                    .padding()
                    .background(Color.blue.cornerRadius(8))
                    .foregroundColor(.white)
            }
            .onPressingChanged { point in
                if let point = point {
                    originButton = point
                    counterButton += 1
                }
            }
            .modifier(
                RippleEffect(
                    at: originButton,
                    trigger: counterButton
                )
            )

            // Ripple on an Image
            Image(systemName: "heart.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
                .onPressingChanged { point in
                    if let point = point {
                        originImage = point
                        counterImage += 1
                    }
                }
                .modifier(
                    RippleEffect(
                        at: originImage,
                        trigger: counterImage
                    )
                )

            // Ripple on a Custom View
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
                .frame(width: 150, height: 100)
                .overlay(
                    Text("Tap Here")
                        .font(.headline)
                        .foregroundColor(.white)
                )
                .onPressingChanged { point in
                    if let point = point {
                        originRectangle = point
                        counterRectangle += 1
                    }
                }
                .modifier(
                    RippleEffect(
                        at: originRectangle,
                        trigger: counterRectangle
                    )
                )
        }
        .padding()
    }
}

struct RippleEffectOnMultipleUIComponentsWithIndependentStateVariablesView_Previews: PreviewProvider {
    static var previews: some View {
        RippleEffectOnMultipleUIComponentsWithIndependentStateVariablesView()
    }
}
