//
//  AVKitFrameworkView.swift
//  MyApp
//
//  Created by Cong Le on 3/24/25.
//
import UIKit
import AVKit
import AVFoundation
import Combine

// MARK: - Custom Delegate

/// A custom delegate protocol to handle events from `AVPlayerViewController`.
protocol PlayerViewControllerDelegate: AnyObject {
    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController)
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController)
    func playerViewController(_ playerViewController: AVPlayerViewController, failedWithError error: Error)
    func playerViewControllerReadyToPlay(_ playerViewController: AVPlayerViewController)
}

// MARK: - Main View Controller

class ViewController: UIViewController, AVPlayerViewControllerDelegate, AVAssetDownloadDelegate, URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print(#function)
    }
    
    
    // MARK: - Properties
    
    private var playerViewController: AVPlayerViewController!
    private var player: AVQueuePlayer! // Use AVQueuePlayer for playlist capability
    private var playerLooper: AVPlayerLooper?
    private var playerItem: AVPlayerItem!
    private var cancellables = Set<AnyCancellable>() // For Combine subscriptions
    weak var customDelegate: PlayerViewControllerDelegate?
    private let contentOverlay = UIView()
    private var isSeeking = false  // Flag to prevent updates during seek
    
    // URLs for demonstration. Replace with your actual video URLs.
    private let videoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    private let hlsURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")! // Example HLS stream.
    
    // MARK: - Observations Tokens
    
    private var timeControlStatusObserver: NSKeyValueObservation?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var loadedTimeRangesObserver: NSKeyValueObservation?
    private var periodicTimeObserverToken: Any?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        setupUI()
        observePlayback()
        //        downloadAsset(url: hlsURL)
        playVideo()
    }
    
    deinit {
        // Invalidate block based KVO observers
        timeControlStatusObserver?.invalidate()
        playerItemStatusObserver?.invalidate()
        loadedTimeRangesObserver?.invalidate()
        
        // Remove periodic time observer
        if let token = periodicTimeObserverToken {
            player.removeTimeObserver(token)
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupPlayer() {
        // Use HLS URL for a more advanced demonstration.
        playerItem = AVPlayerItem(url: hlsURL)
        player = AVQueuePlayer(items: [playerItem])
        
        // Setup AVPlayerViewController and assign its properties.
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.delegate = self
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true // Enable automatic PiP.
        playerViewController.updatesNowPlayingInfoCenter = true // Display on lock screen.
        playerViewController.showsPlaybackControls = true // Display controls.
        
        // Add AVPlayerViewController as a child view controller.
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
        // Create a player looper for the current item.
        createPlayerLooper()
    }
    
    private func createPlayerLooper() {
        guard let currentItem = player.currentItem else { return }
        playerLooper = AVPlayerLooper(player: player, templateItem: currentItem)
    }
    
    private func setupUI() {
        // Layout playerViewController's view.
        playerViewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 300)
        
        // Setup and add a custom content overlay.
        contentOverlay.backgroundColor = UIColor.clear // Transparent overlay.
        if let overlayView = playerViewController.contentOverlayView {
            overlayView.addSubview(contentOverlay)
            contentOverlay.frame = overlayView.bounds
            contentOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        // Example: Add a custom label to the overlay.
        let customLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 200, height: 30))
        customLabel.text = "My Custom Overlay"
        customLabel.textColor = .white
        customLabel.textAlignment = .center
        contentOverlay.addSubview(customLabel)
    }
    
    // MARK: - Playback Control
    
    private func playVideo() {
        guard let player = playerViewController.player else { return }
        if playerItem.status == .readyToPlay {
            player.play()
        } else {
            // The observer will call play() once ready.
            print("Player item not ready; waiting for observer callback.")
        }
    }
    
    private func pauseVideo() {
        playerViewController.player?.pause()
    }
    
    private func seekToTime(seconds: Double) {
        guard let player = playerViewController.player else { return }
        isSeeking = true
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            if finished {
                self?.isSeeking = false
            }
        }
    }
    
    private func addNextItemToQueue() {
        guard let newItemURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4") else { return }
        let newItem = AVPlayerItem(url: newItemURL)
        if player.canInsert(newItem, after: player.currentItem) {
            player.insert(newItem, after: player.currentItem)
            createPlayerLooper() // Recreate looper to loop current item
        }
    }
    
    private func skipToNextItem() {
        player.advanceToNextItem()
        createPlayerLooper() // Recreate looper if needed.
    }
    
    // MARK: - Playback Observations
    
    private func observePlayback() {
        // Observe player's timeControlStatus using block-based KVO.
        timeControlStatusObserver = player.observe(\.timeControlStatus, options: [.new, .old]) { [weak self] player, change in
            guard let self = self else { return }
            switch player.timeControlStatus {
            case .paused:
                print("Playback paused")
            case .waitingToPlayAtSpecifiedRate:
                if let reason = player.reasonForWaitingToPlay {
                    print("Waiting Reason: \(reason)")
                }
            case .playing:
                print("Playback playing")
            @unknown default:
                break
            }
        }
        
        // Observe playerItem's status.
        playerItemStatusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, change in
            guard let self = self else { return }
            switch item.status {
            case .readyToPlay:
                print("Player item ready to play")
                self.customDelegate?.playerViewControllerReadyToPlay(self.playerViewController)
                self.player.play() // Auto play when ready.
            case .failed:
                if let error = item.error {
                    print("Failed to load video: \(error)")
                    self.customDelegate?.playerViewController(self.playerViewController, failedWithError: error)
                }
            default:
                break
            }
        }
        
        // Observe loadedTimeRanges for progress updates if needed.
        loadedTimeRangesObserver = playerItem.observe(\.loadedTimeRanges, options: [.new]) { [weak self] item, _ in
            // You can update a progress bar here if required.
        }
        
        // Combine publisher for player's currentItem duration.
        player.publisher(for: \.currentItem?.duration)
            .sink { [weak self] duration in
                guard let self = self, let duration = duration else { return }
                print("Total Duration: \(duration.seconds)")
            }
            .store(in: &cancellables)
        
        // Add periodic time observer (remembering its token).
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        periodicTimeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            if !self.isSeeking {
                print("Current Time: \(time.seconds)")
            }
            // Process timed metadata if available.
            if let metadata = self.playerItem.timedMetadata {
                for item in metadata {
                    if let commonKey = item.commonKey?.rawValue, let value = item.value {
                        print("Metadata: \(commonKey) - \(value)")
                    }
                }
            }
        }
    }
    
    // MARK: - AVPlayerViewControllerDelegate Methods (Picture in Picture)
    
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        customDelegate?.playerViewControllerDidStartPictureInPicture(playerViewController)
    }
    
    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        // Additional implementation if needed.
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        customDelegate?.playerViewController(playerViewController, failedWithError: error)
        print("PiP Failed: \(error)")
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Restore your UI after PiP ends.
        completionHandler(true)
    }
    
    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return true
    }
    
    // MARK: - Download Asset
    
    //    private func downloadAsset(url: URL) {
    //        // Create a background URLSession configuration with a unique identifier.
    //        let config = URLSessionConfiguration.background(withIdentifier: "com.example.downloadSession")
    //        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    //
    //        // Create an AVURLAsset and start the download task.
    //        let asset = AVURLAsset(url: url)
    //        if let downloadTask = session.avAssetDownloadTask(with: asset,
    //                                                          assetTitle: "MyDownloadedVideo",
    //                                                          assetArtworkData: nil,
    //                                                          options: [AVAssetDownloadTaskMinimumBitRateKey: 2_000_000]) {
    //            downloadTask.resume()
    //        }
    
    //        session.dataTask(with: URLRequest(url: asset)) { data, respponse, error in
    //            print(#function)
    //            print(data)
    //        }
}

// MARK: - URLSession & Download Delegate Methods

func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    print(#function)
}

func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    if let error = error {
        print("URLSession became invalid: \(error.localizedDescription)")
        // Optionally, reinitialize the session if necessary.
    }
}

func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let error = error {
        print("Download Task Failed: \(error)")
        // Handle download failure (e.g., show an alert).
    } else {
        print("Download completed successfully")
    }
}

func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
    print("Asset Downloaded to: \(location)")
    // Move the temporary file to a permanent location.
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Failed to access Documents directory")
        return
    }
    let downloadsDirectory = documentsDirectory.appendingPathComponent("MyDownloads")
    let destinationURL = downloadsDirectory.appendingPathComponent(assetDownloadTask.urlAsset.url.lastPathComponent)
    
    do {
        // Create the downloads directory if needed.
        try FileManager.default.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true)
        // Remove the file if it already exists.
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        // Move the downloaded file to the destination URL.
        try FileManager.default.moveItem(at: location, to: destinationURL)
        // Persist the destination URL (example: using UserDefaults).
        UserDefaults.standard.set(destinationURL, forKey: "downloadedVideoURL")
    } catch {
        print("Failed to move downloaded file: \(error)")
    }
}

func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask,
                didLoad timeRange: CMTimeRange,
                totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                timeRangeExpectedToLoad: CMTimeRange) {
    // Calculate and print download progress.
    let progress = loadedTimeRanges.reduce(0.0) { result, value -> Double in
        let range = value.timeRangeValue
        return result + range.duration.seconds / timeRangeExpectedToLoad.duration.seconds
    }
    print("Download Progress: \(progress * 100)%")
    
    // Update UI on the main thread if needed.
    DispatchQueue.main.async {
        // For instance: self.progressView.progress = Float(progress)
    }
}

