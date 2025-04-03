//
//  CongLeSolutionXAnimatedView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI
import Combine

struct CongLeSolutionXAnimatedView: View {

    // --- Configuration ---
    let fullText = "CongLeSolutionX"
    let animationInterval: TimeInterval = 0.15
    let fontSize: CGFloat = 45
    let textFont: Font = .system(size: 45.0, weight: .bold, design: .serif)
    // Define Colors
    let darkGrayColor = Color(white: 0.35)
    let grayColor = Color.gray // ADDED Gray color
    let whiteColor = Color.white
    let cursorWidth: CGFloat = 2
    let cursorHeightRatio: CGFloat = 0.9

    // --- State ---
    @State private var displayedChars: Int = 0
    @State private var timerSubscription: Cancellable?

    // --- Timer ---
    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    // --- Dynamic AttributedString Logic (Colors UPDATED) ---
    func createAttributedString(for text: String) -> AttributedString {
        guard !text.isEmpty else {
            return AttributedString("")
        }

        var attrString = AttributedString(text)
        attrString.font = textFont // Apply base font

        // Check if animation is complete
        if text.count == fullText.count {
            // Final state: All white
            attrString.foregroundColor = whiteColor
        } else {
            // Animation in progress: Apply 3-part coloring (Dark Gray, Gray, White)

            // Define the logical parts for "CongLeSolutionX"
            let part1 = "Cong"
            let part2 = "Le"
            let part3 = "SolutionX"

            // 1. Apply Dark Gray to visible "Cong" part
            if let rangeInText = text.range(of: part1) {
                if let attrRange = attrString.range(of: String(text[rangeInText])) {
                    attrString[attrRange].foregroundColor = darkGrayColor // Dark Gray
                }
            } else if text.starts(with: "C") {
                 if let startIndexInAttr = attrString.range(of: String(text.prefix(1)))?.lowerBound {
                    let rangeToColor = startIndexInAttr..<attrString.endIndex
                    attrString[rangeToColor].foregroundColor = darkGrayColor // Dark Gray
                 }
            }

            // 2. Apply Gray to visible "Le" part (UPDATED COLOR)
            if let rangeInText = text.range(of: part2) {
                if let attrRange = attrString.range(of: String(text[rangeInText])) {
                    attrString[attrRange].foregroundColor = grayColor // Gray
                }
            } else if let lIndex = text.firstIndex(of: "L"), text.contains(part1) {
                 let partialPart2Substring = String(text.suffix(from: lIndex))
                 if let partialRange = attrString.range(of: partialPart2Substring) {
                     attrString[partialRange].foregroundColor = grayColor // Gray
                 }
            }

            // 3. Apply White to visible "SolutionX" part (remains White)
            if let rangeInText = text.range(of: part3) {
                 if let attrRange = attrString.range(of: String(text[rangeInText])) {
                     attrString[attrRange].foregroundColor = whiteColor // White
                 }
             } else if let sIndex = text.firstIndex(of: "S"), text.contains(part2) {
                 let partialPart3Substring = String(text.suffix(from: sIndex))
                 if let partialRange = attrString.range(of: partialPart3Substring) {
                     attrString[partialRange].foregroundColor = whiteColor // White
                 }
            }
        }

        // Optional: Kerning
        // attrString.kern = -1

        return attrString
    }

    // --- Body ---
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HStack(spacing: 1) {
                let currentSubstring = String(fullText.prefix(displayedChars))
                Text(createAttributedString(for: currentSubstring))
                    .frame(minWidth: fontSize * CGFloat(fullText.count) * 0.5)
                    .fixedSize(horizontal: true, vertical: false)
                    .lineLimit(1)

                // Cursor Logic (same as before)
                if displayedChars == fullText.count {
                    Rectangle()
                        .fill(whiteColor)
                        .frame(width: cursorWidth, height: fontSize * cursorHeightRatio)
                        .transition(.opacity.animation(.easeIn.delay(0.1)))
                } else {
                     Rectangle()
                        .fill(Color.clear) // Placeholder
                        .frame(width: cursorWidth, height: fontSize * cursorHeightRatio)
                }
            }
            .padding(.horizontal)
        }
        .preferredColorScheme(.dark)
        .onReceive(timer) { _ in
            if displayedChars < fullText.count {
                 withAnimation(.linear(duration: 0.05)) {
                     displayedChars += 1
                 }
            } else {
                timer.upstream.connect().cancel()
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}

// --- Preview ---
struct CongLeSolutionXAnimatedView_Previews: PreviewProvider {
    static var previews: some View {
        CongLeSolutionXAnimatedView()
    }
}
