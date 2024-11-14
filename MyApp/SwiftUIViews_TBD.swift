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

struct CustomCloseButtonView: View {
    var action: () -> Void
    var size: CGFloat = 20
    var backgroundColor: Color = Color.black.opacity(0.5)
    var iconColor: Color = .red
    
    var body: some View {
        Button(action: {
            action()
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }) {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(iconColor)
                .padding(10)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .accessibilityLabel("Close")
        .accessibilityHint("Closes the current view")
    }
}



struct AnimatedCloseButtonView: View {
    // Action to perform when the button is tapped
    var action: () -> Void
    
    // State variables to manage animation
    @State private var isPressed: Bool = false
    @State private var rotateAngle: Double = 0
    
    var body: some View {
        Button(action: {
            // Trigger the action with animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                // Scale down the button
                isPressed = true
                
                // Rotate the icon by 45 degrees
                rotateAngle += 45
            }
            
            // Perform the provided action after a short delay to allow animation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                action()
                
                // Provide haptic feedback
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                // Reset the animation states
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                    isPressed = false
                }
            }
        }) {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20) // Adjust size as needed
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
                // Apply scale effect based on isPressed state
                .scaleEffect(isPressed ? 0.9 : 1.0)
                // Apply rotation effect
                .rotationEffect(.degrees(rotateAngle))
                // Smooth out the animation transitions
                .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .accessibilityLabel("Close")
        .accessibilityHint("Closes the current view")
    }
}

// MARK: - Previews

struct AnimatedCloseButtonView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage within a VStack for preview purposes
        VStack {
            Spacer()
            HStack {
                Spacer()
                AnimatedCloseButtonView(action: {
                    // Example action: print to console
                    print("Animated Close Button tapped")
                })
                .padding()
            }
        }
        .background(Color.gray.edgesIgnoringSafeArea(.all))
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

#Preview {
    CustomCloseButtonView {
        print("Custom Close button tapped")
    }
}
