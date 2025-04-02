//
//  GlanceableContent.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//
//import SwiftUI
//import WidgetKit
//import ActivityKit
//import AppIntents // Required for App Intents
//
//// MARK: - 1 & 2: Live Activity Attributes & State (Karaoke Lyrics)
//
//struct KaraokeAttributes: ActivityAttributes {
//    // Static data for the activity
//    public struct ContentState: Codable, Hashable {
//        // Dynamic data that updates
//        var currentLineIndex: Int
//        var timestamp: Date // For timer examples if needed
//    }
//
//    // Static input for the activity
//    var songTitle: String
//    var lyrics: [String]
//    var totalLines: Int
//}
//
//// MARK: - 3: App Intent for Watch Interaction
//
//struct AdvanceLyricIntent: AppIntent {
//    static var title: LocalizedStringResource = "Advance Lyric"
//    // Add parameters if needed, e.g., activity ID
//
//    // In a real app, this would communicate with the main app
//    // to update the Live Activity state.
//    func perform() async throws -> some IntentResult {
//        print("AdvanceLyricIntent triggered!")
//        // Find the relevant Live Activity and update its state
//        // (Requires communication mechanism like background push or shared data)
//        return .result()
//    }
//}
//
//// MARK: - 4, 5, 6: Live Activity Widget View (iPhone + Watch Tailoring + Interaction)
//
//struct KaraokeLiveActivityView: View {
//    // Access environment values to adapt the view
//    @Environment(\.isLuminanceReduced) var isLuminanceReduced
//    @Environment(\.activityFamily) var activityFamily
//
//    let context: ActivityViewContext<KaraokeAttributes>
//
//    var currentLine: String {
//        context.state.currentLineIndex < context.attributes.lyrics.count ?
//        context.attributes.lyrics[context.state.currentLineIndex] : "..."
//    }
//
//    var body: some View {
//        switch activityFamily {
//        case .activitySupplemental: // watchOS Small / Supplemental View
//            VStack {
//                Text(context.attributes.songTitle)
//                    .font(.caption)
//                Text(currentLine)
//                    .font(.headline)
//                    .foregroundStyle(.cyan)
//                    .lineLimit(2) // Show more lyrics on watch
//                    .contentTransition(.interpolate) // Smooth transitions
//                 // --- Add Double Tap Shortcut ---
//                HStack {
//                     Spacer()
//                     Image(systemName: "hand.tap") // Indicate interactibility
//                         .font(.caption)
//                         .foregroundStyle(.yellow)
//                     Spacer()
//
//                 }
//                 // Add gesture to the whole VStack or a specific element
//                 .handGestureShortcut(.doubleTap, action: AdvanceLyricIntent())
//                 // --- End Double Tap Shortcut ---
//            }
//            .padding(.horizontal, 5)
//
//        case .activityExpanded, .activityMinimal: // Standard iOS Views (Example)
//            fallthrough
//        default:
//            VStack(alignment: .leading) {
//                Text(context.attributes.songTitle)
//                    .font(.headline)
//                Spacer()
//                Text(currentLine)
//                    .font(activityFamily == .activityExpanded ? .title : .body) // Adapt font size
//                    .foregroundStyle(isLuminanceReduced ? .white : .cyan)
//                    .contentTransition(.interpolate)
//                Spacer()
//                ProgressView(value: Double(context.state.currentLineIndex + 1), total: Double(context.attributes.totalLines))
//            }
//            .padding()
//            .activityBackgroundTint(Color.black.opacity(0.8))
//            .activitySystemActionForegroundColor(Color.white)
//        }
//    }
//}
//
//// Create the Live Activity Widget Bundle
//@main
//struct KaraokeWidgets: WidgetBundle {
//    var body: some Widget {
//        KaraokeLiveActivity() // Live Activity definition
//        KaraokeCountdownWidget() // Standard Widget definition
//    }
//}
//
//struct KaraokeLiveActivity: Widget {
//   var body: some WidgetConfiguration {
//       ActivityConfiguration(for: KaraokeAttributes.self) { context in
//           // Lock screen UI - Minimum required (can be same as expanded)
//           KaraokeLiveActivityView(context: context)
//       } dynamicIsland: { context in
//           // Dynamic Island UI (required)
//           DynamicIsland {
//               // Expanded UI - Shown when user long-presses island
//               DynamicIslandExpandedRegion(.leading) {
//                   Text(context.attributes.songTitle).font(.caption)
//               }
//               DynamicIslandExpandedRegion(.trailing) {
//                   Text("\(context.state.currentLineIndex + 1)/\(context.attributes.totalLines)")
//                       .font(.caption)
//               }
//               DynamicIslandExpandedRegion(.center) {
//                  // Often contains primary content or controls
//                   Text(context.state.currentLineIndex < context.attributes.lyrics.count ? context.attributes.lyrics[context.state.currentLineIndex] : "...")
//                       .lineLimit(1)
//                       .font(.body) // Adjust as needed
//                       .contentTransition(.interpolate)
//               }
//               DynamicIslandExpandedRegion(.bottom) {
//                  ProgressView(value: Double(context.state.currentLineIndex + 1), total: Double(context.attributes.totalLines))
//                     .progressViewStyle(.linear)
//               }
//           } compactLeading: {
//               // Compact UI - Leading side of notch/island
//                Image(systemName: "music.mic.circle")
//                    .foregroundStyle(.cyan)
//           } compactTrailing: {
//               // Compact UI - Trailing side of notch/island
//               Text("\(context.state.currentLineIndex + 1)") // Current line number
//                   .foregroundStyle(.cyan)
//                   .contentTransition(.numericText())
//           } minimal: {
//              // Minimal UI - Shown when multiple activities are active
//               Image(systemName: "music.note")
//                .foregroundStyle(.cyan)
//                .contentTransition(.symbolEffect(.replace)) // Nice transition
//           }
//            // Add `.supplementalActivityFamilies([.supplemental])` if you *only*
//            // want to support the supplemental view on watchOS and not have
//            // the system generate a default one from the other views.
//            // If you provide a view for .activitySupplemental as above,
//            // this isn't strictly necessary but can be explicit.
//       }
//   }
//}
//
//// MARK: - 7: Standard Widget (Timeline, Entry, Provider) - Karaoke Countdown
//
//struct KaraokeCountdownEntry: TimelineEntry {
//    let date: Date // Required by TimelineEntry
//    let eventDate: Date
//    let eventName: String
//    let venueLocation: String? // For relevance context
//    let isRelevant: Bool // Simple flag for example
//}
//
//struct KaraokeCountdownProvider: TimelineProvider {
//    // Placeholder data for previews
//    func placeholder(in context: Context) -> KaraokeCountdownEntry {
//        KaraokeCountdownEntry(date: Date(), eventDate: Calendar.current.date(byAdding: .hour, value: 3, to: Date())!, eventName: "WWDC Karaoke", venueLocation: "Apple Park", isRelevant: true)
//    }
//
//    // Snapshot for widget gallery
//    func getSnapshot(in context: Context, completion: @escaping (KaraokeCountdownEntry) -> ()) {
//        let entry = KaraokeCountdownEntry(date: Date(), eventDate: Calendar.current.date(byAdding: .hour, value: 3, to: Date())!, eventName: "Karaoke Night!", venueLocation: nil, isRelevant: true)
//        completion(entry)
//    }
//
//    // Provide timeline entries (when the widget should update)
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [KaraokeCountdownEntry] = []
//        let currentDate = Date()
//        let eventDate = getNextKaraokeEventDate() // Fetch your event date
//
//        // Create an entry for now
//        let entry = KaraokeCountdownEntry(date: currentDate, eventDate: eventDate, eventName: "Karaoke Party", venueLocation: "Main Stage", isRelevant: Calendar.current.isDate(currentDate, equalTo: eventDate, toGranularity: .day))
//        entries.append(entry)
//
//        // Create future updates (e.g., update every 15 mins, or just once at event time)
//         let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
//         let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
//        // let timeline = Timeline(entries: entries, policy: .atEnd) // Update only when timeline ends
//
//        completion(timeline)
//    }
//
//    // Helper to get event date (replace with your logic)
//    private func getNextKaraokeEventDate() -> Date {
//        // In a real app, fetch this from storage, network, calendar etc.
//        return Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
//    }
//}
//
//// MARK: - 8 & 9: Widget View with New Date Formats
//
//struct KaraokeCountdownWidgetView : View {
//    var entry: KaraokeCountdownProvider.Entry
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(entry.eventName)
//                .font(.headline)
//                .foregroundStyle(.purple)
//
//            Divider()
//
//            // --- New Date Formats ---
//            Text("Starts in:")
//                .font(.caption)
//
//            // Timer style (counts down/up)
//            Text(entry.eventDate, style: .timer)
//                .font(Font.system(.title, design: .rounded).monospacedDigit())
//                .fontWeight(.bold)
//                .multilineTextAlignment(.leading) // Ensure leading alignment
//
//            // Relative style
//            Text(entry.eventDate, style: .relative)
//                .font(.footnote)
//                .foregroundStyle(.secondary)
//
//            // Offset style
//            Text(entry.eventDate, style: .offset)
//                .font(.footnote)
//                .foregroundStyle(.secondary)
//
//            // Example of custom Date Reference (e.g., "Today at 5:00 PM")
//            // Requires more setup with Date.FormatStyle components
//             Text("Event Time: \(entry.eventDate, format: .dateTime.hour().minute())")
//                 .font(.caption)
//
//            if let venue = entry.venueLocation {
//                 Text("Location: \(venue)")
//                    .font(.caption)
//                    .foregroundStyle(.tertiary)
//            }
//
//            Spacer() // Push content up
//
//        }
//        .padding()
//        // Use containerBackground for widgets in iOS 17+
//        .containerBackground(for: .widget) {
//             Color.black.opacity(0.6) // Example background
//        }
//
//    }
//}
//
//// MARK: - 10: Widget Configuration with Relevance
//
//struct KaraokeCountdownWidget: Widget {
//    let kind: String = "KaraokeCountdownWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: KaraokeCountdownProvider()) { entry in
//            KaraokeCountdownWidgetView(entry: entry)
//                // Add relevance information here
//                .widgetRelevantContext {
//                    // Define conditions when this widget is most relevant
//                    // Example: Relevant on the day of the event, starting 2 hours before
//                     let twoHoursBefore = Calendar.current.date(byAdding: .hour, value: -2, to: entry.eventDate)!
//                     let isToday = Calendar.current.isDateInToday(entry.eventDate)
//
//                     // Example context: active time window and location (if available)
//                     var context = WidgetRelevantContext()
//
//                     if isToday && entry.date >= twoHoursBefore && entry.date < entry.eventDate {
//                        context.time = RelevantContext.Time(start: twoHoursBefore, end: entry.eventDate)
//                     }
//
//                     // Example: Add location relevance if venue info is present
//                     // Need to convert venueLocation string to a CLRegion or similar
//                     // context.location = RelevantContext.Location(...)
//
//                     // Return the configured context
//                     return context
//                }
//                // Specify default relevance (if context doesn't match)
//                .widgetDefaultRelevantContext(duration: .hours(1)) // e.g., relevant for 1 hour if no specific context applies
//        }
//        .configurationDisplayName("Karaoke Countdown")
//        .description("See when the next karaoke party starts.")
//        .supportedFamilies([.systemSmall, .systemMedium]) // Specify supported sizes
//    }
//}
//
//// MARK: - Previews (Optional)
//
//// Preview for Live Activity
//struct KaraokeLiveActivity_Previews: PreviewProvider {
//    static let attributes = KaraokeAttributes(songTitle: "Cupertino Dreamin'", lyrics: ["First line...", "Second line...", "Third line..."], totalLines: 3)
//    static let contentState = KaraokeAttributes.ContentState(currentLineIndex: 1, timestamp: Date())
//
//    static var previews: some View {
//        // Preview for Supplemental (Watch)
//        ActivityPreview(context: ActivityViewContext(state: contentState, attributes: attributes))
//             .environment(\.activityFamily, .activitySupplemental)
//             .previewDisplayName("Watch Supplemental")
//             .frame(width: 150, height: 80) // Approx watch size
//
//        // Preview for Expanded (iOS Lock Screen / Dynamic Island)
//        ActivityPreview(context: ActivityViewContext(state: contentState, attributes: attributes))
//            .environment(\.activityFamily, .activityExpanded)
//            .previewDisplayName("iOS Expanded")
//
//         // Can add more previews for compact, minimal etc.
//    }
//}
//
//// Preview for Standard Widget
//#Preview(as: .systemSmall) { // Preview widget in small size
//    KaraokeCountdownWidget()
//} timeline: {
//    KaraokeCountdownEntry(date: Date(), eventDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!, eventName: "Preview Party", venueLocation: "Preview Stage", isRelevant: true)
//    KaraokeCountdownEntry(date: Date(), eventDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, eventName: "Future Party", venueLocation: nil, isRelevant: false)
//}
