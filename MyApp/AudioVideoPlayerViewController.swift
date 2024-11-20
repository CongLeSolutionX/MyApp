//
//  AudioVideoPlayerViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/19/24.
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
    let fileName: String
    let fileType: String

    init(fileName: String, fileType: String) {
        self.fileName = fileName
        self.fileType = fileType
    }

    func getPlayerItem() -> AVPlayerItem? {
        if let path = Bundle.main.path(forResource: fileName, ofType: fileType) {
            let url = URL(fileURLWithPath: path)
            let asset = AVAsset(url: url)
            return AVPlayerItem(asset: asset)
        } else {
            print("Error: Local video file not found.")
            return nil
        }
    }
}

class RemoteVideoSource: VideoSource {
    let videoURL: URL

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

    var playerViewController: AVPlayerViewController!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!

    var videoSource: VideoSource!

    var playButton: UIButton!
    var pauseButton: UIButton!
    var seekButton: UIButton!
    var rateButton: UIButton!
    var currentTimeButton: UIButton!
    var switchSourceButton: UIButton!

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set the initial video source to a local source
        videoSource = LocalVideoSource(fileName: "Khoa_Ly_Biet_video", fileType: "mp4")
        
        // Set the initial video source to a remote source
        //let remoteURL = URL(string: "https://www.example.com/path/to/your/video.mp4")!
        //videoSource = RemoteVideoSource(videoURL: remoteURL)

        setupPlayer()
        setupPlaybackControls()
    }

    deinit {
        removeObservers()
    }
}

// MARK: - Player Setup

extension AudioVideoPlayerViewController {

    func setupPlayer() {
        // Get the player item from the video source
        guard let item = videoSource.getPlayerItem() else {
            print("Error: Unable to load video.")
            return
        }
        playerItem = item

        // Initialize the player with the player item
        player = AVPlayer(playerItem: playerItem)

        // Set up the player view controller
        playerViewController = AVPlayerViewController()
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

extension AudioVideoPlayerViewController {

    func setupPlaybackControls() {
        // Play Button
        playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        // Pause Button
        pauseButton = UIButton(type: .system)
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)

        // Seek Button
        seekButton = UIButton(type: .system)
        seekButton.setTitle("Seek +10s", for: .normal)
        seekButton.addTarget(self, action: #selector(seekTapped), for: .touchUpInside)

        // Rate Button
        rateButton = UIButton(type: .system)
        rateButton.setTitle("Rate 1.5x", for: .normal)
        rateButton.addTarget(self, action: #selector(rateTapped), for: .touchUpInside)

        // Current Time Button
        currentTimeButton = UIButton(type: .system)
        currentTimeButton.setTitle("Current Time", for: .normal)
        currentTimeButton.addTarget(self, action: #selector(currentTimeTapped), for: .touchUpInside)

        // Switch Source Button
        switchSourceButton = UIButton(type: .system)
        switchSourceButton.setTitle("Switch Source", for: .normal)
        switchSourceButton.addTarget(self, action: #selector(switchSourceTapped), for: .touchUpInside)

        // Arrange buttons in a stack view
        let stackView = UIStackView(arrangedSubviews: [playButton, pauseButton, seekButton, rateButton, currentTimeButton, switchSourceButton])
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

    // Playback Controls Actions

    @objc func playTapped() {
        player.play()
    }

    @objc func pauseTapped() {
        player.pause()
    }

    @objc func seekTapped() {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 10.0

        if let duration = player.currentItem?.duration {
            let durationSeconds = CMTimeGetSeconds(duration)
            if newTime < durationSeconds {
                let time = CMTime(seconds: newTime, preferredTimescale: 1)
                player.seek(to: time)
            }
        }
    }

    @objc func rateTapped() {
        if player.rate != 1.5 {
            player.rate = 1.5
            rateButton.setTitle("Rate 1.0x", for: .normal)
        } else {
            player.rate = 1.0
            rateButton.setTitle("Rate 1.5x", for: .normal)
        }
    }

    @objc func currentTimeTapped() {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let alert = UIAlertController(title: "Current Time", message: "Current playback time: \(currentTime) seconds", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc func switchSourceTapped() {
        // Toggle between local and remote sources
        if videoSource is RemoteVideoSource {
            videoSource = LocalVideoSource(fileName: "localVideoFileName", fileType: "mp4")
        } else {
            let remoteURL = URL(string: "https://www.example.com/path/to/your/video.mp4")!
            videoSource = RemoteVideoSource(videoURL: remoteURL)
        }

        // Reinitialize the player with the new source
        player.pause()
        removeObservers()
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()

        setupPlayer()
    }
}

// MARK: - Observers and Notifications

extension AudioVideoPlayerViewController {

    func addObservers() {
        if let item = playerItem {
            item.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinish(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
        }
    }

    func removeObservers() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "status" else { return }

        switch playerItem.status {
        case .readyToPlay:
            print("Player item is ready to play.")
        case .failed:
            if let error = playerItem.error {
                print("Player item failed: \(error.localizedDescription)")
            }
        default:
            break
        }
    }

    @objc func playbackDidFinish(_ notification: Notification) {
        print("Playback finished.")
    }
}
