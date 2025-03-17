////
////  MatrixRainView.swift
////  MyApp
////
////  Created by Cong Le on 3/17/25.
////
//
////
////  MatrixView.swift
////  MyApp
////
////  Created by Cong Le on 3/17/25.
////
//
//import SwiftUI
//
//struct MatrixView: View {
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // Background
//                Color.black
//                    .ignoresSafeArea()
//
//                // Matrix Effect
//                MatrixRainView(size: geometry.size)
//
//                // Apple Logo Overlay (with reduced opacity rain)
//                AppleLogoView(size: geometry.size)
//            }
//        }
//    }
//}
//
//// View to create the Matrix rain effect
//struct MatrixRainView: View {
//    let size: CGSize
//
//    var body: some View {
//        HStack(spacing: 0) {
//            ForEach(0..<Int(size.width / 20), id: \.self) { _ in // Adjust 20 for column width
//                VStack(spacing: 0) {
//                    ForEach(0..<Int(size.height / 20), id: \.self) { _ in // Adjust 20 for row height
//                        MatrixCharacterView() // Using the custom view
//                    }
//                }
//            }
//        }
//    }
//}
//
//// Custom view to represent a single Matrix character
//struct MatrixCharacterView: View {
//    let characters = ["0", "1"]
//    @State private var character = "0"
//    @State private var foregroundColor: Color = .green
//    @State private var opacity: Double = 1.0
//    @State private var fontSize: CGFloat = 20
//
//    var body: some View {
//        Text(character)
//            .font(.system(size: fontSize, weight: .bold))
//            .foregroundColor(foregroundColor)
//            .opacity(opacity)
//            .onAppear {
//                // Initial random values
//                character = characters.randomElement() ?? "0"
//                randomizeValues()
//
//                // Continuous updates for animation
//                Timer.scheduledTimer(withTimeInterval: Double.random(in: 0.1...0.6), repeats: true) { _ in
//                    randomizeValues()
//                }
//            }
//    }
//
//    func randomizeValues() {
//        character = characters.randomElement() ?? "0"
//        withAnimation(.easeInOut(duration: 0.5)) {
//            opacity = Double.random(in: 0.2...1.0) // Vary opacity
//            fontSize = CGFloat.random(in: 10...20)  // Vary size
//        }
//
//        // Randomly choose a shade of green
//        let greenShades: [Color] = [.green, .init(white: 0.7, opacity: 0.8), .init(white: 0.6, opacity: 0.7), .init(white: 0.5, opacity: 0.6)]
//        foregroundColor = greenShades.randomElement() ?? .green
//    }
//}
//
//// View for creating the Apple logo and the semi-transparent overlay
//struct AppleLogoView: View {
//    let size: CGSize
//
//    var body: some View {
//        ZStack {
//            // Solid Green Apple Logo
//            Image(systemName: "apple.logo")
//                .resizable()
//                .scaledToFit()
//                .foregroundColor(.green)
//                .frame(width: size.width * 0.4, height: size.width * 0.4) // Adjust size as needed
//                .position(x: size.width / 2, y: size.height / 2.1) // Center the logo, slightly above center
//
//            // Semi-transparent Matrix Rain (for overlay effect)
//            MatrixRainView(size: size)
//                .opacity(0.3) // Reduced opacity for overlay
//                .mask(
//                    Image(systemName: "apple.logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: size.width * 0.4, height: size.width * 0.4)
//                )
//                .position(x: size.width / 2, y: size.height / 2.1)
//        }
//    }
//}
//
//// MARK: - Previews
////struct MatrixView_Previews: PreviewProvider {
////    static var previews: some View {
////        MatrixCharacterView()
////        AppleLogoView(size: .init(width: CGFloat(400), height: 800))
////        MatrixRainView(size: .init(width: CGFloat(400), height: 800))
////    }
////}
//
//#Preview("Matrix Character View") {
//    MatrixCharacterView()
//}
//
//#Preview("Apple Logo View") {
//    AppleLogoView(size: .init(width: CGFloat(400), height: 800))
//}
//
//#Preview("Matrix Rain View") {
//    MatrixRainView(size: .init(width: CGFloat(400), height: 800))
//}
