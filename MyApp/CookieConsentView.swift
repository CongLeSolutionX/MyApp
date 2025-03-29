////
////  CookieConsentView.swift
////  MyApp
////
////  Created by Cong Le on 3/29/25.
////
//
//import SwiftUI
////
////// Main Application Structure
////@main
////struct CookieConsentApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
//
//// Main Content View - Manages the visibility of the consent card
//struct ContentView: View {
//    // Use AppStorage to persist the consent choice across app launches.
//    @AppStorage("cookieConsentGiven") var cookieConsentGiven: Bool?
//
//    // State to control the immediate visibility of the card in the UI
//    // Initialize it to a default state (e.g., false). It will be updated in onAppear.
//    @State private var showCookieConsent: Bool = false
//
//    // Remove the custom init()
//
//    var body: some View {
//        ZStack {
//            // Background content of your app would go here
//            Color.gray.opacity(0.3) // Example background
//                .ignoresSafeArea()
//                .overlay(
//                    Text("App Content Area")
//                        .foregroundColor(.white)
//                )
//
//            // Display the Cookie Consent View conditionally
//            // Use an overlay or similar container if you want it modal-like
//            if showCookieConsent {
//                CookieConsentView(isPresented: $showCookieConsent) { userAllowed in
//                    // This closure is called when the user makes a choice
//                    self.cookieConsentGiven = userAllowed
//                    // You might trigger other actions here based on consent
//                    print("Cookie consent set to: \(userAllowed)")
//                    // Explicitly set showCookieConsent to false again in case the binding doesn't propagate instantly
//                    // Although binding should handle it, this can be a safeguard.
//                    self.showCookieConsent = false
//                }
//                .zIndex(1) // Ensure it draws on top
//                .transition(.move(edge: .bottom).combined(with: .opacity)) // Nice transition
//            }
//        }
//        .onAppear {
//            // Check the consent status *after* the view has appeared and properties are initialized.
//            // Only show the consent view if no decision has been recorded yet.
//            if cookieConsentGiven == nil {
//                // Set the state to trigger the view presentation
//                // Use withAnimation for a smoother appearance if desired immediately on load
//                withAnimation {
//                    self.showCookieConsent = true
//                }
//            }
//            // If cookieConsentGiven is not nil (true or false), showCookieConsent remains false (its initial value).
//        }
//        // Animate based on the state change (optional, depends on desired effect)
//        // .animation(.easeInOut, value: showCookieConsent) // Already applied in the transition
//    }
//}
//
//// The Cookie Consent Card View
//struct CookieConsentView: View {
//    // Binding to control the presentation state of this view
//    @Binding var isPresented: Bool
//    // Closure to call when a decision is made (true for allow, false for decline)
//    var onDecision: (Bool) -> Void
//
//    // --- Constants based on CSS ---
//    let cardWidth: CGFloat = 300
//    let cardHeight: CGFloat = 220 // Adjusted slightly for typical SwiftUI layout flow
//    let iconSize: CGFloat = 50
//    let buttonWidth: CGFloat = 80
//    let buttonHeight: CGFloat = 30
//    let cornerRadius: CGFloat = 20 // Button corner radius
//    let cardCornerRadius: CGFloat = 12 // Card corner radius (inferring from overall look)
//    let shadowRadius: CGFloat = 8
//
//    // --- Colors based on CSS ---
//    let cardBackgroundColor = Color.white
//    let iconColor = Color(red: 97/255, green: 81/255, blue: 81/255)
//    let headingColor = Color(red: 26/255, green: 26/255, blue: 26/255)
//    let descriptionColor = Color(red: 99/255, green: 99/255, blue: 99/255)
//    let acceptButtonColor = Color(red: 123/255, green: 87/255, blue: 255/255) // #7b57ff
//    let acceptButtonTextColor = Color.white // rgb(241, 241, 241) - close enough to white
//    let declineButtonColor = Color(red: 218/255, green: 218/255, blue: 218/255)
//    let declineButtonTextColor = Color(red: 46/255, green: 46/255, blue: 46/255)
//    let shadowColor = Color.black.opacity(0.1) // Approximating rgba(0, 0, 0, 0.062) shadow
//
//    var body: some View {
//        VStack(spacing: 15) { // Approximating `gap: 13px` and item spacing
//            // Cookie Icon
//            Image(systemName: "figure.cookie") // Using SF Symbol
//                .resizable()
//                .scaledToFit()
//                .frame(width: iconSize, height: iconSize)
//                .foregroundColor(iconColor)
//
//            // Heading Text
//            Text("We use cookies.")
//                .font(.system(size: 20, weight: .heavy)) // Approximating 1.2em, 800 weight
//                .foregroundColor(headingColor)
//
//            // Description Text
//            Text("This website uses cookies to ensure you get the best experience on our site.")
//                .font(.system(size: 13, weight: .semibold)) // Approximating 0.7em, 600 weight
//                .foregroundColor(descriptionColor)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 10) // Ensure text wraps reasonably
//
//            // Button Container
//            HStack(spacing: 20) { // `gap: 20px`
//                // Allow Button
//                Button {
//                    handleDecision(allowed: true)
//                } label: {
//                    Text("Allow")
//                        .font(.system(size: 14, weight: .semibold)) // 600 weight
//                        .frame(width: buttonWidth, height: buttonHeight)
//                        .background(acceptButtonColor)
//                        .foregroundColor(acceptButtonTextColor)
//                        .cornerRadius(cornerRadius)
//                }
//
//                // Decline Button
//                Button {
//                   handleDecision(allowed: false)
//                } label: {
//                    Text("Decline")
//                        .font(.system(size: 14, weight: .semibold)) // 600 weight
//                        .frame(width: buttonWidth, height: buttonHeight)
//                        .background(declineButtonColor)
//                        .foregroundColor(declineButtonTextColor)
//                        .cornerRadius(cornerRadius)
//                }
//            }
//            .padding(.top, 5) // Add a bit of space above buttons
//        }
//        .padding(.vertical, 20) // `padding: 20px 30px` - vertical
//        .padding(.horizontal, 30) // `padding: 20px 30px` - horizontal
//        .frame(width: cardWidth) // Fixed width from CSS
//        // Height is more flexible in SwiftUI, determined by content unless explicitly set
//        // .frame(height: cardHeight) // Setting fixed height can cause layout issues if content varies
//        .background(cardBackgroundColor)
//        .cornerRadius(cardCornerRadius)
//        .shadow(color: shadowColor, radius: shadowRadius, x: 2, y: 2) // `box-shadow: 2px 2px 20px rgba(0, 0, 0, 0.062)` - approximated
//    }
//
//    // Helper function to handle button taps
//    private func handleDecision(allowed: Bool) {
//        onDecision(allowed) // Inform the parent view
//        isPresented = false // Dismiss the view
//    }
//}
//
//// Helper struct for previewing in Xcode Canvas
//struct CookieConsentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview the ContentView to see the conditional logic
//        ContentView()
//
//        // Preview the CookieConsentView directly
//        CookieConsentView(isPresented: .constant(true)) { decision in
//            print("Preview decision: \(decision)")
//        }
//        .padding()
//        .background(Color.gray.opacity(0.2))
//    }
//}
//
//// Extension for SF Symbol name (optional but good practice)
//extension Image {
//    // You might need to find the exact SF Symbol name or import a custom asset.
//    // "figure.cookie" is a placeholder; adjust if a better symbol exists.
//    static let cookieIcon = Image(systemName: "figure.cookie") // Check SF Symbols app for best match
//}
