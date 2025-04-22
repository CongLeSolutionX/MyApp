////
////  NotificationView.swift
////  MyApp
////
////  Created by Cong Le on 4/21/25.
////
//
//import SwiftUI
//
//// 1. Data Model for a Notification
//struct NotificationData: Identifiable {
//    let id = UUID()
//    let iconName: String // System name for the icon (e.g., "calendar", "message.fill")
//    let title: String
//    let description: String
//    let timeString: String
//}
//
//// 2. View for a Single Notification Row
//struct NotificationView: View {
//    let notification: NotificationData
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            // Icon
//            Image(systemName: notification.iconName)
//                .font(.title3) // Adjust size as needed
//                .frame(width: 30, height: 30) // Consistent icon area
//                .foregroundColor(.primary.opacity(0.7)) // Subtle icon color
//                .padding(6)
//                .background(Color.gray.opacity(0.15)) // Subtle background for icon
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//
//            // Text Content (Title & Description)
//            VStack(alignment: .leading, spacing: 2) {
//                Text(notification.title)
//                    .font(.headline)
//                    .foregroundColor(.primary) // Use primary color, material adjusts look
//
//                Text(notification.description)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary) // Use secondary color for description
//                    .lineLimit(2) // Allow up to two lines for description
//            }
//
//            Spacer() // Pushes timestamp to the right
//
//            // Timestamp
//            Text(notification.timeString)
//                .font(.caption)
//                .foregroundColor(.secondary) // Dimmed timestamp color
//                .padding(.top, 2) // Align slightly below the title's baseline
//        }
//        .padding(12) // Inner padding for content
//        .background(.ultraThinMaterial) // Translucent background
//        .clipShape(RoundedRectangle(cornerRadius: 16)) // Rounded corners
//        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2) // Subtle shadow
//    }
//}
//
//// 3. Main Content View to Display the Stack
//struct ContentView: View {
//    // Mock data simulating incoming notifications
//    @State private var notifications: [NotificationData] = [
//        NotificationData(iconName: "calendar", title: "Meeting Reminder", description: "Project Sync-up in 15 minutes", timeString: "9:45 AM"),
//        NotificationData(iconName: "message.fill", title: "John Appleseed", description: "Hey, are you free for lunch?", timeString: "9:41 AM"),
//        NotificationData(iconName: "envelope.fill", title: "Newsletter", description: "Weekly SwiftUI Tips & Tricks", timeString: "9:30 AM"),
//        NotificationData(iconName: "bell.fill", title: "Reminder", description: "Pick up dry cleaning", timeString: "Yesterday")
//    ]
//
//    // State for simulating the stacked/collapsed view (optional enhancement)
//    @State private var showCollapsed = false
//    let maxVisibleNotifications = 2 // How many show before collapsing summary appears
//
//    var body: some View {
//        ZStack {
//            // Background (Simulating Lock Screen Wallpaper)
//            Image(systemName: "photo.fill") // Placeholder for actual wallpaper
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//                .overlay(.ultraThinMaterial.opacity(0.5)) // Slight blur overlay
//
//            // Notification Area
//            ScrollView { // Use ScrollView if list can exceed screen height
//                VStack(spacing: 8) { // Spacing between notifications
//                    // Sample Date/Time like Lock Screen (for context)
//                    VStack {
//                        Text("Monday, June 6")
//                             .font(.title3)
//                             .fontWeight(.medium)
//                             .foregroundColor(.white)
//                             .shadow(radius: 2)
//                        Text("9:41")
//                            .font(.system(size: 80, weight: .thin))
//                             .foregroundColor(.white)
//                             .shadow(radius: 2)
//
//                    }
//                    .padding(.top, 40)
//                    .padding(.bottom, 20)
//
//                    // --- Display Notifications ---
//                    if showCollapsed && notifications.count > maxVisibleNotifications {
//                        // Collapsed View: Show top ones + summary
//                        ForEach(notifications.prefix(maxVisibleNotifications)) { notification in
//                            NotificationView(notification: notification)
//                        }
//                        // Summary Line (similar style but different content)
//                        Text("+\(notifications.count - maxVisibleNotifications) more from Apps...") // Customize as needed
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 12)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(.ultraThinMaterial)
//                            .clipShape(RoundedRectangle(cornerRadius: 16))
//                            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
//
//                    } else {
//                        // Expanded View: Show all
//                        ForEach(notifications) { notification in
//                            NotificationView(notification: notification)
//                        }
//                    }
//
//                    // Button to toggle collapsed state (for demo)
//                    Button(showCollapsed ? "Show All" : "Show Less") {
//                         withAnimation(.spring()) {
//                            showCollapsed.toggle()
//                        }
//                    }
//                    .buttonStyle(.bordered)
//                    .padding(.top)
//                    .tint(.white.opacity(0.8))
//
//                }
//                .padding(.horizontal, 10) // Inset the notification stack from edges
//                .padding(.bottom, 100) // Space at the bottom above dock/shortcuts
//            }
//        }
//        // Simulating bottom shortcuts (optional, for visual context)
//        .overlay(alignment: .bottom) {
//             HStack {
//                Image(systemName: "flashlight.on.fill")
//                Spacer()
//                Image(systemName: "camera.fill")
//            }
//            .font(.title2)
//            .foregroundColor(.white)
//            .padding(.horizontal, 40)
//            .padding(.bottom, 40)
//            .shadow(radius: 2)
//        }
//    }
//}
//
//// --- Previews ---
//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .preferredColorScheme(.dark) // Preview in dark mode often matches lock screen
//    }
//}
//#endif
