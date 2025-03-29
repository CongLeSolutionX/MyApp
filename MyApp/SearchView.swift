//
//  SearchView.swift
//  MyApp
//
//  Created by Cong Le on 3/29/25.
//

import SwiftUI

// Main View implementing the custom text field
struct ContentView: View {
    // Use @AppStorage for simple UserDefaults persistence under the key "savedInputText"
    @AppStorage("savedInputText") private var inputText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    // Define constants for styling based on the CSS and images
    let outlineColor = Color(hex: "#FEBF00") ?? .yellow // Fallback color
    let normalBackgroundColor = Color(hex: "#e2e2e2") ?? .gray.opacity(0.2)
    let focusedBackgroundColor = Color.white
    let placeholderText = "Write here..."
    let containerBackgroundColor = Color(white: 0.9) // Light gray like image 1 background

    let cornerRadius: CGFloat = 10 // border-radius: 10px
    let outlineWidth: CGFloat = 2  // outline: 2px solid ...
    let normalOutlineOffset: CGFloat = 3 // outline-offset: 3px
    let focusedOutlineOffset: CGFloat = 5 // outline-offset: 5px (on focus)

    var body: some View {
        VStack {
            Spacer() // Push TextField towards the center

            // The custom styled TextField
            TextField(placeholderText, text: $inputText)
                .focused($isTextFieldFocused) // Link focus state
                .padding(.vertical, 10)       // padding: 10px ... (top/bottom)
                .padding(.horizontal, 16)     // padding: ... 1rem (left/right, approx 16px)
                .background( // 1. Inner Background (Changes color)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isTextFieldFocused ? focusedBackgroundColor : normalBackgroundColor)
                )
                // 2. Padding to create space for the outline + offset
                // Total space needed = outline thickness + current offset value
                .padding(outlineWidth + (isTextFieldFocused ? focusedOutlineOffset : normalOutlineOffset))
                .background( // 3. Outline Color Layer (Fills the padded space)
                     RoundedRectangle(
                        // Adjust outer radius based on inner radius + total padding
                        cornerRadius: cornerRadius + (isTextFieldFocused ? focusedOutlineOffset : normalOutlineOffset)
                     )
                        .fill(outlineColor)
                )
                // 4. Clip the entire view to the final outer rounded shape
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: cornerRadius + (isTextFieldFocused ? focusedOutlineOffset : normalOutlineOffset)
                    )
                )
                // 5. Animation: Apply smooth transition on focus change
                .animation(.easeInOut(duration: 0.25), value: isTextFieldFocused)
                .padding(.horizontal, 40) // Add some padding around the entire component

            Spacer() // Push TextField towards the center
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack fills the screen
        .background(containerBackgroundColor) // Set the overall screen background
        .edgesIgnoringSafeArea(.all) // Allow background to extend to screen edges
        .onTapGesture {
            // Dismiss keyboard when tapping outside the text field
            isTextFieldFocused = false
        }
    }
}

// Helper extension to initialize Color from HEX strings
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            // Return nil for invalid hex format
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// SwiftUI Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview both light and dark modes if desired
        Group {
            ContentView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")

            ContentView()
                 // Simulate the dark background from the second image for dark mode preview
                .environment(\.colorScheme, .dark) // Set environment explicitly
                .preferredColorScheme(.dark) // Ensure preview uses dark mode
                .previewDisplayName("Dark Mode")
        }

    }
}

// You would typically have an App struct like this:
/*
 @main
 struct YourApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
*/
