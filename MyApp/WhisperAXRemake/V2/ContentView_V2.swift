////
////  ContentView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
////  ContentView.swift
////  WhisperAX (Enhanced)
////
////  For licensing see accompanying LICENSE.md file.
////  Copyright © 2024 Argmax, Inc. All rights reserved.
////
////  ** This file combines ContentView and its subviews for demonstration. **
////  ** In a real project, these subviews should be in separate files. **
////  ** Assumes ContentViewModel, AppSettings, and TranscriptionService exist. **
//
//import SwiftUI
//import WhisperKit // For Enums like ModelState, MLComputeUnits, etc.
//import AVFoundation // For DeviceID used in ViewModel
//import CoreML
//
//// MARK: - Main Content View
//
//struct ContentView: View {
//    // Use @StateObject for the ViewModel lifecycle tied to the View
//    // Initialize with default or injected services/settings
//    @StateObject private var viewModel = ContentViewModel(transcriptionService: TranscriptionServiceProtocol.self as! TranscriptionServiceProtocol)
//    @StateObject private var settings = AppSettings()
//
//    @State private var columnVisibility: NavigationSplitViewVisibility = .all
//    // isFilePickerPresented is now managed within ControlsView and passed up if needed,
//    // or directly triggered via ViewModel. For simplicity, keep it local to trigger .fileImporter
//    @State private var isFilePickerPresented = false
//
//    var body: some View {
//        NavigationSplitView(columnVisibility: $columnVisibility) {
//            SidebarView()
//                .navigationTitle("WhisperAX")
//                .navigationSplitViewColumnWidth(min: 300, ideal: 350)
//                 // Pass viewModel and settings down the hierarchy
//                .environmentObject(viewModel)
//                .environmentObject(settings)
//
//        } detail: {
//            DetailView(isFilePickerPresented: $isFilePickerPresented) // Pass binding
//                 // Pass viewModel and settings down the hierarchy
//                .environmentObject(viewModel)
//                .environmentObject(settings)
//                // Attach fileImporter here, triggered by the DetailView's ControlsView binding
//                .fileImporter(
//                    isPresented: $isFilePickerPresented,
//                    allowedContentTypes: [.audio], // Adjust UTI types as needed
//                    allowsMultipleSelection: false
//                 ) { result in
//                    // handleFilePicker(result: result)
//                 }
//        }
//        .onAppear {
//            // Initial setup if needed, though most is in ViewModel init
//        }
//        // Alert for showing errors from ViewModel
//        .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _,_ in viewModel.errorMessage = nil } )) {
//             Button("OK", role: .cancel) { }
//         } message: {
//             Text(viewModel.errorMessage ?? "An unknown error occurred.")
//         }
//    }
//
//    // Handle file picker result and pass to ViewModel
//    func handleFilePicker(result: Result<[URL], Error>) async {
//         switch result {
//         case .success(let urls):
//             guard let url = urls.first else { return }
//             // Ensure the ViewModel handles security scoping if necessary *inside* transcribeFile
//             await viewModel.transcribeFile(url: url)
//         case .failure(let error):
//             viewModel.errorMessage = "Failed to pick file: \(error.localizedDescription)"
//         }
//     }
//}
//
//// MARK: - Sidebar View
//
//struct SidebarView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings // Settings might be needed by subviews
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) { // Added spacing
//            ModelSelectorView() // Uses viewModel, settings implicitly via EnvironmentObject
//                .padding(.bottom) // Keep some space
//
//            ComputeUnitsView() // Uses viewModel, settings implicitly
//                .padding(.bottom) // Keep some space
//
//            TabSelectionView() // Uses viewModel implicitly
//
//            Spacer() // Pushes App Info to bottom
//
//            AppInfoView() // Uses viewModel implicitly
//        }
//        .padding() // Add padding to the whole sidebar content
//    }
//}
//
//// MARK: - Detail View
//
//struct DetailView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//    @Binding var isFilePickerPresented: Bool // Receive binding from ContentView
//
//    var body: some View {
//        VStack(spacing: 0) { // Use spacing 0 if dividers provide enough space visually
//            TranscriptionDisplayView() // Uses viewModel, settings
//                .layoutPriority(1) // Allow text view to expand
//
//            Divider().padding(.vertical, 8) // Explicit divider with padding
//
//            ControlsView(isFilePickerPresented: $isFilePickerPresented) // Uses viewModel, settings, pass binding
//        }
//        .padding() // Padding for the detail content
//        .toolbar {
//            ToolbarItem {
//                Button {
//                    viewModel.copyTranscriptionToClipboard()
//                } label: {
//                    Label("Copy Text", systemImage: "doc.on.doc")
//                }
//                .keyboardShortcut("c", modifiers: .command)
//                // Ensure button is enabled only when there's text?
//                .disabled(viewModel.transcriptionText.isEmpty && viewModel.confirmedEagerText.isEmpty)
//            }
//        }
//    }
//}
//
//// MARK: - Model Selector View (Card UI)
//
//struct ModelSelectorView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//
//    var body: some View {
//        GroupBox("Model Management") { // Using GroupBox for card style
//            VStack(alignment: .leading, spacing: 10) { // Added alignment and spacing
//                HStack {
//                    // Model Status Indicator
//                    Image(systemName: "circle.fill")
//                        .foregroundStyle(viewModel.modelState.color)
//                        .symbolEffect(.variableColor.iterative.reversing, isActive: viewModel.modelState.isProcessing)
//                    Text(viewModel.modelState.description)
//                        .font(.headline)
//
//                    Spacer()
//
//                    // Model Picker
//                    modelPicker
//                        .frame(maxWidth: 200) // Give picker some space
//
//                    // Action Buttons
//                    HStack(spacing: 15) { // Group buttons
//                         deleteButton
//                         folderButton // macOS only
//                         repoLinkButton
//                    }
//                }
//
//                 // Loading / Progress View
//                 modelLoadingProgressView // Extracted subview
//            }
//            .padding(.vertical, 5) // Add padding inside the GroupBox
//        }
//    }
//
//    // --- Subviews for Clarity ---
//
//    @ViewBuilder
//    private var modelPicker: some View {
//        if !viewModel.availableModels.isEmpty {
//             Picker("Model", selection: $settings.selectedModel) { // Added label for accessibility
//                 ForEach(viewModel.availableModels, id: \.self) { model in
//                     HStack {
//                         Image(systemName: viewModel.localModels.contains(model) ? "checkmark.circle.fill" : "arrow.down.circle")
//                             .foregroundColor(viewModel.localModels.contains(model) ? .green : .accentColor) // Use accent color for download
//                         Text(model.friendlyName).tag(model)
//                    }
//                 }
//             }
//             .labelsHidden() // Hide label visually but keep for accessibility
//             .pickerStyle(.menu)
//             .disabled(viewModel.modelState.isProcessing) // Disable during load/download
//         } else if viewModel.modelState == .unloaded {
//             // Indicate that models need to be fetched or none are available
//             Text("Fetching models...")
//                   .font(.caption)
//                   .foregroundColor(.secondary)
//         }
//          else {
//             ProgressView().scaleEffect(0.8) // Show loading indicator if models aren't loaded yet
//         }
//    }
//
//    @ViewBuilder
//    private var modelLoadingProgressView: some View {
//         if viewModel.modelState == .loading || viewModel.modelState == .prewarming || viewModel.modelState == .downloading {
//              VStack(alignment: .leading) {
//                 ProgressView(value: viewModel.downloadProgress, total: 1.0)
//                 Text(viewModel.modelState == .prewarming ? "Specializing model (\(String(format: "%.0f", viewModel.downloadProgress * 100))%)..." : "\(viewModel.modelState.description) (\(String(format: "%.0f", viewModel.downloadProgress * 100))%)...")
//                     .font(.caption)
//                     .foregroundColor(.secondary)
//             }
//             .padding(.top, 5)
//         } else if viewModel.modelState == .unloaded {
//             // Load Button
//            Button {
//                viewModel.loadSelectedModel()
//            } label: {
//                Label("Load Model", systemImage: "bolt.fill")
//                     .frame(maxWidth: .infinity)
//            }
//             .buttonStyle(.borderedProminent)
//             .padding(.top, 5)
//             .disabled(settings.selectedModel.isEmpty || viewModel.availableModels.isEmpty) // Ensure a model is selected and available
//        }
//    }
//
//    private var deleteButton: some View {
//        Button {
//            // Add confirmation dialog?
//            //viewModel.deleteSelectedModel()
//        } label: {
//            Image(systemName: "trash")
//        }
//        .help("Delete Selected Model")
//        .buttonStyle(.borderless)
//        .foregroundColor(.red)
//        .disabled(!viewModel.localModels.contains(settings.selectedModel) || viewModel.modelState.isProcessing)
//    }
//
//    #if os(macOS)
//    private var folderButton: some View {
//        Button {
//            viewModel.openModelFolder()
//        } label: {
//            Image(systemName: "folder")
//        }
//        .help("Show Model Folder")
//        .buttonStyle(.borderless)
//        .disabled(!viewModel.modelFolderExists || viewModel.modelState.isProcessing)
//    }
//    #else
//    private var folderButton: some View { EmptyView() }
//    #endif
//
//    private var repoLinkButton: some View {
//        Button {
//            viewModel.openRepoURL()
//        } label: {
//            Image(systemName: "link.circle")
//        }
//        .help("Open Model Repository (\(settings.repoName))")
//        .buttonStyle(.borderless)
//    }
//}
//
//// MARK: - Compute Units View (Card UI)
//
//struct ComputeUnitsView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//    @State private var isExpanded: Bool = true // Keep expanded by default
//
//    var body: some View {
//        GroupBox { // Card style
//            DisclosureGroup("Compute Units", isExpanded: $isExpanded) {
//                VStack(spacing: 8) { // Use VStack for spacing
//                    computeUnitPicker(
//                        label: "Audio Encoder",
//                        selection: $settings.encoderComputeUnits, statusColor: .red
//                         //statusColor: viewModel.modelState.isProcessing ? .yellow : (viewModel.modelState == .loaded ? .green : .red) // Reflect overall state for simplicity
//                    )
//                    computeUnitPicker(
//                        label: "Text Decoder ", // Added space for alignment
//                        selection: $settings.decoderComputeUnits,
//                         statusColor: viewModel.modelState.isProcessing ? .yellow : (viewModel.modelState == .loaded ? .green : .red)
//                    )
//                }
//                .padding(.top, 5) // Space below disclosure title
//            }
//            .disabled(viewModel.modelState.isProcessing) // Disable during load/download/prewarm
//        }
//    }
//
//    // Reusable picker row
//    private func computeUnitPicker(label: String, selection: Binding<MLComputeUnits>, statusColor: Color) -> some View {
//        HStack {
//            Image(systemName: "circle.fill")
//                .foregroundStyle(statusColor) // Show status based on overall model state
//                 // Symbol effect might be distracting here unless tied to specific component load state
//                //.symbolEffect(.variableColor, isActive: viewModel.modelState.isProcessing)
//
//            Text(label).frame(width: 100, alignment: .leading) // Align labels
//            Spacer()
//            Picker(label, selection: selection) { // Label for accessibility
//                 Text("CPU").tag(MLComputeUnits.cpuOnly)
//                 Text("CPU + GPU").tag(MLComputeUnits.cpuAndGPU)
//                 Text("Neural Engine").tag(MLComputeUnits.cpuAndNeuralEngine)
//                 Text("All").tag(MLComputeUnits.all) // Add 'All' option if applicable
//             }
//             .labelsHidden()
//             .pickerStyle(.menu)
//             .frame(maxWidth: 150) // Control picker width
//        }
//    }
//}
//
//// MARK: - Tab Selection View
//
//struct TabSelectionView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//
//    var body: some View {
//        EmptyView()
////         List(ContentViewModel.Tab.allCases, selection: $viewModel.selectedTab) { tab in
////             Label(tab.rawValue, systemImage: tab.imageName)
////                .tag(tab) // Tag with the enum case itself
////        }
////         .listStyle(.sidebar) // Appropriate style for sidebar list
////         .frame(maxHeight: CGFloat(ContentViewModel.Tab.allCases.count * 45)) // Limit height
////         .disabled(viewModel.modelState != .loaded) // Disable if model not loaded
////         .opacity(viewModel.modelState != .loaded ? 0.5 : 1.0) // Dim if disabled
//    }
//}
//
//// MARK: - App Info View
//
//struct AppInfoView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//             Text("App Version: \(viewModel.appVersion) (\(viewModel.appBuild))")
//             Text("Device: \(viewModel.deviceName)")
//             Text("OS: \(viewModel.osVersion)")
//         }
//        .font(.caption)
//        .foregroundColor(.secondary)
//        .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
//    }
//}
//
//// MARK: - Transcription Display View (Card UI)
//
//struct TranscriptionDisplayView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings // Needed for timestamp/preview toggle
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            // Audio Level Meter (Optional Card)
//            if viewModel.isRecording && !viewModel.audioSignal.bufferEnergy.isEmpty {
//                SignalEnergyView(energy: viewModel.audioSignal.bufferEnergy, threshold: Float(settings.silenceThreshold))
//                    .frame(height: 30)
//                    .padding(.vertical, 5)
//                    .background(Color(.secondarySystemBackground)) // Subtle background
//                    .cornerRadius(5)
//            }
//
//            // GroupBox for the main transcription area
//             GroupBox("Transcription Output") {
//                 ScrollViewReader { scrollProxy in // Added ScrollViewReader
//                     ScrollView {
//                         VStack(alignment: .leading, spacing: 8) {
//                             if settings.enableEagerDecoding && viewModel.selectedTab == .stream {
//                                 eagerTextView
//                             } else {
//                                 standardTextView
//                             }
//                             
//                             // Placeholder for auto-scroll target
//                             Spacer().frame(height: 0).id("bottom")
//
//                             // Optional Decoder Preview
//                             decoderPreviewSection
//                         }
//                         .textSelection(.enabled)
//                         .frame(maxWidth: .infinity, alignment: .leading)
//                         .padding(5) // Inner padding for scroll content
//                     }
//                     .onChange(of: viewModel.transcriptionText) { _, _ in // Scroll on any text change
//                         withAnimation {
//                            scrollProxy.scrollTo("bottom", anchor: .bottom)
//                        }
//                     }
//                     .onChange(of: viewModel.confirmedEagerText) { _, _ in
//                         withAnimation {
//                            scrollProxy.scrollTo("bottom", anchor: .bottom)
//                        }
//                     }
//                      .onChange(of: viewModel.hypothesisEagerText) { _, _ in
//                         withAnimation {
//                            scrollProxy.scrollTo("bottom", anchor: .bottom)
//                        }
//                     }
//                 }
//                // Progress bar for non-streaming transcription
//                fileTranscriptionProgressView
//             }
//        }
//        .frame(maxHeight: .infinity) // Allow vertical expansion
//    }
//
//    // --- Subviews for Text Display ---
//
//    @ViewBuilder
//    private var standardTextView: some View {
//        let combinedSegments = viewModel.confirmedSegments + viewModel.unconfirmedSegments
//        
//        if combinedSegments.isEmpty && viewModel.isTranscribing {
//            Text("Listening..." + (viewModel.decoderPreviewText.isEmpty ? "" : "\n\(viewModel.decoderPreviewText)"))
//                    .font(.headline)
//                    .foregroundColor(.secondary)
//        } else if combinedSegments.isEmpty && !viewModel.isTranscribing {
//             Text("No transcription.") // Placeholder when empty and not transcribing
//                 .font(.headline)
//                 .foregroundColor(.secondary)
//        } else {
//             // Confirmed Segments
//             ForEach(viewModel.confirmedSegments) { segment in // Segment needs to be Identifiable (or use .enumerated())
//                 segmentText(segment: segment, confirmed: true, showTimestamps: settings.enableTimestamps)
//             }
//             // Unconfirmed Segments
//             ForEach(viewModel.unconfirmedSegments) { segment in
//                 segmentText(segment: segment, confirmed: false, showTimestamps: settings.enableTimestamps)
//             }
//         }
//    }
//
//    // Helper for segment display
//    @ViewBuilder
//    private func segmentText(segment: TranscriptionSegment, confirmed: Bool, showTimestamps: Bool) -> some View {
//        let timestampPrefix = showTimestamps ? "[\(String(format: "%.2f", segment.start)) → \(String(format: "%.2f", segment.end))] " : ""
//        Text(timestampPrefix + segment.text)
//            .fontWeight(confirmed ? .medium : .regular)
//            .foregroundColor(confirmed ? .primary : .secondary)
//            .multilineTextAlignment(.leading)
//             .id(segment.id) // Ensure each segment has a unique ID for ForEach
//    }
//    
//    // Make TranscriptionSegment Identifiable if it's not already (e.g., using start time + text)
//    // extension TranscriptionSegment: Identifiable { public var id: String { "\(start)-\(text)" } }
//
//    @ViewBuilder
//    private var eagerTextView: some View {
//         if viewModel.confirmedEagerText.isEmpty && viewModel.hypothesisEagerText.isEmpty && viewModel.isTranscribing {
//              Text("Listening..." + (viewModel.decoderPreviewText.isEmpty ? "" : "\n\(viewModel.decoderPreviewText)"))
//                  .font(.headline)
//                  .foregroundColor(.secondary)
//         } else if viewModel.confirmedEagerText.isEmpty && viewModel.hypothesisEagerText.isEmpty && !viewModel.isTranscribing {
//              Text("No transcription.")
//                  .font(.headline)
//                  .foregroundColor(.secondary)
//         } else {
//              // Use Text concatenation for different styles
//              Text(viewModel.confirmedEagerText)
//                 .fontWeight(.medium) // Make confirmed text slightly bolder
//                 .foregroundColor(.primary)
//                 + Text(" ") // Add space if both exist
//                 + Text(viewModel.hypothesisEagerText) // Append hypothesis directly
//                 .fontWeight(.regular)
//                 .foregroundColor(.secondary) // Style hypothesis differently
//         }
//    }
//
//    @ViewBuilder
//    private var decoderPreviewSection: some View {
//        if settings.enableDecoderPreview && !viewModel.decoderPreviewText.isEmpty {
//             Divider().padding(.vertical, 4)
//             VStack(alignment: .leading) {
//                 Text("Decoder Preview:")
//                     .font(.caption.weight(.semibold)) // Slightly emphasize label
//                     .foregroundColor(.secondary)
//                 Text(viewModel.decoderPreviewText)
//                     .font(.caption)
//                     .foregroundColor(.orange) // Use a distinct color
//                     .frame(maxWidth: .infinity, alignment: .leading)
//             }
//         }
//    }
//
//    @ViewBuilder
//    private var fileTranscriptionProgressView: some View {
//        // Show progress only during file transcription (selectedTab is transcribe, not recording)
//         if viewModel.isTranscribing && viewModel.selectedTab == .transcribe && !viewModel.isRecording {
//             // Progress calculation ideally comes from the service/WhisperKit callback
//             // Using a simple indeterminate progress bar for now
//             ProgressView() // Indeterminate progress
//                 .progressViewStyle(.linear)
//                 .padding(.top, 8)
//                 .transition(.opacity) // Fade in/out
//         }
//    }
//}
//
//// MARK: - Signal Energy View
//
//struct SignalEnergyView: View {
//    let energy: [Float]
//    let threshold: Float
//    private let maxEnergyPoints = 300 // Limit displayed points visually
//    private let energyScaleFactor: CGFloat = 2.0 // Amplify visual difference
//    private let minBarHeight: CGFloat = 1.0
//
//    var body: some View {
//        Canvas { context, size in
//            let displayEnergy = energy.suffix(maxEnergyPoints)
//            let widthPerBar = size.width / CGFloat(maxEnergyPoints) // Distribute across available width
//            let maxBarHeight = size.height
//
//            var xOffset: CGFloat = 0
//            for level in displayEnergy {
//                let isAboveThreshold = level > threshold
//                let barHeight = min(max(CGFloat(level) * maxBarHeight * energyScaleFactor, minBarHeight), maxBarHeight)
//                let barRect = CGRect(x: xOffset, y: maxBarHeight - barHeight, width: widthPerBar, height: barHeight)
//
//                context.fill(
//                    Path(barRect),
//                    with: .color(isAboveThreshold ? Color.green.opacity(0.7) : Color.red.opacity(0.6))
//                )
//                xOffset += widthPerBar
//            }
//        }
//        .clipped() // Clip drawing to bounds
//    }
//}
//
//// MARK: - Controls View (Card UI)
//
//struct ControlsView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//    @Binding var isFilePickerPresented: Bool // Passed down for file button action
//
//    var body: some View {
//        VStack(spacing: 15) { // Add spacing between sections
//            BasicSettingsView() // Basic Task/Lang/Metrics
//
//            GroupBox("Actions") { // Card style for main actions
//                // Mode specific controls
//                switch viewModel.selectedTab {
//                case .transcribe:
//                     transcribeModeControls
//                case .stream:
//                     streamModeControls
//                }
//            }
//        }
//         // Show settings sheet - triggered by button press
//        .sheet(isPresented: $viewModel.showSettingsSheet) {
//             SettingsView()
//                 .environmentObject(viewModel) // Ensure sheet has access
//                 .environmentObject(settings)
//         }
//    }
//
//    // --- Mode Specific Control Views ---
//
//    private var transcribeModeControls: some View {
//        VStack(spacing: 15) {
//            // Top row: Reset, Audio Device, Settings
//            HStack {
//                resetButton
//                Spacer()
//                #if os(macOS)
//                 audioDevicePicker.disabled(viewModel.isRecording || viewModel.isTranscribing) // Disable if busy
//                #else
//                Spacer() // Maintain balance on iOS
//                #endif
//                Spacer()
//                settingsButton
//            }
//
//            // Bottom row: Action Buttons
//            HStack(spacing: 20) {
//                 fileButton
//                 recordButton(isStream: false)
//            }
//        }
//        .padding(5) // Padding inside the GroupBox
//    }
//
//    private var streamModeControls: some View {
//        VStack(spacing: 15) {
//            // Top row: Reset, Audio Device, Settings
//             HStack {
//                resetButton
//                Spacer()
//                #if os(macOS)
//                  audioDevicePicker.disabled(viewModel.isRecording) // Disable only if recording
//                #else
//                Spacer()
//                #endif
//                Spacer()
//                settingsButton
//             }
//
//            // Bottom row: Record Button and status info
//            ZStack { // Use ZStack to overlay status info
//                 recordButton(isStream: true) // Center button
//
//                 // Status overlays - shown only when recording
//                 if viewModel.isRecording {
//                    HStack {
//                        // Encoding/Decoding Loops (Left)
//                        VStack(alignment: .leading) {
//                             Text("Enc: \(viewModel.metrics.currentEncodingLoops)")
//                             Text("Dec: \(viewModel.metrics.currentDecodingLoops)")
//                         }
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                         .padding(.leading) // Indent from left edge
//
//                         Spacer() // Push buffer time to the right
//
//                         // Buffer Time (Right)
//                        Text("\(String(format: "%.1f", viewModel.audioSignal.bufferSeconds)) s")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                            .padding(.trailing) // Indent from right edge
//                    }
//                     .frame(maxWidth: .infinity)
//                     .offset(y: 40) // Position below the button
//                 }
//             }
//             .frame(minHeight: 70) // Ensure ZStack has height for overlays
//        }
//        .padding(5) // Padding inside the GroupBox
//    }
//
//    // --- Common Control Elements ---
//
//    private var resetButton: some View {
//        Button {
//             viewModel.resetTranscriptionState()
//        } label: {
//            Label("Reset Text", systemImage: "arrow.clockwise") // More specific label
//        }
//        .buttonStyle(.borderless)
//        .disabled(viewModel.isTranscribing || viewModel.isRecording) // Disable if busy
//    }
//
//    private var settingsButton: some View {
//        Button {
//             viewModel.showSettingsSheet = true
//        } label: {
//            Label("Settings", systemImage: "slider.horizontal.3")
//        }
//        .buttonStyle(.borderless)
//    }
//
//    #if os(macOS)
//    private var audioDevicePicker: some View {
//        Picker("Input", selection: $settings.selectedAudioInput) {
//            if viewModel.audioDevices.isEmpty {
//                  Text("No Input Devices").tag("No Audio Input")
//            } else {
//                ForEach(viewModel.audioDevices) { device in // Needs AudioDevice: Identifiable
//                     Text(device.name).tag(device.name)
//                 }
//            }
//        }
//        .labelsHidden()
//        .frame(maxWidth: 200) // Limit width
//    }
//    // Assume AudioDevice is Identifiable and Hashable for Picker
//    
//    #endif
//
//    private var fileButton: some View {
//        Button {
//             isFilePickerPresented = true // Trigger the file importer in ContentView
//        } label: {
//            VStack {
//                Image(systemName: "doc.text.fill")
//                    .font(.title) // Slightly smaller icon
//                 Text("FROM FILE")
//                     .font(.headline)
//            }
//            // Removed fixed frame to allow natural sizing with padding
//        }
//        .buttonStyle(CardButtonStyle(enabled: viewModel.modelState == .loaded && !viewModel.isRecording && !viewModel.isTranscribing)) // More precise enabled state
//        .disabled(viewModel.modelState != .loaded || viewModel.isRecording || viewModel.isTranscribing) // Explicit disable
//    }
//
//     private func recordButton(isStream: Bool) -> some View {
//         Button {
//             //viewModel.toggleRecording(isStream: isStream)
//         } label: {
//             if viewModel.isRecording {
//                 // Stop Button Style
//                 Image(systemName: "stop.circle.fill")
//                     .resizable()
//                     .scaledToFit()
//                     .frame(width: 60, height: 60) // Slightly smaller stop button
//                     .foregroundColor(viewModel.modelState == .loaded ? .red : .gray)
//
//             } else {
//                 // Start Button Style
//                 VStack {
//                    Image(systemName: isStream ? "record.circle" : "mic.circle.fill")
//                        .font(.title) // Consistent icon size
//                     Text(isStream ? "STREAM" : "RECORD")
//                        .font(.headline)
//                 }
//             }
//         }
//          .buttonStyle(CardButtonStyle(enabled: viewModel.modelState == .loaded, isRecording: viewModel.isRecording))
//          .disabled(viewModel.modelState != .loaded) // Disable if model not loaded
//          .contentTransition(.symbolEffect(.replace)) // Nice transition for icon change
//     }
//}
//
//// MARK: - Basic Settings View
//
//struct BasicSettingsView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//
//    var body: some View {
//        VStack(spacing: 10) {
//            Picker("Task", selection: $settings.selectedTask) {
//                 Text("Transcribe").tag("transcribe")
//                 Text("Translate").tag("translate")
//            }
//            .pickerStyle(SegmentedPickerStyle())
//             .disabled(viewModel.modelState != .loaded || viewModel.isTranscribing || viewModel.isRecording) // Disable when busy or model not loaded
//
//            LabeledContent { // Better layout for Label + Picker
//                 Picker("Language", selection: $settings.selectedLanguage) {
//                     ForEach(viewModel.availableLanguages, id: \.self) { language in
//                         Text(language.capitalized).tag(language) // Use capitalized language name
//                     }
//                 }
////                 .disabled(viewModel.modelState != .loaded || !(viewModel.whisperKit?.modelVariant.isMultilingual ?? false) || viewModel.isTranscribing || viewModel.isRecording) // More precise disabling
//            } label: { // Use LabeledContent label
//                 Label("Language", systemImage: "globe")
//             }
//
//            // Metrics Display - improved layout
//             HStack {
//                 metricItem(value: viewModel.metrics.realTimeFactor, unit: "RTF", precision: 2)
//                 Spacer()
//                 metricItem(value: viewModel.metrics.tokensPerSecond, unit: "tok/s", precision: 0)
//                 Spacer()
//                 #if os(macOS) // Speed factor might be less relevant on iOS
//                 metricItem(value: viewModel.metrics.speedFactor, unit: "x Speed", precision: 1)
//                 Spacer()
//                 #endif
//                 metricItem(value: viewModel.metrics.firstTokenTime - viewModel.metrics.pipelineStart, unit: "s First", precision: 2, showPositiveOnly: true)
//             }
//            .font(.caption) // Smaller font for metrics
//            .foregroundColor(.secondary)
//            .lineLimit(1)
//        }
//    }
//    
//    // Helper for consistent metric display
//    @ViewBuilder func metricItem(value: Double, unit: String, precision: Int, showPositiveOnly: Bool = false) -> some View {
//        let number = (showPositiveOnly && value < 0) ? "-" : String(format: "%.\(precision)f", value)
//        Text("\(number) \(unit)")
//    }
//
//}
//
//// MARK: - Reusable Card Button Style
//
//struct CardButtonStyle: ButtonStyle {
//    var enabled: Bool = true
//    var isRecording: Bool = false // Optional for changing style while recording
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .frame(maxWidth: .infinity) // Make buttons expand horizontally
//            .padding(.vertical, 10) // Consistent vertical padding
//            .padding(.horizontal, 5)
//            .background(backgroundMaterial(enabled: enabled, isRecording: isRecording, isPressed: configuration.isPressed))
//            .foregroundColor(foregroundColor(enabled: enabled, isRecording: isRecording))
//            .cornerRadius(10)
//            .scaleEffect(configuration.isPressed && enabled ? 0.97 : 1.0) // Only scale when enabled
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(strokeColor(enabled: enabled, isRecording: isRecording), lineWidth: 1.5) // Slightly thicker border
//             )
//             .opacity(enabled ? 1.0 : 0.5) // Dim when disabled
//    }
//    
//    // Helper functions for style properties
//    private func backgroundMaterial(enabled: Bool, isRecording: Bool, isPressed: Bool) -> Material {
//        if !enabled {
//            return .ultraThinMaterial // More subtle disabled background
//        } else if isRecording {
//            return isPressed ? .ultraThickMaterial : .regularMaterial // Slightly different pressed effect for recording
//        } else {
//            return isPressed ? .thickMaterial : .regularMaterial
//        }
//    }
//    
//    private func foregroundColor(enabled: Bool, isRecording: Bool) -> Color {
//        if !enabled {
//            return .secondary
//        } else if isRecording {
//            return .red
//        } else {
//            return .accentColor // Use standard accent color
//        }
//    }
//    
//    private func strokeColor(enabled: Bool, isRecording: Bool) -> Color {
//        if !enabled {
//            return .gray.opacity(0.5)
//        } else if isRecording {
//            return .red.opacity(0.8)
//        } else {
//            return .accentColor.opacity(0.8)
//        }
//    }
//}
//
//// MARK: - Advanced Settings View (Sheet Content)
//
//struct SettingsView: View {
//    @EnvironmentObject var viewModel: ContentViewModel // May not be needed directly if only settings are modified
//    @EnvironmentObject var settings: AppSettings
//    @Environment(\.dismiss) var dismiss // To close the sheet
//
//    var body: some View {
//        // Use NavigationView for consistent title/toolbar on iOS
//        NavigationView {
//            Form { // Form provides standard settings layout
//                Section("General") {
//                    infoToggle(label: "Show Timestamps", isOn: $settings.enableTimestamps, info: "Include [START --> END] timestamps in the output.")
//                    infoToggle(label: "Special Characters", isOn: $settings.enableSpecialCharacters, info: "Allow the model to output special characters like punctuation.")
//                    infoToggle(label: "Show Decoder Preview", isOn: $settings.enableDecoderPreview, info: "Display the raw, potentially unstable output from the decoder below the main transcription.")
//                }
//
//                Section("Prefill Options") {
//                    infoToggle(label: "Prompt Prefill", isOn: $settings.enablePromptPrefill, info: "Force task, language, and timestamp tokens initially. Turn off to let the model predict them (experimental).")
//                    infoToggle(label: "Cache Prefill", isOn: $settings.enableCachePrefill, info: "Use pre-computed KV caches for initial tokens to potentially speed up the first token generation.")
//                }
//
//                Section("Strategy & Performance") {
//                    Picker("Chunking Strategy", selection: $settings.chunkingStrategy) {
//                        Text("None").tag(ChunkingStrategy.none)
//                        Text("VAD").tag(ChunkingStrategy.vad)
//                    }
//                    .withInfo("How to segment audio for processing. VAD splits on silence (requires 'Use VAD' enabled).")
//
//                    Stepper("Concurrent Workers: \(Int(settings.concurrentWorkerCount))", value: $settings.concurrentWorkerCount, in: 0...32, step: 1)
//                        .withInfo("Number of parallel transcription jobs. Increases memory but can improve speed. 0 = automatic.")
//                }
//
//                Section("Decoding Parameters") {
//                    hSlider(label: "Temperature", value: $settings.temperatureStart, range: 0...1, step: 0.1, precision: 1, info: "Controls randomness (~0=deterministic, ~1=random). Higher values may explore more options but risk incoherence.")
//                    hSlider(label: "Fallback Count", value: $settings.fallbackCount, range: 0...5, step: 1, precision: 0, info: "Max times to retry decoding with higher temperature if results are poor (e.g., repetition, low probability). Increases processing time.")
//                    hSlider(label: "Comp Check Tokens", value: $settings.compressionCheckWindow, range: 10...100, step: 5, precision: 0, info: "Number of recent tokens checked for repetition using compression ratio.")
//                    hSlider(label: "Max Tokens/Loop", value: $settings.sampleLength, range: 50...448, step: 16, precision: 0, info: "Maximum tokens generated in one decoding step. Lower values may help prevent long repetitions.") // Adjust range based on actual maxSequenceLength if possible
//                }
//
//                Section("Streaming & VAD") {
//                     infoToggle(label: "Use VAD", isOn: $settings.useVAD, info: "Enable Voice Activity Detection. If enabled and Chunking Strategy is VAD, transcription pauses during silence.")
//                     hSlider(label: "Silence Threshold", value: $settings.silenceThreshold, range: 0.05...0.95, step: 0.05, precision: 2, info: "Sensitivity for VAD (relative energy). Lower values detect quieter sounds as speech.")
//                         .disabled(!settings.useVAD)
//                     hSlider(label: "Realtime Delay (s)", value: $settings.realtimeDelayInterval, range: 0.5...5, step: 0.5, precision: 1, info: "Minimum seconds of new audio needed before processing the next chunk in streaming mode. Higher delay saves battery but increases latency.")
//                 }
//
//                Section("Experimental") {
//                    infoToggle(label: "Eager Streaming", isOn: $settings.enableEagerDecoding, info: "Update transcription more frequently using word-level confirmations. Output may be less stable initially.")
//                    if settings.enableEagerDecoding {
//                         hSlider(label: "Token Confirmations", value: $settings.tokenConfirmationsNeeded, range: 1...10, step: 1, precision: 0, info: "Number of consecutive identical words required between decoding loops to confirm text in Eager mode.")
//                    }
//                }
//            }
//            .navigationTitle("Advanced Settings")
//            #if os(iOS)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") { dismiss() }
//                }
//            }
//            #else // macOS needs explicit close button if in sheet
//             .toolbar {
//                 ToolbarItem(placement: .confirmationAction) { // Use standard placement
//                     Button("Done") { dismiss() }
//                 }
//               }
//             .frame(minWidth: 450, minHeight: 500) // Set appropriate size for macOS sheet
//            #endif
//        }
//        // On macOS, NavigationView in a sheet might behave differently than expected.
//        // If issues arise, remove NavigationView and place toolbar content directly on the Form.
//    }
//
//     // --- Helper Views for Settings ---
//
//    @ViewBuilder
//    private func infoToggle(label: String, isOn: Binding<Bool>, info: String) -> some View {
//        HStack {
//            Toggle(label, isOn: isOn)
//            InfoButton(info)
//        }
//    }
//
//    @ViewBuilder
//     private func hSlider(label: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, precision: Int, info: String) -> some View {
//        VStack(alignment: .leading) {
//             HStack {
//                 Text(label)
//                 Spacer()
//                 Text(String(format: "%.\(precision)f", value.wrappedValue))
//                     .font(.body.monospacedDigit()) // Ensures stable width
//                     .foregroundColor(.secondary)
//                 InfoButton(info)
//             }
//             Slider(value: value, in: range, step: step) {
//                 Text(label) // Accessibility label
//             }
//         }
//     }
//     
//    // View modifier for Picker with InfoButton
//    struct InfoPickerModifier: ViewModifier {
//        let infoText: String
//        func body(content: Content) -> some View {
//            HStack {
//                content // The Picker itself
//                InfoButton(infoText)
//            }
//        }
//    }
//}
//
//// Extension to add the modifier easily
//extension View {
//    func withInfo(_ text: String) -> some View {
//        modifier(SettingsView.InfoPickerModifier(infoText: text))
//    }
//}
//
//// Simple Info Button Popover (from original code)
//struct InfoButton: View {
//    var infoText: String
//    @State private var showInfo = false
//
//    init(_ infoText: String) {
//        self.infoText = infoText
//    }
//
//    var body: some View {
//        Button {
//            showInfo = true
//        } label: {
//            Image(systemName: "info.circle")
//                .foregroundColor(.accentColor) // Use accent color
//        }
//        .buttonStyle(.borderless) // Ensure it doesn't look like a standard button
//        .popover(isPresented: $showInfo, arrowEdge: .bottom) { // Popover for info text
//            Text(infoText)
//                .font(.caption) // Smaller font for popover
//                .padding()
//                 #if os(macOS)
//                 .frame(maxWidth: 250) // Limit width on macOS
//                 #endif
//        }
//    }
//}
//
//// MARK: - Helper Extensions
//
//extension String {
//    // Simple helper to make model names more readable in the picker
//    var friendlyName: String {
//        guard let lastPart = self.split(separator: "/").last else { // Handle potential repo/name format
//            return self.replacingOccurrences(of: "_", with: " ").capitalized
//        }
//        // Further clean up common patterns like replacing '-'
//        return String(lastPart).replacingOccurrences(of: "-", with: " ").capitalized
//    }
//}
//
//extension ModelState {
//    var color: Color {
//        switch self {
//        case .loaded: .green
//        case .loading, .prewarming: .orange // Use Orange for clearer processing state
//        case .downloading: .blue // Blue often indicates networking/download
//        case .unloaded: .red
//        default: .gray // Handle potential future cases
//        }
//    }
//
//    // Indicates an active background process related to the model
//    var isProcessing: Bool {
//        switch self {
//         case .loading, .prewarming, .downloading: true
//         default: false
//        }
//    }
//}
//
//// Assume AudioDevice is Identifiable and Hashable if used in ForEach/Picker
//// Example: extension AudioDevice: Identifiable { public var id: String { name } }
//// Example: extension AudioDevice: Hashable { ... }
//
//// Make TranscriptionSegment Identifiable for ForEach loops
//extension TranscriptionSegment: @retroactive Identifiable {
//    // Using start time and text hash is usually unique enough for UI purposes
//    // Alternatively, if WhisperKit provides a unique ID, use that.
//     public var id: String { "\(start)-\(text.hashValue)" }
//}
//
//// MARK: - Previews
//#Preview {
//    ContentView()
//    #if os(macOS)
//        .frame(width: 900, height: 600) // Adjust frame size for preview
//    #endif
//    // Inject mock ViewModel/Settings for preview if needed
//    // .environmentObject(ContentViewModel(transcriptionService: MockTranscriptionService()))
//    // .environmentObject(AppSettings())
//}
