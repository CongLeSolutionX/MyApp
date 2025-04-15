////
////  SpecialDesginMoreModelsView.swift
////  MyApp
////
////  Created by Cong Le on 3/27/25.
////
//
//import SwiftUI
//import SafariServices // Needed for SFSafariViewController
//
//// MARK: - Data Structures (Model Definitions)
//
//// Represents a single capability and its support status
//struct Capability: Identifiable {
//    let id = UUID() // Conformance to Identifiable for ForEach
//    let name: String
//    let supported: Bool
//}
//
//// Represents audio/visual specifications (relevant for models like Flash)
//struct AudioVisualSpec {
//    let maxImagesPerPrompt: Int?
//    let maxVideoLength: String?
//    let maxAudioLength: String?
//}
//
//// Main data structure holding all information about a Gemini model
//struct GeminiModelInfo: Identifiable {
//    let id = UUID()
//    let title: String
//    let description: String
//    let tryLink: URL? // URL for the "Try in AI Studio" button
//    let modelCode: String
//    let inputDataTypes: String
//    let outputDataTypes: String
//    let inputTokenLimit: Int
//    let outputTokenLimit: Int
//    let audioVisualSpecs: AudioVisualSpec? // Optional, as not all models have these specifics listed
//    let capabilities: [Capability]
//    let versions: [String] // Using a simple string array for display
//    let versionPatternLink: URL? // Optional link for more version details
//    let latestUpdate: String
//    let knowledgeCutoff: String? // Optional, as not all models list this
//}
//
//// MARK: - Sample Data (Static Constants)
//
//// Using static constants for sample data improves efficiency and organization
//struct SampleData {
//    static let gemini25ProExperimental = GeminiModelInfo(
//        title: "Gemini 2.5 Pro Experimental",
//        description: "Gemini 2.5 Pro Experimental is our state-of-the-art thinking model, capable of reasoning over complex problems in code, math, and STEM, as well as analyzing large datasets, codebases, and documents using long context.",
//        tryLink: URL(string: "https://aistudio.google.com/"),
//        modelCode: "gemini-2.5-pro-exp-03-25",
//        inputDataTypes: "Audio, images, video, and text",
//        outputDataTypes: "Text",
//        inputTokenLimit: 1_048_576,
//        outputTokenLimit: 65_536,
//        audioVisualSpecs: nil, // No specific audio/visual specs listed in the Pro screenshot
//        capabilities: [
//            Capability(name: "Structured outputs", supported: true),
//            Capability(name: "Caching", supported: false),
//            Capability(name: "Tuning", supported: false),
//            Capability(name: "Function calling", supported: true),
//            Capability(name: "Code execution", supported: true),
//            Capability(name: "Search grounding", supported: true),
//            Capability(name: "Image generation", supported: false),
//            Capability(name: "Native tool use", supported: true),
//            Capability(name: "Audio generation", supported: false),
//            Capability(name: "Live API", supported: false),
//            Capability(name: "Thinking", supported: true)
//        ],
//        versions: ["Experimental: gemini-2.5-pro-exp-03-25"],
//        versionPatternLink: URL(string: "https://cloud.google.com/vertex-ai/docs/generative-ai/learn/model-versioning"), // Example link
//        latestUpdate: "March 2025",
//        knowledgeCutoff: "January 2025"
//    )
//
//    static let gemini15Flash = GeminiModelInfo(
//        title: "Gemini 1.5 Flash",
//        description: "Gemini 1.5 Flash is a fast and versatile multimodal model for scaling across diverse tasks.",
//        tryLink: URL(string: "https://aistudio.google.com/"),
//        modelCode: "models/gemini-1.5-flash",
//        inputDataTypes: "Audio, images, video, and text",
//        outputDataTypes: "Text",
//        inputTokenLimit: 1_048_576,
//        outputTokenLimit: 8_192,
//        audioVisualSpecs: AudioVisualSpec( // Specific specs for Flash
//            maxImagesPerPrompt: 3600,
//            maxVideoLength: "1 hour",
//            maxAudioLength: "Approximately 9.5 hours"
//        ),
//        capabilities: [
//            Capability(name: "System instructions", supported: true),
//            Capability(name: "JSON mode", supported: true),
//            Capability(name: "JSON schema", supported: true),
//            Capability(name: "Adjustable safety settings", supported: true),
//            Capability(name: "Caching", supported: true),
//            Capability(name: "Tuning", supported: true),
//            Capability(name: "Function calling", supported: true),
//            Capability(name: "Code execution", supported: true),
//            Capability(name: "Live API", supported: false)
//        ],
//        versions: [
//            "Latest: gemini-1.5-flash-latest",
//            "Latest stable: gemini-1.5-flash",
//            "Stable:",
//            "  • gemini-1.5-flash-001",
//            "  • gemini-1.5-flash-002"
//        ],
//        versionPatternLink: URL(string: "https://cloud.google.com/vertex-ai/docs/generative-ai/learn/model-versioning"), // Example link
//        latestUpdate: "September 2024",
//        knowledgeCutoff: nil // Not explicitly listed for Flash
//    )
//}
//
//// MARK: - Main Content View
//
//struct SpecialDesginMoreModelsView: View {
//    // Easily switch the data source
//    let modelInfo: GeminiModelInfo = SampleData.gemini25ProExperimental
////    let modelInfo: GeminiModelInfo = SampleData.gemini15Flash
//
//    // Optimization: Use a single NumberFormatter instance if needed frequently,
//    // but creating it within computed properties is fine for this use case.
//    private static var decimalFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        return formatter
//    }()
//
//    private var formattedInputTokenLimit: String {
//        Self.decimalFormatter.string(from: NSNumber(value: modelInfo.inputTokenLimit)) ?? "\(modelInfo.inputTokenLimit)"
//    }
//
//    private var formattedOutputTokenLimit: String {
//        Self.decimalFormatter.string(from: NSNumber(value: modelInfo.outputTokenLimit)) ?? "\(modelInfo.outputTokenLimit)"
//    }
//
//    var body: some View {
//        // ScrollView allows content to exceed screen height
//        ScrollView {
//            // Main vertical stack for content sections
//            VStack(alignment: .leading, spacing: 16) {
//                HeaderView(
//                    title: modelInfo.title,
//                    description: modelInfo.description,
//                    tryLink: modelInfo.tryLink
//                )
//                Divider() // Visual separator between sections
//                ModelDetailsSection(
//                    modelCode: modelInfo.modelCode,
//                    inputDataTypes: modelInfo.inputDataTypes,
//                    outputDataTypes: modelInfo.outputDataTypes,
//                    inputTokenLimitFormatted: formattedInputTokenLimit,
//                    outputTokenLimitFormatted: formattedOutputTokenLimit,
//                    audioVisualSpecs: modelInfo.audioVisualSpecs
//                )
//                Divider()
//                CapabilitiesSection(capabilities: modelInfo.capabilities)
//                Divider()
//                VersionsSection(
//                    versions: modelInfo.versions,
//                    patternLink: modelInfo.versionPatternLink
//                )
//                Divider()
//                MetadataSection(
//                    latestUpdate: modelInfo.latestUpdate,
//                    knowledgeCutoff: modelInfo.knowledgeCutoff
//                )
//            }
//            .padding() // Add padding around the entire ScrollView content
//        }
//        // Consider adding a .navigationTitle if embedding in NavigationView
//    }
//}
//
//// MARK: - Section Views (Breaking down the UI)
//
//struct HeaderView: View {
//    let title: String
//    let description: String
//    let tryLink: URL?
//
//    @State private var showSafari: Bool = false // State to control Safari sheet presentation
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.largeTitle.weight(.semibold)) // Combine font and weight
//
//            Text(description)
//                .font(.body)
//                .foregroundColor(.secondary) // Use secondary color for less emphasis
//
//            // Only show button if link exists
//            if let link = tryLink {
//                Button {
//                    showSafari = true // Trigger sheet presentation
//                } label: {
//                    // Use Label for icon and text
//                    Label("Try in Google AI Studio", systemImage: "sparkles")
//                }
//                .buttonStyle(.borderedProminent) // Prominent style
//                .tint(.blue) // Specific tint
//                .padding(.top, 8)
//                // Optimization: Use .sheet for modal presentation
//                .sheet(isPresented: $showSafari) {
//                    // Reuse SafariView Helper
//                    SafariView(url: link)
//                        .ignoresSafeArea() // Allow Safari view to use full screen
//                }
//            }
//        }
//    }
//}
//
//struct ModelDetailsSection: View {
//    let modelCode: String
//    let inputDataTypes: String
//    let outputDataTypes: String
//    let inputTokenLimitFormatted: String
//    let outputTokenLimitFormatted: String
//    let audioVisualSpecs: AudioVisualSpec?
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            SectionHeader(title: "Model details")
//
//            InfoRow(
//                icon: "barcode.viewfinder",
//                title: "Model code",
//                value: modelCode
//            )
//
//            InfoRow(
//                icon: "doc.plaintext",
//                title: "Supported data types",
//                values: [
//                    ("Inputs", inputDataTypes),
//                    ("Output", outputDataTypes)
//                ]
//            )
//
//            InfoRow(
//                icon: "arrow.down.forward.and.arrow.up.backward.circle",
//                title: "Token limits",
//                values: [
//                    ("Input token limit", inputTokenLimitFormatted),
//                    ("Output token limit", outputTokenLimitFormatted)
//                ]
//            )
//
//            // Conditionally display Audio/Visual Specs using if let
////            if let specs = audioVisualSpecs {
////                // Create specs array dynamically
////                var specValues: [(String, String)] = []
////                if let maxImages = specs.maxImagesPerPrompt {
////                    specValues.append(("Max images/prompt", "\(maxImages)"))
////                }
////                if let maxVideo = specs.maxVideoLength {
////                    specValues.append(("Max video length", maxVideo))
////                }
////                if let maxAudio = specs.maxAudioLength {
////                    specValues.append(("Max audio length", maxAudio))
////                }
////
////                if !specValues.isEmpty {
////                    InfoRow(
////                        icon: "film", // System icon for film/media
////                        title: "Audio/visual specs",
////                        values: specValues
////                    )
////                }
////            }
//        }
//    }
//}
//
//struct CapabilitiesSection: View {
//    let capabilities: [Capability]
//
//    // Optimization: Define columns once. `adaptive(minimum:)` is flexible.
//    // Adjust `minimum` based on desired item size. Using 3 fixed flexible
//    // columns like the screenshot.
//    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            SectionHeader(title: "Capabilities")
//
//            // Optimization: LazyVGrid renders items on demand, efficient for large lists.
//            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
//                ForEach(capabilities) { capability in
//                    CapabilityView(capability: capability)
//                }
//            }
//        }
//    }
//}
//
//struct VersionsSection: View {
//    let versions: [String]
//    let patternLink: URL?
//    @State private var showSafari: Bool = false // State for link presentation
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // Use the custom @ViewBuilder initializer for InfoRow
//            InfoRow(icon: "list.number", title: "Versions") {
//                VStack(alignment: .leading, spacing: 4) {
//                    // Instructions text
//                    Text("Read the model version patterns for more details.")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//
//                    // Use ForEach to display the list of version strings
//                    ForEach(versions, id: \.self) { versionLine in
//                        Text(versionLine)
//                            // Optimization: Use monospaced design specifically for code/versions
//                            .font(.system(.callout, design: .monospaced))
//                    }
//
//                    // Conditionally show the link button
//                    if let link = patternLink {
//                        Button("Learn about version patterns") {
//                            showSafari = true
//                        }
//                        .font(.footnote)
//                        .padding(.top, 4)
//                        .sheet(isPresented: $showSafari) {
//                            SafariView(url: link)
//                                .ignoresSafeArea()
//                        }
//                    }
//                }
//                // Ensure the content aligns correctly within the InfoRow HStack
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//        }
//    }
//}
//
//struct MetadataSection: View {
//    let latestUpdate: String
//    let knowledgeCutoff: String?
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            InfoRow(
//                icon: "calendar",
//                title: "Latest update",
//                value: latestUpdate
//            )
//
//            // Conditionally display Knowledge Cutoff using if let
//            if let cutoff = knowledgeCutoff {
//                InfoRow(
//                    icon: "brain.head.profile", // Relevant system icon
//                    title: "Knowledge cutoff",
//                    value: cutoff
//                )
//            }
//        }
//    }
//}
//
//// MARK: - Helper Views (Reusable UI Components)
//
//// Simple header view for sections
//struct SectionHeader: View {
//    let title: String
//
//    var body: some View {
//        Text(title)
//            .font(.title3.weight(.medium)) // More concise font declaration
//            .foregroundColor(.primary) // Standard text color
//    }
//}
//
//// --- InfoRow: Cleaner Approach with Extension Initializers ---
//
//// Base InfoRow structure - Holds the common layout
//struct InfoRow<Content: View>: View {
//    let icon: String
//    let title: String
//    let content: Content // The generic content view
//
//    // Common body applying horizontal layout
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) { // Added spacing
//            Image(systemName: icon)
//                .frame(width: 25, alignment: .center) // Consistent icon width
//                .foregroundColor(.accentColor) // Use accent color for icons
//                .padding(.top, 2) // Fine-tune vertical alignment
//
//            Text(title)
//                 // Adaptive width, ensures title is readable but doesn't push content too far
//                .frame(minWidth: 100, idealWidth: 120, maxWidth: 150 , alignment: .leading)
//                .font(.callout) // Slightly smaller font for titles
//                .foregroundColor(.secondary)
//
//            Spacer() // Pushes content to the trailing edge
//
//            content // Display the provided content view
//                .multilineTextAlignment(.trailing) // Align text content to the right
//        }
//    }
//}
//
//// Dedicated View for single string content
//struct SingleValueContent: View {
//    let value: String
//    var body: some View {
//        Text(value)
//            .font(.system(.callout, design: .monospaced)) // Monospaced for values like codes/dates
//            .foregroundColor(.primary) // Standard text color for values
//    }
//}
//
//// Dedicated View for key-value pair content
//struct KeyValueContent: View {
//    let values: [(String, String)]
//    var body: some View {
//        VStack(alignment: .trailing, spacing: 4) { // Align values to the right
//            ForEach(values, id: \.0) { key, value in
//                HStack {
//                    // Key text can be smaller/dimmed if desired
//                    // Text(key).font(.caption).foregroundColor(.gray)
//                    // Spacer()
//                    Text(value) // Main value text
//                         .font(.system(.callout, design: .monospaced))
//                         .foregroundColor(.primary)
//                }
//                 // Include Key Text if design requires distinction like Input/Output
//                // For simpler lists like Token Limits, showing just the value might suffice.
//                // Example with Key:
//                 /*
//                 HStack {
//                     Text(key)
//                         .font(.caption)
//                         .foregroundColor(.gray)
//                      Spacer()
//                     Text(value)
//                         .font(.system(.callout, design: .monospaced))
//                         .foregroundColor(.primary)
//                 }
//                 */
//            }
//        }
//    }
//}
//
//
//// Extension providing convenient initializers for InfoRow
//extension InfoRow {
//    // Initializer for simple String value
//    init(icon: String, title: String, value: String) where Content == SingleValueContent {
//        self.icon = icon
//        self.title = title
//        self.content = SingleValueContent(value: value)
//    }
//
//    // Initializer for key-value pairs
//    init(icon: String, title: String, values: [(String, String)]) where Content == KeyValueContent {
//        self.icon = icon
//        self.title = title
//        self.content = KeyValueContent(values: values)
//    }
//
//    // Initializer for fully custom content view using @ViewBuilder
//    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
//        self.icon = icon
//        self.title = title
//        self.content = content()
//    }
//}
//
//// Displays a single capability item in the grid
//struct CapabilityView: View {
//    let capability: Capability
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(capability.name)
//                .font(.subheadline)
//                .lineLimit(2) // Allow text to wrap up to 2 lines
//                // Ensures view height adjusts to wrapped text
//                .fixedSize(horizontal: false, vertical: true)
//
//            SupportStatusView(supported: capability.supported)
//        }
//        // Ensures each grid item fills available width and aligns content leadingly
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
//// Displays the "Supported" / "Not supported" tag
//struct SupportStatusView: View {
//    let supported: Bool
//
//    var body: some View {
//        Text(supported ? "Supported" : "Not supported")
//            .font(.caption.weight(.medium)) // Use combined font/weight
//            .padding(.horizontal, 6)
//            .padding(.vertical, 3)
//            // Use ternary operator for concise color setting
//            .background(supported ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
//            .foregroundColor(supported ? .green : .red)
//            .clipShape(RoundedRectangle(cornerRadius: 5)) // Use clipShape for rounded corners
//    }
//}
//
//// MARK: - Safari View Helper (UIViewControllerRepresentable)
//
//// Helper to present SFSafariViewController modally
//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//
//    func makeUIViewController(context: Context) -> SFSafariViewController {
//        // Create the Safari view controller
//        return SFSafariViewController(url: url)
//    }
//
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
//        // No updates needed when the view redraws
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group { // Group allows multiple previews
////            SpecialDesginMoreModelsView(modelInfo: SampleData.gemini25ProExperimental)
////                .previewDisplayName("Gemini 2.5 Pro Exp")
//
//            SpecialDesginMoreModelsView()
////
////            SpecialDesginMoreModelsView(modelInfo: SampleData.gemini15Flash)
////                .previewDisplayName("Gemini 1.5 Flash")
//        }
//    }
//}
