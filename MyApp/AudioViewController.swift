//
//  AudioViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/19/24.
//

import UIKit
import AVFoundation
import AVKit

// Loading a local audio file
class AudioViewController2: UIViewController {

    var audioPlayer: AVAudioPlayer?

    @IBAction func playAudioButtonTapped(_ sender: UIButton) {
        // Get the path to the audio file
        if let path = Bundle.main.path(forResource: "Khoa_Ly_Biet_DJ_Remixed-Segmented", ofType: "mp3") {
            let audioURL = URL(fileURLWithPath: path)

            do {
                // Initialize the audio player
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.prepareToPlay()

                // Play the audio
                audioPlayer?.play()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
    }
}


// Loading a remote audio file
class AudioViewController: UIViewController {

    // Replace with your audio URL
    let audioURL = URL(string: "https://www.example.com/path/to/audio.mp3")!

    @IBAction func playAudioButtonTapped(_ sender: UIButton) {
        // Create an AVPlayer with the audio URL
        let player = AVPlayer(url: audioURL)

        // Create an AVPlayerViewController and set the player
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        // Present the AVPlayerViewController
        present(playerViewController, animated: true) {
            // Start audio playback
            player.play()
        }
    }
}
