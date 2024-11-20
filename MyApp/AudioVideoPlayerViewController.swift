//
//  AudioVideoPlayerViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/19/24.
//

import UIKit
import AVKit
import AVFoundation

class AudioVideoPlayerViewController: UIViewController {

    // MARK: - Properties

    var playerViewController: AVPlayerViewController!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!

    let videoURL = URL(string: "https://www.example.com/path/to/your/video.mp4")!

    var playButton: UIButton!
    var pauseButton: UIButton!
    var seekButton: UIButton!
    var rateButton: UIButton!
    var currentTimeButton: UIButton!

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        setupPlaybackControls()
    }

    deinit {
        playerItem.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - AudioVideoPlayerViewController Helper Methods
extension AudioVideoPlayerViewController {

    func setupPlayer() {
        playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)

        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false

        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.bounds
        playerViewController.didMove(toParent: self)

        addObservers()
    }

    func setupPlaybackControls() {
        playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        pauseButton = UIButton(type: .system)
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)

        seekButton = UIButton(type: .system)
        seekButton.setTitle("Seek +10s", for: .normal)
        seekButton.addTarget(self, action: #selector(seekTapped), for: .touchUpInside)

        rateButton = UIButton(type: .system)
        rateButton.setTitle("Rate 1.5x", for: .normal)
        rateButton.addTarget(self, action: #selector(rateTapped), for: .touchUpInside)

        currentTimeButton = UIButton(type: .system)
        currentTimeButton.setTitle("Current Time", for: .normal)
        currentTimeButton.addTarget(self, action: #selector(currentTimeTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [playButton, pauseButton, seekButton, rateButton, currentTimeButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

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

    func addObservers() {
        playerItem.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinish(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
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
