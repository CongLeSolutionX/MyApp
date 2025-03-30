//
//  TimelineViewExample.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI
import Combine
import Foundation

// MARK: - TimelineScheduleMode (Unchanged)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum TimelineScheduleMode: Sendable, Hashable, Equatable { case normal, lowFrequency }

// MARK: - TimelineSchedule Protocol (Reverted to Original Generic Form)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol TimelineSchedule { // <<< No Sendable here, no AnySequence default
    typealias Mode = TimelineScheduleMode
    // Associated type requires *some* Sequence of Dates
    associatedtype Entries: Sequence where Entries.Element == Date
    func entries(from startDate: Date, mode: Mode) -> Entries
}

// MARK: - PeriodicTimelineSchedule (Reverted to use own Iterator + Sendable)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct PeriodicTimelineSchedule: TimelineSchedule, Sendable { // <<< Conforms & is Sendable
    private let scheduleStartDate: Date
    private let interval: TimeInterval

    public init(from startDate: Date, by interval: TimeInterval) {
        precondition(interval > 0, "PeriodicTimelineSchedule interval must be positive.")
        self.scheduleStartDate = startDate
        self.interval = interval
    }

    // Defines its specific sequence type
    public struct PeriodicEntriesIterator: Sequence, IteratorProtocol, Sendable {
        public typealias Element = Date
        private var nextDate: Date
        private let interval: TimeInterval
        init(firstDate: Date, interval: TimeInterval) { self.nextDate = firstDate; self.interval = interval }
        public mutating func next() -> Date? {
            let current = nextDate; nextDate = nextDate.addingTimeInterval(interval); return current
        }
    }
    public typealias Entries = PeriodicEntriesIterator // Explicit typealias

    // Returns its specific sequence type
    public func entries(from date: Date, mode: Mode) -> Entries {
        let actualInterval = (mode == .lowFrequency) ? max(interval, 60.0) : interval
        let timeSinceScheduleStart = date.timeIntervalSince(scheduleStartDate)
        var firstEntryDate: Date // (Calculation logic as before...)
        if date < scheduleStartDate { firstEntryDate = scheduleStartDate } else {
            let intervalsPassed = floor(timeSinceScheduleStart / actualInterval)
            let currentIntervalStartDate = scheduleStartDate.addingTimeInterval(intervalsPassed * actualInterval)
            firstEntryDate = (abs(date.timeIntervalSince(currentIntervalStartDate)) < 1e-9) ? currentIntervalStartDate : currentIntervalStartDate.addingTimeInterval(actualInterval)
        }
        if firstEntryDate < date { firstEntryDate = firstEntryDate.addingTimeInterval(actualInterval) }
        return PeriodicEntriesIterator(firstDate: firstEntryDate, interval: actualInterval)
    }
}

// MARK: - EveryMinuteTimelineSchedule (Reverted to use own Iterator + Sendable)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct EveryMinuteTimelineSchedule: TimelineSchedule, Sendable { // <<< Conforms & is Sendable
    public init() {}

    public struct MinuteEntriesIterator: Sequence, IteratorProtocol, Sendable {
         public typealias Element = Date
         private var nextDate: Date
         private let interval: TimeInterval = 60.0
         init(firstDate: Date) { self.nextDate = firstDate }
         public mutating func next() -> Date? { let current = nextDate; nextDate = nextDate.addingTimeInterval(interval); return current }
    }
    public typealias Entries = MinuteEntriesIterator

    public func entries(from startDate: Date, mode: Mode) -> Entries {
        let calendar = Calendar.current // (Calculation logic as before...)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate); components.second = 0; components.nanosecond = 0
        guard let startOfCurrentMinute = calendar.date(from: components) else {
             let interval: TimeInterval = 60.0; let timeSinceEpoch = startDate.timeIntervalSinceReferenceDate; let intervalsSinceEpoch = floor(timeSinceEpoch / interval); let nextMinuteBoundary = Date(timeIntervalSinceReferenceDate: (intervalsSinceEpoch + 1) * interval); let fallbackFirstDate = max(nextMinuteBoundary, startDate)
             return MinuteEntriesIterator(firstDate: fallbackFirstDate)
         }
         let interval: TimeInterval = 60.0; let firstEntryDate = (abs(startDate.timeIntervalSince(startOfCurrentMinute)) < 1e-9) ? startOfCurrentMinute : startOfCurrentMinute.addingTimeInterval(interval)
         var actualFirstDate = max(firstEntryDate, startDate)
         if actualFirstDate == startDate && abs(startDate.timeIntervalSince(startOfCurrentMinute)) >= 1e-9 { actualFirstDate = startOfCurrentMinute.addingTimeInterval(interval) }
         return MinuteEntriesIterator(firstDate: actualFirstDate)
    }
}

// MARK: - ExplicitTimelineSchedule (Reverted + Sendable)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ExplicitTimelineSchedule<EntriesCollection>: TimelineSchedule, Sendable // <<< Conforms & is Sendable
    where EntriesCollection: Sequence & Sendable, EntriesCollection.Element == Date { // Require input sequence Sendable

    private let sortedDates: [Date] // Use Array<Date> which is Sequence & Sendable

    public init(_ dates: EntriesCollection) {
       // Ensure internal storage is Sendable ([Date])
       if let array = dates as? [Date] {
           self.sortedDates = array.sorted()
       } else {
           self.sortedDates = Array(dates).sorted()
       }
    }

    public typealias Entries = [Date] // Return concrete Array

    public func entries(from startDate: Date, mode: Mode) -> Entries {
        sortedDates.filter { $0 >= startDate }
    }
}


// MARK: - AnyTimelineSchedule Type Eraser
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnyTimelineSchedule: TimelineSchedule, Sendable { // <<< Conforms & is Sendable
    private let _entries: @Sendable (Date, Mode) -> AnySequence<Date>

    // Initializer takes ANY TimelineSchedule conforming type that is ALSO Sendable
    public init<S: TimelineSchedule & Sendable>(_ schedule: S) {
        self._entries = { startDate, mode in
            // Immediately type-erase the result of the underlying schedule's entries func
            AnySequence(schedule.entries(from: startDate, mode: mode))
        }
    }

    // The eraser ALWAYS provides AnySequence<Date>
    public typealias Entries = AnySequence<Date>

    public func entries(from startDate: Date, mode: Mode) -> Entries {
        self._entries(startDate, mode) // Execute the captured closure
    }
}


// MARK: - Example Usage (Using the Wrapper)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct TimelineViewExample: View {
    // Define concrete implementations (these are Sendable)
    let periodicScheduleImpl = PeriodicTimelineSchedule(from: .now, by: 5.0)
    let explicitScheduleImpl = ExplicitTimelineSchedule([Date(), Date().addingTimeInterval(5), Date().addingTimeInterval(10)])
    let minuteScheduleImpl = EveryMinuteTimelineSchedule()

    // *** Store type-erased versions for TimelineView ***
    let periodicSchedule: AnyTimelineSchedule
    let explicitSchedule: AnyTimelineSchedule
    let minuteSchedule: AnyTimelineSchedule

    // *** Initialize the wrappers ***
    init() {
        self.periodicSchedule = AnyTimelineSchedule(periodicScheduleImpl)
        self.explicitSchedule = AnyTimelineSchedule(explicitScheduleImpl)
        self.minuteSchedule = AnyTimelineSchedule(minuteScheduleImpl)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text("Periodic Schedule (Every 5s)")
            // *** Pass the WRAPPED schedule to TimelineView ***
            TimelineView(periodicSchedule) { context in
                Text("Periodic Update at: \(context.date.formatted(date: .omitted, time: .standard))")
            }
            .border(Color.green)
            .frame(height: 50)

            Text("Explicit Schedule (Now, +5s, +10s)")
             // *** Pass the WRAPPED schedule to TimelineView ***
             TimelineView(explicitSchedule) { context in
                Text("Explicit Update: \(context.date.formatted(date: .omitted, time: .standard))")
            }
            .border(Color.red)
            .frame(height: 50)

            Text("Every Minute Schedule")
            // *** Pass the WRAPPED schedule to TimelineView ***
            TimelineView(minuteSchedule) { context in
                 Text("Minute Update: \(context.date.formatted(date: .omitted, time: .standard))")
            }
           .border(Color.blue)
           .frame(height: 50)

            Spacer()
        }
        .padding()
    }
}


// MARK: - Preview (Unchanged)
#if compiler(>=5.9)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
#Preview { TimelineViewExample() }
#else
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct TimelineViewExample_Previews: PreviewProvider { static var previews: some View { TimelineViewExample() } }
#endif
