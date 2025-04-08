////
////  AVPlayerView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//import SwiftUI
//
//// Main ContentView that renders the UI
//struct AVPlayerView: View {
//
//    // MARK: - State Variables
//    // These would typically be updated based on AVPlayerItem state changes
//    @State private var playerStatus: String = "Unknown"
//    @State private var statusColor: Color = .orange // Color for the status text
//    @State private var currentTimeString: String = "00:00"
//    @State private var totalTimeString: String = "00:00"
//    @State private var playbackProgress: Double = 0.0 // Value between 0.0 and 1.0 (or actual time)
//    @State private var logs: String = "8:37 AM [ERROR] Play() called but no item loaded\n" // Example initial log
//
//    // MARK: - Body
//    var body: some View {
//        VStack(spacing: 0) { // Main vertical stack, zero spacing initially to control manually
//
//            // 1. Title Area
//            Text("AVPlayerItem Demo")
//                .font(.title) // Use a suitable font size
//                .fontWeight(.bold)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding()
//                // Note: The screenshot shows white background here, but it might be
//                // part of a larger container or navigation view in a real app.
//                // Background is omitted here to fit standard view structure.
//
//            // 2. Player Placeholder View
//            Rectangle()
//                .fill(Color.black)
//                .frame(height: 200) // Adjust height as needed
//                // In a real app, this would be replaced by a UIViewRepresentable
//                // holding an AVPlayerLayer or a VideoPlayer view (iOS 14+)
//
//            // 3. Player Info and Controls Section
//            VStack(alignment: .leading, spacing: 8) {
//                // Status Label
//                HStack {
//                    Text("Status:")
//                        .font(.headline)
//                    Text(playerStatus)
//                        .font(.headline)
//                        .foregroundColor(statusColor) // Dynamic color based on status potentially
//                    Spacer() // Push status to the left
//                }
//
//                // Playback Controls and Timing
//                HStack {
//                    Text(currentTimeString)
//                        .font(.caption)
//                        .monospacedDigit() // Ensures fixed width for time digits
//
//                    Spacer()
//
//                    // Play/Pause Button Placeholder
//                    Button {
//                        // Add play/pause action here
//                        print("Play/Pause tapped")
//                    } label: {
//                        Image(systemName: "play.fill") // Icon can change based on player state
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                            .foregroundColor(.blue) // System blue color
//                    }
//
//                    Spacer()
//
//                    Text(totalTimeString)
//                        .font(.caption)
//                        .monospacedDigit()
//                }
//
//                // Progress Slider
//                Slider(value: $playbackProgress, in: 0...1) { // Assuming progress is 0.0 to 1.0
//                    // Empty label needed for structure
//                } minimumValueLabel: {
//                    // Empty label
//                } maximumValueLabel: {
//                    // Empty label
//                }
//                // You might need to customize the slider's appearance further
//                // or use a custom ProgressView for a non-interactive bar.
//
//            }
//            .padding(.horizontal) // Add padding to the sides of the controls section
//            .padding(.vertical, 10) // Add vertical padding
//            // Removed explicit background color here to let the main VStack background show
//
//            Divider() // Visual separation
//
//            // 4. Logs Section
//            VStack(alignment: .leading, spacing: 12) {
//                Text("LOGS")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity, alignment: .leading) // Align title left
//
//                // Action Buttons
//                HStack(spacing: 15) {
//                    // Using a custom Button Style for consistent look
//                    Button("Fetch Access Log") {
//                        fetchAccessLog()
//                    }
//                    .buttonStyle(FilledButtonStyle(backgroundColor: .blue))
//
//                    Button("Fetch Error Log") {
//                        fetchErrorLog()
//                    }
//                    .buttonStyle(FilledButtonStyle(backgroundColor: .blue))
//
//                    Button("Clear UI Logs") {
//                        clearLogs()
//                    }
//                    .buttonStyle(FilledButtonStyle(backgroundColor: .pink.opacity(0.7))) // Pinkish color
//                }
//                .frame(maxWidth: .infinity) // Center the HStack containing buttons
//
//                // Log Output Area
//                TextEditor(text: $logs)
//                    .font(.system(.footnote, design: .monospaced)) // Monospaced for log readability
//                    .frame(height: 150) // Fixed height for the log area
//                    .border(Color.gray.opacity(0.3), width: 1) // Subtle border
//                    .cornerRadius(4) // Slightly rounded corners for the text editor border
//                    .disabled(true) // Make it read-only like a log display
//
//            }
//            .padding() // Add padding around the entire Logs section
//
//            Spacer() // Push all content towards the top
//        }
//        .background(Color(.systemGroupedBackground)) // Use a subtle background color for the whole view
//        // .ignoresSafeArea(edges: .bottom) // Optional: Extend background to bottom edge if needed
//    }
//
//    // MARK: - Action Methods (Placeholders)
//    func fetchAccessLog() {
//        let timestamp = Date().formatted(date: .omitted, time: .standard)
//        logs += "\(timestamp) [INFO] Fetched Access Log.\n"
//        print("Fetch Access Log Tapped")
//        // Add logic to fetch AVPlayerItem.accessLog()
//    }
//
//    func fetchErrorLog() {
//        let timestamp = Date().formatted(date: .omitted, time: .standard)
//        logs += "\(timestamp) [INFO] Fetched Error Log.\n"
//        print("Fetch Error Log Tapped")
//        // Add logic to fetch AVPlayerItem.errorLog()
//    }
//
//    func clearLogs() {
//        logs = "" // Clear the log text
//        print("Clear UI Logs Tapped")
//    }
//}
//
//// MARK: - Custom Button Style
//struct FilledButtonStyle: ButtonStyle {
//    var backgroundColor: Color
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.caption.weight(.semibold))
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .foregroundColor(.white)
//            .background(backgroundColor)
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//            .scaleEffect(configuration.isPressed ? 0.96 : 1.0) // Subtle press effect
//            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//// MARK: - Preview Provider
//struct AVPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        AVPlayerView()
//    }
//}
