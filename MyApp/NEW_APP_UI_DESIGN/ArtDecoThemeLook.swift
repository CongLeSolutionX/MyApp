//
//  ArtDecoView.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//
import SwiftUI

struct ArtDecoAlbumCoverView: View {
    let album: AlbumItem
    var body: some View {
        AsyncImage(url: album.bestImageURL) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            LinearGradient(
                                colors: [.brown, .gold, .brown],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing),
                            lineWidth: 2.0
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 5)
                .padding(4)
        }
        placeholder: {
            ZStack {
                Color.gray.opacity(0.1)
                Image(systemName: "music.note.list")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            .frame(width: 160, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}
struct ArtDecoAlbumCoverView_Previews: PreviewProvider {
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    // Use 640px image for detail view
    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for realistic preview
            ArtDecoAlbumCoverView(album: mockAlbum)
        }
        .preferredColorScheme(.dark) // Essential for retro theme
    }
}

struct AlbumCard: View {
    let album: AlbumItem
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArtDecoAlbumCoverView(album: album)
            Text(album.name)
                .font(Font.custom("JosefinSans-Bold", size: 18)) // "Josefin Sans", "Cinzel", "Playfair Display"
                .lineLimit(2)
                .foregroundStyle(Color.primary)
            Text(album.formattedArtists)
                .font(Font.custom("JosefinSans-Regular", size: 15))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
            HStack {
                Text(album.release_date.prefix(4)) // show year only
                Text("•")
                Text("\(album.total_tracks) Tracks")
            }
            .font(Font.custom("JosefinSans-Light", size: 13))
            .foregroundColor(.teal.opacity(0.9))
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.05))
            )
            Button {
                if let url = URL(string: album.external_urls.spotify ?? "google.com") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Play", systemImage: "play.circle.fill")
                    .font(Font.custom("JosefinSans-Regular", size: 15)) // "Josefin Sans", "Cinzel", "Playfair Display"
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule().strokeBorder(Color.gold, lineWidth: 1.5)
                    )
            }
            .foregroundStyle(Color.gold)
            .padding(.top, 2)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 5)
    }
}
struct AlbumDetailView_Previews: PreviewProvider {
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    // Use 640px image for detail view
    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for realistic preview
            AlbumCard(album: mockAlbum)
        }
        .preferredColorScheme(.dark) // Essential for retro theme
    }
}


// MARK: - Art Deco Color Palette
extension Color {
    static let gold = Color(hex: "#CBA328")
    static let bronze = Color(hex: "#CD7F32")
    static let black = Color(hex: "#1F1B24")
    static let emerald = Color(hex: "#50C878")
    static let navyDeco = Color(hex: "#223544")
}
//
// Helper to initialize Color from hex string
extension Color {
    init(hex: String) {
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
            (a, r, g, b) = (1, 1, 1, 0) // Default black
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
