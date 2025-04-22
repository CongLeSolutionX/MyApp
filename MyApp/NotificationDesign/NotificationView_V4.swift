//  ContentView_RealData.swift
//  MyApp // Replace with your app name
//
//  Created by Cong Le on 4/22/25. // Update Date
//  Requires iOS 15+ for some SwiftUI features like .swipeActions, .sheet presentationDetents
//  Remember to add NSCalendarsUsageDescription to your Info.plist!

import SwiftUI
import EventKit // For Calendar access
import AVFoundation // For Flashlight control

// --- Haptic Feedback Generator ---
struct Haptics {
    static let shared = Haptics()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let impactLightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let impactMediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private init() {
        selectionGenerator.prepare()
        impactLightGenerator.prepare()
        impactMediumGenerator.prepare()
    }
    
    func playSelectionChanged() {
        selectionGenerator.selectionChanged()
    }
    
    func playImpactLight() {
        impactLightGenerator.impactOccurred()
    }
    
    func playImpactMedium() {
        impactMediumGenerator.impactOccurred()
    }
}

// --- Event Store Manager (Handles Calendar Logic) ---
class EventStoreManager: ObservableObject {
    @Published var events: [EKEvent] = []
    @Published var accessGranted: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let eventStore = EKEventStore()
    
    func requestAccessAndFetchEvents() {
        isLoading = true
        errorMessage = nil
        
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error requesting calendar access: \(error.localizedDescription)"
                    self.isLoading = false
                    print(self.errorMessage!)
                    return
                }
                
                self.accessGranted = granted
                
                if granted {
                    self.fetchUpcomingEvents()
                } else {
                    self.errorMessage = "Calendar access was denied. Please enable it in Settings."
                    self.isLoading = false
                    print(self.errorMessage!)
                }
            }
        }
    }
    
    func fetchUpcomingEvents() {
        guard accessGranted else {
            errorMessage = "Access not granted to fetch events."
            print(errorMessage!)
            isLoading = false
            return
        }
        
        let calendars = eventStore.calendars(for: .event)
        let startDate = Date()
        // Fetch events for the next 24 hours (adjust as needed)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        // Fetch events asynchronously to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let fetchedEvents = self.eventStore.events(matching: predicate)
                .filter { !$0.isAllDay } // Exclude all-day events for this example
                .sorted { $0.startDate < $1.startDate } // Sort by start date
                
            DispatchQueue.main.async {
                self.events = fetchedEvents
                self.isLoading = false
                print("Fetched \(fetchedEvents.count) upcoming events.")
            }
        }
    }
}

// --- Data Models ---

// Destination Enum - Simplified for actual app opening
enum NotificationDestination: Identifiable {
    case messagesApp // Opens the Messages app (compose)
    case calendarApp // Opens the Calendar app
    case cameraApp // Attempts to open the Camera app
    case photosApp // Specific example for photos memory
    case remindersApp // Opens Reminders app
    case mailApp // Opens Mail app
    case generic // Placeholder for apps we can't open easily
    
    var id: String { // Base ID on the app type
        switch self {
        case .messagesApp: return "app-messages"
        case .calendarApp: return "app-calendar"
        case .cameraApp: return "app-camera"
        case .photosApp: return "app-photos"
        case .remindersApp: return "app-reminders"
        case .mailApp: return "app-mail"
        case .generic: return "app-generic"
        }
    }
}

// Combined Notification Struct (Can represent mock or real data)
struct NotificationData: Identifiable {
    let id = UUID() // Unique ID for SwiftUI lists
    let sourceEventID: String? // Optional: Store EKEvent identifier if from Calendar
    let iconName: String
    let appName: String
    let title: String
    let description: String
    let notificationDate: Date // Use Date for sorting
    let destination: NotificationDestination
    let isSilent: Bool = false
    
    // Computed property for display time string
    var timeString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(notificationDate) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        } else if Calendar.current.isDateInYesterday(notificationDate) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        }
        return formatter.string(from: notificationDate)
    }
}

// --- Views ---

// The visual representation of a notification row (Mostly Unchanged)
struct NotificationView: View {
    let notification: NotificationData
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: notification.iconName)
                .font(.title3)
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundColor(.primary.opacity(0.8))
                .padding(6)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(notification.appName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer()
                    Text(notification.timeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 1)
                
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(notification.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 2)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)
    }
}

// Interactive Wrapper (Handles Tap & Swipe)
struct InteractiveNotificationView: View {
    let notification: NotificationData
    // Pass the specific destination to the action handler
    let tapAction: (NotificationDestination) -> Void
    let clearAction: (UUID) -> Void
    
    var body: some View {
        Button(action: {
            Haptics.shared.playImpactLight()
            tapAction(notification.destination) // Pass the destination
        }) {
            NotificationView(notification: notification)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(notification.appName): \(notification.title)")
        .accessibilityHint("Double tap to open \(notification.appName). Swipe left to clear.")
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                clearAction(notification.id)
            } label: {
                Label("Clear", systemImage: "trash.fill")
            }
            .tint(.red)
        }
    }
}

// --- Main Content View ---
struct ContentView: View {
    // State Variables
    @State private var allNotifications: [NotificationData] = initialMockNotifications // Start with mocks
    @State private var showCollapsed = true // Control stack expansion
    @State private var isFlashlightOn: Bool = false // Control flashlight state
    
    // Use @StateObject for the EventStoreManager lifecycle
    @StateObject private var eventManager = EventStoreManager()
    
    let maxVisibleNotifications = 2 // Max notifs before collapsing
    
    // Computed property to sort notifications (most recent first)
    var sortedNotifications: [NotificationData] {
        allNotifications.sorted { $0.notificationDate > $1.notificationDate }
    }
    
    // --- Body ---
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.9), Color.purple.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            // Main Content ScrollView
            ScrollView {
                VStack(spacing: 8) {
                    HeaderView()
                        .padding(.bottom, 20)
                    
                    // Display Loading/Error/Content based on EventManager state
                    if eventManager.isLoading && allNotifications.count <= initialMockNotifications.count {
                         // Only show loading if we haven't merged calendar events yet
                        ProgressView("Loading Calendar Events...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding()
                    }
                    
                    if let errorMsg = eventManager.errorMessage {
                        Text("⚠️ \(errorMsg)")
                            .font(.footnote)
                            .foregroundColor(.yellow)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .transition(.opacity)
                    }
                    
                    // Notification Stack Display
                    if sortedNotifications.isEmpty && !eventManager.isLoading {
                        EmptyNotificationsView()
                    } else {
                        NotificationStackView(
                            notifications: sortedNotifications, // Use computed property
                            showCollapsed: $showCollapsed,
                            maxVisibleNotifications: maxVisibleNotifications,
                            handleTap: handleNotificationTap, // Pass tap handler
                            removeNotification: removeNotification // Pass remove handler
                        )
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 120) // Space for bottom buttons
            }
            .contentMargins(.top, 50, for: .scrollContent)
        }
        // --- No Sheet Needed - Opening Apps Directly ---
        // --- Bottom Shortcuts Overlay ---
        .overlay(alignment: .bottom) {
            BottomShortcutsView(
                isFlashlightOn: $isFlashlightOn,
                activateCamera: { handleNotificationTap(for: .cameraApp) }, // Directly trigger action
                toggleFlashlight: toggleFlashlight // Pass flashlight function
            )
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Request access and fetch events when the view appears
            if !eventManager.accessGranted && eventManager.errorMessage == nil {
                 eventManager.requestAccessAndFetchEvents()
            }
        }
        .onChange(of: eventManager.events) { newEvents in
            // Merge Calendar events with existing notifications when fetched data changes
            mergeCalendarEvents(newEvents)
        }
        .onChange(of: eventManager.accessGranted) { granted in
             // If access is granted later (e.g., from settings), try fetching again
             if granted && eventManager.events.isEmpty {
                 eventManager.fetchUpcomingEvents()
             } else if !granted && allNotifications.contains(where: { $0.appName == "Calendar" }) {
                 // If access revoked, remove calendar notifications
                 allNotifications.removeAll { $0.appName == "Calendar" }
             }
         }
    }
    
    // --- Action Functions ---
    
    // Handles tapping on a notification - Opens appropriate app/URL
    private func handleNotificationTap(for destination: NotificationDestination) {
        Haptics.shared.playImpactMedium()
        var urlString: String? = nil
        
        switch destination {
        case .messagesApp:
            urlString = "sms:" // Opens Messages compose/list
        case .calendarApp:
             // Using calshow: often just opens the app to the current date view
             // For better control, native integration is needed, but this opens the app.
            urlString = "calshow:"
        case .cameraApp:
            // This is a private URL scheme used by some Apple systems, might fail
            // A more robust way within an app is UIImagePickerController
             print("Attempting to open Camera via URL Scheme...")
             urlString = "photos-redirect://camera" // Try this scheme
        case .photosApp:
             // Standard scheme to open Photos app
             urlString = "photos-redirect://"
        case .remindersApp:
             // No official URL scheme documented, might not work reliably.
             // urlString = "x-apple-reminderkit://" // Example, likely won't work
             print("Opening Reminders App - URL Scheme unreliable, simulating action.")
             // In a real app, you might show an alert here or do nothing.
             return // Exit early if no reliable action
        case .mailApp:
              urlString = "message://" // Opens default mail client
        case .generic:
            print("Tapped on a generic notification - no specific app to open.")
            // Maybe show an alert or log this event
            return // Exit early
        }
        
        if let urlString = urlString, let url = URL(string: urlString) {
            openURL(url)
        } else if destination == .cameraApp {
            // Fallback if camera scheme fails - inform user
             print("Could not construct Camera URL. Opening apps via URL schemes can be fragile.")
             // Optionally, show an alert here.
        }
    }
    
    // Helper to open URLs
    private func openURL(_ url: URL) {
        // Ensure we are running on iOS
        #if canImport(UIKit)
        UIApplication.shared.open(url) { success in
            if !success {
                print("Failed to open URL: \(url)")
                // Handle failure (e.g., show an alert)
            }
        }
        #else
          print("URL opening only supported on iOS/iPadOS.")
        #endif
    }
    
    // Removes a notification
    private func removeNotification(id: UUID) {
        withAnimation(.easeOut(duration: 0.3)) {
            allNotifications.removeAll { $0.id == id }
            if allNotifications.count <= maxVisibleNotifications && !showCollapsed {
                // If expanded and count becomes small, maybe collapse? Or keep expanded? User preference.
                // For now, let's keep it expanded if user explicitly expanded it.
            }
             if allNotifications.count > maxVisibleNotifications && showCollapsed {
                 // If collapsed and count remains large, stay collapsed.
             }
              if allNotifications.count <= maxVisibleNotifications && showCollapsed {
                 // If collapsed and count becomes small, expand automatically
                 showCollapsed = false
             }
        }
        Haptics.shared.playImpactLight()
    }
    
    // Toggles the device flashlight
    private func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            print("Flashlight not available on this device.")
            // Maybe show an alert to the user on real device if needed
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            if device.torchMode == .on {
                device.torchMode = .off
                isFlashlightOn = false
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel) // Use max brightness
                isFlashlightOn = true
            }
            
            device.unlockForConfiguration()
            Haptics.shared.playSelectionChanged() // Haptic for toggle
            
        } catch {
            print("Error controlling flashlight: \(error)")
             isFlashlightOn = false // Ensure state is consistent on error
        }
    }
    
    // Merges fetched calendar events into the main notification list
    private func mergeCalendarEvents(_ events: [EKEvent]) {
         // Remove previous calendar notifications to avoid duplicates
         allNotifications.removeAll { $0.appName == "Calendar" }

         let calendarNotifications = events.map { event -> NotificationData in
             return NotificationData(
                 sourceEventID: event.eventIdentifier, // Store original ID if needed later
                 iconName: "calendar",
                 appName: "Calendar",
                 title: event.title ?? "Calendar Event",
                 description: event.notes ?? "Starts at \(event.startDate.formatted(date: .omitted, time: .shortened))",
                 notificationDate: event.startDate, // Use event start date as notification time
                 destination: .calendarApp
             )
         }
        
        // Add the new calendar events
         allNotifications.append(contentsOf: calendarNotifications)

         // Optional: Auto-expand if new events make the list small enough
         if allNotifications.count <= maxVisibleNotifications {
             showCollapsed = false
         }
         print("Merged \(calendarNotifications.count) calendar events into notifications list.")
    }
}

// --- Extracted Subviews ---

struct HeaderView: View { // (Unchanged)
    var body: some View {
        VStack {
            Text(Date(), style: .date)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .shadow(radius: 2)
            Text(Date(), style: .time)
                .font(.system(size: 80, weight: .thin))
                .foregroundColor(.white)
                .shadow(radius: 2)
        }
    }
}

struct EmptyNotificationsView: View { // (Unchanged)
    var body: some View {
        Text("No Notifications")
            .font(.headline)
            .foregroundColor(.white.opacity(0.7))
            .padding(.top, 50)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

struct NotificationStackView: View { // Modified to pass destination
    let notifications: [NotificationData] // Now receives sorted list
    @Binding var showCollapsed: Bool
    let maxVisibleNotifications: Int
    let handleTap: (NotificationDestination) -> Void // Renamed, passes destination
    let removeNotification: (UUID) -> Void
    
    var body: some View {
        if showCollapsed && notifications.count > maxVisibleNotifications {
            // Collapsed View
            VStack(spacing: 8) {
                ForEach(notifications.prefix(maxVisibleNotifications)) { notification in
                    InteractiveNotificationView(
                        notification: notification,
                        tapAction: handleTap, // Pass tap handler
                        clearAction: removeNotification
                    )
                      .transition(.move(edge: .top).combined(with: .opacity)) // Add transition
                }
                ExpandButton(
                    count: notifications.count - maxVisibleNotifications,
                    action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showCollapsed = false
                        }
                        Haptics.shared.playImpactLight()
                    }
                )
            }
            .transition(.opacity)
            
        } else if !notifications.isEmpty { // Check if not empty before showing expanded
            // Expanded View
            VStack(spacing: 8) {
                 // Only show header if there are notifications
                 if !notifications.isEmpty {
                     Text("Notifications")
                         .font(.caption.weight(.semibold))
                         .foregroundColor(.white.opacity(0.8))
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.leading, 5)
                 }

                ForEach(notifications) { notification in
                    InteractiveNotificationView(
                        notification: notification,
                        tapAction: handleTap, // Pass tap handler
                        clearAction: removeNotification
                    )
                    .transition(.move(edge: .top).combined(with: .opacity)) // Add transition
                }
                
                if notifications.count > maxVisibleNotifications {
                    CollapseButton(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showCollapsed = true
                        }
                        Haptics.shared.playImpactLight()
                    })
                }
            }
            .transition(.opacity)
        }
    }
}

struct ExpandButton: View { // (Unchanged)
    let count: Int
    let action: () -> Void
    var body: some View { // ... same implementation ...
        Button(action: action) {
            HStack {
                Text("+\(count) more notification\(count > 1 ? "s" : "")")
                    .font(.footnote)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 16))
           // .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3) // Optional shadow removed for flatter look
            .accessibilityLabel("Show \(count) more notification\(count > 1 ? "s" : "")")
            .accessibilityHint("Double tap to expand the notification stack")
        }
        .buttonStyle(.plain)
    }
}

struct CollapseButton: View { // (Unchanged)
    let action: () -> Void
    var body: some View { // ... same implementation ...
       Button(action: action) {
            Label("Show Less", systemImage: "chevron.up")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.black.opacity(0.25))
                .clipShape(Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.top, 5)
        .accessibilityHint("Double tap to collapse the notification stack")
    }
}

struct BottomShortcutsView: View { // Modified for direct actions
    @Binding var isFlashlightOn: Bool
    let activateCamera: () -> Void // Changed from sheet activation
    let toggleFlashlight: () -> Void
    
    var body: some View { // (Minor visual tweaks maybe, functionality change)
        HStack(spacing: 60) {
            Button(action: toggleFlashlight) { // Flashlight button uses passed action
                Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .imageScale(.large)
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(isFlashlightOn ? .white.opacity(0.3) : .black.opacity(0.3))
                    .clipShape(Circle())
                   // .animation(.bouncy, value: isFlashlightOn) // Bouncy animation exists
            }
             .accessibilityLabel(isFlashlightOn ? "Flashlight On" : "Flashlight Off")
             .accessibilityHint("Double tap to toggle flashlight")
            
            Button(action: activateCamera) { // Camera button uses passed action
                Image(systemName: "camera.fill")
                    .imageScale(.large)
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Camera")
            .accessibilityHint("Double tap to open camera")

        }
        .buttonStyle(.plain)
        .foregroundColor(.white)
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
        .shadow(radius: 3)
        // Add explicit animation for flashlight state change if desired beyond image change
         .animation(.easeInOut(duration: 0.2), value: isFlashlightOn)
    }
}

// --- Initial Mock Data (Will be supplemented by Calendar Events) ---
let initialMockNotifications: [NotificationData] = [
    // Keep some mocks for apps we can't easily fetch data for
    NotificationData(sourceEventID: nil, iconName: "message.fill", appName: "Messages", title: "John Appleseed", description: "Let's grab lunch!", notificationDate: Calendar.current.date(byAdding: .minute, value: -5, to: Date())!, destination: .messagesApp),
    NotificationData(sourceEventID: nil, iconName: "envelope.fill", appName: "Mail", title: "Newsletter", description: "Your weekly update.", notificationDate: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, destination: .mailApp),
    NotificationData(sourceEventID: nil, iconName: "photo.on.rectangle.angled", appName: "Photos", title: "Memory Available", description: "A new memory from your trip.", notificationDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, destination: .photosApp),
    NotificationData(sourceEventID: nil, iconName: "bell.fill", appName: "Reminders", title: "Grocery Shopping", description: "Milk, eggs, bread", notificationDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, destination: .remindersApp), // Example reminder
]

// --- Previews ---
#if DEBUG
struct ContentView_RealData_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
