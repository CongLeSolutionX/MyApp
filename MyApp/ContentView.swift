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

// MARK: - Main Application Structure

@main
struct AccessibilityConceptsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Main ContentView (Navigation)

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Core Concepts Demo")) {
                    NavigationLink("Accessibility Elements", destination: AccessibilityElementsDemoView())
                    NavigationLink("Dynamic Type", destination: DynamicTypeDemoView())
                    NavigationLink("UI Accommodations", destination: UIAccommodationsDemoView())
                }

                Section(header: Text("Explanations")) {
                    Text("This app demonstrates key iOS accessibility features relevant to game development, based on the concepts used by the Apple Accessibility Plugin for Unity.")
                    Text("Explore each section to see how Labels, Traits, Values, Dynamic Type, and UI Accommodation settings work in a native SwiftUI context.")
                }
            }
            .navigationTitle("iOS Accessibility Concepts")
        }
    }
}

// MARK: - 1. Accessibility Elements Demo

struct AccessibilityElementsDemoView: View {
    @State private var card1Value: String = "Covered"
    @State private var card2Value: String = "Covered"
    @State private var card1IsFaceUp: Bool = false
    @State private var card2IsFaceUp: Bool = false

    let cardFaces = ["Two of Clubs", "Ace of Clubs", "King of Hearts", "Queen of Spades"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Eric's Card Game (SwiftUI Demo)")
                .font(.title)
                // Trait: Header - Provides semantic structure
                .accessibilityAddTraits(.isHeader)

            Text("Flip the cards.")
                // Trait: Static Text - Indicates non-interactive text content
                .accessibilityAddTraits(.isStaticText)

            HStack(spacing: 30) {
                // Card 1 Representation
                VStack {
                    Text("🃏") // Simple visual representation
                        .font(.system(size: 80))
                     Text(card1Value)
                        .font(.caption)
                }
                // Label: Describes the element clearly
                .accessibilityElement(children: .combine) // Combine children for single focus
                .accessibilityLabel("Card 1")
                // Value: Provides dynamic state read by VoiceOver
                .accessibilityValue(card1Value)
                // Hint: Optional guidance (not explicitly in docs, but good practice)
                .accessibilityHint("Represents the first card.")

                // Card 2 Representation
                VStack {
                     Text("🃏")
                        .font(.system(size: 80))
                    Text(card2Value)
                        .font(.caption)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Card 2")
                .accessibilityValue(card2Value)
                .accessibilityHint("Represents the second card.")
            }

            // Button Element
            Button("Flip") {
                flipCards()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            // Trait: Button - Automatically added by SwiftUI for Button type
            // Label: Uses the Button's text content by default
            // Hint: Explains the action
            .accessibilityHint("Tap to reveal two random cards.")

            Spacer()

            Text("Info:")
                .font(.headline)
            Text("Use VoiceOver to navigate. Notice how labels, values (Covered/Card Face), and traits (Static Text, Button) are announced.")
                .padding(.horizontal)
                .accessibilityAddTraits(.isStaticText)

        }
        .padding()
        .navigationTitle("Accessibility Elements")
    }

    func flipCards() {
        card1IsFaceUp.toggle()
        card2IsFaceUp.toggle()

        card1Value = card1IsFaceUp ? cardFaces.randomElement() ?? "Error" : "Covered"
        card2Value = card2IsFaceUp ? cardFaces.randomElement() ?? "Error" : "Covered"
    }
}

// MARK: - 2. Dynamic Type Demo

struct DynamicTypeDemoView: View {
    // Read the user's preferred content size category from the environment
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Dynamic Type adjusts text size based on user settings (Settings > Accessibility > Display & Text Size > Larger Text).")
                    .font(.footnote) // Uses predefined style, scales automatically

                Divider()

                Text("Caption Style Text")
                    .font(.caption) // Scales
                Text("Body Style Text")
                    .font(.body) // Scales
                Text("Title Style Text")
                    .font(.title) // Scales
                Text("Fixed Size Text (Avoid for Scalability)")
                    .font(.system(size: 16)) // Does NOT scale well

                Divider()

                Text("Conditional UI based on Text Size:")
                    .font(.headline) // Scales

                // Example: Show different content for accessibility sizes
                // This mimics the "Large Print Cards" concept
                if sizeCategory.isAccessibilityCategory {
                    // Show when text size is one of the larger accessibility sizes
                    LargePrintCardView()
                } else {
                    RegularCardView()
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Dynamic Type")
    }
}

// Helper Views for Dynamic Type Demo
struct RegularCardView: View {
     var body: some View {
        HStack {
            Text("🃏")
                 .font(.system(size: 50))
            Text("Regular Card Face Representation (Smaller Text Sizes)")
                 .font(.callout) // Scales
        }
        .padding()
        .border(Color.gray)
    }
}

struct LargePrintCardView: View {
    var body: some View {
        HStack {
             // Larger visual, different representation maybe
             Text("🅰️♣️")
                .font(.system(size: 70))
             Text("Large Print Card Face (Larger Accessibility Text Sizes)")
                 .font(.title2) // Larger base size, but still scales
        }
        .padding()
        .background(Color.yellow.opacity(0.3))
        .border(Color.orange, width: 2)
    }
}

// MARK: - 3. UI Accommodations Demo

struct UIAccommodationsDemoView: View {
    // Read accommodation settings from the environment
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.colorSchemeContrast) var colorSchemeContrast // Or accessibilityDifferentiateWithoutColor

    @State private var animatedValue: CGFloat = 0.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // --- Reduce Transparency ---
                Text("Reduce Transparency")
                    .font(.title2)
                Text("Changes background from translucent to opaque when enabled (Settings > Accessibility > Display & Text Size).")
                    .font(.caption)
                HStack {
                    Text("Sample Text")
                    Spacer()
                    Image(systemName: "star.fill")
                }
                .padding()
                // Conditional background based on the setting
                .background(reduceTransparency ? Color.gray : Color.blue.opacity(0.5))
                .cornerRadius(8)

                 Divider()

                // --- Increase Contrast ---
                // Note: SwiftUI handles some contrast automatically. This demonstrates manual adjustment.
                // accessibilityDifferentiateWithoutColor is also relevant here.
                 Text("Increase Contrast")
                    .font(.title2)
                 Text("Enhances legibility between foreground and background (Settings > Accessibility > Display & Text Size). May also trigger differentiate without color.")
                     .font(.caption)

                Text("Contrast Example")
                    .padding(10)
                    // Change appearance based on contrast preference
//                    .foregroundColor(colorSchemeContrast == .high ? .yellow : .white)
//                    .background(colorSchemeContrast == .high ? Color.black : Color.purple)
                    .cornerRadius(5)
                    // Optionally add borders for differentiation without color
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
//                            .stroke(colorSchemeContrast == .high ? Color.white : Color.clear, lineWidth: 2)
                    )

                 Divider()

                // --- Reduce Motion ---
                Text("Reduce Motion")
                    .font(.title2)
                Text("Disables or replaces animations when enabled (Settings > Accessibility > Motion).")
                     .font(.caption)

                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 50, height: 50)
                        // Apply offset animation ONLY if reduceMotion is OFF
                        .offset(y: animatedValue)

                    Spacer()

                    Button("Animate") {
                        if reduceMotion {
                             // Skip animation if Reduce Motion is ON
                             print("Reduce Motion is ON: Animation skipped.")
                             // Optionally reset position instantly
                             animatedValue = 0
                        } else {
                            // Perform animation only if Reduce Motion is OFF
                            withAnimation(.easeInOut(duration: 1.0)) {
                                animatedValue = animatedValue == 0 ? 50 : 0
                            }
                        }
                    }
                 }
            }
            .padding()
        }
        .navigationTitle("UI Accommodations")
    }
}

// MARK: - Previews (for Xcode Canvas)

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AccessibilityElementsDemoView_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityElementsDemoView()
    }
}

struct DynamicTypeDemoView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicTypeDemoView()
            .environment(\.sizeCategory, .large) // Preview with a specific size
    }
}

struct UIAccommodationsDemoView_Previews: PreviewProvider {
    static var previews: some View {
        UIAccommodationsDemoView()
            // Preview different accommodation settings
            // .environment(\.accessibilityReduceMotion, true)
            // .environment(\.accessibilityReduceTransparency, true)
//             .environment(\.colorSchemeContrast, .high)
    }
}
