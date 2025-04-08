////
////  AVPlayerItemDocumentationView.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//import SwiftUI
//import AVFoundation
//import CoreMedia // For CMTime
//
//// Note: This code defines SwiftUI views for documentation purposes only.
//// It does not interact with a live AVPlayer instance.
//
//// MARK: - Main Documentation View
//
//struct AVPlayerItemDocumentationView: View {
//    var body: some View {
//        NavigationView {
//            List {
//                CoreAttributesSection()
//                InitializationSection()
//                PlaybackControlSection()
//                NotificationsSection()
//                BufferingNetworkSection()
////                MediaSelectionSection()
////                AudioVideoProcessingSection()
////                OutputsDataCollectionSection()
////                LoggingSection()
////                ConcurrencySection()
////                DeprecatedAPISection()
//            }
//            .navigationTitle("AVPlayerItem API")
//            .listStyle(GroupedListStyle())
//        }
//    }
//}
//
//// MARK: - Helper View for API Items
//
//struct APIItemView: View {
//    let label: String
//    let value: String
//    let annotation: String?
//    let availability: String?
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Text(label).font(.headline).foregroundColor(.blue)
//                Spacer()
//                Text(value).font(.body.monospaced()).foregroundColor(.secondary)
//            }
//            if let annotation = annotation {
//                Text(annotation)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.top, 1)
//            }
//             if let availability = availability {
//                Text("Available: \(availability)")
//                    .font(.caption2)
//                    .foregroundColor(.orange)
//                    .padding(.top, 1)
//            }
//        }
//        .padding(.vertical, 2)
//    }
//}
//
//struct APIMethodView: View {
//    let signature: String
//    let description: String?
//    let availability: String?
//    let annotation: String?
//
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(signature).font(.system(.body, design: .monospaced)).bold()
//                .padding(.bottom, 1)
//            if let description = description {
//                 Text(description).font(.caption).foregroundColor(.secondary)
//            }
//            if let annotation = annotation {
//                Text(annotation)
//                    .font(.caption)
//                    .foregroundColor(.purple)
//                    .padding(.top, 1)
//            }
//             if let availability = availability {
//                Text("Available: \(availability)")
//                    .font(.caption2)
//                    .foregroundColor(.orange)
//                    .padding(.top, 1)
//            }
//        }
//         .padding(.vertical, 4)
//    }
//}
//
//// MARK: - Core Attributes Section
//
//struct CoreAttributesSection: View {
//    var body: some View {
//        Section("Core Attributes") {
//            APIItemView(label: "status", value: "AVPlayerItem.Status", annotation: "Read-only. Indicates playback readiness (unknown, readyToPlay, failed). KVO observable initially. `nonisolated`.", availability: "iOS 4.0+")
//            APIItemView(label: "error", value: "Error?", annotation: "Read-only. Describes failure if status is .failed, otherwise nil. `nonisolated`.", availability: "iOS 4.0+")
//            APIItemView(label: "asset", value: "AVAsset", annotation: "Read-only. The underlying media asset. @MainActor isolated for non-Sendable AVAsset.", availability: "iOS 4.0+")
//            APIItemView(label: "duration", value: "CMTime", annotation: "Read-only. Duration of the item. Can be kCMTimeIndefinite. KVO observable. `nonisolated`.", availability: "iOS 4.3+")
//            APIItemView(label: "presentationSize", value: "CGSize", annotation: "Read-only. Size of the visual portion. CGSizeZero before loaded or for audio-only. KVO observable. `nonisolated`.", availability: "iOS 4.0+")
//            APIItemView(label: "tracks", value: "[AVPlayerItemTrack]", annotation: "Read-only. Array of tracks. Empty until loaded. KVO observable. `nonisolated`.", availability: "iOS 4.0+")
//            APIItemView(label: "automaticallyLoadedAssetKeys", value: "[String]", annotation: "Read-only. Keys automatically loaded from the asset before ready. `nonisolated`.", availability: "iOS 7.0+")
//        }
//    }
//}
//
//// MARK: - AVPlayerItem.Status Enum View
//
//struct StatusEnumView: View {
//    var body: some View {
//         VStack(alignment: .leading) {
//             Text("enum Status : Int, @unchecked Sendable").font(.system(.headline, design: .monospaced))
//                 .padding(.bottom, 2)
//
//             HStack(alignment: .top) {
//                 Text("Cases:")
//                 VStack(alignment: .leading) {
//                     Text("case unknown (0)").font(.system(.body, design:.monospaced)).italic()
//                         + Text(" - Not yet determined.")
//                     Text("case readyToPlay (1)").font(.system(.body, design:.monospaced)).italic()
//                         + Text(" - Ready for playback.")
//                     Text("case failed (2)").font(.system(.body, design:.monospaced)).italic()
//                         + Text(" - Playback failed (check error).")
//                 }
//             }
//             .font(.caption)
//             .foregroundColor(.secondary)
//         }
//    }
//}
//
//// MARK: - Initialization Section
//
//struct InitializationSection: View {
//    var body: some View {
////        Section("Initialization") {
//            APIMethodView(
//                signature: "init(url: URL)",
//                description: "Convenience init from a URL. Equivalent to init(asset: AVAsset(url: URL)). `nonisolated`.",
//                availability: "iOS 4.0+", annotation: nil
//            )
//             APIMethodView(
//                signature: "init(asset: AVAsset)",
//                description: "Convenience init from an AVAsset. Loads 'duration' key automatically. @MainActor isolated for non-Sendable AVAsset.",
//                availability: "iOS 4.0+", annotation: nil
//            )
//            APIMethodView(
//                signature: "init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?)",
//                description: "Init from an AVAsset, specifying asset keys to load before becoming ready. @MainActor isolated for non-Sendable AVAsset.",
//                availability: "iOS 7.0+", annotation: nil
//            )
//            APIMethodView(
//                signature: "init(asset: any AVAsset & Sendable)",
//                description: "Convenience init from a Sendable AVAsset. Can be called from any concurrency domain. `nonisolated`.",
//                availability: "iOS 4.0+", annotation: nil
//            )
//            APIMethodView(
//                signature: "init(asset: any AVAsset & Sendable, automaticallyLoadedAssetKeys: [AVPartialAsyncProperty<AVAsset>])",
//                description: "Init from a Sendable AVAsset, specifying async properties to load. Can be called from any concurrency domain. `nonisolated`.",
//                availability: "macOS 12+, iOS 15+, etc.", annotation: nil
//            )
//             APIMethodView(
//                signature: "init(asset: AVAsset, automaticallyLoadedAssetKeys: [AVPartialAsyncProperty<AVAsset>] = [])",
//                description: "Init from a (potentially non-Sendable) AVAsset, specifying async properties to load. @MainActor isolated.",
//                availability: "macOS 12+, iOS 15+, etc.", annotation: nil
//            )
//
//            VStack(alignment: .leading) {
//                Text("Concurrency Notes:").font(.headline)
//                Text("• Initializers taking non-Sendable `AVAsset` are `@MainActor`-isolated.")
//                Text("• Initializers taking `AVAsset & Sendable` are `nonisolated`.")
//            }.font(.caption).foregroundColor(.purple)
////        }
//    }
//}
//
//
//// MARK: - Playback Control Section
//
//struct PlaybackControlSection: View {
//    var body: some View {
////        Section("Playback Control & State") {
//            // Time
//             APIMethodView(
//                signature: "currentTime() -> CMTime",
//                description: "Returns the current playback time. Not KVO observable (use time observers). `nonisolated`.",
//                availability: "iOS 4.0+", annotation: nil
//            )
//             APIMethodView(
//                signature: "currentDate() -> Date?",
//                description: "Maps currentTime to a real-time date, if applicable. `nonisolated`.",
//                 availability: "iOS 6.0+", annotation: nil
//            )
//
//            // Seeking
//             APIMethodView(
//                signature: "seek(to: CMTime, completionHandler: ((Bool) -> Void)?)",
//                description: "Seeks to a time. Cancels pending seeks. Completion indicates if finished without interruption. `nonisolated`.",
//                availability: "iOS 5.0+", annotation: nil
//            )
//             APIMethodView(
//                signature: "seek(to: CMTime) async -> Bool",
//                description: "Async version of seek(to: CMTime:). Returns true if completed. `nonisolated`.",
//                availability: "iOS 5.0+", annotation: nil
//            )
//             APIMethodView(
//                signature: "seek(to: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: ((Bool) -> Void)?)",
//                description: "Seeks within tolerance for efficiency. kCMTimeZero for sample-accurate. `nonisolated`.",
//                availability: "iOS 5.0+", annotation: nil
//            )
//             APIMethodView(
//                signature: "seek(to: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) async -> Bool",
//                description: "Async version of seek with tolerance. `nonisolated`.",
//                availability: "iOS 5.0+", annotation: nil
//            )
//            APIMethodView(
//                signature: "seek(to: Date, completionHandler: ((Bool) -> Void)?) -> Bool",
//                description: "Seeks to a specific date if content is date-ranged. Returns success synchronously, completion updates finish status. `nonisolated`.",
//                availability: "iOS 6.0+", annotation: nil
//            )
//            APIMethodView(
//                signature: "seek(to: date: Date) async -> Bool",
//                description: "Async version of seeking to a date. `nonisolated`.",
//                availability: "macOS 13+, iOS 16+, etc.", annotation: nil
//            )
//             APIMethodView(
//                signature: "cancelPendingSeeks()",
//                description: "Cancels any in-progress seek operations. `nonisolated`.",
//                availability: "iOS 5.0+", annotation: nil
//            )
//
//            // Boundaries & Ranges
//            APIItemView(label: "forwardPlaybackEndTime", value: "CMTime", annotation: "Effective end time when rate > 0. Default is kCMTimeInvalid (use duration). `nonisolated`.", availability: "iOS 4.0+")
//            APIItemView(label: "reversePlaybackEndTime", value: "CMTime", annotation: "Effective end time when rate < 0. Default is kCMTimeInvalid (use kCMTimeZero). `nonisolated`.", availability: "iOS 4.0+")
//            APIItemView(label: "seekableTimeRanges", value: "[NSValue (CMTimeRange)]", annotation: "Read-only. Time ranges the item can seek within. KVO observable. `nonisolated`.", availability: "iOS 4.0+")
//            APIItemView(label: "loadedTimeRanges", value: "[NSValue (CMTimeRange)]", annotation: "Read-only. Time ranges with readily available media data. KVO observable. `nonisolated`.", availability: "iOS 4.0+")
//
//
//            // Capabilities
//             SubsectionHeader(title: "Playback Capabilities (`nonisolated`)")
//             PlaybackCapabilityView(label: "canPlayFastForward", availability: "iOS 5.0+")
//             PlaybackCapabilityView(label: "canPlaySlowForward", availability: "iOS 6.0+")
//             PlaybackCapabilityView(label: "canPlayReverse", availability: "iOS 6.0+")
//             PlaybackCapabilityView(label: "canPlaySlowReverse", availability: "iOS 6.0+")
//             PlaybackCapabilityView(label: "canPlayFastReverse", availability: "iOS 5.0+")
//             PlaybackCapabilityView(label: "canStepForward", availability: "iOS 6.0+")
//             PlaybackCapabilityView(label: "canStepBackward", availability: "iOS 6.0+")
//
//            // Stepping & Timebase
//             APIMethodView(
//                signature: "step(byCount: Int)",
//                description: "Steps forward/backward by a number of frames/steps (depends on enabled tracks). `nonisolated`.",
//                availability: "iOS 4.0+", annotation: nil
//            )
//            APIItemView(label: "timebase", value: "CMTimebase?", annotation: "Read-only. The item's timebase relating item time to a source clock. `nonisolated`.", availability: "iOS 6.0+")
//
//             // Live Streaming Time Offset
//            SubsectionHeader(title: "Live Streaming Time Offsets (`nonisolated`)")
//            APIItemView(label: "configuredTimeOffsetFromLive", value: "CMTime", annotation: "How close to live edge playback begins/resumes. kCMTimeInvalid for non-live.", availability: "iOS 13.0+")
//            APIItemView(label: "recommendedTimeOffsetFromLive", value: "CMTime", annotation: "Read-only. Recommended offset based on network. kCMTimeInvalid for non-live.", availability: "iOS 13.0+")
//            APIItemView(label: "automaticallyPreservesTimeOffsetFromLive", value: "Bool", annotation: "If YES, seeks forward after buffering to maintain live offset. Default NO.", availability: "iOS 13.0+")
//        }
////    }
//}
//
//struct PlaybackCapabilityView: View {
//    let label: String
//    let availability: String
//    var body: some View {
//         HStack {
//             Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
//             Text(label).font(.system(.body, design: .monospaced))
//             Spacer()
//              Text("(iOS \(availability))")
//                  .font(.caption2)
//                  .foregroundColor(.orange)
//         }
//    }
//}
//
//struct SubsectionHeader: View {
//    let title: String
//    var body: some View {
//        Text(title)
//            .font(.subheadline)
//            .foregroundColor(.gray)
//            .padding(.top, 8)
//    }
//}
//
//// MARK: - Notifications Section
//
//struct NotificationsSection: View {
//    var body: some View {
//        Section("Notifications (AVPlayerItem static NSNotification.Name)") {
//            NotificationItemView(name: "timeJumpedNotification", description: "Posted when the time discontinuously changes.", availability: "iOS 5.0+")
//            NotificationItemView(name: "didPlayToEndTimeNotification", description: "Posted when the item plays to its end time.", availability: "iOS 4.0+")
//            NotificationItemView(name: "failedToPlayToEndTimeNotification", description: "Posted when the item fails to play to the end. Check error key.", availability: "iOS 4.3+")
//            NotificationItemView(name: "playbackStalledNotification", description: "Posted when playback stalls due to insufficient buffering.", availability: "iOS 6.0+")
//            NotificationItemView(name: "newAccessLogEntryNotification", description: "Posted when a new entry is added to the access log.", availability: "iOS 6.0+")
//            NotificationItemView(name: "newErrorLogEntryNotification", description: "Posted when a new entry is added to the error log.", availability: "iOS 6.0+")
//            NotificationItemView(name: "recommendedTimeOffsetFromLiveDidChangeNotification", description: "Posted when the recommended live offset changes.", availability: "iOS 13.0+")
//            NotificationItemView(name: "mediaSelectionDidChangeNotification", description: "Posted when the current media selection changes.", availability: "iOS 13.0+")
//
//            SubsectionHeader(title: "Notification Keys")
//            APIItemView(label: "timeJumpedOriginatingParticipantKey", value: "String", annotation: "UserInfo key for timeJumpedNotification. Value is AVCoordinatedPlaybackParticipant if jump originated remotely.", availability: "iOS 15.0+")
//            APIItemView(label: "AVPlayerItemFailedToPlayToEndTimeErrorKey", value: "String", annotation: "UserInfo key for failedToPlayToEndTimeNotification. Value is the NSError.", availability: "iOS 4.3+")
//        }
//    }
//}
//
//struct NotificationItemView: View {
//    let name: String
//    let description: String
//    let availability: String
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(name).font(.system(.body, design: .monospaced)).bold()
//             Text(description).font(.caption).foregroundColor(.secondary)
//             Text("Available: \(availability)")
//                  .font(.caption2)
//                  .foregroundColor(.orange)
//                  .padding(.top, 1)
//        }
//         .padding(.vertical, 2)
//    }
//}
//
//// MARK: - Buffering & Network Section
//
//struct BufferingNetworkSection: View {
//    var body: some View {
//         Section("Buffering & Network (`nonisolated`)") {
//              APIItemView(label: "isPlaybackLikelyToKeepUp", value: "Bool", annotation: "Read-only. Prediction if playback can continue without stalling.", availability: "iOS 4.0+")
//              APIItemView(label: "isPlaybackBufferFull", value: "Bool", annotation: "Read-only. Indicates if the internal buffer is full.", availability: "iOS 4.0+")
//              APIItemView(label: "isPlaybackBufferEmpty", value: "Bool", annotation: "Read-only. Indicates if the internal buffer is empty.", availability: "iOS 4.0+") // Assuming availability aligns with others
//              APIItemView(label: "canUseNetworkResourcesForLiveStreamingWhilePaused", value: "Bool", annotation: "Allows network use to keep live state updated while paused. Default NO.", availability: "iOS 9.0+")
//              APIItemView(label: "preferredForwardBufferDuration", value: "TimeInterval", annotation: "Preferred buffer duration ahead of playhead (seconds). 0 lets player decide.", availability: "iOS 10.0+")
//
//             SubsectionHeader(title: "Bit Rate & Resolution Control (HLS)")
//             APIItemView(label: "preferredPeakBitRate", value: "Double", annotation: "Desired limit for network bandwidth consumption (bits/sec). 0 = no limit.", availability: "iOS 8.0+")
//             APIItemView(label: "preferredPeakBitRateForExpensiveNetworks", value: "Double", annotation: "Desired limit over expensive networks (e.g., cellular). 0 = no limit. Subject to preferredPeakBitRate.", availability: "iOS 15.0+")
//             APIItemView(label: "preferredMaximumResolution", value: "CGSize", annotation: "Preferred max video resolution. CGSizeZero = no limit.", availability: "iOS 11.0+")
//             APIItemView(label: "preferredMaximumResolutionForExpensiveNetworks", value: "CGSize", annotation: "Preferred max resolution over expensive networks. CGSizeZero = no limit. Subject to preferredMaximumResolution.", availability: "iOS 15.0+")
//
//            SubsectionHeader(title: "HLS Variant Selection")
//            APIItemView(label: "startsOnFirstEligibleVariant", value: "Bool", annotation: "If YES, starts playback with the first eligible variant in playlist. Default NO.", availability: "iOS 14.0+")
//            APIItemView(label: "variantPreferences", value: "AVVariantPreferences", annotation: "Preferences for variant switching (e.g., allow lossless). Default .none.", availability: "iOS 14.5+")
//            VariantPreferencesView() // Display the OptionSet
//        }
//    }
//}
//
//struct VariantPreferencesView: View {
//     var body: some View {
//         VStack(alignment: .leading) {
//             Text("struct AVVariantPreferences: OptionSet").font(.caption.monospaced()).bold()
//             HStack(alignment: .top) {
//                 Text("Options:").font(.caption)
//                 VStack(alignment: .leading) {
//                     Text(".scalabilityToLosslessAudio").font(.caption.monospaced())
//                         + Text(" - Permit variants with lossless audio if bandwidth allows.")
//                      Text(".none").font(.caption.monospaced())
//                         + Text(" - Basic player behavior only.")
//                 }
//                 .font(.caption)
//             }
//            .foregroundColor(.secondary)
//            Text("(Available: iOS 14.5+)").font(.caption2).foregroundColor(.orange)
//         }
//         .padding(.leading)
//    }
//}
//
//// MARK: - Media Selection Section
//
//struct MediaSelectionSection: View {
//    var body: some View {
////         Section("Media Selection") {
//             Text("Manages selection of audio, subtitle, and legible tracks via AVMediaSelectionGroup and AVMediaSelectionOption obtained from the asset.")
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding(.bottom, 5)
//
//            APIMethodView(
//                signature: "select(_ mediaSelectionOption: AVMediaSelectionOption?, in mediaSelectionGroup: AVMediaSelectionGroup)",
//                description: "Selects an option in a group, deselecting others. Pass nil to clear if group allows empty selection. `nonisolated`.",
//                availability: "iOS 5.0+", annotation: nil
//            )
//            APIMethodView(
//                signature: "selectMediaOptionAutomatically(in mediaSelectionGroup: AVMediaSelectionGroup)",
//                description: "Re-enables automatic selection for a group (if player applies criteria automatically). `nonisolated`.",
//                availability: "iOS 7.0+", annotation: nil
//            )
//            APIItemView(label: "currentMediaSelection", value: "AVMediaSelection", annotation: "Read-only. Contains the currently selected option for each group. @MainActor isolated.", availability: "iOS 9.0+")
////        }
//    }
//}
//
//
//// MARK: - Audio/Video Processing Section
//
//struct AudioVideoProcessingSection: View {
//    var body: some View {
//         Section("Audio/Video Processing") {
//             APIItemView(label: "videoComposition", value: "AVVideoComposition?", annotation: "Specifies custom video composition instructions. Setter is @MainActor isolated.", availability: "iOS 4.0+")
//            APIItemView(label: "customVideoCompositor", value: "(any AVVideoCompositing)?", annotation: "Read-only. The custom compositor instance, if videoComposition uses one. `nonisolated`.", availability: "iOS 7.0+")
//            APIItemView(label: "seekingWaitsForVideoCompositionRendering", value: "Bool", annotation: "If YES, item timing waits for composed video frame rendering during seeks. Default NO. `nonisolated`.", availability: "iOS 6.0+")
//            APIItemView(label: "textStyleRules", value: "[AVTextStyleRule]?", annotation: "Applies text styling (e.g., font) to WebVTT subtitles if not specified in media. `nonisolated`.", availability: "iOS 6.0+")
//            APIItemView(label: "videoApertureMode", value: "AVVideoApertureMode", annotation: "Video aperture mode (e.g., clean aperture). Default `.cleanAperture`. `nonisolated`.", availability: "iOS 11.0+")
//            APIItemView(label: "appliesPerFrameHDRDisplayMetadata", value: "Bool", annotation: "Controls applying per-frame HDR metadata during playback. Default YES? (Doc unclear). `nonisolated`.", availability: "iOS 14.0+")
//
//             SubsectionHeader(title: "Audio Processing")
//             APIItemView(label: "audioTimePitchAlgorithm", value: "AVAudioTimePitchAlgorithm", annotation: "Algorithm for time stretching/pitch shifting. Default varies by OS version. `nonisolated`.", availability: "iOS 7.0+")
//             APIItemView(label: "allowedAudioSpatializationFormats", value: "AVAudioSpatializationFormats", annotation: "Specifies which source layouts (mono, stereo, multichannel) are allowed for spatialization. Default varies. `nonisolated`.", availability: "iOS 14.0+")
//             APIItemView(label: "audioMix", value: "AVAudioMix?", annotation: "Applies audio mixing parameters. Input parameters must match asset track IDs. Setter is @MainActor isolated.", availability: "iOS 4.0+") // Assuming availability aligns with videoComposition
//
//        }
//    }
//}
//
//// MARK: - Outputs & Data Collection Section
//
//struct OutputsDataCollectionSection: View {
//    var body: some View {
////        Section("Outputs & Data Collection") {
//            SubsectionHeader(title: "AVPlayerItemOutput")
//             Text("Allows retrieving decoded media samples (e.g., video frames, audio samples) for custom processing or display.")
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding(.bottom, 3)
//
//            APIMethodView(
//                signature: "add(_ output: AVPlayerItemOutput)",
//                description: "Adds an output object.",
//                availability: "iOS 6.0+",
//                 annotation: "@MainActor isolated?" // Assumed based on collection access
//            )
//             APIMethodView(
//                signature: "remove(_ output: AVPlayerItemOutput)",
//                description: "Removes an output object.",
//                availability: "iOS 6.0+",
//                 annotation: "@MainActor isolated?" // Assumed based on collection access
//            )
//            APIItemView(label: "outputs", value: "[AVPlayerItemOutput]", annotation: "Read-only. The collection of added outputs. @MainActor isolated?", availability: "iOS 6.0+")
//
//
//            SubsectionHeader(title: "AVPlayerItemMediaDataCollector")
//            Text("Collects specific timed metadata asynchronously as it's encountered during playback.")
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding(.bottom, 3)
//
//             APIMethodView(
//                signature: "add(_ collector: AVPlayerItemMediaDataCollector)",
//                description: "Adds a media data collector. `nonisolated`.",
//                availability: "iOS 9.3+", annotation: nil
//            )
//             APIMethodView(
//                signature: "remove(_ collector: AVPlayerItemMediaDataCollector)",
//                description: "Removes a media data collector. `nonisolated`.",
//                availability: "iOS 9.3+", annotation: nil
//            )
//            APIItemView(label: "mediaDataCollectors", value: "[AVPlayerItemMediaDataCollector]", annotation: "Read-only. The collection of added collectors. `nonisolated`.", availability: "iOS 9.3+")
////        }
//    }
//}
//
//
//// MARK: - Logging Section
//
//struct LoggingSection: View {
//    var body: some View {
////         Section("Logging") {
//             APIMethodView(
//                signature: "accessLog() -> AVPlayerItemAccessLog?",
//                description: "Returns a snapshot of the network access log. Nil if unavailable. `nonisolated`.",
//                availability: "iOS 4.3+", annotation: nil
//            )
//             APIMethodView(
//                signature: "errorLog() -> AVPlayerItemErrorLog?",
//                description: "Returns a snapshot of the error log. Nil if unavailable. `nonisolated`.",
//                availability: "iOS 4.3+", annotation: nil
//            )
//
////             NavigationLink("View Access Log Details", destination: AccessLogDetailView())
//             NavigationLink("View Error Log Details", destination: ErrorLogDetailView())
////        }
//    }
//}
//
////// MARK: - Logging Detail Views (Structure Representation)
////
////struct AccessLogDetailView: View {
////    var body: some View {
////        List {
////            Section("AVPlayerItemAccessLog Structure") {
////                 Text("Inherits from: NSObject, NSCopying, @unchecked Sendable")
////                    .font(.caption).foregroundColor(.gray)
////                APIItemView(label: "events", value: "[AVPlayerItemAccessLogEvent]", annotation: "Ordered list of log events.")
////                APIMethodView(signature: "extendedLogData() -> Data?", description: "Serializes log to W3C Extended Log File Format.")
////                APIItemView(label: "extendedLogDataStringEncoding", value: "UInt", annotation: "Encoding for extendedLogData.")
////            }
////
////            Section("AVPlayerItemAccessLogEvent Properties") {
////                 Text("Inherits from: NSObject, NSCopying, @unchecked Sendable\n(All properties read-only, non-observable)")
////                     .font(.caption2).foregroundColor(.gray)
////                Group {
////                    APIItemView(label: "numberOfMediaRequests", value: "Int")
////                    APIItemView(label: "playbackStartDate", value: "Date?")
////                    APIItemView(label: "uri", value: "String?")
////                    APIItemView(label: "serverAddress", value: "String?")
////                    APIItemView(label: "numberOfServerAddressChanges", value: "Int")
////                    APIItemView(label: "playbackSessionID", value: "String?")
////                    APIItemView(label: "playbackStartOffset", value: "TimeInterval")
////                    APIItemView(label: "segmentsDownloadedDuration", value: "TimeInterval")
////                    APIItemView(label: "durationWatched", value: "TimeInterval")
////                    APIItemView(label: "numberOfStalls", value: "Int")
////                }
////                Group {
////                    APIItemView(label: "numberOfBytesTransferred", value: "Int64")
////                    APIItemView(label: "transferDuration", value: "TimeInterval", availability: "iOS 7.0+")
////                    APIItemView(label: "observedBitrate", value: "Double")
////                    APIItemView(label: "indicatedBitrate", value: "Double")
////                    APIItemView(label: "indicatedAverageBitrate", value: "Double", availability: "iOS 10.0+")
////                    APIItemView(label: "averageVideoBitrate", value: "Double", availability: "iOS 10.0+")
////                    APIItemView(label: "averageAudioBitrate", value: "Double", availability: "iOS 10.0+")
////                    APIItemView(label: "numberOfDroppedVideoFrames", value: "Int")
////                    APIItemView(label: "startupTime", value: "TimeInterval", availability: "iOS 7.0+")
////                    APIItemView(label: "downloadOverdue", value: "Int", availability: "iOS 7.0+")
////                    APIItemView(label: "observedBitrateStandardDeviation", value: "Double", availability: "iOS 7.0+")
////                    APIItemView(label: "playbackType", value: "String?", availability: "iOS 7.0+")
////                    APIItemView(label: "mediaRequestsWWAN", value: "Int", availability: "iOS 7.0+")
////                    APIItemView(label: "switchBitrate", value: "Double", availability: "iOS 7.0+")
////                }
////            }
////        }
////        .navigationTitle("Access Log Details")
////        .listStyle(InsetGroupedListStyle())
////    }
////}
//
//struct ErrorLogDetailView: View {
//    var body: some View {
//         List {
////            Section("AVPlayerItemErrorLog Structure") {
//                 Text("Inherits from: NSObject, NSCopying, @unchecked Sendable")
//                    .font(.caption).foregroundColor(.gray)
//             APIItemView(label: "events", value: "[AVPlayerItemErrorLogEvent]", annotation: "Ordered list of log events.", availability: nil)
//             APIMethodView(signature: "extendedLogData() -> Data?", description: "Serializes log to W3C Extended Log File Format.", availability: nil, annotation: nil)
//             APIItemView(label: "extendedLogDataStringEncoding", value: "UInt", annotation: "Encoding for extendedLogData.", availability: nil)
//            }
//
////            Section("AVPlayerItemErrorLogEvent Properties") {
//                 Text("Inherits from: NSObject, NSCopying, @unchecked Sendable\n(All properties read-only, non-observable)")
//                     .font(.caption2).foregroundColor(.gray)
//        APIItemView(label: "date", value: "Date?", annotation: nil, availability: nil)
//                APIItemView(label: "uri", value: "String?", annotation: nil, availability: nil)
//                APIItemView(label: "serverAddress", value: "String?", annotation: nil, availability: nil)
//                APIItemView(label: "playbackSessionID", value: "String?", annotation: nil, availability: nil)
//                APIItemView(label: "errorStatusCode", value: "Int", annotation: nil, availability: nil)
//                APIItemView(label: "errorDomain", value: "String", annotation: nil, availability: nil)
//                APIItemView(label: "errorComment", value: "String?", annotation: nil, availability: nil)
//        APIItemView(label: "allHTTPResponseHeaderFields", value: "[String : String]?", annotation: nil, availability: "iOS 17.5+")
////            }
//        }
////        .navigationTitle("Error Log Details")
////         .listStyle(InsetGroupedListStyle())
////    }
//}
//
//
//// MARK: - Concurrency Section
//
//struct ConcurrencySection: View {
//    var body: some View {
//        Section("Concurrency Considerations") {
//             VStack(alignment: .leading, spacing: 8) {
//                 Text("@MainActor").font(.headline)
//                 Text("• Some initializers (taking non-`Sendable` AVAsset) and properties (historically `timedMetadata`, `asset`, etc.) require access from the main actor/thread for safety.")
//                 Text("• Attempting access from a background thread will result in runtime warnings or errors.")
//
//                 Text("nonisolated").font(.headline)
//                 Text("• Many properties (e.g., `status`, `error`, `duration`, `tracks`, `isPlaybackLikelyToKeepUp`) and methods (e.g., `seek`, `currentTime`, logging methods) are marked `nonisolated`.")
//                Text("• These can be safely accessed/called from any concurrency context (main or background).")
//
//                 Text("Sendable").font(.headline)
//                 Text("• `AVAsset` itself is *not* Sendable.")
//                 Text("• Subclasses like `AVURLAsset` *are* Sendable.")
//                 Text("• `AVPlayerItem` provides nonisolated initializers specifically for `Sendable` assets, allowing item creation from background threads.")
//                 Text("• Logging classes (`AVPlayerItemAccessLog`, etc.) are `@unchecked Sendable`, requiring careful subclassing if adding mutable state.")
//
//                Text("async/await").font(.headline)
//                Text("• Modern `seek` methods provide `async` versions returning `Bool`, replacing older completion handlers and integrating with Swift Concurrency.")
//
//            }
//            .font(.caption)
//        }
//    }
//}
//
//// MARK: - Deprecated API Section
//
//struct DeprecatedAPISection: View {
//    var body: some View {
////        Section("Deprecated APIs") {
//            APIMethodView(
//                signature: "seek(to: CMTime)",
//                description: "Use seek(to:completionHandler:) instead.",
//                availability: "Deprecated iOS 11.0", annotation: nil
//            )
//            APIMethodView(
//                signature: "seek(to: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime)",
//                description: "Use seek(to:toleranceBefore:toleranceAfter:completionHandler:) instead.",
//                availability: "Deprecated iOS 11.0", annotation: nil
//            )
//            APIMethodView(
//                signature: "seek(to: Date) -> Bool",
//                description: "Use seek(to:completionHandler:) instead.",
//                availability: "Deprecated iOS 11.0", annotation: nil
//            )
//             APIMethodView(
//                 signature: "selectedMediaOption(in mediaSelectionGroup: AVMediaSelectionGroup) -> AVMediaSelectionOption?",
//                description: "Use currentMediaSelection property instead.",
//                availability: "Deprecated iOS 11.0", annotation: nil
//            )
//            APIItemView(label: "timedMetadata", value: "[AVMetadataItem]?", annotation: "Use AVPlayerItemMetadataOutput instead. @MainActor.", availability: "Deprecated iOS 13.0")
//            APIItemView(label: "isAudioSpatializationAllowed", value: "Bool", annotation: "Use allowedAudioSpatializationFormats instead.", availability: "Deprecated iOS 18.0")
//            // Deprecated logging properties were omitted as they were only available briefly
//             // APIItemView(label: "observedMaxBitrate", value: "Double", annotation: "Use observedBitrateStandardDeviation instead.", availability: "Deprecated iOS 15.0")
//             // APIItemView(label: "observedMinBitrate", value: "Double", annotation: "Use observedBitrateStandardDeviation instead.", availability: "Deprecated iOS 15.0")
//
////        }
//    }
//}
//
//// MARK: - Preview
//
//struct AVPlayerItemDocumentationView_Previews: PreviewProvider {
//    static var previews: some View {
//        AVPlayerItemDocumentationView()
//    }
//}
