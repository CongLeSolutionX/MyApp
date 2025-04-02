//
//  PartiesView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// --- Placeholder Content Views ---
// These represent the actual views that would display content for each tab.

struct PartiesView: View {
    var body: some View {
        NavigationView { // Added for title context in sidebar view
            List {
                Text("Karaoke Party @ WWDC '24")
                Text("Team Karaoke Night - July")
                Text("Retro Theme Party - August")
            }
            .navigationTitle("Parties")
        }
    }
}

struct PlanningView: View {
    var body: some View {
        NavigationView {
            Text("Planning Tools and Checklists")
                .navigationTitle("Planning")
        }
    }
}

struct AttendanceView: View {
    var body: some View {
        NavigationView {
            Text("Track Attendance and RSVPs")
                .navigationTitle("Attendance")
        }
    }
}

struct SongListView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Bohemian Rhapsody")
                Text("Don't Stop Believin'")
                Text("Sweet Caroline")
                Text("Wannabe")
            }
            .navigationTitle("Song List")
        }
    }
}

// --- Main TabView Implementation ---

struct AdaptiveTabViewExample: View {
    // State to hold the user's customizations (like tab order/visibility)
    @State private var customization = TabViewCustomization()

    var body: some View {
        // Use the new type-safe TabView initializer
        TabView {
            // Define each Tab with a title, optional system image, and content view
            Tab("Parties", systemImage: "party.popper.fill") {
                PartiesView()
            }
            // Assign a unique and stable ID for customization persistence
            .customizationID("com.yourapp.tabs.parties")

            Tab("Planning", systemImage: "list.clipboard.fill") {
                PlanningView()
            }
            .customizationID("com.yourapp.tabs.planning")

            Tab("Attendance", systemImage: "person.3.fill") {
                AttendanceView()
            }
            .customizationID("com.yourapp.tabs.attendance")

            Tab("Song List", systemImage: "music.note.list") {
                SongListView()
            }
            .customizationID("com.yourapp.tabs.songlist")

            // Add more tabs as needed...
        }
        // Apply the style that enables switching between tab bar and sidebar
        .tabViewStyle(.sidebarAdaptable)
        // Bind the customization state to allow users to reorder/hide tabs
        // This enables the "Edit" button functionality in the sidebar view
        .tabViewCustomization($customization)
    }
}

// --- Preview Provider ---

#Preview {
    AdaptiveTabViewExample()
    // Recommended to preview on iPad or Mac target to see sidebar behavior
}

// --- Notes on Customization ---

/*
 - TabViewCustomization: Stores the user's preferences for tab order and visibility.
   SwiftUI handles the persistence automatically when bound correctly.
 - .customizationID(_:): Essential for identifying tabs across sessions so
   customizations can be reapplied correctly. Use reverse-DNS or similar unique strings.
 - Programmatic Control: You can observe and modify the `customization` state
   to programmatically change the available or visible tabs if needed, though common
   use cases rely on the user-driven customization via the sidebar's "Edit" button.
*/
