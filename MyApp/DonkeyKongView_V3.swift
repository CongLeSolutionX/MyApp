////
////  DonkeyKongView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/12/25.
//
//import SwiftUI
//import Combine // Needed for ObservableObject
//
//
//// MARK: - Character Representation Enum
//enum CharacterRepresentation {
//    case localImage(name: String) // Name of the image in Assets.xcassets
//    case sfSymbol(name: String, color: Color = .white) // Name of SF Symbol, optional color override
//}
//
//
//// MARK: - Model (Observable Game State)
//
//class GameState: ObservableObject {
//    // Published properties automatically notify SwiftUI views of changes
//    @Published var playerScore: Int = 0
//    @Published var highScore: Int = 5000 // Default high score
//    @Published var currentLevel: Int = 1
//    @Published var livesRemaining: Int = 3
//    @Published var hammerCount: Int = 0 // Example item count
//    
//    // Simplified character positions (using relative coordinates within GameArea 0.0-1.0)
//    @Published var marioPosition: CGPoint = CGPoint(x: 0.2, y: 0.85) // Start bottom-left
//    @Published var dkPosition: CGPoint = CGPoint(x: 0.5, y: 0.15)   // Start top-middle
//    @Published var princessPosition: CGPoint = CGPoint(x: 0.65, y: 0.18) // Near DK
//    
//    // Example state for a dynamic element
//    @Published var isLadderBroken: [Int: Bool] = [1: false, 2: true, 3: false] // Dictionary to track state of specific ladders (e.g., by index)
//    @Published var collectedBonusItems: Set<String> = [] // Track collected items by name/ID
//    
//    // Constants for demo movement
//    private let marioMoveStep: CGFloat = 0.05
//    
//    // --- Mock Actions to Simulate Gameplay ---
//    
//    func increaseScore(points: Int) {
//        playerScore += points
//        if playerScore > highScore {
//            highScore = playerScore // Update high score if exceeded
//        }
//    }
//    
//    func moveMarioLeft() {
//        marioPosition = CGPoint(x: max(0.05, marioPosition.x - marioMoveStep), y: marioPosition.y)
//        increaseScore(points: 5) // Score for moving (example)
//    }
//    
//    func moveMarioRight() {
//        marioPosition = CGPoint(x: min(0.95, marioPosition.x + marioMoveStep), y: marioPosition.y)
//        increaseScore(points: 5)
//    }
//    
//    func moveMarioUp() {
//        // Basic jump simulation or ladder climb start
//        marioPosition = CGPoint(x: marioPosition.x, y: max(0.05, marioPosition.y - marioMoveStep * 2))
//        increaseScore(points: 10)
//    }
//    
//    func moveMarioDown() {
//        marioPosition = CGPoint(x: marioPosition.x, y: min(0.95, marioPosition.y + marioMoveStep * 2))
//        increaseScore(points: 10)
//    }
//    
//    func loseLife() {
//        if livesRemaining > 0 {
//            livesRemaining -= 1
//            // Reset Mario's position on life loss (typical behavior)
//            marioPosition = CGPoint(x: 0.2, y: 0.85)
//        } else {
//            // Game Over logic would go here
//            print("GAME OVER")
//        }
//    }
//    
//    func collectHammer() {
//        hammerCount += 1
//        increaseScore(points: 100)
//        // Maybe add "Hammer" to collectedBonusItems
//        collectedBonusItems.insert("Hammer")
//    }
//    
//    func fixLadder(id: Int) {
//        isLadderBroken[id] = false
//    }
//    
//    func nextLevel() {
//        currentLevel += 1
//        playerScore += 1000 // Bonus for completing level
//        // Reset positions, enemy states etc. for new level
//        marioPosition = CGPoint(x: 0.2, y: 0.85)
//        dkPosition = CGPoint(x: 0.5, y: 0.15)
//        // Cycle broken ladders for variety maybe?
//        isLadderBroken = [1: Bool.random(), 2: Bool.random(), 3: Bool.random()]
//    }
//}
//
//// MARK: - Font Constants (Best Practice)
//struct GameFont {
//    static let pixel = "PixelEmulator" // Replace with your actual font name
//    static let scoreSize: CGFloat = 18
//    static let characterSize: CGFloat = 16
//    static let titleSize: CGFloat = 18
//}
//
//// MARK: - Main View Container
//struct DonkeyKongView: View {
//    // @StateObject creates and owns the instance of GameState for this view hierarchy
//    @StateObject private var gameState = GameState()
//    
//    var body: some View {
//        ZStack {
//            Color.black
//                .edgesIgnoringSafeArea(.all)
//            
//            VStack(spacing: 0) {
//                InfoBarView() // Will get gameState via @EnvironmentObject
//                    .padding(.top, 5)
//                    .padding(.horizontal)
//                
//                Spacer()
//                
//                GameAreaView() // Will get gameState via @EnvironmentObject
//                    .padding(.bottom)
//                
//                // --- Temporary Controls for Demonstration ---
//                DemoControlView() // Also gets gameState via @EnvironmentObject
//                    .padding(.bottom, 20)
//                
//                Spacer(minLength: 30) // Ensure controls don't overlap bottom safe area
//            }
//        }
//        // Inject the gameState into the environment for child views to access
//        .environmentObject(gameState)
//    }
//}
//
//// MARK: - Info Bar View
//struct InfoBarView: View {
//    // Access the shared GameState from the environment
//    @EnvironmentObject var gameState: GameState
//    
//    // Helper function to format scores
//    private func formatScore(_ score: Int) -> String {
//        String(format: "%06d", score)
//    }
//    
//    var body: some View {
//        HStack {
//            // Player 1 Score
//            VStack(alignment: .leading) {
//                Text("1UP")
//                    .foregroundColor(.white)
//                    .font(.custom(GameFont.pixel, size: GameFont.titleSize))
//                Text(formatScore(gameState.playerScore)) // Use formatted score
//                    .foregroundColor(.white)
//                    .font(.custom(GameFont.pixel, size: GameFont.scoreSize))
//            }
//            
//            Spacer()
//            
//            // High Score
//            VStack {
//                Text("HIGH SCORE")
//                    .foregroundColor(.red)
//                    .font(.custom(GameFont.pixel, size: GameFont.titleSize))
//                Text(formatScore(gameState.highScore)) // Use formatted score
//                    .foregroundColor(.white)
//                    .font(.custom(GameFont.pixel, size: GameFont.scoreSize))
//            }
//            
//            Spacer()
//            
//            // Level and Bonus Items
//            VStack(alignment: .trailing) {
//                Text("L=\(String(format: "%02d", gameState.currentLevel))") // Formatted Level
//                    .foregroundColor(.cyan) // Original game used Cyan
//                    .font(.custom(GameFont.pixel, size: GameFont.titleSize))
//                
//                // Display collected Bonus Item indicators dynamically
//                HStack {
//                    // Example: Show hammer if collected
//                    if gameState.collectedBonusItems.contains("Hammer") {
//                        Image(systemName: "hammer.fill")
//                            .foregroundColor(.orange)
//                            .font(.system(size: GameFont.characterSize))
//                        Text("\(gameState.hammerCount)")
//                            .foregroundColor(.orange)
//                            .font(.custom(GameFont.pixel, size: GameFont.characterSize))
//                    }
//                    // Add other indicators similarly (e.g., Parasol, Hat)
//                }
//                .frame(minHeight: GameFont.characterSize) // Ensure consistent height
//            }
//        }
//        .padding(.bottom, 10)
//    }
//}
//
//// MARK: - Game Area View
//struct GameAreaView: View {
//    @EnvironmentObject var gameState: GameState
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // Calculate absolute positions based on relative state and geometry
//                let marioAbsolutePos = CGPoint(/*...*/)
//                let dkAbsolutePos = CGPoint(/*...*/)
//                let princessAbsolutePos = CGPoint(/*...*/)
//                
//        
//                // --- Background Elements (Platforms, Ladders) ---
//                VStack(spacing: geometry.size.height * 0.1) {
//                    // Pass dynamic properties if needed, e.g., platform damage state
//                    PlatformView(width: geometry.size.width * 0.9)
//                    PlatformView(width: geometry.size.width * 0.8)
//                    PlatformView(width: geometry.size.width * 0.9, isBroken: false, breakPosition: 0.3) // Example static break
//                    PlatformView(width: geometry.size.width * 0.85)
//                    PlatformView(width: geometry.size.width * 0.95)
//                }
//                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.55)
//                
//                // Example Ladders - Use gameState to determine if broken
//                LadderView(height: geometry.size.height * 0.15, isBroken: gameState.isLadderBroken[1, default: false])
//                    .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.25) // ID 1
//                
//                LadderView(height: geometry.size.height * 0.15, isBroken: gameState.isLadderBroken[2, default: false])
//                    .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.45) // ID 2
//                
//                LadderView(height: geometry.size.height * 0.15, isBroken: gameState.isLadderBroken[3, default: false])
//                    .position(x: geometry.size.width * 0.6, y: geometry.size.height * 0.65) // ID 3
//                
//                
//                // --- Foreground Elements (Characters, Lives) ---
//                LivesIndicatorView()
//                    .position(x: geometry.size.width * 0.12, y: geometry.size.height * 0.12)
//                
//                // --- UPDATED CHARACTER USAGE ---
//                
//                // Example: Donkey Kong using a local image named "dk_idle"
//                CharacterPlaceholder(
//                    representation: .localImage(name: "My-meme-original"),
//                    size: 60 // DK is often larger
//                )
//                .position(dkAbsolutePos)
//                
//                // Example: Princess using an SF Symbol
//                CharacterPlaceholder(
//                    representation: .sfSymbol(name: "figure.dress.line.vertical.figure", color: .pink), // Choose an appropriate SF symbol
//                    size: 35 // Size for princess
//                )
//                .position(princessAbsolutePos)
//                
//                // Example: Mario using a local image named "mario_stand"
//                CharacterPlaceholder(
//                    representation: .localImage(name: "My-meme-original"),
//                    size: 35 // Size for Mario
//                )
//                .position(marioAbsolutePos) // Use calculated absolute position
//                .animation(.linear(duration: 0.1), value: gameState.marioPosition)
//                
//                // Example Item...
//                if gameState.hammerCount == 0 && !gameState.collectedBonusItems.contains("Hammer") {
//                    Image(systemName: "hammer.fill")
//                    // ... (hammer code remains the same)
//                }
//            }
//            // ... (rest of the view)
//        }
//        .aspectRatio(3.0 / 4.0, contentMode: .fit)
//    }
//}
//
//// MARK: - Lives Indicator View
//struct LivesIndicatorView: View {
//    @EnvironmentObject var gameState: GameState
//    
//    var body: some View {
//        HStack(spacing: 2) {
//            // Display one Mario icon for each life remaining
//            ForEach(0..<gameState.livesRemaining, id: \.self) { _ in
//                // Use either a small local image or an SF symbol
//                CharacterPlaceholder(
//                    representation: .localImage(name: "My-meme-original"), // OR .sfSymbol(name: "figure.walk", color: .red)
//                    size: 20 // Smaller size for life icons
//                )
//            }
//        }
//    }
//}
//
//// MARK: - Platform & Girder (Mostly Unchanged, potentially add state later)
//struct PlatformView: View {
//    let width: CGFloat
//    var isBroken: Bool = false
//    var breakPosition: CGFloat = 0.5 // 0.0 to 1.0
//    
//    // Could accept state from EnvironmentObject if platforms become dynamic
//    // @EnvironmentObject var gameState: GameState
//    
//    var body: some View {
//        // Specific red color - using system red for now
//        let platformColor = Color(red: 252/255, green: 16/255, blue: 20/255)
//        
//        GirderShape(isBroken: isBroken, breakPosition: breakPosition)
//            .fill(platformColor)
//            .frame(width: width, height: 15)
//    }
//}
//
//struct GirderShape: Shape { /* ... Shape code remains the same ... */
//    let isBroken: Bool
//    let breakPosition: CGFloat
//    
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let segmentWidth: CGFloat = 8
//        let _: CGFloat = rect.height * 0.4
//        let numSegments = Int(rect.width / segmentWidth)
//        
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: rect.width, y: 0))
//        
//        let breakStartSegment = Int(CGFloat(numSegments) * breakPosition) - 1
//        let breakEndSegment = breakStartSegment + 2
//        
//        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.6))
//        
//        for i in (0..<numSegments).reversed() {
//            let xStart = CGFloat(i) * segmentWidth
//            let xMid = xStart + segmentWidth / 2
//            let xEnd = xStart + segmentWidth
//            
//            if isBroken && i >= breakStartSegment && i < breakEndSegment {
//                path.addLine(to: CGPoint(x: xStart, y: rect.height * 0.6))
//            } else {
//                path.addLine(to: CGPoint(x: xEnd, y: rect.height * 0.6))
//                path.addLine(to: CGPoint(x: xMid, y: rect.height))
//                path.addLine(to: CGPoint(x: xStart, y: rect.height * 0.6))
//            }
//        }
//        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.6))
//        path.closeSubpath()
//        return path
//    }
//}
//
//// MARK: - Ladder Views (Accepts broken state)
//struct LadderView: View {
//    let height: CGFloat
//    var isBroken: Bool // Now determined by GameState via GameAreaView
//    
//    var body: some View {
//        // Brighter White for ladders, closer to original
//        let ladderColor = Color(red: 252/255, green: 252/255, blue: 252/255)
//        
//        HStack(spacing: 5) {
//            LadderRail(height: height, color: ladderColor)
//            LadderRail(height: height, isBroken: isBroken, color: ladderColor) // Pass broken state
//        }
//    }
//}
//
//struct LadderRail: View {
//    let height: CGFloat
//    var isBroken: Bool = false
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 5) {
//            if isBroken {
//                Rectangle()
//                    .fill(color.opacity(0.7)) // Slightly faded for broken part
//                    .frame(width: 5, height: height * 0.4)
//                Spacer()
//                Rectangle()
//                    .fill(color)
//                    .frame(width: 5, height: height * 0.4)
//            } else {
//                Rectangle()
//                    .fill(color)
//                    .frame(width: 5, height: height)
//            }
//        }
//        .frame(height: height)
//    }
//}
//
//// MARK: - Character Placeholder (Image or SF Symbol)
//struct CharacterPlaceholder: View {
//    let representation: CharacterRepresentation // Use the enum now
//    let size: CGFloat
//    
//    var body: some View {
//        Group { // Use Group to allow conditional view types
//            switch representation {
//            case .localImage(let name):
//                Image(name) // Load from Assets.xcassets
//                    .resizable()
//                    .interpolation(.none) // Keep pixel art crisp
//                    .scaledToFit() // Or .scaledToFill() depending on desired look
//                
//            case .sfSymbol(let name, let color):
//                Image(systemName: name) // Load SF Symbol
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(color) // Apply color to SF Symbol
//            }
//        }
//        .frame(width: size, height: size) // Apply frame to the Group
//        // Optional: Add background/overlay if needed for testing
//        .background(Color.gray.opacity(0.3))
//        .overlay(Rectangle().stroke(Color.red, lineWidth: 1))
//    }
//}
//// MARK: - Demo Controls View
//struct DemoControlView: View {
//    @EnvironmentObject var gameState: GameState
//    
//    var body: some View {
//        VStack {
//            Text("Demo Controls")
//                .font(.custom(GameFont.pixel, size: 14))
//                .foregroundColor(.yellow)
//            HStack {
//                Button("Left") { gameState.moveMarioLeft() }
//                Button("Up") { gameState.moveMarioUp() } // Simulate Jump/Climb
//                Button("Down") { gameState.moveMarioDown() } // Simulate Descend
//                Button("Right") { gameState.moveMarioRight() }
//            }
//            HStack {
//                Button("Score+100") { gameState.increaseScore(points: 100) }
//                Button("Lose Life") { gameState.loseLife() }
//                Button("Next Lvl") { gameState.nextLevel() }
//                Button("Get Hammer") {gameState.collectHammer()}
//                Button("Fix L2") {gameState.fixLadder(id: 2)}
//            }
//            
//        }
//        .buttonStyle(PixelButtonStyle()) // Apply custom button style
//        .padding(.horizontal)
//    }
//}
//
//// MARK: - Custom Button Style (Pixel Look)
//struct PixelButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.custom(GameFont.pixel, size: 12))
//            .padding(.horizontal, 10)
//            .padding(.vertical, 5)
//            .background(configuration.isPressed ? Color.gray : Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(0) // Square corners
//            .shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//        
//    }
//}
//
//// MARK: - Preview Provider
//struct DonkeyKongView_Previews: PreviewProvider {
//    static var previews: some View {
//        DonkeyKongView()
//        // Ensure preview also has access to an environment object if needed,
//        // though @StateObject in DonkeyKongView handles this.
//        // .environmentObject(GameState()) // Not strictly needed here due to @StateObject
//            .previewLayout(.device) // Preview on a device frame
//            .preferredColorScheme(.dark) // Match the game's theme
//        // Add the custom font to the preview environment if necessary for it to render
//        // .environment(\.font, Font.custom("PixelEmulator", size: 16)) // Example
//    }
//}
