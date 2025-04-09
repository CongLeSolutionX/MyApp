//
//  WelcomeView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import Foundation

// Simple mock event data structure
struct Event: Identifiable, Hashable {
    enum Status: String, CaseIterable, Hashable {
        case upcoming = "Upcoming"
        case past = "Past"
        case draft = "Draft" // Maybe for events being created
    }
    
    let id = UUID()
    var name: String
    var date: Date
    var location: String
    var host: String = "Friend" // Default host
    var status: Status = .upcoming // Default status
    
    // Sample events for simulation
    static let sampleEvents: [Event] = [
        Event(
            name: "Summer BBQ Bash",
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            location: "Central Park - Great Lawn",
            host: "Alice",
            status: .upcoming
        ),
        Event(
            name: "Project Alpha Launch Party",
            date: Calendar.current.date(byAdding: .day, value: 20, to: Date())!,
            location: "Tech Hub Auditorium",
            host: "My Company", // User is hosting this one
            status: .upcoming
        ),
        Event(
            name: "Board Game Night",
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, // Past event
            location: "Bob's Apartment",
            host: "Bob",
            status: .past
        ),
        Event(
            name: "Weekend Getaway Planning",
            date: Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
            location: "Virtual Meeting",
            host: "Travel Group",
            status: .draft // Still being planned
        ),
        Event(
            name: "Birthday Dinner",
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            location: "The Italian Place",
            host: "Charlie",
            status: .upcoming
        )
    ]
    
    // Function for deep linking simulation (no change needed here)
    static func mockEvent(withId idString: String) -> Event? {
        if !idString.isEmpty {
            return Event(
                name: "Special Event Invite (\(idString.prefix(4)))",
                date: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
                location: "Online / Specific Venue",
                host: "Inviter",
                status: .upcoming // Assume linked events are upcoming
            )
        }
        return nil
    }
}


import SwiftUI
import Combine

@MainActor
class MainAppViewModel: ObservableObject {
    
    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // State to control presenting the create event sheet
    @Published var showingCreateEventSheet: Bool = false
    
    // Grouped events for sections (optional but good practice)
    var groupedEvents: [Event.Status: [Event]] {
        Dictionary(grouping: events, by: { $0.status })
    }
    
    // Order for sections
    let statusOrder: [Event.Status] = [.upcoming, .draft, .past]
    
    init() {
        fetchEvents() // Fetch events when the ViewModel is created
    }
    
    func fetchEvents() {
        isLoading = true
        errorMessage = nil
        events = [] // Clear existing events
        
        // Simulate network delay or database fetch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            // --- Mock Data Population ---
            // In a real app, replace this with actual data fetching
            // For demo, sort by date within status groups potentially
            self.events = Event.sampleEvents.sorted { event1, event2 in
                // Primarily sort by date (upcoming soonest, past most recent)
                if event1.status == event2.status {
                    if event1.status == .past {
                        return event1.date > event2.date // Past events: newest first
                    } else {
                        return event1.date < event2.date // Upcoming/Draft: soonest first
                    }
                }
                // Keep statuses grouped implicitly by how 'groupedEvents' works
                return false // Should rely on section grouping mostly
            }
            
            // --- Simulate Error (Uncomment to test) ---
            // self.errorMessage = "Failed to load events. Please try again."
            // self.events = []
        }
    }
    
    func createNewEventTapped() {
        showingCreateEventSheet = true
    }
}

import SwiftUI

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                Text("Host: \(event.host)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(event.date, style: .date)
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Optional: Status indicator or icon
            statusIndicator()
        }
        .padding(.vertical, 6) // Add some vertical padding within the row
    }
    
    // Helper to show a status indicator
    @ViewBuilder
    private func statusIndicator() -> some View {
        switch event.status {
        case .upcoming:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .past:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
        case .draft:
            Image(systemName: "pencil.circle.fill")
                .foregroundColor(.orange)
        }
    }
}

#Preview {
    List { // Preview within a List for context
        EventRowView(event: Event.sampleEvents[0])
        EventRowView(event: Event.sampleEvents[2])
        EventRowView(event: Event.sampleEvents[3])
    }
}

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) var dismiss // To close the sheet
    
    // State for the form (add more fields as needed)
    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventLocation: String = ""
    
    var body: some View {
        NavigationView { // Embed in NavigationView for title and buttons
            Form {
                Section("Event Details") {
                    TextField("Event Name", text: $eventName)
                    DatePicker("Date & Time", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                    TextField("Location", text: $eventLocation)
                }
                
                Section {
                    Button("Create Event") {
                        // TODO: Add logic to save the event
                        print("Creating event: \(eventName)")
                        dismiss() // Close the sheet
                    }
                    .disabled(eventName.isEmpty) // Basic validation
                    
                    Button("Cancel", role: .destructive) {
                        dismiss() // Close the sheet
                    }
                }
            }
            .navigationTitle("New Invitation")
            .navigationBarTitleDisplayMode(.inline) // Keep title compact in sheet
        }
    }
}

#Preview {
    CreateEventView()
}

import SwiftUI

struct MainAppView: View {
    // Use @StateObject for the ViewModel tied to this view's lifecycle
    @StateObject private var viewModel = MainAppViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // Keep using NavigationStack for consistency
        // It's already provided by ContentView if MainAppView is pushed onto it.
        // If MainAppView *replaces* WelcomeView (e.g., based on first launch),
        // it might need its own NavigationStack root. Assuming it's pushed for now.
        
        ZStack { // Use ZStack to overlay loading/error states
            List {
                // Iterate through the defined status order for consistent sectioning
                ForEach(viewModel.statusOrder, id: \.self) { status in
                    // Check if there are events for this status
                    if let eventsInSection = viewModel.groupedEvents[status], !eventsInSection.isEmpty {
                        Section(header: Text(status.rawValue)) {
                            ForEach(eventsInSection) { event in
                                // NavigationLink wraps the row content
                                NavigationLink(value: event) {
                                    EventRowView(event: event)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped) // Use a modern list style
            .opacity(viewModel.isLoading || viewModel.errorMessage != nil ? 0 : 1) // Hide list when loading/error
            .refreshable {
                // Add pull-to-refresh functionality
                viewModel.fetchEvents()
            }
            
            // --- Loading State ---
            if viewModel.isLoading {
                ProgressView("Loading Events...")
                    .progressViewStyle(.circular)
                    .padding()
                    .background(Material.ultraThin) // Use a blur background
                    .cornerRadius(10)
            }
            
            // --- Error State ---
            if let errorMessage = viewModel.errorMessage, !viewModel.isLoading {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        viewModel.fetchEvents()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Material.ultraThin)
                .cornerRadius(10)
            }
            
            // --- Empty State (Only show if not loading and no error) ---
            if !viewModel.isLoading && viewModel.errorMessage == nil && viewModel.events.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No Invitations Yet")
                        .font(.title2)
                        .fontWeight(.medium)
                    Text("Tap the '+' button to create your first invitation.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Button {
                        viewModel.createNewEventTapped()
                    } label: {
                        Label("Create Invitation", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding(.horizontal, 40) // Add padding to center the text
            }
            
        } // End ZStack
        .navigationTitle("My Invitations")
        // Add the "+" button to the navigation bar
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.createNewEventTapped()
                } label: {
                    Label("Create New Event", systemImage: "plus")
                }
            }
        }
        // Define navigation destination for Event type (needed here or ancestor)
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event)
        }
        // Present the CreateEventView as a sheet
        .sheet(isPresented: $viewModel.showingCreateEventSheet) {
            CreateEventView()
            // Optional: Add completion logic if needed when sheet closes
        }
        .navigationBarBackButtonHidden(true) // Hide back button if pushed from Welcome
        // Optional: Use onAppear if fetchEvents shouldn't run in init
        // .onAppear {
        //     if viewModel.events.isEmpty { // Fetch only if list is empty
        //         viewModel.fetchEvents()
        //     }
        // }
    }
}

#Preview {
    // Wrap in NavigationView/NavigationStack for Preview purposes
    NavigationStack {
        MainAppView()
    }
}

// Make sure ContentView uses this correctly:
struct ContentView: View {
    var body: some View {
        NavigationStack {
            WelcomeView() // WelcomeView handles its own navigation destinations now
        }
    }
}


struct WelcomeView: View {
    // Create and manage the ViewModel instance
    @StateObject private var viewModel = WelcomeViewModel()
    @Environment(\.colorScheme) var colorScheme // To potentially adjust colors
    
    var body: some View {
        ZStack {
            // Adapt background slightly based on color scheme
            (colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(red: 0.15, green: 0.15, blue: 0.15))
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // --- Logo --- (unchanged)
                Image(systemName: "envelope.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(15)
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.bottom, 20)
                
                // --- Title --- (unchanged)
                Text("Welcome to\nApple Invites")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                
                // --- Action Rows --- (unchanged visually, but context implies functionality)
                InfoRow(
                    iconName: "envelope.fill",
                    text: "Received an invitation? Tap the link you were sent to see the event details."
                )
                
                InfoRow(
                    iconName: "plus.app.fill",
                    text: "Just got the app? Continue to explore or set up your first event."
                )
                
                Spacer()
                
                // --- Informational Text Section with Functional Link ---
                VStack(spacing: 10) {
                    Image(systemName: "person.2.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)
                    
                    // Combine static text with a tappable button for the link
                    HStack(spacing: 4) { // HStack for alignment if needed
                        Text("Apple Invites allows iCloud+ subscribers to create party invitations, manage RSVPs, and create Shared Albums and Shared Playlists for their Apple Invites. Apple processes information about your event and invitees, such as the event name, location, and guest RSVP details, in order to send and display event details to guests. ")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        //                              .multilineTextAlignment(.center)
                        +
                        Text("See how your data is managed...") // Visually styled part
                            .font(.footnote)
                            .foregroundColor(.yellow)
                            .fontWeight(.medium)
                            .underline()
                    }
                    .onTapGesture { // Make the whole combined text tappable
                        viewModel.showPrivacyTapped()
                    }
                    // Alternatively, use a Button for better accessibility:
                    /*
                     Button {
                     viewModel.showPrivacyTapped()
                     } label: {
                     Text("Apple Invites allows iCloud+ subscribers... ")
                     .font(.footnote)
                     .foregroundColor(.gray)
                     .multilineTextAlignment(.center)
                     +
                     Text("See how your data is managed...") // Visually styled part
                     .font(.footnote)
                     .foregroundColor(.yellow)
                     .fontWeight(.medium)
                     }
                     .buttonStyle(.plain) // Avoid default button styling
                     */
                    
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                
                // --- Continue Button --- (Action delegated to ViewModel)
                Button {
                    viewModel.continueTapped()
                } label: {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(colorScheme == .dark ? .black : .black) // Ensure contrast
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                .padding(.bottom) // Padding below the button before safe area
                
            }
            .padding(.horizontal) // Overall horizontal padding
        }
        .navigationBarHidden(true) // Hide nav bar on this welcome screen
        // --- URL Handling ---
        .onOpenURL { url in
            viewModel.handleOpenURL(url) // Delegate to ViewModel
        }
        // --- Navigation Destinations ---
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event) // Navigate to detail when event is set
        }
        .navigationDestination(isPresented: $viewModel.navigateToMainApp) {
            MainAppView() // Navigate to main app when flag is true
        }
        // --- Modal Sheet for Privacy Policy ---
        .sheet(isPresented: $viewModel.showPrivacyPolicy) {
            // Present the SafariView modally
            SafariView(url: viewModel.privacyPolicyURL)
            // Optional: Make the sheet background dark if needed
            // .preferredColorScheme(.dark)
        }
        // Trigger navigation from link *after* the view appears
        // Use task to observe the optional event property for NavigationStack
        .task(id: viewModel.eventToShowFromLink) {
            // This task will run when eventToShowFromLink changes *from* nil *to* a value
            // However, NavigationStack's .navigationDestination(for:) handles this automatically.
            // If we needed manual navigation *push*, we'd do it here or via selection tag.
            // For this setup, the .navigationDestination(for:) is sufficient.
            // print("Task detected event change: \(viewModel.eventToShowFromLink?.name ?? "nil")")
        }
        // If using NavigationLink(tag:selection:), you'd use .onAppear or the task above
        // to trigger the selection change after a delay.
        // Example (if NOT using .navigationDestination):
        /*
         .background(
         NavigationLink(
         destination: EventDetailView(event: viewModel.eventToShowFromLink ?? Event.sampleEvent), // Placeholder needed
         tag: viewModel.eventToShowFromLink, // Use the event itself as the tag
         selection: $viewModel.selectedNavLinkEvent, // Bind to a @State var for selection
         label: { EmptyView() }
         )
         .hidden()
         )
         .task(id: viewModel.eventToShowFromLink) {
         if let event = viewModel.eventToShowFromLink {
         // Ensure selection happens *after* view is potentially ready
         try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds delay
         viewModel.selectedNavLinkEvent = event
         }
         }
         */
    }
}

@MainActor // Ensure UI updates happen on the main thread
class WelcomeViewModel: ObservableObject {
    
    // MARK: - Published Properties (Drive UI Updates)
    
    // For navigating directly to an event detail view from a link
    @Published var eventToShowFromLink: Event? = nil
    
    // For navigating to the main app area via the "Continue" button
    @Published var navigateToMainApp: Bool = false
    
    // For presenting the privacy policy web view
    @Published var showPrivacyPolicy: Bool = false
    let privacyPolicyURL = URL(string: "https://www.apple.com/legal/privacy/data/en/apple-invites/")! // Example URL
    
    // MARK: - Public Methods (Called by the View)
    
    func handleOpenURL(_ url: URL) {
        print("App opened with URL: \(url.absoluteString)")
        // --- Simulate URL Parsing for an Event Invitation ---
        // Example URL Scheme: appleinvitesapp://event/{event-uuid}
        // Example Universal Link: https://yourdomain.com/invite/{event-uuid}
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL components")
            return
        }
        
        // Check scheme or host depending on your setup (scheme for custom, host for universal)
        let isEventLinkScheme = components.scheme == "appleinvitesapp" && components.host == "event"
        let isEventLinkUniversal = components.host == "yourappdomain.com" && components.path.starts(with: "/invite/")
        
        if isEventLinkScheme || isEventLinkUniversal {
            let eventID: String
            if isEventLinkScheme {
                // Path for scheme is often just the ID: /<event-id>
                eventID = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            } else { // Universal Link
                // Path is /invite/<event-id>
                eventID = url.lastPathComponent // Gets the last part of the path
            }
            
            print("Extracted Event ID: \(eventID)")
            // Fetch or create mock event data based on the ID
            if let event = Event.mockEvent(withId: eventID) {
                // Setting this will trigger navigation in the view via NavigationLink(tag:selection:)
                // Use a slight delay to allow the initial view to appear briefly if desired
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.eventToShowFromLink = event
                    print("Scheduled navigation to event: \(event.name)")
                }
            } else {
                print("Could not find or create mock event for ID: \(eventID)")
            }
        } else {
            print("URL does not match expected event link format.")
        }
    }
    
    func continueTapped() {
        print("Continue button tapped - navigating to main app")
        navigateToMainApp = true
    }
    
    func showPrivacyTapped() {
        print("Privacy link tapped")
        showPrivacyPolicy = true
    }
}


// Placeholder for the event detail view
struct EventDetailView: View {
    let event: Event
    
    var body: some View {
        List { // Use a List for better structure
            Section("Event Details") {
                Text(event.name).font(.title2).fontWeight(.bold)
                HStack {
                    Image(systemName: "calendar")
                    Text(event.date, style: .date) + Text(" at ") + Text(event.date, style: .time)
                }
                HStack {
                    Image(systemName: "location.fill")
                    Text(event.location)
                }
                HStack {
                    Image(systemName: "person.fill")
                    Text("Hosted by: \(event.host)")
                }
            }
            Section("Actions") {
                Button("RSVP (Coming Soon)") {}
                Button("View Guest List (Coming Soon)") {}
            }
        }
        .navigationTitle("Invitation Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

import SafariServices

// Wrapper to use SFSafariViewController in SwiftUI
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Configure the Safari View Controller
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false // Optional: disable reader mode
        let safariVC = SFSafariViewController(url: url, configuration: config)
        // Optional: Customize appearance
        // safariVC.preferredBarTintColor = UIColor.systemGray6
        // safariVC.preferredControlTintColor = UIColor.systemYellow
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed for this simple case
    }
}


// Reusable InfoRow (unchanged)
struct InfoRow: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: iconName)
                .font(.title2)
                .frame(width: 30)
                .foregroundColor(.yellow)
            
            Text(text)
                .font(.callout)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

