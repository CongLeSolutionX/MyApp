////
////  CSSCardView.swift
////  MyApp
////
////  Created by Cong Le on 3/28/25.
////
//
//import SwiftUI
//
//// Extension to allow initializing Color from HEX strings
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
//            (a, r, g, b) = (255, 0, 0, 0) // Default to black
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//
//    // Define the specific colors from the CSS
//    static let cardBackground = Color(hex: "#24233b")
//    static let codeBackground = Color(red: 73/255, green: 70/255, blue: 92/255) // rgb(73, 70, 92)
//    static let shadowColor = Color(red: 73/255, green: 70/255, blue: 92/255) // rgb(73, 70, 92)
//    static let controlRed = Color(hex: "#ff605c")
//    static let controlYellow = Color(hex: "#ffbd44")
//    static let controlGreen = Color(hex: "#00ca4e")
//}
//
////// The Main App Structure
////@main
////struct CodeCardApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
//
//// The Content View holding the Card
//struct ContentView: View {
//    var body: some View {
//        // Center the card on the screen
//        ZStack {
//            // Optional: Add a background to the whole screen if desired
//             Color.gray.opacity(0.3).ignoresSafeArea()
//            
//            CSSCardView()
//        }
//    }
//}
//
//// The View representing the CSS Card
//struct CSSCardView: View {
//    // State variable to hold the CSS code (Local Storage)
//    @State private var cssCode: String = """
//    .card {
//      width: 300px;
//      height: 400px;
//      margin: 0 auto;
//      background-color: #24233b;
//      border-radius: 8px;
//      z-index: 1;
//      box-shadow: 0px 10px 10px rgb(73, 70, 92);
//      transition: 0.5s;
//    }
//
//    .card:hover {
//      transform: translateY(-7px);
//      box-shadow: 0px 10px 10px black;
//    }
//
//    .top {
//      display: flex;
//      align-items: center;
//      padding-left: 10px;
//    }
//    """ // Truncated for brevity, add the rest if needed
//
//    var body: some View {
//        VStack(spacing: 5) { // Reduced spacing between header and code area
//            // Top Bar (Window Controls + Title)
//            HStack {
//                // Window Controls
//                HStack(spacing: 8) { // Spacing between circles
//                    Circle()
//                        .fill(Color.controlRed)
//                        .frame(width: 12, height: 12)
//                    Circle()
//                        .fill(Color.controlYellow)
//                        .frame(width: 12, height: 12)
//                    Circle()
//                        .fill(Color.controlGreen)
//                        .frame(width: 12, height: 12)
//                }
//                .padding(.leading, 12) // Padding from left edge
//
//                Spacer() // Pushes title away from controls
//
//                // Title
//                Text("style.css")
//                    .font(.system(size: 14, weight: .medium)) // Adjusted font size/weight
//                    .foregroundColor(.white.opacity(0.8)) // Slightly muted white
//
//                Spacer() // Centers title (roughly)
//
//                 // Add placeholder elements matching the width of controls for better centering
//                 // Adjust width/opacity if needed for perfect balance
//                 HStack(spacing: 8) {
//                     Circle().fill(.clear).frame(width: 12, height: 12)
//                     Circle().fill(.clear).frame(width: 12, height: 12)
//                     Circle().fill(.clear).frame(width: 12, height: 12)
//                 }
//                 .padding(.trailing, 12)
//                 .opacity(0) // Make them invisible
//
//            }
//            .padding(.top, 10) // Padding from top edge
//
//            // Code Area
//            TextEditor(text: $cssCode)
//                .font(.system(size: 13, design: .monospaced)) // Monospaced font for code
//                .foregroundColor(.white)
//                // Apply background styling
//                .scrollContentBackground(.hidden) // Necessary for background color in newer SwiftUI
//                .background(Color.codeBackground)
//                .cornerRadius(5) // Inner corner radius for the text editor
//                .padding(.horizontal, 15) // Horizontal padding for the code container
//                .padding(.bottom, 15) // Bottom padding for the code container
//
//        }
//        .frame(width: 300, height: 400) // Card dimensions
//        .background(Color.cardBackground) // Card background color
//        .cornerRadius(8) // Card corner radius
//        .shadow(color: Color.shadowColor.opacity(0.5), radius: 10, x: 0, y: 10) // Card shadow
//    }
//}
//
//// Preview Provider for Xcode Canvas
//struct CSSCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
