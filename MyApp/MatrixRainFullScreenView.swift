//
//  MatrixRainFullScreenView.swift
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

struct MatrixFullScreenView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                MatrixRainFullScreenView(size: geometry.size)
            }
        }
    }
}

struct MatrixRainFullScreenView: View {
    let size: CGSize
    @State private var characters: [[MatrixCharacter]] = []
    @State private var timer: Timer? = nil
    let greenShades: [Color] = [.green, .init(white: 0.7, opacity: 0.8), .init(white: 0.6, opacity: 0.7), .init(white: 0.5, opacity: 0.6)]
    let charactersString = ["0", "1"]

    // Constants to control the density and animation
    let density: CGFloat = 20 // Adjust for desired character spacing
    let updateInterval: TimeInterval = 0.15 // Adjust for animation speed

    var body: some View {
        Canvas { context, size in
            let charWidth = size.width / CGFloat(characters.count)
            let charHeight = size.height / CGFloat(characters.first?.count ?? 1)

            for (colIndex, col) in characters.enumerated() {
                for (rowIndex, charData) in col.enumerated() {
                    let x = CGFloat(colIndex) * charWidth
                    let y = CGFloat(rowIndex) * charHeight

                    let rect = CGRect(x: x, y: y, width: charWidth, height: charHeight)
                    // Use the drawing context to draw the text
                    context.draw(Text(charData.char)
                        .font(.system(size: charData.fontSize, weight: .bold))
                        .foregroundColor(greenShades[charData.greenShadeIndex].opacity(charData.opacity)), in: rect)
                }
            }
        }
        .onAppear {
            initializeCharacters()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
        
    func initializeCharacters() {
        let cols = Int(size.width / density)
        let rows = Int(size.height / density)
        characters = Array(repeating: [], count: cols)
        
        for col in 0..<cols {
            characters[col] = Array(repeating: MatrixCharacter(char: "0", opacity: 1.0, fontSize: density, greenShadeIndex: 0), count: rows)
            for row in 0..<rows {
                characters[col][row] = createRandomCharacter()
            }
        }
    }

    func createRandomCharacter() -> MatrixCharacter {
        MatrixCharacter(
            char: charactersString.randomElement() ?? "0",
            opacity: Double.random(in: 0.2...1.0),
            fontSize: CGFloat.random(in: density * 0.5 ... density), // Font size relative to density
            greenShadeIndex: Int.random(in: 0..<greenShades.count)
        )
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            // Update a few characters randomly each tick
            for _ in 0..<Int(Double(characters.count) * 0.1) { // Update 10% of columns each tick
                let col = Int.random(in: 0..<characters.count)
                // Make sure columns array is not empty.
                if characters[col].count > 0 {
                    let row = Int.random(in: 0..<characters[col].count)
                    characters[col][row] = createRandomCharacter()

                    // "Falling" effect: Shift characters down
                    if row > 0 {
                        characters[col][row] = characters[col][row - 1]
                        characters[col][row - 1] = createRandomCharacter()
                    }
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview("Matrix Rain Full Screen View") {
    MatrixRainFullScreenView(size: .init(width: CGFloat(400), height: 800))
}

#Preview("Matrix View") {
    MatrixFullScreenView()
}
