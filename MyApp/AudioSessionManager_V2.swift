//
//  AudioSessionManager_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import Foundation
import AVFoundation
import Combine // Used for potential future KVO observation if needed

class AudioSessionManager {

    let session: AVAudioSession
    private var observers: [NSObjectProtocol] = [] // To hold notification observers

    init() {
        // 1. Get the Shared Instance
        session = AVAudioSession.sharedInstance()
        print("AVAudioSession instance obtained.")
        setupNotifications()
    }

    deinit {
        removeNotifications()
    }

    // MARK: - Core Configuration

    func demonstrateConfiguration() {
        print("\n--- Demonstrating Core Configuration ---")

        // Setting Category (various forms)
        do {
            // Basic (iOS 3.0+)
            print("Setting category to .playback (iOS 3.0+)")
            try session.setCategory(.playback)
            print("  Current Category: \(session.category.rawValue)")

            // With Options (iOS 6.0+)
            print("Setting category to .playAndRecord with options (iOS 6.0+)")
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            print("  Current Category: \(session.category.rawValue)")
            print("  Current Options: \(session.categoryOptions.rawValue)") // Raw value for demo

            // With Mode and Options (iOS 10.0+)
            print("Setting category to .playAndRecord, mode .videoRecording, with options (iOS 10.0+)")
            try session.setCategory(.playAndRecord, mode: .videoRecording, options: [.duckOthers])
            print("  Current Category: \(session.category.rawValue)")
            print("  Current Mode: \(session.mode.rawValue)")
            print("  Current Options: \(session.categoryOptions.rawValue)")

            // With Policy, Mode, Options (iOS 11.0+) - Primarily for LongFormAudio/Video
            print("Setting category to .playback, mode .moviePlayback, policy .longFormAudio (iOS 11.0+)")
            // Note: LongForm policy usually requires specific category/mode and often disallows options.
            try session.setCategory(.playback, mode: .moviePlayback, policy: .longFormAudio, options: [])
            print("  Current Category: \(session.category.rawValue)")
            print("  Current Mode: \(session.mode.rawValue)")
            print("  Current Policy: \(session.routeSharingPolicy.rawValue)") // Raw value for demo
            print("  Current Options: \(session.categoryOptions.rawValue)")


            // Resetting to a common default
            print("Resetting category to .ambient, mode .default")
            try session.setCategory(.ambient, mode: .default, options: [])


        } catch {
            print("  Error setting category/mode/options: \(error.localizedDescription)")
        }

        // Querying Available Categories/Modes (iOS 9.0+)
        if #available(iOS 9.0, *) {
             print("Available Categories: \(session.availableCategories.map { $0.rawValue })")
             print("Available Modes: \(session.availableModes.map { $0.rawValue })")
        }

        // Setting Mode Separately (iOS 5.0+)
        do {
            print("Setting mode separately to .voiceChat (iOS 5.0+)")
            try session.setMode(.voiceChat)
            print("  Current Mode: \(session.mode.rawValue)")
        } catch {
             print("  Error setting mode: \(error.localizedDescription)")
        }
    }

    // MARK: - Session Activation

    func demonstrateActivation() {
        print("\n--- Demonstrating Session Activation ---")
        do {
            // Activate (iOS 6.0+ for options)
            print("Attempting to activate session...")
            // Option .notifyOthersOnDeactivation is common
            try session.setActive(true, options: [.notifyOthersOnDeactivation])
            print("  Session successfully activated.")
        } catch {
            print("  Error activating session: \(error.localizedDescription)")
        }

        // ... app does audio work ...

//        do {
//            // Deactivate (iOS 6.0+ for options)
//            print("Attempting to deactivate session...")
//            try session.setActive(false, options: [.notifyOthersOnDeactivation])
//            print("  Session successfully deactivated.")
//        } catch {
//            print("  Error deactivating session: \(error.localizedDescription)")
//        }
        // Note: Deactivation often happens automatically or based on app lifecycle.
        // Leaving it active for further demonstrations.
    }

    // MARK: - Hardware Preferences & State

    func demonstrateHardwarePreferencesAndState() {
        print("\n--- Demonstrating Hardware Preferences & State ---")

        // --- Setting Preferences ---
        print("Setting Hardware Preferences:")
        do {
            if #available(iOS 6.0, *) {
                let preferredSampleRate = 48000.0
                print("  Setting preferred sample rate: \(preferredSampleRate)")
                try session.setPreferredSampleRate(preferredSampleRate)
            }

            let preferredBufferDuration: TimeInterval = 0.005 // 5ms
            print("  Setting preferred IO buffer duration: \(preferredBufferDuration)")
            try session.setPreferredIOBufferDuration(preferredBufferDuration)

            if #available(iOS 7.0, *) {
                let preferredInputChannels = 1
                print("  Setting preferred input channels: \(preferredInputChannels)")
                try session.setPreferredInputNumberOfChannels(preferredInputChannels)

                let preferredOutputChannels = 2
                print("  Setting preferred output channels: \(preferredOutputChannels)")
                try session.setPreferredOutputNumberOfChannels(preferredOutputChannels)
            }

             if #available(iOS 14.0, *) {
                let preferredOrientation = AVAudioSession.StereoOrientation.landscapeLeft
                print("  Setting preferred input orientation: \(preferredOrientation.rawValue)")
                try session.setPreferredInputOrientation(preferredOrientation)
             }

            if #available(iOS 6.0, *) {
                if session.isInputGainSettable {
                    let preferredGain: Float = 0.75
                    print("  Setting preferred input gain: \(preferredGain) (Hardware supports gain setting)")
                    try session.setInputGain(preferredGain)
                } else {
                    print("  Input gain is not settable for the current route.")
                }
            }

        } catch {
            print("  Error setting hardware preferences: \(error.localizedDescription)")
        }

        // --- Querying Actual State ---
        print("\nQuerying Actual Hardware State:")
        if #available(iOS 6.0, *) {
             print("  Actual Sample Rate: \(session.sampleRate)")
             print("  Input Available: \(session.isInputAvailable)") // KVO observable
             print("  Input Gain Settable: \(session.isInputGainSettable)")
             print("  Actual Input Gain: \(session.inputGain)") // KVO observable
             print("  Input Channels: \(session.inputNumberOfChannels)") // KVO observable
             print("  Output Channels: \(session.outputNumberOfChannels)") // KVO observable
             print("  Input Latency: \(session.inputLatency) seconds")
             print("  Output Latency: \(session.outputLatency) seconds")
        }
         print("  Actual IO Buffer Duration: \(session.ioBufferDuration) seconds")

        if #available(iOS 7.0, *) {
             print("  Max Input Channels: \(session.maximumInputNumberOfChannels)")
             print("  Max Output Channels: \(session.maximumOutputNumberOfChannels)")
             print("  Preferred Input Channels: \(session.preferredInputNumberOfChannels)")
             print("  Preferred Output Channels: \(session.preferredOutputNumberOfChannels)")
        }
        if #available(iOS 6.0, *) {
            print("  Preferred Sample Rate: \(session.preferredSampleRate)")
        }
        if #available(iOS 14.0, *) {
             print("  Preferred Input Orientation: \(session.preferredInputOrientation.rawValue)")
             print("  Actual Input Orientation: \(session.inputOrientation.rawValue)")
        }
         if #available(iOS 17.2, *) {
             print("  Supported Output Channel Layouts: \(session.supportedOutputChannelLayouts.count)")
             // You would inspect the actual AVAudioChannelLayout objects here
         }
    }

    // MARK: - Routing and Data Sources

    func demonstrateRoutingAndDataSources() {
        print("\n--- Demonstrating Routing & Data Sources ---")

        // Query Routes
        if #available(iOS 7.0, *) {
            if let availableInputs = session.availableInputs {
                print("Available Inputs (\(availableInputs.count)):")
                availableInputs.forEach { print("  - Port: \($0.portName), Type: \($0.portType.rawValue)") }
            } else {
                print("No available inputs for current category/mode.")
            }
        }
        if #available(iOS 6.0, *) {
            let currentRoute = session.currentRoute
            print("Current Route:")
            print("  Inputs (\(currentRoute.inputs.count)):")
            currentRoute.inputs.forEach { print("    - Port: \($0.portName), Type: \($0.portType.rawValue), UID: \($0.uid)") }
            print("  Outputs (\(currentRoute.outputs.count)):")
            currentRoute.outputs.forEach { print("    - Port: \($0.portName), Type: \($0.portType.rawValue), UID: \($0.uid)") }
        }

        // Set Preferred Input (iOS 7.0+)
        if #available(iOS 7.0, *) {
            if let firstAvailableInput = session.availableInputs?.first {
                do {
                    print("Attempting to set preferred input to: \(firstAvailableInput.portName)")
                    try session.setPreferredInput(firstAvailableInput)
                    if let preferred = session.preferredInput {
                        print("  Successfully set preferred input to: \(preferred.portName)")
                    } else {
                        print("  Preferred input cleared or not set.")
                    }
                } catch {
                    print("  Error setting preferred input: \(error.localizedDescription)")
                }
            } else {
                 print("No available inputs to set as preferred.")
            }
        }

        // Override Output Port (iOS 6.0+) - Only valid for PlayAndRecord
        if #available(iOS 6.0, *) {
            if session.category == .playAndRecord || session.category == .multiRoute {
                 print("Attempting to override output to Speaker (requires PlayAndRecord/MultiRoute category)")
                 do {
                     try session.overrideOutputAudioPort(.speaker)
                     print("  Successfully overrode output to speaker.")
                     // To revert: try session.overrideOutputAudioPort(.none)
                 } catch {
                    print("  Error overriding output port: \(error.localizedDescription)")
                 }
            } else {
                print("Output override only valid for PlayAndRecord/MultiRoute category (Current: \(session.category.rawValue))")
            }
        }

        // Data Sources (iOS 6.0+) - Check if available first
        print("\nData Sources:")
        if #available(iOS 6.0, *) {
            if let inputSources = session.inputDataSources { // KVO observable
                 print("Input Data Sources (\(inputSources.count)):")
                 inputSources.forEach { print("  - Name: \($0.dataSourceName), ID: \($0.dataSourceID)") }
                 if let currentInputSource = session.inputDataSource {
                     print("  Current Input Source: \(currentInputSource.dataSourceName)")
                 }

                 // Try setting the first available input source
                 if let firstSource = inputSources.first {
                     do {
                         print("  Attempting to set Input Data Source to: \(firstSource.dataSourceName)")
                         try session.setInputDataSource(firstSource)
                          if let setSource = session.inputDataSource {
                             print("    Successfully set Input Data Source to: \(setSource.dataSourceName)")
                          }
                     } catch {
                         print("    Error setting Input Data Source: \(error.localizedDescription)")
                     }
                 }
             } else {
                 print("No Input Data Sources available for the current route.")
             }

            if let outputSources = session.outputDataSources { // LVO observable
                 print("Output Data Sources (\(outputSources.count)):")
                 outputSources.forEach { print("  - Name: \($0.dataSourceName), ID: \($0.dataSourceID)") }
                 if let currentOutputSource = session.outputDataSource {
                     print("  Current Output Source: \(currentOutputSource.dataSourceName)")
                 }
                 // Try setting the first available output source
                 if let firstSource = outputSources.first {
                    do {
                         print("  Attempting to set Output Data Source to: \(firstSource.dataSourceName)")
                        try session.setOutputDataSource(firstSource)
                        if let setSource = session.outputDataSource {
                             print("    Successfully set Output Data Source to: \(setSource.dataSourceName)")
                          }
                    } catch {
                        print("    Error setting Output Data Source: \(error.localizedDescription)")
                    }
                 }
             } else {
                print("No Output Data Sources available for the current route.")
             }
        }
    }

    // MARK: - Permissions (Record)

    func demonstratePermissions() {
        print("\n--- Demonstrating Recording Permissions (Deprecated) ---")
        print("Note: AVAudioSession recordPermission APIs are deprecated since iOS 17. Use AVAudioApplication instead.")

        // Query Permission (iOS 8.0 - 17.0)
        if #available(iOS 8.0, *) {
            let permission = session.recordPermission
            print("Current Record Permission Status (Deprecated API): \(permission.rawValue)") // Raw value for demo
        }

        // Request Permission (iOS 7.0 - 17.0)
        if #available(iOS 7.0, *) {
             print("Requesting Record Permission (Deprecated API)...")
             session.requestRecordPermission { granted in
                 // IMPORTANT: This block may be called on a different thread! Dispatch to main if needed for UI updates.
                 DispatchQueue.main.async {
                     if granted {
                         print("  Record permission granted (via deprecated API).")
                     } else {
                         print("  Record permission denied (via deprecated API).")
                     }
                 }
             }
        }
         print("Modern Equivalent: Use AVAudioApplication.requestRecordPermission { granted in ... }")
    }


    // MARK: - Querying Session State

    func demonstrateSessionStateQueries() {
        print("\n--- Demonstrating Session State Queries ---")

        if #available(iOS 6.0, *) {
             print("Is other audio playing? \(session.isOtherAudioPlaying)")
             print("Output Volume: \(session.outputVolume)") // KVO observable
        }
        if #available(iOS 8.0, *) {
             print("Should secondary audio be silenced hint? \(session.secondaryAudioShouldBeSilencedHint)")
        }
         if #available(iOS 13.0, *) {
             print("Prompt Style: \(session.promptStyle.rawValue)") // KVO observable
         }
         if #available(iOS 17.2, *) {
             print("Rendering Mode: \(session.renderingMode.rawValue)")
         }
    }


    // MARK: - Specialized Features

    func demonstrateSpecializedFeatures() {
        print("\n--- Demonstrating Specialized Features ---")

        // Haptics & System Sounds during Recording (iOS 13.0+)
        if #available(iOS 13.0, *) {
            do {
                let allow = true
                print("Setting allow haptics/system sounds during recording: \(allow)")
                try session.setAllowHapticsAndSystemSoundsDuringRecording(allow)
                print("  Value is now: \(session.allowHapticsAndSystemSoundsDuringRecording)")
            } catch {
                print("  Error setting allow haptics: \(error.localizedDescription)")
            }
        }

        // Prefer No Interruptions from System Alerts (iOS 14.5+)
        if #available(iOS 14.5, *) {
            do {
                let preferNoAlerts = true
                print("Setting prefers no interruptions from system alerts: \(preferNoAlerts)")
                try session.setPrefersNoInterruptionsFromSystemAlerts(preferNoAlerts)
                print("  Value is now: \(session.prefersNoInterruptionsFromSystemAlerts)")
            } catch {
                print("  Error setting prefers no system alert interruptions: \(error.localizedDescription)")
            }
        }

         // Prefer Interruption on Route Disconnect (iOS 17.0+)
        if #available(iOS 17.0, *) {
            do {
                let preferInterrupt = true // e.g., for a music player
                print("Setting prefers interruption on route disconnect: \(preferInterrupt)")
                try session.setPrefersInterruptionOnRouteDisconnect(preferInterrupt)
                print("  Value is now: \(session.prefersInterruptionOnRouteDisconnect)")
            } catch {
                print("  Error setting prefers disconnect interruption: \(error.localizedDescription)")
            }
        }

        // Aggregated IO Preference (iOS 10.0+) - For PlayAndRecord/MultiRoute
        if #available(iOS 10.0, *) {
             if session.category == .playAndRecord || session.category == .multiRoute {
                 do {
                     let ioType = AVAudioSession.IOType.aggregated
                     print("Setting aggregated IO preference: \(ioType.rawValue)")
                     try session.setAggregatedIOPreference(ioType)
                     // Note: Querying this preference directly isn't exposed
                 } catch {
                     print("  Error setting aggregated IO preference: \(error.localizedDescription)")
                 }
             } else {
                print("Aggregated IO preference only valid for PlayAndRecord/MultiRoute category.")
             }
        }

        // Supports Multichannel Content (iOS 15.0+) - For 'Now Playing' apps
        if #available(iOS 15.0, *) {
            do {
                let supportsMulti = true
                print("Setting supports multichannel content: \(supportsMulti)")
                try session.setSupportsMultichannelContent(supportsMulti)
                print("  Value is now: \(session.supportsMultichannelContent)")
            } catch {
                 print("  Error setting supports multichannel content: \(error.localizedDescription)")
            }
        }

        // --> Features available in iOS 18.2 and later (Conceptual) <--
        // These require conditional compilation or runtime checks if building with older SDKs.
        // #if compiler(>=6.0) // Example check for Swift 6 compiler (associated with Xcode 16 / iOS 18 SDK)
        if #available(iOS 18.2, *) { // Runtime check

            // Echo Cancelled Input
            print("\nEcho Cancellation (iOS 18.2+):")
            print("  Is Echo Cancelled Input Available: \(session.isEchoCancelledInputAvailable)")
            if session.isEchoCancelledInputAvailable {
                do {
                    let preferEchoCancel = true
                    print("  Setting prefers echo cancelled input: \(preferEchoCancel)")
                    try session.setPrefersEchoCancelledInput(preferEchoCancel)
                    print("  Current preference: \(session.prefersEchoCancelledInput)")
                    // Note: Check isEchoCancelledInputEnabled *after* session is active
                    print("  Is Echo Cancelled Input Enabled (check when active): \(session.isEchoCancelledInputEnabled)")
                } catch {
                    print("  Error setting prefers echo cancelled input: \(error.localizedDescription)")
                }
            }

            // Microphone Injection
            print("\nMicrophone Injection (iOS 18.2+):")
             print("  Is Microphone Injection Available: \(session.isMicrophoneInjectionAvailable)") // Observe Notification
            if session.isMicrophoneInjectionAvailable {
                do {
                    let injectionMode = AVAudioSession.MicrophoneInjectionMode.spokenAudio // or .block, .systemDefined
                    print("  Setting preferred microphone injection mode: \(injectionMode.rawValue)")
                    try session.setPreferredMicrophoneInjectionMode(injectionMode)
                        print("  Current preference: \(session.preferredMicrophoneInjectionMode.rawValue)")
                } catch {
                    print("  Error setting preferred microphone injection mode: \(error.localizedDescription)")
                }
            }
        }
        // #endif // End of compiler check example
    }


    // MARK: - Notification Handling

    private func setupNotifications() {
        print("Setting up AVAudioSession notifications...")
        let nc = NotificationCenter.default

        // Interruption Notification (iOS 6.0+)
        let interruptionObserver = nc.addObserver(forName: AVAudioSession.interruptionNotification, object: session, queue: .main) { [weak self] notification in
            self?.handleInterruption(notification: notification)
        }

        // Route Change Notification (iOS 6.0+)
        let routeChangeObserver = nc.addObserver(forName: AVAudioSession.routeChangeNotification, object: session, queue: .main) { [weak self] notification in
            self?.handleRouteChange(notification: notification)
        }

        // Media Services Were Lost (iOS 7.0+)
        let lostObserver = nc.addObserver(forName: AVAudioSession.mediaServicesWereLostNotification, object: session, queue: .main) { notification in
             print("Notification Received: Media Services Were Lost. Re-initialize audio objects: \(notification)")
        }

        // Media Services Were Reset (iOS 6.0+)
        let resetObserver = nc.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification, object: session, queue: .main) { notification in
            print("Notification Received: Media Services Were Reset. Re-initialize audio session and objects:\(notification)")
            // Might need to re-activate session, reset category, etc.
        }

        // Silence Secondary Audio Hint (iOS 8.0+)
        let silenceHintObserver = nc.addObserver(forName: AVAudioSession.silenceSecondaryAudioHintNotification, object: session, queue: .main) { [weak self] notification in
            self?.handleSilenceSecondaryAudioHint(notification: notification)
        }

        // Spatial Playback Capabilities Changed (iOS 15.0+)
        let spatialObserver = nc.addObserver(forName: AVAudioSession.spatialPlaybackCapabilitiesChangedNotification, object: session, queue: .main) { [weak self] notification in
             self?.handleSpatialPlaybackCapabilitiesChanged(notification: notification)
        }

        // Rendering Mode Change (iOS 17.2+)
        let renderModeObserver = nc.addObserver(forName: AVAudioSession.renderingModeChangeNotification, object: session, queue: .main) { [weak self] notification in
            self?.handleRenderingModeChange(notification: notification)
        }

        // Rendering Capabilities Change (iOS 17.2+)
         let renderCapsObserver = nc.addObserver(forName: AVAudioSession.renderingCapabilitiesChangeNotification, object: session, queue: .main) { notification in
             print("Notification Received: Rendering Capabilities Changed: \(notification)")
             // Re-query session.supportedOutputChannelLayouts if needed
         }


        observers = [
            interruptionObserver, routeChangeObserver, lostObserver, resetObserver,
            silenceHintObserver, spatialObserver, renderModeObserver, renderCapsObserver // Add future observers here
        ]


        // Microphone Injection Capabilities Change (iOS 18.2+) - Add conditionally
        if #available(iOS 18.2, *) {
             let micInjectionObserver = nc.addObserver(forName: AVAudioSession.microphoneInjectionCapabilitiesChangeNotification, object: session, queue: .main) { [weak self] notification in
                self?.handleMicrophoneInjectionCapabilitiesChange(notification: notification)
            }
            observers.append(micInjectionObserver)
        }
    }

    private func removeNotifications() {
        print("Removing AVAudioSession notifications...")
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
    }

    // --- Individual Notification Handlers ---

    private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            print("Interruption Notification: Invalid user info")
            return
        }

        print("Notification Received: Interruption - Type: \(type == .began ? "Began" : "Ended")")

        if type == .began {
             print("  Audio session interrupted.")
             // Pause audio, update UI, etc.
             if #available(iOS 14.5, *), let reasonValue = userInfo[AVAudioSessionInterruptionReasonKey] as? UInt, let reason = AVAudioSession.InterruptionReason(rawValue: reasonValue) {
                 print("  Interruption Reason: \(reason.rawValue)") // e.g., default, appEnteredBackground, etc.
             }

        } else { // .ended
            print("  Audio interruption ended.")
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    print("  Hint: Should resume audio playback.")
                    // Resume audio playback if appropriate
                } else {
                     print("  Hint: Should NOT resume audio playback.")
                }
            }
        }
    }

    private func handleRouteChange(notification: Notification) {
         guard let userInfo = notification.userInfo,
               let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
               let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
             print("Route Change Notification: Invalid user info")
             return
         }

        print("Notification Received: Route Change - Reason: \(routeChangeReasonString(reason)) (\(reason.rawValue)))")

        if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
            print("  Previous Route:")
             previousRoute.inputs.forEach { print("    - Input: \($0.portName)") }
             previousRoute.outputs.forEach { print("    - Output: \($0.portName)") }
        }

        let currentRoute = session.currentRoute
        print("  Current Route:")
        currentRoute.inputs.forEach { print("    - Input: \($0.portName)") }
        currentRoute.outputs.forEach { print("    - Output: \($0.portName)") }

        // Handle specific route changes (e.g., headphones unplugged)
        switch reason {
            case .newDeviceAvailable:
                print("  Action Hint: New device connected.")
            case .oldDeviceUnavailable:
                print("  Action Hint: Old device disconnected (e.g., headphones removed). Pause playback?")
                 // Check session.prefersInterruptionOnRouteDisconnect if needed (iOS 17+)
            case .categoryChange:
                 print("  Action Hint: Category changed. Re-evaluate hardware settings.")
            case .override:
                 print("  Action Hint: Route changed due to override.")
             case .wakeFromSleep:
                 print("  Action Hint: System woke from sleep.")
             case .noSuitableRouteForCategory:
                  print("  Action Hint: No suitable route. May need to change category.")
             case .routeConfigurationChange:
                 print("  Action Hint: Ports/channels changed without connection status change.")
            default:
                 print("  Reason details: Check documentation for \(reason.rawValue)")
        }
         // Check spatial audio capabilities on new route if needed
         if #available(iOS 15.0, *) {
             let spatialEnabled = session.currentRoute.outputs.first?.isSpatialAudioEnabled ?? false
             print("  Current Route Spatial Audio Enabled: \(spatialEnabled)")
         }
         // Refresh hardware parameter queries if necessary
         // demonstrateHardwarePreferencesAndState() // Example call
    }

    private func handleSilenceSecondaryAudioHint(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
              let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue) else {
               print("Silence Secondary Audio Hint Notification: Invalid user info")
               return
        }
        let hintValue = session.secondaryAudioShouldBeSilencedHint // Get current state

        print("Notification Received: Silence Secondary Audio Hint - Type: \(type == .begin ? "Begin" : "End")")
        print("  Current Hint Value: \(hintValue)")
        // If type is .begin, consider muting non-essential audio.
        // If type is .end, consider unmuting.
    }

     private func handleSpatialPlaybackCapabilitiesChanged(notification: Notification) {
         guard let userInfo = notification.userInfo,
             let enabled = userInfo[AVAudioSessionSpatialAudioEnabledKey] as? NSNumber else {
              print("Spatial Playback Caps Changed Notification: Invalid user info")
              return
         }
         print("Notification Received: Spatial Playback Capabilities Changed - System Preference Enabled: \(enabled.boolValue)")
         // Also check route capabilities: session.currentRoute.outputs.first?.isSpatialAudioEnabled
     }

     private func handleRenderingModeChange(notification: Notification) {
        if #available(iOS 17.2, *) {
         guard let userInfo = notification.userInfo,
               let modeValue = userInfo[AVAudioSessionRenderingModeNewRenderingModeKey] as? Int,
               let newMode = AVAudioSession.RenderingMode(rawValue: modeValue) else {
             print("Rendering Mode Change Notification: Invalid user info")
             return
         }
         print("Notification Received: Rendering Mode Changed - New Mode: \(newMode.rawValue)")
         // Badge content appropriately based on newMode
        }
     }

     @available(iOS 18.2, *)
     private func handleMicrophoneInjectionCapabilitiesChange(notification: Notification) {
         guard let userInfo = notification.userInfo,
             let available = userInfo[AVAudioSessionMicrophoneInjectionIsAvailableKey] as? NSNumber else {
              print("Microphone Injection Caps Changed Notification: Invalid user info")
              return
         }
          print("Notification Received: Microphone Injection Capabilities Changed - Available: \(available.boolValue)")
          // Update UI or logic based on availability
     }


    // Helper to make route change reasons readable
    private func routeChangeReasonString(_ reason: AVAudioSession.RouteChangeReason) -> String {
        switch reason {
            case .unknown: return "Unknown"
            case .newDeviceAvailable: return "NewDeviceAvailable"
            case .oldDeviceUnavailable: return "OldDeviceUnavailable"
            case .categoryChange: return "CategoryChange"
            case .override: return "Override"
            case .wakeFromSleep: return "WakeFromSleep"
            case .noSuitableRouteForCategory: return "NoSuitableRouteForCategory"
            case .routeConfigurationChange: return "RouteConfigurationChange" // iOS 7+
            default: return "Other (\(reason.rawValue))"
        }
    }
}

// MARK: - Example Usage

func runAudioSessionDemonstrations() {
    print("Starting AVAudioSession Demonstrations...")
    let manager = AudioSessionManager()

    // Run through the different demonstration functions
    manager.demonstrateConfiguration()
    manager.demonstrateActivation() // Activate before querying hardware/routing state
    manager.demonstrateHardwarePreferencesAndState()
    manager.demonstrateRoutingAndDataSources()
    manager.demonstratePermissions()
    manager.demonstrateSessionStateQueries()
    manager.demonstrateSpecializedFeatures()

    print("\nDemonstrations Complete. Notifications will continue to be logged.")
    print("Keep the program running to observe notifications (e.g., plug/unplug headphones).")

    // Keep the manager alive to receive notifications if running in a simple context
    // In a real app, the manager would typically live longer.
     // You might need RunLoop.main.run() or similar in a command-line tool context
     // Keep a reference to the manager if needed:
     // globalManager = manager
}

// var globalManager: AudioSessionManager? // Example to keep manager alive

// Call the main function to run the demos
// runAudioSessionDemonstrations()

// --- End of File ---
