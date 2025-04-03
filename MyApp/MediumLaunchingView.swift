////
////  MediumLaunchingView.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//
//struct MediumLaunchView: View {
// 
//    // --- Configuration ---
//    let displayText = "Medium"
////    let fontSize: CGFloat = 90.0
//    // Using system serif, adjust font name if a specific custom font is known
//    let textFont: Font = .system(size: 90.0, weight: .bold, design: .serif)
//    // Adjusted gray to better match the screenshot's dark gray
//    let darkGrayColor = Color(white: 0.35)
//    let whiteColor = Color.white
//    let cursorWidth: CGFloat = 3
//    let cursorHeightRatio: CGFloat = 0.9 // Relative to font size
//
//    // --- AttributedString for Multi-Color Text ---
//    var attributedDisplayText: AttributedString {
//        var attrString = AttributedString(displayText)
//
//        // Apply the base font to the entire string
//        attrString.font = textFont
//        // Apply kerning if needed for visual adjustment
//        // attrString.kern = -1.5 // Example: Adjust letter spacing if necessary
//
//        // Color "Me" part
//        if let rangeMe = attrString.range(of: "Me") {
//            attrString[rangeMe].foregroundColor = darkGrayColor
//        }
//
//        // Color "dium" part
//        if let rangeDium = attrString.range(of: "dium") {
//            attrString[rangeDium].foregroundColor = whiteColor
//        }
//
//        return attrString
//    }
//
//    // --- Body ---
//    var body: some View {
//        ZStack {
//            // 1. Background
//            Color.black
//                .ignoresSafeArea() // Extend to screen edges
//
//            // 2. Content (Text + Cursor)
//            HStack(spacing: 2) { // Adjust spacing between text and cursor
//                // 3. Styled Text
//                Text(attributedDisplayText)
//
//                // 4. Simulated Cursor
//                Rectangle()
//                    .fill(whiteColor)
//                    .frame(width: cursorWidth, height: 90.0 * cursorHeightRatio)
//            }
//            // Optional: Add padding if needed to position away from edges
//            // .padding()
//        }
//        // 5. Ensure light status bar content for dark background
//        .preferredColorScheme(.dark)
//    }
//}
//
//// --- Preview ---
//struct MediumLaunchView_Previews: PreviewProvider {
//    static var previews: some View {
//        MediumLaunchView()
//    }
//}
