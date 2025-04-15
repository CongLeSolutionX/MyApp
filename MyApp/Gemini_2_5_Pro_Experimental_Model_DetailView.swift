////
////  GeminiModelDetailView.swift
////  MyApp
////
////  Created by Cong Le on 3/27/25.
////
//
//import SwiftUI
//
//// Reusable view for displaying "Supported" / "Not supported" status
//struct Gemini_2_5_Pro_Experimental_Model_StatusView: View {
//    let isSupported: Bool
//
//    var body: some View {
//        Text(isSupported ? "Supported" : "Not supported")
//            .font(.caption.weight(.medium))
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .foregroundColor(isSupported ? .green.opacity(0.9) : .red.opacity(0.9))
//            .background(isSupported ? .green.opacity(0.15) : .red.opacity(0.15))
//            .cornerRadius(6)
//    }
//}
//
//// Main view structure
//struct Gemini_2_5_Pro_Experimental_Model_DetailView: View {
//
//    // Simple struct to hold capability info
//    struct Capability {
//        let name: String
//        let isSupported: Bool
//    }
//
//    // Data mirroring the image content
//    let modelDescription = "Gemini 2.5 Pro Experimental is our state-of-the-art thinking model, capable of reasoning over complex problems in code, math, and STEM, as well as analyzing large datasets, codebases, and documents using long context."
//    let modelCode = "gemini-2.5-pro-exp-03-25"
//    let supportedInputs = "Audio, images, video, and text"
//    let supportedOutputs = "Text"
//    let inputTokenLimit = "1,048,576"
//    let outputTokenLimit = "65,536"
//    let latestUpdate = "March 2025"
//    let knowledgeCutoff = "January 2025"
//
//    // Group capabilities for grid layout
//    let capabilities: [Capability] = [
//        Capability(name: "Structured outputs", isSupported: true),
//        Capability(name: "Caching", isSupported: false),
//        Capability(name: "Tuning", isSupported: false),
//        Capability(name: "Function calling", isSupported: true),
//        Capability(name: "Code execution", isSupported: true),
//        Capability(name: "Search grounding", isSupported: true),
//        Capability(name: "Image generation", isSupported: false),
//        Capability(name: "Native tool use", isSupported: true),
//        Capability(name: "Audio generation", isSupported: false),
//        Capability(name: "Live API", isSupported: false),
//        Capability(name: "Thinking", isSupported: true)
//        // Add placeholder for potential third column if needed for alignment
//         //Capability(name: "", isSupported: false) // Invisible placeholder if needed
//    ]
//
//    // Define grid columns
//    let columns: [GridItem] = [
//        GridItem(.flexible(), alignment: .leading),
//        GridItem(.flexible(), alignment: .leading),
//        GridItem(.flexible(), alignment: .leading)
//    ]
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                // --- Header ---
//                Text("Gemini 2.5 Pro Experimental")
//                    .font(.largeTitle)
//                    .fontWeight(.semibold)
//
//                Text(modelDescription)
//                    .font(.body)
//                    .foregroundColor(.secondary)
//
//                Button {
//                    // Action to open Google AI Studio (placeholder)
//                    print("Try in Google AI Studio tapped")
//                } label: {
//                    Label("Try in Google AI Studio", systemImage: "sparkles")
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.top, 8)
//
//                Divider().padding(.vertical, 8)
//
//                // --- Model Details ---
//                Text("Model details")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .padding(.bottom, 8)
//
//                // --- Property List ---
//                VStack(alignment: .leading, spacing: 12) {
//                    Gemini_2_5_Pro_Experimental_Model_PropertyRow(icon: "display", label: "Model code", value: modelCode)
//
//                    Divider()
//
//                    Gemini_2_5_Pro_Experimental_Model_PropertyRowMultiLine(
//                         icon: "square.stack.3d.up",
//                         label: "Supported data types",
//                         lines: [("Inputs", supportedInputs), ("Output", supportedOutputs)]
//                     )
//
//                    Divider()
//
//                    Gemini_2_5_Pro_Experimental_Model_PropertyRowMultiLine(
//                         icon: "arrow.clockwise.circle",
//                         label: "Token limits [*]", // Matches the image note
//                         lines: [("Input token limit", inputTokenLimit), ("Output token limit", outputTokenLimit)]
//                     )
//
//                    Divider()
//
//                    // --- Capabilities Section ---
//                    HStack(spacing: 8) {
//                           Image(systemName: "wrench.and.screwdriver")
//                               .foregroundColor(.accentColor)
//                               .frame(width: 20, alignment: .center)
//                           Text("Capabilities")
//                               .font(.headline)
//                       }
//                       .padding(.bottom, 4)
//
//                     // Using Grid for better alignment of capabilities
//                     Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
//                           ForEach(0..<capabilities.count / 3 + (capabilities.count % 3 > 0 ? 1 : 0), id: \.self) { rowIndex in
//                               GridRow {
//                                   ForEach(0..<3) { colIndex in
//                                       let index = rowIndex * 3 + colIndex
//                                       if index < capabilities.count {
//                                           Gemini_2_5_Pro_Experimental_Model_CapabilityItemView(capability: capabilities[index])
//                                       } else {
//                                           // Placeholder for empty grid cells if needed for alignment
//                                           Color.clear
//                                       }
//                                   }
//                               }
//                           }
//                       }
//                       .padding(.leading, 28) // Indent capability grid under the title
//
//                    Divider()
//
//                    Gemini_2_5_Pro_Experimental_Model_PropertyRowComplexValue(
//                         icon: "list.number",
//                         label: "Versions"
//                    ) {
//                         VStack(alignment: .trailing, spacing: 2) {
//                             // Assuming this is meant to be a link - Link view is better
//                             Text("Read the model version patterns for more details.")
//                                 .font(.caption)
//                                 .foregroundColor(.blue) // Style as link
//                             Text("• Experimental: \(modelCode)")
//                                 .font(.caption)
//                                 .foregroundColor(.secondary)
//                         }
//                     }
//
//                    Divider()
//
//                    Gemini_2_5_Pro_Experimental_Model_PropertyRow(icon: "calendar", label: "Latest update", value: latestUpdate)
//
//                    Divider()
//
//                    Gemini_2_5_Pro_Experimental_Model_PropertyRow(icon: "brain.head.profile", label: "Knowledge cutoff", value: knowledgeCutoff)
//
//                } // End Property List VStack
//            } // End Main VStack
//            .padding()
//        } // End ScrollView
//    }
//}
//
//// --- Reusable Row Components ---
//
//// Simple Key-Value Row
//struct Gemini_2_5_Pro_Experimental_Model_PropertyRow: View {
//    let icon: String
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack(alignment: .top) {
//            Image(systemName: icon)
//                .foregroundColor(.accentColor)
//                .frame(width: 20, alignment: .center) // Fixed width for alignment
//            Text(label)
//                .font(.headline)
//                .frame(minWidth: 150, alignment: .leading) // Align labels
//            Spacer()
//            Text(value)
//                .font(.body)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.trailing)
//        }
//    }
//}
//
//// Row for properties with multiple titled lines (like Input/Output)
//struct Gemini_2_5_Pro_Experimental_Model_PropertyRowMultiLine: View {
//    let icon: String
//    let label: String
//    let lines: [(String, String)] // Tuple of (Title, Value)
//
//    var body: some View {
//        HStack(alignment: .top) {
//            Image(systemName: icon)
//                .foregroundColor(.accentColor)
//                .frame(width: 20, alignment: .center)
//            Text(label)
//                .font(.headline)
//                 .frame(minWidth: 150, alignment: .leading)
//            Spacer()
//            VStack(alignment: .trailing, spacing: 4) {
//                ForEach(lines, id: \.0) { line in
//                    VStack(alignment: .trailing, spacing: 0) {
//                        Text(line.0).font(.caption).bold()
//                        Text(line.1)
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// Row where the value part is a custom view builder content
//struct Gemini_2_5_Pro_Experimental_Model_PropertyRowComplexValue<Content: View>: View {
//    let icon: String
//    let label: String
//    @ViewBuilder let valueContent: Content
//
//    var body: some View {
//         HStack(alignment: .top) {
//            Image(systemName: icon)
//                .foregroundColor(.accentColor)
//                .frame(width: 20, alignment: .center)
//            Text(label)
//                .font(.headline)
//                 .frame(minWidth: 150, alignment: .leading)
//            Spacer()
//            valueContent // Embed the custom content
//        }
//    }
//}
//
//// View for a single item within the Capabilities Grid
//struct Gemini_2_5_Pro_Experimental_Model_CapabilityItemView: View {
//    let capability: Gemini_2_5_Pro_Experimental_Model_DetailView.Capability
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(capability.name).font(.subheadline)
//            Gemini_2_5_Pro_Experimental_Model_StatusView(isSupported: capability.isSupported)
//        }
//        // Ensure minimum width if needed, or let the grid manage it
//         // .frame(minWidth: 100, alignment: .leading)
//    }
//}
//
//// --- Preview ---
//#Preview {
//    Gemini_2_5_Pro_Experimental_Model_DetailView()
//}
