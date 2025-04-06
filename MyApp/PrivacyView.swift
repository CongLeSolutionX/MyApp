//
//  PrivacyView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//
//
//import SwiftUI
//
//// --- Data Models (Placeholders) ---
//
//struct SidebarItem: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let iconName: String
//}
//
//struct SafetyStatus {
//    enum StatusType { case warning, check, info }
//    let id = UUID()
//    let title: String
//    let subtitle: String
//    let iconName: String
//    let statusType: StatusType
//
//    var iconColor: Color {
//        switch statusType {
//        case .warning: return .orange
//        case .check: return .green
//        case .info: return .blue
//        }
//    }
//}
//
//struct NotificationSite {
//    let id = UUID()
//    let name: String
//    let detail: String
//    let faviconName: String // Placeholder for actual favicon handling
//}
//
//struct PermissionSite: Identifiable {
//    let id = UUID()
//    let name: String
//    let detail: String
//    let faviconName: String // Placeholder
//}
//
//// --- Reusable View Components ---
//
//struct SidebarItemView: View {
//    let item: SidebarItem
//    let isSelected: Bool
//
//    var body: some View {
//        HStack {
//            Image(systemName: item.iconName)
//                .frame(width: 20, alignment: .center)
//            Text(item.name)
//            Spacer()
//        }
//        .padding(.vertical, 8)
//        .padding(.horizontal, 12)
//        .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
//        .foregroundColor(isSelected ? .blue : .primary)
//        .cornerRadius(8)
//    }
//}
//
//struct SafetyStatusCard: View {
//    let status: SafetyStatus
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            Image(systemName: status.iconName)
//                .foregroundColor(status.iconColor)
//                .font(.title3)
//                .padding(.top, 2) // Align icon better with text
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(status.title)
//                    .font(.system(size: 14, weight: .medium))
//                Text(status.subtitle)
//                    .font(.system(size: 12))
//                    .foregroundColor(.gray)
//            }
//            Spacer() // Push content to the left
//        }
//        .padding(12)
//        .background(Color(.systemGray6)) // Subtle background like Chrome's cards
//        .cornerRadius(8)
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color(.systemGray4), lineWidth: 0.5) // Subtle border
//        )
//        // .frame(maxWidth: .infinity) // Allow card to take available width in HStack
//    }
//}
//
//struct RecommendationHeader: View {
//    let title: String
//    let buttonLabel: String?
//    let buttonAction: (() -> Void)?
//
//    var body: some View {
//        HStack {
//            Text(title)
//                .font(.system(size: 15, weight: .medium))
//                 .lineLimit(2) // Allow title to wrap slightly if needed
//                 .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
//            Spacer()
//            if let label = buttonLabel, let action = buttonAction {
//                Button(label, action: action)
//                    .buttonStyle(.bordered) // Simple bordered button style
//                    .controlSize(.small)
//                    .tint(.gray) // Match subtle button color
//                    .layoutPriority(1) // Prevent button from being compressed too much
//            }
//        }
//        .padding(.vertical, 8)
//    }
//}
//
//struct NotificationSiteView: View {
//    let site: NotificationSite
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // Placeholder for Favicon
//            Image(systemName: site.faviconName)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 20, height: 20)
//                .foregroundColor(.gray)
//                .clipShape(Circle()) // Common favicon style
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(site.name).font(.system(size: 14))
//                Text(site.detail).font(.system(size: 12)).foregroundColor(.gray)
//            }
//            Spacer()
//            // Block/Dismiss icon (optional based on screenshot interpretation)
//            Image(systemName: "nosign") // Example icon
//                .foregroundColor(.gray)
//                .padding(.trailing, 5) // Space before ellipsis
//
//            Image(systemName: "ellipsis") // More options
//                .foregroundColor(.gray)
//
//        }
//        .padding(12)
//        .background(Color(.systemGray6)) // Card background
//        .cornerRadius(8)
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color(.systemGray4), lineWidth: 0.5) // Subtle border
//        )
//    }
//}
//
//struct PermissionSiteView: View {
//    let site: PermissionSite
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // Placeholder for Favicon
//            Image(systemName: site.faviconName) // Use a generic icon or site initial
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 20, height: 20)
//                .foregroundColor(.gray)
//                .background(Color(.systemGray5)) // Simple background
//                .clipShape(RoundedRectangle(cornerRadius: 4)) // Common favicon shape
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(site.name).font(.system(size: 14))
//                Text(site.detail).font(.system(size: 12)).foregroundColor(.gray)
//            }
//            Spacer()
//            Image(systemName: "arrow.uturn.backward") // Undo icon
//                .foregroundColor(.blue)
//                .font(.system(size: 16)) // Slightly smaller icon
//        }
//        .padding(.horizontal, 12) // Padding inside the list item
//        .padding(.vertical, 8)
//        // No card background needed if part of a List section? Or add if desired.
//    }
//}
//
//// --- Refactored Subviews for SafetyCheckView ---
//
//struct SafetyCheckHeaderView: View {
//    var body: some View {
//        HStack {
//            Image(systemName: "arrow.left")
//            Text("Safety Check")
//                .font(.system(size: 18, weight: .semibold)) // Consistent title size
//            Spacer()
//        }
//        .padding(.bottom, 10)
//    }
//}
//
//struct SafetyGlanceView: View {
//    let safetyStatuses: [SafetyStatus]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Safety at a glance")
//                .font(.system(size: 15, weight: .medium))
//                .padding(.bottom, 4)
//
//            HStack(spacing: 15) { // Spacing between cards
//                ForEach(safetyStatuses, id: \.id) { status in
//                    SafetyStatusCard(status: status)
//                       // Removed frame max width - let HStack distribute space
//                }
//            }
//        }
//    }
//}
//
//struct NotificationRecommendationsView: View {
//    let notificationSites: [NotificationSite]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) { // Spacing within sub-section
//            RecommendationHeader(
//                title: "Review 1 site that recently sent a lot of notifications",
//                buttonLabel: "Block all",
//                buttonAction: { print("Block all notifications tapped") }
//            )
//            // Example detail text - add if needed based on original screenshot
//            Text("You can stop this site from sending future notifications")
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding(.bottom, 5) // Spacing after detail text
//
////            ForEach(notificationSites) { site in
////                NotificationSiteView(site: site)
////            }
//        }
//        .padding(15) // Padding around the sub-section content
//        .background(Color.white) // White background for the card section
//        .cornerRadius(10)
//        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2) // Subtle shadow
//    }
//}
//
//struct PermissionRecommendationsView: View {
//    let permissionSites: [PermissionSite]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            RecommendationHeader(
//                title: "Permissions removed from 2 sites",
//                buttonLabel: "Got it",
//                buttonAction: { print("Got it tapped") }
//            )
//            // Example detail text
//             Text("To protect your data, permissions were removed from sites you haven't visited recently")
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding(.bottom, 5) // Spacing after detail text
//
//
//            // Use a List-like structure without actual List for custom rows
//            VStack(alignment: .leading, spacing: 0) { // No spacing between items, handled by padding
//                ForEach(permissionSites) { site in
//                    PermissionSiteView(site: site)
//                    // Add divider betwee n items only if it's not the last one
//                    if site.id != permissionSites.last?.id {
//                        Divider().padding(.leading, 44) // Indent divider past icon
//                    }
//                }
//            }
//            .background(Color(.systemGray6)) // Background for the list area
//            .cornerRadius(8)
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color(.systemGray4), lineWidth: 0.5) // Border
//            )
//        }
//        .padding(15) // Padding around the sub-section content
//        .background(Color.white) // White background for the card section
//        .cornerRadius(10)
//        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2) // Subtle shadow
//    }
//}
//
//// Optional: Combine recommendation subviews into one parent recommendation view
//struct SafetyRecommendationsView: View {
//    let notificationSites: [NotificationSite]
//    let permissionSites: [PermissionSite]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) { // Increased spacing between recommendation cards
//            Text("Safety recommendations")
//                .font(.system(size: 16, weight: .medium)) // Main section heading
//                .padding(.bottom, 5)
//
//            // Use the further broken down views
//            NotificationRecommendationsView(notificationSites: notificationSites)
//            PermissionRecommendationsView(permissionSites: permissionSites)
//        }
//    }
//}
//
//
//// --- Main Content View: Safety Check (Refactored) ---
//
//struct SafetyCheckView: View {
//
//    // Placeholder Data - stays here as it's specific to this screen setup
//    let safetyStatuses: [SafetyStatus] = [
//        .init(title: "3 weak passwords", subtitle: "Create strong passwords", iconName: "exclamationmark.triangle.fill", statusType: .warning),
//        .init(title: "Chrome is up to date", subtitle: "Checked just now", iconName: "checkmark.circle.fill", statusType: .check),
//        .init(title: "Safe Browsing is on", subtitle: "You're getting standard protection", iconName: "checkmark.circle.fill", statusType: .check)
//    ]
//
//    let notificationSites: [NotificationSite] = [
//        .init(name: "baydailymedia.com", detail: "About 8 notifications a day", faviconName: "newspaper.fill") // Placeholder icon
//    ]
//
//    let permissionSites: [PermissionSite] = [
//        .init(name: "magazineglam.com", detail: "Removed Location, Camera, Microphone", faviconName: "text.bubble.fill"), // Placeholder icon
//        .init(name: "gurushape.com", detail: "Removed Location", faviconName: "globe.americas.fill") // Placeholder icon
//    ]
//
//    // Simplified Body using refactored subviews
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 25) { // Spacing between major sections
//
//                SafetyCheckHeaderView()
//                SafetyGlanceView(safetyStatuses: safetyStatuses)
//                SafetyRecommendationsView(notificationSites: notificationSites, permissionSites: permissionSites) // Use combined recommendations view
//                Spacer() // Push content to top if scroll view has extra space
//
//            }
//            .padding() // Overall padding for the content area
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it takes available space
//        .background(Color(.systemGray5).ignoresSafeArea()) // Background for the content area
//    }
//}
//
//
//// --- Sidebar View ---
//
//struct SidebarView: View {
//    let items: [SidebarItem]
//    @Binding var selectedItemId: UUID?
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            // Placeholder for grouping (e.g., Sections), omitted for simplicity
//            // Add sections if needed visually separating groups of items
//
//            ForEach(items) { item in
//                SidebarItemView(item: item, isSelected: item.id == selectedItemId)
//                    .contentShape(Rectangle()) // Makes the whole row tappable
//                    .onTapGesture {
//                        selectedItemId = item.id
//                    }
//            }
//            Spacer() // Pushes items to the top
//        }
//        .padding(.top)
//        .padding(.horizontal, 8) // Padding for the sidebar container
//        .frame(width: 250) // Fixed width for the sidebar
//        .background(Color(.systemGray6).ignoresSafeArea(edges: .vertical)) // Background color for the sidebar area
//    }
//}
//
//// --- Top Level View ---
//
//struct PrivacyView: View {
//    // Placeholder Data for Sidebar
//    let sidebarItems: [SidebarItem] = [
//        .init(name: "You and Google", iconName: "person.circle"),
//        .init(name: "Autofill and passwords", iconName: "keyboard"),
//        .init(name: "Privacy and security", iconName: "shield.lefthalf.filled"), // Selected
//        .init(name: "Performance", iconName: "gauge.medium"),
//        .init(name: "Appearance", iconName: "paintbrush"),
//        .init(name: "Search engine", iconName: "magnifyingglass"),
//        .init(name: "Default browser", iconName: "square.grid.2x2"),
//        .init(name: "On startup", iconName: "power"),
//        .init(name: "Languages", iconName: "globe"),
//        .init(name: "Downloads", iconName: "arrow.down.circle"),
//        .init(name: "Accessibility", iconName: "figure.walk.circle"), // Adjusted icon slightly
//        .init(name: "System", iconName: "gearshape"),
//        .init(name: "Reset settings", iconName: "arrow.counterclockwise"),
//        .init(name: "Extensions", iconName: "puzzlepiece.extension"),
//        .init(name: "About Chrome", iconName: "info.circle")
//    ]
//
//    @State private var selectedItemId: UUID?
//
//    // Initialize the selected state
//    init() {
//        // Find the actual ID of the item to select initially
//        // Use _selectedItemId to set the initial value of the State variable
//        _selectedItemId = State(initialValue: sidebarItems.first(where: { $0.name == "Privacy and security" })?.id)
//    }
//
//    var body: some View {
//        HStack(spacing: 0) { // No spacing between sidebar and content
//            SidebarView(items: sidebarItems, selectedItemId: $selectedItemId)
//
//            // Determine Content View based on selection (simplified)
//            ZStack { // Use ZStack to easily switch views
//                // Show SafetyCheckView if it's the selected item
//                if selectedItemId == sidebarItems.first(where: { $0.name == "Privacy and security" })?.id {
//                    SafetyCheckView()
//                        .transition(.opacity) // Add a subtle transition if desired
//                } else {
//                    // Placeholder for other settings views
//                    VStack {
//                         Text("Selected:")
//                         Text(sidebarItems.first(where: { $0.id == selectedItemId })?.name ?? "None")
//                             .font(.title)
//                             .foregroundColor(.gray)
//                     }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color(.systemGray5).ignoresSafeArea())
//                     .transition(.opacity)
//                }
//            }
//            .animation(.default, value: selectedItemId) // Animate the change between views
//        }
//        .frame(minWidth: 800, minHeight: 600) // Example minimum window size
//        // Optional: Add a specific app title if running on macOS
//        // .navigationTitle("Settings") // Uncomment for macOS if appropriate
//    }
//}
//
//// --- App Entry Point (if this is the main content) ---
///*
// Uncomment this if this ContentView is the root of your app
// @main
// struct YourAppNameApp: App {
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//         }
//         // Add settings scene for macOS if needed
//         // #if os(macOS)
//         // Settings {
//         //     Text("App Settings View Placeholder")
//         // }
//         // #endif
//     }
// }
// */
//
//
//// --- Preview ---
//
//#Preview { // Use the newer #Preview macro
//    PrivacyView()
//}
//
import SwiftUI

// --- Data Models (Placeholders) ---

struct SidebarItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let iconName: String
}

struct SafetyStatus {
    enum StatusType { case warning, check, info }
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let statusType: StatusType

    var iconColor: Color {
        switch statusType {
        case .warning: return .orange
        case .check: return .green
        case .info: return .blue // Although not shown, good to have
        }
    }
}

struct NotificationSite: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let faviconName: String // Placeholder for actual favicon handling
}

struct PermissionSite: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let faviconName: String // Placeholder
}

// --- Reusable View Components ---

struct SidebarItemView: View {
    let item: SidebarItem
    let isSelected: Bool

    var body: some View {
        HStack {
            Image(systemName: item.iconName)
                .frame(width: 20, alignment: .center) // Consistent icon width
            Text(item.name)
                .font(.system(size: 14)) // Standard sidebar font size
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
        .foregroundColor(isSelected ? .blue : .primary)
        .cornerRadius(8)
    }
}

struct SafetyStatusCard: View {
    let status: SafetyStatus

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: status.iconName)
                .foregroundColor(status.iconColor)
                .font(.system(size: 18, weight: .medium)) // Slightly larger/bolder icon
                .frame(width: 20, alignment: .center) // Align icon frame
                .padding(.top, 3) // Fine-tune vertical alignment

            VStack(alignment: .leading, spacing: 2) {
                Text(status.title)
                    .font(.system(size: 14, weight: .medium))
                Text(status.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true) // Allow subtitle to wrap

            }
            Spacer() // Push content to the left
        }
        .padding(12) // Internal padding for the card content
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 0.5) // Subtle border
        )
        // Let the HStack in the parent distribute width
    }
}

struct RecommendationHeader: View {
    let title: String
    let buttonLabel: String?
    let buttonAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) { // Align based on text better
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .lineLimit(2) // Allow title to wrap slightly if needed
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion for wrapping
            Spacer()
            if let label = buttonLabel, let action = buttonAction {
                Button(label, action: action)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.gray)
                    .layoutPriority(1) // Prevent button from being compressed too much
            }
        }
        .padding(.vertical, 8) // Standard vertical padding for header row
        .padding(.horizontal, 0) // No extra horizontal needed if parent handles it
    }
}

struct NotificationSiteView: View {
    let site: NotificationSite

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: site.faviconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(.gray)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(site.name).font(.system(size: 14))
                Text(site.detail).font(.system(size: 12)).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "nosign")
                .foregroundColor(.gray)
                .padding(.trailing, 5)
            Image(systemName: "ellipsis")
                .foregroundColor(.gray)
        }
        .padding(12) // Internal padding for this specific row's content
        .background(Color(.systemGray6)) // Background for the site row
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 0.5) // Border for the site row
        )
    }
}

struct PermissionSiteView: View {
    let site: PermissionSite

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: site.faviconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(.gray)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            VStack(alignment: .leading, spacing: 2) {
                Text(site.name).font(.system(size: 14))
                Text(site.detail).font(.system(size: 12)).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "arrow.uturn.backward")
                .foregroundColor(.blue)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 12) // Horizontal padding within the row
        .padding(.vertical, 10)   // Slightly increased vertical padding for better spacing
    }
}

// --- Refactored Subviews for SafetyCheckView ---

struct SafetyCheckHeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "arrow.left")
                .font(.system(size: 17, weight: .medium)) // Match system back button look
            Text("Safety Check")
                .font(.system(size: 17, weight: .semibold)) // Standard iOS title size
            Spacer()
        }
        .padding(.bottom, 15) // More padding below header
    }
}

struct SafetyGlanceView: View {
    let safetyStatuses: [SafetyStatus]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Safety at a glance")
                .font(.headline) // Use standard headline font
                .padding(.bottom, 4)

            HStack(spacing: 15) {
                ForEach(safetyStatuses, id: \.id) { status in
                    SafetyStatusCard(status: status)
                }
            }
        }
    }
}

struct NotificationRecommendationsView: View {
    let notificationSites: [NotificationSite]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RecommendationHeader(
                title: "Review 1 site that recently sent a lot of notifications",
                buttonLabel: "Block all",
                buttonAction: { print("Block all notifications tapped") }
            )
            Text("You can stop this site from sending future notifications")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 5) // Spacing after detail text

            ForEach(notificationSites) { site in
                NotificationSiteView(site: site)
            }
        }
        .padding(15) // Padding around the sub-section content
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // Slightly adjusted shadow
    }
}

struct PermissionRecommendationsView: View {
    let permissionSites: [PermissionSite]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RecommendationHeader(
                title: "Permissions removed from 2 sites",
                buttonLabel: "Got it",
                buttonAction: { print("Got it tapped") }
            )
            Text("To protect your data, permissions were removed from sites you haven't visited recently")
                .font(.caption)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                .padding(.bottom, 5) // Spacing after detail text

            // List-like container for permission items
            VStack(alignment: .leading, spacing: 0) {
                ForEach(permissionSites) { site in
                    PermissionSiteView(site: site)
                    if site.id != permissionSites.last?.id {
                        Divider().padding(.leading, 44) // Indent divider consistently
                    }
                }
            }
            .background(Color(.systemGray6)) // Background for this list area
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 0.5) // Border for this list area
            )
        }
        .padding(15) // Padding around the sub-section content
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // Slightly adjusted shadow
    }
}

struct SafetyRecommendationsView: View {
    let notificationSites: [NotificationSite]
    let permissionSites: [PermissionSite]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) { // Consistent spacing between recommendation cards
            Text("Safety recommendations")
                .font(.headline) // Standard section headline
                .padding(.bottom, 5)

            NotificationRecommendationsView(notificationSites: notificationSites)
            PermissionRecommendationsView(permissionSites: permissionSites)
        }
    }
}

// --- Main Content View: Safety Check (Refactored) ---

struct SafetyCheckView: View {

    // Placeholder Data
    let safetyStatuses: [SafetyStatus] = [
        .init(title: "3 weak passwords", subtitle: "Create strong passwords", iconName: "exclamationmark.triangle.fill", statusType: .warning),
        .init(title: "Chrome is up to date", subtitle: "Checked just now", iconName: "checkmark.circle.fill", statusType: .check),
        .init(title: "Safe Browsing is on", subtitle: "You're getting standard protection", iconName: "checkmark.circle.fill", statusType: .check)
    ]
    let notificationSites: [NotificationSite] = [
        .init(name: "baydailymedia.com", detail: "About 8 notifications a day", faviconName: "newspaper.fill") // Placeholder icon
    ]
    let permissionSites: [PermissionSite] = [
        .init(name: "magazineglam.com", detail: "Removed Location, Camera, Microphone", faviconName: "text.bubble.fill"), // Placeholder icon
        .init(name: "gurushape.com", detail: "Removed Location", faviconName: "globe.americas.fill") // Placeholder icon
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) { // Spacing between major sections
                SafetyCheckHeaderView()
                SafetyGlanceView(safetyStatuses: safetyStatuses)
                SafetyRecommendationsView(notificationSites: notificationSites, permissionSites: permissionSites)
                Spacer() // Pushes content up if scroll view has space
            }
            .padding() // Standard padding around the entire ScrollView content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Use system grouped background
        .navigationBarHidden(true) // Hide navigation bar if this is the root view in a NavigationView
    }
}

// --- Sidebar View ---

struct SidebarView: View {
    let items: [SidebarItem]
    @Binding var selectedItemId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items) { item in
                 // Add Sections here if needed for visual grouping in the sidebar
                 // Section(header: Text("Section Title")) { ... }
                SidebarItemView(item: item, isSelected: item.id == selectedItemId)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedItemId = item.id
                    }
            }
            Spacer()
        }
        .padding(.top) // Padding at the top of the sidebar content
        .padding(.horizontal, 8)
        .frame(width: 250)
        .background(Color(.systemGray6).ignoresSafeArea(edges: .vertical))
    }
}

// --- Top Level View ---

struct PrivacyView: View {
    // Sidebar Data
    let sidebarItems: [SidebarItem] = [
        .init(name: "You and Google", iconName: "person.circle"),
        .init(name: "Autofill and passwords", iconName: "keyboard"),
        .init(name: "Privacy and security", iconName: "shield.lefthalf.filled"),
        .init(name: "Performance", iconName: "gauge.medium"),
        .init(name: "Appearance", iconName: "paintbrush"),
        .init(name: "Search engine", iconName: "magnifyingglass"),
        .init(name: "Default browser", iconName: "square.grid.2x2"),
        .init(name: "On startup", iconName: "power"),
        .init(name: "Languages", iconName: "globe"),
        .init(name: "Downloads", iconName: "arrow.down.circle"),
        .init(name: "Accessibility", iconName: "figure.walk.circle"),
        .init(name: "System", iconName: "gearshape"),
        .init(name: "Reset settings", iconName: "arrow.counterclockwise"),
        .init(name: "Extensions", iconName: "puzzlepiece.extension"),
        .init(name: "About Chrome", iconName: "info.circle")
    ]
    @State private var selectedItemId: UUID?

    init() {
        // Pre-select "Privacy and security"
        _selectedItemId = State(initialValue: sidebarItems.first(where: { $0.name == "Privacy and security" })?.id)
    }

    var body: some View {
        // Use NavigationView for sidebar/detail pattern on macOS/iPadOS if needed
        // On iOS, you might use TabView or a custom container
        HStack(spacing: 0) {
            SidebarView(items: sidebarItems, selectedItemId: $selectedItemId)

            ZStack {
                // Determine Content View based on selection
                if selectedItemId == sidebarItems.first(where: { $0.name == "Privacy and security" })?.id {
                    SafetyCheckView()
                         .transition(.opacity.animation(.easeInOut(duration: 0.2))) // Smoother transition
                } else {
                    // Placeholder for other views
                    VStack {
                         Text("Selected:")
                         Text(sidebarItems.first(where: { $0.id == selectedItemId })?.name ?? "None")
                             .font(.title)
                             .foregroundColor(.gray)
                     }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
                     .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                }
            }
           // .animation(.default, value: selectedItemId) // Apply animation to the ZStack content change
        }
        .frame(minWidth: 800, minHeight: 600) // Example minimum size for macOS/iPadOS
        // .navigationTitle("Settings") // Set window title if needed
    }
}

// --- App Entry Point (Example) ---
/*
 @main
 struct SettingsAppCloneApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
         #if os(macOS)
         Settings {
             // Add macOS specific settings view if needed
             Text("App Settings Placeholder")
                 .padding()
                 .frame(width: 300, height: 200)
         }
         #endif
     }
 }
 */

// --- Preview ---

#Preview { // Use the #Preview macro
    PrivacyView()
}
