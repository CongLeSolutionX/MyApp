//
//  AskALe.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//


import SwiftUI
import Combine

struct CongLeSolutionXAnimatedView: View {

    // --- Configuration ---
    let fullText = "Ask a Lê"
    let imageName = "My-meme-original" // <-- !!! UPDATE THIS with your actual image name in Assets
    let animationInterval: TimeInterval = 0.15
    let fontSize: CGFloat = 45
    let textFont: Font = .system(size: 45.0, weight: .bold, design: .serif)
    let darkGrayColor = Color(white: 0.35)
    let grayColor = Color.gray
    let whiteColor = Color.white
    let imageSizeRatio: CGFloat = 0.8 // Adjust ratio of image height to font size
    let imageAppearDelay: TimeInterval = 0.2 // Delay before image fades in

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

        // Check if animation is complete (for text coloring only)
        if text.count == fullText.count {
            // When fully typed, make text white (before image appears)
            attrString.foregroundColor = whiteColor
        } else {
            // Animation in progress: Apply 3-part coloring (Dark Gray, Gray, White)
            let part1 = "Ask "
            let part2 = "a"
            let part3 = "Lê"

            // Dark Gray for "Cong"
            if let rangeInText = text.range(of: part1) {
                if let attrRange = attrString.range(of: String(text[rangeInText])) { attrString[attrRange].foregroundColor = darkGrayColor }
            } else if text.starts(with: "C") {
                 if let startIndexInAttr = attrString.range(of: String(text.prefix(1)))?.lowerBound { attrString[startIndexInAttr..<attrString.endIndex].foregroundColor = darkGrayColor }
            }

            // Gray for "Le"
            if let rangeInText = text.range(of: part2) {
                 if let attrRange = attrString.range(of: String(text[rangeInText])) { attrString[attrRange].foregroundColor = grayColor }
            } else if let lIndex = text.firstIndex(of: "L"), text.contains(part1) {
                 let partialPart2Substring = String(text.suffix(from: lIndex))
                 if let partialRange = attrString.range(of: partialPart2Substring) { attrString[partialRange].foregroundColor = grayColor }
            }

            // White for "SolutionX"
            if let rangeInText = text.range(of: part3) {
                 if let attrRange = attrString.range(of: String(text[rangeInText])) { attrString[attrRange].foregroundColor = whiteColor }
             } else if let sIndex = text.firstIndex(of: "S"), text.contains(part2) {
                 let partialPart3Substring = String(text.suffix(from: sIndex))
                 if let partialRange = attrString.range(of: partialPart3Substring) { attrString[partialRange].foregroundColor = whiteColor }
            }
        }
        // Final override: If complete, ensure whole text is white regardless of part logic runs
        if text.count == fullText.count {
             attrString.foregroundColor = whiteColor
        }

        return attrString
    }

    // --- Body ---
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HStack(spacing: 3) { // Increase spacing slightly for image
                let currentSubstring = String(fullText.prefix(displayedChars))
                Text(createAttributedString(for: currentSubstring))
                    .frame(minWidth: fontSize * CGFloat(fullText.count) * 0.5)
                    .fixedSize(horizontal: true, vertical: false)
                    .lineLimit(1)

                // --- Image/Placeholder Logic ---
                if displayedChars == fullText.count {
                    // Show the image AFTER animation completes
                    Image(imageName) // Use the image name variable
                        .resizable()
                        .scaledToFit()
                         // Control size relative to font, use height to maintain aspect ratio
                        .frame(height: fontSize * imageSizeRatio)
                        // Add transition for smooth appearance
                        .transition(.opacity.animation(.easeIn(duration: 0.4).delay(imageAppearDelay))) // Fade in with delay
                        .id("finalImage") // Add ID for transition stability
                } else {
                    // Placeholder during animation (keeps spacing consistent)
                    // Use a clear item with roughly the expected image width (or a fixed small width)
                    Rectangle()
                        .fill(Color.clear)
                        // Estimate width based on height and typical aspect ratio, or use fixed small width
                        .frame(width: (fontSize * imageSizeRatio) * 0.8, height: fontSize * imageSizeRatio)

                }
            }
            .padding(.horizontal)
        }
        .preferredColorScheme(.dark)
        .onReceive(timer) { _ in
            if displayedChars < fullText.count {
                 withAnimation(.linear(duration: 0.05)) { // Keep subtle char animation
                     displayedChars += 1
                 }
            } else {
                timer.upstream.connect().cancel() // Stop timer when done
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}

#Preview("CongLeSolutionXAnimatedView") {
    CongLeSolutionXAnimatedView()
}
