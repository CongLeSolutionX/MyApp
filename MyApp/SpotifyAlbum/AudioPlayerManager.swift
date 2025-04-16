//
//  AudioPlayerManager.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import Foundation
import AVFoundation
import Combine // For @Published

class AudioPlayerManager: ObservableObject {
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?

    // Published properties to update the UI
    @Published var isPlaying: Bool = false
    @Published var currentlyPlayingTrackID: UUID? = nil // Track which item is playing
    @Published var errorMessage: String? = nil

    // Combine cancellables for player status observation (optional but good practice)
    private var playerStatusObserver: AnyCancellable?
    private var playerEndTimeObserver: AnyCancellable?

    init() {
        // Configure audio session for playback (important for background audio, etc.)
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio Session Configured")
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
            self.errorMessage = "Failed to configure audio session."
        }
    }

    func playTrack(id: UUID, urlString: String) {
        // Stop current playback before starting new one
        stop()

        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL string - \(urlString)")
            self.errorMessage = "Invalid audio URL."
            resetState()
            return
        }

        // Create player item and player
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        // Observe player item status
        playerStatusObserver = playerItem?.publisher(for: \.status)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .readyToPlay:
                    print("Player ready to play: \(urlString)")
                    self.player?.play()
                    self.isPlaying = true
                    self.currentlyPlayingTrackID = id
                    self.errorMessage = nil // Clear previous errors
                case .failed:
                    print("Error: Player failed to load. URL: \(urlString), Error: \(self.playerItem?.error?.localizedDescription ?? "Unknown error")")
                    self.errorMessage = "Failed to load audio. Please try again."
                    self.resetState()
                case .unknown:
                    print("Player status unknown.")
                    self.errorMessage = "Could not load audio."
                    self.resetState()
                @unknown default:
                    print("Unknown player status.")
                    self.resetState()
                }
            }

        // Observe when playback ends
        playerEndTimeObserver = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                print("Playback finished naturally.")
                self?.stop() // Reset state when track finishes
            }
    }

    func togglePlayPause(for trackId: UUID, urlString: String?) {
        if currentlyPlayingTrackID == trackId {
            // It's the currently playing track, toggle its state
            if isPlaying {
                pause()
            } else {
                resume()
            }
        } else {
            // It's a new track, play it
            if let url = urlString {
                playTrack(id: trackId, urlString: url)
            } else {
                 print("Error: No URL provided for track ID \(trackId)")
                 self.errorMessage = "Audio URL missing."
                 resetState()
            }
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        print("Playback Paused")
    }

    func resume() {
        // Ensure player exists and item is ready or likely ready
        if player?.currentItem != nil {
            player?.play()
            isPlaying = true
            print("Playback Resumed")
        } else {
            print("Cannot resume, player not ready.")
            // Optionally attempt to replay if state seems inconsistent
        }
    }

    func stop() {
        player?.pause() // Pause playback
        player = nil      // Release the player instance
        playerItem = nil  // Release the player item
        resetState()
        print("Playback Stopped and Player Reset")
    }

    private func resetState() {
         isPlaying = false
         currentlyPlayingTrackID = nil
        // Keep potential error message until a new action clears it
         // Cancel observers manually if player is being destroyed
         playerStatusObserver?.cancel()
         playerEndTimeObserver?.cancel()
    }

    deinit {
        print("AudioPlayerManager deinit")
        // Ensure observers are cancelled if the manager is destroyed
        playerStatusObserver?.cancel()
        playerEndTimeObserver?.cancel()
        // Maybe deactivate audio session if appropriate for app lifecycle
         try? AVAudioSession.sharedInstance().setActive(false)
    }
}
