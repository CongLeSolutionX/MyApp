//
//  TimelineViewExample.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//
import SwiftUI
import Combine // Needed for PassthroughSubject if used elsewhere, good practice for ObservableObject
import Foundation

// MARK: - TimelineScheduleMode

/// A mode of operation for timeline schedule updates.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum TimelineScheduleMode: Sendable, Hashable, Equatable {
    /// A mode that produces schedule updates at the schedule's natural cadence.
    case normal

    /// A mode that produces schedule updates at a reduced rate.
    case lowFrequency
}

// MARK: - TimelineSchedule Protocol

/// A type that provides a sequence of dates for use as a schedule.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol TimelineSchedule {
    /// An alias for the timeline schedule update mode.
    typealias Mode = TimelineScheduleMode

    /// The sequence of dates within a schedule.
    associatedtype Entries: Sequence where Self.Entries.Element == Date

    /// Provides a sequence of dates starting around a given date.
    func entries(from startDate: Date, mode: Self.Mode) -> Self.Entries
}

// MARK: - PeriodicTimelineSchedule

/// A schedule for updating a timeline view at regular intervals.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct PeriodicTimelineSchedule: TimelineSchedule, Sendable {

    private let scheduleStartDate: Date
    private let interval: TimeInterval

    /// Creates a periodic update schedule.
    /// - Parameters:
    ///   - startDate: The date on which to start the sequence generation *relative to*.
    ///   - interval: The time interval between successive sequence entries. Must be positive.
    public init(from startDate: Date, by interval: TimeInterval) {
        precondition(interval > 0, "PeriodicTimelineSchedule interval must be positive.")
        // Store the reference date which defines the 'phase' of the schedule.
        self.scheduleStartDate = startDate
        self.interval = interval
    }

    /// Provides a sequence of periodic dates starting from around a given date.
    public func entries(from date: Date, mode: TimelineScheduleMode) -> Entries {
        // Adjust interval based on mode if desired, e.g., lowFrequency could use a larger interval
        let actualInterval = (mode == .lowFrequency) ? max(interval, 60.0) : interval // Example: min 1 minute in low freq

        // --- Corrected Logic for First Entry ---
        // Find how many intervals have passed since the schedule's reference start date
        // up to the requested `date`.
        let timeSinceScheduleStart = date.timeIntervalSince(scheduleStartDate)

        var nextEntryDate: Date
        if timeSinceScheduleStart < 0 {
            // If the requested date is before the schedule's reference start,
            // the first entry is the schedule's reference start itself.
             nextEntryDate = scheduleStartDate
        } else {
            // Calculate the number of full intervals that fit before or at `date`.
            let intervalsPassed = floor(timeSinceScheduleStart / actualInterval)
            // The last entry *before or at* `date` would be at this interval count.
            let lastEntryBeforeOrAtDate = scheduleStartDate.addingTimeInterval(intervalsPassed * actualInterval)

            // The next entry is one interval after that.
             nextEntryDate = lastEntryBeforeOrAtDate.addingTimeInterval(actualInterval)

             // Ensure the next entry is not *before* the requested `date`. If it is (due to floating point), advance one more interval.
             // A small tolerance helps here.
             if nextEntryDate.timeIntervalSince(date) < -1e-9 { // Use tolerance
                 nextEntryDate = nextEntryDate.addingTimeInterval(actualInterval)
             }

             // Handle the edge case where date *is* exactly scheduleStartDate
             if date == scheduleStartDate {
                nextEntryDate = scheduleStartDate
             }
        }
        // --- End Corrected Logic ---

        // The iterator starts from the calculated next entry date.
        return Entries(firstDate: nextEntryDate, interval: actualInterval)
    }


    /// The sequence of dates in periodic schedule.
    public struct Entries: Sequence, IteratorProtocol, Sendable {
        private var nextDate: Date
        private let interval: TimeInterval

        init(firstDate: Date, interval: TimeInterval) {
            self.nextDate = firstDate
            self.interval = interval
        }

        /// Advances to the next element and returns it, or `nil` if no next element exists.
        public mutating func next() -> Date? {
            let current = nextDate
            nextDate = nextDate.addingTimeInterval(interval)
            return current
        }
    }
}


// MARK: - EveryMinuteTimelineSchedule

/// A schedule for updating a timeline view at the start of every minute.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct EveryMinuteTimelineSchedule: TimelineSchedule, Sendable {

    /// Creates a per-minute update schedule.
    public init() {}

    /// Provides a sequence of per-minute dates starting from a given date.
    public func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
        // In low frequency mode, could potentially update less often (e.g., every 5 mins),
        // but the name implies every minute, so we stick to that unless specifically needed.
        let calendar = Calendar.current
        // Calculate the start of the minute containing startDate
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        components.second = 0
        components.nanosecond = 0 // Ensure it's exactly the start of the minute

        guard let startOfCurrentMinute = calendar.date(from: components) else {
            // Fallback: Start from the next full minute if calculation fails
            return Entries(nextDate: startDate.addingTimeInterval(60).advanced(by: -startDate.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)), interval: 60.0)
        }

        // Determine the first entry: If startDate is exactly on a minute, the first entry is that minute.
        // Otherwise, the first entry is the *start* of the *next* minute.
        let firstEntryDate: Date
        if startDate == startOfCurrentMinute {
             firstEntryDate = startOfCurrentMinute // Update immediately if exactly on the minute
        } else {
             firstEntryDate = startOfCurrentMinute.addingTimeInterval(60) // Update at the start of the next minute
        }


        return Entries(nextDate: firstEntryDate, interval: 60.0)
    }


    /// The sequence of dates in an every minute schedule.
    public struct Entries: Sequence, IteratorProtocol, Sendable {
        private var nextDate: Date
        private let interval: TimeInterval

        init(nextDate: Date, interval: TimeInterval) {
            self.nextDate = nextDate
            self.interval = interval
        }

        /// Advances to the next element and returns it, or `nil` if no next element exists.
        public mutating func next() -> Date? {
             let current = nextDate
             nextDate = nextDate.addingTimeInterval(interval)
             return current
        }
    }
}

// MARK: - ExplicitTimelineSchedule

/// A schedule for updating a timeline view at explicit points in time.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ExplicitTimelineSchedule<EntriesCollection>: TimelineSchedule where EntriesCollection: Sequence, EntriesCollection.Element == Date {

    private let dates: EntriesCollection
    // Store dates sorted to ensure correct behavior if the input sequence isn't guaranteed sorted.
    // If performance is critical and inputs are always sorted, could skip this.
    private let sortedDates: [Date]

    /// Creates a schedule composed of an explicit sequence of dates.
    /// - Parameter dates: The sequence of dates at which a timeline view updates.
    ///   The sequence will be sorted internally.
    public init(_ dates: EntriesCollection) {
        // Ensure dates are sorted for predictable filtering
        self.dates = dates // Keep original if needed, though not strictly required by protocol
        if let specificDates = dates as? [Date] {
             self.sortedDates = specificDates.sorted()
        } else {
            // Handle generic sequences - might be less efficient
            self.sortedDates = Array(dates).sorted()
        }
    }

    /// Provides the sequence of dates starting from the first date at or after the given start date.
    public func entries(from startDate: Date, mode: TimelineScheduleMode) -> [Date] {
       // Filter the sorted dates to return only those at or after the `startDate`.
       // In lowFrequency mode, we could potentially thin out the dates, but
       // the definition of "explicit" suggests using exactly the provided ones.
       sortedDates.filter { $0 >= startDate }
    }

    // Make the Entries type concrete for the implementation
    public typealias Entries = [Date] // Return a concrete Array for simplicity
}


// MARK: - TimelineSchedule Factory Methods REMOVED

// Removing the problematic extension factory methods.
// Use direct initializers: PeriodicTimelineSchedule(...), EveryMinuteTimelineSchedule(), ExplicitTimelineSchedule(...)


// MARK: - Example Usage (TimelineView - Requires SwiftUI)

// This part shows how the schedules might be *used* within SwiftUI's TimelineView.
// Running this requires a SwiftUI environment (e.g., Xcode project).

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct TimelineViewExample: View {
    let startDate = Date()

    // CORRECTED: Use direct initializers for the concrete types
    let periodicSchedule = PeriodicTimelineSchedule(from: .now, by: 5.0)

    let explicitDates = [
        Date().addingTimeInterval(10), // 10 seconds from now
        Date().addingTimeInterval(20), // 20 seconds from now
        Date().addingTimeInterval(30)  // 30 seconds from now
    ]
    // CORRECTED: Use direct initializer
    let explicitSchedule = ExplicitTimelineSchedule([Date()] + [Date().addingTimeInterval(5)]) // Example: update now and in 5s

    // CORRECTED: Use direct initializer
    let minuteSchedule = EveryMinuteTimelineSchedule()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text("Periodic Schedule (Every 5s)")
            // CORRECTED: Pass the initialized concrete type
            TimelineView(periodicSchedule) { context in
                // Display the date provided by the timeline's context
                Text("Periodic Update at: \(context.date.formatted(date: .omitted, time: .standard))")
            }
            .border(Color.green)
            .frame(height: 50)


            Text("Explicit Schedule (Now, +5s)")
            // CORRECTED: Pass the initialized concrete type
             TimelineView(explicitSchedule) { context in
                Text("Explicit Update: \(context.date.formatted(date: .omitted, time: .standard))")
            }
            .border(Color.red)
            .frame(height: 50)

            Text("Every Minute Schedule")
             // CORRECTED: Pass the initialized concrete type
            TimelineView(minuteSchedule) { context in
                 Text("Minute Update: \(context.date.formatted(date: .omitted, time: .standard))")
            }
           .border(Color.blue)
           .frame(height: 50)

            Spacer() // Add spacer to push content up
        }
        .padding()
    }
}


// MARK: - Preview (For Xcode Canvas)
#if compiler(>=5.9) // Use the #Preview macro if available
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
#Preview {
    TimelineViewExample()
}
#else // Fallback for older Xcode versions
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct TimelineViewExample_Previews: PreviewProvider {
    static var previews: some View {
        TimelineViewExample()
    }
}
#endif
