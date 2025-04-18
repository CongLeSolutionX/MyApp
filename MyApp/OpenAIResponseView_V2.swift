//
//  OpenAIResponseView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import Foundation

// Represents the error structure (simplified)
struct ResponseError: Codable, Hashable {
    let code: String?
    let message: String
    let type: String?
}

// Represents the output content structure
struct OutputContent: Codable, Hashable {
    let type: String // e.g., "output_text"
    let text: String?
    // Skipping annotations for simplicity
}

// Represents a single output message
struct OutputMessage: Codable, Hashable {
    let id: String
    let type: String // e.g., "message"
    let status: String
    let role: String // e.g., "assistant"
    let content: [OutputContent]
}

// Represents the usage details
struct UsageDetails: Codable, Hashable {
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int
    // Skipping detailed nested fields like cached_tokens for this view
    
    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
    }
}

// Main structure for the API response
struct OpenAIResponse: Codable, Hashable, Identifiable {
    let id: String
    let object: String
    let createdAt: TimeInterval
    let status: String
    let error: ResponseError? // Make error optional
    let model: String
    let output: [OutputMessage]? // Make output optional for error cases
    let parallelToolCalls: Bool?
    let store: Bool?
    let temperature: Double?
    let toolChoice: String?
    let topP: Double?
    let truncation: String?
    let usage: UsageDetails? // Make usage optional for error cases
    
    // Helper to easily get the primary text output
    var primaryOutputText: String? {
        guard status == "completed", let firstMessage = output?.first(where: { $0.role == "assistant" }),
              let textContent = firstMessage.content.first(where: { $0.type == "output_text" })?.text else {
            return nil
        }
        return textContent
    }
    
    // Coding keys to map JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case id, object, status, error, model, output, store, temperature, usage, user, metadata // Include simplified keys
        case createdAt = "created_at"
        case parallelToolCalls = "parallel_tool_calls"
        case toolChoice = "tool_choice"
        case topP = "top_p"
        case truncation
        // Ignoring fields not directly displayed: instructions, max_output_tokens, prev_id, reasoning, text, tools
    }
    
    // Provide default initializer for Hashable conformance if needed, or rely on synthesized
    // Provide init(from decoder: Decoder) if custom decoding logic is needed
}

import SwiftUI
import UniformTypeIdentifiers // Required for UIPasteboard

// Helper to format the Unix timestamp (same as before)
fileprivate func formatUnixDate(_ timestamp: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: timestamp)
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

// Main SwiftUI View to display the API Response Data
struct OpenAIResponseView: View {
    // State to manage feedback on copy actions
    @State private var outputCopied: Bool = false
    @State private var idCopied: Bool = false
    @State private var showErrorAlert: Bool = false
    
    // The response data - optional to handle loading/error states
    let response: OpenAIResponse?
    // Mock action closure for regeneration
    let onRegenerate: (() -> Void)?
    
    // Computed property for easier access to primary text
    private var primaryText: String? {
        response?.primaryOutputText
    }
    
    // Computed property to determine if the view should show content vs loading/error
    private var shouldShowContent: Bool {
        guard let response = response else { return false }
        return response.status == "completed" && response.error == nil && response.primaryOutputText != nil
    }
    
    var body: some View {
        ScrollView {
            if response == nil {
                // --- Loading State ---
                ProgressView("Loading Response...")
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity)
                
            } else if let error = response?.error {
                // --- Error State (Based on Error Field) ---
                ErrorView(error: error)
                
            } else if response?.status != "completed" {
                // --- Error State (Based on Status Field) ---
                ErrorView(error: ResponseError(
                    code: response?.status,
                    message: "Response processing did not complete successfully (Status: \(response?.status ?? "unknown")).",
                    type: "status_error"
                ))
                
            } else if let response = response, shouldShowContent {
                // --- Success State ---
                Form {
                    // Section 1: Core Output Text with Actions
                    Section("Generated Output") {
                        VStack(alignment: .leading, spacing: 10) {
                            if let text = primaryText {
                                Text(text)
                                    .font(.body)
                                    .textSelection(.enabled)
                                    .fixedSize(horizontal: false, vertical: true) // Ensure text wraps
                                
                                HStack(spacing: 15) {
                                    Spacer() // Push buttons to the right
                                    
                                    // Copy Button
                                    Button {
                                        copyToClipboard(text)
                                        outputCopied = true
                                        // Reset after a delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            outputCopied = false
                                        }
                                    } label: {
                                        Label(outputCopied ? "Copied!" : "Copy", systemImage: outputCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(outputCopied ? .green : .blue) // Visual feedback
                                    
                                    // Share Button
                                    ShareLink(item: text) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding(.top, 5) // Add some space above buttons
                            } else {
                                Text("No output text found.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    // Section 2: Response Metadata with ID Copy
                    Section("Metadata") {
                        HStack {
                            LabeledContent("Response ID") {
                                Text(response.id)
                                    .lineLimit(1)
                                    .truncationMode(.middle) // Truncate long IDs
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                copyToClipboard(response.id)
                                idCopied = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    idCopied = false
                                }
                            } label: {
                                Image(systemName: idCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                    .foregroundColor(idCopied ? .green : .blue)
                            }
                            .buttonStyle(.plain) // Use plain style for inline icon button
                        }
                        LabeledContent("Object Type", value: response.object)
                        LabeledContent("Model", value: response.model)
                        HStack {
                            Label("Status", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green) // Always green in success case
                            Spacer()
                            Text(response.status.capitalized)
                                .foregroundColor(.secondary)
                        }
                        LabeledContent("Created At", value: formatUnixDate(response.createdAt))
                    }
                    
                    // Section 3: Token Usage
                    if let usage = response.usage {
                        Section("Token Usage") {
                            LabeledContent("Input Tokens", value: "\(usage.inputTokens)")
                            LabeledContent("Output Tokens", value: "\(usage.outputTokens)")
                            LabeledContent("Total Tokens", value: "\(usage.totalTokens)")
                        }
                    }
                    
                    // Section 4: Generation Configuration
                    Section("Configuration") {
                        if let temp = response.temperature {
                            LabeledContent("Temperature", value: String(format: "%.1f", temp))
                        }
                        if let topP = response.topP {
                            LabeledContent("Top P", value: String(format: "%.1f", topP))
                        }
                        if let trunc = response.truncation {
                            LabeledContent("Truncation", value: trunc.capitalized)
                        }
                        if let choice = response.toolChoice {
                            LabeledContent("Tool Choice", value: choice.capitalized)
                        }
                        if let parallel = response.parallelToolCalls {
                            LabeledContent("Parallel Tool Calls", value: parallel ? "Enabled" : "Disabled")
                        }
                        if let store = response.store {
                            LabeledContent("Store Result", value: store ? "Enabled" : "Disabled")
                        }
                    }
                } // End Form
            } else {
                // --- Fallback / Unexpected State ---
                ErrorView(error: ResponseError(code: "ui_error", message: "Could not display response content.", type: "internal"))
            }
            
        } // End ScrollView
        .navigationTitle("API Response Details")
        .toolbar {
            // Add Regenerate button to toolbar if action is provided
            if let regenerateAction = onRegenerate {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        regenerateAction() // Call the provided closure
                    } label: {
                        Label("Regenerate", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    // Helper function for copying text
    private func copyToClipboard(_ text: String) {
#if os(iOS) || os(macOS) // UIPasteboard is available on iOS and macOS via Catalyst or AppKit bridging
        UIPasteboard.general.string = text
#else
        // Handle other platforms if necessary (e.g., tvOS, watchOS - clipboard might not be available)
        print("Clipboard not available on this platform.")
#endif
        print("Copied: \(text)") // Debug print
    }
}

// Separate view for displaying errors nicely
struct ErrorView: View {
    let error: ResponseError
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Error Processing Response")
                .font(.headline)
            Text(error.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if let code = error.code {
                Text("Code: \(code)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center vertically
    }
}

// --- Mock Data for Previews ---

let mockSuccessResponse = OpenAIResponse(
    id: "resp_67ccd2bed1ec8190b14f964abc0542670bb6a6b452d3795b",
    object: "response",
    createdAt: 1741476542,
    status: "completed",
    error: nil,
    model: "gpt-4.1-2025-04-14",
    output: [
        OutputMessage(
            id: "msg_67ccd2bf17f0819081ff3bb2cf6508e60bb6a6b452d3795b",
            type: "message",
            status: "completed",
            role: "assistant",
            content: [
                OutputContent(
                    type: "output_text",
                    text: "In a peaceful grove beneath a silver moon, a unicorn named Lumina discovered a hidden pool that reflected the stars. As she dipped her horn into the water, the pool began to shimmer, revealing a pathway to a magical realm of endless night skies. Filled with wonder, Lumina whispered a wish for all who dream to find their own hidden magic, and as she glanced back, her hoofprints sparkled like stardust."
                )
            ]
        )
    ],
    parallelToolCalls: true,
    store: true,
    temperature: 1.0,
    toolChoice: "auto",
    topP: 1.0,
    truncation: "disabled",
    usage: UsageDetails(inputTokens: 36, outputTokens: 87, totalTokens: 123)
)

let mockErrorResponse = OpenAIResponse(
    id: "resp_err_1234567890abcdef1234567890abcdef",
    object: "response",
    createdAt: 1741477000,
    status: "failed",
    error: ResponseError(code: "invalid_request_error", message: "The prompt provided contained disallowed content.", type: "api_error"),
    model: "gpt-4.1-2025-04-14",
    output: nil, // No output on error
    parallelToolCalls: nil,
    store: nil,
    temperature: nil,
    toolChoice: nil,
    topP: nil,
    truncation: nil,
    usage: nil // Potentially no usage on some errors
)

// --- Preview Provider ---
#Preview("Success State") {
    NavigationView {
        OpenAIResponseView(response: mockSuccessResponse) {
            print("Regenerate Tapped!") // Mock action
        }
    }
}

#Preview("Loading State") {
    NavigationView {
        OpenAIResponseView(response: nil, onRegenerate: nil) // Pass nil for loading
    }
}

#Preview("Error State") {
    NavigationView {
        OpenAIResponseView(response: mockErrorResponse, onRegenerate: nil)
    }
}
