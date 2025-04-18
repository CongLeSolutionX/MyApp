////
////  OpenAIResponseView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//
//// Helper to format the Unix timestamp
//func formatUnixDate(_ timestamp: TimeInterval) -> String {
//    let date = Date(timeIntervalSince1970: timestamp)
//    let formatter = DateFormatter()
//    formatter.dateStyle = .medium
//    formatter.timeStyle = .short
//    return formatter.string(from: date)
//}
//
//// Main SwiftUI View to display the API Response Data
//struct OpenAIResponseView: View {
//
//    // --- Placeholder Data (Mirroring the provided JSON) ---
//    let responseId = "resp_67ccd2bed1ec8190b14f964abc0542670bb6a6b452d3795b"
//    let objectType = "response"
//    let createdAt: TimeInterval = 1741476542
//    let status = "completed"
//    let model = "gpt-4.1-2025-04-14"
//    let outputText = "In a peaceful grove beneath a silver moon, a unicorn named Lumina discovered a hidden pool that reflected the stars. As she dipped her horn into the water, the pool began to shimmer, revealing a pathway to a magical realm of endless night skies. Filled with wonder, Lumina whispered a wish for all who dream to find their own hidden magic, and as she glanced back, her hoofprints sparkled like stardust."
//    let parallelToolCalls = true
//    let storeEnabled = true
//    let temperature = 1.0
//    let toolChoice = "auto"
//    let topP = 1.0
//    let truncation = "disabled"
//    let inputTokens = 36
//    let outputTokens = 87
//    let totalTokens = 123
//    // --- End of Placeholder Data ---
//
//    var body: some View {
//        ScrollView {
//            Form {
//                // Section 1: Core Output Text
//                Section("Generated Output") {
//                    Text(outputText)
//                        .font(.body)
//                        .padding(.vertical, 5)
//                        .textSelection(.enabled) // Make text selectable
//                        .fixedSize(horizontal: false, vertical: true) // Ensure text wraps
//                }
//
//                // Section 2: Response Metadata
//                Section("Metadata") {
//                    LabeledContent("Response ID", value: responseId)
//                        .lineLimit(1)
//                        .truncationMode(.middle) // Truncate long IDs if needed
//                    LabeledContent("Object Type", value: objectType)
//                    LabeledContent("Model", value: model)
//                    HStack {
//                        Label("Status", systemImage: status == "completed" ? "checkmark.circle.fill" : "xmark.circle.fill")
//                            .foregroundColor(status == "completed" ? .green : .red)
//                        Spacer()
//                        Text(status.capitalized)
//                            .foregroundColor(.secondary)
//                    }
//                    LabeledContent("Created At", value: formatUnixDate(createdAt))
//                }
//
//                // Section 3: Token Usage
//                Section("Token Usage") {
//                    LabeledContent("Input Tokens", value: "\(inputTokens)")
//                    LabeledContent("Output Tokens", value: "\(outputTokens)")
//                    LabeledContent("Total Tokens", value: "\(totalTokens)")
//                }
//
//                // Section 4: Generation Configuration
//                Section("Configuration") {
//                    LabeledContent("Temperature", value: String(format: "%.1f", temperature))
//                    LabeledContent("Top P", value: String(format: "%.1f", topP))
//                    LabeledContent("Truncation", value: truncation.capitalized)
//                    LabeledContent("Tool Choice", value: toolChoice.capitalized)
//                    LabeledContent("Parallel Tool Calls", value: parallelToolCalls ? "Enabled" : "Disabled")
//                    LabeledContent("Store Result", value: storeEnabled ? "Enabled" : "Disabled")
//                }
//            }
//             // Apply padding around the entire Form content if desired
//             // .padding()
//        }
//        .navigationTitle("API Response Details") // Optional: Add a title if used in NavigationView
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                 Text("API Response Details").font(.headline) // Alternative Title Style
//            }
//        }
//    }
//}
//
//// Preview Provider
//#Preview {
//    NavigationView { // Wrap in NavigationView for better preview context
//        OpenAIResponseView()
//    }
//}
