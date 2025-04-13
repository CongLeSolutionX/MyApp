//
//  DonkeyKongView_Level2.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI
import Combine
import Foundation // Needed for JSONEncoder, JSONDecoder, UserDefaults

// MARK: - Global Constants and Setup

// IMPORTANT:
// 1. Add your pixel font file (e.g., "PixelEmulator.ttf") to your project,
//    include it in "Copy Bundle Resources", and add it to `Info.plist` under
//    "Fonts provided by application".
// 2. Add the following images to Assets.xcassets:
//    - dk_idle.png
//    - mario_stand.png
//    - princess.png
//    - mario_icon.png
//    - level_thumb_1.png, level_thumb_2.png, ... level_thumb_5.png (Level thumbnails)
//    - arcade_background_pattern.png (Optional, for Level Select background)

// If fonts/images are missing, warnings will print, and fallback UI (colors/SF Symbols) will be used.

// MARK: - Data Models (Level Select)

enum LevelStatus: Codable, Equatable {
    case locked
    case unlocked
    case completed(highScore: Int)

    var isLocked: Bool {
        if case .locked = self { return true }
        return false
    }

    var isCompleted: Bool {
        if case .completed = self { return true }
        return false
    }

     var highScore: Int? {
         if case .completed(let score) = self { return score }
         return nil
     }
}

struct LevelInfo: Identifiable, Codable, Equatable {
    let id: Int
    var name: String
    var description: String
    var thumbnailName: String
    var status: LevelStatus = .locked
    var difficulty: Int = 1
    var features: [String] = []
}

// MARK: - Observable Objects (State Management)

// Manages state for a single game attempt (positions, score during play)
class GameState: ObservableObject {
    @Published var playerScore: Int = 0
    @Published var highScore: Int = 5000 // Default high score (can be loaded)
    @Published var currentLevel: Int = 1
    @Published var livesRemaining: Int = 3
    @Published var hammerCount: Int = 0
    @Published var marioPosition: CGPoint = CGPoint(x: 0.2, y: 0.85)
    @Published var dkPosition: CGPoint = CGPoint(x: 0.5, y: 0.15)
    @Published var princessPosition: CGPoint = CGPoint(x: 0.65, y: 0.18)
    @Published var isLadderBroken: [Int: Bool] = [1: false, 2: true, 3: false]
    @Published var collectedBonusItems: Set<String> = []

    private let marioMoveStep: CGFloat = 0.05

    // --- Mock Actions ---
    func increaseScore(points: Int) {
        playerScore += points
        if playerScore > highScore {
            highScore = playerScore
        }
    }

    func moveMarioLeft() {
        marioPosition = CGPoint(x: max(0.05, marioPosition.x - marioMoveStep), y: marioPosition.y)
        increaseScore(points: 5)
    }

    func moveMarioRight() {
        marioPosition = CGPoint(x: min(0.95, marioPosition.x + marioMoveStep), y: marioPosition.y)
         increaseScore(points: 5)
    }

     func moveMarioUp() {
         marioPosition = CGPoint(x: marioPosition.x, y: max(0.05, marioPosition.y - marioMoveStep * 2))
         increaseScore(points: 10)
     }

      func moveMarioDown() {
          marioPosition = CGPoint(x: marioPosition.x, y: min(0.95, marioPosition.y + marioMoveStep * 2))
          increaseScore(points: 10)
      }

    func loseLife() {
        if livesRemaining > 0 {
            livesRemaining -= 1
            marioPosition = CGPoint(x: 0.2, y: 0.85)
        } else {
            print("GAME OVER")
            // In a real game, trigger game over sequence
        }
    }

    func collectHammer() {
        if !collectedBonusItems.contains("Hammer") { // Prevent collecting multiple times visually
             hammerCount += 1
             increaseScore(points: 100)
             collectedBonusItems.insert("Hammer")
        }
    }

     func useHammer() {
         if hammerCount > 0 {
             hammerCount -= 1
             print("Used Hammer!")
             // Add hammer swing animation trigger here
         }
     }

    func fixLadder(id: Int) {
        isLadderBroken[id] = false
        print("Fixed ladder \(id)")
    }

    func nextLevel() {
        currentLevel += 1
        playerScore += 1000 // Level complete bonus
        resetLevelState()
    }

    func resetLevelState() {
         // Reset positions, enemy states etc. for new level/life lost retry
         marioPosition = CGPoint(x: 0.2, y: 0.85)
         dkPosition = CGPoint(x: 0.5, y: 0.15)
         princessPosition = CGPoint(x: 0.65, y: 0.18)
         collectedBonusItems.removeAll() // Clear bonus items for new level
         hammerCount = 0 // Reset hammer count

         // Maybe randomize ladder breaks for new levels?
         isLadderBroken = [1: Bool.random(), 2: Bool.random(), 3: Bool.random()]
    }

    func loadLevel(_ levelId: Int) {
        print("Configuring GameState for Level \(levelId)")
        self.currentLevel = levelId
        // TODO: Add logic to load specific layouts, enemy patterns, highscore based on levelId
        // Example: Load high score for this specific level if tracked separately
        // self.highScore = PlayerProgress.getHighScoreForLevel(levelId) ?? 5000
        resetLevelState() // Reset positions for the start of the level
    }
}

// Manages overall player progress across levels
class PlayerProgress: ObservableObject {
    @Published var levels: [LevelInfo] = []
    @Published var totalPlayerScore: Int = 0 // Example: track overall lifetime score

    private let levelsSaveKey = "gameLevelsProgress_v1" // Increment version if data structure changes significantly

    init() {
        loadProgress()
    }

    func loadProgress() {
         if let savedData = UserDefaults.standard.data(forKey: levelsSaveKey),
            let decodedLevels = try? JSONDecoder().decode([LevelInfo].self, from: savedData) {
             self.levels = decodedLevels
             print("Loaded \(levels.count) levels from UserDefaults.")
             // Ensure Level 1 is always playable if loading corrupt/empty data
             if self.levels.isEmpty || self.levels.first?.status == .locked {
                  print("Loaded data invalid or Level 1 locked. Resetting or unlocking Level 1.")
                  self.levels = Self.createDefaultLevels() // Reset to default if data seems bad
                  // OR: Just ensure level 1 is unlocked:
                  // if !self.levels.isEmpty { self.levels[0].status = .unlocked }
             }
         } else {
             print("No saved data found or decoding failed. Loading default levels.")
             self.levels = Self.createDefaultLevels()
         }
         // TODO: Load totalPlayerScore if applicable
    }

    func completeLevel(id: Int, scoreAchieved: Int) {
        guard let index = levels.firstIndex(where: { $0.id == id }) else {
            print("Error: Could not find level with ID \(id) to mark complete.")
            return
        }

        let currentStatus = levels[index].status
        let currentHighScore = currentStatus.highScore ?? 0

        // Update status only if score is higher OR if it wasn't completed before
        if scoreAchieved > currentHighScore {
            levels[index].status = .completed(highScore: scoreAchieved)
            print("Level \(id) completed with NEW high score: \(scoreAchieved)")
        } else if !currentStatus.isCompleted {
             levels[index].status = .completed(highScore: currentHighScore) // Mark completed
             print("Level \(id) completed with score: \(scoreAchieved) (High score: \(currentHighScore))")
        } else {
             print("Level \(id) already completed with score: \(scoreAchieved). High score remains: \(currentHighScore)")
        }

        // Unlock the next level if it exists and is currently locked
        let nextLevelIndex = index + 1
        if nextLevelIndex < levels.count && levels[nextLevelIndex].status == .locked {
            levels[nextLevelIndex].status = .unlocked
            print("Unlocked Level \(levels[nextLevelIndex].id): \(levels[nextLevelIndex].name)")
        }
        saveProgress()
    }

    func saveProgress() {
        do {
            let encodedData = try JSONEncoder().encode(levels)
            UserDefaults.standard.set(encodedData, forKey: levelsSaveKey)
            print("Saved \(levels.count) level progress entries to UserDefaults.")
        } catch {
             print("Failed to encode and save level progress: \(error)")
        }
    }

    static func createDefaultLevels() -> [LevelInfo] {
        return [
            LevelInfo(id: 1, name: "Ramps", description: "Classic barrel dodging.", thumbnailName: "level_thumb_1", status: .unlocked, difficulty: 1, features: ["Barrels"]),
            LevelInfo(id: 2, name: "Cement Factory", description: "Mind the moving pies!", thumbnailName: "level_thumb_2", status: .locked, difficulty: 2, features: ["Conveyor Belts"]),
            LevelInfo(id: 3, name: "Elevators", description: "Tricky jumps and springs.", thumbnailName: "level_thumb_3", status: .locked, difficulty: 3, features: ["Elevators", "Springs"]),
            LevelInfo(id: 4, name: "Rivets", description: "Bring the structure down!", thumbnailName: "level_thumb_4", status: .locked, difficulty: 4, features: ["Rivets", "Fireballs"]),
            LevelInfo(id: 5, name: "Jungle Chase", description: "Bonus! Grab the fruit!", thumbnailName: "level_thumb_5", status: .locked, difficulty: 3, features: ["Vines", "Bonus Fruit"])
        ]
    }

    func resetProgress() {
      print("Resetting level progress to default.")
      // Optional: Add confirmation alert here in a real app
      self.levels = Self.createDefaultLevels()
      saveProgress()
    }
}

// MARK: - Styling and Font Constants

struct GameFont {
    static let pixel = "PixelEmulator" // The filename added to Info.plist
    static let defaultFont = Font.system(.body, design: .monospaced)

    static let scoreSize: CGFloat = 18
    static let characterSize: CGFloat = 16
    static let titleSize: CGFloat = 18
    static let buttonSize: CGFloat = 12
    static let rowTitleSize: CGFloat = 16
    static let rowDescSize: CGFloat = 12
    static let rowStatusSize: CGFloat = 12
    static let levelSelectTitleSize: CGFloat = 24

    static func gameFont(size: CGFloat) -> Font {
        // Attempt to load the custom font
        if UIFont(name: GameFont.pixel, size: size) != nil {
            return Font.custom(GameFont.pixel, size: size)
        } else {
            // Fallback and warning if custom font is not found
            print("⚠️ Warning: Custom font '\(GameFont.pixel)' not found. Using system monospaced font.")
            return Font.system(size: size, weight: .bold, design: .monospaced)
        }
    }
}

// MARK: - Reusable UI Components

// Represents game characters, supporting local images or SF Symbols
enum CharacterRepresentation {
    case localImage(name: String)
    case sfSymbol(name: String, color: Color = .white)
}

struct CharacterPlaceholder: View {
    let representation: CharacterRepresentation
    let size: CGFloat

    var body: some View {
        Group {
            switch representation {
            case .localImage(let name):
                 // Use Image initialiser that returns Optional to check existence
                 if let uiImage = UIImage(named: name) {
                     Image(uiImage: uiImage)
                         .resizable()
                         .interpolation(.none) // Crucial for pixel art
                         .scaledToFit()
                 } else {
                     // Fallback view if image missing
                     Rectangle()
                         .fill(Color.purple) // Distinct fallback color
                         .overlay(Text("!\(name)").font(.caption).foregroundColor(.white))
                         .onAppear {
                              print("⚠️ Warning: Local image '\(name)' not found in Assets.xcassets.")
                         }
                 }
            case .sfSymbol(let name, let color):
                Image(systemName: name)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(color)
            }
        }
        .frame(width: size, height: size)
    }
}

// Platform/Girder Drawing
struct GirderShape: Shape {
    let isBroken: Bool
    let breakPosition: CGFloat // Normalized position (0.0 to 1.0)

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let segmentWidth: CGFloat = max(8, rect.width / 30) // Dynamic segment width
        let topHeightRatio: CGFloat = 0.6 // Flat top part height ratio
        let numSegments = Int(floor(rect.width / segmentWidth))

        // Top line
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))

        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * topHeightRatio))

        // Break calculation
        let breakStartSegment = max(0, Int(CGFloat(numSegments) * breakPosition) - 1)
        let breakEndSegment = breakStartSegment + (isBroken ? 2 : 0) // Break width

        // Bottom zig-zag (right-to-left)
        for i in (0..<numSegments).reversed() {
            let xStart = CGFloat(i) * segmentWidth
            let xMid = xStart + segmentWidth / 2
            let xEnd = xStart + segmentWidth

            if isBroken && i >= breakStartSegment && i < breakEndSegment {
                 path.addLine(to: CGPoint(x: xStart, y: rect.height * topHeightRatio)) // Flat line in broken section
            } else {
                // Normal zig-zag
                 path.addLine(to: CGPoint(x: xEnd, y: rect.height * topHeightRatio))
                 path.addLine(to: CGPoint(x: xMid, y: rect.height)) // Dip down
                 path.addLine(to: CGPoint(x: xStart, y: rect.height * topHeightRatio)) // Rise back
            }
        }
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: rect.height * topHeightRatio))
        path.closeSubpath()
        return path
    }
}

struct PlatformView: View {
    let width: CGFloat
    var isBroken: Bool = false
    var breakPosition: CGFloat = 0.5
    let platformColor = Color(red: 252/255, green: 16/255, blue: 20/255) // DK Red

    var body: some View {
        GirderShape(isBroken: isBroken, breakPosition: breakPosition)
            .fill(platformColor)
            .frame(width: width, height: 15)
    }
}

// Ladder Drawing using Canvas
struct LadderView: View {
    let height: CGFloat
    var isBroken: Bool
    let ladderColor = Color(red: 252/255, green: 252/255, blue: 252/255) // White
    let rungSpacing: CGFloat = 12

    var body: some View {
        Canvas { context, size in
            let railWidth: CGFloat = 5
            let railOffset: CGFloat = 10
            let leftRailOrigin = CGPoint(x: (size.width - railOffset - 2 * railWidth) / 2, y: 0)
            let rightRailOrigin = CGPoint(x: leftRailOrigin.x + railOffset + railWidth, y: 0)

            let leftRailRect = CGRect(origin: leftRailOrigin, size: CGSize(width: railWidth, height: size.height))
            let rightRailRect = CGRect(origin: rightRailOrigin, size: CGSize(width: railWidth, height: size.height))
            context.fill(Path(leftRailRect), with: .color(ladderColor))
            context.fill(Path(rightRailRect), with: .color(ladderColor))

            let rungWidth = railOffset + railWidth
            let rungHeight: CGFloat = 4
            let numberOfRungs = Int(size.height / rungSpacing)
            let breakStartY = size.height * 0.3
            let breakEndY = size.height * 0.6

            for i in 0..<numberOfRungs {
                let yPos = CGFloat(i) * rungSpacing + rungSpacing / 2
                if !(isBroken && yPos > breakStartY && yPos < breakEndY) {
                    let rungRect = CGRect(x: leftRailOrigin.x + railWidth, y: yPos - rungHeight / 2, width: rungWidth, height: rungHeight)
                    context.fill(Path(rungRect), with: .color(ladderColor))
                }
            }
        }
        .frame(width: 25, height: height)
    }
}

// Displays Mario Icons for remaining lives
struct LivesIndicatorView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<min(gameState.livesRemaining, 5), id: \.self) { _ in // Show max 5 icons
                CharacterPlaceholder(
                    representation: .localImage(name: "mario_icon"),
                    size: 20
                )
            }
            if gameState.livesRemaining > 5 {
                Text("+") // Indicate more lives off-screen
                    .font(GameFont.gameFont(size: GameFont.characterSize))
                    .foregroundColor(.white)
            }
        }
    }
}

// Custom Button Style for Pixelated Look
struct PixelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GameFont.gameFont(size: GameFont.buttonSize))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(configuration.isPressed ? Color.gray.opacity(0.8) : Color.blue.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(0) // Sharp corners
            .overlay(
                Rectangle()
                    .stroke(configuration.isPressed ? Color.white.opacity(0.5) : Color.black.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: configuration.isPressed ? 0 : 2, x: configuration.isPressed ? 1 : 2, y: configuration.isPressed ? 1 : 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - Game Screen Views

// Top Info Bar (Scores, Level, Lives)
struct InfoBarView: View {
    @EnvironmentObject var gameState: GameState

    private func formatScore(_ score: Int) -> String {
        String(format: "%06d", score)
    }

    var body: some View {
        HStack {
            // Player 1 Score
            VStack(alignment: .leading) {
                Text("1UP")
                    .foregroundColor(.white)
                    .font(GameFont.gameFont(size: GameFont.titleSize))
                Text(formatScore(gameState.playerScore))
                    .foregroundColor(.white)
                    .font(GameFont.gameFont(size: GameFont.scoreSize))
            }

            Spacer()

            // High Score
            VStack {
                Text("HIGH SCORE")
                    .foregroundColor(.red)
                    .font(GameFont.gameFont(size: GameFont.titleSize))
                Text(formatScore(gameState.highScore))
                    .foregroundColor(.white)
                    .font(GameFont.gameFont(size: GameFont.scoreSize))
            }

            Spacer()

            // Level and Bonus Items
            VStack(alignment: .trailing) {
                Text("L=\(String(format: "%02d", gameState.currentLevel))")
                    .foregroundColor(.cyan)
                    .font(GameFont.gameFont(size: GameFont.titleSize))

                 HStack {
                     if gameState.hammerCount > 0 {
                         Image(systemName: "hammer.fill")
                             .foregroundColor(.orange)
                             .font(.system(size: GameFont.characterSize))
                         Text("x\(gameState.hammerCount)")
                              .foregroundColor(.orange)
                              .font(GameFont.gameFont(size: GameFont.characterSize))
                     }
                     // Add other bonus item indicators here if needed
                 }
                 .frame(minHeight: GameFont.characterSize) // Consistent height
                 .padding(.top, 1) // Small space below level number
            }
        }
        .padding(.bottom, 10)
    }
}

// Main Area where Gameplay Happens
struct GameAreaView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        GeometryReader { geometry in
            let charSize: CGFloat = 35
            let dkSize: CGFloat = 60
            // Calculate absolute positions based on relative state
             let marioAbsolutePos = CGPoint(
                x: gameState.marioPosition.x * geometry.size.width,
                y: gameState.marioPosition.y * geometry.size.height
             )
             let dkAbsolutePos = CGPoint(
                x: gameState.dkPosition.x * geometry.size.width,
                y: gameState.dkPosition.y * geometry.size.height
             )
             let princessAbsolutePos = CGPoint(
                x: gameState.princessPosition.x * geometry.size.width,
                y: gameState.princessPosition.y * geometry.size.height
             )
            let hammerAbsolutePos = CGPoint(
                x: geometry.size.width * 0.8,
                y: geometry.size.height * 0.7
            )

            ZStack {
                // --- Background Elements ---
                 VStack(spacing: geometry.size.height * 0.1) {
                     PlatformView(width: geometry.size.width * 0.9)
                     PlatformView(width: geometry.size.width * 0.8, isBroken: false) // Example static break
                     PlatformView(width: geometry.size.width * 0.9)
                     PlatformView(width: geometry.size.width * 0.85, isBroken: true, breakPosition: 0.7)
                     PlatformView(width: geometry.size.width * 0.95)
                 }
                 .position(x: geometry.size.width / 2, y: geometry.size.height * 0.55) // Centered platforms

                // Ladders (using dynamic broken state)
                 LadderView(height: geometry.size.height * 0.15, isBroken: gameState.isLadderBroken[1, default: false])
                    .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.25) // ID 1
                 LadderView(height: geometry.size.height * 0.15, isBroken: gameState.isLadderBroken[2, default: false])
                    .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.45) // ID 2
                 LadderView(height: geometry.size.height * 0.15, isBroken: gameState.isLadderBroken[3, default: false])
                    .position(x: geometry.size.width * 0.6, y: geometry.size.height * 0.65) // ID 3

                // --- Foreground Elements ---
                LivesIndicatorView()
                     .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.06) // Top-left corner

                // DK
                CharacterPlaceholder(representation: .localImage(name: "dk_idle"), size: dkSize)
                    .position(dkAbsolutePos)

                 // Princess
                 CharacterPlaceholder(representation: .localImage(name: "princess"), size: charSize)
                     .position(princessAbsolutePos)

                 // Mario
                 CharacterPlaceholder(representation: .localImage(name: "mario_stand"), size: charSize)
                    .position(marioAbsolutePos)
                    .animation(.linear(duration: 0.05), value: gameState.marioPosition) // Animate movement

                // Hammer Item (if not collected)
                if !gameState.collectedBonusItems.contains("Hammer") {
                     Image(systemName: "hammer.fill")
                         .foregroundColor(.orange)
                         .font(.system(size: 25))
                         .shadow(color: .black.opacity(0.5), radius: 1, x: 1, y: 1)
                         .position(hammerAbsolutePos)
                           .onTapGesture { // Make Hammer tappable
                              let distance = hypot(marioAbsolutePos.x - hammerAbsolutePos.x, marioAbsolutePos.y - hammerAbsolutePos.y)
                              if distance < charSize * 1.2 { // If Mario is close enough (adjust threshold)
                                  gameState.collectHammer()
                              } else {
                                  print("Mario too far to collect hammer (\(String(format: "%.1f", distance)) units)")
                              }
                           }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
             //.background(Color.gray.opacity(0.1)) // Uncomment to visualize frame bounds
        }
        .aspectRatio(3.0 / 4.0, contentMode: .fit) // Standard arcade aspect ratio
         .clipped() // Prevent elements from drawing outside the aspect ratio frame if needed
    }
}

// Temporary Debug/Demo Controls
struct DemoControlView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack(spacing: 8) {
            Text("Demo Controls")
                .font(GameFont.gameFont(size: 14))
                .foregroundColor(.yellow)
                .padding(.bottom, 4)

            // Movement D-Pad Style
            HStack(spacing: 10) {
                 Button { gameState.moveMarioLeft() } label: { Image(systemName: "arrow.left.circle.fill") }
                 VStack {
                     Button { gameState.moveMarioUp() } label: { Image(systemName: "arrow.up.circle.fill") }
                    Button { } label: { Image(systemName: "circle.fill").opacity(0) } // Placeholder
                     Button { gameState.moveMarioDown() } label: { Image(systemName: "arrow.down.circle.fill") }
                 }
                 Button { gameState.moveMarioRight() } label: { Image(systemName: "arrow.right.circle.fill") }
            }
            .font(.system(size: 35)) // Larger touch targets for movement
            .foregroundColor(.cyan)

            // Action Buttons
             HStack(spacing: 5) {
                   Button("Score+100") { gameState.increaseScore(points: 100) }
                   Button("Lose Life") { gameState.loseLife() }
                   Button("Get Hammer") { gameState.collectHammer() }
                    Button("Use Hammer") { gameState.useHammer() }
                   Button("Fix L2") { gameState.fixLadder(id: 2) }
                   Button("Next Lvl") { gameState.nextLevel() }
             }
             .buttonStyle(PixelButtonStyle()) // Apply custom style
             .padding(.top, 5)
        }
        .padding(.horizontal)
         .background(Color.black.opacity(0.5)) // Semi-transparent background
         .cornerRadius(5)
    }
}

// Main Game View Container
struct DonkeyKongView: View {
    // This view now often receives GameState from GameLevelContainerView
    // It doesn't usually own it directly unless it's the only view.
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                InfoBarView()
                    .padding(.top, 5)
                    .padding(.horizontal)

                // Spacer pushes game area down, allows controls at bottom if needed
                 Spacer(minLength: 0)

                GameAreaView()
                    .padding(.bottom)

                // Only show demo controls if needed during development
                     #if DEBUG
                      DemoControlView()
                           .padding(.bottom, 20)
                     #endif

                // Ensures space between bottom of screen and controls/game area
                  Spacer(minLength: 20)
            }
        }
        // gameState is injected by the parent (e.g., GameLevelContainerView or App)
    }
}

// MARK: - Level Selection Views

// Represents a single Row in the Level Select List
struct LevelRowView: View {
    let level: LevelInfo
    let isSelected: Bool // For potential visual feedback

    private let lockedColor = Color.gray.opacity(0.7)
    private let unlockedColor = Color.white
    private let completedColor = Color.yellow
    private let nameColor = Color.cyan
    private let scoreColor = Color.red

    var body: some View {
        HStack(spacing: 15) {
            // Thumbnail
            ZStack {
                // Use the placeholder which handles missing images
                CharacterPlaceholder(representation: .localImage(name: level.thumbnailName), size: 60)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(4)
                    .overlay(
                         RoundedRectangle(cornerRadius: 4)
                             .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )

                if level.status.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                         .shadow(radius: 3)
                }
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text("Lvl \(level.id): \(level.name)")
                    .font(GameFont.gameFont(size: GameFont.rowTitleSize))
                    .foregroundColor(level.status.isLocked ? lockedColor : nameColor)

                Text(level.description)
                     .font(GameFont.gameFont(size: GameFont.rowDescSize))
                     .foregroundColor(level.status.isLocked ? lockedColor : unlockedColor)
                     .lineLimit(2)
                     .fixedSize(horizontal: false, vertical: true) // Allow text wrap

                HStack {
                    if let highScore = level.status.highScore {
                        Image(systemName: "star.fill")
                             .foregroundColor(completedColor)
                             .font(.system(size: 14))
                        Text("Hi: \(String(format: "%06d", highScore))")
                             .font(GameFont.gameFont(size: GameFont.rowStatusSize))
                             .foregroundColor(scoreColor)
                    } else if !level.status.isLocked {
                         Text("Ready!")
                             .font(GameFont.gameFont(size: GameFont.rowStatusSize))
                             .foregroundColor(.green)
                    } else {
                           Text("Locked")
                              .font(GameFont.gameFont(size: GameFont.rowStatusSize))
                              .foregroundColor(lockedColor)
                    }
                    // Optionally add difficulty stars
                     HStack(spacing: 1) {
                          ForEach(0..<level.difficulty, id: \.self) { _ in
                              Image(systemName: "staroflife.fill") // Or other symbol
                                  .font(.system(size:10))
                                  .foregroundColor(.orange.opacity(0.8))
                          }
                     }
                }
                .padding(.top, 2)
            }

            Spacer()

            // Chevron indicator for playable levels
            if !level.status.isLocked {
                 Image(systemName: "chevron.right")
                     .font(.system(size: 16, weight: .semibold))
                     .foregroundColor(unlockedColor.opacity(0.8))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(
             ZStack {
                 // Background differs slightly if selected (if selection state used)
                  if isSelected {
                      Color.blue.opacity(0.3)
                  } else {
                      Color.gray.opacity(0.15)
                  }

             }
             .cornerRadius(8)
             .overlay(
                 RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: 1)
             )
         )
        .opacity(level.status.isLocked ? 0.6 : 1.0)
        .contentShape(Rectangle()) // Ensures entire row area is tappable
    }
}

// Main Level Selection Screen
struct GameLevelSelectView: View {
    @EnvironmentObject var playerProgress: PlayerProgress
    @State private var selectedLevelId: Int? = nil // Used by NavigationLink tag/selection
    @Environment(\.dismiss) private var dismiss // For Back button if presented modally

    var body: some View {
        // Use NavigationView for the title bar and navigation capabilities
         NavigationView {
             ZStack {
                 // Background Theme
                 Color.black
                     .edgesIgnoringSafeArea(.all)

                 // Optional background pattern
                 Image("arcade_background_pattern")
                      .resizable(resizingMode: .tile)
                      .opacity(0.1)
                      .edgesIgnoringSafeArea(.all)

                 ScrollView {
                     VStack(spacing: 10) {
                         // Title
                         Text("Select Stage")
                             .font(GameFont.gameFont(size: GameFont.levelSelectTitleSize))
                             .foregroundColor(.red)
                             .padding(.top, 20)
                             .padding(.bottom, 10)
                             .shadow(color: .red.opacity(0.5), radius: 5)

                         // Level List
                         ForEach(playerProgress.levels) { level in
                             // NavigationLink is triggered by `selectedLevelId` matching the `tag`
                             NavigationLink(
                                 destination: GameLevelContainerView(levelId: level.id)
                                                .navigationBarHidden(true), // Hide nav bar in game
                                 tag: level.id,
                                 selection: $selectedLevelId
                             ) {
                                 LevelRowView(level: level, isSelected: selectedLevelId == level.id)
                             }
                             .disabled(level.status.isLocked)
                             // Use simultaneousGesture to *set* the ID which triggers the NavigationLink
                             .simultaneousGesture(TapGesture().onEnded {
                                 if !level.status.isLocked {
                                      print("Selected Level \(level.id)")
                                      selectedLevelId = level.id // This activates the link
                                 } else {
                                     print("Level \(level.id) is locked.")
                                     // Add feedback? (e.g., haptic, shake animation)
                                 }
                             })
                         }

                         // --- Footer Actions ---
                          HStack {
                              Button("Back") {
                                  // This only makes sense if presented modally.
                                  // If pushed onto a NavigationView, the "< Back" is automatic.
                                   dismiss()
                              }
                              .buttonStyle(PixelButtonStyle())
                              .opacity(0.7) // Make less prominent?

                              Spacer()

                              Button("Reset Progress?") {
                                   // TODO: Add confirmation dialog here!
                                   playerProgress.resetProgress()
                               }
                               .buttonStyle(PixelButtonStyle())
                               .foregroundColor(.red) // Warning color
                          }
                          .padding(.top, 20)

                     } // Main VStack ends
                     .padding(.horizontal)
                     .padding(.bottom, 30)
                 } // ScrollView ends
             } // ZStack ends
              //.navigationTitle("Level Select") // Set title for the Nav Bar
              .navigationBarHidden(true) // Hide standard navigation bar if using custom title etc.
               // .navigationBarTitleDisplayMode(.inline)
         } // NavigationView ends
         .navigationViewStyle(.stack) // Use stack style for standard push navigation
          .onAppear {
              // Crucial: Reset selection when the view appears to prevent phantom navigation
              // if the user navigated back from the game screen.
              selectedLevelId = nil
          }
    }
}

// MARK: - Game Level Loading Container

// This view acts as the destination from Level Select.
// It sets up the GameState for the chosen level.
struct GameLevelContainerView: View {
    let levelId: Int
    @StateObject private var gameState = GameState() // Owns the GameState for THIS level attempt
    @EnvironmentObject var playerProgress: PlayerProgress // To update overall progress
    @Environment(\.dismiss) private var dismiss // To return to Level Select

    var body: some View {
         // The actual game view, passing the configured GameState
        DonkeyKongView()
            .environmentObject(gameState) // Provide the GameState to DonkeyKongView and its children
            .onAppear {
                // Load level-specific data into the GameState when this view appears
                gameState.loadLevel(levelId)
            }
            // Example Overlay: Debug button to simulate level completion
            .overlay(alignment: .topTrailing) {
                #if DEBUG // Only show debug buttons in debug builds
                 Button {
                     // Simulate completing level with random score
                      let score = gameState.playerScore + Int.random(in: 500...10000)
                      print("Debug: Simulating completion of level \(levelId) with score \(score)")
                     // Update the overall player progress
                     playerProgress.completeLevel(id: levelId, scoreAchieved: score)
                     // Go back to the level select screen
                     dismiss()
                 } label: {
                     Text("DEBUG:\nFinish Lvl")
                          .font(GameFont.gameFont(size: 10))
                          .padding(5)
                          .background(Color.green.opacity(0.8))
                          .foregroundColor(.white)
                 }
                 .buttonStyle(PixelButtonStyle())
                 .padding()
                #endif
            }
    }
}

// MARK: - App Entry Point

@main
struct DonkeyKongCloneApp: App {
    // Create the PlayerProgress state object once and share it via environment
    @StateObject private var playerProgress = PlayerProgress()

    var body: some Scene {
        WindowGroup {
            // Start the app with the Level Select view
            GameLevelSelectView()
                .environmentObject(playerProgress) // Inject the progress tracker
                .preferredColorScheme(.dark) // Enforce dark mode for arcade feel
        }
    }
}

// MARK: - Preview Providers

// Preview for the main Game View
//struct DonkeyKongView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Create a preview-specific GameState
//        let previewGameState = GameState()
//        previewGameState.playerScore = 12340
//        previewGameState.livesRemaining = 2
//        previewGameState.hammerCount = 1
//
//        DonkeyKongView()
//              .environmentObject(previewGameState) // Inject the state for preview
//            .previewLayout(.device)
//            .previewDevice("iPhone SE (3rd generation)") // Test on smaller screen
//            .preferredColorScheme(.dark)
//            .previewDisplayName("Game View (iPhone SE)")
//    }
//}

// Preview for the Level Select Screen
//struct GameLevelSelectView_Previews: PreviewProvider {
//    static var previews: some View {
//        let progressAllLocked = PlayerProgress() // Uses default initializer
//        progressAllLocked.levels = PlayerProgress.createDefaultLevels() // Force default state
//
//        let progressSomeCompleted = PlayerProgress()
//        progressSomeCompleted.levels = PlayerProgress.createDefaultLevels()
//         // Simulate completing some levels for preview
//         progressSomeCompleted.completeLevel(id: 1, scoreAchieved: 8800)
//         progressSomeCompleted.completeLevel(id: 2, scoreAchieved: 10500)
//         // Manually unlock next if needed after simulated completion
//         if progressSomeCompleted.levels.indices.contains(2) {
//             progressSomeCompleted.levels[2].status = .unlocked
//         }
//
//        Group {
//             GameLevelSelectView()
//                 .environmentObject(progressAllLocked)
//                 .previewDisplayName("Level Select (Default)")
//
//            GameLevelSelectView()
//                  .environmentObject(progressSomeCompleted)
//                  .previewDisplayName("Level Select (Some Done)")
//
//             // Preview individual rows for isolation
//             LevelRowView(level: progressSomeCompleted.levels[1], isSelected: false) // Lvl 2 (Completed)
//                 .padding()
//                 .background(Color.black)
//                 .previewLayout(.sizeThatFits)
//                 .previewDisplayName("Row (Completed)")
//
//             LevelRowView(level: progressAllLocked.levels[3], isSelected: false) // Lvl 4 (Locked)
//                 .padding()
//                 .background(Color.black)
//                 .previewLayout(.sizeThatFits)
//                 .previewDisplayName("Row (Locked)")
//        }
//        .preferredColorScheme(.dark)
//    }
//}
