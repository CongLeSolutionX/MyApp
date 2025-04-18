////
////  MusicPlayerView_V6.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//import AVFoundation
//import Combine
//
//// MARK: - Data Model
//struct Track: Identifiable, Codable, Equatable {
//    let id: UUID
//    let title: String
//    let artist: String
//    let artwork: String // Name of artwork image in assets
//    let fileName: String // Local .mp3 file in project bundle
//}
//
//// MARK: - Playlist Provider
//struct PlaylistProvider {
//    static let tracks: [Track] = [
//        Track(id: UUID(), title: "Morning Glow", artist: "Sunrise Ensemble", artwork: "My-meme-orange_2", fileName: "song1"),
//        Track(id: UUID(), title: "Evening Chill", artist: "Lo-Fi Lounge", artwork: "My-meme-with-cap-2", fileName: "song2"),
//        Track(id: UUID(), title: "Night Dreams", artist: "SleepWave", artwork: "My-meme-orange", fileName: "song3")
//    ]
//}
//
//// MARK: - ViewModel
//class MusicPlayerViewModel: ObservableObject {
//    @Published var currentTrack: Track = PlaylistProvider.tracks[0]
//    @Published var isPlaying = false
//    @Published var currentTime: Double = 0
//    @Published var duration: Double = 0
//    @Published var isShuffle = false
//    @Published var isRepeat = false
//    @Published var favorites: Set<UUID> = []
//
//    private var audioPlayer: AVAudioPlayer?
//    private var timerSubscription: AnyCancellable?
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        loadFavorites()
//        setupAudioSession()
//        prepareToPlay(track: currentTrack)
//    }
//
//    // Audio Session Setup
//    private func setupAudioSession() {
//        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//        try? AVAudioSession.sharedInstance().setActive(true)
//    }
//
//    func prepareToPlay(track: Track) {
//        guard let path = Bundle.main.url(forResource: track.fileName, withExtension: "wav") else { return }
//        audioPlayer = try? AVAudioPlayer(contentsOf: path)
//        duration = audioPlayer?.duration ?? trackDurationFallback
//        audioPlayer?.prepareToPlay()
//        startProgressUpdate()
//    }
//
//    var trackDurationFallback: Double { 200 } // fallback duration if AVAudioPlayer fails to load
//
//    func playPauseToggle() {
//        guard let player = audioPlayer else { return }
//        if player.isPlaying {
//            player.pause()
//            isPlaying = false
//            stopProgressUpdate()
//        } else {
//            player.play()
//            isPlaying = true
//            startProgressUpdate()
//        }
//    }
//
//    func nextTrack() {
//        changeTrack(forward: true)
//    }
//
//    func previousTrack() {
//        if currentTime > 5 {
//            seek(to: 0)
//        } else {
//            changeTrack(forward: false)
//        }
//    }
//
//    func seek(to time: Double) {
//        audioPlayer?.currentTime = time
//        currentTime = time
//    }
//
//    private func changeTrack(forward: Bool) {
//        audioPlayer?.stop()
//        var idx = PlaylistProvider.tracks.firstIndex(of: currentTrack) ?? 0
//        idx = isShuffle ? Int.random(in: 0..<PlaylistProvider.tracks.count)
//                        : (forward ? (idx + 1) % PlaylistProvider.tracks.count
//                                   : (idx - 1 + PlaylistProvider.tracks.count) % PlaylistProvider.tracks.count)
//        currentTrack = PlaylistProvider.tracks[idx]
//        prepareToPlay(track: currentTrack)
//        audioPlayer?.play()
//        isPlaying = true
//        currentTime = 0
//    }
//
//    func toggleFavorite() {
//        if favorites.contains(currentTrack.id) {
//            favorites.remove(currentTrack.id)
//        } else {
//            favorites.insert(currentTrack.id)
//        }
//        saveFavorites()
//    }
//
//    private func saveFavorites() {
//        if let data = try? JSONEncoder().encode(favorites) {
//            UserDefaults.standard.set(data, forKey: "favorites")
//        }
//    }
//
//    private func loadFavorites() {
//        if let data = UserDefaults.standard.data(forKey: "favorites"),
//           let savedFavorites = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
//            favorites = savedFavorites
//        }
//    }
//
//    private func startProgressUpdate() {
//        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                guard let self = self, let player = self.audioPlayer else { return }
//                self.currentTime = player.currentTime
//                if !player.isPlaying && player.currentTime >= self.duration {
//                    self.trackFinishedPlaying()
//                }
//            }
//    }
//
//    private func stopProgressUpdate() {
//        timerSubscription?.cancel()
//    }
//
//    private func trackFinishedPlaying() {
//        if isRepeat {
//            seek(to: 0)
//            audioPlayer?.play()
//        } else {
//            nextTrack()
//        }
//    }
//}
//
//// MARK: - Player View
//struct MusicPlayerView: View {
//    @StateObject private var vm = MusicPlayerViewModel()
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(vm.currentTrack.artwork)
//                .resizable()
//                .scaledToFit()
//                .cornerRadius(12)
//                .shadow(radius: 5)
//
//            Text(vm.currentTrack.title)
//                .font(.title2).bold()
//            Text(vm.currentTrack.artist)
//                .foregroundColor(.secondary)
//
//            Slider(value: $vm.currentTime, in: 0...vm.duration, onEditingChanged: { editing in
//                if !editing { vm.seek(to: vm.currentTime) }
//            })
//            HStack {
//                Text(formattedTime(vm.currentTime))
//                Spacer()
//                Text(formattedTime(vm.duration))
//            }.font(.footnote).foregroundColor(.gray)
//
//            HStack(spacing: 50) {
//                ControlButton(systemName: "backward.fill", action: vm.previousTrack)
//                PlayPauseButton(isPlaying: vm.isPlaying, action: vm.playPauseToggle)
//                ControlButton(systemName: "forward.fill", action: vm.nextTrack)
//            }.font(.title)
//
//            HStack(spacing: 40) {
//                ToggleButton(systemName: vm.isShuffle ? "shuffle.circle.fill" : "shuffle.circle", active: vm.isShuffle) {
//                    vm.isShuffle.toggle()
//                }
//                ToggleButton(systemName: vm.isRepeat ? "repeat.1.circle.fill" : "repeat.circle", active: vm.isRepeat) {
//                    vm.isRepeat.toggle()
//                }
//                ToggleButton(systemName: vm.favorites.contains(vm.currentTrack.id) ? "heart.fill" : "heart", active: vm.favorites.contains(vm.currentTrack.id)) {
//                    vm.toggleFavorite()
//                }
//            }.font(.title2).foregroundColor(.accentColor)
//        }
//        .padding().animation(.easeInOut, value: vm.currentTrack)
//    }
//
//    func formattedTime(_ time: Double) -> String {
//        String(format: "%d:%02d", Int(time)/60, Int(time)%60)
//    }
//}
//
//// MARK: Reusable Controls
//struct ControlButton: View {
//    let systemName: String
//    let action: ()->Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: systemName)
//        }
//    }
//}
//
//struct PlayPauseButton: View {
//    var isPlaying: Bool
//    var action: ()->Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                .font(.system(size: 60))
//        }
//    }
//}
//
//struct ToggleButton: View {
//    var systemName: String
//    var active: Bool
//    var action: ()->Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: systemName)
//                .opacity(active ? 1.0 : 0.3)
//        }
//    }
//}
//
//// MARK: Preview
//struct MusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicPlayerView()
//    }
//}
