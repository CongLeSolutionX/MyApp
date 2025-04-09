//
//  WelcomeView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

// MARK: - Mock Data Structure
import Foundation

// Simple mock event data structure
struct Event: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var date: Date
    var location: String
    var host: String = "Friend" // Default host

    // Sample events for simulation
    static let sampleEvent = Event(
        name: "Summer BBQ Bash",
        date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        location: "Central Park - Great Lawn"
    )

    static func mockEvent(withId idString: String) -> Event? {
        // In a real app, you'd fetch based on the ID. Here we just return a sample.
        // We could use the idString to slightly customize, but for simplicity:
        if !idString.isEmpty { // Basic check if an ID was provided
             return Event(
                 name: "Special Event Invite (\(idString.prefix(4)))",
                 date: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
                 location: "Online / Specific Venue",
                 host: "Inviter"
             )
         }
         return nil
     }
}


// MARK: - ViewModel
import SwiftUI
import Combine // Needed for ObservableObject

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

// MARK: - Safari View Wrapper
import SwiftUI
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


// MARK: - Placeholder Destination Views

import SwiftUI

// Placeholder for the main application interface
struct MainAppView: View {
    var body: some View {
        NavigationView { // Or NavigationStack
            Text("Main Application Area")
                .font(.title)
                .navigationTitle("Explore Events")
        }
        .navigationBarBackButtonHidden(true) // Hide back button when coming from Welcome
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

// MARK: - WelcomeView and Root View

import SwiftUI

// Entry point of the app or the view that contains WelcomeView
struct ContentView: View {
    var body: some View {
        // Use NavigationStack for modern navigation (iOS 16+)
        NavigationStack {
            WelcomeView()
        }
        // You might have other global modifiers here (e.g., environment objects)
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

// Preview Provider
#Preview {
    // Wrap WelcomeView in ContentView for preview to include NavigationStack
    ContentView()
        // Optional: Simulate opening with a URL in preview
         .onAppear {
             let viewModel = WelcomeViewModel()
             let testURL = URL(string: "appleinvitesapp://event/abc123def456")!
             // Need access to the view model instance used by WelcomeView,
             // which is tricky in previews directly. Better to test in simulator.
         }
}
