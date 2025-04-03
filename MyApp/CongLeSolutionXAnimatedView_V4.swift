////
////  CongLeSolutionXAnimatedView_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//import SwiftUI
//import Combine
//
//struct CongLeSolutionXAnimatedView: View {
//
//    // --- Configuration ---
//    let fullText = "CongLeSolutionX"
//    let imageName = "My-meme-original" // <-- !!! UPDATE THIS with your actual image name in Assets
//    let animationInterval: TimeInterval = 0.15
//    let fontSize: CGFloat = 45
//    let textFont: Font = .system(size: 0.15, weight: .bold, design: .serif)
//    let darkGrayColor = Color(white: 0.35)
//    let grayColor = Color.gray
//    let whiteColor = Color.white
//    let imageSizeRatio: CGFloat = 0.8
//    let imageAppearDelay: TimeInterval = 0.2
//    let verticalSpacing: CGFloat = 5
//
//    // --- State ---
//    @State private var displayedChars: Int = 0
//    @State private var timerSubscription: Cancellable?
//
//    // --- Timer ---
//    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
//
//    // --- Dynamic AttributedString Logic (REVISED FOR VISIBILITY) ---
//    func createAttributedString(for text: String) -> AttributedString {
//        guard !text.isEmpty else {
//            return AttributedString("")
//        }
//
//        var attrString = AttributedString(text)
//        attrString.font = textFont
//
//        // --- Revised Coloring Logic ---
//        // 1. **** SET VISIBLE DEFAULT COLOR FIRST ****
//        //    Make all characters visible by default (e.g., white)
//        attrString.foregroundColor = whiteColor
//
//        // 2. Apply specific part colors IF animation is NOT complete
//        if text.count < fullText.count { // Only apply overrides during animation
//             let part1 = "Cong"
//             let part2 = "Le"
//             // Part 3 ("SolutionX") will naturally remain the default color (white)
//
//             // Apply Dark Gray for "Cong" (overwrites the default white)
//             if let rangeInText = text.range(of: part1) {
//                 if let attrRange = attrString.range(of: String(text[rangeInText])) {
//                    attrString[attrRange].foregroundColor = darkGrayColor
//                 }
//             } else if text.starts(with: "C") {
//                  // Handle partial like "C", "Co", "Con"
//                  if let startIndexInAttr = attrString.range(of: String(text.prefix(1)))?.lowerBound {
//                      let rangeToColor = startIndexInAttr..<attrString.endIndex
//                      attrString[rangeToColor].foregroundColor = darkGrayColor
//                   }
//             }
//
//             // Apply Gray for "Le" (overwrites the default white)
//             if let rangeInText = text.range(of: part2) {
//                  if let attrRange = attrString.range(of: String(text[rangeInText])) {
//                    attrString[attrRange].foregroundColor = grayColor
//                  }
//             } else if let lIndex = text.firstIndex(of: "L"), text.contains(part1) {
//                  // Handle partial like "L" only after "Cong" is fully visible
//                  let partialPart2Substring = String(text.suffix(from: lIndex))
//                  if let partialRange = attrString.range(of: partialPart2Substring) {
//                      attrString[partialRange].foregroundColor = grayColor
//                  }
//             }
//             // No need for Part 3 logic as it uses the default white
//        }
//        // When text.count == fullText.count, the loop above is skipped,
//        // and the text remains the default color (white).
//
//        return attrString
//    }
//
//    // --- Body ---
//       var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//
//            VStack(spacing: verticalSpacing) {
//                // 1. Animated Text
//                let currentSubstring = String(fullText.prefix(displayedChars))
//                // *** Add a print statement for debugging if needed ***
//                // let _ = print("Substring: \(currentSubstring), Chars: \(displayedChars)")
//                Text(createAttributedString(for: currentSubstring))
//                     // Maybe add minHeight to ensure it has space? Though unlikely the issue.
//                    // .frame(minHeight: fontSize * 1.2) // Optional: Test if layout gives it no height
//                    .fixedSize(horizontal: false, vertical: true)
//                    .lineLimit(1)
//
//                // 2. Conditional Placeholder or Image below the text
//                let imageHeight = fontSize * imageSizeRatio
//                if displayedChars == fullText.count {
//                    // Show Image AFTER animation completes
//                    Image(imageName)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: imageHeight) // Control image size
//                        .transition(.opacity.animation(.easeIn(duration: 0.4).delay(imageAppearDelay))) // Fade in
//                        .id("finalImage") // ID for transition stability
//                } else {
//                    // Placeholder BELOW text during animation
//                    Color.clear
//                        .frame(height: imageHeight) // Use same height as image
//                }
//            }
//            .padding(.horizontal)
//        }
//        .preferredColorScheme(.dark)
//        .onReceive(timer) { _ in
//            if displayedChars < fullText.count {
//                 withAnimation(.linear(duration: 0.05)) {
//                     displayedChars += 1
//                 }
//            } else {
//                 // Stop the timer only once
//                 if timerSubscription == nil { // Prevent multiple cancellations if timer fires again
//                    timerSubscription = EmptyCancellable() // Placeholder to mark as stopped
//                    timer.upstream.connect().cancel()
//                    // print("Timer stopped") // Debug print
//                }
//            }
//        }
//         .onAppear { // Reset state if the view appears again
//             displayedChars = 0
//             timerSubscription = nil // Ensure timer can restart
//             // Reconnect timer logic might be needed if it auto-cancels strongly on disappear
//         }
//        .onDisappear {
//            // Ensure timer is cancelled when view disappears
//            timer.upstream.connect().cancel()
//            timerSubscription = EmptyCancellable() // Mark as stopped
//            // print("Timer cancelled on disappear") // Debug print
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
//
//// Helper for timer cancellation tracking if needed more robustly
//class EmptyCancellable: Cancellable {
//    func cancel() {}
//}
