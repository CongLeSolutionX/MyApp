////
////  AVPlayerView.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//import SwiftUI
//import AVFoundation
//import AVKit // For VideoPlayer
//import Combine // For Publishers and ObservableObject
//
//// MARK: - Data Structures for UI Display
//
//struct MediaGroupSelection: Identifiable {
//    let id = UUID()
//    let group: AVMediaSelectionGroup
//    var options: [AVMediaSelectionOption?] // Include nil for 'off' if allowed
//    var selectedOption: AVMediaSelectionOption? // Track selection
//}
//
//struct LogEntry: Identifiable, Hashable {
//    let id = UUID()
//    let timestamp: Date = Date() // Log time in UI, not event time
//    let message: String
//    let type: LogType
//
//    enum LogType { case access, error, status, notification, other }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
//        lhs.id == rhs.id
//    }
//}
//
//// MARK: - Player View Model (Manages AVPlayer and AVPlayerItem)
//
//@MainActor // Ensure UI updates are on the main thread
//class PlayerViewModel: NSObject, ObservableObject {
//
//    // --- Published Properties for SwiftUI ---
//    @Published var player = AVPlayer() // The main player instance
//    @Published var playerItem: AVPlayerItem? = nil // Can change
//
//    @Published var playerStatus: AVPlayerItem.Status = .unknown
//    @Published var isPlaying: Bool = false
//    @Published var currentTime: CMTime = .zero
//    @Published var duration: CMTime = .zero
//    @Published var seekableRanges: [CMTimeRange] = []
//    @Published var loadedRanges: [CMTimeRange] = []
//    @Published var isPlaybackLikelyToKeepUp: Bool = false
//    @Published var isPlaybackBufferFull: Bool = false
//    @Published var isPlaybackBufferEmpty: Bool = true
//
//    @Published var availableMediaGroups: [MediaGroupSelection] = []
//    @Published var currentLogs: [LogEntry] = []
//    @Published var itemError: Error? = nil
//    @Published var preferredPeakBitrate: Double = 0.0 // 0 = no limit
//    @Published var audioPitchAlgorithm: AVAudioTimePitchAlgorithm = .timeDomain // Default starting iOS 15/macOS 12
//
//    // --- Private Properties ---
//    private var timeObserverToken: Any?
//    private var itemStatusObserver: NSKeyValueObservation?
//    private var loadedRangesObserver: NSKeyValueObservation?
//    private var likelyToKeepUpObserver: NSKeyValueObservation?
//    private var bufferFullObserver: NSKeyValueObservation?
//    private var bufferEmptyObserver: NSKeyValueObservation?
//    private var currentItemErrorObserver: NSKeyValueObservation?
//    private var rateObserver: NSKeyValueObservation?
//
//    private var subscriptions = Set<AnyCancellable>()
//    private var notificationSubscriptions: [NSObjectProtocol] = []
//
//    private let logQueue = DispatchQueue(label: "com.example.PlayerViewModel.logQueue")
//
//    // Example Media URL (Replace with a valid HLS or other stream/file URL)
//    // HLS streams are better for demonstrating network features and media selection
//     private let defaultMediaURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
////    private let defaultMediaURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")! // Progressive Download Example
//
//
//    override init() {
//        super.init()
//        setupPlayerObservers()
//        addLog("ViewModel Initialized", type: .other)
////        loadMedia(url: defaultMediaURL) // Load default media on init
//    }
//
////    deinit {
////        cleanup()
////        addLog("ViewModel Deinitialized", type: .other)
////        print("PlayerViewModel Deinit")
////    }
//
//    // MARK: - Media Loading
////    func loadMedia(url: URL) {
////        cleanupCurrentItem() // Remove observers from the old item
////
////        addLog("Loading media: \(url.absoluteString)", type: .other)
////        let asset = AVURLAsset(url: url) // Use AVURLAsset (Sendable)
////
////        // Load asset properties asynchronously (optional but good practice)
////        Task {
////            do {
////                // Keys needed for basic playback and UI updates
//////                let keysToLoad: [AVAsyncKeys] = [.duration, .tracks, .availableMediaCharacteristicsWithMediaSelectionOptions, .isPlayable]
//////                try await asset.load(keysToLoad)
////
////                // Check if playable after loading
////                guard try await asset.load(.isPlayable) else {
////                   addLog("Asset is not playable.", type: .error)
////                   self.itemError = NSError(domain: "PlayerDemoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Asset not playable"])
////                   self.playerStatus = .failed // Simulate failed status
////                   return
////                 }
////
////
////                // Create the player item *after* keys are loaded (or start loading)
////                let newItem = AVPlayerItem(asset: asset) // or init(asset:automaticallyLoadedAssetKeys:) if needed
////
////                // --- Configure the New Item ---
////                // Example: Set preferred peak bit rate (e.g., 1 Mbps)
//////                newItem.preferredPeakBitRate = self.preferredPeakBitRate
//////                addLog("Set preferredPeakBitrate to \(self.preferredPeakBitRate)", type: .other)
////
////                 // Example: Set audio pitch algorithm
////                 newItem.audioTimePitchAlgorithm = self.audioPitchAlgorithm
////                 addLog("Set audioTimePitchAlgorithm to \(self.audioPitchAlgorithm.rawValue)", type: .other)
////
////                // Example: Allow all spatialization formats (if applicable)
////                 if #available(iOS 14.0, *) {
////                      newItem.allowedAudioSpatializationFormats = .monoStereoAndMultichannel
////                     addLog("Set allowedAudioSpatializationFormats to allow all", type: .other)
////                 }
////
////                 // Example: Ensure network resources are not used excessively when paused for live streams
////                 if #available(iOS 9.0, *) {
////                      newItem.canUseNetworkResourcesForLiveStreamingWhilePaused = false // Default, but explicit
////                 }
////                
////                // Replace the player's current item
////                self.playerItem = newItem
////                setupNewPlayerItemObservers(item: newItem)
////                self.player.replaceCurrentItem(with: newItem)
////                addLog("Player item created and replaced.", type: .other)
////
////                // Reset UI state for new item
////                self.currentTime = .zero
////                do {
////                      self.duration = try await newItem.asset.load(.duration)
////                } catch {
////                      self.duration = .indefinite
////                      addLog("Failed to load duration initially: \(error)", type: .error)
////                }
////                self.seekableRanges = []
////                self.loadedRanges = []
////                self.itemError = nil // Clear previous error
////
////                // Load media selection groups once the item is ready
////                await loadMediaSelectionGroups(for: newItem)
////
////            } catch {
////                addLog("Error loading asset keys: \(error)", type: .error)
////                self.itemError = error
////                self.playerStatus = .failed // Set status to failed on asset load error
////            }
////        }
////    }
//
//    // MARK: - Playback Control
//    func play() {
//        if player.currentItem != nil {
//            player.play()
//            // isPlaying will be updated by the rate observer
//            addLog("Play() called", type: .other)
//        } else {
//             addLog("Play() called but no item loaded", type: .error)
//        }
//    }
//
//    func pause() {
//        player.pause()
//        // isPlaying will be updated by the rate observer
//        addLog("Pause() called", type: .other)
//    }
//
//    func seek(to time: CMTime) {
//        guard let item = playerItem else { return }
//
//        // Basic seek with completion handler (can use async version too)
//        addLog("Seeking to \(CMTimeGetSeconds(time).formatted(.number.precision(.fractionLength(2))))s", type: .other)
//        item.seek(to: time) { [weak self] finished in
//             guard let self = self else { return }
//             if finished {
//                 self.addLog("Seek finished.", type: .other)
//             } else {
//                 self.addLog("Seek interrupted.", type: .other)
//             }
//         }
//        // Or using async/await:
//        /*
//        Task {
//            let finished = await item.seek(to: time)
//            if finished {
//                 addLog("Async Seek finished.", type: .other)
//             } else {
//                 addLog("Async Seek interrupted.", type: .other)
//             }
//        }
//        */
//    }
//
//    func seek(to percentage: Double) {
//        guard duration.seconds > 0 else { return }
//        let timeInSeconds = duration.seconds * percentage
//        let time = CMTime(seconds: timeInSeconds, preferredTimescale: 600)
//        seek(to: time)
//    }
//
//    // MARK: - Media Selection
////    @MainActor // Ensure updates happen on main thread for UI consistency
////    private func loadMediaSelectionGroups(for item: AVPlayerItem) async {
////        guard let asset = playerItem?.asset else { return }
////
////        do {
////            let groups = try await asset.load(.availableMediaCharacteristicsWithMediaSelectionOptions)
////                .compactMap { characteristic -> AVMediaSelectionGroup? in
////                    return try? asset.loadMediaSelectionGroup(for: characteristic)
////                }
////
////            // Transform into our UI struct
////            self.availableMediaGroups = groups.map { group in
////                var options: [AVMediaSelectionOption?] = group.options
////                if group.allowsEmptySelection {
////                    options.insert(nil, at: 0) // Add nil option for 'Off'/'Automatic'
////                }
////                // Get the currently selected option for this group *from the player item*
////                 let currentItemSelection = item.currentMediaSelection // Requires iOS 9+
////                 let selected = currentItemSelection.selectedMediaOption(in: group)
////
////                return MediaGroupSelection(group: group, options: options, selectedOption: selected)
////            }
////            addLog("Loaded \(availableMediaGroups.count) media selection groups.", type: .other)
////        } catch {
////            addLog("Error loading media selection groups: \(error)", type: .error)
////            self.availableMediaGroups = []
////        }
////    }
//
//
////    func selectMediaOption(_ option: AVMediaSelectionOption?, in group: AVMediaSelectionGroup) {
////        guard let item = playerItem else { return }
////        addLog("Selecting option '\(option?.displayName ?? "None")' in group '\(AVMediaSelectionGroup.mediaSelectionOptions(from: [.init()], withoutMediaCharacteristics: nil).first?.commonMetadata.first?.value ?? "Unknown")'", type: .other)
////        item.select(option, in: group)
////        
////        // Update our UI state immediately (the notification might take a moment)
////         if let index = availableMediaGroups.firstIndex(where: { $0.group == group }) {
////            availableMediaGroups[index].selectedOption = option
////        }
////    }
//    
//    // MARK: - Preference Settings
//    
//    func setPreferredBitrate(_ bitrate: Double) {
//        self.preferredPeakBitrate = bitrate
////        playerItem?.preferredPeakBitrate = bitrate // Apply to current item if loaded
//        addLog("Setting preferredPeakBitrate to \(bitrate)", type: .other)
//    }
//    
//    func setAudioPitch(_ algorithm: AVAudioTimePitchAlgorithm) {
//        self.audioPitchAlgorithm = algorithm
//        playerItem?.audioTimePitchAlgorithm = algorithm // Apply to current item
//        addLog("Setting audioTimePitchAlgorithm to \(algorithm.rawValue)", type: .other)
//    }
//
//    // MARK: - Logging Access
//    func fetchAccessLog() {
//        guard let item = playerItem else {
//            addLog("Cannot fetch Access Log: No player item.", type: .error)
//            return
//        }
//        guard let log = item.accessLog() else {
//            addLog("Access Log is currently nil.", type: .status)
//            return
//        }
//        guard let data = log.extendedLogData(),
//              let logString = String(data: data, encoding: .utf8) else {
//            addLog("Access Log exists but could not be serialized.", type: .error)
//            return
//        }
//        addLog("--- Access Log Start ---", type: .access)
//        logString.split(separator: "\n").forEach { addLog(String($0), type: .access) }
//        // Or process log.events individually
//        // log.events.forEach { event in addLog("Access Event: \(event.description)", type: .access) }
//         addLog("--- Access Log End ---", type: .access)
//    }
//
//    func fetchErrorLog() {
//         guard let item = playerItem else {
//            addLog("Cannot fetch Error Log: No player item.", type: .error)
//            return
//        }
//        guard let log = item.errorLog() else {
//             addLog("Error Log is currently nil.", type: .status)
//             return
//        }
//         guard let data = log.extendedLogData(),
//               let logString = String(data: data, encoding: .utf8) else {
//             addLog("Error Log exists but could not be serialized.", type: .error)
//            return
//        }
//        addLog("--- Error Log Start ---", type: .error)
//        logString.split(separator: "\n").forEach { addLog(String($0), type: .error) }
//         // Or process log.events individually
//         // log.events.forEach { event in addLog("Error Event: uri=\(event.uri ?? "N/A"), code=\(event.errorStatusCode), domain=\(event.errorDomain), comment=\(event.errorComment ?? "N/A")", type: .error) }
//         addLog("--- Error Log End ---", type: .error)
//    }
//
//    // MARK: - Private Setup & Cleanup
//    private func setupPlayerObservers() {
//        // Observe player rate changes to update isPlaying
//        rateObserver = player.observe(\.rate, options: [.new]) { [weak self] player, change in
//            guard let self = self else { return }
//            DispatchQueue.main.async { // Ensure UI update is on main thread
//                self.isPlaying = player.rate > 0
//                self.addLog("Player rate changed to \(player.rate). isPlaying = \(self.isPlaying)", type: .status)
//            }
//        }
//    }
//
//    private func setupNewPlayerItemObservers(item: AVPlayerItem) {
//        // KVO for Item Status
//        itemStatusObserver = item.observe(\.status, options: [.new, .initial]) { [weak self] item, change in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                let newStatus = item.status
//                self.playerStatus = newStatus
//                 self.addLog("Item status changed: \(newStatus.description)", type: .status)
//                 if newStatus == .failed {
//                    self.itemError = item.error // Capture error on failure
//                    self.addLog("Item failed. Error: \(item.error?.localizedDescription ?? "Unknown error")", type: .error)
//                     // Fetch detailed error log on failure
//                     self.fetchErrorLog()
//                } else {
//                    self.itemError = nil // Clear error if status is not failed
//                }
//                 if newStatus == .readyToPlay {
//                     // Update duration when ready (might have loaded async before)
//                     if self.duration == .zero || self.duration == .indefinite {
//                         self.duration = item.duration
//                     }
//                     // Refresh media selection groups when ready
////                     Task { await self.loadMediaSelectionGroups(for: item) }
//                     self.fetchAccessLog() // Fetch initial access log
//                 }
//            }
//        }
//
//        // KVO for Time Ranges
//        loadedRangesObserver = item.observe(\.loadedTimeRanges, options: [.new]) { [weak self] item, change in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.loadedRanges = item.loadedTimeRanges.map { $0.timeRangeValue }
//            }
//        }
//        // Note: Seekable time ranges often come from the asset and might not change as frequently
//        // but observing can be useful for live streams. Consider observing asset's seekableTimeRanges property if needed.
//
//
//        // KVO for Buffering Status
//        likelyToKeepUpObserver = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, change in
//             guard let self = self else { return }
//             DispatchQueue.main.async {
//                 self.isPlaybackLikelyToKeepUp = item.isPlaybackLikelyToKeepUp
//                 self.addLog("isPlaybackLikelyToKeepUp: \(self.isPlaybackLikelyToKeepUp)", type: .status)
//             }
//        }
//        bufferFullObserver = item.observe(\.isPlaybackBufferFull, options: [.new]) { [weak self] item, change in
//             guard let self = self else { return }
//             DispatchQueue.main.async {
//                 self.isPlaybackBufferFull = item.isPlaybackBufferFull
//                 self.addLog("isPlaybackBufferFull: \(self.isPlaybackBufferFull)", type: .status)
//             }
//        }
//         bufferEmptyObserver = item.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] item, change in
//             guard let self = self else { return }
//             DispatchQueue.main.async {
//                 self.isPlaybackBufferEmpty = item.isPlaybackBufferEmpty
//                  self.addLog("isPlaybackBufferEmpty: \(self.isPlaybackBufferEmpty)", type: .status)
//             }
//        }
//        
//        // KVO specifically for item error (though status observer often catches it)
//         currentItemErrorObserver = item.observe(\.error, options: [.new]) { [weak self] item, change in
//             guard let self = self, let error = item.error else { return }
//              // Avoid duplicate logging if already handled by status observer
//              if self.itemError == nil || (self.itemError as NSError?)?.code != (error as NSError).code {
//                  DispatchQueue.main.async {
//                      self.itemError = error
//                      self.addLog("Item error property set: \(error.localizedDescription)", type: .error)
//                  }
//              }
//         }
//
//
//        // Periodic Time Observer for currentTime updates
//        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
//            guard let self = self else { return }
//             // Only update if the status is ready to prevent updates during seeking/loading
//             if self.playerStatus == .readyToPlay {
//                self.currentTime = time
//            }
//        }
//
//        // --- Notification Center Observers ---
//        let nc = NotificationCenter.default
//
//        notificationSubscriptions.append(
//             nc.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak self] _ in
//                self?.addLog("Notification: DidPlayToEndTime", type: .notification)
//                // Optionally seek back to zero or handle playlist logic
//                 self?.player.seek(to: .zero)
//                 self?.player.pause() // Pause after reaching end
//                 self?.currentTime = .zero // Reset UI Time
//            }
//        )
//
//        notificationSubscriptions.append(
//            nc.addObserver(forName: .AVPlayerItemPlaybackStalled, object: item, queue: .main) { [weak self] _ in
//                self?.addLog("Notification: PlaybackStalled", type: .notification)
//            }
//        )
//         notificationSubscriptions.append(
//             nc.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main) { [weak self] notification in
//                 let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
//                 self?.itemError = error // Capture error
//                 self?.addLog("Notification: FailedToPlayToEndTime. Error: \(error?.localizedDescription ?? "Unknown")", type: .notification)
//                 self?.fetchErrorLog()
//             }
//         )
//        notificationSubscriptions.append(
//            nc.addObserver(forName: .AVPlayerItemNewAccessLogEntry, object: item, queue: .main) { [weak self] _ in
//                self?.addLog("Notification: NewAccessLogEntry (fetch log to view)", type: .notification)
//                // Optionally fetch/process log automatically here
//                 // self?.fetchAccessLog()
//            }
//        )
//         notificationSubscriptions.append(
//             nc.addObserver(forName: .AVPlayerItemNewErrorLogEntry, object: item, queue: .main) { [weak self] _ in
//                 self?.addLog("Notification: NewErrorLogEntry (fetch log to view)", type: .notification)
//                 // Optionally fetch/process log automatically here
//                 // self?.fetchErrorLog()
//             }
//         )
////         notificationSubscriptions.append(
////             nc.addObserver(forName: .AVPlayerItemMediaSelectionDidChange, object: item, queue: .main) { [weak self] _ in
////                  guard let self = self else { return }
////                 self.addLog("Notification: MediaSelectionDidChange", type: .notification)
////                 // Refresh UI state for media selection
////                 Task { await self.loadMediaSelectionGroups(for: item) }
////             }
////         )
//         
//          // Example: Observe recommendedTimeOffsetFromLive (for live streams)
//           notificationSubscriptions.append(
//            nc.addObserver(forName: .AVAssetChapterMetadataGroupsDidChange, object: item, queue: .main) { [weak self] _ in
//                   guard let self = self else { return }
//                   let recommendedOffset = item.recommendedTimeOffsetFromLive
//                   self.addLog("Notification: RecommendedTimeOffsetFromLive changed to \(recommendedOffset.seconds)", type: .notification)
//                    // Optionally update UI or adjust configuredTimeOffsetFromLive
//               }
//           )
//    }
//
//    private func cleanupCurrentItem() {
//        player.replaceCurrentItem(with: nil)
//        playerItem = nil
//        
//        if let token = timeObserverToken {
//            player.removeTimeObserver(token)
//            timeObserverToken = nil
//        }
//        
//        itemStatusObserver?.invalidate()
//        loadedRangesObserver?.invalidate()
//        likelyToKeepUpObserver?.invalidate()
//        bufferFullObserver?.invalidate()
//         bufferEmptyObserver?.invalidate()
//         currentItemErrorObserver?.invalidate()
//
//        itemStatusObserver = nil
//        loadedRangesObserver = nil
//        likelyToKeepUpObserver = nil
//        bufferFullObserver = nil
//         bufferEmptyObserver = nil
//         currentItemErrorObserver = nil
//
//        notificationSubscriptions.forEach(NotificationCenter.default.removeObserver)
//        notificationSubscriptions.removeAll()
//
//        // Reset published properties related to item state
//        DispatchQueue.main.async { // Ensure main thread for UI updates
//            self.playerStatus = .unknown
//            self.currentTime = .zero
//            self.duration = .zero
//            self.seekableRanges = []
//            self.loadedRanges = []
//            self.isPlaybackLikelyToKeepUp = false
//            self.isPlaybackBufferFull = false
//            self.isPlaybackBufferEmpty = true
//            self.availableMediaGroups = []
//            self.itemError = nil
//            // Don't clear logs here unless intended
//        }
//        addLog("Cleaned up previous player item.", type: .other)
//    }
//
//    private func cleanup() {
//        cleanupCurrentItem()
//        rateObserver?.invalidate()
//        rateObserver = nil
//        subscriptions.forEach { $0.cancel() }
//        subscriptions.removeAll()
//    }
//    
//     // MARK: - Logging Helper
//    private func addLog(_ message: String, type: LogEntry.LogType) {
//         // Use a separate queue for adding logs to avoid blocking main thread if processing is heavy
//          logQueue.async {
//            let entry = LogEntry(message: message, type: type)
//             // Switch back to main thread to publish UI updates
//             DispatchQueue.main.async {
//                 // Limit log size for performance
//                 if self.currentLogs.count > 200 {
//                      self.currentLogs.removeFirst(50)
//                 }
//                 self.currentLogs.append(entry)
//             }
//        }
//    }
//}
//
//// MARK: - SwiftUI View
//
//struct AVPlayerItemDemoView: View {
//    @StateObject private var viewModel = PlayerViewModel()
//    @State private var sliderValue: Double = 0.0 // 0.0 to 1.0
//    @State private var isSeeking: Bool = false // Flag to avoid slider updates during user drag
//
//    var body: some View {
//        VStack(spacing: 0) {
//             // --- Video Player ---
//            VideoPlayer(player: viewModel.player)
//                 .frame(height: 250)
//                 .onAppear {
//                    // If you want to load media only when view appears, move loadMedia call here
//                     // viewModel.loadMedia(url: viewModel.defaultMediaURL) // Example
//                 }
//                 .onChange(of: viewModel.currentTime) { _, newTime in
//                    // Update slider only if user is not actively dragging it
//                      guard !isSeeking, viewModel.duration.seconds > 0 else { return }
//                     sliderValue = newTime.seconds / viewModel.duration.seconds
//                 }
//
//
//            // --- Status & Error Display ---
//            PlayerStatusView(status: viewModel.playerStatus, error: viewModel.itemError)
//
//             // --- Basic Controls & Time ---
//             PlayerControlsView(
//                isPlaying: viewModel.isPlaying,
//                currentTime: viewModel.currentTime,
//                duration: viewModel.duration,
//                playAction: viewModel.play,
//                pauseAction: viewModel.pause
//            )
//
//            PlayerSliderView(
//                value: $sliderValue,
//                isSeeking: $isSeeking,
//                duration: viewModel.duration,
//                seekAction: viewModel.seek(to:)
//            )
//             .disabled(viewModel.playerStatus != .readyToPlay)
//             .opacity(viewModel.playerStatus != .readyToPlay ? 0.5 : 1.0)
//
//
//             // --- Feature Demonstrations ---
//            List {
//                BufferingStatusSection(viewModel: viewModel)
//                TimeRangesSection(
//                    loadedRanges: viewModel.loadedRanges,
//                    seekableRanges: viewModel.seekableRanges,
//                    duration: viewModel.duration
//                )
////                 MediaSelectionSection(availableGroups: $viewModel.availableMediaGroups) { option, group in
////                      viewModel.selectMediaOption(option, in: group)
////                 }
//                 NetworkPreferencesSection(viewModel: viewModel)
//                 AudioProcessingSection(viewModel: viewModel)
//                 LoggingSection(logs: viewModel.currentLogs) {
//                     viewModel.fetchAccessLog()
//                 } errorLogAction: {
//                      viewModel.fetchErrorLog()
//                 } clearLogsAction: {
//                      viewModel.currentLogs.removeAll()
//                 }
//            }
//            .listStyle(InsetGroupedListStyle()) // Use inset for better spacing
//        }
//         .navigationTitle("AVPlayerItem Demo") // Add title if within NavigationView
//    }
//}
//
//// MARK: - Helper Subviews
//
//struct PlayerStatusView: View {
//    let status: AVPlayerItem.Status
//    let error: Error?
//
//    var body: some View {
//        HStack {
//            Text("Status:")
//                .font(.footnote).bold()
//            Text(status.description)
//                .font(.footnote)
//                .foregroundColor(statusColor)
//                .padding(.trailing)
//
//            if status == .failed, let error = error {
//                 Image(systemName: "exclamationmark.triangle.fill")
//                     .foregroundColor(.red)
//                 Text("Error: \(error.localizedDescription)")
//                    .font(.caption)
//                    .foregroundColor(.red)
//                    .lineLimit(1)
//            }
//            Spacer()
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 4)
//        .background(Color(.systemGray6))
//    }
//
//    private var statusColor: Color {
//        switch status {
//        case .unknown: return .orange
//        case .readyToPlay: return .green
//        case .failed: return .red
//        @unknown default: return .gray
//        }
//    }
//}
//
//struct PlayerControlsView: View {
//    let isPlaying: Bool
//    let currentTime: CMTime
//    let duration: CMTime
//    let playAction: () -> Void
//    let pauseAction: () -> Void
//
//    var body: some View {
//        HStack {
//            Text(currentTime.formattedString())
//                 .font(.caption.monospacedDigit())
//                 .frame(width: 50, alignment: .leading)
//
//             Spacer()
//
//             Button {
//                 if isPlaying { pauseAction() } else { playAction() }
//             } label: {
//                 Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                     .resizable()
//                     .aspectRatio(contentMode: .fit)
//                     .frame(width: 30, height: 30)
//             }
//
//             Spacer()
//
//            Text(duration.formattedString())
//                .font(.caption.monospacedDigit())
//                .frame(width: 50, alignment: .trailing)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 5)
//    }
//}
//
//struct PlayerSliderView: View {
//    @Binding var value: Double // 0.0 to 1.0
//    @Binding var isSeeking: Bool
//    let duration: CMTime
//    let seekAction: (Double) -> Void // Action taking percentage
//
//
//    var body: some View {
//          Slider(value: $value, in: 0...1) { editing in
//                isSeeking = editing // Update seeking state
//                if !editing { // On release, perform the seek
//                     seekAction(value)
//                 }
//            }
//         .padding(.horizontal)
//         .padding(.bottom, 5)
//    }
//}
//
//
//struct BufferingStatusSection: View {
//    @ObservedObject var viewModel: PlayerViewModel // Use ObservedObject if passed down
//
//    var body: some View {
//         Section("Buffering Status") {
//             HStack {
//                 Text("Likely To Keep Up:")
//                 Spacer()
//                 Image(systemName: viewModel.isPlaybackLikelyToKeepUp ? "checkmark.circle.fill" : "xmark.circle.fill")
//                     .foregroundColor(viewModel.isPlaybackLikelyToKeepUp ? .green : .orange)
//            }
//             HStack {
//                 Text("Buffer Full:")
//                 Spacer()
//                 Image(systemName: viewModel.isPlaybackBufferFull ? "battery.100.bolt" : "battery.25") // Example icons
//                     .symbolRenderingMode(.palette)
//                     .foregroundStyle(viewModel.isPlaybackBufferFull ? .green : .gray, .primary)
//             }
//             HStack {
//                  Text("Buffer Empty:")
//                 Spacer()
//                  Image(systemName: viewModel.isPlaybackBufferEmpty ? "exclamationmark.triangle.fill" : "checkmark.circle")
//                     .foregroundColor(viewModel.isPlaybackBufferEmpty ? .red : .green)
//             }
//         }
//         .font(.footnote)
//    }
//}
//
//struct TimeRangesSection: View {
//    let loadedRanges: [CMTimeRange]
//    let seekableRanges: [CMTimeRange]
//    let duration: CMTime
//
//    var body: some View {
//        Section("Time Ranges") {
//            VStack(alignment: .leading) {
//                 Text("Loaded Ranges").font(.caption).bold()
//                TimeRangeVisualizer(ranges: loadedRanges, duration: duration, color: .blue)
//                     .padding(.bottom, 5)
//
//                 // Seekable ranges often don't change much for VOD, more relevant for Live
//                 // Text("Seekable Ranges").font(.caption).bold()
//                 // TimeRangeVisualizer(ranges: seekableRanges, duration: duration, color: .green)
//            }
//        }
//    }
//}
//
//struct TimeRangeVisualizer: View {
//    let ranges: [CMTimeRange]
//    let duration: CMTime
//    let color: Color
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .leading) {
//                 // Background track
//                 Rectangle()
//                    .fill(Color(.systemGray4))
//                     .frame(height: 8)
//                     .cornerRadius(4)
//
//                 // Loaded segments
//                 if duration.seconds > 0 {
//                     ForEach(ranges, id: \.self) { range in
//                         let startFraction = range.start.seconds / duration.seconds
//                         let widthFraction = range.duration.seconds / duration.seconds
//                         
//                         // Clamp values to avoid drawing outside bounds
//                         let clampedStart = max(0, min(1, startFraction))
//                         let clampedWidth = max(0, min(1 - clampedStart, widthFraction))
//
//                         if clampedWidth > 0 {
//                              Rectangle()
//                                 .fill(color)
//                                 .frame(width: geometry.size.width * clampedWidth, height: 8)
//                                 .cornerRadius(4)
//                                 .offset(x: geometry.size.width * clampedStart)
//                         }
//                     }
//                 }
//            }
//        }
//        .frame(height: 10) // Set a fixed height for the geometry reader content
//    }
//}
//
//
//struct MediaSelectionSection: View {
//    @Binding var availableGroups: [MediaGroupSelection]
//    let selectionAction: (AVMediaSelectionOption?, AVMediaSelectionGroup) -> Void
//
//    var body: some View {
//        Section("Media Selection") {
//            if availableGroups.isEmpty {
//                 Text("No media selection groups available or loaded yet.")
//                      .font(.footnote)
//                     .foregroundColor(.secondary)
//            } else {
//                ForEach($availableGroups) { $groupInfo in
//                    MediaGroupPicker(groupInfo: $groupInfo, selectionAction: selectionAction)
//                }
//            }
//        }
//    }
//}
//
//struct MediaGroupPicker: View {
//     @Binding var groupInfo: MediaGroupSelection
//     let selectionAction: (AVMediaSelectionOption?, AVMediaSelectionGroup) -> Void
//
//    var body: some View {
//         // Use Menu for a compact picker-like experience within a List
//         Menu {
//             // Use ForEach directly on the options array
//             ForEach(groupInfo.options, id: \.self) { option in
//                Button {
//                     selectionAction(option, groupInfo.group)
//                 } label: {
//                     HStack {
//                          // Use explicit check for nil option
//                         let displayName = option?.displayName ?? (groupInfo.group.allowsEmptySelection ? "Off / Automatic" : "Unknown Option")
//                         Text(displayName)
//                         Spacer()
//                          // Show checkmark if this option matches the current selection in groupInfo
//                         if groupInfo.selectedOption == option {
//                              Image(systemName: "checkmark")
//                         }
//                     }
//                 }
//             }
//         } label: {
//             // Label for the Menu button itself
//             HStack {
////                 Text(groupInfo.group.displayName) // Characteristic (e.g., Legible, Audible)
//                 Spacer()
//                  // Display the name of the currently selected option
//                 Text(groupInfo.selectedOption?.displayName ?? (groupInfo.group.allowsEmptySelection ? "Off / Automatic" : "None"))
//                     .font(.footnote)
//                     .foregroundColor(.secondary)
//             }
//             .contentShape(Rectangle()) // Ensure the entire row is tappable
//         }
//         .id(groupInfo.id) // Ensure re-rendering on selection change
//    }
//}
//
//struct NetworkPreferencesSection: View {
//    @ObservedObject var viewModel: PlayerViewModel
//     private let bitrates: [Double] = [0, 500_000, 1_000_000, 2_000_000, 5_000_000] // 0 = unlimited
//
//    var body: some View {
//        Section("Network Preferences") {
//             Picker("Preferred Peak Bitrate", selection: $viewModel.preferredPeakBitrate) {
//                  ForEach(bitrates, id: \.self) { rate in
//                    Text(rate == 0 ? "Unlimited" : "\((rate / 1_000_000).formatted(.number.precision(.fractionLength(1)))) Mbps").tag(rate)
//                 }
//             }
//             .onChange(of: viewModel.preferredPeakBitrate) { _, newRate in
//                  viewModel.setPreferredBitrate(newRate)
//             }
//             .pickerStyle(.menu) // Use menu style for compactness
//
//            // Note: preferredMaximumResolution could be added similarly if needed
//        }
//    }
//}
//
//struct AudioProcessingSection: View {
//     @ObservedObject var viewModel: PlayerViewModel
//     private let algorithms: [AVAudioTimePitchAlgorithm] = [.lowQualityZeroLatency, .timeDomain, .spectral, .varispeed]
//
//    var body: some View {
//         Section("Audio Processing") {
//              Picker("Audio Pitch Algorithm", selection: $viewModel.audioPitchAlgorithm) {
//                  ForEach(algorithms, id: \.rawValue) { algo in
//                      Text(algo.description).tag(algo) // Use description for label
//                 }
//             }
//             .onChange(of: viewModel.audioPitchAlgorithm) { _, newAlgo in
//                  viewModel.setAudioPitch(newAlgo)
//             }
//             .pickerStyle(.menu)
//             
//              // Spatialization could be added here too if relevant (iOS 14+)
//         }
//    }
//}
//
//
//struct LoggingSection: View {
//    let logs: [LogEntry]
//    let accessLogAction: () -> Void
//    let errorLogAction: () -> Void
//     let clearLogsAction: () -> Void // Action to clear logs
//
//    var body: some View {
//        Section("Logs") {
//            HStack {
//                 Button("Fetch Access Log", action: accessLogAction)
//                 Spacer()
//                  Button("Fetch Error Log", action: errorLogAction)
//                 Spacer()
//                 Button("Clear UI Logs") {
//                       withAnimation { // Optional animation for clearing
//                         clearLogsAction()
//                     }
//                 }
//                 .buttonStyle(.bordered)
//                 .tint(.red) // Make clear button distinct
//            }
//             .buttonStyle(.borderedProminent)
//             .font(.caption)
//
//
//             // Display Logs (Limited Height)
//             ScrollViewReader { proxy in
//                 ScrollView(.vertical) {
//                      LazyVStack(alignment: .leading, spacing: 4) { // Use LazyVStack for performance
//                         ForEach(logs) { log in
//                             LogMessageView(log: log)
//                                 .id(log.id) // ID for scrolling
//                         }
//                     }
//                      .padding(.vertical, 5)
//                 }
//                  .frame(height: 150) // Limit log display height
//                  .background(Color(.systemGray6))
//                  .cornerRadius(5)
//                  .onChange(of: logs.count) { _, _ in
//                       // Scroll to the newest log entry when logs are updated
//                       if let lastLog = logs.last {
//                           withAnimation {
//                               proxy.scrollTo(lastLog.id, anchor: .bottom)
//                           }
//                       }
//                   }
//             }
//        }
//    }
//}
//
//struct LogMessageView: View {
//    let log: LogEntry
//
//    var body: some View {
//        HStack(alignment: .top) {
//            Text(log.timestamp, style: .time) // Show time for context
//                .font(.system(size: 9, design: .monospaced))
//                 .foregroundColor(.secondary)
//
//             Text("[\(log.type.label)]")
//                 .font(.system(size: 9, weight: .bold, design: .monospaced))
//                 .foregroundColor(log.type.color)
//
//            Text(log.message)
//                 .font(.system(size: 10))
//                 .lineLimit(nil) // Allow multiple lines
//                 .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
//
//             Spacer() // Push content to the left
//        }
//    }
//}
//
//
//// MARK: - Extensions & Helpers
//
//extension AVPlayerItem.Status {
//    var description: String {
//        switch self {
//        case .unknown: return "Unknown"
//        case .readyToPlay: return "Ready To Play"
//        case .failed: return "Failed"
//        @unknown default: return "Unexpected Status"
//        }
//    }
//}
//
//extension LogEntry.LogType {
//     var label: String {
//         switch self {
//         case .access: return "ACCESS"
//         case .error: return "ERROR "
//         case .status: return "STATUS"
//         case .notification: return "NOTIF "
//         case .other: return "INFO  "
//         }
//     }
//    
//     var color: Color {
//         switch self {
//         case .access: return .purple
//         case .error: return .red
//         case .status: return .orange
//         case .notification: return .blue
//         case .other: return .gray
//         }
//     }
//}
//
//
//extension CMTime {
//    func formattedString() -> String {
////        guard self.isValid && self.isNumeric else {
////            return duration == .indefinite ? " --:-- " : "00:00" // Show indefinite marker
////        }
//        let totalSeconds = Int(self.seconds)
//         guard totalSeconds >= 0 else { return "00:00" } // Handle potential negative values if needed
//        let seconds = totalSeconds % 60
//        let minutes = totalSeconds / 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//    
//    var seconds: Double {
//         guard self.isValid && self.isNumeric else { return 0.0 }
//         return CMTimeGetSeconds(self)
//     }
//}
//
//extension AVAudioTimePitchAlgorithm {
//    var description: String {
//        switch self {
//        case .lowQualityZeroLatency: return "Low Quality Zero Latency"
//        case .timeDomain: return "Time Domain"
//        case .spectral: return "Spectral"
//        case .varispeed: return "Varispeed"
//        default: return "Unknown (\(self.rawValue))"
//        }
//    }
//}
//
//// Conformance for Picker/ForEach
//extension AVAudioTimePitchAlgorithm: Identifiable {
//    public var id: String { self.rawValue }
//}
//
//
//// MARK: - Preview
//
//struct AVPlayerItemDemoView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView { // Wrap in NavigationView for title and list styling
//            AVPlayerItemDemoView()
//        }
//    }
//}
