//
//  RealtimeAgent_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import Foundation
import SwiftUI

// Enum for Session Status
enum SessionStatus: String, CaseIterable {
    case active
    case expired
    case connecting
    case error

    var icon: String {
        switch self {
        case .active: "checkmark.circle.fill"
        case .expired: "xmark.circle.fill"
        case .connecting: "hourglass.circle"
        case .error: "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .active: .green
        case .expired: .gray
        case .connecting: .orange
        case .error: .red
        }
    }
}

// Enhanced, Identifiable Data Structure
struct RealtimeSessionInfo: Identifiable {
    let id = UUID() // Make it Identifiable for Lists/Navigation
    let sessionId: String
    let model: String
    let modalities: [String]
    let instructions: String
    let voice: String
    let clientSecretExpiresAt: Date?
    let turnDetectionThreshold: Double?
    let creationDate: Date // Added creation date context
    var status: SessionStatus // Added dynamic status

    // Helper for display
    var modalitiesString: String {
        modalities.map { $0.capitalized }.joined(separator: ", ")
    }

    // Check if instructions might be truncated (simple length check)
    var instructionsPotentiallyTruncated: Bool {
        instructions.count > 80 // Arbitrary threshold for demonstration
    }

    // Helper to check if expired (allows for buffer)
    var isExpired: Bool {
        guard let expiry = clientSecretExpiresAt else { return false } // If no expiry, assume not expired
        // Consider expired slightly before actual time for safety
        return expiry.addingTimeInterval(-60) < Date()
    }

    // --- Mock Data Generation ---
    static func generateMock(index: Int) -> RealtimeSessionInfo {
        let now = Date()
        let expiryInterval: TimeInterval = Double.random(in: -3600...7200) // Expire between 1hr ago and 2hrs from now
        let expirationDate = now.addingTimeInterval(expiryInterval)
        let mockInstructions = [
            "You are a helpful assistant.",
            "Respond concisely.",
            "Act as a pirate captain giving directions on a treasure map. Make sure to use plenty of pirate slang like 'Ahoy!', 'Shiver me timbers!', and 'X marks the spot!'. Keep the directions exciting and adventurous.",
            "Summarize technical documents clearly.",
            "Translate English to French."
        ]
        let mockModels = ["gpt-4o-realtime-preview", "gpt-4-turbo-realtime", "custom-realtime-model"]
        let mockVoices = ["alloy", "echo", "fable", "onyx", "nova", "shimmer"]

        var status: SessionStatus
        if expirationDate < now {
            status = .expired
        } else if index % 5 == 0 { // Simulate occasional errors/connecting
             status = [.connecting, .error].randomElement()!
        }
        else {
            status = .active
        }

        return RealtimeSessionInfo(
            sessionId: "sess_" + UUID().uuidString.prefix(20).lowercased(),
            model: mockModels.randomElement()!,
            modalities: [["text", "audio"].randomElement()!, "audio"], // Ensure audio is usually there
            instructions: mockInstructions.randomElement()!,
            voice: mockVoices.randomElement()!,
            clientSecretExpiresAt: expirationDate,
            turnDetectionThreshold: [0.3, 0.5, 0.7].randomElement()!,
            creationDate: now.addingTimeInterval(Double(-index * 60 * 5)), // Stagger creation times
            status: status
        )
    }

    static var mockSessions: [RealtimeSessionInfo] {
        (0..<10).map { generateMock(index: $0) }
    }
}

import SwiftUI

// A dedicated view to show all details when navigating
struct SessionDetailView: View {
    let sessionInfo: RealtimeSessionInfo

    var body: some View {
        List {
            Section("Overview") {
                InfoRow(label: "Session ID", value: sessionInfo.sessionId, isMonospaced: true) {
                    CopyButton(textToCopy: sessionInfo.sessionId) // Add copy here too
                }
                InfoRow(label: "Status", value: sessionInfo.status.rawValue.capitalized) {
                    Image(systemName: sessionInfo.status.icon)
                        .foregroundColor(sessionInfo.status.color)
                }
                InfoRow(label: "Created", value: sessionInfo.creationDate, style: .medium, timeStyle: .short)
                if let expiry = sessionInfo.clientSecretExpiresAt {
                     InfoRow(label: "Expires", value: expiry, style: .medium, timeStyle: .short)
                }
            }

            Section("Configuration") {
                InfoRow(label: "Model", value: sessionInfo.model)
                InfoRow(label: "Modalities", value: sessionInfo.modalitiesString)
                InfoRow(label: "Voice", value: sessionInfo.voice.capitalized)
                if let threshold = sessionInfo.turnDetectionThreshold {
                     InfoRow(label: "Turn Detect", value: String(format: "%.1f", threshold))
                }
            }

            Section("Instructions") {
                Text(sessionInfo.instructions)
                    .font(.body)
                    .lineSpacing(5)
                    .padding(.vertical, 5)
            }
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}



import SwiftUI

struct RealtimeSessionCardView: View {
    let sessionInfo: RealtimeSessionInfo
    @State private var showingFullInstructions = false // State for modal sheet

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header - Now reflects dynamic status
            HStack {
                Image(systemName: "waveform.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Real-time Session") // Slightly more generic title
                    .font(.headline)
                Spacer()
                // Dynamic Status Icon
                Image(systemName: sessionInfo.status.icon)
                    .foregroundColor(sessionInfo.status.color)
                    .font(.title2)
                    .accessibilityLabel("Session status: \(sessionInfo.status.rawValue)")
            }

            Divider()

            // Session Details Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Info")
                    .font(.caption) // Use caption for section header
                    .foregroundColor(.secondary)
                    .padding(.bottom, 2)

                // Made Session ID row interactive
                InfoRow(label: "Session ID", value: sessionInfo.sessionId, isMonospaced: true) {
                    CopyButton(textToCopy: sessionInfo.sessionId) // Pass the ID to the button
                }
                .accessibilityElement(children: .combine) // Combine label, value, button for accessibility

                InfoRow(label: "Model", value: sessionInfo.model, lineLimit: 1)
                InfoRow(label: "Created", value: sessionInfo.creationDate, style: .short, timeStyle:.short)

                // Make Instructions interactive if needed
                if !sessionInfo.instructions.isEmpty {
                    HStack(alignment: .top) {
                        InfoRow(label: "Instructions", value: "\"\(sessionInfo.instructions)\"", lineLimit: 2)
                            .accessibilityHint(sessionInfo.instructionsPotentiallyTruncated ? "Tap to view full instructions" : "")

                        if sessionInfo.instructionsPotentiallyTruncated {
                             Image(systemName: "doc.text.magnifyingglass")
                                .foregroundColor(.accentColor)
                                .padding(.leading, 5)
                                .accessibilityLabel("View full instructions")
                         }
                    }
                    .contentShape(Rectangle()) // Make the whole HStack tappable
                    .onTapGesture {
                        if sessionInfo.instructionsPotentiallyTruncated {
                            showingFullInstructions = true
                        }
                    }
                }

                // Format the expiration date concisely
                if let expirationDate = sessionInfo.clientSecretExpiresAt {
                    let relativeFormatter = RelativeDateTimeFormatter()
                   // relativeFormatter.unitsStyle = .abbreviated
                    let relativeDateString = relativeFormatter.localizedString(for: expirationDate, relativeTo: Date())
                    InfoRow(label: "Expires", value: relativeDateString)
                        .foregroundColor(sessionInfo.isExpired ? .secondary : .primary) // Dim if expired
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground)) // Slightly different background
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)
        // --- Add Sheet Modifier ---
        .sheet(isPresented: $showingFullInstructions) {
            // --- View Presented in the Sheet ---
            NavigationView { // Add NavigationView for title/buttons inside sheet
                // Explicitly call the initializer with default parameters
                ScrollView(.vertical, showsIndicators: true) {
                    Text(sessionInfo.instructions)
                        .padding()
                }
                .navigationTitle("Full Instructions")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showingFullInstructions = false }
                    }
                })
            }

        }
    }
}

// --- Helper Views ---

// Reusable Copy Button
struct CopyButton: View {
    let textToCopy: String
    @State private var copied = false // Feedback state

    var body: some View {
        Button {
            UIPasteboard.general.string = textToCopy
            copied = true
            // Reset visual feedback after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                copied = false
            }
        } label: {
            Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                 .foregroundColor(copied ? .green : .accentColor)
                 .animation(.easeInOut, value: copied) // Animate the change
        }
        .buttonStyle(.plain) // Use plain style to avoid default button background
        .accessibilityLabel(copied ? "Copied" : "Copy to clipboard")
    }
}

// Updated InfoRow to allow trailing content
struct InfoRow<TrailingContent: View>: View {
    let label: String
    let value: String
    var isMonospaced: Bool = false
    var lineLimit: Int? = 1
    @ViewBuilder let trailingContent: TrailingContent // Generic trailing view

    // Initializer for String value
    init(label: String, value: String, isMonospaced: Bool = false, lineLimit: Int? = 1, @ViewBuilder trailingContent: () -> TrailingContent = { EmptyView() }) {
        self.label = label
        self.value = value
        self.isMonospaced = isMonospaced
        self.lineLimit = lineLimit
        self.trailingContent = trailingContent()
    }

    // Overload for Date formatting
    init(label: String, value: Date, style: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short, @ViewBuilder trailingContent: () -> TrailingContent = { EmptyView() }) {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = timeStyle
        self.label = label
        self.value = formatter.string(from: value)
        self.isMonospaced = false
        self.lineLimit = 1
        self.trailingContent = trailingContent()
    }

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading) // Fixed label width

            HStack { // Inner HStack for value and trailing content
                 Text(value)
                    .font(isMonospaced ? .caption.monospaced() : .caption)
                    .lineLimit(lineLimit)
                    .frame(maxWidth: .infinity, alignment: .leading) // Allow value to wrap
                 Spacer() // Pushes trailing content to the end
                 trailingContent
            }
        }
        .frame(minHeight: 18) // Ensure minimum row height
    }
}

struct ContentView: View {
    @State private var sessions = RealtimeSessionInfo.mockSessions
    // Instantiate the ViewModel
    // Use @StateObject to keep it alive for the view's lifecycle
    @StateObject private var speechViewModel = SpeechRecognitionViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Use VStack to stack List and Voice UI
                List {
                    ForEach(sessions) { session in
                        NavigationLink {
                            SessionDetailView(sessionInfo: session)
                        } label: {
                            RealtimeSessionCardView(sessionInfo: session)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteSession(session)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .navigationTitle("OpenAI Sessions")
                .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Apply background to List only
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                             sessions = RealtimeSessionInfo.mockSessions
                        } label: {
                             Image(systemName: "arrow.clockwise")
                        }
                    }
                }

                // --- Voice Input UI Area ---
                Divider() // Separate list from voice controls
                VoiceInputView(viewModel: speechViewModel)
                    .padding()
                    .background(Color(.systemBackground)) // Background for the voice area
                // --- End Voice Input UI Area ---
            }
            .onAppear {
                // Set the command handler when the view appears
                // Here, ContentView itself will handle the command
                 speechViewModel.commandHandler = self
            }
            .onDisappear {
                 // Clean up listener when the view disappears
                 speechViewModel.stopListening()
            }
        }
    }

    func deleteSession(_ session: RealtimeSessionInfo) {
        sessions.removeAll { $0.id == session.id }
    }
}

// MARK: - SpeechCommandHandler Conformance for ContentView
extension ContentView: SpeechCommandHandler {
    func handleVoiceCommand(_ command: String) {
        print("ContentView Received Command: \(command)")
        let lowercasedCommand = command.lowercased()

        // --- Example Command Handling Logic ---
        // This is where you'd implement the actual actions based on the voice command.
        if lowercasedCommand.contains("refresh sessions") || lowercasedCommand.contains("reload") {
            print("ACTION: Refreshing sessions...")
            sessions = RealtimeSessionInfo.mockSessions
        } else if lowercasedCommand.contains("delete all") {
            print("ACTION: Deleting all sessions...")
            sessions.removeAll()
        } else if let sessionIdPrefix = extractSessionId(from: lowercasedCommand) {
             print("ACTION: Trying to navigate to session starting with \(sessionIdPrefix)...")
             // TODO: Implement navigation logic if possible, or select the item.
             // Navigation programmatically in SwiftUI can be complex.
             // You might filter the list or highlight the item.
             if let sessionToSelect = sessions.first(where: { $0.sessionId.lowercased().hasPrefix("sess_\(sessionIdPrefix)") }) {
                 print("Found session: \(sessionToSelect.sessionId)")
                 // Highlight or select logic here (difficult with default List/NavLink)
             } else {
                print("Session with prefix \(sessionIdPrefix) not found.")
             }
        } else {
            print("Command not recognized: \(command)")
            // Optionally provide feedback to the user via speechViewModel.statusMessage
            // speechViewModel.statusMessage = "Command '\(command)' not recognized."
        }
        // --- End Example Command Handling ---
    }

    // Helper to extract potential session ID prefix (simple example)
    private func extractSessionId(from command: String) -> String? {
        // Look for patterns like "go to session abc12", "open session abc12"
        let patterns = ["go to session", "open session", "select session", "show session", "find session"]
        for pattern in patterns {
            if let range = command.range(of: pattern + " ") {
                let potentialId = String(command[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                // Basic validation: check if it looks like part of our mock UUIDs
                if !potentialId.isEmpty && potentialId.count <= 20 && potentialId.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil {
                     return potentialId
                }
            }
        }
        // Look for just "session abc12"
        if let range = command.range(of: "session ") {
            let potentialId = String(command[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
             if !potentialId.isEmpty && potentialId.count <= 20 && potentialId.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil {
                 return potentialId
             }
        }
        return nil
    }
}

// MARK: - Dedicated Voice Input UI View
struct VoiceInputView: View {
    @ObservedObject var viewModel: SpeechRecognitionViewModel // Use ObservedObject here

    var body: some View {
        VStack {
            // Status Message / Transcribed Text Area
            Text(viewModel.isListening ? (viewModel.transcribedText.isEmpty ? "Listening..." : viewModel.transcribedText) : viewModel.statusMessage)
                 .font(.callout)
                 .foregroundColor(viewModel.hasError ? .red : .secondary)
                 .frame(height: 50, alignment: .center) // Give it some fixed height
                 .lineLimit(3)
                 .multilineTextAlignment(.center)

            // Microphone Button
            Button {
                viewModel.toggleListening()
            } label: {
                Image(systemName: viewModel.isListening ? "mic.fill" : "mic.slash.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .padding(20)
                    .background(
                        Circle()
                             // Optional: Use mic level for visual feedback
                            .fill(viewModel.isListening ? Color.red.opacity(0.8) : Color.gray.opacity(0.5))
                             .scaleEffect(viewModel.isListening ? CGFloat(1.0 + viewModel.micLevel * 0.4) : 1.0) // Pulse effect
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.micLevel)
                    )
                    .foregroundColor(.white)
            }
            .disabled(viewModel.hasError && !viewModel.isListening) // Disable if error state unless actively trying to stop
        }
    }
}

// --- Previews (No changes needed unless you want to test voice UI standalone) ---

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

#Preview {
    ContentView()
        .preferredColorScheme(.light)
}

// Optional: Preview for the VoiceInputView itself
#Preview("Voice Input UI") {
    VoiceInputView(viewModel: SpeechRecognitionViewModel())
        .padding()
        .background(Color.gray.opacity(0.2))
}
#Preview {
    ContentView()
        .preferredColorScheme(.dark) // Preview in dark mode too
}

#Preview {
    ContentView()
        .preferredColorScheme(.light)
}
