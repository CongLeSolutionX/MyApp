////
////  MediumLaunchingView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//import Combine // Import Combine for Timer publisher
//
//struct MediumAnimatedLaunchView: View {
//
//    // --- Configuration ---
//    let fullText = "Medium"
//    let animationInterval: TimeInterval = 0.15 // Seconds between characters
//    let fontSize: CGFloat = 90
//    let textFont: Font = .system(size: 90.0, weight: .bold, design: .serif)
//    let darkGrayColor = Color(white: 0.35)
//    let whiteColor = Color.white
//    let cursorWidth: CGFloat = 3
//    let cursorHeightRatio: CGFloat = 0.9
//
//    // --- State ---
//    @State private var displayedChars: Int = 0
//    @State private var timerSubscription: Cancellable? // To hold the timer subscription
//
//    // --- Timer Publisher ---
//    // Creates a timer that fires every `animationInterval` seconds on the main run loop
//    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
//
//    // --- Dynamic AttributedString Logic ---
//    func createAttributedString(for text: String) -> AttributedString {
//        guard !text.isEmpty else {
//            return AttributedString("") // Return empty if no text yet
//        }
//
//        var attrString = AttributedString(text)
//        attrString.font = textFont // Apply base font to the visible part
//
//        // Determine ranges based on the *current* visible text
//        let meRange = text.range(of: "Me")
//        let diumRange = text.range(of: "dium") // This might be partial
//
//        // Apply dark gray to the portion of "Me" that is visible
//        if let actualMeRange = meRange {
//            let effectiveRange = attrString.range(of: text[actualMeRange])!
//            attrString[effectiveRange].foregroundColor = darkGrayColor
//        } else if text.starts(with: "M") { // Handle just "M"
//             let mRange = attrString.range(of: "M")!
//             attrString[mRange].foregroundColor = darkGrayColor
//        }
//
//        // Apply white to the portion of "dium" that is visible
//         if let actualDiumRange = diumRange {
//             let effectiveRange = attrString.range(of: text[actualDiumRange])!
//             attrString[effectiveRange].foregroundColor = whiteColor
//         } else if let dIndex = text.firstIndex(of: "d") { // Handle when "dium" starts appearing
//            let partialDiumSubstring = String(text.suffix(from: dIndex))
//            if let partialRange = attrString.range(of: partialDiumSubstring) {
//                 attrString[partialRange].foregroundColor = whiteColor
//            }
//         }
//
//        // Optional: Apply negative kerning if desired for specific fonts
//        // attrString.kern = -1.5
//
//        return attrString
//    }
//
//    // --- Body ---
//    var body: some View {
//        ZStack {
//            // 1. Background
//            Color.black
//                .ignoresSafeArea()
//
//            // 2. Content (Text + Conditional Cursor)
//            HStack(spacing: 2) {
//                // 3. Dynamically Styled Text
//                // Calculate the substring based on the current state
//                let currentSubstring = String(fullText.prefix(displayedChars))
//                // Create and display the attributed string for the substring
//                Text(createAttributedString(for: currentSubstring))
//                    // Add a minimum width to prevent layout shifts as text grows
//                     .frame(minWidth: fontSize * CGFloat(fullText.count) * 0.6) // Estimate width
//                     .fixedSize(horizontal: true, vertical: false) // Prevent line wrapping
//
//                // 4. Simulated Cursor (only when animation is complete)
//                if displayedChars == fullText.count {
//                    Rectangle()
//                        .fill(whiteColor)
//                        .frame(width: cursorWidth, height: fontSize * cursorHeightRatio)
//                        // Add a transition for the cursor appearance
//                        .transition(.opacity.animation(.easeIn.delay(0.1)))
//                } else {
//                    // Placeholder to maintain layout consistency during animation
//                     Rectangle()
//                        .fill(Color.clear) // Invisible
//                        .frame(width: cursorWidth, height: fontSize * cursorHeightRatio)
//                }
//            }
//            // Optional padding
//            // .padding()
//        }
//        .preferredColorScheme(.dark)
//        // 5. Timer Receiver
//        .onReceive(timer) { _ in
//            // Increment character count if not yet complete
//            if displayedChars < fullText.count {
//                // Using withAnimation adds a subtle fade, but might not be desired
//                // withAnimation {
//                     displayedChars += 1
//                // }
//            } else {
//                // Animation complete, stop the timer
//                timer.upstream.connect().cancel()
//            }
//        }
//        // Ensure timer stops if the view disappears
//        .onDisappear {
//            timer.upstream.connect().cancel()
//        }
//    }
//}
//
//// --- Preview ---
//struct MediumAnimatedLaunchView_Previews: PreviewProvider {
//    static var previews: some View {
//        MediumAnimatedLaunchView()
//    }
//}
