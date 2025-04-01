////
////  SpotifyMusicPlayerView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/1/25.
////
//
//
//import SwiftUI
//import UIKit // Needed for UIImage if you add image support
//
//// MARK: - Custom Result Builder: ItemBuilder
//
//@resultBuilder
//struct ItemBuilder {
//    
//    // Combines multiple components (arrays) into a single array
//    static func buildBlock(_ components: [Any]...) -> [Any] {
//        // components is an array of arrays [[Any], [Any], ...], flatten it
//        return components.flatMap { $0 }
//    }
//    
//    // Handles individual expressions (String, URL, UIImage, etc.)
//    // Wrap each expression in an array `[Any]` so buildBlock works consistently.
//    static func buildExpression(_ expression: String) -> [Any] {
//        return [expression]
//    }
//    
//    static func buildExpression(_ expression: URL) -> [Any] {
//        return [expression]
//    }
//    
//    // Add support for UIImages if you plan to share them
//    static func buildExpression(_ expression: UIImage) -> [Any] {
//        return [expression]
//    }
//    
//    // Allow passing through existing arrays
//    static func buildExpression(_ expression: [Any]) -> [Any] {
//        return expression
//    }
//    
//    // Add more buildExpression overloads for other types you need to share...
//    
//    // Handles `if` statements without an `else`
//    static func buildOptional(_ component: [Any]?) -> [Any] {
//        // If the condition is true, component is the array `[Any]`, otherwise it's nil.
//        // Return the array or an empty array.
//        return component ?? []
//    }
//    
//    // Handles the `if` part of an `if-else` statement
//    static func buildEither(first component: [Any]) -> [Any] {
//        return component
//    }
//    
//    // Handles the `else` part of an `if-else` statement
//    static func buildEither(second component: [Any]) -> [Any] {
//        return component
//    }
//    
//    // --- Optional: Add support for ForEach loops ---
//    static func buildArray(_ components: [[Any]]) -> [Any] {
//        // components is an array of arrays, one for each loop iteration. Flatten them.
//        return components.flatMap { $0 }
//    }
//}
//
//
//
//struct MusicPlayerView: View {
//    // --- Constants (Replaced Hardcoded Strings/Values) ---
//    private let songTitle = "để tôi ôm em bằng giai điệu này"
//    private let artistName = "CongLeSolutionX"
//    private let songURL: URL? = URL(string: "https://open.spotify.com/track/example-track-id") // Replace with actual URL
//    private let albumArtImageName = "My-meme-microphone" // Define image name once
//    private let totalDurationSeconds: Double = 254 // Consistent duration (e.g., 4:14)
//    
//    // --- State Variables ---
//    @State private var isPlaying: Bool = true // Example: Assume playing initially
//    @State private var progressValue: Double = 0.3 // Example: Progress slider value (0.0 to 1.0)
//    @State private var isLiked: Bool = true    // Example: Song is liked
//    @State private var isShuffling: Bool = true // Example: Shuffle is active
//    @State private var repeatMode: Int = 0     // Example: 0 = no repeat, 1 = repeat one, 2 = repeat all
//    @State private var isShowingShareSheet = false // State to control the share sheet
//    @State private var buildItems: [ItemBuilder] = []
//    
//    // --- Computed Display Times ---
//    var currentTime: String {
//        let current = totalDurationSeconds * progressValue
//        let minutes = Int(current) / 60
//        let seconds = Int(current) % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//    
//    var remainingTime: String {
//        let remaining = totalDurationSeconds * (1.0 - progressValue)
//        let minutes = Int(remaining) / 60
//        let seconds = Int(remaining) % 60
//        return String(format: "-%d:%02d", minutes, seconds)
//    }
//    
//    // --- Body ---
//    var body: some View {
//        ZStack {
//            // Background Color
//            Color(red: 0.18, green: 0.20, blue: 0.18) // Approximate dark green/grey
//                .ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                Spacer(minLength: 10) // Push content down slightly
//                
//                topBar
//                albumArt
//                songInfo
//                progressBar
//                playbackControls
//                bottomControls
//                lyricsSection
//                
//                Spacer(minLength: 10) // Push lyrics section up slightly
//            }
//            .padding(.horizontal)
//            .foregroundColor(.white) // Default text/icon color
//        }
//        // --- Share Sheet Modifier ---
//        .sheet(isPresented: $isShowingShareSheet) {
//            var itemsToShare: [Any] = []
//            // --- Use the Custom ItemBuilder ---
//            let itemsToShare = buildItems {
//                // Each line here becomes an expression handled by ItemBuilder
//                "\(songTitle) - \(artistName)" // buildExpression(String)
//                
//                if let url = songURL {         // buildOptional
//                    url                        // buildExpression(URL) inside optional
//                }
//                
//                // --- Example: Add image based on state ---
//                if let image = UIImage(named: albumArtImageName) { // buildOptional
//                    image // buildExpression(UIImage)
//                }
//                
//                // --- Example: Add multiple extra items ---
//                // ["Extra Item 1", "Another Item"] // buildExpression([Any])
//                
//                // --- Example: Using ForEach (if buildArray implemented) ---
//                // ForEach(["Tag1", "Tag2"]) { tag in // buildArray
//                //    tag // buildExpression(String)
//                // }
//                
//                // ------------------------------------
//                
//                // --- Return the View (Declarative) ---
//                if !itemsToShare.isEmpty {
//                    ActivityViewController(activityItems: itemsToShare)
//                        .preferredColorScheme(.dark)
//                    // You might want to exclude certain activity types if sharing images/complex data
//                    // .excludedActivityTypes([.assignToContact, .markupAsPDF])
//                } else {
//                    Text("Nothing available to share")
//                        .padding()
//                        .onAppear {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                                isShowingShareSheet = false
//                            }
//                        }
//                }
//            }
//            // --- End Share Sheet Modifier ---
//        }
//        // --- End Share Sheet Modifier ---
//        // .statusBar(hidden: true) // Keep commented if status bar should be visible
//    }
//    
//    
//    // MARK: - UI Components
//    
//    private var topBar: some View {
//        HStack {
//            Button {} label: { // Placeholder Action
//                Image(systemName: "chevron.down")
//                    .font(.body.weight(.semibold))
//            }
//            Spacer()
//            Text("Liked Songs")
//                .font(.footnote.weight(.bold))
//            Spacer()
//            Button {} label: { // Placeholder Action
//                Image(systemName: "ellipsis")
//                    .font(.body.weight(.semibold))
//            }
//        }
//        .padding(.vertical, 5)
//    }
//    
//    private var albumArt: some View {
//        Image(albumArtImageName) // Use defined constant
//            .resizable()
//            .aspectRatio(1.0, contentMode: .fit) // Make it square
//            .cornerRadius(8)
//            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
//            .padding(.vertical) // Add some vertical space around the art
//    }
//    
//    private var songInfo: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(songTitle) // Use defined constant
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .lineLimit(1)
//                Text(artistName) // Use defined constant
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//                    .lineLimit(1)
//            }
//            Spacer()
//            Button {
//                isLiked.toggle() // Actual action
//            } label: {
//                Image(systemName: isLiked ? "checkmark.circle.fill" : "plus.circle")
//                    .font(.title2)
//                    .foregroundColor(isLiked ? .green : .white.opacity(0.7))
//            }
//        }
//    }
//    
//    private var progressBar: some View {
//        VStack(spacing: 4) {
//            Slider(value: $progressValue, in: 0...1)
//                .accentColor(.white) // Color for the track to the left of the thumb
//            // NOTE: A fully custom slider might be needed for different track/thumb colors matching the original screenshot.
//            
//            HStack {
//                Text(currentTime)
//                Spacer()
//                Text(remainingTime)
//            }
//            .font(.caption)
//            .foregroundColor(.white.opacity(0.7))
//        }
//        .padding(.vertical)
//    }
//    
//    private var playbackControls: some View {
//        HStack(spacing: 25) {
//            Button {
//                isShuffling.toggle() // Actual action
//            } label: {
//                Image(systemName: "shuffle")
//                    .font(.title2)
//                    .foregroundColor(isShuffling ? .green : .white.opacity(0.7))
//            }
//            
//            Button {} label: { // Placeholder Action
//                Image(systemName: "backward.fill")
//                    .font(.title)
//                    .fontWeight(.bold)
//            }
//            
//            Button {
//                isPlaying.toggle() // Actual action
//            } label: {
//                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 70, height: 70)
//                    .foregroundColor(.white)
//            }
//            
//            Button {} label: { // Placeholder Action
//                Image(systemName: "forward.fill")
//                    .font(.title)
//                    .fontWeight(.bold)
//            }
//            
//            Button {
//                // Cycle through repeat modes: 0 -> 1 -> 2 -> 0 (Actual action)
//                repeatMode = (repeatMode + 1) % 3
//            } label: {
//                Image(systemName: repeatMode == 1 ? "repeat.1" : "repeat")
//                    .font(.title2)
//                    .foregroundColor(repeatMode != 0 ? .green : .white.opacity(0.7))
//            }
//        }
//    }
//    
//    private var bottomControls: some View {
//        HStack {
//            Button {} label: { // Placeholder Action
//                Image(systemName: "hifispeaker.and.appletv")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//            Spacer()
//            Button {} label: { // Placeholder Action
//                Image(systemName: "list.bullet")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//        }
//        .padding(.top, 10)
//    }
//    
//    private var lyricsSection: some View {
//        HStack {
//            Text("Lyrics")
//                .font(.headline)
//                .fontWeight(.bold)
//            
//            Spacer()
//            
//            Button {
//                isShowingShareSheet = true // Actual Action
//            } label: {
//                Image(systemName: "square.and.arrow.up")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//            .padding(.trailing, 5)
//            
//            Button {} label: { // Placeholder Action
//                Image(systemName: "arrow.up.left.and.arrow.down.right")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white.opacity(0.1))
//        )
//        .padding(.top)
//    }
//    
//}
//// MARK: - Preview
//
//struct MusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicPlayerView()
//            .preferredColorScheme(.dark) // Preview in dark mode
//        // NOTE: Add an image named "My-meme-microphone" to your Assets.xcassets
//        // for the album art to display correctly in previews and the app.
//    }
//}
//
//// NOTE: For the slider styling (thumb color, track color on the right),
//// a fully custom implementation might be needed beyond the standard SwiftUI Slider.
//// This implementation uses the default Slider behavior with an accent color.
