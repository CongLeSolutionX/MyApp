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

class ViewController: UIViewController, AVPlayerViewControllerDelegate, AVAssetDownloadDelegate, URLSessionDelegate, URLSessionDownloadDelegate  {
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
    private var playerContext = 0 // Unique context for KVO
    private let contentOverlay = UIView()
    private var isSeeking = false  // Flag to prevent updates during seek

    // URLs for demonstration. Replace with your actual video URLs.
    private let videoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    private let hlsURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")! // Example HLS stream.
 //   private let localVideoURL: URL  //URL For offline video.

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        setupUI()
        observePlayback()
        downloadAsset(url: hlsURL)
        playVideo()
    }

    // MARK: - Setup

    private func setupPlayer() {
        // Use HLS URL for more advanced features demonstration.
        playerItem = AVPlayerItem(url: hlsURL)
        player = AVQueuePlayer(items: [playerItem])

        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.delegate = self
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true // Enable automatic PiP
        playerViewController.updatesNowPlayingInfoCenter = true // Display on lock screen
        playerViewController.showsPlaybackControls = true // Display controls

        // Add AVPlayerViewController as a child view controller
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)    // Important: notify the child

           createPlayerLooper()
    }


      private func createPlayerLooper() {
        guard let currentItem = player.currentItem else { return }
        playerLooper = AVPlayerLooper(player: player, templateItem: currentItem) // Loop currentItem
    }

    private func setupUI() {
        // Layout AVPlayerViewController's view
        playerViewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 300)

        // Setup and add a custom content overlay
        contentOverlay.backgroundColor = UIColor.clear // Make it transparent
        playerViewController.contentOverlayView?.addSubview(contentOverlay)
        contentOverlay.frame = playerViewController.contentOverlayView?.bounds ?? .zero
        contentOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Example: Add a custom label to the overlay
        let customLabel = UILabel()
        customLabel.text = "My Custom Overlay"
        customLabel.textColor = .white
        customLabel.textAlignment = .center
        customLabel.frame = CGRect(x: 20, y: 20, width: 200, height: 30)
        contentOverlay.addSubview(customLabel)
    }

    // MARK: - Playback Control

      private func playVideo() {
          guard let player = playerViewController.player else { return }

          // Check if the player item is ready to play before playing
          if playerItem.status == .readyToPlay {
              player.play()
          } else {
              // Observe the 'status' property of the AVPlayerItem
               playerItem.addObserver(self,
                                       forKeyPath: #keyPath(AVPlayerItem.status),
                                       options: [.new, .old],
                                       context: &playerContext)
          }
      }

    private func pauseVideo() {
        playerViewController.player?.pause()
    }

    private func seekToTime(seconds: Double) {
        guard let player = playerViewController.player else { return }
        isSeeking = true
          let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

          // Use the precise seek method for better responsiveness
          player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
              if finished {
                  self?.isSeeking = false // Reset the seeking flag
              }
          }
    }

     private func addNextItemToQueue() {
            guard let newItemURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4") else { return } // Different video
            let newItem = AVPlayerItem(url: newItemURL)
            if player.canInsert(newItem, after: player.currentItem) { // Check before inserting
                 player.insert(newItem, after: player.currentItem)
                 createPlayerLooper() //Recreate to loop current item.
            }
        }

        private func skipToNextItem()
        {
            player.advanceToNextItem() // Skips the current item.
            createPlayerLooper() //Recreate to loop the current item.
        }


    // MARK: - Observation (KVO and Combine)

    private func observePlayback() {
       // KVO for player's timeControlStatus (playing, paused, waiting)
        player.addObserver(self,
                          forKeyPath: #keyPath(AVPlayer.timeControlStatus),
                          options: [.new, .old],
                          context: &playerContext)

        // Observe the current item's status
         playerItem.addObserver(self,
                                forKeyPath: #keyPath(AVPlayerItem.status),
                                options: [.new, .old],
                                context: &playerContext)


        // Observe loadedTimeRanges to update the progress bar, for example
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges),
                               options: [.new, .old],
                               context: &playerContext)

        //Using Combine
          player.publisher(for: \.currentItem?.duration)
            .sink { [weak self] duration in
                guard let self = self, let duration = duration else { return }
                // Update UI with total duration
                print("Total Duration: \(duration.seconds)")
            }
            .store(in: &cancellables)


        // Periodic time observation using Combine.  This is more efficient than a timer.
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            // Update UI with current time, *but only if not seeking*
            if !self.isSeeking {
               print("Current Time: \(time.seconds)")
           }

           // Access metadata (if any).  This is just an example; handle specific metadata appropriately.
           if let metadata = self.playerItem.timedMetadata {
              for item in metadata {
                  if let commonKey = item.commonKey?.rawValue, let value = item.value {
                       print("Metadata: \(commonKey) - \(value)")
                   }
               }
            }
        }
    }


    // MARK: - KVO Handling

        override func observeValue(forKeyPath keyPath: String?,
                             of: Any?,
                             change: [NSKeyValueChangeKey: Any]?,
                             context: UnsafeMutableRawPointer?) {

        // Only handle observations for this specific context.  This is crucial for avoiding issues
        // if other objects are also using KVO.
        guard context == &playerContext else {
            super.observeValue(forKeyPath: keyPath, of: .none, change: change, context: context)
            return
        }

        if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            if let statusInt = change?[.newKey] as? Int,
               let status = AVPlayer.TimeControlStatus(rawValue: statusInt) {
                // Handle timeControlStatus changes
                switch status {
                case .paused:
                    print("Playback paused")
                    // Update UI (e.g., change play button to "Play")
                case .waitingToPlayAtSpecifiedRate:
                    if let reason = player.reasonForWaitingToPlay {
                        print("Waiting Reason: \(reason)")
                    }
                        // Show a loading indicator
                case .playing:
                    print("Playback playing")
                    //Update UI
                @unknown default:
                    break
                }
            }
        }else if keyPath == #keyPath(AVPlayerItem.status){
                if let statusInt = change?[.newKey] as? Int,
                   let status = AVPlayerItem.Status(rawValue: statusInt)
                {
                    switch status{
                    case .unknown:
                        print("unknown")
                    case .readyToPlay:
                        print("ready to play")
                        player.play() //auto play when the video is ready.
                    case .failed:
                         if let error = playerItem.error {
                            print("Failed to load video: \(error)")
                            customDelegate?.playerViewController(playerViewController, failedWithError: error)
                        }
                    @unknown default:
                        break
                    }
                }
        }else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges){
           // print("loadedTimeRanges \(change?[.newKey] ?? "")") // Log the update

        }
    }

    // MARK: - AVPlayerViewControllerDelegate

    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        customDelegate?.playerViewControllerDidStartPictureInPicture(playerViewController)
    }

    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        // Handle PiP start
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        customDelegate?.playerViewController(playerViewController, failedWithError: error)
        print("PiP Failed: \(error)")
    }
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Restore your UI after PiP ends.  This is important for a good user experience.
        completionHandler(true) // Indicate that the UI was restored successfully.
    }

    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
         return true; // Allow auto dismiss.
     }

    // MARK: - Download Asset

   private func downloadAsset(url: URL) {
         // Create a background configuration.
         // Use a unique identifier so the system can track this session even across app restarts.
         let config = URLSessionConfiguration.background(withIdentifier: "com.example.downloadSession")

         // Create the URLSession, passing in the delegate (self).
         let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)

         // Create the download task.  Use AVAssetDownloadTask for HLS streams.
         let asset = AVURLAsset(url: url)
         if let downloadTask = session.avAssetDownloadTask(with: asset,
                                                         assetTitle: "MyDownloadedVideo", // Title for the downloaded asset
                                                         assetArtworkData: nil, // Optional artwork
                                                         options: [AVAssetDownloadTaskMinimumBitRateKey: 2_000_000]) { // Example option: minimum bitrate
             // Start (or resume) the download.
             downloadTask.resume()
         }
     }



    // MARK: - URLSessionDownloadDelegate
     func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
         // Check for `session` deallocated, in that cause, create a new `URLSession`
     }
     func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
         if let error = error {
             print("Download Task Failed: \(error)")
             // Handle download failure (e.g., show an alert to the user).
         } else {
             // Handle successful download.
             print("download completed")
         }
     }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        // Do *NOT* perform any UI updates from this method; it's called on a background thread.
        print("Asset Downloaded to: \(location)")
        // 1. Persist the `location`.  The file at `location` is temporary and will be deleted.
        //    You *must* move it to a permanent location in your app's Documents directory.

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Failed to access Documents directory")
                return
        }

        //Create specific location to store files.
        let destinationURL = documentsDirectory.appendingPathComponent("MyDownloads").appendingPathComponent(assetDownloadTask.urlAsset.url.lastPathComponent)
        do{
            // Create a directory for storing downloaded assets
            try FileManager.default.createDirectory(at: documentsDirectory.appendingPathComponent("MyDownloads"), withIntermediateDirectories: true)

            // Remove the file if exits.
            if FileManager.default.fileExists(atPath: destinationURL.path){
                try FileManager.default.removeItem(at: destinationURL)

            }
            // Move the downloaded file to the destination URL.
            try FileManager.default.moveItem(at: location, to: destinationURL)
            // 2. Store the destination URL persistently (UserDefaults, Core Data, etc.).
            UserDefaults.standard.set(destinationURL, forKey: "downloadedVideoURL") // Example: using UserDefaults

        }catch{
            print("move item failed \(error)")
        }
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        // Calculate download progress (example).  Update a progress bar in your UI on the main thread.
        let progress = loadedTimeRanges.reduce(0.0) { (result, value) -> Double in
            let range = value.timeRangeValue
            return result + range.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        print("Download Progress: \(progress * 100)%")
        // Dispatch to main queue for UI updating
        DispatchQueue.main.async {
              //self.progressView.progress = Float(progress) // Assuming you have a UIProgressView

          }
      }


    // MARK: - Deinitialization

    deinit {
        //CRITICAL:  Remove observers in deinit to prevent crashes.
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: &playerContext)
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &playerContext)
        playerItem.removeObserver(self,forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges),  context: &playerContext)
      //  playerViewController.player = nil
    }
}
