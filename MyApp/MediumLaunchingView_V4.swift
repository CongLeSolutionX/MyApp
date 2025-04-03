//
//  MediumLaunchingView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI
import Combine

struct MediumAnimatedLaunchView3Part: View {

    // --- Configuration ---
    let fullText = "Medium"
    let animationInterval: TimeInterval = 0.15
    let fontSize: CGFloat = 90
    let textFont: Font = .system(size: 90.0, weight: .bold, design: .serif)
    let darkGrayColor = Color(white: 0.35)
    let whiteColor = Color.white
    let cursorWidth: CGFloat = 3
    let cursorHeightRatio: CGFloat = 0.9

    // --- State ---
    @State private var displayedChars: Int = 0
    @State private var timerSubscription: Cancellable?

    // --- Timer ---
    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    // --- Dynamic AttributedString Logic (UPDATED for 3 parts) ---
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
            // Animation in progress: Apply 3-part coloring

            // Define the logical parts
            let part1 = "Me"
            let part2 = "di"
            let part3 = "um"

            // Apply Dark Gray to visible "Me" part
            // Find the actual occurrence of part1 within the current `text`
            if let rangeInText = text.range(of: part1) {
                // Find the corresponding range in the AttributedString
                if let attrRange = attrString.range(of: String(text[rangeInText])) {
                    attrString[attrRange].foregroundColor = darkGrayColor
                }
             } else if text.starts(with: "M") { // Handle just "M"
                 if let attrRange = attrString.range(of: "M") {
                    attrString[attrRange].foregroundColor = darkGrayColor
                }
             }

            // Apply White to visible "di" part
            if let rangeInText = text.range(of: part2) {
                if let attrRange = attrString.range(of: String(text[rangeInText])) {
                    attrString[attrRange].foregroundColor = whiteColor
                }
            } else if let dIndex = text.firstIndex(of: "d"), text.firstIndex(of: "M") != nil || text.firstIndex(of: "e") != nil {
                // Handle partial 'di' (e.g., when text is "Med")
                 let partialPart2Substring = String(text.suffix(from: dIndex))
                  if let partialRange = attrString.range(of: partialPart2Substring) {
                      attrString[partialRange].foregroundColor = whiteColor
                  }
            }

            // Apply White to visible "um" part
            if let rangeInText = text.range(of: part3) {
                 if let attrRange = attrString.range(of: String(text[rangeInText])) {
                     attrString[attrRange].foregroundColor = whiteColor
                 }
            } else if let uIndex = text.firstIndex(of: "u"), text.firstIndex(of: "d") != nil || text.firstIndex(of: "i") != nil {
                 // Handle partial 'um' (e.g., when text is "Mediu")
                 let partialPart3Substring = String(text.suffix(from: uIndex))
                 if let partialRange = attrString.range(of: partialPart3Substring) {
                     attrString[partialRange].foregroundColor = whiteColor
                 }
            }
        }

        // Optional: Kerning
        // attrString.kern = -1.5

        return attrString
    }

    // --- Body ---
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HStack(spacing: 2) {
                let currentSubstring = String(fullText.prefix(displayedChars))
                Text(createAttributedString(for: currentSubstring))
                    .frame(minWidth: fontSize * CGFloat(fullText.count) * 0.6) // Estimate width
                    .fixedSize(horizontal: true, vertical: false) // Prevent wrap

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
        }
        .preferredColorScheme(.dark)
        .onReceive(timer) { _ in
            if displayedChars < fullText.count {
                 displayedChars += 1
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
struct MediumAnimatedLaunchView3Part_Previews: PreviewProvider {
    static var previews: some View {
        MediumAnimatedLaunchView3Part()
    }
}
