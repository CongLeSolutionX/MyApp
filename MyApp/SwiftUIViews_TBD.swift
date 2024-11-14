//
//  SwiftUIViews_TBD.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//

import SwiftUI

struct CloseButtonView: View {
    // Action to perform when the button is tapped
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            // Perform the provided action
            action()
            
            // Optional: Haptic feedback for better user experience
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }) {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20) // Adjust size as needed
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
        .accessibilityLabel("Close")
        .accessibilityHint("Closes the current view")
    }
}

struct CloseButtonView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage within a VStack for preview purposes
        VStack {
            Spacer()
            HStack {
                Spacer()
                CloseButtonView(action: {
                    // Example action: print to console
                    print("Close button tapped")
                })
                .padding()
            }
        }
        .background(Color.gray.edgesIgnoringSafeArea(.all))
    }
}
