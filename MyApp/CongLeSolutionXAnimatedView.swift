////
////  CongLeSolutionXAnimatingView.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//import Combine
//
//struct CongLeSolutionXAnimatedView: View {
//
//    // --- Configuration ---
//    let fullText = "CongLeSolutionX" // UPDATED
//    let animationInterval: TimeInterval = 0.15
//    let fontSize: CGFloat = 45 // ADJUSTED for length
//    let textFont: Font = .system(size: 45.0, weight: .bold, design: .serif)
//    let darkGrayColor = Color(white: 0.35)
//    let whiteColor = Color.white
//    let cursorWidth: CGFloat = 2 // Can adjust if needed
//    let cursorHeightRatio: CGFloat = 0.9
//
//    // --- State ---
//    @State private var displayedChars: Int = 0
//    @State private var timerSubscription: Cancellable?
//
//    // --- Timer ---
//    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
//
//    // --- Dynamic AttributedString Logic (ADAPTED for CongLeSolutionX) ---
//    func createAttributedString(for text: String) -> AttributedString {
//        guard !text.isEmpty else {
//            return AttributedString("")
//        }
//
//        var attrString = AttributedString(text)
//        attrString.font = textFont // Apply base font
//
//        // Check if animation is complete
//        if text.count == fullText.count {
//            // Final state: All white
//            attrString.foregroundColor = whiteColor
//        } else {
//            // Animation in progress: Apply 3-part coloring
//
//            // Define the logical parts for "CongLeSolutionX"
//            let part1 = "Cong"
//            let part2 = "Le"
//            let part3 = "SolutionX"
//
//            // 1. Apply Dark Gray to visible "Cong" part
//            if let rangeInText = text.range(of: part1) {
//                // Full part1 ("Cong") is visible
//                if let attrRange = attrString.range(of: String(text[rangeInText])) {
//                    attrString[attrRange].foregroundColor = darkGrayColor
//                }
//            } else if text.starts(with: "C") {
//                // Handle partial part1 (e.g., "C", "Co", "Con")
//                // Find the range of the current substring starting with 'C'
//                 if let startIndexInAttr = attrString.range(of: String(text.prefix(1)))?.lowerBound {
//                    // Color from 'C' up to the end of the current text
//                    let rangeToColor = startIndexInAttr..<attrString.endIndex
//                    attrString[rangeToColor].foregroundColor = darkGrayColor
//                 }
//            }
//
//            // 2. Apply White to visible "Le" part
//            if let rangeInText = text.range(of: part2) {
//                // Full part2 ("Le") is visible
//                if let attrRange = attrString.range(of: String(text[rangeInText])) {
//                    attrString[attrRange].foregroundColor = whiteColor
//                }
//            } else if let lIndex = text.firstIndex(of: "L"), text.contains(part1) {
//                // Handle partial part2 ("L") only after part1 is complete
//                 let partialPart2Substring = String(text.suffix(from: lIndex))
//                 if let partialRange = attrString.range(of: partialPart2Substring) {
//                     attrString[partialRange].foregroundColor = whiteColor
//                 }
//            }
//
//            // 3. Apply White to visible "SolutionX" part
//            if let rangeInText = text.range(of: part3) {
//                // Full part3 ("SolutionX") is visible
//                if let attrRange = attrString.range(of: String(text[rangeInText])) {
//                    attrString[attrRange].foregroundColor = whiteColor
//                }
//             } else if let sIndex = text.firstIndex(of: "S"), text.contains(part2) {
//                // Handle partial part3 ("S", "So", "Sol"...) only after part2 is complete
//                 let partialPart3Substring = String(text.suffix(from: sIndex))
//                 if let partialRange = attrString.range(of: partialPart3Substring) {
//                     attrString[partialRange].foregroundColor = whiteColor
//                 }
//            }
//        }
//
//        // Optional: Kerning
//        // attrString.kern = -1 // Adjust if needed for the new font/size
//
//        return attrString
//    }
//
//    // --- Body ---
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//
//            HStack(spacing: 1) { // Adjust spacing if needed
//                let currentSubstring = String(fullText.prefix(displayedChars))
//                Text(createAttributedString(for: currentSubstring))
//                    // Estimate width dynamically - maybe slightly less aggressive factor?
//                    .frame(minWidth: fontSize * CGFloat(fullText.count) * 0.5)
//                    .fixedSize(horizontal: true, vertical: false) // Prevent wrap
//                    .lineLimit(1) // Explicitly prevent wrapping
//
//                // Cursor Logic (same as before)
//                if displayedChars == fullText.count {
//                    Rectangle()
//                        .fill(whiteColor)
//                        .frame(width: cursorWidth, height: fontSize * cursorHeightRatio)
//                        .transition(.opacity.animation(.easeIn.delay(0.1)))
//                } else {
//                     Rectangle()
//                        .fill(Color.clear) // Placeholder
//                        .frame(width: cursorWidth, height: fontSize * cursorHeightRatio)
//                }
//            }
//            .padding(.horizontal) // Add some padding if text gets too close to edge
//        }
//        .preferredColorScheme(.dark)
//        .onReceive(timer) { _ in
//            if displayedChars < fullText.count {
//                 withAnimation(.linear(duration: 0.05)) { // Subtle animation for char appearance
//                     displayedChars += 1
//                 }
//            } else {
//                timer.upstream.connect().cancel()
//            }
//        }
//        .onDisappear {
//            timer.upstream.connect().cancel()
//        }
//    }
//}
//
//// --- Preview ---
//struct CongLeSolutionXAnimatedView_Previews: PreviewProvider {
//    static var previews: some View {
//        CongLeSolutionXAnimatedView()
//    }
//}
