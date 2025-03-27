//
//  GeminiModelCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//

import SwiftUI

// --- Reusable Helper Views (Mostly Unchanged) ---

struct StatusView: View {
    let isSupported: Bool
    // Unchanged from previous version
    var body: some View {
        Text(isSupported ? "Supported" : "Not supported")
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(isSupported ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
            .background(isSupported ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            .cornerRadius(6)
    }
}

struct PropertyRow: View {
    let icon: String
    let label: String
    let value: String
    // Unchanged from previous version
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20, alignment: .center)
            Text(label)
                .font(.headline)
                .frame(minWidth: 150, alignment: .leading)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct PropertyRowMultiLine: View {
    let icon: String
    let label: String
    let lines: [(String, String)]
    // Unchanged from previous version
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20, alignment: .center)
            Text(label)
                .font(.headline)
                .frame(minWidth: 150, alignment: .leading)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                ForEach(lines, id: \.0) { line in
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(line.0).font(.caption).bold()
                        Text(line.1)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct PropertyRowComplexValue<Content: View>: View {
    let icon: String
    let label: String
    @ViewBuilder let valueContent: Content
    // Unchanged from previous version
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20, alignment: .center)
            Text(label)
                .font(.headline)
                .frame(minWidth: 150, alignment: .leading)
            Spacer()
            valueContent
        }
    }
}

struct CapabilityItemView: View {
    let capability:         Gemini_2_5_Pro_Experimental_Model_CardView.Capability
    // Unchanged from previous version
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(capability.name).font(.subheadline)
            StatusView(isSupported: capability.isSupported)
        }
    }
}


// --- Main Card-Based View ---

struct         Gemini_2_5_Pro_Experimental_Model_CardView: View {
    
    // --- Data Properties (Same as before) ---
    struct Capability {
        let name: String
        let isSupported: Bool
    }
    
    let modelDescription = "Gemini 2.5 Pro Experimental is our state-of-the-art thinking model, capable of reasoning over complex problems in code, math, and STEM, as well as analyzing large datasets, codebases, and documents using long context."
    let modelCode = "gemini-2.5-pro-exp-03-25"
    let supportedInputs = "Audio, images, video, and text"
    let supportedOutputs = "Text"
    let inputTokenLimit = "1,048,576"
    let outputTokenLimit = "65,536"
    let latestUpdate = "March 2025"
    let knowledgeCutoff = "January 2025"
    
    let capabilities: [Capability] = [
        Capability(name: "Structured outputs", isSupported: true),
        Capability(name: "Caching", isSupported: false),
        Capability(name: "Tuning", isSupported: false),
        Capability(name: "Function calling", isSupported: true),
        Capability(name: "Code execution", isSupported: true),
        Capability(name: "Search grounding", isSupported: true),
        Capability(name: "Image generation", isSupported: false),
        Capability(name: "Native tool use", isSupported: true),
        Capability(name: "Audio generation", isSupported: false),
        Capability(name: "Live API", isSupported: false),
        Capability(name: "Thinking", isSupported: true)
    ]
    
    let columns: [GridItem] = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]
    
    // --- Body with Card Layout ---
    var body: some View {
        ScrollView {
            VStack(spacing: 20) { // Spacing BETWEEN cards
                
                // --- Card 1: Header ---
                VStack(alignment: .leading, spacing: 12) {
                    Text("Gemini 2.5 Pro Experimental")
                        .font(.title) // Slightly smaller title for card context
                        .fontWeight(.semibold)
                    
                    Text(modelDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button {
                        print("Try in Google AI Studio tapped")
                    } label: {
                        Label("Try in Google AI Studio", systemImage: "sparkles")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 4)
                }
                .padding() // Internal padding for the card
                .background(Color(.secondarySystemGroupedBackground)) // Card background
                .cornerRadius(12)
                
                // --- Card 2: Basic Properties ---
                VStack(alignment: .leading, spacing: 12) {
                    PropertyRow(icon: "display", label: "Model code", value: modelCode)
                    Divider()
                    PropertyRowMultiLine(
                        icon: "square.stack.3d.up",
                        label: "Supported data types",
                        lines: [("Inputs", supportedInputs), ("Output", supportedOutputs)]
                    )
                    Divider()
                    PropertyRowMultiLine(
                        icon: "arrow.clockwise.circle",
                        label: "Token limits [*]",
                        lines: [("Input token limit", inputTokenLimit), ("Output token limit", outputTokenLimit)]
                    )
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                // --- Card 3: Capabilities ---
                VStack(alignment: .leading, spacing: 12) {
                    // Capabilities Title inside the card
                    HStack(spacing: 8) {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundColor(.accentColor)
                            .frame(width: 20, alignment: .center)
                        Text("Capabilities")
                            .font(.title3.weight(.semibold)) // Adjusted title size
                    }
                    
                    // Grid for capabilities
                    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 12) {
                        ForEach(0..<capabilities.count / 3 + (capabilities.count % 3 > 0 ? 1 : 0), id: \.self) { rowIndex in
                            GridRow {
                                ForEach(0..<3) { colIndex in
                                    let index = rowIndex * 3 + colIndex
                                    if index < capabilities.count {
                                        CapabilityItemView(capability: capabilities[index])
                                    } else {
                                        Color.clear // Placeholder
                                    }
                                }
                            }
                        }
                    }
                    // Removed extra leading padding for grid, handled by card padding
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                // --- Card 4: Metadata ---
                VStack(alignment: .leading, spacing: 12) {
                    PropertyRowComplexValue(
                        icon: "list.number",
                        label: "Versions"
                    ) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Read the model version patterns for more details.")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("• Experimental: \(modelCode)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Divider()
                    PropertyRow(icon: "calendar", label: "Latest update", value: latestUpdate)
                    Divider()
                    PropertyRow(icon: "brain.head.profile", label: "Knowledge cutoff", value: knowledgeCutoff)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
            } // End Main VStack between cards
            .padding() // Padding around the entire scrollable content
        }
        .background(Color(.systemGroupedBackground)) // Background for the whole view
        .navigationTitle("Model Details") // Add a navigation title if appropriate
        .navigationBarTitleDisplayMode(.inline) // Or .large
    }
}

// --- Preview ---
#Preview {
    NavigationView { // Wrap in NavigationView for title display
        Gemini_2_5_Pro_Experimental_Model_CardView()
    }
}
