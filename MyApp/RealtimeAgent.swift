//
//  RealtimeSessionCardView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import Foundation
import SwiftUI // Needed for Date formatting later

// Data structure to hold key session information
struct RealtimeSessionInfo {
    let sessionId: Date
    let model: String
    let modalities: [String]
    let instructions: String
    let voice: String
    let clientSecretExpiresAt: Date? // Store as Date for easier formatting
    let turnDetectionThreshold: Double? // Example of including a specific setting

    // Helper to format modalities array
    var modalitiesString: String {
        modalities.map { $0.capitalized }.joined(separator: ", ")
    }

    // Example Initializer using the provided JSON data
    static func fromExampleData() -> RealtimeSessionInfo {
        let expirationTimestamp: TimeInterval = 1744582951
        return RealtimeSessionInfo(
            sessionId: Date(),
            model: "gpt-4o-realtime-preview",
            modalities: ["text", "audio"],
            instructions: "You are a friendly assistant.",
            voice: "alloy",
            clientSecretExpiresAt: Date(timeIntervalSince1970: expirationTimestamp),
            turnDetectionThreshold: 0.5
        )
    }
}


import SwiftUI

struct RealtimeSessionCardView: View {
    let sessionInfo: RealtimeSessionInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Image(systemName: "waveform.circle.fill") // Icon representing audio/realtime
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Real-time Session Created")
                    .font(.headline)
                Spacer()
                Image(systemName: "checkmark.circle.fill") // Success indicator
                    .foregroundColor(.green)
            }

            Divider()

            // Session Details Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Session Details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                InfoRow(label: "Session ID", value: sessionInfo.sessionId)
               // InfoRow(label: "Model", value: sessionInfo.model)
              //  InfoRow(label: "Modalities", value: sessionInfo.modalitiesString)
             //   InfoRow(label: "Voice", value: sessionInfo.voice.capitalized)

                // Show instructions if not too long, otherwise indicate presence
//                if !sessionInfo.instructions.isEmpty {
//                   InfoRow(label: "Instructions", value: "\"\(sessionInfo.instructions)\"", lineLimit: 2)
//                }

                // Format the expiration date
//                if let expirationDate = sessionInfo.clientSecretExpiresAt {
//                    InfoRow(label: "Connection Valid Until", value: expirationDate, style: .date)
//                }

                // Example of showing a specific setting
//                if let threshold = sessionInfo.turnDetectionThreshold {
//                     InfoRow(label: "Turn Detect Threshold", value: String(format: "%.1f", threshold))
//                }
            }
        }
        .padding()
        .background(Color(.systemGray6)) // Use a subtle background color
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Helper View for consistent label-value rows
struct InfoRow: View {
    let label: String
    let value: String
    var isMonospaced: Bool = false
    var lineLimit: Int? = 1

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 150, alignment: .leading) // Align labels
            Text(value)
                .font(isMonospaced ? .caption.monospaced() : .caption)
                .lineLimit(lineLimit)
                .frame(maxWidth: .infinity, alignment: .leading) // Allow value to wrap
        }
    }

    // Overload for Date formatting
    init(label: String, value: Date, style: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = timeStyle
        self.label = label
        self.value = formatter.string(from: value)
        self.isMonospaced = false
        self.lineLimit = 1
    }
}

// Example Usage in a ContentView
struct ContentView: View {
    // Create data instance from your example
    let sessionData = RealtimeSessionInfo.fromExampleData()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    RealtimeSessionCardView(sessionInfo: sessionData)
                        .padding() // Add padding around the card

                    Spacer() // Pushes card to the top if needed
                }
            }
            .navigationTitle("OpenAI Sessions")
        }
    }
}

#Preview {
    ContentView()
}
