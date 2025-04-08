//
//  UpcomingEventsView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import Foundation

struct Event: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var location: String? // Optional location
    var emoji: String // For visual flair
    var attendeeCount: Int = Int.random(in: 5...50) // Example random attendees

    // Helper for formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a" // e.g., Sep 15, 9:30 AM
        return formatter.string(from: date)
    }
}

import SwiftUI

// MARK: - Main View

struct UpcomingEventsView: View {

    // State Variables
    @State private var events: [Event] = [] // Start empty or load mock data
    @State private var showingCreateEventSheet = false

    // Constants for Styling/Configuration
    let toolbarButtonBackgroundColor = Color(white: 0.2)
    let toolbarButtonSize: CGFloat = 32
    
    
    // --- ADD INITIALIZERS ---

    // 1. Default Initializer (for normal use and the empty preview)
    //    Needed because defining any custom init removes the implicit default one.
    //    We MUST initialize ALL @State properties here.
    init() {
        _events = State(initialValue: []) // Initialize with empty array
        _showingCreateEventSheet = State(initialValue: false)
    }

    // 2. Initializer for passing initial events (for the mock data preview)
    //    We MUST initialize ALL @State properties here too.
    init(events: [Event]) {
        _events = State(initialValue: events) // Use the passed-in events
        _showingCreateEventSheet = State(initialValue: false) // Still default to false
    }

    // --- END OF ADDED INITIALIZERS ---
    
    

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color(white: 0.05).ignoresSafeArea()

                // Main Content Area
                Group { // Group allows switching content easily
                    if events.isEmpty {
                        EmptyStateView(createAction: {
                            showingCreateEventSheet = true
                        })
                        .padding(.horizontal) // Apply padding here for the Vstack inside
                    } else {
                        EventListView(events: events)
                    }
                }
            }
            // Custom Toolbar
            .toolbar {
                // Leading Item: Title and Arrow
                ToolbarItem(placement: .navigationBarLeading) {
                    // For now, this remains visual, could add filtering later
                    HStack {
                        Text("Upcoming")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                    .accessibilityElement(children: .combine) // Better for accessibility
                    .accessibilityLabel("Upcoming Events Filter")
                    .accessibilityHint("Tap to change event filter, currently showing upcoming.")
                }

                // Trailing Items: Action Buttons
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Plus Button (Create Event)
                        Button {
                            showingCreateEventSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: toolbarButtonSize, height: toolbarButtonSize)
                                .background(toolbarButtonBackgroundColor)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Create New Event")

                        // Profile Button (Navigation)
                        NavigationLink {
                            // Destination View
                            ProfileView()
                        } label: {
                             Text("👻")
                                .font(.title3)
                                .frame(width: toolbarButtonSize, height: toolbarButtonSize)
                                .background(toolbarButtonBackgroundColor)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("View Profile")
                    }
                }
            }
            .toolbarBackground(Color(white: 0.05), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationTitle("") // Hide default title, we use custom leading item
            .navigationBarTitleDisplayMode(.inline) // Keep consistent layout
            .onAppear(perform: loadMockData) // Load data when view appears
            // Sheet for Creating Event
            .sheet(isPresented: $showingCreateEventSheet) {
                CreateEventView(events: $events) // Pass binding to potentially add event
            }
        }
    }

    // Function to load mock data (can be called onAppear)
    private mutating func loadMockData() {
        // Add delay to simulate loading and show empty state initially
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
             // Uncomment the next line to always see the event list
            // if events.isEmpty {
             self.events = [
                Event(title: "SwiftUI Workshop", date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, location: "Online", emoji: "💻"),
                Event(title: "Team Lunch", date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, location: "Downtown Cafe", emoji: "🍕"),
                Event(title: "Design Review", date: Calendar.current.date(byAdding: .hour, value: 24*7 + 2, to: Date())!, emoji: "🎨"), // No location
                Event(title: "Weekend Hike", date: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, location: "Mountain Trail", emoji: "⛰️", attendeeCount: 15)
             ]
            // }
        }
    }
}

// MARK: - Empty State Subview

struct EmptyStateView: View {
    var createAction: () -> Void // Closure to trigger sheet presentation

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)

                Text("No Upcoming Events")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Upcoming events, whether you're a host or a guest, will appear here.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20) // Adjusted padding slightly

                Button(action: createAction) { // Use the passed-in action
                    Text("Create Event")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .clipShape(Capsule())
                }
                .padding(.top, 10)
            }
            Spacer()
            Spacer() // Adjust spacing ratio if needed
        }
    }
}

// MARK: - Event List Subview

struct EventListView: View {
    let events: [Event]

    var body: some View {
        List {
            ForEach(events) { event in
                EventRowView(event: event)
                    // Remove default padding/background for custom look
                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                    .listRowBackground(Color.clear) // Make row background transparent
                    .listRowSeparator(.hidden) // Hide default separators
            }
        }
        .listStyle(.plain) // Use plain style to remove default list styling
        .background(Color.clear) // Ensure List background is clear
        .scrollContentBackground(.hidden) // New iOS 16 way to make List background clear
    }
}

// MARK: - Event Row Subview

struct EventRowView: View {
    let event: Event

    var body: some View {
        HStack(spacing: 15) {
            Text(event.emoji)
                .font(.largeTitle)
                .padding(8)
                .background(Color(white: 0.15).opacity(0.8)) // Slightly lighter background for emoji
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(event.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                if let location = event.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.lightGray) // Use a specific light gray
                }
            }

            Spacer() // Pushes content left and attendee count right

            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                Text("\(event.attendeeCount)")
            }
            .font(.caption)
            .foregroundColor(.systemTeal) // Example color
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.systemTeal.opacity(0.15))
            .clipShape(Capsule())
        }
        .padding(.vertical, 8) // Add vertical padding to the HStack itself
        .background(Color(white: 0.1)) // Background for the entire row
        .cornerRadius(10)
    }
}

// MARK: - Create Event Sheet View (Placeholder)

struct CreateEventView: View {
    @Binding var events: [Event] // Binding to potentially add a new event
    @Environment(\.dismiss) var dismiss // To close the sheet

    // Simple state for form fields (not fully implemented)
    @State private var newEventTitle: String = ""
    @State private var newEventDate: Date = Date()

    var body: some View {
        NavigationView { // Embed in NavigationView for Title and Buttons
            Form {
                Section(header: Text("Event Details").foregroundColor(.white)) {
                    TextField("Event Title", text: $newEventTitle)
                        .listRowBackground(Color(white: 0.15)) // Style form field
                    DatePicker("Date", selection: $newEventDate)
                        .listRowBackground(Color(white: 0.15))
                        // Add more fields as needed (location, emoji picker, etc.)
                }
                .listRowSeparatorTint(.gray) // Customize separator
            }
            .background(Color(white: 0.1).ignoresSafeArea()) // Form background
            .scrollContentBackground(.hidden) // Make Form background clear for ZStack below
            .navigationTitle("Create New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar) // Use dark elements in Navigation bar
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Basic validation
                        if !newEventTitle.isEmpty {
                            let newEvent = Event(title: newEventTitle, date: newEventDate, emoji: "🎉") // Default emoji
                            events.append(newEvent) // Add to the main list
                            dismiss() // Close the sheet
                        }
                    }
                    .fontWeight(.bold)
                    // Disable save if title is empty
                    .disabled(newEventTitle.isEmpty)
                }
            }
            .preferredColorScheme(.dark) // Force dark mode for the sheet content
        }
    }
}

// MARK: - Profile View (Placeholder)

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color(white: 0.05).ignoresSafeArea() // Matching background
            VStack {
                Text("👻")
                    .font(.system(size: 100))
                    .padding()
                Text("Profile / Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("This screen would show user profile details or application settings.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar) // Ensure nav bar items are light
    }
}

// MARK: - Preview Provider

struct UpcomingEventsView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with initial empty state (data loads after delay)
        UpcomingEventsView()
            .previewDisplayName("Empty Initial State")

        // Preview directly with data
        UpcomingEventsView(events: [
             Event(title: "Preview Event 1", date: Date(), location: "Test Location", emoji: "🚀"),
             Event(title: "Another Preview", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, emoji: "💡", attendeeCount: 22)
            ]
        )
        .previewDisplayName("With Mock Data")
    }
}

// Helper Color Extension (Optional - for semantic colors)
extension Color {
    static let lightGray = Color(white: 0.65)
    static let systemTeal = Color(red: 90/255, green: 200/255, blue: 250/255) // Approximate system teal
}
