////
////  MusicPlayerView_V5.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//import AVFoundation
//import Combine
//
//// MARK: - Mock Data Model
//struct Track: Identifiable, Equatable {
//    let id = UUID()
//    let title: String
//    let artist: String
//    let artwork: String
//    let duration: Double
//}
//
//struct MockPlaylist {
//    static let tracks = [
//        Track(title: "Sunrise Serenade", artist: "Luminants", artwork: "My-meme-heineken", duration: 240),
//        Track(title: "Moonrise Dreams", artist: "NightWaves", artwork: "My-meme-orange", duration: 195),
//        Track(title: "City Streets", artist: "Jazz Cats", artwork: "My-meme-with-cap-2", duration: 210),
//        Track(title: "Evening Glow", artist: "LoFi Beats", artwork: "My-meme-red-wine-glass", duration: 185),
//        Track(title: "Ocean Breeze", artist: "ChillSoft", artwork: "My-meme-orange_1", duration: 255)
//    ]
//}
//
//// MARK: - ViewModel with Combine
//class MusicPlayerViewModel: ObservableObject {
//    @Published var currentTrack: Track = MockPlaylist.tracks.first!
//    @Published var isPlaying = false
//    @Published var currentTime: Double = 0
//    @Published var isShuffle = false
//    @Published var isRepeat = false
//    @Published var favorites: Set<UUID> = []
//    
//    private var cancellables = Set<AnyCancellable>()
//    private var timerCancellable: AnyCancellable?
//    
//    init() {
//        $isPlaying
//            .sink { [weak self] playing in
//                playing ? self?.startTimer() : self?.stopTimer()
//            }.store(in: &cancellables)
//    }
//    
//    func togglePlayPause() {
//        isPlaying.toggle()
//    }
//    
//    func nextTrack() {
//        guard let idx = MockPlaylist.tracks.firstIndex(of: currentTrack) else { return }
//        if isShuffle {
//            currentTrack = MockPlaylist.tracks.randomElement()!
//        } else {
//            currentTrack = MockPlaylist.tracks[(idx + 1) % MockPlaylist.tracks.count]
//        }
//        resetPlayback()
//    }
//    
//    func previousTrack() {
//        guard let idx = MockPlaylist.tracks.firstIndex(of: currentTrack) else { return }
//        let previousIdx = (idx - 1 + MockPlaylist.tracks.count) % MockPlaylist.tracks.count
//        currentTrack = MockPlaylist.tracks[previousIdx]
//        resetPlayback()
//    }
//    
//    func seek(to time: Double) {
//        currentTime = min(max(0, time), currentTrack.duration)
//    }
//    
//    func toggleFavorite() {
//        if favorites.contains(currentTrack.id) {
//            favorites.remove(currentTrack.id)
//        } else {
//            favorites.insert(currentTrack.id)
//        }
//    }
//    
//    func resetPlayback() {
//        currentTime = 0
//        if !isPlaying { isPlaying = true }
//    }
//    
//    private func startTimer() {
//        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//                self.currentTime += 1
//                if self.currentTime >= self.currentTrack.duration {
//                    self.playbackDidFinish()
//                }
//            }
//    }
//    
//    private func stopTimer() {
//        timerCancellable?.cancel()
//    }
//    
//    private func playbackDidFinish() {
//        if isRepeat {
//            resetPlayback()
//        } else {
//            nextTrack()
//        }
//    }
//}
//
//// MARK: - Main View
//struct MusicPlayerView: View {
//    @StateObject private var vm = MusicPlayerViewModel()
//    
//    var body: some View {
//        VStack(spacing: 15) {
//            headerView
//            artworkView
//            trackDetailsView
//            playbackSliderView
//            playbackControlsView
//            playbackModesView
//            playlistView
//        }
//        .padding()
//        .animation(.easeInOut(duration: 0.3), value: vm.currentTrack.id)
//    }
//}
//
//// MARK: - UI Components
//private extension MusicPlayerView {
//    var headerView: some View {
//        HStack {
//            Button(action:{}) {
//                Image(systemName:"chevron.down")
//                    .font(.title3).foregroundColor(.primary)
//            }
//            Spacer()
//            Text("Now Playing").font(.headline).bold()
//            Spacer()
//            Button(action:vm.toggleFavorite) {
//                Image(systemName: vm.favorites.contains(vm.currentTrack.id) ? "heart.fill":"heart")
//                    .font(.title2).foregroundColor(.pink)
//            }
//        }
//    }
//    
//    var artworkView: some View {
//        Image(vm.currentTrack.artwork)
//            .resizable()
//            .frame(width:300,height:300)
//            .cornerRadius(12)
//            .shadow(radius:8)
//    }
//    
//    var trackDetailsView: some View {
//        VStack(spacing:5) {
//            Text(vm.currentTrack.title).font(.title2).bold()
//            Text(vm.currentTrack.artist).font(.callout).foregroundColor(.secondary)
//        }
//    }
//    
//    var playbackSliderView: some View {
//        VStack {
//            Slider(value:Binding(
//                get:{vm.currentTime},
//                set:{vm.seek(to:$0)}
//            ), in:0...vm.currentTrack.duration)
//            
//            HStack {
//                Text(formatTime(vm.currentTime))
//                Spacer()
//                Text(formatTime(vm.currentTrack.duration))
//            }.font(.caption2).foregroundColor(.secondary)
//        }
//    }
//    
//    var playbackControlsView: some View {
//        HStack(spacing:60) {
//            Button(action: vm.previousTrack){
//                Image(systemName:"backward.fill").font(.title)
//            }
//            Button(action: vm.togglePlayPause){
//                Image(systemName: vm.isPlaying ? "pause.circle.fill":"play.circle.fill")
//                    .font(.system(size:60))
//            }
//            Button(action: vm.nextTrack){
//                Image(systemName:"forward.fill").font(.title)
//            }
//        }
//        .buttonStyle(.plain)
//    }
//    
//    var playbackModesView: some View {
//        HStack(spacing:30) {
//            Button(action:{ vm.isRepeat.toggle() }){
//                Image(systemName: vm.isRepeat ? "repeat.1":"repeat")
//                    .foregroundColor(vm.isRepeat ? .blue:.primary)
//                    .font(.title2)
//            }
//            Button(action:{ vm.isShuffle.toggle() }){
//                Image(systemName: "shuffle")
//                    .foregroundColor(vm.isShuffle ? .blue:.primary)
//                    .font(.title2)
//            }
//        }
//    }
//    
//    var playlistView: some View {
//        List(MockPlaylist.tracks){ track in
//            HStack {
//                VStack(alignment:.leading) {
//                    Text(track.title).bold()
//                    Text(track.artist).font(.caption).foregroundColor(.secondary)
//                }
//                Spacer()
//                if track.id == vm.currentTrack.id {
//                    Image(systemName: vm.isPlaying ? "speaker.wave.2.fill":"speaker.fill")
//                        .foregroundColor(.blue).animation(.easeIn)
//                }
//            }
//            .contentShape(Rectangle())
//            .onTapGesture {
//                vm.currentTrack = track
//                vm.resetPlayback()
//            }
//        }.listStyle(.plain).frame(height:150)
//    }
//    
//    func formatTime(_ time: Double) -> String {
//        String(format:"%d:%02d", Int(time)/60,Int(time)%60)
//    }
//}
//
//// MARK: - Preview with Mock Data Assets
//struct MusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group{
//            MusicPlayerView().preferredColorScheme(.light)
//            MusicPlayerView().preferredColorScheme(.dark)
//        }.previewDevice("iPhone 15 Pro")
//    }
//}
