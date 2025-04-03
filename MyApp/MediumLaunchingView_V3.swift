////
////  MediumLaunchingView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//import Combine
//
//struct MediumAnimatedLaunchViewFinalWhite: View {
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
//    @State private var timerSubscription: Cancellable?
//
//    // --- Timer Publisher ---
//    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
//
//    // --- Dynamic AttributedString Logic (UPDATED) ---
//    func createAttributedString(for text: String) -> AttributedString {
//        guard !text.isEmpty else {
//            return AttributedString("")
//        }
//
//        var attrString = AttributedString(text)
//        attrString.font = textFont // Apply base font
//
//        // --- NEW: Check if animation is complete ---
//        if text.count == fullText.count {
//            // Animation complete: Make the entire text white
//            attrString.foregroundColor = whiteColor
//        } else {
//            // Animation in progress: Apply gray/white coloring
//            let meRange = text.range(of: "Me")
//            let diumRange = text.range(of: "dium")
//
//            // Apply dark gray to the portion of "Me" that is visible
//             if let actualMeRange = meRange {
//                if let effectiveRange = attrString.range(of: text[actualMeRange]) {
//                     attrString[effectiveRange].foregroundColor = darkGrayColor
//                }
//             } else if text.starts(with: "M") { // Handle just "M"
//                 if let mRange = attrString.range(of: "M") {
//                     attrString[mRange].foregroundColor = darkGrayColor
//                 }
//             }
//
//            // Apply white to the portion of "dium" that is visible
//             if let actualDiumRange = diumRange {
//                 if let effectiveRange = attrString.range(of: text[actualDiumRange]) {
//                     attrString[effectiveRange].foregroundColor = whiteColor
//                 }
//             } else if let dIndex = text.firstIndex(of: "d") { // Handle when "dium" starts appearing
//                 let partialDiumSubstring = String(text.suffix(from: dIndex))
//                 if let partialRange = attrString.range(of: partialDiumSubstring) {
//                      attrString[partialRange].foregroundColor = whiteColor
//                 }
//             }
//        }
//
//        // Optional: Apply negative kerning if desired
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
//                let currentSubstring = String(fullText.prefix(displayedChars))
//                Text(createAttributedString(for: currentSubstring))
//                    .frame(minWidth: fontSize * CGFloat(fullText.count) * 0.6) // Estimate width
//                    .fixedSize(horizontal: true, vertical: false) // Prevent line wrapping
//
//                // 4. Simulated Cursor (only when animation is complete)
//                if displayedChars == fullText.count {
//                    Rectangle()
//                        .fill(whiteColor)
//                        .frame(width: cursorWidth, height: fontSize * cursorHeightRatio)
//                        .transition(.opacity.animation(.easeIn.delay(0.1))) // Cursor appears after text turns white
//                } else {
//                    // Placeholder to maintain layout consistency
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
//            if displayedChars < fullText.count {
//                 // Note: Avoid 'withAnimation' here if you want the color
//                 // change to be instant when the last character appears.
//                 // Using withAnimation would try to animate the color change too.
//                 displayedChars += 1
//            } else {
//                timer.upstream.connect().cancel() // Stop timer
//            }
//        }
//        .onDisappear {
//            timer.upstream.connect().cancel()
//        }
//    }
//}
//
//// --- Preview ---
//struct MediumAnimatedLaunchViewFinalWhite_Previews: PreviewProvider {
//    static var previews: some View {
//        MediumAnimatedLaunchViewFinalWhite()
//    }
//}
