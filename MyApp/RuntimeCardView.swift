////
////  RuntimeCardView.swift
////  MyApp
////
////  Created by Cong Le on 3/28/25.
////
//
//import SwiftUI
//
//// Define custom colors based on the CSS hex codes
//extension Color {
//    static let cardBackground = Color(hex: "#262626")
//    static let cardBorder = Color(hex: "#3F3F40")
//    static let primaryText = Color(hex: "#FFFFFF") // White
//    static let secondaryText = Color(hex: "#BDBFB7") // Light Gray
//    static let highlightText = Color(hex: "#2CAD3D") // Green
//}
//
//// Helper to initialize Color from hex string
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0) // Default to black if invalid
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
//
//// The main view replicating the card design
//struct RuntimeCardView: View {
//    // --- Data (Hardcoded for now, representing local storage) ---
//    let runtimeValue: Int = 42
//    let runtimeUnit: String = "ms"
//    let beatPercentage: Double = 92.42
//    let language: String = "JavaScript"
//
//    // --- Body ---
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) { // Adjust spacing as needed
//            // --- Header ---
//            HStack {
//                Text("Runtime")
//                    .font(.system(size: 15)) // Match footer CSS font size
//                    .foregroundColor(.secondaryText)
//
//                Spacer() // Pushes "Details" to the right
//
//                Button {
//                    // Action for the Details button
//                    print("Details tapped!")
//                } label: {
//                    Text("Details")
//                        .font(.system(size: 15))
//                        .foregroundColor(.secondaryText)
//                }
//                .buttonStyle(.plain) // Removes default button styling
//            }
//
//            // --- Main Content ---
//            HStack(alignment: .firstTextBaseline, spacing: 4) {
//                Text("\(runtimeValue)")
//                    .font(.system(size: 24, weight: .semibold)) // Simulates font-weight: 600
//                    .foregroundColor(.primaryText) // White
//
//                Text(runtimeUnit)
//                    .font(.system(size: 20, weight: .light)) // Simulates font-weight: 100
//                    .foregroundColor(.secondaryText) // Light Gray
//                    // Adjust baseline offset if alignment isn't perfect
//                    // .baselineOffset(-2)
//            }
//
//            // --- Footer ---
//            HStack(alignment: .center, spacing: 5) { // Matches gap: 5px
//                Text("Beats \(String(format: "%.2f%%", beatPercentage))")
//                    .font(.system(size: 15, weight: .semibold)) // Matches font-size and font-weight: 600
//                    .foregroundColor(.highlightText) // Green
//
//                Text("of users with \(language)")
//                    .font(.system(size: 15)) // Matches font-size
//                    .foregroundColor(.primaryText) // White
//            }
//        }
//        .padding(20) // Matches margin: 20px
//        .frame(width: 350, height: 150, alignment: .topLeading) // Matches fixed size, aligns content top-left
//        .background(Color.cardBackground) // Matches background: #262626
//        .cornerRadius(10) // Matches border-radius: 10px
//        .overlay( // Adds the border
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.cardBorder, lineWidth: 1) // Matches border: 1px solid #3F3F40
//        )
//    }
//}
//
//// --- Preview Provider ---
//struct RuntimeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        RuntimeCardView()
//            .padding() // Add padding around the card in the preview
//            .background(Color.gray) // Contextual background for the preview
//    }
//}
//
//// --- App Entry Point (Optional, for running directly) ---
//// You would typically use this view within a larger app structure.
//// @main
//// struct RuntimeCardApp: App {
////     var body: some Scene {
////         WindowGroup {
////             ContentView() // Where ContentView might contain RuntimeCardView
////         }
////     }
//// }
////
//// struct ContentView: View {
////     var body: some View {
////         RuntimeCardView()
////     }
//// }
