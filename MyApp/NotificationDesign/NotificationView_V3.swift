//
//  NotificationView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI

// --- Global Haptic Feedback Generator ---
// It's often good practice to have a shared instance or helper class
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

// --- Data Models ---

// Enum to represent where interaction should lead (Unified for Sheets)
enum NotificationDestination: Identifiable {
    case messageThread(userName: String)
    case calendarEvent(eventTitle: String)
    case genericApp(appName: String)
    case camera // Added for the camera button
    
    var id: String { // Conformance to Identifiable for .sheet
        switch self {
        case .messageThread(let userName): return "msg-\(userName)"
        case .calendarEvent(let eventTitle): return "cal-\(eventTitle)"
        case .genericApp(let appName): return "app-\(appName)"
        case .camera: return "sys-camera"
        }
    }
}

// Enhanced Data Model
struct NotificationData: Identifiable {
    let id = UUID()
    let iconName: String
    let appName: String
    let title: String
    let description: String
    let timeString: String
    let destination: NotificationDestination // Unified destination type
    let isSilent: Bool = false
}

// --- Views ---

// View for a Single Notification Row (Visuals Only - Unchanged)
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
                    .lineLimit(2) // Allow slightly more text before truncating
            }
            .padding(.vertical, 2)
        }
        .padding(12)
        .background(.ultraThinMaterial) // Material background works well on gradients
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3) // Slightly softer shadow
    }
}

// Wrapper View adding interactivity to NotificationView (Minor Haptic Additions)
struct InteractiveNotificationView: View {
    let notification: NotificationData
    let tapAction: () -> Void
    let clearAction: () -> Void
    
    var body: some View {
        Button(action: {
            Haptics.shared.playImpactLight() // Haptic feedback on tap
            tapAction()
        }) {
            NotificationView(notification: notification)
        }
        .buttonStyle(.plain) // Use plain style to avoid default button visuals
        .accessibilityLabel("\(notification.appName): \(notification.title)")
        .accessibilityHint("Double tap to open. Swipe left to clear.")
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                // No haptic needed here, removeNotification handles it
                clearAction()
            } label: {
                Label("Clear", systemImage: "trash.fill")
            }
            .tint(.red)
        }
    }
}

// View to show when a destination is activated (Sheet Content)
struct DestinationView: View {
    let destination: NotificationDestination
    
    var body: some View {
        NavigationView { // Embed in NavigationView for optional title/toolbar
            VStack(spacing: 25) {
                Spacer() // Push content down slightly
                
                Image(systemName: iconForDestination)
                    .font(.system(size: 60)) // Larger icon
                    .foregroundColor(colorForDestination)
                
                Text(titleForDestination)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text(detailsForDestination)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                Spacer() // Add more space at the bottom
            }
            .padding(30)
            .navigationTitle(navTitleForDestination) // Display a title in the sheet's nav bar
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // Add a dismiss button (standard practice)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // action to dismiss the sheet is handled by the system via @Environment(\.dismiss)
                        // or by setting the bound item to nil. This button provides a visual cue.
                    }
                }
            }
        }
    }
    
    // Helper properties for sheet content based on destination
    private var iconForDestination: String {
        switch destination {
        case .messageThread: return "message.bubble.fill"
        case .calendarEvent: return "calendar"
        case .genericApp: return "app.badge"
        case .camera: return "camera.fill"
        }
    }
    
    private var colorForDestination: Color {
        switch destination {
        case .messageThread: return .blue
        case .calendarEvent: return .red
        case .genericApp: return .orange
        case .camera: return .gray
        }
    }
    
    private var titleForDestination: String {
        switch destination {
        case .messageThread(let userName): return "\(userName) Opened Message"
        case .calendarEvent: return "Opened Calendar Event"
        case .genericApp(let appName): return "Opened \(appName)"
        case .camera: return "Camera Activated"
        }
    }
    
    private var navTitleForDestination: String {
        switch destination {
        case .messageThread: return "Messages"
        case .calendarEvent: return "Calendar"
        case .genericApp(let appName): return appName
        case .camera: return "Camera"
        }
    }
    
    private var detailsForDestination: String {
        switch destination {
        case .messageThread(let userName): return "Simulating navigation to chat with \(userName)."
        case .calendarEvent(let eventTitle): return "Showing placeholder details for event: '\(eventTitle)'."
        case .genericApp(let appName): return "Simulating opening the \(appName) application to the relevant section."
        case .camera: return "Camera view would be active here."
        }
    }
}

// --- Main Content View ---
struct ContentView: View {
    // --- State Variables ---
    @State private var notifications: [NotificationData] = mockNotifications // Load mock data
    @State private var showCollapsed = true // Control stack expansion
    @State private var activeSheet: NotificationDestination? = nil // Control sheet presentation
    @State private var isFlashlightOn: Bool = false // Control flashlight state
    
    let maxVisibleNotifications = 2 // Max notifs before collapsing
    
    // --- Body ---
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.9), Color.purple.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            // Main Content ScrollView
            ScrollView {
                VStack(spacing: 8) { // Reduced spacing for tighter packing
                    // Lock Screen Time/Date Context
                    HeaderView() // Extracted header for clarity
                        .padding(.bottom, 20)
                    
                    // --- Display Notifications ---
                    if notifications.isEmpty {
                        EmptyNotificationsView() // Extracted view for empty state
                    } else {
                        NotificationStackView( // Extracted notification stack logic
                            notifications: $notifications,
                            showCollapsed: $showCollapsed,
                            maxVisibleNotifications: maxVisibleNotifications,
                            activateSheet: activateSheet, // Pass function
                            removeNotification: removeNotification // Pass function
                        )
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 120) // Ensure space above bottom buttons
            }
            .contentMargins(.top, 50, for: .scrollContent) // Add top padding for status bar area
            
        }
        // --- Sheet Presentation (Unified) ---
        .sheet(item: $activeSheet) { destination in
            DestinationView(destination: destination)
                .presentationDetents([.medium, .large]) // Allow sheet resizing
                .presentationDragIndicator(.visible) // Show the grab handle
        }
        // --- Bottom Shortcuts Overlay ---
        .overlay(alignment: .bottom) {
            BottomShortcutsView( // Extracted bottom shortcuts
                isFlashlightOn: $isFlashlightOn,
                activateCameraSheet: { activateSheet(for: .camera) }, // Use unified sheet activation
                toggleFlashlight: toggleFlashlight // Pass function
            )
        }
        // Ensure dark mode styling is consistent
        .preferredColorScheme(.dark)
    }
    
    // --- Action Functions ---
    
    // Activates the sheet for a given destination
    private func activateSheet(for destination: NotificationDestination) {
        Haptics.shared.playImpactMedium() // Stronger haptic for opening something
        activeSheet = destination
    }
    
    // Removes a notification with animation and haptics
    private func removeNotification(id: UUID) {
        withAnimation(.easeOut(duration: 0.3)) {
            notifications.removeAll { $0.id == id }
            // If the list becomes small enough, automatically expand
            if notifications.count <= maxVisibleNotifications {
                showCollapsed = false
            }
        }
        Haptics.shared.playImpactLight() // Haptic feedback for dismissal
    }
    
    // Toggles the flashlight state with feedback
    private func toggleFlashlight() {
        isFlashlightOn.toggle()
        Haptics.shared.playSelectionChanged() // Good haptic for a toggle switch
    }
}

// --- Extracted Subviews for Clarity ---

struct HeaderView: View {
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

struct EmptyNotificationsView: View {
    var body: some View {
        Text("No Notifications")
            .font(.headline)
            .foregroundColor(.white.opacity(0.7))
            .padding(.top, 50)
            .transition(.opacity.combined(with: .scale(scale: 0.9))) // Add subtle transition
    }
}

struct NotificationStackView: View {
    @Binding var notifications: [NotificationData]
    @Binding var showCollapsed: Bool
    let maxVisibleNotifications: Int
    let activateSheet: (NotificationDestination) -> Void
    let removeNotification: (UUID) -> Void
    
    var body: some View {
        // Conditional display based on collapsed state and count
        if showCollapsed && notifications.count > maxVisibleNotifications {
            // --- Collapsed View ---
            VStack(spacing: 8) {
                ForEach(notifications.prefix(maxVisibleNotifications)) { notification in
                    InteractiveNotificationView(
                        notification: notification,
                        tapAction: { activateSheet(notification.destination) },
                        clearAction: { removeNotification(notification.id) }
                    )
                }
                // Summary Line Button
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
            .transition(.opacity) // Animate stack change
            
        } else {
            // --- Expanded View ---
            VStack(spacing: 8) {
                Text("Notifications")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                
                ForEach(notifications) { notification in
                    InteractiveNotificationView(
                        notification: notification,
                        tapAction: { activateSheet(notification.destination) },
                        clearAction: { removeNotification(notification.id) }
                    )
                }
                
                // Button to collapse (only show if expanded and count allows collapsing)
                if notifications.count > maxVisibleNotifications {
                    CollapseButton(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showCollapsed = true
                        }
                        Haptics.shared.playImpactLight()
                    })
                }
            }
            .transition(.opacity) // Animate stack change
        }
    }
}

struct ExpandButton: View {
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("+\(count) more notification\(count > 1 ? "s" : "")") // Pluralization
                    .font(.footnote)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .foregroundColor(.secondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)
            .accessibilityLabel("Show \(count) more notification\(count > 1 ? "s" : "")")
            .accessibilityHint("Double tap to expand the notification stack")
        }
        .buttonStyle(.plain)
    }
}

struct CollapseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Show Less", systemImage: "chevron.up")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.black.opacity(0.25)) // Slightly more prominent background
                .clipShape(Capsule())
                .contentShape(Capsule()) // Ensure the whole capsule is tappable
        }
        .buttonStyle(.plain)
        .padding(.top, 5)
        .accessibilityHint("Double tap to collapse the notification stack")
    }
}

struct BottomShortcutsView: View {
    @Binding var isFlashlightOn: Bool
    let activateCameraSheet: () -> Void
    let toggleFlashlight: () -> Void
    
    var body: some View {
        HStack(spacing: 60) { // Add more spacing between buttons
            // Flashlight Button
            Button(action: toggleFlashlight) {
                Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .imageScale(.large) // Consistent sizing
                    .font(.title2) // Slightly smaller font size
                    .frame(width: 50, height: 50) // Explicit frame for consistent tap target
                    .background(isFlashlightOn ? .white.opacity(0.3) : .black.opacity(0.3))
                    .clipShape(Circle())
                    .animation(.bouncy, value: isFlashlightOn) // Add bouncy effect
            }
            .accessibilityLabel(isFlashlightOn ? "Flashlight On" : "Flashlight Off")
            .accessibilityHint("Double tap to toggle flashlight")
            
            // Camera Button
            Button(action: activateCameraSheet) {
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
        .padding(.bottom, 40) // Adjust bottom padding as needed
        .shadow(radius: 3)
    }
}

// --- Mock Data ---
let mockNotifications: [NotificationData] = [
    NotificationData(iconName: "calendar", appName: "Calendar", title: "Meeting Reminder", description: "Project Sync-up with the team starts in 15 minutes!", timeString: "9:45 AM", destination: .calendarEvent(eventTitle: "Project Sync-up")), // Example silent
    NotificationData(iconName: "message.fill", appName: "Messages", title: "John Appleseed", description: "Hey, are you free for lunch later today? Let me know your availability. We could try that new place downtown.", timeString: "9:41 AM", destination: .messageThread(userName: "John Appleseed")),
    NotificationData(iconName: "envelope.fill", appName: "Mail", title: "Weekly Digest", description: "Your curated list of top tech articles is ready.", timeString: "9:30 AM", destination: .genericApp(appName: "Mail")),
    NotificationData(iconName: "bell.fill", appName: "Reminders", title: "Grocery Shopping", description: "Pick up milk, eggs, bread, and coffee beans", timeString: "Yesterday", destination: .genericApp(appName: "Reminders")),
    NotificationData(iconName: "photo.on.rectangle.angled", appName: "Photos", title: "Memory Available", description: "A new memory from your trip to the coast last year.", timeString: "Yesterday", destination: .genericApp(appName: "Photos")),
    NotificationData(iconName: "message.fill", appName: "Messages", title: "Jane Doe", description: "Did you see the latest WWDC announcements?", timeString: "2 days ago", destination: .messageThread(userName: "Jane Doe"))
]

// --- Previews ---
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        // You can add more preview variations here if needed
        // e.g., with no notifications:
        //             ContentView(notifications: [], showCollapsed: false)
        //                 .previewDisplayName("Empty State")
        
        // e.g., with few notifications (should be expanded):
        //             ContentView(notifications: Array(mockNotifications.prefix(2)), showCollapsed: true)
        //                .previewDisplayName("Few Notifications")
    }
}
#endif
