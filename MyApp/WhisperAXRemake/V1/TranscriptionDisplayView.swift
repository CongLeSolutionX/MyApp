////
////  TranscriptionDisplayView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//// TranscriptionDisplayView.swift
//import SwiftUI
//import WhisperKit
//
//struct TranscriptionDisplayView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings // Needed for timestamp/preview toggle
//
//    var body: some View {
//        GroupBox("Transcription Output") { // Card style
//            VStack(alignment: .leading) {
//                // Audio Level Meter (Optional Card)
//                if !viewModel.audioSignal.bufferEnergy.isEmpty {
//                    SignalEnergyView(energy: viewModel.audioSignal.bufferEnergy, threshold: Float(settings.silenceThreshold))
//                        .frame(height: 30)
//                        .padding(.bottom, 5)
//                }
//
//                // Main Transcription Text Area
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 8) {
//                        if settings.enableEagerDecoding && viewModel.selectedTab == .stream {
//                             eagerTextView
//                         } else {
//                             standardTextView
//                         }
//
//                        // Optional Decoder Preview
//                        if settings.enableDecoderPreview && !viewModel.decoderPreviewText.isEmpty {
//                             Divider()
//                             Text("Decoder Preview:")
//                                 .font(.caption)
//                                 .foregroundColor(.secondary)
//                             Text(viewModel.decoderPreviewText)
//                                 .font(.caption)
//                                 .foregroundColor(.orange) // Differentiate preview
//                                 .frame(maxWidth: .infinity, alignment: .leading)
//                         }
//                    }
//                     .textSelection(.enabled)
//                     .frame(maxWidth: .infinity, alignment: .leading) // Ensure text aligns left
//                     .padding(5) // Inner padding for scroll content
//                }
//                .defaultScrollAnchor(.bottom) // Auto-scroll
//
//                // Progress bar for non-streaming transcription
//                if viewModel.isTranscribing && viewModel.selectedTab == .transcribe && !viewModel.isRecording {
//                     ProgressView(value: calculateFileProgress()) // Implement progress logic
//                         .progressViewStyle(.linear)
//                         .padding(.top, 5)
//                 }
//            }
//            .frame(maxHeight: .infinity) // Allow vertical expansion
//        }
//        .padding(.bottom, 5) // Space below card
//    }
//
//    // --- Subviews for Text Display ---
//
//    private var standardTextView: some View {
//        Group {
//            // Confirmed Segments (e.g., darker text)
//            ForEach(viewModel.confirmedSegments, id: \.self) { segment in // Segment needs to be Hashable
//                segmentText(segment: segment, confirmed: true, showTimestamps: settings.enableTimestamps)
//            }
//            // Unconfirmed Segments (e.g., lighter/gray text)
//            ForEach(viewModel.unconfirmedSegments, id: \.self) { segment in
//                segmentText(segment: segment, confirmed: false, showTimestamps: settings.enableTimestamps)
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func segmentText(segment: TranscriptionSegment, confirmed: Bool, showTimestamps: Bool) -> some View {
//        let timestampPrefix = showTimestamps ? "[\(String(format: "%.2f", segment.start)) → \(String(format: "%.2f", segment.end))] " : ""
//        Text(timestampPrefix + segment.text)
//            .fontWeight(confirmed ? .medium : .regular)
//            .foregroundColor(confirmed ? .primary : .secondary)
//            .multilineTextAlignment(.leading)
//    }
//
//    private var eagerTextView: some View {
//         // Use Text concatenation for different styles
//         Text(viewModel.confirmedEagerText)
//            .fontWeight(.medium)
//            .foregroundColor(.primary)
//            + Text(viewModel.hypothesisEagerText) // Append hypothesis directly
//            .fontWeight(.regular)
//            .foregroundColor(.secondary) // Style hypothesis differently
//            
////        Alternative if complex interactions are needed:
////        HStack(spacing: 0) {
////            Text(viewModel.confirmedEagerText).fontWeight(.medium)
////            Text(viewModel.hypothesisEagerText).foregroundColor(.secondary)
////        } // But Text concatenation is often better for flow
//    }
//
//    // Placeholder for file progress calculation - depends on how service reports it
//    private func calculateFileProgress() -> Double {
//        // Needs logic based on WhisperKit progress or estimated progress
//        return viewModel.isTranscribing ? 0.5 : 0.0 // Dummy value
//    }
//}
//
//// View for visualizing audio energy
//struct SignalEnergyView: View {
//    let energy: [Float]
//    let threshold: Float
//    private let maxEnergyPoints = 300 // Limit displayed points
//
//    var body: some View {
//        GeometryReader { geometry in
//             let displayEnergy = energy.suffix(maxEnergyPoints)
//             let widthPerBar = geometry.size.width / CGFloat(maxEnergyPoints) // Fixed number of potential bars
//             let maxBarHeight = geometry.size.height
//             let startIndex = energy.count > maxEnergyPoints ? energy.count - maxEnergyPoints : 0
//
//             HStack(spacing: 0) {
//                 ForEach(Array(displayEnergy.enumerated()), id: \.offset) { _, level in
//                     let isAboveThreshold = level > threshold
//                     Rectangle()
//                         .fill(isAboveThreshold ? Color.green.opacity(0.6) : Color.red.opacity(0.5))
//                         .frame(width: widthPerBar, height: min(max(CGFloat(level) * maxBarHeight * 1.5, 1), maxBarHeight)) // Scale height, ensure min 1px
//                 }
//                 // Add spacer if fewer than maxEnergyPoints points to fill width
//                 if displayEnergy.count < maxEnergyPoints {
//                    Spacer(minLength: 0)
//                 }
//             }
//             .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
//             .clipped() // Clip overflowing bars
//             .drawingGroup() // Optimize rendering
//        }
//    }
//}
