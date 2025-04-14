//
//  AVAudioSessionVisualizerView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI

// Main view to display the AVAudioSession visualization
struct AVAudioSessionVisualizerView: View {

    // State for potentially collapsible sections (optional)
    @State private var showConfigDetails = true
    @State private var showStateDetails = true
    @State private var showHardwareDetails = true
    @State private var showNotificationDetails = true
    @State private var showFlowDetails = true

    var body: some View {
        NavigationView {
            List {
                // MARK: - Class Overview
                Section("Class Overview") {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("AVAudioSession").font(.title2).bold()
                        HStack {
                            Image(systemName: "swift")
                            Text("Inherits from: NSObject")
                        }
                        HStack {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                            Text("Type: Singleton (Accessed via `sharedInstance()`)")
                        }
                        HStack {
                            Image(systemName: "iphone.gen1") // Representing iOS version
                            Text("Available: iOS 3.0+")
                        }
                        Text("Manages the application's audio behavior within the iOS system.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                    }
                }

                // MARK: - Core Functional Areas (Based on Mind Map)
                Section("Core Functional Areas") {
                    DisclosureGroup("Configuration", isExpanded: $showConfigDetails) {
                        FunctionalAreaItem(icon: "headphones", text: "Categories (setCategory, category, availableCategories, categoryOptions, routeSharingPolicy)")
                        FunctionalAreaItem(icon: "slider.horizontal.3", text: "Modes (setMode, mode, availableModes)")
                        FunctionalAreaItem(icon: "power", text: "Activation (setActive, SetActiveOptions)")
                        FunctionalAreaItem(icon: "dial.medium", text: "Preferences (setPreferredInput, setPreferredSampleRate, etc.)")
                        FunctionalAreaItem(icon: "speaker.wave.2.bubble.left", text: "Interruption Preferences (setPrefersNoInterruptionsFromSystemAlerts, setPrefersInterruptionOnRouteDisconnect)")
                        FunctionalAreaItem(icon: "mic.badge.plus", text: "Echo Cancellation (setPrefersEchoCancelledInput)")
                         FunctionalAreaItem(icon: "mic.and.signal.meter", text: "Microphone Injection (setPreferredMicrophoneInjectionMode)")
                    }

                    DisclosureGroup("State & Hardware Querying", isExpanded: $showStateDetails) {
                        FunctionalAreaItem(icon: "map", text: "Current Route (currentRoute, availableInputs)")
                        FunctionalAreaItem(icon: "cpu", text: "Hardware Status (sampleRate, input/outputChannels, latency, ioBufferDuration, inputGain, dataSources)")
                        FunctionalAreaItem(icon: "volume.3", text: "System Audio Status (isOtherAudioPlaying, secondaryAudioShouldBeSilencedHint, outputVolume, promptStyle, renderingMode)")
                        FunctionalAreaItem(icon: "waveform.path.ecg", text: "Capability Status (isEchoCancelledInputAvailable/Enabled, isMicrophoneInjectionAvailable)")
                        FunctionalAreaItem(icon: "mic.fill", text: "Recording Status (allowHapticsAndSystemSoundsDuringRecording)")
                    }

                    DisclosureGroup("Permissions (Deprecated)", isExpanded: $showStateDetails) {
                         FunctionalAreaItem(icon: "lock.slash", text: "Record Permission (recordPermission, requestRecordPermission) - Use AVAudioApplication now")
                    }

                    DisclosureGroup("Hardware Control", isExpanded: $showHardwareDetails) {
                        FunctionalAreaItem(icon: "speaker.badge.exclamationmark", text: "Output Override (overrideOutputAudioPort)")
                    }

                    DisclosureGroup("Notifications", isExpanded: $showNotificationDetails) {
                        FunctionalAreaItem(icon: "bell.badge", text: "System Events (interruptionNotification, routeChangeNotification, etc.)")
                        FunctionalAreaItem(icon: "key", text: "Notification Keys (AVAudioSessionInterruptionTypeKey, etc.)")
                    }
                }

                // MARK: - Key Methods Visualization
                Section("Key Method Examples") {
                    MethodView(name: "setCategory", params: "_ category: Category, mode: Mode, policy: RouteSharingPolicy, options: CategoryOptions", availability: "iOS 11.0+", description: "Configures the session's primary role.")
                    MethodView(name: "setActive", params: "_ active: Bool, options: SetActiveOptions", availability: "iOS 6.0+", description: "Activates or deactivates the audio session.")
                    MethodView(name: "setPreferredSampleRate", params: "_ sampleRate: Double", availability: "iOS 6.0+", description: "Hints the desired hardware sample rate.")
                    MethodView(name: "overrideOutputAudioPort", params: "_ portOverride: PortOverride", availability: "iOS 6.0+", description: "Temporarily forces output to speaker (PlayAndRecord only).")
                     MethodView(name: "setPrefersEchoCancelledInput", params: "_ value: Bool", availability: "iOS 18.2+", description: "Requests echo cancellation for built-in mic/speaker.")
                }

                // MARK: - Key Properties Visualization
                 Section("Key Property Examples") {
                     PropertyView(name: "category", type: "Category", availability: "iOS 3.0+", description: "The current session category.", isGettable: true, isSettable: false)
                     PropertyView(name: "mode", type: "Mode", availability: "iOS 5.0+", description: "The current session mode.", isGettable: true, isSettable: false)
                     PropertyView(name: "currentRoute", type: "AVAudioSessionRouteDescription", availability: "iOS 6.0+", description: "Describes the current input/output ports.", isGettable: true, isSettable: false)
                     PropertyView(name: "outputVolume", type: "Float", availability: "iOS 6.0+", description: "Current system output volume [0.0, 1.0].", isGettable: true, isSettable: false, isObservable: true)
                     PropertyView(name: "isOtherAudioPlaying", type: "Bool", availability: "iOS 6.0+", description: "Indicates if any other app is playing audio.", isGettable: true, isSettable: false)
                     PropertyView(name: "isMicrophoneInjectionAvailable", type: "Bool", availability: "iOS 18.2+", description: "Checks if microphone injection is possible.", isGettable: true, isSettable: false, isObservable: true)
                 }

                // MARK: - Nested Types Visualization
                Section("Nested Types (Enums & OptionSets)") {
                    NestedTypeView(name: "Category", type: "enum", examples: ["playback", "record", "playAndRecord", "ambient", "multiRoute"])
                    NestedTypeView(name: "Mode", type: "enum", examples: ["default", "voiceChat", "videoRecording", "measurement", "moviePlayback"])
                    NestedTypeView(name: "CategoryOptions", type: "struct OptionSet", examples: ["mixWithOthers", "duckOthers", "allowBluetooth", "defaultToSpeaker"])
                    NestedTypeView(name: "RouteSharingPolicy", type: "enum", examples: ["default", "longFormAudio", "longFormVideo", "independent"])
                    NestedTypeView(name: "SetActiveOptions", type: "struct OptionSet", examples: ["notifyOthersOnDeactivation"])
                    NestedTypeView(name: "RecordPermission", type: "enum", examples: ["undetermined", "denied", "granted"])
                     NestedTypeView(name: "MicrophoneInjectionMode", type: "enum", examples: ["unspecified", "voiceProcessing", "allow"])
                    // Add more nested types as needed
                }

                // MARK: - Relationships Visualization
                Section("Relationships with Other Types") {
                    RelationshipView(relatedType: "AVAudioSessionPortDescription", role: "Describes input/output ports (e.g., builtInMic, headphones). Used in `currentRoute`, `availableInputs`, `setPreferredInput`.")
                    RelationshipView(relatedType: "AVAudioSessionRouteDescription", role: "Describes the combination of active input/output ports (`currentRoute`).")
                    RelationshipView(relatedType: "AVAudioSessionDataSourceDescription", role: "Describes specific data sources on a port (e.g., Front Mic, Bottom Mic). Used with `input/outputDataSource(s)`, `setInput/OutputDataSource`.")
                    RelationshipView(relatedType: "AVAudioChannelLayout", role: "Describes multichannel layouts supported by the current route.")
                    RelationshipView(relatedType: "NSNotification.Name", role: "Used for observing system audio events (interruptions, route changes, etc.).")
                }

                // MARK: - Flow Visualizations
                 Section("Common Flows") {
                    DisclosureGroup("Basic Setup Flow", isExpanded: $showFlowDetails) {
                         FlowchartView(title: "Basic Session Setup", steps: [
                             .action(text: "Get Shared Instance", icon: "person.crop.circle.badge.checkmark"),
                             .action(text: "Set Category/Mode/Options", icon: "slider.horizontal.3"),
                             .decision(text: "Set Other Preferences?", yesPath: [.action(text: "Set Prefs (Sample Rate, Buffer, etc.)", icon: "dial.medium")], noPath: []),
                             .action(text: "Activate Session (setActive)", icon: "power"),
                             .result(text: "Session Configured & Active", icon: "checkmark.circle.fill")
                         ])
                     }

                     DisclosureGroup("Interruption Handling Flow", isExpanded: $showFlowDetails) {
                         FlowchartView(title: "Interruption Handling", steps: [
                             .action(text: "Register for interruptionNotification", icon: "bell"),
                             .event(text: "Interruption Occurs", icon: "exclamationmark.triangle"),
                             .action(text: "Notification Received", icon: "envelope.fill"),
                             .decision(text: "Check Type (Begin/End)", yesPath: [
                                 .action(text: "Interruption Started", icon: "pause.circle") ,
                                 .action(text: "Check Reason (iOS 14.5+)", icon: "questionmark.circle"),
                                 .action(text: "Pause Audio / Update UI", icon: "pause.rectangle.fill")
                             ], noPath: [ // Represents "End" path
                                 .action(text: "Interruption Ended", icon: "play.circle"),
                                 .decision(text: "Check Options (ShouldResume?)", yesPath: [.action(text: "Resume Audio / Update UI", icon:"play.rectangle.fill")], noPath: [.action(text:"Stay Paused / Update UI", icon: "pause.rectangle.fill")]),
                             ]),
                             .result(text: "Handling Complete", icon: "checkmark.circle.fill")
                         ])
                     }

                     DisclosureGroup("Route Change Handling Flow", isExpanded: $showFlowDetails) {
                         FlowchartView(title: "Route Change Handling", steps: [
                            .action(text: "Register for routeChangeNotification", icon: "bell"),
                            .event(text: "Route Changes (e.g., Headphones)", icon: "headphones"),
                            .action(text: "Notification Received", icon: "envelope.fill"),
                            .decision(text: "Check Reason (Why changed?)", yesPath: [ // Represents handling specific reasons
                                .action(text: "Get Previous Route (Optional)", icon: "arrow.uturn.backward.circle"),
                                .action(text: "Update Audio Engine/UI based on New/Old Route & Reason", icon: "gearshape.2.fill")
                            ], noPath: [ // Represents handling unknown reasons
                                .action(text: "Query currentRoute & Update", icon: "magnifyingglass")
                            ]),
                            .result(text: "Handling Complete", icon: "checkmark.circle.fill")
                         ])
                     }
                 }

            } // End List
            .listStyle(SidebarListStyle()) // Use a style suitable for lots of sections
            .navigationTitle("AVAudioSession Viz")
        }
    }
}

// MARK: - Helper Views

struct FunctionalAreaItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20, alignment: .center)
            Text(text).font(.body)
        }
        .padding(.vertical, 2)
    }
}

struct MethodView: View {
    let name: String
    let params: String
    let availability: String
    let description: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "function") // Placeholder for method icon
                    .foregroundColor(.purple)
                Text(name).bold() + Text("(" + params + ")")
            }
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 25) // Indent description slightly
            Text(availability)
                .font(.caption2)
                .foregroundColor(.orange)
                .padding(.leading, 25)
        }
        .padding(.vertical, 3)
    }
}

struct PropertyView: View {
    let name: String
    let type: String
    let availability: String
    let description: String
    let isGettable: Bool
    let isSettable: Bool
    var isObservable: Bool = false // Default to false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                 Image(systemName: "propertylist") // Placeholder for property icon
                     .foregroundColor(.blue)
                 Text(name).bold() + Text(": \(type)")
                 Spacer()
                 if isGettable { Image(systemName: "g.circle").foregroundColor(.green) }
                 if isSettable { Image(systemName: "s.circle").foregroundColor(.orange) }
                if isObservable { Image(systemName: "eye.circle").foregroundColor(.pink).help("Key-Value Observable") }
             }
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 25)
            Text(availability)
                .font(.caption2)
                .foregroundColor(.orange)
                .padding(.leading, 25)
             }
        .padding(.vertical, 3)
    }
}

struct NestedTypeView: View {
    let name: String
    let type: String
    let examples: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(name)").font(.headline) + Text(" (\(type))")
            Text("Examples: \(examples.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 15)
        }
        .padding(.vertical, 2)
    }
}

struct RelationshipView: View {
    let relatedType: String
    let role: String

    var body: some View {
        VStack(alignment: .leading) {
             HStack {
                 Image(systemName: "link")
                 Text(relatedType).bold()
             }
             Text(role)
                 .font(.caption)
                 .foregroundColor(.gray)
                 .padding(.leading, 25)
         }
        .padding(.vertical, 2)
    }
}

// MARK: - Flowchart Views

// Represents different kinds of steps in a flowchart
enum FlowStep {
    case action(text: String, icon: String)
    case decision(text: String, yesPath: [FlowStep] = [], noPath: [FlowStep] = [])
    case event(text: String, icon: String)
    case result(text: String, icon: String)

    // Simple helper to get associated text
    var text: String {
        switch self {
        case .action(let text, _), .decision(let text, _, _), .event(let text, _), .result(let text, _):
            return text
        }
    }
     // Simple helper to get associated icon
     var icon: String? {
         switch self {
         case .action(_, let icon), .event(_, let icon), .result(_, let icon):
             return icon
         case .decision:
             return "diamond" // Default icon for decision
        }
    }
}

// A reusable view to display a flowchart
struct FlowchartView: View {
    let title: String
    let steps: [FlowStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.headline).padding(.bottom, 5)
            ForEach(0..<steps.count, id: \.self) { index in
                FlowStepView(step: steps[index], level: 0)
                if index < steps.count - 1 {
                    FlowConnector()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// Renders a single step in the flowchart, handling nesting for decisions
struct FlowStepView: View {
    let step: FlowStep
    let level: Int // Indentation level for decision paths

    private var indent: CGFloat { CGFloat(level * 20) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                 Spacer().frame(width: indent) // Indentation
                 FlowStepContentView(step: step)
            }

            // Handle decision paths
            if case .decision(_, let yesPath, let noPath) = step {
                if !yesPath.isEmpty {
                    DecisionPathView(label: "YES", steps: yesPath, level: level + 1)
                 }
                 if !noPath.isEmpty {
                     DecisionPathView(label: "NO ", steps: noPath, level: level + 1)
                 }
            }
        }
    }
}

// Renders the content (box/diamond) of a single flow step
struct FlowStepContentView: View {
    let step: FlowStep

    var body: some View {
        HStack(spacing: 8) {
             if let iconName = step.icon {
                 Image(systemName: iconName)
                     .foregroundColor(iconColor)
                     .frame(width: 15)
             }
             Text(step.text)
                 .font(.system(size: 13))
                 .lineLimit(2)
                 .fixedSize(horizontal: false, vertical: true) // Allow text wrap
             Spacer() // Push to left
         }
         .padding(8)
         .background(backgroundColor)
         .cornerRadius(5)
         .overlay(
             RoundedRectangle(cornerRadius: 5)
                .stroke(borderColor, lineWidth: 1)
         )
         .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes width
    }

    // --- Styling Helpers ---
    private var backgroundColor: Color {
        switch step {
        case .action: return Color.blue.opacity(0.15)
        case .decision: return Color.purple.opacity(0.15)
        case .event: return Color.orange.opacity(0.15)
        case .result: return Color.green.opacity(0.15)
        }
    }

    private var borderColor: Color {
        switch step {
        case .action: return .blue
        case .decision: return .purple
        case .event: return .orange
        case .result: return .green
        }
    }

      private var iconColor: Color {
        switch step {
         case .action: return .blue
         case .decision: return .purple
         case .event: return .orange
         case .result: return .green
         }
    }
}

// Renders the path (Yes/No) leading from a decision
struct DecisionPathView: View {
    let label: String
    let steps: [FlowStep]
    let level: Int

    private var indent: CGFloat { CGFloat(level * 20) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
             HStack {
                 Spacer().frame(width: indent - 15) // Align label slightly before the arrow
                 Text(label)
                     .font(.caption)
                     .foregroundColor(.gray)
                     .padding(.horizontal, 4)
                     .background(Color(.systemBackground)) // Opaque background
                     .offset(y: 5) // Position over the arrow
             }
            FlowConnector(indent: indent) // Connector from decision

            ForEach(0..<steps.count, id: \.self) { index in
                FlowStepView(step: steps[index], level: level)
                if index < steps.count - 1 {
                    FlowConnector(indent: indent) // Connector between steps in the path
                }
            }
        }
    }
}

// Simple connector line for flowcharts
struct FlowConnector: View {
    var indent: CGFloat = 0
    var body: some View {
        HStack {
            Spacer().frame(width: indent)
            Image(systemName: "arrow.down")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 15)
                .foregroundColor(.gray)
            Spacer()
        }
         .frame(maxWidth:.infinity, alignment: .leading)
       // .padding(.vertical, 0) // Reduced vertical padding
    }
}

// MARK: - Preview
#Preview {
    AVAudioSessionVisualizerView()
}
