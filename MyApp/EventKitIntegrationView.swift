//
//  EventKitIntegrationView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//
import SwiftUI
import EventKit // Provides EKEventStore, EKEvent
import EventKitUI // Provides EKEventEditViewController, EKEventEditViewDelegate

// MARK: - UIViewControllerRepresentable Definition

/// A SwiftUI view that wraps the UIKit EKEventEditViewController.
/// This allows presenting the standard iOS event editing interface modally
/// without requiring explicit calendar permissions *just* for adding an event via this UI.
private struct EventEditViewControllerRepresentable: UIViewControllerRepresentable {

    // MARK: Environment and Bindings

    /// Controls the presentation state of the sheet containing this view controller.
    @Binding var isPresented: Bool

    /// Stores the action (saved, canceled, deleted) taken by the user upon dismissal.
    @Binding var completedAction: EKEventEditViewAction?

    /// An optional EKEvent object to pre-populate the editor with initial details.
    /// If nil, the controller opens a blank new event form.
    @Binding var event: EKEvent?

    /// The EKEventStore instance to associate with the event editor.
    /// It's crucial that the EKEvent (if provided) belongs to this store.
    let eventStore: EKEventStore

    // MARK: Initializer

    init(store: EKEventStore, event: Binding<EKEvent?>, isPresented: Binding<Bool>, completedAction: Binding<EKEventEditViewAction?>) {
        self.eventStore = store
        self._event = event
        self._isPresented = isPresented
        self._completedAction = completedAction
    }

    // MARK: UIViewControllerRepresentable Protocol Methods

    /// Creates the initial EKEventEditViewController instance.
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore // Associate the store
        controller.event = event // Set the initial event data (can be nil)
        controller.editViewDelegate = context.coordinator // Assign the delegate for callbacks
        // Note: We use 'editViewDelegate', not 'delegate'. 'delegate' is for UINavigationControllerDelegate.
        return controller
    }

    /// Updates the view controller. In this specific case, the EKEventEditViewController
    /// manages its own state once presented, so we don't typically need to update it here.
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        // If the event binding changed *while* the sheet was trying to present,
        // you *might* update uiViewController.event here, but it's generally
        // simpler to ensure the event is set correctly in makeUIViewController.
    }

    /// Creates the Coordinator instance to act as the delegate.
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    // MARK: Coordinator

    /// The Coordinator class acts as the delegate for EKEventEditViewController.
    /// It bridges events from the UIKit world back to our SwiftUI representable.
    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: EventEditViewControllerRepresentable

        init(_ parent: EventEditViewControllerRepresentable) {
            self.parent = parent
        }

        /// This delegate method is called when the user finishes editing (saves, cancels, or deletes).
        /// - Parameters:
        ///   - controller: The EKEventEditViewController instance.
        ///   - action: The action the user took (saved, canceled, deleted).
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            // --- Limitations Note ---
            // We CANNOT reliably inspect `controller.event` here to get the final state
            // of the saved event. Edits happen out-of-process, and the controller's
            // event property might not reflect the final user changes upon dismissal.
            // This approach gives up control over the final saved data.

            // Update the bindings to communicate back to the SwiftUI view
            parent.completedAction = action
            parent.isPresented = false // Triggers the dismissal of the sheet
        }

        // --- Optional Delegate Method ---
        // func eventEditViewControllerDefaultCalendar(forNewEvents controller: EKEventEditViewController) -> EKCalendar {
            // --- Permission Note ---
            // Implementing this method to specify a default calendar REQUIRES calendar read permissions.
            // You would need to:
            // 1. Add NSCalendarsReadUsageDescription to Info.plist.
            // 2. Request and check authorization using EKEventStore.
            // 3. Fetch the desired EKCalendar using `eventStore.calendars(for:)`.
            // If you don't implement this, EventKit chooses a default calendar.
            // The user can always change the calendar within the presented UI.
        //    return eventStore.defaultCalendarForNewEvents ?? EKCalendar(for: .event, eventStore: eventStore) // Example placeholder
        // }
    }
}

// MARK: - EKEventEditViewAction Extension for Display

/// Make EKEventEditViewAction displayable in the UI.
extension EKEventEditViewAction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .canceled:
            return "Event Edit Canceled"
        case .saved:
            return "Event Saved to Calendar"
        case .deleted:
            // Note: 'Deleted' usually appears only if editing an *existing* event,
            // which requires fetch permissions not covered by this basic 'add' flow.
            return "Event Deleted from Calendar"
        @unknown default:
            return "Unknown Action"
        }
    }
}

// MARK: - SwiftUI ContentView

struct EventKitIntegrationView: View {
    // MARK: State Variables

    /// Controls whether the event editing sheet is presented.
    @State private var showEventEditSheet: Bool = false

    /// Stores the result from the EKEventEditViewController.
    @State private var lastAction: EKEventEditViewAction? = nil

    /// User input for the pre-filled event title.
    @State private var eventTitle: String = "Team Meeting"

    /// User input for the pre-filled event start date.
    @State private var eventStartDate: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()

    /// User input for the pre-filled event end date.
    @State private var eventEndDate: Date = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()

    /// The EKEvent object created from user input, passed to the representable.
    @State private var preparedEvent: EKEvent? = nil

    /// Single instance of EKEventStore for the view.
    @State private var eventStore = EKEventStore()

    // MARK: Body

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Event via EKEventEditViewController")
                    .font(.headline)
                    .padding(.top)

                // Display the result of the last action
                if let action = lastAction {
                    Text("Last Action: \(action.description)")
                        .padding()
                        .background(action == .saved ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .cornerRadius(8)
                        .transition(.opacity.combined(with: .scale))
                }

                // Input fields for pre-setting event details
                GroupBox("Pre-fill Event Details (Optional)") {
                    TextField("Event Title", text: $eventTitle)
                        .textFieldStyle(.roundedBorder)

                    DatePicker("Start Date", selection: $eventStartDate)
                    DatePicker("End Date", selection: $eventEndDate)
                }
                .padding(.horizontal)

                // Button to trigger the event creation and sheet presentation
                Button {
                    prepareAndShowEventEditor()
                } label: {
                    Label("Add Event to Calendar", systemImage: "calendar.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)

                // Explanation of limitations
                GroupBox("Important Considerations") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• No explicit permission needed *just to show this UI* for adding.")
                        Text("• **Limitation:** App cannot get the final event details after saving.")
                        Text("• **Limitation:** User can change *any* pre-filled detail.")
                        Text("• **Limitation:** Cannot edit *existing* events without full calendar access permissions.")
                        Text("• **Limitation:** Cannot programmatically set the target calendar without permissions.")
                    }
                    .font(.caption)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("EventKitUI Demo")
            .sheet(isPresented: $showEventEditSheet, onDismiss: handleSheetDismiss) {
                // Present the Representable within the sheet
                EventEditViewControllerRepresentable(
                    store: eventStore,
                    event: $preparedEvent, // Pass the prepared event (or nil)
                    isPresented: $showEventEditSheet,
                    completedAction: $lastAction
                )
                .ignoresSafeArea() // Allow the view controller to use the full screen
            }
            .onChange(of: lastAction) { newAction in
                // Optional: Clear the temporary action display after a delay
                if newAction != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        // Only clear if it hasn't changed again in the meantime
                       // if self.lastAction == newAction { // Comparing enums directly is fine
                       //     withAnimation {
                       //         self.lastAction = nil
                       //     }
                       // }
                       // Temporarily removing comparison as @unknown default makes it non-equatable without explicit conformance
                       withAnimation {
                            self.lastAction = nil
                       }
                    }
                }
            }
        }
    }

    // MARK: Helper Functions

    /// Creates an EKEvent object based on the current state variables and triggers the sheet presentation.
    private func prepareAndShowEventEditor() {
        // Create a new EKEvent associated with our event store
        let newEvent = EKEvent(eventStore: self.eventStore)
        newEvent.title = self.eventTitle
        newEvent.startDate = self.eventStartDate
        newEvent.endDate = self.eventEndDate
        // Note: We don't set newEvent.calendar here unless we have permissions
        // and have fetched a specific calendar. EKEventEditViewController will use
        // a default or let the user choose.

        // --- Editing Existing Event Note ---
        // If this `newEvent` had an `eventIdentifier` (meaning it was fetched
        // from the calendar previously), EKEventEditViewController would open
        // in edit mode. But creating it like this (`EKEvent(eventStore:)`)
        // results in a nil `eventIdentifier` initially, triggering the 'add new' flow.

        self.preparedEvent = newEvent // Assign to the state variable bound to the Representable
        self.showEventEditSheet = true // Present the sheet
    }

    /// Called when the sheet is dismissed.
    private func handleSheetDismiss() {
        // Optionally, reset fields or perform other cleanup based on the action
        if lastAction == .saved {
            // Example: Clear the fields after a successful save
            // clearEventInputFields()
            print("Sheet dismissed after saving.")
        } else {
            print("Sheet dismissed (Action: \(String(describing: lastAction)))")
        }
        // The 'preparedEvent' is automatically reset if needed the next time
        // prepareAndShowEventEditor is called. Setting it to nil here is optional.
        // self.preparedEvent = nil
    }

    /// Example function to clear input fields (call from handleSheetDismiss if needed)
    private func clearEventInputFields() {
        self.eventTitle = ""
        self.eventStartDate = Date()
        self.eventEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EventKitIntegrationView()
    }
}

// MARK: - Application Entry Point (If needed for a standalone app)
/*
 @main
 struct EventKitUIDemoApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
 */
