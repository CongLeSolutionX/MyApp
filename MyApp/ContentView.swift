//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}

import SwiftUI

// MARK: - Main Tab View

struct ContentView: View {
    var body: some View {
        TabView {
            QuoteView()
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble")
                }
                // Add identifier for the tab itself if needed for testing
                .accessibilityIdentifier("QUOTES_TAB")

            ReflectionView()
                .tabItem {
                    Label("Reflection", systemImage: "pencil.and.scribble")
                }
                // Add identifier for the tab itself if needed for testing
                .accessibilityIdentifier("REFLECTION_TAB")
        }
    }
}

// MARK: - Quote Tab View

struct QuoteView: View {
    // State for the dynamic quote
    @State private var currentQuote: String = "Live one day at a time and make it a masterpiece."
    private let quotes = [
        "The journey of a thousand miles begins with one step.",
        "That which does not kill us makes us stronger.",
        "Life is what happens when you’re busy making other plans.",
        "When the going gets tough, the tough get going.",
        "You must be the change you wish to see in the world."
    ]

    var body: some View {
        // ZStack for background image and foreground content
        ZStack {
            // --- Decorative Background Image ---
            Image("backgroundImage") // Assume you have an image named "backgroundImage" in Assets
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                // **Accessibility Fix 1: Hide Decorative Image from Assistive Tech**
                // Like overriding accessibilityElements in UIKit to exclude it.
                .accessibilityHidden(true)
                // **Automation Element Equivalent: Make it findable for UI Tests**
                // Even though hidden from AT, UI tests can still find it using this identifier.
                // This mirrors the purpose of `automationElements` in the UIKit example.
                // UI tests would fail to find this *before* adding the identifier if it was
                // removed via a more complex hierarchy manipulation, but `.accessibilityHidden`
                // usually allows identification if the identifier is present.
                .accessibilityIdentifier("BACKGROUND_IMAGE")

            // VStack to layout the text and button
            VStack {
                Spacer() // Pushes content down a bit

                // --- Quote Text View ---
                Text(currentQuote)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white) // Assuming dark background
                    .padding()
                    .background(.black.opacity(0.5)) // Improve contrast
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
                    // **Accessibility Fix 2: Use Identifier for UI Tests**
                    // Remove the problematic accessibilityLabel="QUOTE_TEXTVIEW"
                    // Set the identifier instead. VoiceOver will read the Text content.
                    .accessibilityIdentifier("QUOTE_TEXTVIEW")
                    // Let VoiceOver read the content directly (no explicit label needed here)

                Spacer() // Pushes button down

                // --- New Quote Button ---
                Button("New Quote") {
                    // Action to update the quote
                    currentQuote = quotes.randomElement() ?? "Keep inspiring!"
                }
                .padding()
                .buttonStyle(.borderedProminent)
                // **Accessibility Best Practice: Identifier for interactive elements**
                .accessibilityIdentifier("NEW_QUOTE_BUTTON")
                // The button text "New Quote" acts as its default accessibilityLabel.

                Spacer() // Pushes content towards center
            }
            .padding() // Padding for the VStack content

        }
        // Make the ZStack a container for accessibility elements, allowing individual control
        // .contain means VoiceOver navigates *into* the ZStack to its children
        .accessibilityElement(children: .contain)
        .navigationTitle("Inspiration") // Example if used in NavigationView
    }
}

// MARK: - Reflection Tab View

struct ReflectionView: View {
    @State private var reflectionText: String = ""

    var body: some View {
        VStack {
            Text("Write down your thoughts:")
                .font(.headline)
                .padding(.top)

            // Use TextEditor for multi-line input
            TextEditor(text: $reflectionText)
                .border(Color.gray.opacity(0.5), width: 1)
                .padding()
                // **Accessibility Best Practice: Identifier for text input**
                .accessibilityIdentifier("REFLECTION_TEXTEDITOR")
                // Add a label for better context if needed
                .accessibilityLabel("Reflection Input Area")

            Spacer() // Pushes editor up
        }
        .padding()
        .navigationTitle("Reflection") // Example if used in NavigationView
    }
}

// MARK: - Previews (for Xcode Canvas)

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct QuoteView_Previews: PreviewProvider {
    static var previews: some View {
        // Add a placeholder image for preview if needed
        QuoteView()
            .preferredColorScheme(.dark) // Simulate potential contrast issues
    }
}

struct ReflectionView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectionView()
    }
}
