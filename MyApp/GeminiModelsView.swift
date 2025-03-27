//
//  Gemini_Models_View.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//

import SwiftUI
import SafariServices // For opening links

// MARK: - Data Structures

struct Gemini_Models_Capability: Identifiable {
    let id = UUID()
    let name: String
    let supported: Bool
}

struct Gemini_Models_AudioVisualSpec {
    let maxImagesPerPrompt: Int?
    let maxVideoLength: String?
    let maxAudioLength: String?
}

struct Gemini_Models_GeminiModelInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let tryLink: URL? = URL(string: "https://aistudio.google.com/") // Example URL
    let modelCode: String
    let inputDataTypes: String
    let outputDataTypes: String
    let inputTokenLimit: Int
    let outputTokenLimit: Int
    let audioVisualSpecs: Gemini_Models_AudioVisualSpec? // Optional for models like Pro
    let capabilities: [Gemini_Models_Capability]
    let versions: [String] // Simple list for demonstration
    let versionPatternLink: URL? = nil // Placeholder for actual link if available
    let latestUpdate: String
    let knowledgeCutoff: String? // Optional for models like Flash
}

// MARK: - Sample Data

let gemini25ProExperimentalData = Gemini_Models_GeminiModelInfo(
    title: "Gemini 2.5 Pro Experimental",
    description: "Gemini 2.5 Pro Experimental is our state-of-the-art thinking model, capable of reasoning over complex problems in code, math, and STEM, as well as analyzing large datasets, codebases, and documents using long context.",
    modelCode: "gemini-2.5-pro-exp-03-25",
    inputDataTypes: "Audio, images, video, and text",
    outputDataTypes: "Text",
    inputTokenLimit: 1_048_576,
    outputTokenLimit: 65_536,
    audioVisualSpecs: nil, // Not present in the Pro screenshot
    capabilities: [
        Gemini_Models_Capability(name: "Structured outputs", supported: true),
        Gemini_Models_Capability(name: "Caching", supported: false),
        Gemini_Models_Capability(name: "Tuning", supported: false),
        Gemini_Models_Capability(name: "Function calling", supported: true),
        Gemini_Models_Capability(name: "Code execution", supported: true),
        Gemini_Models_Capability(name: "Search grounding", supported: true),
        Gemini_Models_Capability(name: "Image generation", supported: false),
        Gemini_Models_Capability(name: "Native tool use", supported: true),
        Gemini_Models_Capability(name: "Audio generation", supported: false),
        Gemini_Models_Capability(name: "Live API", supported: false),
        Gemini_Models_Capability(name: "Thinking", supported: true)
        // Add System Instructions, Safety Settings etc. if adapting for Flash
    ],
    versions: ["Experimental: gemini-2.5-pro-exp-03-25"],
    latestUpdate: "March 2025",
    knowledgeCutoff: "January 2025"
)

let gemini15FlashData = Gemini_Models_GeminiModelInfo(
    title: "Gemini 1.5 Flash",
    description: "Gemini 1.5 Flash is a fast and versatile multimodal model for scaling across diverse tasks.",
    modelCode: "models/gemini-1.5-flash",
    inputDataTypes: "Audio, images, video, and text",
    outputDataTypes: "Text",
    inputTokenLimit: 1_048_576,
    outputTokenLimit: 8_192,
    audioVisualSpecs: Gemini_Models_AudioVisualSpec(
        maxImagesPerPrompt: 3600,
        maxVideoLength: "1 hour",
        maxAudioLength: "Approximately 9.5 hours"
    ),
    capabilities: [
        Gemini_Models_Capability(name: "System instructions", supported: true),
        Gemini_Models_Capability(name: "JSON mode", supported: true),
        Gemini_Models_Capability(name: "JSON schema", supported: true),
        Gemini_Models_Capability(name: "Adjustable safety settings", supported: true),
        Gemini_Models_Capability(name: "Caching", supported: true),
        Gemini_Models_Capability(name: "Tuning", supported: true),
        Gemini_Models_Capability(name: "Function calling", supported: true),
        Gemini_Models_Capability(name: "Code execution", supported: true),
        Gemini_Models_Capability(name: "Live API", supported: false)
        // Add Structured Outputs, Search Grounding etc. if needed
    ],
    versions: [
        "Latest: gemini-1.5-flash-latest",
        "Latest stable: gemini-1.5-flash",
        "Stable:",
        "  • gemini-1.5-flash-001",
        "  • gemini-1.5-flash-002"
    ],
    latestUpdate: "September 2024",
    knowledgeCutoff: nil // Not explicitly mentioned in the screenshot
)

// MARK: - Main Content View

struct Gemini_Models_View: View {
    // Select which model data to display
    // You could use a @State variable and Picker to switch between models
    let modelInfo: Gemini_Models_GeminiModelInfo = gemini25ProExperimentalData
    // let modelInfo: GeminiModelInfo = gemini15FlashData // Alternatively display Flash
    
    var body: some View {
        // Using ScrollView directly without NavigationView for closer layout match
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Gemini_Models_HeaderView(title: modelInfo.title, description: modelInfo.description, tryLink: modelInfo.tryLink)
                Divider()
                Gemini_Models_ModelDetailsSection(modelInfo: modelInfo)
                Divider()
                Gemini_Models_CapabilitiesSection(capabilities: modelInfo.capabilities)
                Divider()
                Gemini_Models_VersionsSection(versions: modelInfo.versions, patternLink: modelInfo.versionPatternLink)
                Divider()
                Gemini_Models_MetadataSection(latestUpdate: modelInfo.latestUpdate, knowledgeCutoff: modelInfo.knowledgeCutoff)
            }
            .padding() // Add padding around the entire content
        }
    }
}

// MARK: - Section Views

struct Gemini_Models_HeaderView: View {
    let title: String
    let description: String
    let tryLink: URL?
    @State private var showSafari: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
            
            if let link = tryLink {
                Button {
                    showSafari = true
                } label: {
                    Label("Try in Google AI Studio", systemImage: "sparkles")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue) // Match screenshot color
                .padding(.top, 8)
                .sheet(isPresented: $showSafari) {
                    // Present SFSafariViewController to open the link in-app
                    SafariView(url: link)
                }
            }
        }
    }
}

struct Gemini_Models_ModelDetailsSection: View {
    let modelInfo: Gemini_Models_GeminiModelInfo
    
    private var inputTokenFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: modelInfo.inputTokenLimit)) ?? "\(modelInfo.inputTokenLimit)"
    }
    
    private var outputTokenFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: modelInfo.outputTokenLimit)) ?? "\(modelInfo.outputTokenLimit)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Gemini_Models_SectionHeader(title: "Model details")
            
            Gemini_Models_InfoRow(
                icon: "barcode.viewfinder",
                title: "Model code",
                value: modelInfo.modelCode
            )
            
            Gemini_Models_InfoRow(
                icon: "doc.plaintext",
                title: "Supported data types",
                values: [
                    ("Inputs", modelInfo.inputDataTypes),
                    ("Output", modelInfo.outputDataTypes)
                ]
            )
            
            Gemini_Models_InfoRow(
                icon: "arrow.down.forward.and.arrow.up.backward.circle",
                title: "Token limits",
                values: [
                    ("Input token limit", inputTokenFormatted),
                    ("Output token limit", outputTokenFormatted)
                ]
            )
            
            // Conditionally display Audio/Visual Specs for models like Flash
            if let specs = modelInfo.audioVisualSpecs {
                Gemini_Models_InfoRow(
                    icon: "film", // Or appropriate icon
                    title: "Audio/visual specs",
                    values: [
                        ("Max images/prompt", specs.maxImagesPerPrompt.map { "\($0)" } ?? "N/A"),
                        ("Max video length", specs.maxVideoLength ?? "N/A"),
                        ("Max audio length", specs.maxAudioLength ?? "N/A")
                    ]
                )
            }
        }
    }
}

struct Gemini_Models_CapabilitiesSection: View {
    let capabilities: [Gemini_Models_Capability]
    // Define grid columns, adapting based on screen size if needed
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3) // 3 columns like screenshot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Gemini_Models_SectionHeader(title: "Capabilities")
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                ForEach(capabilities) { capability in
                    Gemini_Models_CapabilityView(capability: capability)
                }
            }
        }
    }
}

struct Gemini_Models_VersionsSection: View {
    let versions: [String]
    let patternLink: URL?
    @State private var showSafari: Bool = false // For link
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Gemini_Models_InfoRow(
                icon: "list.number",
                title: "Versions",
                content: {
                    VStack(alignment: .leading) {
                        Text("Read the model version patterns for more details.") // Consider making "model version patterns" a tappable link if URL provided
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)
                        
                        // Display version list
                        ForEach(versions, id: \.self) { versionLine in
                            Text(versionLine)
                                .font(.system(.body, design: .monospaced)) // Monospaced for version strings
                        }
                        
                        // Example of adding a link
                        if let link = patternLink {
                            Button("Learn about version patterns") {
                                showSafari = true
                            }
                            .font(.footnote)
                            .padding(.top, 2)
                            .sheet(isPresented: $showSafari) {
                                SafariView(url: link)
                            }
                        }
                    }
                }
            )
        }
    }
}

struct Gemini_Models_MetadataSection: View {
    let latestUpdate: String
    let knowledgeCutoff: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // SectionHeader(title: "Metadata") // Can omit header if desired
            
            Gemini_Models_InfoRow(
                icon: "calendar",
                title: "Latest update",
                value: latestUpdate
            )
            
            if let cutoff = knowledgeCutoff {
                Gemini_Models_InfoRow(
                    icon: "brain.head.profile",
                    title: "Knowledge cutoff",
                    value: cutoff
                )
            }
        }
    }
}

// MARK: - Helper Views

struct Gemini_Models_SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(.secondary) // Optional: slightly muted color
            .padding(.bottom, -4) // Adjust spacing if needed
    }
}
// MARK: - Helper Views
// The core generic struct
struct Gemini_Models_InfoRow<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    
    // Common body
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .frame(width: 25, alignment: .center)
                .foregroundColor(.blue)
                .padding(.top, 2)
            
            Text(title)
                .frame(minWidth: 120, alignment: .leading)
            
            Spacer()
            
            content // The generic content
        }
    }
}

// Separate simple content views
struct SingleValueContent: View {
    let value: String
    var body: some View { Text(value).font(.system(.body, design: .monospaced)) }
}

struct KeyValueContent: View {
    let values: [(String, String)]
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(values, id: \.0) { key, value in
                HStack {
                    Text(key).font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text(value).font(.system(.body, design: .monospaced)).multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

// Extension providing the specific, distinct initializers
extension Gemini_Models_InfoRow {
    // Init for single String value
    init(icon: String, title: String, value: String) where Content == SingleValueContent {
        self.init(icon: icon, title: title, content: SingleValueContent(value: value))
    }
    
    // Init for key-value pairs <<<--- THIS IS THE ONE YOU ARE USING
    init(icon: String, title: String, values: [(String, String)]) where Content == KeyValueContent {
        self.init(icon: icon, title: title, content: KeyValueContent(values: values))
    }
    
    // Init for fully custom content view using @ViewBuilder
    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.init(icon: icon, title: title, content: content()) // Pass the built content
    }
}

struct Gemini_Models_CapabilityView: View {
    let capability: Gemini_Models_Capability
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(capability.name)
                .font(.subheadline)
                .lineLimit(2) // Allow wrapping
                .fixedSize(horizontal: false, vertical: true) // Allow height to adjust
            
            Gemini_Models_SupportStatusView(supported: capability.supported)
        }
        // Add a border or background for visual separation if needed
        // .padding(8)
        // .background(Color.gray.opacity(0.1))
        // .cornerRadius(5)
    }
}

struct Gemini_Models_SupportStatusView: View {
    let supported: Bool
    
    var body: some View {
        Text(supported ? "Supported" : "Not supported")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(supported ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
            .foregroundColor(supported ? .green : .red)
            .cornerRadius(5)
    }
}

// MARK: - Safari View Helper

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Preview
// TODO - Add Dependencu Injection for each preview - TBD
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Gemini_Models_View() // Preview Pro
            .previewDisplayName("Gemini 2.5 Pro Exp")
        
        Gemini_Models_View() // Preview Flash
            .previewDisplayName("Gemini 1.5 Flash")
    }
}
