//
//  Retro_1980s_Party_Aesthetic_Theme_Look_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/20/25.
//

//
//  DiscoThemeSpotifyApp.swift
//  MyApp
//
//  Created by Cong Le on 4/19/25.
//
//  Comprehensive version combining all features with 1970s Disco Theme
//

import SwiftUI
@preconcurrency import WebKit // Mark import as non-concurrent // Mark import as non-concurrent
import Foundation

// MARK: - 1970s Disco Theme Constants & Modifiers

// --- Colors ---
let discoBackgroundStart = Color(hex: "2C1B1A") // Very Dark Brown/Maroon
let discoBackgroundEnd = Color(hex: "4A2C2A") // Dark Warm Brown
let discoGold = Color(hex: "FFD700") // Classic Gold
let discoOrange = Color(hex: "F28C28") // Burnt Orange/Tangerine
let discoCream = Color(hex: "FFFDD0") // Creamy White for text
let discoSilver = Color(hex: "C0C0C0") // Silver for accents
let discoHighlightPurple = Color(hex: "703F9A") // Deep Purple highlight

let discoGradientBackground = LinearGradient(
    gradient: Gradient(colors: [discoBackgroundStart, discoBackgroundEnd]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

let discoAccentGradient = LinearGradient(
    gradient: Gradient(colors: [discoGold, discoOrange, discoHighlightPurple]),
    startPoint: .leading,
    endPoint: .trailing
)

// --- Fonts ---
// Using system fonts as placeholders. Replace with actual 70s-style fonts if available.
// Examples: "Funkydori", "Groovy Script", "Discoteque" etc.
func discoTitleFont(size: CGFloat) -> Font {
    // Placeholder: A rounded, bold system font
    // Font.system(.largeTitle, design: typeface(.tanhoma), weight: .heavy).italic() // Font.custom("Georama", size: 18.0)
    //Font.system(size: size, weight: .bold, design: .rounded)
    Font.custom("Funkydori", size: 24.0)
}

func discoBodyFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    // Placeholder: A clean, slightly rounded sans-serif
    //Font.system(size: size, weight: weight, design: .serif) // Avenir Next could work
    Font.custom("Georama-Regular", size: 12.0)
}

func discoScriptFont(size: CGFloat) -> Font {
    // Placeholder: System script-like font
    //Font.system(size: size, weight: .medium, design: .serif).italic()
    Font.custom("PlaylistScript", size: 24.0)
}

// --- Modifiers ---
struct DiscoSparkleGlow: ViewModifier {
    var color: Color
    var radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius * 0.4, x: 0, y: 0) // Base glow
            .shadow(color: color.opacity(0.4), radius: radius * 0.8, x: 0, y: 0) // Softer outer glow
            .overlay( // Subtle sparkle simulation
                SparkleOverlay(color: color.opacity(0.7))
                    .blur(radius: 1) // Soften sparkles slightly
                    .blendMode(.overlay) // Blend sparkles
                    .allowsHitTesting(false)
                    .clipped() // Clip sparkles to content shape
            )
    }
}

extension View {
    func discoSparkleGlow(_ color: Color = discoGold, radius: CGFloat = 10) -> some View {
        self.modifier(DiscoSparkleGlow(color: color, radius: radius))
    }
}

// Simple Sparkle Overlay using Canvas (Illustrative, performance considerations apply)
struct SparkleOverlay: View {
    var color: Color = discoGold.opacity(0.7)
    var density: Double = 0.015 // Fewer, larger sparkles than noise
    @State private var seed: Int = Int.random(in: 0...100) // For variation
    
    var body: some View {
        Canvas { context, size in
            var rng = SeededRandomNumberGenerator(seed: UInt64(seed)) // Use seeded RNG
            context.blendMode = .screen // Make sparkles bright
            
            for _ in 0..<Int(size.width * size.height * density) {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                let baseSize = Double.random(in: 1.0...3.0, using: &rng)
                let flareLength = baseSize * Double.random(in: 1.5...3.0, using: &rng)
                let angle = Angle.degrees(Double.random(in: 0...360, using: &rng))
                
                // Simple star shape path
                var path = Path()
                path.move(to: CGPoint(x: x, y: y - flareLength / 2))
                path.addLine(to: CGPoint(x: x, y: y + flareLength / 2))
                path.move(to: CGPoint(x: x - flareLength / 2, y: y))
                path.addLine(to: CGPoint(x: x + flareLength / 2, y: y))
                
                context.stroke(
                    path.applying(.init(rotationAngle: CGFloat(angle.radians))),
                    with: .color(color.opacity(Double.random(in: 0.5...1.0, using: &rng))),
                    lineWidth: baseSize * 0.5 // Thickness of sparkle lines
                )
            }
        }
        .onAppear { // Ensures different sparkles on each appearance/redraw
            seed = Int.random(in: 0...100)
        }
    }
}

// --- Hex Color Extension (Unchanged) ---
extension Color {
    init(hex: String) { /* ... Hex init implementation from previous versions ... */
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// --- Seeded RNG ---
//struct SeededRandomNumberGenerator: RandomNumberGenerator { /* ... */ }
// Simple Seeded RNG (Needed for NoiseTexture)
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345 // Simple LCG
        return state
    }
}
// MARK: - Data Models (Unchanged)

//struct SpotifySearchResponse: Codable, Hashable { let albums: Albums }
//struct Albums: Codable, Hashable { /* ... Fields ... */ }
//struct AlbumItem: Codable, Identifiable, Hashable {
//    let id: String
//    let album_type: String
//    let total_tracks: Int
//    let available_markets: [String]?
//    let external_urls: ExternalUrls
//    let href: String
//    let images: [SpotifyImage]
//    let name: String
//    let release_date: String
//    let release_date_precision: String
//    let type: String
//    let uri: String
//    let artists: [Artist]
//
//    var bestImageURL: URL? { /* ... Logic ... */ }
//    var listImageURL: URL? { /* ... Logic ... */ }
//    var formattedArtists: String { /* ... Logic ... */ }
//    func formattedReleaseDate() -> String { /* ... Logic ... */ }
//}

//struct Artist: Codable, Identifiable, Hashable { /* ... Fields ... */ }
//struct SpotifyImage: Codable, Hashable {
//    let height: Int?
//    let url: String
//    let width: Int?
//    var urlObject: URL? { URL(string: url) }
//}
//struct ExternalUrls: Codable, Hashable { /* ... Fields ... */ }
//struct AlbumTracksResponse: Codable, Hashable { /* ... Fields ... */ }
//struct Track: Codable, Identifiable, Hashable {
//    let id: String
//    let artists: [Artist]
//    /* ... other fields ... */
//    let uri: String
//
//    var formattedDuration: String { /* ... Logic ... */ }
//    var formattedArtists: String { /* ... Logic ... */ }
//}

// MARK: - Spotify Embed WebView (Unchanged Functionality, Coordinator Code Omitted)

//final class SpotifyPlaybackState: ObservableObject { /* ... Published properties ... */ }
//struct SpotifyEmbedWebView: UIViewRepresentable {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String?
//
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//    func makeUIView(context: Context) -> WKWebView { /* ... WebView setup, background clear ... */ }
//    func updateUIView(_ webView: WKWebView, context: Context) { /* ... JS loading logic ... */ }
//    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) { /* ... Cleanup ... */ }
//    private func generateHTML() -> String { /* ... HTML structure ... */ }
//
//    // --- COORDINATOR CLASS (Assume functional code from previous versions) ---
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//          var parent: SpotifyEmbedWebView
//          weak var webView: WKWebView?
//          var isApiReady = false
//          var lastLoadedUri: String? = nil
//          var currentSpotifyUri: String? = nil
//          var desiredUriBeforeReady: String? = nil
//
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { /* ... Logic ... */ }
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { /* ... Logic ... */ }
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { /* ... Logic ... */ }
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) { /* ... Logic ... */ }
//
//          init(_ parent: SpotifyEmbedWebView) { self.parent = parent }
//          // --- Implementation details for handling JS communication, omitted for brevity - Use previous version's ---
//          func updateDesiredUriBeforeReady(_ uri: String?) { if !isApiReady { desiredUriBeforeReady = uri } }
//          func updatePlaybackState(with data: [String: Any]) { /* Update parent state */ }
//          func handleApiReady() { /* Set flag, create controller */ }
//          func handleEvent(event: String, data: Any?) { /* Handle JS events */ }
//          func createSpotifyController(with initialUri: String?) { /* Execute JS */ }
//          func loadUri(_ uri: String?) { /* Execute JS */ }
//      } // End Coordinator
//}

// MARK: - API Service (Still Needs Valid Token)

let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // CRITICAL: Replace this!

//enum SpotifyAPIError: Error, LocalizedError { /* ... Cases and descriptions ... */ }
//struct SpotifyAPIService {
//    static let shared = SpotifyAPIService()
//    private let session: URLSession
//
//    init() { /* ... Session setup ... */ }
//    private func makeRequest<T: Decodable>(url: URL) async throws -> T { /* ... Request logic, token check ... */ }
//    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse { /* ... Search endpoint logic ... */ }
//    func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse { /* ... Tracks endpoint logic ... */ }
//}

// MARK: - SwiftUI Views (Disco Theme Applied)

// --- Preview ---
struct DiscoSpotifyApp_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
            .preferredColorScheme(.dark)
    }
}

// --- Themed Album Card ---
struct DiscoAlbumCard: View {
    let album: AlbumItem
    @State private var animateGlow = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) { // Align text to bottom
            // Album Art as Background Layer
            AlbumImageView(url: album.listImageURL)
                .aspectRatio(contentMode: .fill)
                .frame(height: 110) // Reduced height for card style
                .clipped()
            
            // Gradient overlay for effect + readability
            LinearGradient(
                gradient: Gradient(colors: [
                    discoBackgroundStart.opacity(0.1),
                    discoBackgroundStart.opacity(0.8),
                    discoBackgroundStart.opacity(1.0)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // --- Mirrored Ball/Sparkle Effect (Subtle) ---
            Circle()
                .fill(discoSilver.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -50, y: -60) // Position the "light source"
                .blendMode(.overlay)
            SparkleOverlay(color: discoSilver.opacity(0.4), density: 0.005) // Faint sparkles
                .allowsHitTesting(false)
            
            // --- Text Content ---
            HStack(spacing: 0) { // Use HStack to place image and text
                // Optional: Small version of album art at left edge
                AlbumImageView(url: album.listImageURL)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle()) // Disco ball shape
                    .overlay(Circle().stroke(discoGold.opacity(0.5), lineWidth: 1))
                    .padding([.leading, .vertical], 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(album.name)
                        .font(discoTitleFont(size: 17))
                        .foregroundColor(discoCream)
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                    
                    Text(album.formattedArtists)
                        .font(discoBodyFont(size: 13, weight: .medium))
                        .foregroundColor(discoOrange.opacity(0.9)) // Artist name accent
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "opticaldisc") // Disco record icon
                            .foregroundColor(discoSilver.opacity(0.7))
                        Text(album.album_type.capitalized)
                        Text("•")
                            .foregroundColor(discoCream.opacity(0.5))
                        Text(album.formattedReleaseDate())
                    }
                    .font(discoBodyFont(size: 10, weight: .light))
                    .foregroundColor(discoCream.opacity(0.7))
                }
                .padding(.leading, 5)
                .padding(.vertical, 10)
                .padding(.trailing, 10)
                
                Spacer() // Push text to left
            }
        }
        .frame(height: 110) // Consistent height
        .background(discoBackgroundEnd) // Base card color
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)) // Smoother corners
        .overlay( // Gold border trim
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(discoGold.opacity(0.7), lineWidth: 1)
        )
        .discoSparkleGlow(discoGold, radius: animateGlow ? 12 : 8) // Animate glow
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateGlow.toggle()
            }
        }
    }
}

// --- Themed Placeholders ---
//struct ErrorPlaceholderView: View {
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: iconName)
//                .font(.system(size: 60))
//                .foregroundStyle(discoAccentGradient) // Apply accent gradient
//                .discoSparkleGlow(color: discoOrange, radius: 15)
//                .padding(.bottom, 10)
//
//            Text("PARTY FOUL!") // Themed title
//                .font(discoTitleFont(size: 28))
//                .foregroundColor(discoCream)
//                .shadow(color: .black.opacity(0.6), radius: 3, y: 1)
//
//            Text(errorMessage)
//                .font(discoBodyFont(size: 15, weight: .light))
//                .foregroundColor(discoCream.opacity(0.85))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 20)
//                .lineSpacing(5)
//
//            // TODO: Confirmation to BinaryInteger
//            //            if error != .invalidToken, let retryAction = retryAction {
//            //                DiscoButton( // Use themed button
//            //                    text: "TRY AGAIN",
//            //                    action: retryAction,
//            //                    iconName: "arrow.clockwise.circle.fill"
//            //                )
//            //                .padding(.top, 15)
//            //            } else if error == .invalidToken {
//            Text("Access Denied.\nCheck Spotify Token.")
//                .font(discoBodyFont(size: 12))
//                .foregroundColor(discoOrange.opacity(0.8))
//                .multilineTextAlignment(.center)
//                .padding(.top, 10)
//            //            }
//        }
//        .padding(30)
//        .background(
//            discoBackgroundEnd.opacity(0.8) // Darker theme background
//                .overlay(.thinMaterial) // Subtle frosted glass
//        )
//        .cornerRadius(20)
//        .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
//        .padding(20) // Padding around the error view
//    }
//
//    // Icon and message logic remains unchanged
//    private var iconName: String { /* ... from previous version ... */ }
//    private var errorMessage: String { /* ... from previous version ... */ }
//}

struct EmptyStatePlaceholderView: View {
    let searchQuery: String
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: isInitialState ? "music.mic.circle.fill" : "questionmark.diamond.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(gradient: Gradient(colors: [discoGold, discoSilver]), startPoint: .top, endPoint: .bottom)
                )
                .discoSparkleGlow(discoGold, radius: 20)
                .padding(.bottom, 15)
            
            Text(title)
                .font(discoTitleFont(size: 24))
                .foregroundColor(discoCream)
            
            Text(message)
                .font(discoBodyFont(size: 16, weight: .light))
                .foregroundColor(discoCream.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(6)
        }
        .padding(30)
        // Background inherent from ZStack in parent view
    }
    
    // Logic remains unchanged
    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var title: String { isInitialState ? "FEEL THE GROOVE" : "CAN'T FIND IT" }
    private var message: String {
        if isInitialState {
            return "What vibe are you searchin' for?\nEnter an album or artist to get started."
        } else {
            return "Nothin' matching \"\(searchQuery)\" on the dance floor.\nTry another name, cool cat."
        }
    }
}

// --- Themed Detail View ---
struct AlbumDetailView: View {
    let album: AlbumItem
    @State private var tracks: [Track] = []
    @State private var isLoadingTracks: Bool = false
    @State private var trackFetchError: SpotifyAPIError? = nil
    @State private var selectedTrackUri: String? = nil
    @StateObject private var playbackState = SpotifyPlaybackState()
    
    var body: some View {
        ZStack {
            discoGradientBackground.ignoresSafeArea() // Use disco theme gradient
            
            // Optional: Subtle animated background element
            DiscoLightsBackground().blur(radius: 50).opacity(0.3)
            
            List {
                // Header View
                Section { AlbumHeaderView(album: album) }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                
                // Player View (Themed)
                if let uriToPlay = selectedTrackUri {
                    Section { DiscoEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay) }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                        .listRowBackground(Color.clear)
                        .transition(.opacity.combined(with: .move(edge: .top)).animation(.smooth))
                }
                
                // Tracks Section (Themed)
                Section {
                    TracksSectionView(
                        tracks: tracks, isLoading: isLoadingTracks, error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    )
                } header: {
                    Text("THE TRACK LIST") // Groovy header
                        .font(discoTitleFont(size: 15))
                        .tracking(2) // Letter spacing
                        .foregroundColor(discoGold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                        .background(discoBackgroundStart.opacity(0.5))
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                // External Link (Themed)
                //                if let stringURL = album.external_urls ?? "google.com",
                //                   let spotifyURL = URL(string: stringURL) {
                //                    Section { ExternalLinkDiscoButton(url: spotifyURL) }
                //                        .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                //                        .listRowSeparator(.hidden)
                //                        .listRowBackground(Color.clear)
                //                }
                
                Section {
                    ExternalLinkDiscoButton(
                        url: (URL(string: "spotifyURL.com") ??
                              URL(string: "google.com"))!
                    )
                }
                .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
            } // End List
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden) // Allow ZStack background
        } // End ZStack
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar) // Dark scheme for NavBar items
        //        .toolbarBackground( // Match background gradient in NavBard
        //            discoGradientBackground.opacity(0.8)
        //                .blur(radius: 5), // Slight blur for effect
        //            for: .navigationBar
        //        )
        .toolbarBackground(.visible, for: .navigationBar)
        .accentColor(discoGold) // Tint back button etc.
        .task { await fetchTracks() }
        .refreshable { await fetchTracks(forceReload: true) }
        .animation(.smooth(duration: 0.4), value: selectedTrackUri)
    }
    
    // Fetch Tracks Logic (Unchanged)
    private func fetchTracks(forceReload: Bool = false) async { /* ... */ }
}

// --- Detail View Sub-Components (Themed) ---

// Background for Detail View (Illustrative)
struct DiscoLightsBackground: View {
    @State private var animate = false
    let colors: [Color] = [discoGold, discoOrange, discoHighlightPurple, discoSilver]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<10) { _ in
                    Circle()
                        .fill(colors.randomElement() ?? .white)
                        .opacity(0.3)
                        .frame(width: CGFloat.random(in: 50...150), height: CGFloat.random(in: 50...150))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .scaleEffect(animate ? 1.1 : 0.9)
                        .animation(
                            .easeInOut(duration: Double.random(in: 2...5))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...1)),
                            value: animate
                        )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}

struct AlbumHeaderView: View {
    let album: AlbumItem
    
    var body: some View {
        VStack(spacing: 15) {
            AlbumImageView(url: album.bestImageURL) // Reusable Image View
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(Circle()) // Keep it round like a record/disco ball
                .overlay(Circle().stroke(discoGold.opacity(0.8), lineWidth: 2))
                .discoSparkleGlow(discoGold, radius: 15) // Gold glow
                .padding(.horizontal, 60) // Give it space
                .padding(.top, 10)
            
            VStack(spacing: 5) {
                Text(album.name)
                    .font(discoTitleFont(size: 24).italic()) // Title font, maybe italicized
                    .foregroundColor(discoCream)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                
                Text("by \(album.formattedArtists)")
                    .font(discoScriptFont(size: 18)) // Script-like font for artist
                    .foregroundColor(discoOrange)
                    .multilineTextAlignment(.center)
                
                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(discoBodyFont(size: 11, weight: .light))
                    .foregroundColor(discoCream.opacity(0.7))
            }
            .padding(.horizontal)
            
        }
        .padding(.bottom, 20) // Space below header
    }
}

struct DiscoEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String
    
    var body: some View {
        VStack(spacing: 10) {
            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                .frame(height: 85) // Default embed height + buffer
            // Player Frame/Background: Dark base with gold accents
                .background(
                    discoBackgroundStart.opacity(0.7)
                        .overlay(.ultraThinMaterial) // Frosted glass
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)) // Smooth corners
                        .overlay( // Gold border
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(discoGold.opacity(0.6), lineWidth: 1)
                                )
                    // .discoSparkleGlow($playbackState.isPlaying ? discoGold : discoSilver, radius: 9) // Dynamic glow color
                )
                .padding(.horizontal) // Padding around the player
            
            // Playback Status Text (Themed)
            HStack {
                // let statusText = playbackState.isPlaying ? "GROOVIN'" : "PAUSED"
                let statusText = "GROOVIN'"
                let statusColor = discoGold //playbackState.isPlaying ? discoGold : discoSilver.opacity(0.8)
                
                Text(statusText)
                    .font(discoBodyFont(size: 10, weight: .bold))
                    .foregroundColor(statusColor)
                    .tracking(1.5)
                    .discoSparkleGlow(statusColor, radius: 4) // Mini glow on status
                
                Spacer()
                
                // Time Display
                //Text(playbackState.duration > 0.1 ? "\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))" : "--:-- / --:--")
                Text("Display Time")
                    .font(discoBodyFont(size: 11, weight: .medium))
                    .foregroundColor(discoCream.opacity(0.8))
                    .monospacedDigit() // Keep time spacing consistent
            }
            .padding(.horizontal, 25) // Align with player padding
            .frame(height: 15)
            
        }
        // .animation(.easeInOut, value: $playbackState.isPlaying) // Animate glow
    }
    
    private func formatTime(_ time: Double) -> String {
        let totalSeconds = max(0, Int(time)) // Ensure non-negative
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TracksSectionView: View {
    let tracks: [Track]
    let isLoading: Bool
    let error: SpotifyAPIError?
    @Binding var selectedTrackUri: String?
    let retryAction: () -> Void
    
    var body: some View {
        if isLoading {
            HStack { // Center progress view
                Spacer()
                ProgressView().tint(discoGold) // Gold spinner
                Text("Loading Hits...")
                    .font(discoBodyFont(size: 14))
                    .foregroundColor(discoCream.opacity(0.7))
                Spacer()
            }.padding(.vertical, 25)
        } else if let error = error {
            ErrorPlaceholderView(error: error, retryAction: retryAction)
                .padding(.vertical, 20)
        } else if tracks.isEmpty {
            Text("The record's empty, man.")
                .font(discoBodyFont(size: 14))
                .foregroundColor(discoCream.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 25)
        } else {
            ForEach(tracks) { track in
                TrackRowView(
                    track: track,
                    isSelected: track.uri == selectedTrackUri
                )
                .contentShape(Rectangle())
                .onTapGesture { selectedTrackUri = track.uri }
                .listRowBackground(
                    track.uri == selectedTrackUri
                    ? discoHighlightPurple.opacity(0.2) // Highlight color
                    : Color.clear
                )
                .listRowSeparatorTint(discoGold.opacity(0.3)) // Subtle gold separator
            }
        }
    }
}

struct TrackRowView: View {
    let track: Track
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Track Number (Styled)
            Text("\(track.track_number)")
                .font(discoBodyFont(size: 12, weight: .bold))
                .foregroundColor(isSelected ? discoGold : discoCream.opacity(0.6))
                .frame(width: 25, alignment: .center)
                .padding(.leading, 15)
            
            // Track Info
            VStack(alignment: .leading, spacing: 3) {
                Text(track.name)
                    .font(discoBodyFont(size: 15, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? discoOrange : discoCream)
                    .lineLimit(1)
                Text(track.formattedArtists)
                    .font(discoBodyFont(size: 11, weight: .light))
                    .foregroundColor(discoCream.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Duration
            Text(track.formattedDuration)
                .font(discoBodyFont(size: 12, weight: .medium))
                .foregroundColor(discoCream.opacity(0.7))
                .padding(.trailing, 5)
            
            // Play/Selected Indicator (Disco Ball)
            Image(systemName: isSelected ? "stop.circle.fill" : "play.circle.fill") // Changed icons
                .foregroundColor(isSelected ? discoGold : discoSilver.opacity(0.8))
                .font(isSelected ? .title3 : .title3) // Slightly larger when selected
                .discoSparkleGlow(isSelected ? discoGold : discoSilver, radius: isSelected ? 7 : 4) // More glow when selected
                .frame(width: 30, height: 30)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                .padding(.trailing, 10)
            
        }
        .padding(.vertical, 10) // Slightly less vertical padding
    }
}

// --- Other Supporting Views (Themed) ---

struct AlbumImageView: View { // Reusable Image View - uses AsyncImage
    let url: URL?
    var placeholderColor1: Color = discoBackgroundEnd.opacity(0.5)
    var placeholderColor2: Color = discoBackgroundStart.opacity(0.5)
    var errorColor: Color = discoOrange.opacity(0.4)
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    LinearGradient(colors: [placeholderColor1, placeholderColor2], startPoint: .top, endPoint: .bottom)
                    ProgressView().tint(discoGold) // Gold tint
                }
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                ZStack {
                    LinearGradient(colors: [placeholderColor1, placeholderColor2], startPoint: .top, endPoint: .bottom)
                    Image(systemName: "photo.on.rectangle.angled") // Disc icon
                        .resizable().scaledToFit()
                        .foregroundColor(errorColor)
                        .padding(15)
                }
            @unknown default: EmptyView()
            }
        }
    }
}

struct SearchMetadataHeader: View {
    let totalResults: Int
    let limit: Int
    let offset: Int
    
    var body: some View {
        HStack {
            Label("\(totalResults) Grooves Found", systemImage: "music.note.list")
            Spacer()
            if totalResults > limit {
                Text("Viewing \(offset + 1)-\(min(offset + limit, totalResults))")
            }
        }
        .font(discoBodyFont(size: 10, weight: .medium))
        .foregroundColor(discoGold.opacity(0.85))
        .tracking(1.0)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(discoBackgroundStart.opacity(0.6).blur(radius: 3))
        .cornerRadius(5) // Less rounded than capsule
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(discoGold.opacity(0.3), lineWidth: 0.5))
    }
}

// --- Themed Button Component ---
struct DiscoButton: View {
    let text: String
    let action: () -> Void
    var iconName: String? = nil
    var gradient: LinearGradient = discoAccentGradient // Default gradient
    var textColor: Color = discoBackgroundStart // Dark text on bright button
    var glowColor: Color = discoGold
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let iconName = iconName { Image(systemName: iconName) }
                Text(text)
                    .tracking(1.5) // Letter spacing
            }
            .font(discoBodyFont(size: 16, weight: .bold))
            .padding(.horizontal, 35)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(gradient)
            .foregroundColor(textColor)
            .clipShape(Capsule()) // Keep capsule shape
            .overlay(Capsule().stroke(discoCream.opacity(0.4), lineWidth: 0.5)) // Creamy edge
            .discoSparkleGlow(glowColor, radius: 12) // Disco glow
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2) // Standard shadow
        }
        .buttonStyle(.plain)
    }
}

// Separate External Link Button using the DiscoButton style
struct ExternalLinkDiscoButton: View {
    let text: String = "OPEN IN SPOTIFY"
    let url: URL
    @Environment(\.openURL) var openURL
    
    var body: some View {
        DiscoButton(
            text: text,
            action: { openURL(url) },
            iconName: "arrow.up.forward.square.fill", // Spotify-like icon
            // Use specific disco colors for this button
            gradient: LinearGradient(colors: [discoGold, discoOrange], startPoint: .leading, endPoint: .trailing),
            textColor: discoBackgroundStart,
            glowColor: discoGold
        )
    }
}

// --- Main List View (Themed) ---
struct SpotifyAlbumListView: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil
    @State private var currentError: SpotifyAPIError? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // --- Disco Background ---
                discoGradientBackground.ignoresSafeArea()
                DiscoLightsBackground().blur(radius: 60).opacity(0.2) // Subtle background lights
                
                // --- Main Content Area ---
                Group {
                    if isLoading && displayedAlbums.isEmpty {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: discoGold))
                            .scaleEffect(1.8)
                    } else if let error = currentError {
                        ErrorPlaceholderView(error: error) { Task { await performDebouncedSearch() } }
                    } else if displayedAlbums.isEmpty && !searchQuery.isEmpty {
                        EmptyStatePlaceholderView(searchQuery: searchQuery)
                    } else if displayedAlbums.isEmpty && searchQuery.isEmpty {
                        EmptyStatePlaceholderView(searchQuery: searchQuery) // Show initial state
                    } else {
                        albumList // Display the themed list
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow content to fill
                .transition(.opacity.animation(.smooth(duration: 0.4)))
                
                // --- Loading Indicator Overlay (Themed) ---
                if isLoading && !displayedAlbums.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            ProgressView().tint(discoGold)
                            Text("Finding the Funk...")
                                .font(discoBodyFont(size: 12, weight: .bold))
                                .foregroundColor(discoGold)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(discoBackgroundStart.opacity(0.7).blur(radius: 5))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(discoGold.opacity(0.4), lineWidth: 0.5))
                        .shadow(color: discoGold.opacity(0.5), radius: 5)
                        .padding(.top, 8)
                        Spacer() // Push indicator to top
                    }
                    .transition(.opacity.animation(.easeInOut))
                }
                
            } // End ZStack
            .navigationTitle("Disco Spotify Finder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark)
            //            .toolbarBackground( // Gradient Navbar
            //                discoGradientBackground.opacity(0.8).blur(radius: 5),
            //                for: .navigationBar
            //            )
            .toolbarBackground(.visible, for: .navigationBar)
            
            // --- Search Bar (System default styling with accent) ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search Album/Artist...").foregroundColor(.gray))
            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
            .task(id: searchQuery) { await performDebouncedSearch() } // Debounced search
            .onChange(of: searchQuery) { if currentError != nil { currentError = nil } } // Clear error on new search
            .accentColor(discoGold) // Tint cursor/cancel button
            
        } // End NavigationView
        .accentColor(discoOrange) // Global accent for navigation links etc.
    }
    
    // --- Themed Album List View ---
    private var albumList: some View {
        List {
            // Themed Metadata Header
            if let info = searchInfo,
               info.total > 0 {
                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10)) // Center header better
                    .listRowBackground(Color.clear)
            }
            
            // Album Cards
            ForEach(displayedAlbums) { album in
                NavigationLink(destination: AlbumDetailView(album: album)) {
                    DiscoAlbumCard(album: album) // Use the themed card
                        .padding(.vertical, 6) // Tighter spacing between cards
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)) // Padding for cards
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle()) // Remove inset group styling
        .scrollContentBackground(.hidden) // Allow ZStack background through
        .background(Color.clear) // Ensure list itself is transparent
    }
    
    // --- Debounced Search Logic (Unchanged) ---
    private func performDebouncedSearch(immediate: Bool = false) async { /* ... */
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
            return
        }
        if !immediate {
            do { try await Task.sleep(for: .milliseconds(500)); try Task.checkCancellation() }
            catch { print("Search task cancelled (debounce)."); return }
        }
        // Start loading only if query hasn't changed during debounce
        guard trimmedQuery == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        await MainActor.run { isLoading = true }
        print("⚡️ Performing search for: \(trimmedQuery)")
        do {
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
            try Task.checkCancellation()
            await MainActor.run {
                displayedAlbums = response.albums.items
                searchInfo = response.albums
                currentError = nil
                isLoading = false
                print("✅ Search success: \(response.albums.items.count) items loaded.")
            }
        } catch is CancellationError {
            print("Search task cancelled.")
            await MainActor.run { isLoading = false } // Reset loading if cancelled
        } catch let apiError as SpotifyAPIError {
            print("❌ Search API Error: \(apiError.localizedDescription) for query '\(trimmedQuery)'")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
        } catch {
            print("❌ Search Unexpected Error: \(error.localizedDescription) for query '\(trimmedQuery)'")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false }
        }
    }
}

// MARK: - App Entry Point

@main
struct DiscoSpotifyApp: App {
    init() {
        // --- CRITICAL: Check if Spotify Token is Set ---
        if placeholderSpotifyToken.isEmpty || placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨🕺 FATAL STARTUP WARNING: Spotify Bearer Token is MISSING or using the placeholder!")
            print("👉 FIX: Replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in DiscoSpotifyApp.swift with your actual token.")
            print("👉 API calls will FAIL until this is fixed.")
            // Note: In a real app, you might fetch this dynamically or use a more robust config system.
        }
        
        // --- Global UI Appearance (Optional) ---
        // Set global tint color for elements like the back button arrow, progress views
        UIView.appearance().tintColor = UIColor(discoGold)
        
        // Customize Navigation Bar Title Appearance (Disco Style)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(discoCream),
            .font: UIFont(name: "Funkydori", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold), // Use disco font if available
            .kern: 1.5, // Add slight letter spacing
            .paragraphStyle: paragraphStyle,
            .shadow: { // Add subtle shadow to title text
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.black.withAlphaComponent(0.4)
                shadow.shadowOffset = CGSize(width: 0, height: 1)
                shadow.shadowBlurRadius = 2
                return shadow
            }()
        ]
        UINavigationBar.appearance().titleTextAttributes = titleAttributes
        UINavigationBar.appearance().largeTitleTextAttributes = titleAttributes // For consistency if large titles were used
    }
    
    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView() // Start with the disco-themed list
                .preferredColorScheme(.dark) // Disco works best in dark mode
        }
    }
}

// IMPORTANT:
// 1.  Replace `"YOUR_SPOTIFY_BEARER_TOKEN_HERE"` with your actual Spotify API token.
// 2.  Custom Fonts: This code uses placeholders like `discoTitleFont`. To get the full effect, you'd need to:
//     *   Find and add actual 70s-style fonts (like "Funkydori", "PlaylistScript", "Georama-Regular") to your Xcode project.
//     *   Ensure they are correctly added to your app's target and listed in the `Info.plist` file under "Fonts provided by application".
//     *   Update the `discoTitleFont`, `discoBodyFont`, and `discoScriptFont` functions to use `Font.custom("YourFontName", size: size)`.
// 3.  Performance: The `SparkleOverlay` and `DiscoLightsBackground` using `Canvas` might impact performance on older devices or with very high density. For production apps, consider Metal or pre-rendered assets for such effects.
