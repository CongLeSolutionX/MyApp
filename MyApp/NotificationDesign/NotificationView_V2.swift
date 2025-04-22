//
//  NotificationView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI

// --- Data Models ---

// Enum to represent where a notification tap should lead (for simulation)
enum NotificationDestination: Identifiable {
    case messageThread(userName: String)
    case calendarEvent(eventTitle: String)
    case genericApp(appName: String)
    // Add more specific destinations as needed

    var id: String { // Conformance to Identifiable for .sheet
        switch self {
        case .messageThread(let userName): return "msg-\(userName)"
        case .calendarEvent(let eventTitle): return "cal-\(eventTitle)"
        case .genericApp(let appName): return "app-\(appName)"
        }
    }
}

// Enhanced Data Model
struct NotificationData: Identifiable {
    let id = UUID()
    let iconName: String
    let appName: String // Added App Name
    let title: String
    let description: String
    let timeString: String
    let destination: NotificationDestination // Added Destination
    let isSilent: Bool = false // Example property (not visually used here)
}

// --- Views ---

// View for a Single Notification Row (Visuals Only)
struct NotificationView: View {
    let notification: NotificationData

    var body: some View {
        HStack(alignment: .center, spacing: 12) { // Center alignment looks better with app name
            // Icon
            Image(systemName: notification.iconName)
                .font(.title3)
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundColor(.primary.opacity(0.8))
                .padding(6)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Text Content (App Name, Title, Description)
            VStack(alignment: .leading, spacing: 2) {
                // App Name and Timestamp Row
                HStack {
                    Text(notification.appName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer() // Pushes timestamp to the right
                    Text(notification.timeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 1) // Small space before title

                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(notification.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 2) // Small vertical padding for text block
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

// Wrapper View adding interactivity to NotificationView
struct InteractiveNotificationView: View {
    let notification: NotificationData
    let tapAction: () -> Void
    let clearAction: () -> Void

    var body: some View {
        Button(action: tapAction) { // Make the whole view tappable
            NotificationView(notification: notification)
        }
        .buttonStyle(.plain) // Use plain style to avoid default button visuals
        .accessibilityLabel("\(notification.appName): \(notification.title)") // Basic accessibility
        .accessibilityHint("Double tap to open \(notification.appName)")
        .swipeActions(edge: .trailing, allowsFullSwipe: false) { // Add swipe action
            Button(role: .destructive, action: clearAction) {
                Label("Clear", systemImage: "trash.fill")
            }
            .tint(.red) // Standard red color for destructive actions
        }
    }
}

// View to show when a notification destination is activated (for sheet simulation)
struct DestinationView: View {
    let destination: NotificationDestination

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconForDestination)
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text(titleForDestination)
                .font(.title2)
                .multilineTextAlignment(.center)

            Text(detailsForDestination)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(40)
    }

    // Helper properties for sheet content based on destination
    private var iconForDestination: String {
        switch destination {
        case .messageThread: return "message.circle.fill"
        case .calendarEvent: return "calendar.circle.fill"
        case .genericApp: return "app.badge.fill"
        }
    }

    private var titleForDestination: String {
        switch destination {
        case .messageThread(let userName): return "\(userName) Opened Message"
        case .calendarEvent: return "Opened Calendar Event"
        case .genericApp(let appName): return "Opened \(appName)"
        }
    }

    private var detailsForDestination: String {
        switch destination {
        case .messageThread(let userName): return "Navigated to chat with \(userName)."
        case .calendarEvent(let eventTitle): return "Showing details for event: '\(eventTitle)'."
        case .genericApp(let appName): return "Simulating opening the \(appName) application."
        }
    }
}

// --- Main Content View ---
struct ContentView: View {
    @State private var notifications: [NotificationData] = [
        NotificationData(iconName: "calendar", appName: "Calendar", title: "Meeting Reminder", description: "Project Sync-up in 15 minutes", timeString: "9:45 AM", destination: .calendarEvent(eventTitle: "Project Sync-up")),
        NotificationData(iconName: "message.fill", appName: "Messages", title: "John Appleseed", description: "Hey, are you free for lunch later today? Let me know!", timeString: "9:41 AM", destination: .messageThread(userName: "John Appleseed")),
        NotificationData(iconName: "envelope.fill", appName: "Mail", title: "Newsletter", description: "Weekly SwiftUI Tips & Tricks are here!", timeString: "9:30 AM", destination: .genericApp(appName: "Mail")),
        NotificationData(iconName: "bell.fill", appName: "Reminders", title: "Grocery Shopping", description: "Pick up milk, eggs, and bread", timeString: "Yesterday", destination: .genericApp(appName: "Reminders")),
        NotificationData(iconName: "photo.on.rectangle.angled", appName: "Photos", title: "Memory Available", description: "A new memory from your trip last year.", timeString: "Yesterday", destination: .genericApp(appName: "Photos")),
         NotificationData(iconName: "message.fill", appName: "Messages", title: "Jane Doe", description: "Did you see the news?", timeString: "2 days ago", destination: .messageThread(userName: "Jane Doe"))
    ]

    @State private var showCollapsed = true // Start collapsed if many notifications
    @State private var activeSheet: NotificationDestination? = nil // Holds destination for sheet presentation
    let maxVisibleNotifications = 2

    var body: some View {
        ZStack {
            // Background (Simulated)
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            // Notification Area
            ScrollView {
                VStack(spacing: 8) {
                    // Lock Screen Time/Date Context
                    VStack {
                        Text(Date(), style: .date) // Dynamic Date
                             .font(.title3)
                             .fontWeight(.medium)
                             .foregroundColor(.white.opacity(0.9))
                             .shadow(radius: 2)
                        Text(Date(), style: .time) // Dynamic Time
                            .font(.system(size: 80, weight: .thin))
                             .foregroundColor(.white)
                             .shadow(radius: 2)

                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    // --- Display Notifications ---
                    if notifications.isEmpty {
                        Text("No Notifications")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 50)
                    } else if showCollapsed && notifications.count > maxVisibleNotifications {
                        // --- Collapsed View ---
                        ForEach(notifications.prefix(maxVisibleNotifications)) { notification in
                             InteractiveNotificationView(
                                notification: notification,
                                tapAction: {
                                    activateSheet(for: notification.destination)
                                },
                                clearAction: {
                                    removeNotification(id: notification.id)
                                }
                             )
                        }
                        // Summary Line Button
                        Button {
                             withAnimation(.spring()) {
                                showCollapsed = false // Expand the stack
                            }
                        } label: {
                            HStack {
                                Text("+\(notifications.count - maxVisibleNotifications) more notifications")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.down") // Hint for expansion
                            }
                            .foregroundColor(.secondary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
                             .accessibilityLabel("Show \(notifications.count - maxVisibleNotifications) more notifications")
                             .accessibilityHint("Double tap to expand the notification stack")
                        }
                         .buttonStyle(.plain)

                    } else {
                        // --- Expanded View ---
                        Text("Notifications") // Optional Section Header
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 5) // Align with notification content inset

                        ForEach(notifications) { notification in
                            InteractiveNotificationView(
                                notification: notification,
                                tapAction: {
                                    activateSheet(for: notification.destination)
                                },
                                clearAction: {
                                    removeNotification(id: notification.id)
                                }
                            )
                        }

                         // Button to collapse (only show if expanded)
                        if notifications.count > maxVisibleNotifications {
                            Button {
                                withAnimation(.spring()) {
                                    showCollapsed = true
                                }
                            } label: {
                                Label("Show Less", systemImage: "chevron.up")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(8)
                                    .background(.black.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 5)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 100)
            }
        }
         // --- Sheet Presentation for Tapped Notification ---
        .sheet(item: $activeSheet) { destination in
             // Pass the destination data to the sheet content view
            DestinationView(destination: destination)
                .presentationDetents([.medium, .large]) // Allow sheet resizing
        }
        // --- Bottom Shortcuts Overlay ---
        .overlay(alignment: .bottom) {
             HStack {
                Button {} label: { Image(systemName: "flashlight.on.fill").imageScale(.large) }
                Spacer()
                Button {} label: { Image(systemName: "camera.fill").imageScale(.large) }
            }
             .buttonStyle(.plain)
            .font(.title2)
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .shadow(radius: 2)
        }
    }

    // --- Action Functions ---

    // Function to set the state for showing the sheet
    private func activateSheet(for destination: NotificationDestination) {
        activeSheet = destination // Setting this triggers the .sheet modifier
    }

    // Function to remove a notification from the list
    private func removeNotification(id: UUID) {
        withAnimation(.easeOut(duration: 0.3)) {
            notifications.removeAll { $0.id == id }
            // If removing the last "visible" notification in collapsed view, we might want to adjust logic
             // e.g., if notifications.count <= maxVisibleNotifications { showCollapsed = false }
        }
         // Basic haptic feedback for dismiss action
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}

// --- Previews ---
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
#endif
