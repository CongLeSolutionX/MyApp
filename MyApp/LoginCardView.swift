////
////  LoginCardView.swift
////  MyApp
////
////  Created by Cong Le on 3/28/25.
////
//
//import SwiftUI
//
//// Define the neumorphic colors based on the CSS
//struct LoginCardView_NeumorphicColors {
//    static let background = Color(hex: "#dde1e7")
//    static let darkShadow = Color(hex: "#BABECC")
//    static let lightShadow = Color.white.opacity(0.73) // #ffffff73
//    static let textColor = Color(hex: "#595959")
//    static let placeholderColor = Color(hex: "#666666")
//    static let linkColor = Color(hex: "#3498db")
//}
//
//// Main ContentView
//struct LoginCardView: View {
//    @State private var emailOrPhone: String = ""
//    @State private var password: String = ""
//    
//    var body: some View {
//        ZStack {
//            // Background (simulating the dark area around the card)
//            LoginCardView_NeumorphicColors.background.brightness(-0.1).edgesIgnoringSafeArea(.all)
//            
//            // Neumorphic Card Content
//            VStack(spacing: 20) { // Added spacing for general layout
//                // Login Title
//                Text("Login")
//                    .font(.system(size: 33, weight: .semibold))
//                    .foregroundColor(LoginCardView_NeumorphicColors.textColor)
//                    .padding(.bottom, 15) // Adjusted margin from CSS
//                
//                // Email or Phone Field
//                NeumorphicTextField(
//                    text: $emailOrPhone,
//                    placeholder: "Email or Phone",
//                    iconName: "person.fill" // System icon
//                )
//                
//                // Password Field
//                NeumorphicTextField(
//                    text: $password,
//                    placeholder: "Password",
//                    iconName: "lock.fill", // System icon
//                    isSecure: true
//                )
//                
//                // Forgot Password?
//                HStack {
//                    Button("Forgot Password?") {
//                        print("Forgot Password tapped")
//                        // Add action for forgot password
//                    }
//                    .font(.system(size: 16))
//                    .foregroundColor(LoginCardView_NeumorphicColors.placeholderColor)
//                    Spacer() // Pushes the button to the left
//                }
//                .padding(.horizontal, 5) // Match CSS margin-left approx
//                
//                // Sign In Button
//                Button {
//                    print("Sign In Tapped with Email/Phone: \(emailOrPhone), Pass: \(password)")
//                    // Add sign-in action using emailOrPhone and password
//                } label: {
//                    Text("Sign in")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(LoginCardView_NeumorphicColors.textColor)
//                        .frame(maxWidth: .infinity) // Make button take full width
//                        .frame(height: 50)      // Match CSS height
//                }
//                .buttonStyle(NeumorphicButtonStyle()) // Apply custom neumorphic style
//                .padding(.vertical, 15) // Match CSS margin
//                
//                // Sign Up Text
//                HStack(spacing: 4) {
//                    Text("Not a member?")
//                        .font(.system(size: 16))
//                        .foregroundColor(LoginCardView_NeumorphicColors.textColor)
//                    Button("signup now") {
//                        print("Sign Up tapped")
//                        // Add action for sign up
//                    }
//                    .font(.system(size: 16))
//                    .foregroundColor(LoginCardView_NeumorphicColors.linkColor)
//                }
//            }
//            .padding(.horizontal, 30) // Match CSS padding
//            .padding(.vertical, 40)   // Match CSS padding
//            .background(LoginCardView_NeumorphicColors.background)
//            .cornerRadius(10) // Match CSS border-radius
//            // Outer shadow for the card
//            .shadow(color: LoginCardView_NeumorphicColors.lightShadow, radius: 7, x: -3, y: -3)
//            .shadow(color: LoginCardView_NeumorphicColors.darkShadow.opacity(0.288), radius: 5, x: 2, y: 2)
//            .frame(width: 330) // Match CSS width
//        }
//    }
//}
//
//// Custom View for Neumorphic TextFields to avoid repetition
//struct NeumorphicTextField: View {
//    @Binding var text: String
//    let placeholder: String
//    let iconName: String
//    var isSecure: Bool = false
//    
//    @FocusState private var isFocused: Bool
//    
//    var body: some View {
//        HStack(spacing: 0) { // No space between icon and field bg
//            // Icon
//            Image(systemName: iconName)
//                .foregroundColor(LoginCardView_NeumorphicColors.textColor)
//                .frame(width: 45, height: 50) // Center icon vertically
//            
//            // Text Field / Secure Field
//            Group { // Group allows conditional creation
//                if isSecure {
//                    SecureField("", text: $text) // Placeholder handled by ZStack below
//                } else {
//                    TextField("", text: $text) // Placeholder handled by ZStack below
//                        .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
//                        .autocapitalization(.none)
//                }
//            }
//            .focused($isFocused) // Track focus state
//            .foregroundColor(LoginCardView_NeumorphicColors.textColor)
//            .font(.system(size: 18))
//            .frame(height: 50) // Match CSS height
//            // Custom placeholder implementation for fading effect
//            .overlay(
//                HStack { // Use HStack for padding consistency
//                    Text(placeholder)
//                        .foregroundColor(LoginCardView_NeumorphicColors.placeholderColor)
//                        .font(.system(size: 18))
//                        .opacity(text.isEmpty ? 1 : 0) // Fade out if text exists
//                        .padding(.leading, 5) // Small offset from icon edge
//                    Spacer()
//                }
//                    .allowsHitTesting(false) // Let taps pass through to the text field
//            )
//            .padding(.leading, 0) // Input text starts right after icon area
//        }
//        .background(
//            // Use a ZStack to layer background and inset shadows
//            ZStack {
//                LoginCardView_NeumorphicColors.background // Base background color
//                
//                // Simulate inset shadows using gradients on rounded rectangles inside
//                RoundedRectangle(cornerRadius: 25)
//                    .fill(LoginCardView_NeumorphicColors.background) // Fill needed for shadows to show
//                // Simulating inset shadows (adjust offsets/colors as needed for perfect look)
//                // Darker part (top-left inset)
//                    .shadow(color: LoginCardView_NeumorphicColors.darkShadow.opacity(isFocused ? 0.3 : 0.5), radius: isFocused ? 2 : 5, x: isFocused ? 1 : 2, y: isFocused ? 1 : 2) // Inner top-left
//                // Lighter part (bottom-right inset)
//                    .shadow(color: LoginCardView_NeumorphicColors.lightShadow.opacity(isFocused ? 0.9 : 1.0), radius: isFocused ? 1 : 5, x: isFocused ? -1 : -5, y: isFocused ? -1 : -5) // Inner bottom-right
//                // Clipping ensures the shadows appear 'inset'
//                    .clipShape(RoundedRectangle(cornerRadius: 25))
//                // Optional: A slight inner border if needed
//                // .overlay(RoundedRectangle(cornerRadius: 25).stroke(NeumorphicColors.darkShadow.opacity(0.1), lineWidth: 1))
//            }
//        )
//        .cornerRadius(25) // Match CSS border-radius for the whole field
//    }
//}
//
//// Custom ButtonStyle for Neumorphic effect
//struct NeumorphicButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .background(
//                ZStack {
//                    LoginCardView_NeumorphicColors.background // Base color
//                    
//                    // Show different shadows based on pressed state
//                    if configuration.isPressed {
//                        // Inset look when pressed
//                        RoundedRectangle(cornerRadius: 25)
//                            .fill(LoginCardView_NeumorphicColors.background)
//                        // Inset shadow simulation
//                            .shadow(color: LoginCardView_NeumorphicColors.darkShadow, radius: 5, x: 2, y: 2) // Inner top-left
//                            .shadow(color: LoginCardView_NeumorphicColors.lightShadow, radius: 5, x: -5, y: -5) // Inner bottom-right
//                            .clipShape(RoundedRectangle(cornerRadius: 25)) // Clip to make shadows appear inset
//                    } else {
//                        // Normal raised look
//                        RoundedRectangle(cornerRadius: 25)
//                            .fill(LoginCardView_NeumorphicColors.background)
//                        // Outer Shadows for raised effect
//                            .shadow(color: LoginCardView_NeumorphicColors.lightShadow, radius: 10, x: -5, y: -5)
//                            .shadow(color: LoginCardView_NeumorphicColors.darkShadow, radius: 5, x: 2, y: 2)
//                    }
//                }
//            )
//            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // Slight scale effect on press
//            .animation(.spring(), value: configuration.isPressed) // Smooth animation
//        // Apply the corner radius to the final view
//            .clipShape(RoundedRectangle(cornerRadius: 25))
//    }
//}
//
//// Helper extension for using HEX colors
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
//    }
//}
//
//// Preview Provider
//struct LoginCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginCardView()
//        
//    }
//}
