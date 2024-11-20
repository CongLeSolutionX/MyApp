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
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Error: Local video file not found.")
            return nil
        }
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
        let asset = AVAsset(url: videoURL)
        return AVPlayerItem(asset: asset)
    }
}

// MARK: - AudioVideoPlayerViewController

class AudioVideoPlayerViewController: UIViewController {

    // MARK: - Properties

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var videoSource: VideoSource?

    private let playerViewController = AVPlayerViewController()

    // Playback Controls
    private lazy var playButton: UIButton = createButton(title: "Play", action: #selector(playTapped))
    private lazy var pauseButton: UIButton = createButton(title: "Pause", action: #selector(pauseTapped))
    private lazy var seekButton: UIButton = createButton(title: "Seek +10s", action: #selector(seekTapped))
    private lazy var rateButton: UIButton = createButton(title: "Rate 1.5x", action: #selector(rateTapped))
    private lazy var currentTimeButton: UIButton = createButton(title: "Current Time", action: #selector(currentTimeTapped))
    private lazy var switchSourceButton: UIButton = createButton(title: "Switch Source", action: #selector(switchSourceTapped))

    private var timeObserverToken: Any?

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Set the initial video source to a local source
        videoSource = LocalVideoSource(fileName: "Khoa_Ly_Biet_video", fileType: "mp4")

        setupPlayer()
        setupPlaybackControls()
    }

    deinit {
        removeObservers()
    }
}

// MARK: - Player Setup

private extension AudioVideoPlayerViewController {

    func setupPlayer() {
        guard let playerItem = videoSource?.getPlayerItem() else {
            print("Error: Unable to load video.")
            return
        }
        self.playerItem = playerItem

        // Initialize the player with the player item
        player = AVPlayer(playerItem: playerItem)

        // Set up the player view controller
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false

        // Add the player view controller to the hierarchy
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.bounds
        playerViewController.didMove(toParent: self)

        addObservers()
    }
}

// MARK: - Playback Controls

private extension AudioVideoPlayerViewController {

    func setupPlaybackControls() {
        // Arrange buttons in a stack view
        let stackView = UIStackView(arrangedSubviews: [
            playButton,
            pauseButton,
            seekButton,
            rateButton,
            currentTimeButton,
            switchSourceButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center

        // Add the stack view to the view
        view.addSubview(stackView)

        // Set constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // Playback Controls Actions

    @objc func playTapped() {
        player?.play()
    }

    @objc func pauseTapped() {
        player?.pause()
    }

    @objc func seekTapped() {
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: currentTime.timescale))

        if let duration = player.currentItem?.duration, newTime < duration {
            player.seek(to: newTime)
        }
    }

    @objc func rateTapped() {
        guard let player = player else { return }
        if player.rate != 1.5 {
            player.rate = 1.5
            rateButton.setTitle("Rate 1.0x", for: .normal)
        } else {
            player.rate = 1.0
            rateButton.setTitle("Rate 1.5x", for: .normal)
        }
    }

    @objc func currentTimeTapped() {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let message = String(format: "Current playback time: %.2f seconds", currentTime)
        let alert = UIAlertController(title: "Current Time", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alert, animated: true)
    }

    @objc func switchSourceTapped() {
        player?.pause()
        removeObservers()
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()

        // Toggle between local and remote sources
        if videoSource is RemoteVideoSource {
            videoSource = LocalVideoSource(fileName: "Khoa_Ly_Biet_video", fileType: "mp4")
        } else {
            if let remoteURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
                videoSource = RemoteVideoSource(videoURL: remoteURL)
            } else {
                print("Error: Invalid remote URL.")
                return
            }
        }

        setupPlayer()
    }
}

// MARK: - Observers and Notifications

extension AudioVideoPlayerViewController {

    private func addObservers() {
        // Observe AVPlayerItem status
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.initial, .new], context: nil)
        // Observe playback completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackDidFinish(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }

    private func removeObservers() {
        if let playerItem = playerItem {
            playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        }
        NotificationCenter.default.removeObserver(self)
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    internal override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == #keyPath(AVPlayerItem.status),
              let playerItem = object as? AVPlayerItem else { return }

        switch playerItem.status {
        case .readyToPlay:
            print("Player item is ready to play.")
            player?.play()
        case .failed:
            if let error = playerItem.error {
                print("Player item failed: \(error.localizedDescription)")
            }
        default:
            break
        }
    }

    @objc private func playbackDidFinish(_ notification: Notification) {
        print("Playback finished.")
    }
}
