////
////  DonkeyKongView_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/12/25.
////
//
//import SwiftUI
//import Combine // Needed for ObservableObject
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
//    // Simplified Tcharacter positions (using relative coordinates within GameArea 0.0-1.0)
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
//         increaseScore(points: 5)
//    }
//
//     func moveMarioUp() {
//         // Basic jump simulation or ladder climb start
//         marioPosition = CGPoint(x: marioPosition.x, y: max(0.05, marioPosition.y - marioMoveStep * 2))
//         increaseScore(points: 10)
//     }
//
//      func moveMarioDown() {
//          marioPosition = CGPoint(x: marioPosition.x, y: min(0.95, marioPosition.y + marioMoveStep * 2))
//          increaseScore(points: 10)
//      }
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
//        // Add "Hammer" to collectedBonusItems to visually remove it from the GameArea
//        collectedBonusItems.insert("Hammer")
//    }
//
//    func fixLadder(id: Int) {
//        isLadderBroken[id] = false
//        print("Fixed ladder \(id)")
//    }
//
//    func nextLevel() {
//        currentLevel += 1
//        playerScore += 1000 // Bonus for completing level
//        // Reset positions, enemy states etc. for new level
//        marioPosition = CGPoint(x: 0.2, y: 0.85)
//        dkPosition = CGPoint(x: 0.5, y: 0.15)
//        princessPosition = CGPoint(x: 0.65, y: 0.18)
//        collectedBonusItems.removeAll() // Clear bonus items for new level
//        hammerCount = 0 // Reset hammer count
//
//        // Cycle broken ladders for variety maybe?
//        isLadderBroken = [1: Bool.random(), 2: Bool.random(), 3: Bool.random()]
//    }
//}
//
//// MARK: - Font Constants (Best Practice)
//struct GameFont {
//    // IMPORTANT: Replace "PixelEmulator" with the actual name of the font file
//    // you have added to your project and included in your Info.plist
//    static let pixel = "PixelEmulator" // Default fallback if custom font fails
//    static let defaultFont = Font.system(.body, design: .monospaced)
//
//    static let scoreSize: CGFloat = 18
//    static let characterSize: CGFloat = 16
//    static let titleSize: CGFloat = 18
//
//    // Helper to try using custom font, fallback to system monospaced
//    static func gameFont(size: CGFloat) -> Font {
//        if let customFont = UIFont(name: GameFont.pixel, size: size) {
//            return Font(customFont)
//        } else {
//            // Warning if font not found (useful for debugging)
//            print("Warning: Custom font '\(GameFont.pixel)' not found. Using system monospaced font.")
//            return Font.system(size: size, weight: .bold, design: .monospaced)
//        }
//    }
//}
//
//// MARK: - Character Representation Enum
//enum CharacterRepresentation {
//    case localImage(name: String) // Name of the image in Assets.xcassets
//    case sfSymbol(name: String, color: Color = .white) // Name of SF Symbol, optional color override
//}
//
//// MARK: - Character Placeholder (Supports Image or SF Symbol)
//struct CharacterPlaceholder: View {
//    let representation: CharacterRepresentation
//    let size: CGFloat
//
//    var body: some View {
//        Group { // Use Group to allow conditional view types
//            switch representation {
//            case .localImage(let name):
//                 // Attempt to load the image, provide fallback color if it fails
//                 if UIImage(named: name) != nil {
//                    Image(name) // Load from Assets.xcassets
//                        .resizable()
//                        .interpolation(.none) // Keep pixel art crisp
//                        .scaledToFit()
//                } else {
//                    // Fallback view if image is missing
//                    Rectangle()
//                        .fill(Color.purple) // Use a distinct color for missing assets
//                        .overlay(Text("!\(name)").font(.caption).foregroundColor(.white))
//                        .onAppear {
//                             print("Warning: Local image '\(name)' not found in Assets.xcassets.")
//                        }
//                }
//
//            case .sfSymbol(let name, let color):
//                Image(systemName: name) // Load SF Symbol
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(color) // Apply color to SF Symbol
//            }
//        }
//        .frame(width: size, height: size) // Apply frame to the Group
//    }
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
//                    .font(GameFont.gameFont(size: GameFont.titleSize))
//                Text(formatScore(gameState.playerScore)) // Use formatted score
//                    .foregroundColor(.white)
//                    .font(GameFont.gameFont(size: GameFont.scoreSize))
//            }
//
//            Spacer()
//
//            // High Score
//            VStack {
//                Text("HIGH SCORE")
//                    .foregroundColor(.red)
//                    .font(GameFont.gameFont(size: GameFont.titleSize))
//                Text(formatScore(gameState.highScore)) // Use formatted score
//                    .foregroundColor(.white)
//                    .font(GameFont.gameFont(size: GameFont.scoreSize))
//            }
//
//            Spacer()
//
//            // Level and Bonus Items
//            VStack(alignment: .trailing) {
//                Text("L=\(String(format: "%02d", gameState.currentLevel))") // Formatted Level
//                    .foregroundColor(.cyan) // Original game used Cyan
//                    .font(GameFont.gameFont(size: GameFont.titleSize))
//
//                // Display collected Bonus Item indicators dynamically
//                 HStack {
//                     // Example: Show hammer count if player has one
//                     if gameState.hammerCount > 0 {
//                         Image(systemName: "hammer.fill")
//                             .foregroundColor(.orange)
//                             .font(.system(size: GameFont.characterSize))
//                         Text("x\(gameState.hammerCount)")
//                              .foregroundColor(.orange)
//                              .font(GameFont.gameFont(size: GameFont.characterSize))
//                     }
//                     // Add other indicators similarly (e.g., Parasol, Hat)
//                 }
//                 .frame(minHeight: GameFont.characterSize) // Ensure consistent height
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
//                 // Calculate absolute positions based on relative state and geometry
//                 let marioAbsolutePos = CGPoint(
//                    x: gameState.marioPosition.x * geometry.size.width,
//                    y: gameState.marioPosition.y * geometry.size.height
//                 )
//                 let dkAbsolutePos = CGPoint(
//                    x: gameState.dkPosition.x * geometry.size.width,
//                    y: gameState.dkPosition.y * geometry.size.height
//                 )
//                 let princessAbsolutePos = CGPoint(
//                    x: gameState.princessPosition.x * geometry.size.width,
//                    y: gameState.princessPosition.y * geometry.size.height
//                 )
//                let hammerAbsolutePos = CGPoint(
//                    x: geometry.size.width * 0.8,
//                    y: geometry.size.height * 0.7
//                )
//
//                // --- Background Elements (Platforms, Ladders) ---
//                 VStack(spacing: geometry.size.height * 0.1) {
//                     PlatformView(width: geometry.size.width * 0.9)
//                     PlatformView(width: geometry.size.width * 0.8)
//                     PlatformView(width: geometry.size.width * 0.9, isBroken: false, breakPosition: 0.3) // Example static break
//                     PlatformView(width: geometry.size.width * 0.85)
//                     PlatformView(width: geometry.size.width * 0.95)
//                 }
//                 .position(x: geometry.size.width / 2, y: geometry.size.height * 0.55)
//
//                // Example Ladders - Use gameState to determine if broken
//                 LadderView(height: geometry.size.height * 0.15, isBroken: gameState.isLadderBroken[1, default: false])
//                    .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.25) // ID 1
//
//                LadderView(height: geometry.size.height * 0.15, isBroken: gameState.isLadderBroken[2, default: false])
//                    .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.45) // ID 2
//
//                 LadderView(height: geometry.size.height * 0.15, isBroken: gameState.isLadderBroken[3, default: false])
//                    .position(x: geometry.size.width * 0.6, y: geometry.size.height * 0.65) // ID 3
//
//                // --- Foreground Elements (Characters, Lives, Items) ---
//                LivesIndicatorView() // Dedicated view for lives
//                     .position(x: geometry.size.width * 0.12, y: geometry.size.height * 0.12) // Adjusted position
//
//                // --- UPDATED CHARACTER USAGE ---
//
//                // Donkey Kong using a local image named "dk_idle"
//                // IMPORTANT: Ensure "dk_idle.png" exists in Assets.xcassets
//                CharacterPlaceholder(
//                    representation: .localImage(name: "dk_idle"),
//                    size: 60 // DK is often larger
//                )
//                    .position(dkAbsolutePos)
//
//                 // Princess using an SF Symbol
//                 // IMPORTANT: Ensure "princess.png" exists in Assets.xcassets or choose SF symbol
//                 CharacterPlaceholder(
//                    // representation: .sfSymbol(name: "figure.dress.line.vertical.figure", color: .pink), // Example SF Symbol
//                    representation: .localImage(name: "Cap_2"), // Example Local Image
//                     size: 35 // Size for princess
//                 )
//                     .position(princessAbsolutePos)
//
//                 // Mario using a local image named "mario_stand"
//                 // IMPORTANT: Ensure "mario_stand.png" exists in Assets.xcassets
//                 CharacterPlaceholder(
//                    representation: .localImage(name: "My-meme-heineken"),
//                     size: 35 // Size for Mario
//                 )
//                    .position(marioAbsolutePos) // Use calculated absolute position
//                    .animation(.linear(duration: 0.1), value: gameState.marioPosition) // Basic animation for movement
//
//                // Example Item on screen (e.g., hammer) - Only show if not collected
//                if !gameState.collectedBonusItems.contains("Hammer") {
//                     Image(systemName: "hammer.fill")
//                         .foregroundColor(.orange)
//                         .font(.system(size: 25)) // Slightly larger hammer
//                         .shadow(color: .black.opacity(0.5), radius: 1, x: 1, y: 1)
//                         .position(hammerAbsolutePos) // Position somewhere reachable
//                         // Add tap gesture later if needed for collection
//                         .onTapGesture {
//                             // Simple distance check for collection (example)
//                             let distance = hypot(marioAbsolutePos.x - hammerAbsolutePos.x, marioAbsolutePos.y - hammerAbsolutePos.y)
//                             if distance < 40 { // If Mario is close enough
//                                 gameState.collectHammer()
//                             } else {
//                                 print("Mario too far to collect hammer (\(distance.formatted()) units)")
//                             }
//                         }
//                }
//            }
//            .frame(width: geometry.size.width, height: geometry.size.height)
//            // .background(Color.gray.opacity(0.1)) // Uncomment to visualize frame
//        }
//        .aspectRatio(3.0 / 4.0, contentMode: .fit) // Maintain aspect ratio typical of arcade games
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
//                // IMPORTANT: Ensure "mario_icon.png" exists in Assets.xcassets
//                CharacterPlaceholder(
//                    representation: .localImage(name: "My-meme-original"), // Use a small icon version of Mario
//                    size: 20 // Smaller size for life icons
//                )
//            }
//            // Show '+' if more lives than can be displayed easily?
//            // Or just cap the display at 3-4 icons
//        }
//    }
//}
//
//// MARK: - Platform & Girder
//struct PlatformView: View {
//    let width: CGFloat
//    var isBroken: Bool = false
//    var breakPosition: CGFloat = 0.5 // 0.0 to 1.0
//
//    // Specific red color - using values from original games (approx)
//    let platformColor = Color(red: 252/255, green: 16/255, blue: 20/255)
//
//    var body: some View {
//        GirderShape(isBroken: isBroken, breakPosition: breakPosition)
//            .fill(platformColor)
//            .frame(width: width, height: 15) // Standard girder height
//    }
//}
//
//struct GirderShape: Shape {
//    let isBroken: Bool
//    let breakPosition: CGFloat // Normalized position (0.0 to 1.0) for the break start
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let segmentWidth: CGFloat = max(6, rect.width / 40) // Ensure minimum segment width
//        let segmentHeightRatio: CGFloat = 0.4 // How much the diagonal part extends down
//        let topHeightRatio: CGFloat = 1.0 - segmentHeightRatio // The flat top part
//        let numSegments = Int(floor(rect.width / segmentWidth)) // Use floor for whole segments
//
//        // Top line
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: rect.width, y: 0))
//
//        // Right edge
//        path.addLine(to: CGPoint(x: rect.width, y: rect.height * topHeightRatio))
//
//        // Calculate break segments (allow for 1-2 segments break width)
//        let breakStartSegment = max(0, Int(CGFloat(numSegments) * breakPosition) - 1)
//        let breakEndSegment = breakStartSegment + (isBroken ? 2 : 0) // Break width of 2 segments if broken
//
//        // Bottom zig-zag edge (drawn right-to-left)
//        for i in (0..<numSegments).reversed() {
//            let xStart = CGFloat(i) * segmentWidth
//            let xMid = xStart + segmentWidth / 2
//            let xEnd = xStart + segmentWidth
//
//            if isBroken && i >= breakStartSegment && i < breakEndSegment {
//                 // Flat bottom line for the broken section
//                 path.addLine(to: CGPoint(x: xStart, y: rect.height * topHeightRatio))
//            } else {
//                // Normal zig-zag segment
//                 path.addLine(to: CGPoint(x: xEnd, y: rect.height * topHeightRatio)) // Move to segment end on top-bottom line
//                 path.addLine(to: CGPoint(x: xMid, y: rect.height)) // Dip down to bottom
//                 path.addLine(to: CGPoint(x: xStart, y: rect.height * topHeightRatio)) // Rise back to start of segment
//            }
//        }
//        // Left edge
//        path.addLine(to: CGPoint(x: 0, y: rect.height * topHeightRatio))
//
//        // Close path back to start
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
//    // Brighter White for ladders, closer to original
//    let ladderColor = Color(red: 252/255, green: 252/255, blue: 252/255)
//    let rungSpacing: CGFloat = 12 // Adjust spacing between rungs
//
//    var body: some View {
//        Canvas { context, size in
//            let railWidth: CGFloat = 5
//            let railOffset: CGFloat = 10 // Distance between the two rails
//            let leftRailOrigin = CGPoint(x: (size.width - railOffset - 2 * railWidth) / 2, y: 0)
//            let rightRailOrigin = CGPoint(x: leftRailOrigin.x + railOffset + railWidth, y: 0)
//
//            // Draw Rails
//            let leftRailRect = CGRect(origin: leftRailOrigin, size: CGSize(width: railWidth, height: size.height))
//            let rightRailRect = CGRect(origin: rightRailOrigin, size: CGSize(width: railWidth, height: size.height))
//            context.fill(Path(leftRailRect), with: .color(ladderColor))
//            context.fill(Path(rightRailRect), with: .color(ladderColor))
//
//            // Draw Rungs
//            let rungWidth = railOffset + railWidth // Rung goes from inner edge of left to inner edge of right
//            let rungHeight: CGFloat = 4
//            let numberOfRungs = Int(size.height / rungSpacing)
//            let breakStartY = size.height * 0.3 // Where the broken section starts
//            let breakEndY = size.height * 0.6 // Where the broken section ends
//
//            for i in 0..<numberOfRungs {
//                let yPos = CGFloat(i) * rungSpacing + rungSpacing / 2
//                if !(isBroken && yPos > breakStartY && yPos < breakEndY) { // Skip rungs in broken section
//                    let rungRect = CGRect(x: leftRailOrigin.x + railWidth, y: yPos - rungHeight / 2, width: rungWidth, height: rungHeight)
//                    context.fill(Path(rungRect), with: .color(ladderColor))
//                }
//            }
//        }
//        .frame(width: 25, height: height) // Define the frame for the Canvas
//    }
//}
//
//struct LadderRail: View {
//    // This view is now less useful as Canvas provides more control for rungs
//    // Kept here for reference but LadderView uses Canvas now
//     let height: CGFloat
//     var isBroken: Bool = false
//     let color: Color
//
//     var body: some View {
//         VStack(spacing: 5) {
//             if isBroken {
//                  Rectangle()
//                       .fill(color.opacity(0.7)) // Slightly faded for broken part
//                       .frame(width: 5, height: height * 0.4)
//                  Spacer(minLength: height * 0.2) // Gap for broken section
//                  Rectangle()
//                       .fill(color)
//                       .frame(width: 5, height: height * 0.4)
//             } else {
//                  Rectangle()
//                       .fill(color)
//                       .frame(width: 5, height: height)
//             }
//         }
//         .frame(height: height)
//     }
// }
//
//// MARK: - Demo Controls View
//struct DemoControlView: View {
//    @EnvironmentObject var gameState: GameState
//
//    var body: some View {
//        VStack(spacing: 8) {
//            Text("Demo Controls")
//                .font(GameFont.gameFont(size: 14))
//                .foregroundColor(.yellow)
//
//            HStack(spacing: 10) {
//                 Button { gameState.moveMarioLeft() } label: { Image(systemName: "arrow.left.circle.fill") }
//                 VStack {
//                    Button { gameState.moveMarioUp() } label: { Image(systemName: "arrow.up.circle.fill") }
//                    Button { gameState.moveMarioDown() } label: { Image(systemName: "arrow.down.circle.fill") }
//                 }
//                 Button { gameState.moveMarioRight() } label: { Image(systemName: "arrow.right.circle.fill") }
//            }
//            .font(.title) // Larger buttons for movement
//
//            HStack(spacing: 5) {
//                  Button("Score+100") { gameState.increaseScore(points: 100) }
//                  Button("Lose Life") { gameState.loseLife() }
//                  Button("Get Hammer") { gameState.collectHammer() }
//                  Button("Fix L2") { gameState.fixLadder(id: 2) } // Button to fix specific ladder
//                  Button("Next Lvl") { gameState.nextLevel() }
//            }
//            .buttonStyle(PixelButtonStyle()) // Apply custom button style to action buttons
//        }
//        .padding(.horizontal)
//    }
//}
//
//// MARK: - Custom Button Style (Pixel Look)
//struct PixelButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(GameFont.gameFont(size: 12)) // Use game font
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .background(configuration.isPressed ? Color.gray.opacity(0.8) : Color.blue.opacity(0.9))
//            .foregroundColor(.white)
//            .cornerRadius(0) // Square corners
//            .overlay( // Add subtle border
//                Rectangle()
//                    .stroke(configuration.isPressed ? Color.white.opacity(0.5) : Color.black.opacity(0.5), lineWidth: 1)
//            )
//            .shadow(color: .black.opacity(0.4), radius: configuration.isPressed ? 0 : 2, x: configuration.isPressed ? 1 : 2, y: configuration.isPressed ? 1 : 2)
//            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
//            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
//    }
//}
//
//// MARK: - Preview Provider
//struct DonkeyKongView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Create a sample GameState for the preview if needed for testing states
//        let previewGameState = GameState()
//        // previewGameState.playerScore = 12340
//        // previewGameState.livesRemaining = 2
//        // previewGameState.collectedBonusItems.insert("Hammer") // To test hammer logic
//
//        DonkeyKongView()
//              // Use the specific preview state if you customized it
//              // .environmentObject(previewGameState)
//            .previewLayout(.device) // Preview on a device frame like iPhone SE or iPhone 14 Pro
//            .previewDevice("iPhone 14 Pro") // Select a specific device if desired
//            .preferredColorScheme(.dark) // Match the game's theme
//    }
//}
