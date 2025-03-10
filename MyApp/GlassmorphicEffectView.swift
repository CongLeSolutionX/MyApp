//
//  GlassmorphicEffectView.swift
//  MyApp
//
//  Created by Cong Le on 3/10/25.
//

import SwiftUI

struct GlassmorphicLoginView: View {
    // State variables for user input.
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            // Background gradient covering the entire screen.
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue, Color.pink]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Glass background applied as a container for the login elements.
            GlassBackground()
                .frame(width: 350, height: 500)
                .shadow(color: Color.white.opacity(0.2), radius: 10, x: 0, y: 10)
            
            // Main vertical stack for content.
            VStack(spacing: 20) {
                // Title text.
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Email glass text field.
                GlassTextField(
                    placeholder: "Email",
                    isSecure: false,
                    text: $email
                )
                .frame(height: 50)
                
                // Secure password glass text field.
                GlassTextField(
                    placeholder: "Password",
                    isSecure: true,
                    text: $password
                )
                .frame(height: 50)
                
                // Login button with a gradient background.
                Button(action: {
                    // Login action goes here.
                }) {
                    Text("Login")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.white.opacity(0.2), radius: 10, x: 0, y: 10)
                }
                
                // Sign Up text as a call-to-action.
                Text("Sign Up")
                    .foregroundColor(.white)
                    .underline()
                
                // Social login buttons arranged horizontally.
                HStack(spacing: 20) {
                    SocialLoginButton(icon: "applelogo")
                    SocialLoginButton(icon: "globe")
                    SocialLoginButton(icon: "phone.fill")
                }
            }
            .padding()
        }
    }
}

struct GlassBackground: View {
    var body: some View {
        // Base rounded rectangle with semi-transparent white fill.
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.15))
            // Background overlay: another rounded rectangle with a subtle stroke.
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            // Frosted glass blur effect.
            .blur(radius: 10)
    }
}

struct GlassTextField: View {
    var placeholder: String
    var isSecure: Bool
    @Binding var text: String
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(GlassTextFieldStyle())
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(GlassTextFieldStyle())
            }
        }
    }
}

struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SocialLoginButton: View {
    var icon: String
    
    var body: some View {
        Button(action: {
            // Social login action logic.
        }) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
                .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }
}

// Preview provider for SwiftUI canvas.
struct GlassmorphicLoginView_Previews: PreviewProvider {
    static var previews: some View {
        GlassmorphicLoginView()
    }
}
