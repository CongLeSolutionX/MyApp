//
//  UpcomingEventsView.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI

struct UpcomingEventsView_V1: View {

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color - almost black
                Color(white: 0.05).ignoresSafeArea()

                // Main content area
                VStack(spacing: 16) { // Added spacing for consistency
                    Spacer() // Pushes content towards the center vertically

                    // Empty State Content
                    VStack(spacing: 12) { // Spacing within the empty state block
                        Image(systemName: "calendar")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary) // Greyish color for the icon

                        Text("No Upcoming Events")
                            .font(.title2) // Slightly smaller than .title, looks closer
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Upcoming events, whether you're a host or a guest, will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40) // Add horizontal padding for line wrapping

                        Button {
                            // Action for creating an event
                            print("Create Event Tapped")
                        } label: {
                            Text("Create Event")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .foregroundColor(Color.black)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 10) // Add some space above the button
                    }

                    Spacer() // Pushes content towards the center vertically
                    Spacer() // Add more space at the bottom if needed, adjust ratio
                }
                .padding(.horizontal) // Add overall horizontal padding
            }
            // Custom Toolbar
            .toolbar {
                // Leading Item: Title and Arrow
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("Upcoming")
                            .font(.largeTitle) // Large title font
                            .fontWeight(.bold)
                            .foregroundColor(.white) // Explicitly white
                        Image(systemName: "chevron.down")
                            .font(.body) // Default size for chevron
                            .fontWeight(.semibold)
                            .foregroundColor(.gray) // Grey color for chevron
                    }
                }

                // Trailing Items: Action Buttons
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) { // Spacing between the two trailing buttons
                        Button {
                            // Action for the plus button
                            print("Add Tapped")
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline) // Slightly larger/bolder icon
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32) // Fixed size for circle
                                .background(Color(white: 0.2)) // Dark grey background
                                .clipShape(Circle())
                        }

                        Button {
                            // Action for the ghost/profile button
                            print("Profile Tapped")
                        } label: {
                            Text("👻") // Using emoji directly
                                .font(.title3) // Adjust emoji size if needed
                                .frame(width: 32, height: 32)
                                .background(Color(white: 0.2))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            // Optional: Set navigation bar background color if needed
             .toolbarBackground(Color(white: 0.05), for: .navigationBar) // Match background
             .toolbarBackground(.visible, for: .navigationBar)
             .toolbarColorScheme(.dark, for: .navigationBar) // Ensure status bar items are light
        }
        // Note: The green background behind the status bar time (5:21) is
        // likely an OS-level indicator (e.g., screen recording, location access)
        // and not typically part of the app's custom UI layout in SwiftUI.
        // It's not replicated here as it falls outside standard app design.
    }
}

// MARK: - Preview
struct UpcomingEventsView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingEventsView_V1()
    }
}
