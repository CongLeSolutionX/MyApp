//
//  EventKitManagemenView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI
@preconcurrency import EventKit
import Combine // Though not strictly needed with @Observable, good practice context

// MARK: - Important Setup Note

/*
 * Before running this code, you MUST configure your Info.plist:
 *
 * 1. Privacy - Calendars Full Access Usage Description (NSCalendarsFullAccessUsageDescription)
 *    Value: "This app needs access to your calendars to manage events." (or your custom message)
 *
 * 2. Privacy - Reminders Full Access Usage Description (NSRemindersFullAccessUsageDescription)
 *    Value: "This app needs access to your reminders to manage tasks." (or your custom message)
 *
 * Note: The original article correctly states that for iOS 17+, NSCalendarsWriteOnlyAccessUsageDescription
 * and NSCalendarsFullAccessUsageDescription replace the older keys.
 * NSRemindersFullAccessUsageDescription is used for reminders.
 * If supporting older OS versions (pre-iOS 17), refer to Apple's documentation for legacy keys.
 */

// MARK: - EventManager Error Handling

/// Enumerates potential errors during EventKit operations.
enum EventManagerError: Error, LocalizedError, Identifiable {
    case accessDenied(EKEntityType)
    case accessRestricted(EKEntityType)
    case accessInsufficient(EKEntityType) // For write-only when full needed
    case requestAccessError(String, EKEntityType)
    case saveEventError(String)
    case saveReminderError(String)
    case removeEventError(String)
    case removeReminderError(String)
    case fetchEventError(String)
    case fetchReminderError(String)
    case dateCalculationError(String)
    case unknown(String = "An unknown error occurred.")

    var id: String { localizedDescription }

    var errorDescription: String? {
        switch self {
        case .accessDenied(let entity):
            return "Access Denied: Permission to access \(entity.displayName) was denied. Please grant access in Settings."
        case .accessRestricted(let entity):
            return "Access Restricted: Access to \(entity.displayName) is restricted, possibly due to parental controls."
        case .accessInsufficient(let entity):
            return "Access Insufficient: Full access to \(entity.displayName) is required, but only write-only access was granted."
        case .requestAccessError(let message, let entity):
            return "Request Access Error (\(entity.displayName)): \(message)"
        case .saveEventError(let message):
            return "Save Event Error: \(message)"
        case .saveReminderError(let message):
            return "Save Reminder Error: \(message)"
        case .removeEventError(let message):
            return "Remove Event Error: \(message)"
        case .removeReminderError(let message):
            return "Remove Reminder Error: \(message)"
        case .fetchEventError(let message):
            return "Fetch Event Error: \(message)"
        case .fetchReminderError(let message):
            return "Fetch Reminder Error: \(message)"
        case .dateCalculationError(let message):
             return "Date Calculation Error: \(message)"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Event Manager Core Logic

@Observable
@MainActor // Ensures UI-related updates happen on the main thread
final class EventManager {
    // --- State Properties ---
    var currentError: EventManagerError? // Renamed for clarity vs. article's 'error'
    var eventsAuthorized: Bool = false
    var remindersAuthorized: Bool = false

    var events: [EKEvent] = []
    var eventFetchStartDate = Date().addingTimeInterval(-7 * 60 * 60 * 24) // Default: last 7 days
    var eventFetchEndDate = Date() // Default: today
    var selectedEvent: EKEvent? // For potential detail view or editing

    var reminders: [EKReminder] = []
    var selectedReminder: EKReminder? // For potential detail view or editing

    var eventCalendars: [EKCalendar] = []
    var reminderCalendars: [EKCalendar] = []

    // --- Private Properties ---
    let eventStore = EKEventStore()
    private var isListening = false // To prevent multiple listener setups

    // --- Computed Properties ---
    var incompleteReminders: [EKReminder] {
        reminders.filter { !$0.isCompleted }.sortedByAscendingDueDate
    }
    var completedReminders: [EKReminder] {
        reminders.filter { $0.isCompleted }.sortedByAscendingDueDate // Sort completed too if needed
    }

    // Group calendars by type (Local, iCloud, Exchange, etc.)
    var eventCalendarsByType: [EKCalendarType: [EKCalendar]] {
        Dictionary(grouping: eventCalendars, by: { $0.type })
    }
    var reminderCalendarsByType: [EKCalendarType: [EKCalendar]] {
        Dictionary(grouping: reminderCalendars, by: { $0.type })
    }

    // --- Initialization ---
    init() {
        // Asynchronously check initial permissions and load data
        Task {
            await checkInitialPermissions()
            await reloadCalendars() // Fetch calendars after permissions known
            await reloadEvents() // Fetch initial events
            await reloadReminders() // Fetch initial reminders
            await listenToEventStoreChanges() // Start listening for external changes
        }
    }

    // MARK: - Authorization Management
    private func checkInitialPermissions() async {
        eventsAuthorized = await checkAuthorizationStatus(for: .event)
        remindersAuthorized = await checkAuthorizationStatus(for: .reminder)
    }

    /// Requests full access if status is .notDetermined, otherwise updates status.
    func requestFullAccessIfNeeded(for entityType: EKEntityType) async -> Bool {
        let status = EKEventStore.authorizationStatus(for: entityType)
        currentError = nil // Clear previous error

        switch status {
        case .notDetermined:
            print("Requesting full access for \(entityType.displayName)...")
            var granted = false
            do {
                if entityType == .event {
                    // Use the requestFullAccessToEvents (available iOS 17+)
                    if #available(iOS 17.0, *) {
                        granted = try await eventStore.requestFullAccessToEvents()
                    } else {
                        // Fallback or alternative handling for older versions if needed
                        granted = try await eventStore.requestAccess(to: .event) // Older general request
                         if granted {
                            // Re-check status after granting general access on older OS
                            // Full access might not be guaranteed here depending on OS/context
                            granted = EKEventStore.authorizationStatus(for: .event) == .fullAccess
                        }
                    }
                } else { // .reminder
                    // Use the requestFullAccessToReminders (available iOS 17+)
                     if #available(iOS 17.0, *) {
                        granted = try await eventStore.requestFullAccessToReminders()
                    } else {
                        // Fallback or alternative handling for older versions if needed
                        granted = try await eventStore.requestAccess(to: .reminder) // Older general request
                         if granted {
                            // Re-check status after granting general access on older OS
                            granted = EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
                        }
                    }
                }

                if granted {
                    print("Full access granted for \(entityType.displayName).")
                    updateAuthorizationStatus(for: entityType, authorized: true)
                    await reloadCalendars(for: entityType) // Reload calendars after permission change
                    return true
                } else {
                    print("Full access denied for \(entityType.displayName).")
                    updateAuthorizationStatus(for: entityType, authorized: false)
                    currentError = .accessDenied(entityType) // Explicitly denied by user
                    return false
                }
            } catch {
                print("Error requesting access to \(entityType.displayName): \(error.localizedDescription)")
                updateAuthorizationStatus(for: entityType, authorized: false)
                currentError = .requestAccessError(error.localizedDescription, entityType)
                return false
            }

        case .restricted:
            print("Access restricted for \(entityType.displayName).")
            updateAuthorizationStatus(for: entityType, authorized: false)
            currentError = .accessRestricted(entityType)
            return false

        case .denied:
            print("Access denied for \(entityType.displayName).")
            updateAuthorizationStatus(for: entityType, authorized: false)
            currentError = .accessDenied(entityType)
            return false

        case .fullAccess:
            print("Full access already granted for \(entityType.displayName).")
            updateAuthorizationStatus(for: entityType, authorized: true)
            return true

        case .writeOnly: // Applicable primarily to Events pre-iOS 17, treat as insufficient for full access needs
             if #available(iOS 17.0, *) {
                 // On iOS 17+, writeOnly shouldn't typically occur if requesting full. If it does, treat as insufficient.
                 print("Write-only access granted for \(entityType.displayName), but full access required.")
                 updateAuthorizationStatus(for: entityType, authorized: false) // Treat as not authorized for full operations
                 currentError = .accessInsufficient(entityType)
                 return false
             } else {
                 // On older OS, write-only might be the granted status. Treat based on need.
                 print("Write-only access granted for \(entityType.displayName). May be insufficient.")
                 // Decide if writeOnly is acceptable for your specific use case on older OS
                 let sufficientForNeeds = false // Assume full access is needed
                 updateAuthorizationStatus(for: entityType, authorized: sufficientForNeeds)
                 if !sufficientForNeeds {
                    currentError = .accessInsufficient(entityType)
                 }
                 return sufficientForNeeds
             }

        @unknown default:
            print("Unknown authorization status for \(entityType.displayName).")
            updateAuthorizationStatus(for: entityType, authorized: false)
            currentError = .unknown("Unknown authorization status: \(status.rawValue)")
            return false
        }
    }

    /// Checks current status without requesting. Used for initial checks or refreshes.
    private func checkAuthorizationStatus(for entityType: EKEntityType) async -> Bool {
        let status = EKEventStore.authorizationStatus(for: entityType)
        return status == .fullAccess // Consider full access as authorized for this manager's scope
                                      // Adapt if write-only is sometimes acceptable
    }

    /// Helper to update the corresponding boolean flag.
    private func updateAuthorizationStatus(for entityType: EKEntityType, authorized: Bool) {
        if entityType == .event {
            self.eventsAuthorized = authorized
        } else {
            self.remindersAuthorized = authorized
        }
    }

    // MARK: - Calendar Fetching
    func reloadCalendars(for entityType: EKEntityType? = nil) async {
       currentError = nil
       if entityType == .event || entityType == nil {
            guard await requestFullAccessIfNeeded(for: .event) else {
                self.eventCalendars = [] // Clear if not authorized
                return
            }
            self.eventCalendars = fetchCalendars(for: .event).filter { $0.allowsContentModifications }
            print("Fetched \(self.eventCalendars.count) modifiable event calendars.")
       }

       if entityType == .reminder || entityType == nil {
            guard await requestFullAccessIfNeeded(for: .reminder) else {
                self.reminderCalendars = [] // Clear if not authorized
                return
            }
            self.reminderCalendars = fetchCalendars(for: .reminder).filter { $0.allowsContentModifications }
             print("Fetched \(self.reminderCalendars.count) modifiable reminder calendars.")
       }
    }

    private func fetchCalendars(for entityType: EKEntityType) -> [EKCalendar] {
       return self.eventStore.calendars(for: entityType)
    }

    // MARK: - Event CRUD Operations

    /// Fetches events within the specified date range from authorized calendars.
    func reloadEvents() async {
        guard await requestFullAccessIfNeeded(for: .event) else {
            self.events = [] // Clear events if not authorized
            return
        }
        currentError = nil // Clear previous error

        guard let rangeEnd = eventFetchEndDate.endOfDay else {
            currentError = .dateCalculationError("Could not calculate end of day for date: \(eventFetchEndDate)")
            self.events = []
            return
        }
        let rangeStart = eventFetchStartDate.startOfDay

        // Ensure calendars are loaded
        if self.eventCalendars.isEmpty {
            await reloadCalendars(for: .event)
            // Check again if calendars loaded successfully
            guard !self.eventCalendars.isEmpty else {
                 print("Cannot fetch events: No modifiable event calendars found or accessible.")
                 // Optionally set an error or just return empty
                 self.events = []
                 // If you want to show an error:
                 // currentError = .fetchEventError("No modifiable event calendars available.")
                 return
            }
        }

        let predicate = eventStore.predicateForEvents(withStart: rangeStart, end: rangeEnd, calendars: self.eventCalendars)
        let fetchedEvents = eventStore.events(matching: predicate).sortedByAscendingDate

        self.events = fetchedEvents // Update the @Observable property
        print("Fetched \(self.events.count) events from \(rangeStart.formatted(date: .abbreviated, time: .shortened)) to \(rangeEnd.formatted(date: .abbreviated, time: .shortened)).")

        // Update selectedEvent reference if it still exists in the fetched list
        if let selectedId = selectedEvent?.eventIdentifier,
           let updatedSelected = fetchedEvents.first(where: { $0.eventIdentifier == selectedId }) {
            selectedEvent = updatedSelected
        } else {
            selectedEvent = nil // Deselect if the event is no longer in the fetched range/list
        }
    }

    /// Creates and saves a new event.
    func createNewEvent(
        title: String,
        notes: String?,
        start: Date,
        end: Date,
        isAllDay: Bool,
        calendar: EKCalendar?, // Make optional, default to default calendar
        alarmOffset: TimeInterval?,
        recurrenceRule: EKRecurrenceRule? // Pass the rule directly
    ) async {
        guard let targetCalendar = calendar ?? eventStore.defaultCalendarForNewEvents else {
            currentError = .saveEventError("No default calendar available or specified.")
            return
        }

        guard await requestFullAccessIfNeeded(for: .event) else { return }
        currentError = nil

        let newEvent = EKEvent(eventStore: self.eventStore)
        newEvent.title = title
        newEvent.notes = notes
        newEvent.calendar = targetCalendar
        newEvent.isAllDay = isAllDay
        newEvent.startDate = start
        // Ensure end date is valid, especially for all-day events
        newEvent.endDate = (isAllDay ? start.endOfDay : end) ?? end

        if let alarmOffset = alarmOffset {
            newEvent.addAlarm(EKAlarm(relativeOffset: alarmOffset))
        }

        if let recurrenceRule = recurrenceRule {
            newEvent.addRecurrenceRule(recurrenceRule)
        }

        await saveEvent(newEvent, span: .futureEvents) // Use EKSpan.futureEvents for new potentially recurring events
        await reloadEvents() // Refresh the list after adding
    }

    /// Saves an existing or new event.
    func saveEvent(_ event: EKEvent, span: EKSpan) async {
        guard await requestFullAccessIfNeeded(for: .event) else { return }
        currentError = nil

        do {
            try self.eventStore.save(event, span: span, commit: true)
            print("Event '\(event.title ?? "Untitled")' saved successfully.")
            // No need to reload here if createNewEvent calls it, but might be needed if called standalone
        } catch {
            print("Error saving event '\(event.title ?? "Untitled")': \(error.localizedDescription)")
            currentError = .saveEventError("Error saving event: \(error.localizedDescription)")
        }
    }

    /// Removes one or more events.
    func removeEvents(_ eventsToRemove: [(event: EKEvent, span: EKSpan)]) async {
        guard await requestFullAccessIfNeeded(for: .event) else { return }
        guard !eventsToRemove.isEmpty else { return }
        currentError = nil

        do {
            // Batch remove using commit:false then one commit:true
            for item in eventsToRemove {
                try self.eventStore.remove(item.event, span: item.span, commit: false)
                print("Marked event '\(item.event.title ?? "Untitled")' for removal (span: \(item.span)).")
            }
            try self.eventStore.commit()
            print("Committed removals for \(eventsToRemove.count) event(s).")
            await reloadEvents() // Refresh list after removing
        } catch {
            print("Error removing events: \(error.localizedDescription)")
            currentError = .removeEventError("Error removing events: \(error.localizedDescription)")
        }
    }

    // MARK: - Reminder CRUD Operations

    /// Fetches all reminders from authorized calendars.
    func reloadReminders() async {
        guard await requestFullAccessIfNeeded(for: .reminder) else {
            self.reminders = [] // Clear reminders if not authorized
            return
        }
        currentError = nil

        // Ensure calendars are loaded
        if self.reminderCalendars.isEmpty {
            await reloadCalendars(for: .reminder)
             // Check again if calendars loaded successfully
            guard !self.reminderCalendars.isEmpty else {
                 print("Cannot fetch reminders: No modifiable reminder calendars found or accessible.")
                 self.reminders = []
                 // currentError = .fetchReminderError("No modifiable reminder calendars available.") // Optional error
                 return
            }
        }

        // Fetch *all* reminders from the specified calendars
        let predicate = eventStore.predicateForReminders(in: self.reminderCalendars)

        do {
            // EventKit's fetchReminders is async with a completion handler.
            // We bridge it to modern Swift concurrency using withCheckedContinuation.
            let fetchedReminders: [EKReminder] = try await withCheckedThrowingContinuation { continuation in
                eventStore.fetchReminders(matching: predicate) { fetched in
                    // The fetch can return nil, so handle that case.
                    if let reminders = fetched {
                        continuation.resume(returning: reminders)
                    } else {
                        // Treat nil result as an error or an empty list?
                        // Let's return an empty list for safety, but could throw.
                         print("fetchReminders returned nil, returning empty array.")
                         continuation.resume(returning: [])
                        // Or to throw: continuation.resume(throwing: EventManagerError.fetchReminderError("fetchReminders returned nil"))
                    }
                 }
                 // Note: Cancellation handling might be needed for robust apps.
                 // If the Task containing this continuation is cancelled, EKEventStore
                 // doesn't have a direct way to cancel the fetchReminders request.
            }

            self.reminders = fetchedReminders // Update @Observable property
             print("Fetched \(self.reminders.count) reminders.")

             // Update selectedReminder reference
            if let selectedId = selectedReminder?.calendarItemIdentifier,
               let updatedSelected = fetchedReminders.first(where: { $0.calendarItemIdentifier == selectedId }) {
                selectedReminder = updatedSelected
            } else {
                selectedReminder = nil
            }

        } catch {
            print("Error fetching reminders: \(error.localizedDescription)")
            currentError = .fetchReminderError("Failed to fetch reminders: \(error.localizedDescription)")
            self.reminders = [] // Clear on error
        }
    }

    /// Creates and saves a new reminder.
    func createNewReminder(
        title: String,
        notes: String?,
        startDateComponents: DateComponents?,
        dueDateComponents: DateComponents?,
        priority: Int, // 0-9 (0 is default/none)
        calendar: EKCalendar?, // Make optional, default to default
        alarmOffset: TimeInterval?,
        recurrenceRule: EKRecurrenceRule? // Pass the rule directly
    ) async {
        // Reminders require a calendar. Use default if none provided.
        guard let targetCalendar = calendar ?? eventStore.defaultCalendarForNewReminders() else {
            currentError = .saveReminderError("No default reminder calendar available or specified.")
            return
        }

        guard await requestFullAccessIfNeeded(for: .reminder) else { return }
        currentError = nil

        let newReminder = EKReminder(eventStore: eventStore)
        newReminder.title = title // Required
        newReminder.calendar = targetCalendar // Required
        newReminder.notes = notes
        newReminder.startDateComponents = startDateComponents
        newReminder.dueDateComponents = dueDateComponents
        newReminder.priority = min(max(priority, 0), 9) // Clamp priority 0-9

        if let alarmOffset = alarmOffset {
            newReminder.addAlarm(EKAlarm(relativeOffset: alarmOffset))
        }

        if let recurrenceRule = recurrenceRule {
            // Handle the potential issue with setting recurrence on reminders
            // as discussed in the article. Cloning might fail if due date < end date.
            // Consider adding logic here or documenting the limitation.
            print("Warning: Setting recurrence rules on reminders can sometimes cause issues when completing them if the due date is before the recurrence end date.")
            newReminder.addRecurrenceRule(recurrenceRule)
        }

        await saveReminder(newReminder)
        await reloadReminders() // Refresh list
    }

    /// Toggles the completion status of a reminder.
    func toggleReminderCompletion(_ reminder: EKReminder) async {
        guard await requestFullAccessIfNeeded(for: .reminder) else { return }
        currentError = nil

        // Create a mutable copy if needed or ensure the reminder object is correctly referenced
        // Depending on how reminders are passed (value vs reference semantics influence)
        // In this @Observable setup, modifying the object in the `reminders` array should be fine.
        reminder.isCompleted.toggle() // This automatically handles completionDate

        // --- Addressing the Recurrence Issue ---
        // As noted in the article, completing a recurring reminder where the next occurrence's
        // calculated due date is *before* the recurrence end date can cause console warnings
        // ("unable to clone recurrent reminder..."). The completion still works, but it's noisy.
        // A potential workaround (though complex) could involve:
        // 1. Before saving, check if it's recurring and being marked complete.
        // 2. If so, temporarily remove the recurrence rule.
        // 3. Save the reminder (now non-recurring).
        // 4. Manually calculate the *next* occurrence based on the *original* rule.
        // 5. Create a *new* reminder for the next occurrence, copying details and applying the original rule.
        // This mirrors how the system *tries* to behave but avoids the problematic internal clone.
        // --- End Recurrence Issue Handling ---
        // For simplicity here, we proceed without the complex workaround.
        print("Toggling reminder '\(reminder.title ?? "")' to completed: \(reminder.isCompleted)")

        await saveReminder(reminder)
        // No full reload needed usually, as the UI can update based on the changed reminder object
        // However, if filtering/sorting relies on fetched state, a reload might be safer.
        // Let's reload for consistency in this example:
        await reloadReminders()
    }

    /// Saves an existing or new reminder.
    func saveReminder(_ reminder: EKReminder) async {
        guard await requestFullAccessIfNeeded(for: .reminder) else { return }
        currentError = nil

        do {
            try self.eventStore.save(reminder, commit: true)
            print("Reminder '\(reminder.title ?? "Untitled")' saved successfully.")
        } catch {
            print("Error saving reminder '\(reminder.title ?? "Untitled")': \(error.localizedDescription)")
            currentError = .saveReminderError("Error saving reminder: \(error.localizedDescription)")
        }
    }

    /// Removes one or more reminders.
    func removeReminders(_ remindersToRemove: [EKReminder]) async {
        guard await requestFullAccessIfNeeded(for: .reminder) else { return }
        guard !remindersToRemove.isEmpty else { return }
        currentError = nil

        do {
            // Batch remove
            for reminder in remindersToRemove {
                try self.eventStore.remove(reminder, commit: false)
                print("Marked reminder '\(reminder.title ?? "Untitled")' for removal.")
            }
            try self.eventStore.commit()
            print("Committed removals for \(remindersToRemove.count) reminder(s).")
            await reloadReminders() // Refresh list
        } catch {
            print("Error removing reminders: \(error.localizedDescription)")
            currentError = .removeReminderError("Error removing reminders: \(error.localizedDescription)")
        }
    }

    // MARK: - Event Store Change Listener
    private func listenToEventStoreChanges() async {
        guard !isListening else { return } // Don't start multiple listeners
        isListening = true
        print("Starting to listen for EventKit store changes...")

        // Use NotificationCenter's async sequence API
        let notifications = NotificationCenter.default.notifications(named: .EKEventStoreChanged, object: eventStore)

        // Run the listener in a detached task so it doesn't block init
         Task.detached { [weak self] in
             for await notification in notifications {
                guard let self = self else {
                    print("EventManager deallocated, stopping listener.")
                    return
                }
                print("Received EKEventStoreChanged notification.")

                // Perform checks and reloads back on the main actor
                await MainActor.run {
                    // Check user info keys (BE CAUTIOUS as article notes, keys aren't guaranteed API)
                    // A safer approach is often to just reload both if *any* change occurs.
                    let userInfo = notification.userInfo
                    var needsEventReload = false
                    var needsReminderReload = false

                    // Example using potentially unstable keys (use with caution)
                    if let eventChanged = userInfo?["EKEventStoreCalendarDataChangedUserInfoKey"] as? Bool, eventChanged {
                        print("Change detected in Event data.")
                        needsEventReload = true
                    }
                     if let reminderChanged = userInfo?["EKEventStoreRemindersDataChangedUserInfoKey"] as? Bool, reminderChanged {
                        print("Change detected in Reminder data.")
                        needsReminderReload = true
                    }
                    // --- Safer approach: Assume any notification means potential change ---
                    // needsEventReload = true
                    // needsReminderReload = true
                    // --- End Safer Approach ---

                    // Check permissions again before reloading, as they might have changed externally
                    Task { // Run permission checks and reloads concurrently
                         if needsEventReload {
                             print("Checking event permissions and reloading events...")
                             if await self.checkAuthorizationStatus(for: .event) {
                                 self.eventsAuthorized = true
                                 await self.reloadEvents()
                             } else {
                                 self.eventsAuthorized = false
                                 self.events = [] // Clear data if no longer authorized
                             }
                         }
                         if needsReminderReload {
                            print("Checking reminder permissions and reloading reminders...")
                             if await self.checkAuthorizationStatus(for: .reminder) {
                                 self.remindersAuthorized = true
                                 await self.reloadReminders()
                             } else {
                                 self.remindersAuthorized = false
                                 self.reminders = [] // Clear data if no longer authorized
                             }
                         }
                    }
                }
            }
             // If the loop finishes (e.g., Task cancelled), mark as not listening
             await MainActor.run { [weak self] in
                 self?.isListening = false
                 print("EventKit listener loop finished.")
             }
         }
    }
}

// MARK: - EKEntityType Display Name Helper
extension EKEntityType {
    var displayName: String {
        switch self {
        case .event: return "Calendars"
        case .reminder: return "Reminders"
        @unknown default: return "Unknown Type"
        }
    }
}

// MARK: - Array Sorting Extensions (from Article)
extension Array where Element == EKEvent {
    var sortedByAscendingDate: [EKEvent] {
        self.sorted { $0.compareStartDate(with: $1) == .orderedAscending }
    }
}

extension Array where Element == EKReminder {
    // Sorts by due date, placing reminders without a due date last.
    var sortedByAscendingDueDate: [EKReminder] {
        self.sorted { (first, second) -> Bool in
            guard let firstDueDate = first.dueDateComponents?.date else {
                return false // first has no due date, comes after second
            }
            guard let secondDueDate = second.dueDateComponents?.date else {
                return true // second has no due date, first comes before second
            }
            return firstDueDate < secondDueDate
        }
    }
}

// MARK: - Date Helper Extensions (for start/endOfDay)
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }
}

// MARK: - SwiftUI View

struct EventKitManagemenView: View {
    @State private var eventManager = EventManager()
    @State private var showingEventSheet = false
    @State private var showingReminderSheet = false
    @State private var showErrorAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: Status & Permissions
                Section("Status & Permissions") {
                    HStack {
                        Text("Calendar Access:")
                        Spacer()
                        Text(eventManager.eventsAuthorized ? "Authorized" : "Not Authorized")
                            .foregroundStyle(eventManager.eventsAuthorized ? .green : .red)
                    }
                    HStack {
                        Text("Reminder Access:")
                        Spacer()
                        Text(eventManager.remindersAuthorized ? "Authorized" : "Not Authorized")
                            .foregroundStyle(eventManager.remindersAuthorized ? .green : .red)
                    }

                    // Buttons to explicitly request permissions if needed
                    if !eventManager.eventsAuthorized {
                        Button("Request Calendar Access") {
                            Task { await eventManager.requestFullAccessIfNeeded(for: .event) }
                        }
                    }
                    if !eventManager.remindersAuthorized {
                        Button("Request Reminder Access") {
                            Task { await eventManager.requestFullAccessIfNeeded(for: .reminder) }
                        }
                    }
                }

                // MARK: Events Section
                Section("Calendar Events") {
                    // Button to Add New Event
                    Button {
                         showingEventSheet = true
                    } label: {
                         Label("Add New Event", systemImage: "calendar.badge.plus")
                    }
                    .disabled(!eventManager.eventsAuthorized || eventManager.eventCalendars.isEmpty)

                     // Date Range (Example, not fully interactive)
                    HStack {
                         Text("Showing:")
                         Spacer()
                         Text("\(eventManager.eventFetchStartDate.formatted(date: .abbreviated, time: .omitted)) - \(eventManager.eventFetchEndDate.formatted(date: .abbreviated, time: .omitted))")
                    }

                    if eventManager.events.isEmpty && eventManager.eventsAuthorized {
                        Text("No events found in the selected range.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(eventManager.events) { event in
                            EventRow(event: event) {
                                // Delete action
                                Task {
                                    await eventManager.removeEvents([(event: event, span: .thisEvent)]) // Or .futureEvents
                                }
                            }
                        }
                    }
                }

                // MARK: Reminders Section
                Section("Reminders") {
                     // Button to Add New Reminder
                     Button {
                         showingReminderSheet = true
                     } label: {
                         Label("Add New Reminder", systemImage: "list.bullet.clipboard")
                     }
                    .disabled(!eventManager.remindersAuthorized || eventManager.reminderCalendars.isEmpty)

                    if !eventManager.incompleteReminders.isEmpty {
                        // Display Incomplete Reminders
                        ForEach(eventManager.incompleteReminders) { reminder in
                            ReminderRow(reminder: reminder) {
                                // Toggle completion action
                                Task {
                                    await eventManager.toggleReminderCompletion(reminder)
                                }
                            } deleteAction: {
                                // Delete action
                                Task { await eventManager.removeReminders([reminder]) }
                            }
                        }
                    } else if !eventManager.remindersAuthorized {
                         Text("Reminders access not granted.")
                            .foregroundColor(.secondary)
                    } else {
                        Text("No incomplete reminders.")
                            .foregroundColor(.secondary)
                    }

                    // Optionally display completed reminders
                     DisclosureGroup("Completed Reminders (\(eventManager.completedReminders.count))") {
                         if !eventManager.completedReminders.isEmpty {
                             ForEach(eventManager.completedReminders) { reminder in
                                 ReminderRow(reminder: reminder) {
                                     Task { await eventManager.toggleReminderCompletion(reminder) }
                                 } deleteAction: {
                                      Task { await eventManager.removeReminders([reminder]) }
                                 }
                             }
                         } else {
                             Text("No completed reminders.")
                                 .font(.caption)
                                 .foregroundColor(.secondary)
                         }
                     }
                }
            }
            .navigationTitle("EventKit Manager")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await eventManager.reloadEvents()
                            await eventManager.reloadReminders()
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
             // --- Error Handling Alert ---
             .onChange(of: eventManager.currentError) { _, newValue in
                 if newValue != nil {
                     showErrorAlert = true
                 }
             }
             .alert(isPresented: $showErrorAlert, error: eventManager.currentError) { _ in
                 // Default OK button is fine
             } message: { error in
                 Text(error.errorDescription ?? "An unknown error occurred.")
             }
             // --- Sheets for Adding Items ---
            .sheet(isPresented: $showingEventSheet) {
                 // Placeholder - Replace with actual Add Event form
                 AddEventView(eventManager: eventManager)
            }
            .sheet(isPresented: $showingReminderSheet) {
                 // Placeholder - Replace with actual Add Reminder form
                 AddReminderView(eventManager: eventManager)
            }
        }
    }
}

// MARK: - Row Views (Simplified Representations)

struct EventRow: View, Identifiable {
    var id: ObjectIdentifier
    
    let event: EKEvent
    var deleteAction: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.title ?? "No Title")
                    .font(.headline)
                Text(event.calendar.title)
                     .font(.caption)
                     .foregroundColor(Color(cgColor: event.calendar.cgColor))
                HStack {
                    // Display start and end dates/times
                    Text(event.startDate, style: event.isAllDay ? .date : .date)
                    if !event.isAllDay && event.endDate != event.startDate {
                        Text("-")
                         Text(event.endDate, style: .time) // Show end time if different
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)

                 // Show recurrence icon if applicable
                 if event.hasRecurrenceRules {
                     Image(systemName: "repeat")
                         .font(.caption)
                         .foregroundColor(.blue)
                 }
            }
            Spacer()
        }
        .swipeActions {
            Button(role: .destructive) {
                 deleteAction()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct ReminderRow: View {
    let reminder: EKReminder
    var toggleAction: () -> Void
    var deleteAction: () -> Void

    var body: some View {
        HStack {
             // Completion Toggle Button
             Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(reminder.isCompleted ? .green : .gray)
                .onTapGesture {
                    toggleAction()
                }

            VStack(alignment: .leading) {
                Text(reminder.title ?? "No Title")
                    .strikethrough(reminder.isCompleted, color: .secondary) // Strikethrough if completed
                    .foregroundStyle(reminder.isCompleted ? .secondary : .primary )

                // Show due date if available
                if let dueDate = reminder.dueDateComponents?.date {
                    Text("Due: \(dueDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                 // Show recurrence icon if applicable
                 if reminder.hasRecurrenceRules {
                     Image(systemName: "repeat")
                         .font(.caption)
                         .foregroundColor(.blue)
                 }
            }

            Spacer()
            // Display Priority if set (1-9)
            if reminder.priority > 0 {
                Text("P\(reminder.priority)")
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .background(priorityColor(reminder.priority))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
            }

             // Display Calendar Source
             Text(reminder.calendar.title)
                 .font(.caption2)
                 .foregroundColor(Color(cgColor: reminder.calendar.cgColor))

        }
         .contentShape(Rectangle()) // Ensure Hstack is tappable for toggle if needed elsewhere
         .swipeActions {
            Button(role: .destructive) {
                 deleteAction()
            } label: {
                Label("Delete", systemImage: "trash")
            }
         }
    }

    // Helper for priority color
    func priorityColor(_ priority: Int) -> Color {
        switch priority {
        case 1...4: return .orange // High
        case 5: return .yellow // Medium
        case 6...9: return .blue // Low
        default: return .gray
        }
    }
}

// MARK: - Placeholder Add Views (Replace with real forms)

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var eventManager: EventManager // Use @Bindable for @Observable

    // Form State
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // 1 hour later
    @State private var isAllDay = false
    @State private var selectedCalendar: EKCalendar? // Needs initialization

    var body: some View {
        NavigationView {
            Form {
                 // Calendar Picker
                 Picker("Calendar", selection: $selectedCalendar) {
                     // Ensure eventCalendars is not empty before accessing
                     if !eventManager.eventCalendars.isEmpty {
                         ForEach(eventManager.eventCalendars) { calendar in
                             HStack {
                                 Image(systemName: "circle.fill")
                                     .foregroundColor(Color(cgColor: calendar.cgColor))
                                 Text(calendar.title).tag(calendar as EKCalendar?) // Tag must match selection type
                             }
                         }
                     } else {
                         Text("No calendars available").tag(nil as EKCalendar?)
                     }
                 }
                 // Initialize selectedCalendar if possible
                 .onAppear {
                    if selectedCalendar == nil {
                        selectedCalendar = eventManager.eventCalendars.first ?? eventManager.eventStore.defaultCalendarForNewEvents
                    }
                 }

                TextField("Title", text: $title)
                TextField("Notes (Optional)", text: $notes, axis: .vertical)

                Toggle("All-day", isOn: $isAllDay)

                DatePicker("Start Date", selection: $startDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                if !isAllDay {
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                }

                // Add controls for Alarms and Recurrence if needed
            }
            .navigationTitle("Add New Event")
            .navigationBarItems(leading: Button("Cancel") { dismiss() },
                                trailing: Button("Save") { saveEvent() }.disabled(title.isEmpty || selectedCalendar == nil))
        }
    }

    func saveEvent() {
        guard let calendar = selectedCalendar else { return }
        Task {
           await eventManager.createNewEvent(
                title: title,
                notes: notes.isEmpty ? nil : notes,
                start: startDate,
                end: endDate,
                isAllDay: isAllDay,
                calendar: calendar,
                alarmOffset: nil, // Add UI for this
                recurrenceRule: nil // Add UI for this
            )
            if eventManager.currentError == nil { // Dismiss only if save succeeded (or no error was set)
                dismiss()
            }
        }
    }
}

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var eventManager: EventManager

     // Form State
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate = Date()
    @State private var priority: Int = 0 // 0 = None
    @State private var selectedCalendar: EKCalendar? // Needs initialization

    var body: some View {
       NavigationView {
            Form {
                 // Calendar Picker
                 Picker("List", selection: $selectedCalendar) {
                     if !eventManager.reminderCalendars.isEmpty {
                         ForEach(eventManager.reminderCalendars) { calendar in
                             HStack {
                                 Image(systemName: "circle.fill")
                                     .foregroundColor(Color(cgColor: calendar.cgColor))
                                 Text(calendar.title).tag(calendar as EKCalendar?)
                             }
                         }
                     } else {
                         Text("No reminder lists available").tag(nil as EKCalendar?)
                     }
                 }
                  // Initialize selectedCalendar if possible
                 .onAppear {
                    if selectedCalendar == nil {
                        selectedCalendar = eventManager.reminderCalendars.first ?? eventManager.eventStore.defaultCalendarForNewReminders()
                    }
                 }

                TextField("Title", text: $title)
                TextField("Notes (Optional)", text: $notes, axis: .vertical)

                 Toggle("Has Due Date", isOn: $hasDueDate.animation())
                 if hasDueDate {
                     DatePicker("Due Date", selection: $dueDate, displayedComponents: .date) // Can add time if needed
                 }

                 Picker("Priority", selection: $priority) {
                     Text("None").tag(0)
                     Text("Low (!)").tag(9)       // Example mapping
                     Text("Medium (!!)").tag(5)
                     Text("High (!!!)").tag(1)
                 }

                 // Add controls for Start Date, Alarms, Recurrence etc.
            }
             .navigationTitle("Add New Reminder")
             .navigationBarItems(leading: Button("Cancel") { dismiss() },
                                 trailing: Button("Save") { saveReminder() }.disabled(title.isEmpty || selectedCalendar == nil))
       }
    }

     func saveReminder() {
         guard let calendar = selectedCalendar else { return }

         let dueComponents: DateComponents? = hasDueDate ? Calendar.current.dateComponents([.year, .month, .day], from: dueDate) : nil
         // Add start date components if needed

         Task {
             await eventManager.createNewReminder(
                 title: title,
                 notes: notes.isEmpty ? nil : notes,
                 startDateComponents: nil, // Add UI for this
                 dueDateComponents: dueComponents,
                 priority: priority,
                 calendar: calendar,
                 alarmOffset: nil, // Add UI for this
                 recurrenceRule: nil // Add UI for this
             )
              if eventManager.currentError == nil {
                 dismiss()
             }
         }
     }
}
//
//// MARK: - App Entry Point
//@main
//struct EventKitDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            EventKitManagemenView()
//        }
//    }
//}

#Preview("EventKitManagemenView") {
    EventKitManagemenView()
}
