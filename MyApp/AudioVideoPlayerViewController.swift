//
//  AudioVideoPlayerViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/19/24.
//
//

import UIKit
import AVKit
import AVFoundation

// MARK: - Strategy Protocol

protocol VideoSource {
    func getPlayerItem() -> AVPlayerItem?
}

// MARK: - Concrete Strategies

class LocalVideoSource: VideoSource {
    private let fileName: String
    private let fileType: String

    init(fileName: String, fileType: String) {
        self.fileName = fileName
        self.fileType = fileType
    }

    func getPlayerItem() -> AVPlayerItem? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            assertionFailure("Error: Local video file not found.")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)
        return AVPlayerItem(asset: asset)
    }
}

class RemoteVideoSource: VideoSource {
    private let videoURL: URL

    init(videoURL: URL) {
        self.videoURL = videoURL
    }

    func getPlayerItem() -> AVPlayerItem? {
        let asset = AVURLAsset(url: videoURL)
        return AVPlayerItem(asset: asset)
    }
}

// MARK: - AudioVideoPlayerViewController

class AudioVideoPlayerViewController: UIViewController {

    // MARK: - Properties

    private var playerViewController: AVPlayerViewController!
    private var player: AVPlayer?
    private var videoSource: VideoSource?
    private var playerStatusObserver: NSKeyValueObservation?
    
    private let stackViewSpacing: CGFloat = 10
    private let stackViewLeadingMargin: CGFloat = 20
    private let stackViewBottomMargin: CGFloat = -20

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize with a local video source
        videoSource = LocalVideoSource(fileName: "Khoa_Ly_Biet_video", fileType: "mp4")

        setupPlayer()
        setupPlaybackControls()
    }

    deinit {
        player?.pause()
        removeObservers()
    }
}

// MARK: - Player Setup

extension AudioVideoPlayerViewController {

    private func setupPlayer() {
        // Get the player item from the video source
        guard let item = videoSource?.getPlayerItem() else {
            print("Error: Unable to load video.")
            return
        }

        // Initialize the player
        player = AVPlayer(playerItem: item)

        // Set up the player view controller
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false

        // Add the player view controller to the hierarchy
        addPlayerViewController()

        addObservers()
    }

    private func addPlayerViewController() {
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.bounds
        playerViewController.didMove(toParent: self)
    }
}

// MARK: - Playback Controls

extension AudioVideoPlayerViewController {

    private func setupPlaybackControls() {
        // Create and configure the buttons
        let buttons = [("Play", #selector(playTapped)),
                       ("Pause", #selector(pauseTapped)),
                       ("Seek +10s", #selector(seekTapped)),
                       ("Rate 1.5x", #selector(rateTapped)),
                       ("Current Time", #selector(currentTimeTapped)),
                       ("Switch Source", #selector(switchSourceTapped))].map { (title, action) in
            return createButton(title: title, action: action)
        }

        // Arrange buttons in a stack view
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .vertical
        stackView.spacing = stackViewSpacing
        stackView.alignment = .center
        configureStackViewConstraints(stackView)
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func configureStackViewConstraints(_ stackView: UIStackView) {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: stackViewLeadingMargin),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: stackViewBottomMargin)
        ])
    }

    // Playback Controls Actions

    @objc private func playTapped() {
        player?.play()
    }

    @objc private func pauseTapped() {
        player?.pause()
    }

    @objc private func seekTapped() {
        guard let player = player else { return }
        let timeInterval: Float64 = 10.0
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + timeInterval

        if let duration = player.currentItem?.duration {
            let durationSeconds = CMTimeGetSeconds(duration)
            if newTime < durationSeconds {
                let time = CMTime(seconds: newTime, preferredTimescale: 600)
                player.seek(to: time)
            }
        }
    }

    @objc private func rateTapped() {
        guard let player = player else { return }
        if player.rate != 1.5 {
            player.rate = 1.5
        } else {
            player.rate = 1.0
        }
    }

    @objc private func currentTimeTapped() {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let alert = UIAlertController(title: "Current Time", message: "Current playback time: \(currentTime) seconds", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func switchSourceTapped() {
        // Toggle between local and remote sources
        if videoSource is RemoteVideoSource {
            videoSource = LocalVideoSource(fileName: "localVideoFileName", fileType: "mp4")
        } else {
            guard let remoteURL = URL(string: "https://www.example.com/path/to/your/video.mp4") else { return }
            videoSource = RemoteVideoSource(videoURL: remoteURL)
        }

        // Reinitialize the player with the new source
        player?.pause()
        removeObservers()
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()

        setupPlayer()
    }
}

// MARK: - Observers

extension AudioVideoPlayerViewController {

    private func addObservers() {
        guard let item = player?.currentItem else { return }
        
        playerStatusObserver = item.observe(\.status, options: [.initial, .new]) { [weak self] (item, change) in
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    print("Player item is ready to play.")
                case .failed:
                    if let error = item.error {
                        print("Player item failed: \(error.localizedDescription)")
                    }
                default:
                    break
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinish(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
    }

    private func removeObservers() {
        playerStatusObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func playbackDidFinish(_ notification: Notification) {
        print("Playback finished.")
    }
}

