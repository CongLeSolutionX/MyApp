//
//  TripView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// --- Data Model ---
import SwiftUI

// Data Model for Past Trips
struct PastTrip: Identifiable {
    let id = UUID()
    let locationName: String
    let hostInfo: String
    let dates: String
    let imageName: String // Using system names as placeholders
}

// Sample Data
let samplePastTrips = [
    PastTrip(locationName: "Marietta", hostInfo: "Hosted by Javier", dates: "Jan 7–21, 2024", imageName: "house.fill"),
    PastTrip(locationName: "Incline Village", hostInfo: "Hosted by Vacasa Nevada", dates: "Jul 29–31, 2023", imageName: "figure.terrace"),
    PastTrip(locationName: "San Diego", hostInfo: "Hosted by Nizar", dates: "Jul 15–16, 2022", imageName: "bed.double.fill")
]

// Custom Color (Airbnb Pink)
//extension Color {
//    static let airbnbPink = Color(red: 255/255, green: 56/255, blue: 92/255)
//}
// --- Reusable Views ---

// View for the "No trips booked" card
struct NoTripsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.wave.fill") // Placeholder icon
                .font(.system(size: 40))
                .foregroundColor(.airbnbPink)
                .padding(.bottom, 10)

            Text("No trips booked...yet!")
                .font(.title2)
                .fontWeight(.bold)

            Text("Time to dust off your bags and start planning your next adventure.")
                .font(.callout)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Start searching") {
                // Action for starting search
                print("Start searching tapped!")
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.airbnbPink)
            .cornerRadius(10)
            .padding(.top) // Add some space above the button
        }
        .padding(25) // Padding inside the card
        .background(Color(UIColor.systemGray6)) // Light background for the card
        .cornerRadius(12)
        .overlay( // Optional subtle border
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal) // Padding outside the card
    }
}

// View for a single row in the "Where you've been" list
struct PastTripRow: View {
    let trip: PastTrip

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: trip.imageName) // Placeholder image
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .background(Color.gray.opacity(0.3)) // Placeholder background
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(trip.locationName)
                    .font(.headline)
                    .fontWeight(.medium)
                Text(trip.hostInfo)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(trip.dates)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer() // Pushes content to the left
        }
    }
}

// View for the "Where you've been" section
struct PastTripsSection: View {
    let trips: [PastTrip]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Where you've been")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal) // Match card padding

            // LazyVStack is memory efficient for long lists
            LazyVStack(alignment: .leading, spacing: 20) {
                 ForEach(trips) { trip in
                    PastTripRow(trip: trip)
                 }
            }
            .padding(.horizontal) // Add padding to list items
        }
        .padding(.top, 30) // Space above the section title
    }
}

// View for the "Visit Help Center" link
struct HelpLinkView: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("Can't find your reservation here?")
                .font(.callout)
                .foregroundColor(.secondary) // Slightly dimmer text
             Text("Visit the Help Center")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.primary) // Or use .blue for typical link color
                .underline()
                 .onTapGesture {
                     print("Help Center Tapped")
                     // Open URL action
                 }
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
    }
}

// --- Main Trips Screen ---
struct TripsView: View {
    // Inject sample data or load real data here
    let pastTrips = samplePastTrips
    let hasBookedTrips = false // Set to true to hide the "NoTripsView"

    var body: some View {
         // Use a ScrollView to make content scrollable
         ScrollView {
             VStack(spacing: 0) { // Use spacing 0 and add padding manually where needed
                // Show this section only if no trips are booked
                if !hasBookedTrips {
                    NoTripsView()
                        .padding(.top, 20) // Space below navigation title
                } else {
                    // Placeholder for when trips *are* booked
                    Text("Your Upcoming Trips")
                        .font(.title2).bold().padding()
                     // Add Upcoming trips list here...
                }

                // Always show past trips section if available
                if !pastTrips.isEmpty {
                    PastTripsSection(trips: pastTrips)
                }

                HelpLinkView()

                // Add a spacer to push content up if the scroll view
                // doesn't have enough content to fill the screen.
                Spacer(minLength: 20)
             }
         }
         // Use .navigationTitle for the large title effect
         .navigationTitle("Trips")
    }
}

// --- Tab Bar Structure ---
enum TabIdentifier {
    case explore, wishlists, trips, messages, profile
}

struct MainTabView: View {
    @State private var selectedTab: TabIdentifier = .trips // Default to Trips tab

    var body: some View {
        TabView(selection: $selectedTab) {
            // Explore Tab
            Text("Explore Screen")
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(TabIdentifier.explore)

            // Wishlists Tab
            Text("Wishlists Screen")
                .tabItem {
                    Label("Wishlists", systemImage: "heart") // Use heart.fill if needed
                }
                .tag(TabIdentifier.wishlists)

            // Trips Tab (Embeds NavigationView for title)
            NavigationView {
                 TripsView()
                 // Hide the default navigation bar back button title if needed
                 // .navigationBarTitleDisplayMode(.inline) // Or .large
            }
            .tabItem {
                 Label("Trips", systemImage: "airbnb.logo") // Requires custom symbol or image
                 // As a fallback:
                 // Label("Trips", systemImage: "airplane")
            }
            .tag(TabIdentifier.trips)

            // Messages Tab
            Text("Messages Screen")
                .tabItem {
                    Label("Messages", systemImage: "message") // Use message.fill if needed
                }
                .tag(TabIdentifier.messages)
                // Example of adding a badge (requires state management)
                // .badge(3)

            // Profile Tab
            Text("Profile Screen")
                .tabItem {
                    Label("Profile", systemImage: "person.circle") // Use person.crop.circle if needed
                }
                .tag(TabIdentifier.profile)
        }
        // Set the accent color for the selected tab item
         .accentColor(.airbnbPink)
    }
}

// --- Add custom Airbnb logo symbol (Placeholder) ---
// For the Tab Bar, you'd need the actual Airbnb logo image.
// This code provides a way to use SF Symbols if you don't have the logo.
// If you had an image asset named "airbnbLogo", you'd use Image("airbnbLogo") instead.
extension Image {
    static let airbnbLogo = Image(systemName: "a.square.fill") // Placeholder SF Symbol
}

// --- Preview Provider ---
struct TripsView_Previews: PreviewProvider {
    static var previews: some View {
         // Preview the MainTabView to see the whole structure
         MainTabView()

         // Or preview just the TripsView within a NavigationView
         // NavigationView {
         //    TripsView()
         // }
    }
}
