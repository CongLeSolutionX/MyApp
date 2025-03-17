//
//  AppleLogoWithMatrixRainView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

// Data model for a single Matrix character
struct MatrixCharacter {
    var char: String
    var opacity: Double
    var fontSize: CGFloat
    var greenShadeIndex: Int // Index into the greenShades array
    let id = UUID() // Unique identifier for SwiftUI
}

struct MatrixView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
//                MatrixRainView(size: geometry.size)
                AppleLogoView(size: geometry.size)
            }
        }
    }
}
//
//struct MatrixRainView: View {
//    let size: CGSize
//    @State private var characters: [[MatrixCharacter]] = []
//    @State private var timer: Timer? = nil
//    let greenShades: [Color] = [.green, .init(white: 0.7, opacity: 0.8), .init(white: 0.6, opacity: 0.7), .init(white: 0.5, opacity: 0.6)]
//    let charactersString = ["0", "1"]
//
//    // Constants to control the density and animation
//    let density: CGFloat = 20 // Adjust for desired character spacing
//    let updateInterval: TimeInterval = 0.15 // Adjust for animation speed
//
//    var body: some View {
//        Canvas { context, size in
//            let charWidth = size.width / CGFloat(characters.count)
//            let charHeight = size.height / CGFloat(characters.first?.count ?? 1)
//
//            for (colIndex, col) in characters.enumerated() {
//                for (rowIndex, charData) in col.enumerated() {
//                    let x = CGFloat(colIndex) * charWidth
//                    let y = CGFloat(rowIndex) * charHeight
//
//                    let rect = CGRect(x: x, y: y, width: charWidth, height: charHeight)
//                    // Use the drawing context to draw the text
//                    context.draw(Text(charData.char)
//                        .font(.system(size: charData.fontSize, weight: .bold))
//                        .foregroundColor(greenShades[charData.greenShadeIndex].opacity(charData.opacity)), in: rect)
//                }
//            }
//        }
//        .onAppear {
//            initializeCharacters()
//            startTimer()
//        }
//        .onDisappear {
//            stopTimer()
//        }
//    }
//        
//    func initializeCharacters() {
//        let cols = Int(size.width / density)
//        let rows = Int(size.height / density)
//        characters = Array(repeating: [], count: cols)
//        
//        for col in 0..<cols {
//            characters[col] = Array(repeating: MatrixCharacter(char: "0", opacity: 1.0, fontSize: density, greenShadeIndex: 0), count: rows)
//            for row in 0..<rows {
//                characters[col][row] = createRandomCharacter()
//            }
//        }
//    }
//
//    func createRandomCharacter() -> MatrixCharacter {
//        MatrixCharacter(
//            char: charactersString.randomElement() ?? "0",
//            opacity: Double.random(in: 0.2...1.0),
//            fontSize: CGFloat.random(in: density * 0.5 ... density), // Font size relative to density
//            greenShadeIndex: Int.random(in: 0..<greenShades.count)
//        )
//    }
//
//    func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
//            // Update a few characters randomly each tick
//            for _ in 0..<Int(Double(characters.count) * 0.1) { // Update 10% of columns each tick
//                let col = Int.random(in: 0..<characters.count)
//                // Make sure columns array is not empty.
//                if characters[col].count > 0 {
//                    let row = Int.random(in: 0..<characters[col].count)
//                    characters[col][row] = createRandomCharacter()
//
//                    // "Falling" effect: Shift characters down
//                    if row > 0 {
//                        characters[col][row] = characters[col][row - 1]
//                        characters[col][row - 1] = createRandomCharacter()
//                    }
//                }
//            }
//        }
//    }
//
//    func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//}

struct AppleLogoView: View {
    let size: CGSize

    var body: some View {
        ZStack {
            // Solid Green Apple Logo
            Image(systemName: "apple.logo")
                .resizable()
                .scaledToFit()
                .foregroundColor(.green)
                .frame(width: size.width * 0.4, height: size.width * 0.4) // Adjust size
                .position(x: size.width / 2, y: size.height / 2.1)

            // Use a simplified Canvas for the masked overlay
            Canvas { context, canvasSize in
                let logoFrame = CGRect(x: 0, y: 0, width: size.width * 0.4, height: size.width * 0.4)
                context.clip(to: Path(logoFrame)) // Clip to logo bounds

                 let density: CGFloat = 20
                let cols = Int(canvasSize.width / density)
                let rows = Int(canvasSize.height / density)

                let charWidth = canvasSize.width / CGFloat(cols)
                let charHeight = canvasSize.height / CGFloat(rows)

                for col in 0..<cols {
                    for row in 0..<rows {
                        let x = CGFloat(col) * charWidth
                        let y = CGFloat(row) * charHeight
                        let rect = CGRect(x: x, y: y, width: charWidth, height: charHeight)

                        // Draw with low opacity for the overlay effect
                        let charData = MatrixCharacter(
                            char: ["0", "1"].randomElement() ?? "0",
                            opacity: 0.3, // Reduced opacity
                            fontSize: CGFloat.random(in: density * 0.5 ... density),
                            greenShadeIndex: Int.random(in: 0..<4) // Fixed number of green shades
                        )
                        context.draw(Text(charData.char)
                                        .font(.system(size: charData.fontSize, weight: .bold))
                                        .foregroundColor(
                                        [
                                            .green,
                                            .init(white: 0.7, opacity: 0.8),
                                            .init(white: 0.6, opacity: 0.7),
                                            .init(white: 0.5, opacity: 0.6)
                                        ][charData.greenShadeIndex].opacity(charData.opacity)), in: rect)

                    }
                }
            }
            .frame(width: size.width * 0.4, height: size.width * 0.4)
            .mask(
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width * 0.4, height: size.width * 0.4)
            )
            .position(x: size.width / 2, y: size.height / 2.1)
        }
    }
}
//
//#Preview("Matrix Character View") {
//    MatrixCharacterView(char: "1", opacity: 1.0, fontSize: 20, greenShadeIndex: 1)
//}

#Preview("Apple Logo View") {
    AppleLogoView(size: .init(width: CGFloat(400), height: 800))
}
//
//#Preview("Matrix Rain View") {
//    MatrixRainView(size: .init(width: CGFloat(400), height: 800))
//}

#Preview("MatrixView") {
    MatrixView()
}
