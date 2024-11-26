//
//  RippleEffect_SharedStateVariables.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//


import SwiftUI
/*
 In this example, we'll create a user interface with multiple interactive elements,
 such as buttons and images, each incorporating the RippleEffect.
 This will showcase how you can reuse the RippleEffect modifier
 across different views.
 */

struct RippleEffectOnMultipleUIComponentsWithSharedStateVariablesView: View {
    /// `origin` and `counter` are shared among the views
    @State private var counter: Int = 0
    @State private var origin: CGPoint = .zero

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
                    origin = point
                    counter += 1
                }
            }
            .modifier(
                RippleEffect(
                    at: origin,
                    trigger: counter
                )
            )

            // Ripple on an Image
            Image(systemName: "heart.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
                .onPressingChanged { point in
                    if let point = point {
                        origin = point
                        counter += 1
                    }
                }
                .modifier(
                    RippleEffect(
                        at: origin,
                        trigger: counter
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
                        origin = point
                        counter += 1
                    }
                }
                .modifier(
                    RippleEffect(
                        at: origin,
                        trigger: counter
                    )
                )
        }
        .padding()
    }
}

// MARK: - PREVIEWS
struct RippleEffectOnMultipleUIComponentsView_Previews: PreviewProvider {
    static var previews: some View {
        RippleEffectOnMultipleUIComponentsWithSharedStateVariablesView()
    }
}
