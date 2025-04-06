//
//  PrivacyView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
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
        case .info: return .blue
        }
    }
}

struct NotificationSite {
    let id = UUID()
    let name: String
    let detail: String
    let faviconName: String // Placeholder for actual favicon handling
}

struct PermissionSite {
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
                .frame(width: 20, alignment: .center)
            Text(item.name)
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
                .font(.title3)
                .padding(.top, 2) // Align icon better with text

            VStack(alignment: .leading, spacing: 2) {
                Text(status.title)
                    .font(.system(size: 14, weight: .medium))
                Text(status.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
             Spacer() // Push content to the left
        }
        .padding(12)
        .background(Color(.systemGray6)) // Subtle background like Chrome's cards
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 0.5) // Subtle border
        )
       // .frame(maxWidth: .infinity) // Allow card to take available width in HStack
    }
}

struct RecommendationHeader: View {
    let title: String
    let buttonLabel: String?
    let buttonAction: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
            Spacer()
            if let label = buttonLabel, let action = buttonAction {
                Button(label, action: action)
                    .buttonStyle(.bordered) // Simple bordered button style
                     .controlSize(.small)
                     .tint(.gray) // Match subtle button color
            }
        }
        .padding(.vertical, 8)
    }
}

struct NotificationSiteView: View {
    let site: NotificationSite

    var body: some View {
        HStack(spacing: 12) {
            // Placeholder for Favicon
            Image(systemName: site.faviconName)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 20, height: 20)
                 .foregroundColor(.gray)
                 .clipShape(Circle()) // Common favicon style

            VStack(alignment: .leading, spacing: 2) {
                Text(site.name).font(.system(size: 14))
                Text(site.detail).font(.system(size: 12)).foregroundColor(.gray)
            }
            Spacer()
            // Block/Dismiss icon (optional based on screenshot interpretation)
             Image(systemName: "nosign") // Example icon
                 .foregroundColor(.gray)
                 .padding(.trailing, 5) // Space before ellipsis

            Image(systemName: "ellipsis") // More options
                 .foregroundColor(.gray)

        }
        .padding(12)
        .background(Color(.systemGray6)) // Card background
        .cornerRadius(8)
         .overlay(
             RoundedRectangle(cornerRadius: 8)
                 .stroke(Color(.systemGray4), lineWidth: 0.5) // Subtle border
         )
    }
}

struct PermissionSiteView: View {
     let site: PermissionSite

     var body: some View {
         HStack(spacing: 12) {
             // Placeholder for Favicon
             Image(systemName: site.faviconName) // Use a generic icon or site initial
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 20, height: 20)
                 .foregroundColor(.gray)
                 .background(Color(.systemGray5)) // Simple background
                 .clipShape(RoundedRectangle(cornerRadius: 4)) // Common favicon shape

             VStack(alignment: .leading, spacing: 2) {
                 Text(site.name).font(.system(size: 14))
                 Text(site.detail).font(.system(size: 12)).foregroundColor(.gray)
             }
             Spacer()
             Image(systemName: "arrow.uturn.backward") // Undo icon
                 .foregroundColor(.blue)
                 .font(.system(size: 16)) // Slightly smaller icon
         }
          .padding(.horizontal, 12) // Padding inside the list item
          .padding(.vertical, 8)
         // No card background needed if part of a List section? Or add if desired.
     }
}

// --- Main Views ---

struct SidebarView: View {
    let items: [SidebarItem]
    @Binding var selectedItemId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Placeholder for grouping, omitted for simplicity
            ForEach(items) { item in
                SidebarItemView(item: item, isSelected: item.id == selectedItemId)
                    .onTapGesture {
                        selectedItemId = item.id
                    }
            }
            Spacer() // Pushes items to the top
        }
        .padding(.top)
        .padding(.horizontal, 8) // Padding for the sidebar container
        .frame(width: 250) // Fixed width for the sidebar
        .background(Color(.systemGray6)) // Background color for the sidebar area
    }
}

struct SafetyCheckView: View {

    // Placeholder Data
     let safetyStatuses: [SafetyStatus] = [
         .init(title: "3 weak passwords", subtitle: "Create strong passwords", iconName: "exclamationmark.triangle.fill", statusType: .warning),
         .init(title: "Chrome is up to date", subtitle: "Checked just now", iconName: "checkmark.circle.fill", statusType: .check),
         .init(title: "Safe Browsing is on", subtitle: "You're getting standard protection", iconName: "checkmark.circle.fill", statusType: .check)
     ]

    let notificationSites: [NotificationSite] = [
         .init(name: "baydailymedia.com", detail: "About 8 notifications a day", faviconName: "newspaper.fill")
     ]

     let permissionSites: [PermissionSite] = [
         .init(name: "magazineglam.com", detail: "Removed Location, Camera, Microphone", faviconName: "text.alignleft"),
         .init(name: "gurushape.com", detail: "Removed Location", faviconName: "globe.americas.fill")
     ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { // Increased spacing between sections
                // Header
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Safety Check")
                        .font(.system(size: 18, weight: .semibold)) // Slightly larger title
                    Spacer()
                }
                .padding(.bottom, 10)

                // Safety at a glance section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Safety at a glance")
                        .font(.system(size: 15, weight: .medium))
                         .padding(.bottom, 4)

                    HStack(spacing: 15) { // Spacing between cards
                         ForEach(safetyStatuses, id: \.id) { status in
                            SafetyStatusCard(status: status)
                                //.frame(maxWidth: .infinity) // Flexible width
                        }
                    }
                }

                // Safety recommendations Section
                VStack(alignment: .leading, spacing: 15) { //Consistent spacing
                    Text("Safety recommendations")
                         .font(.system(size: 16, weight: .medium)) // Main section heading
                         .padding(.bottom, 5)

                    // Notifications Sub-section
                    VStack(alignment: .leading, spacing: 10) { // Spacing within sub-section
                        RecommendationHeader(
                             title: "Review 1 site that recently sent a lot of notifications",
                             buttonLabel: "Block all",
                             buttonAction: { print("Block all notifications tapped") }
                         )

                        ForEach(notificationSites) { site in
                            NotificationSiteView(site: site)
                         }
                    }
                    .padding(15) // Padding around the sub-section content
                    .background(Color.white) // White background for the card section
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2) // Subtle shadow

                    // Permissions Sub-section
                    VStack(alignment: .leading, spacing: 10) {
                        RecommendationHeader(
                             title: "Permissions removed from 2 sites",
                             buttonLabel: "Got it",
                             buttonAction: { print("Got it tapped") }
                        )

                        // Use a List-like structure without actual List for custom rows
                        VStack(alignment: .leading, spacing: 0) { // No spacing between items, handled by padding
                            ForEach(permissionSites) { site in
                                PermissionSiteView(site: site)
                                if site.id != permissionSites.last?.id { // Add divider between items
                                     Divider().padding(.leading, 44) // Indent divider past icon
                                }
                            }
                         }
                         .background(Color(.systemGray6)) // Background for the list area
                         .cornerRadius(8)
                         .overlay(
                             RoundedRectangle(cornerRadius: 8)
                                 .stroke(Color(.systemGray4), lineWidth: 0.5) // Border
                         )
                    }
                     .padding(15) // Padding around the sub-section content
                     .background(Color.white) // White background for the card section
                     .cornerRadius(10)
                     .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2) // Subtle shadow

                }

            }
            .padding() // Overall padding for the content area
        }
         .background(Color(.systemGray5).ignoresSafeArea()) // Background for the entire content area
    }
}

struct PrivacyView: View {
    // Placeholder Data for Sidebar
    let sidebarItems: [SidebarItem] = [
        .init(name: "You and Google", iconName: "person.circle"),
        .init(name: "Autofill and passwords", iconName: "keyboard"),
        .init(name: "Privacy and security", iconName: "shield.lefthalf.filled"), // Selected
        .init(name: "Performance", iconName: "gauge.medium"),
        .init(name: "Appearance", iconName: "paintbrush"),
        .init(name: "Search engine", iconName: "magnifyingglass"),
        .init(name: "Default browser", iconName: "square.grid.2x2"),
        .init(name: "On startup", iconName: "power"),
        .init(name: "Languages", iconName: "globe"),
        .init(name: "Downloads", iconName: "arrow.down.circle"),
        .init(name: "Accessibility", iconName: "figure.walk"),
        .init(name: "System", iconName: "gearshape"),
        .init(name: "Reset settings", iconName: "arrow.counterclockwise"),
        .init(name: "Extensions", iconName: "puzzlepiece.extension"),
        .init(name: "About Chrome", iconName: "info.circle")
    ]

    // Find the ID of the "Privacy and security" item to pre-select it
     // Note: In a real app, selection would likely be dynamic based on user interaction
    @State private var selectedItemId: UUID? = {
        SidebarItem(name: "Privacy and security", iconName: "shield.lefthalf.filled").id // Example initial selection
    }()

    // Find the ID to initialize the selected state
    init() {
        // Find the actual ID of the item to select initially
        _selectedItemId = State(initialValue: sidebarItems.first(where: { $0.name == "Privacy and security" })?.id)
    }

    var body: some View {
        HStack(spacing: 0) { // No spacing between sidebar and content
            SidebarView(items: sidebarItems, selectedItemId: $selectedItemId)

            // Determine Content View based on selection (simplified)
            if selectedItemId == sidebarItems.first(where: { $0.name == "Privacy and security" })?.id {
                 SafetyCheckView()
             } else {
                 // Placeholder for other settings views
                 Text("Selected: \(sidebarItems.first(where: { $0.id == selectedItemId })?.name ?? "None")")
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .background(Color(.systemGray5).ignoresSafeArea())
             }
        }
         .frame(minWidth: 800, minHeight: 600) // Example minimum window size
    }
}

// --- Preview ---

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
