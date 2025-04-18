////
////  MusicPlayerView_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//import Combine
//
//// MARK: - Model (Mock data)
//struct Track: Identifiable {
//    let id = UUID()
//    let title: String
//    let artist: String
//    let artwork: String
//    let duration: Double
//}
//
//// Example mock playlist
//struct MockPlaylist {
//    static let tracks = [
//        Track(title: "Melting Horizons", artist: "Lazy B.", artwork: "My-meme-microphone", duration: 223),
//        Track(title: "Skyline Reunion", artist: "Midnight Groove", artwork: "My-meme-heineken", duration: 198),
//        Track(title: "Ocean Waves", artist: "Blue Alpha", artwork: "My-meme-red-wine-glass", duration: 241)
//    ]
//}
//
//// MARK: - ViewModel
//class MusicPlayerViewModel: ObservableObject {
//    @Published var currentTrack: Track = MockPlaylist.tracks[0]
//    @Published var isPlaying: Bool = false
//    @Published var currentTime: Double = 0
//    
//    private var playbackCancellable: AnyCancellable?
//    
//    func togglePlayPause() {
//        isPlaying.toggle()
//        if isPlaying {
//            startTimer()
//        } else {
//            stopTimer()
//        }
//    }
//    
//    func previousTrack() {
//        guard let currentIndex = MockPlaylist.tracks.firstIndex(where: { $0.id == currentTrack.id }) else { return }
//        let previousIndex = currentIndex == 0 ? MockPlaylist.tracks.count - 1 : currentIndex - 1
//        loadTrack(at: previousIndex)
//    }
//    
//    func nextTrack() {
//        guard let currentIndex = MockPlaylist.tracks.firstIndex(where: { $0.id == currentTrack.id }) else { return }
//        let nextIndex = (currentIndex + 1) % MockPlaylist.tracks.count
//        loadTrack(at: nextIndex)
//    }
//    
//    func loadTrack(at index: Int) {
//        stopTimer()
//        currentTrack = MockPlaylist.tracks[index]
//        currentTime = 0
//        if isPlaying {
//            startTimer()
//        }
//    }
//    
//    func seekTo(time: Double) {
//        currentTime = min(max(0, time), currentTrack.duration)
//    }
//    
//    private func startTimer() {
//        playbackCancellable = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//                if self.currentTime < self.currentTrack.duration {
//                    self.currentTime += 1
//                } else {
//                    self.nextTrack()
//                }
//            }
//    }
//    
//    private func stopTimer() {
//        playbackCancellable?.cancel()
//    }
//}
//
//// MARK: - SwiftUI View
//struct MusicPlayerView: View {
//    @ObservedObject private var viewModel = MusicPlayerViewModel()
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            headerView
//            trackArtworkView
//            trackDetailView
//            sliderView
//            playbackButtons
//            premiumButton
//        }
//        .padding()
//        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
//        .onAppear {
//            // preload initial state or fetch from backend in real scenario
//        }
//    }
//}
//
//// MARK: - UI Components
//private extension MusicPlayerView {
//    var headerView: some View {
//        HStack {
//            Button(action: {}) {
//                Image(systemName: "chevron.down")
//                    .font(.headline)
//                    .foregroundColor(.primary)
//            }
//            Spacer()
//            Text("Now Playing")
//                .font(.headline)
//                .bold()
//            Spacer()
//            Button(action: {
//                // Favourite track action
//            }) {
//                Image(systemName: "heart")
//                    .foregroundColor(.pink)
//                    .font(.headline)
//            }
//        }
//    }
//    
//    var trackArtworkView: some View {
//        Image(viewModel.currentTrack.artwork)
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 300, height: 300)
//            .clipped()
//            .cornerRadius(15)
//            .shadow(radius: 10)
//            .accessibility(label: Text(viewModel.currentTrack.title))
//    }
//    
//    var trackDetailView: some View {
//        VStack(spacing: 4) {
//            Text(viewModel.currentTrack.title)
//                .font(.title2)
//                .fontWeight(.bold)
//            Text(viewModel.currentTrack.artist)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//        }
//        .accessibilityElement(children: .combine)
//    }
//    
//    var sliderView: some View {
//        VStack {
//            Slider(value: Binding(
//                get: { viewModel.currentTime },
//                set: { viewModel.seekTo(time: $0) }
//            ), in: 0...viewModel.currentTrack.duration)
//            
//            HStack {
//                Text(timeFormatted(viewModel.currentTime))
//                Spacer()
//                Text(timeFormatted(viewModel.currentTrack.duration))
//            }
//            .font(.caption)
//            .foregroundColor(.secondary)
//        }
//    }
//    
//    var playbackButtons: some View {
//        HStack(spacing: 60) {
//            Button(action: viewModel.previousTrack) {
//                Image(systemName: "backward.fill")
//                    .font(.title)
//            }
//            Button(action: viewModel.togglePlayPause) {
//                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                    .font(.system(size: 60))
//            }
//            Button(action: viewModel.nextTrack) {
//                Image(systemName: "forward.fill")
//                    .font(.title)
//            }
//        }
//        .buttonStyle(BorderlessButtonStyle())
//    }
//    
//    var premiumButton: some View {
//        Button(action: {
//            // premium action (practical upsell)
//        }) {
//            Text("Unlock Premium")
//                .font(.headline)
//                .bold()
//                .padding()
//                .frame(maxWidth: .infinity)
//                .foregroundColor(.white)
//                .background(Color.blue)
//                .cornerRadius(12)
//        }
//    }
//}
//
//// MARK: - Helper Methods
//private extension MusicPlayerView {
//    func timeFormatted(_ time: Double) -> String {
//        let minutes = Int(time) / 60
//        let seconds = Int(time) % 60
//        return String(format: "%01d:%02d", minutes, seconds)
//    }
//}
//
//// MARK: - Preview
//struct MusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicPlayerView()
//            .preferredColorScheme(.light)
//            .previewDevice("iPhone 15 Pro")
//        
//        MusicPlayerView()
//            .preferredColorScheme(.dark)
//            .previewDevice("iPhone 15 Pro")
//    }
//}
