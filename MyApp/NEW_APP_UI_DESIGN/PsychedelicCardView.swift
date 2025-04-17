//
//  PsychedelicCardView.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import SwiftUI

struct AlbumCard: View {
    let album: AlbumItem
    @State private var animateGradient = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Artwork Image + Gradient
            ZStack {
                AsyncImage(url: album.bestImageURL){ phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure, .empty:
                        Rectangle()
                            .fill(LinearGradient(colors: [.purple, .blue],
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing))
                    @unknown default:
                        EmptyView()
                    }
                }
                .overlay(psychedelicGradient)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .frame(height: 350)
                .clipped()
                .shadow(radius: 10)
                
                // Psychedelic Animations
                PsychedelicWave()
                    .blendMode(.overlay)
                    .opacity(0.3)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            // Album Information Area
            VStack(alignment: .leading, spacing: 6) {
                Text(album.name)
                    .font(.custom("Bodoni 72 Oldstyle", size: 20))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .lineLimit(1)
                    .padding(.bottom, 1)
                
                Text(album.formattedArtists)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                
                HStack {
                    Text(album.formattedReleaseDate())
                    Text("• \(album.total_tracks) tracks")
                }
                .font(.caption)
                .padding(6)
                .background(.ultraThinMaterial.opacity(0.6))
                .clipShape(Capsule())
                .foregroundColor(.white)
                
                Button {
                    UIApplication.shared.open(URL(string: album.external_urls.spotify)!)
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("PLAY ON SPOTIFY")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(Color.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.green.opacity(0.8))
                .clipShape(Capsule())
                .shadow(radius: 2)
            }
            .padding()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .onAppear(perform: {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        })
    }
    
    var psychedelicGradient: some View {
        LinearGradient(gradient: Gradient(colors: [.pink, .purple, .blue, .green, .yellow, .orange]),
                       startPoint: animateGradient ? .bottomLeading : .topTrailing,
                       endPoint: animateGradient ? .topTrailing : .bottomLeading)
            .opacity(0.25)
            .blendMode(.overlay)
    }
}
#Preview("AlbumCard") {
      
    let album = SampleData.sampleAlbumItems.first
    AlbumCard(album: album!)
        .preferredColorScheme(.dark)
}

struct PsychedelicWave: View {
    @State var animate = false
    var body: some View {
        GeometryReader { geo in
            ZStack {
                WaveShape(yOffset: animate ? 0.5 : -0.5)
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [.orange, .pink, .purple, .blue]),
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )
                    .animation(Animation.linear(duration: 5).repeatForever(autoreverses:true), value: animate)
            }
            .onAppear {
                animate.toggle()
            }
        }
    }
}

struct WaveShape: Shape {
    var yOffset: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        for x in stride(from: 0, to: rect.width, by: 10) {
            let normalizedX = x / rect.width
            let normalizedSine = sin((normalizedX + yOffset) * .pi * 2)
            let y = normalizedSine * 24 + rect.midY
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
