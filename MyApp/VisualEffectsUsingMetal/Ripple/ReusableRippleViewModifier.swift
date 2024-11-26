//
//  ReusableRippleViewModifier.swift
//  MyApp
//
//  Created by Cong Le on 11/26/24.
//

import SwiftUI


// MARK: - Ripple extension
extension View {
    func ripple(
        origin: CGPoint,
        trigger: Int,
        color: Color = Color.blue.opacity(0.3),
        scale: CGFloat = 1.0
    ) -> some View {
        self.modifier(
            RippleEffect(
                at: origin,
                trigger: trigger
            )
        )
    }
}





// MARK: - Preview

struct ReusableRippleViewModifierDemoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        @State var counterButton: Int = 0
        @State var originButton: CGPoint = .zero
        
        
        Button(action: {
            // Button action
        }) {
            Text("Simplified Ripple")
                .font(.title2)
                .padding()
                .background(Color.teal.cornerRadius(8))
                .foregroundColor(.white)
        }
        .onPressingChanged { point in
            if let point = point {
                originButton = point
                counterButton += 1
            }
        }
        .ripple(
            origin: originButton,
            trigger: counterButton,
            color: Color.teal.opacity(0.3),
            scale: 1.5
        )

    }
}
