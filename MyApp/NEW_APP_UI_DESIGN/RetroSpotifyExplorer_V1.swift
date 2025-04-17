////
////  RetroView.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//
//import SwiftUI
//import Foundation
//
//// MARK: - Data Models
//struct SpotifySearchResponse: Codable {
//    let albums: Albums
//}
//struct Albums: Codable {
//    let items: [AlbumItem]
//}
//struct AlbumItem: Identifiable, Codable {
//    let id, name, release_date: String
//    let total_tracks: Int
//    let images: [SpotifyImage]
//    let external_urls: ExternalUrls
//    let artists: [Artist]
//
//    var imageURL: URL? {
//        URL(string: images.first?.url ?? "")
//    }
//    var artistNames: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//}
//struct Artist: Identifiable, Codable {
//    let id: String
//    let name: String
//}
//struct SpotifyImage: Codable {
//    let url: String
//}
//struct ExternalUrls: Codable {
//    let spotify: String
//}
//
//// MARK: - SpotifyAPI Service
//class SpotifyAPI: ObservableObject {
//    @Published var albums: [AlbumItem] = []
//    func search(query: String) {
//        let token = "YOUR_SPOTIFY_BEARER_TOKEN_HERE"
//        let searchQuery = query.replacingOccurrences(of: " ", with: "%20")
//        guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(searchQuery)&type=album") else { return }
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, res, error in
//            guard let data = data else { return }
//            if let decoded = try? JSONDecoder().decode(SpotifySearchResponse.self, from: data) {
//                DispatchQueue.main.async {
//                    self?.albums = decoded.albums.items
//                }
//            }
//        }.resume()
//    }
//}
//
//// MARK: - Neon Glow Custom Modifier
//extension View {
//    func neonGlow(_ color: Color) -> some View {
//        self.shadow(color: color.opacity(0.9), radius: 4)
//            .shadow(color: color.opacity(0.6), radius: 8)
//            .shadow(color: color.opacity(0.4), radius: 12)
//    }
//}
//
//// MARK: - Main App View
//struct RetroSpotifyExplorer: View {
//    @StateObject private var api = SpotifyAPI()
//    @State private var searchQuery = "Miles Davis"
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField("Search Album or Artist", text: $searchQuery, onCommit: { api.search(query: searchQuery) })
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(.black.opacity(0.8))
//                            .neonGlow(.cyan))
//                    .foregroundColor(.white)
//                    .font(.system(.body, design: .monospaced)).padding()
//
//                ScrollView {
//                    ForEach(api.albums) { album in
//                        NavigationLink(destination: AlbumDetail(album: album)) {
//                            AlbumCard(album: album)
//                        }.padding(.vertical, 8)
//                    }
//                }
//            }
//            .navigationTitle("🔮 Retro Spotify")
//            .background(
//                LinearGradient(colors:[.purple.opacity(0.8), .black], startPoint:.top, endPoint:.bottom)
//                    .edgesIgnoringSafeArea(.all)
//            )
//            .onAppear { api.search(query: searchQuery) }
//        }
//    }
//}
//
//// MARK: - Album Card View
//struct AlbumCard: View {
//    let album: AlbumItem
//    var body: some View {
//        ZStack {
//            LinearGradient(colors:[.pink, .purple, .blue], startPoint:.leading, endPoint:.trailing)
//                .frame(height: 160).cornerRadius(16).neonGlow(.blue)
//
//            HStack(spacing: 16) {
//                AsyncImage(url:album.imageURL){img in
//                    img.resizable().scaledToFill()
//                }placeholder:{Color.black.opacity(0.2)}
//                 .frame(width:120,height:120).clipShape(RoundedRectangle(cornerRadius:12)).neonGlow(.pink)
//
//                VStack(alignment:.leading,spacing:6){
//                    Text(album.name).font(.system(.title3,design:.monospaced)).bold().foregroundColor(.white)
//                    Text(album.artistNames).font(.system(.caption,design:.monospaced)).foregroundColor(.white.opacity(0.85))
//                    Text("📅 \(album.release_date)").font(.caption2.monospaced()).foregroundColor(.white.opacity(0.8))
//                    Text("🎧 \(album.total_tracks) Tracks").font(.caption2.monospaced()).foregroundColor(.white.opacity(0.75))
//                }
//                Spacer()
//            }
//            .padding()
//        }.padding(.horizontal)
//    }
//}
//
//// MARK: - Album Detail View
//struct AlbumDetail:View {
//    let album:AlbumItem
//    var body:some View {
//        VStack(spacing:20){
//            AsyncImage(url:album.imageURL){img in
//                img.resizable().scaledToFit()
//            }placeholder:{Color.black.opacity(0.4)}
//             .cornerRadius(14).frame(height:300).neonGlow(.pink)
//
//            Text(album.name).font(.largeTitle.weight(.bold).monospaced()).foregroundColor(.cyan)
//            Text(album.artistNames).foregroundColor(.white.opacity(0.8)).font(.headline.monospaced())
//            Text("🎶 \(album.total_tracks) Tracks • 📅 \(album.release_date)")
//                .foregroundColor(.white.opacity(0.7))
//                .font(.subheadline.monospaced())
//
//            Spacer()
//
//            Button {
//                UIApplication.shared.open(URL(string:album.external_urls.spotify)!)
//            } label: {
//                HStack {
//                    Image(systemName:"play.fill")
//                    Text("Play in Spotify")
//                }.padding().font(.title3.bold().monospaced()).foregroundColor(.white)
//                .background(Capsule().fill(Color.green)).neonGlow(.cyan)
//            }
//            Spacer()
//        }
//        .padding()
//        .background(
//            LinearGradient(colors:[.indigo,.black],startPoint:.top,endPoint:.bottom)
//            .edgesIgnoringSafeArea(.bottom)
//        )
//        .navigationBarTitle("🎵 Details", displayMode:.inline)
//    }
//}
//#Preview("RetroSpotifyExplorer") {
//    RetroSpotifyExplorer()
//}
//
//// MARK: - App Entry Point
//@main
//struct RetroSpotifyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            RetroSpotifyExplorer()
//        }
//    }
//}
