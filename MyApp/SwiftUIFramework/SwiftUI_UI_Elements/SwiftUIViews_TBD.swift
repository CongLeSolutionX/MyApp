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

struct ColorfulAndAnimatingCloseButtonView: View {
    var action: () -> Void
    var size: CGFloat = 20
    var backgroundColor: Color = Color.black.opacity(0.5)
    var iconColor: Color = .white
    var animationDuration: Double = 0.2
    var scaleFactor: CGFloat = 0.9
    var rotationDegrees: Double = 45
    
    @State private var isPressed: Bool = false
    @State private var rotateAngle: Double = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                isPressed = true
                rotateAngle += rotationDegrees
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                action()
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                    isPressed = false
                }
            }
        }) {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(iconColor)
                .padding(10)
                .background(backgroundColor)
                .clipShape(Circle())
                .scaleEffect(isPressed ? scaleFactor : 1.0)
                .rotationEffect(.degrees(rotateAngle))
                .animation(.easeInOut(duration: animationDuration), value: isPressed)
        }
        .accessibilityLabel("Close")
        .accessibilityHint("Closes the current view")
    }
}


struct Rotating45AngleCloseButtonView: View {
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
                .scaleEffect(isPressed ? 0.9 : 1.0) // Apply scale effect based on isPressed state
                .rotationEffect(.degrees(rotateAngle)) // Apply rotation effect
                .animation(.easeInOut(duration: 0.2), value: isPressed) // Smooth out the animation transitions
        }
        .accessibilityLabel("Close")
        .accessibilityHint("Closes the current view")
    }
}


struct PulsingButton: View {
    // MARK: - Properties
    
    /// The action to perform when the button is tapped.
    var action: () -> Void
    
    /// The system image name to display inside the button.
    var systemImageName: String = "heart.fill"
    
    /// The size of the icon within the button.
    var iconSize: CGFloat = 24
    
    /// The foreground color of the icon.
    var iconColor: Color = .red
    
    /// The background color of the button.
    var backgroundColor: Color = .black.opacity(0.8)
    
    /// The size (width and height) of the button.
    var buttonSize: CGFloat = 60
    
    /// The duration of one pulse cycle.
    var pulseDuration: Double = 1.0
    
    /// The scale factor for the pulsing effect.
    var pulseScale: CGFloat = 1.1
    
    // MARK: - State
    
    /// Controls the pulsating animation state.
    @State private var isPulsing: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            // Trigger the button's action
            action()
            
            // Provide haptic feedback
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }) {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundColor(iconColor)
                .padding()
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // Optional: Add shadow for depth
            // Apply pulse animation
                .scaleEffect(isPulsing ? pulseScale : 1.0)
                .animation(
                    Animation.easeInOut(duration: pulseDuration)
                        .repeatForever(autoreverses: true),
                    value: isPulsing
                )
        }
        .onAppear {
            // Start the pulsing effect when the view appears
            isPulsing = true
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .frame(width: buttonSize, height: buttonSize) // Ensures the button has a consistent size
    }
    
    // MARK: - Accessibility
    
    /// Accessibility label for the button.
    private var accessibilityLabel: String {
        return systemImageName.replacingOccurrences(of: ".", with: " ")
    }
    
    /// Accessibility hint for the button.
    private var accessibilityHint: String {
        return "Activates the \(systemImageName) action."
    }
}


struct MultipleGesturesCloseButtonView: View {
    // Actions to perform for different gestures
    var tapAction: () -> Void
    var option1Action: () -> Void
    var option2Action: () -> Void
    
    // Customization parameters
    var size: CGFloat = 20
    var backgroundColor: Color = Color.black.opacity(0.5)
    var iconColor: Color = .white
    var animationDuration: Double = 0.2
    var scaleFactor: CGFloat = 0.9
    var rotationDegreesTap: Double = 45
    var rotationDegreesLongPress: Double = 90
    
    // State variables to manage animations
    @State private var isPressed: Bool = false
    @State private var rotateAngle: Double = 0
    
    var body: some View {
        Button(action: {
            handleTap()
        }) {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(iconColor)
                .padding(10)
                .background(backgroundColor)
                .clipShape(Circle())
            // Apply scale effect based on isPressed state
                .scaleEffect(isPressed ? scaleFactor : 1.0)
            // Apply rotation effect based on rotateAngle
                .rotationEffect(.degrees(rotateAngle))
            // Smooth out the animation transitions
                .animation(.easeInOut(duration: animationDuration), value: isPressed)
        }
        // Attach the context menu
        .contextMenu {
            Button("Option 1") {
                option1Action()
            }
            Button("Option 2") {
                option2Action()
            }
        }
        .accessibilityLabel("Close")
        .accessibilityHint("Closes the current view or shows more options on long press")
    }
    
    // MARK: - Gesture Handlers
    
    /// Handles tap gesture with animations and feedback
    private func handleTap() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
            isPressed = true
            rotateAngle += rotationDegreesTap
        }
        
        // Perform the tap action after a short delay to allow animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            tapAction()
            
            // Provide haptic feedback for tap
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            
            // Reset the animation states
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                isPressed = false
            }
        }
    }
}


// MARK: - Previews


struct MultipleGesturesCloseButtonView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage within a VStack for preview purposes
        VStack {
            Spacer()
            HStack {
                Spacer()
                MultipleGesturesCloseButtonView(
                    tapAction: {
                        print("Close button tapped")
                    },
                    option1Action: {
                        print("Option 1 selected")
                    },
                    option2Action: {
                        print("Option 2 selected")
                    }
                )
                .padding()
            }
        }
        .background(Color.gray.edgesIgnoringSafeArea(.all))
    }
}

struct Rotating45AngleCloseButtonView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage within a VStack for preview purposes
        VStack {
            Spacer()
            HStack {
                Spacer()
                Rotating45AngleCloseButtonView(action: {
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

struct ColorfulAndAnimatingCloseButtonView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage within a VStack for preview purposes
        VStack {
            Spacer()
            HStack {
                Spacer()
                ColorfulAndAnimatingCloseButtonView(
                    action: {
                        print("Customized Close button tapped")
                    },
                    size: 25,
                    backgroundColor: Color.red.opacity(0.7),
                    iconColor: .yellow,
                    animationDuration: 0.3,
                    scaleFactor: 0.85,
                    rotationDegrees: 90
                )
            }
        }
        .background(Color.gray.edgesIgnoringSafeArea(.all))
    }
}


struct PulsingButton_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage within a VStack for preview purposes
        VStack {
            Spacer()
            PulsingButton(action: {
                print("Pulsing button tapped!")
            })
            .padding()
        }
        .background(Color.gray.edgesIgnoringSafeArea(.all))
    }
}

/// Not prefer this macro to preview SwiftUI views
/// since it does not show the name of each individual SwiftUI view
#Preview {
    CustomCloseButtonView {
        print("Custom Close button tapped")
    }
}
