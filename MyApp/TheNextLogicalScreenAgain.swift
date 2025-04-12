//
//  TheNextLogicalScreenAgain.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI

struct UserProfileView: View {
    // MARK: - AppStorage Properties (Reading Existing & Adding New)

    // Read the username set in SettingsView
    @AppStorage("settings.username") private var username: String = ""
    // Add new profile-specific storage
    @AppStorage("profile.email") private var email: String = "user@example.com" // Default mock value
    @AppStorage("profile.bio") private var bio: String = "Loves SwiftUI and exploring new apps!" // Default mock value
    @AppStorage("profile.joinDate") private var joinDateMillis: Double = Date().timeIntervalSince1970 // Store as Double (epoch time)
    @AppStorage("profile.avatarSymbol") private var avatarSymbol: String = "person.crop.circle.fill" // Default SFSymbol

    // Computed property to easily display the join date
    private var joinDate: Date {
        Date(timeIntervalSince1970: joinDateMillis)
    }

    // State for potential future editing mode (not implemented yet)
    @State private var isEditing = false // Placeholder for future edit functionality

    // MARK: - Body

    var body: some View {
        Form {
            // MARK: - Avatar and Basic Info Section
            Section {
                HStack(spacing: 15) {
                    Image(systemName: avatarSymbol) // Placeholder Avatar
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 5) // Add some vertical padding

                    VStack(alignment: .leading) {
                        Text(username.isEmpty ? "Guest User" : username)
                            .font(.title2)
                            .fontWeight(.semibold)
                            // Placeholder for editing state
                            .foregroundStyle(isEditing ? .secondary : .primary)

                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            // Placeholder for editing state
                            .foregroundStyle(isEditing ? .secondary : .primary)

                    }
                    Spacer() // Pushes content to the left
                }
            }

            // MARK: - About Section
            Section("About") {
                // Use Text for display, could be TextField in edit mode
                Text(bio.isEmpty ? "No bio set." : bio)
                    .foregroundStyle(bio.isEmpty ? .secondary : .primary)
                    .frame(minHeight: 80, alignment: .topLeading) // Ensure space for longer bios

                HStack {
                    Text("Joined")
                    Spacer()
                    Text(joinDate, style: .date) // Nicely formatted date
                        .foregroundColor(.secondary)
                }
            }

            // MARK: - Actions Section
            Section("Actions") {
                // --- Placeholder Edit Button ---
                 Button(isEditing ? "Done" : "Edit Profile") {
                     print("UserProfileView: Edit button tapped. Current state: \(isEditing)")
                     // In a real app, toggle isEditing and change UI accordingly
                     // For now, it just prints. We'll disable fields visually based on it.
                     // isEditing.toggle() // Add this later when implementing edit mode
                     print("NOTE: Editing functionality not yet implemented.")
                 }
                 .tint(isEditing ? .green : .blue) // Change color based on state

                // --- Placeholder Logout Button ---
                Button("Log Out", role: .destructive) {
                    print("UserProfileView: Log Out button tapped.")
                    // --- Placeholder Action: Clear some user data ---
                    // In a real app, you'd likely clear tokens, user IDs, etc.
                    // and navigate the user back to a login screen.
                    username = "" // Clears the AppStorage value
                    email = "user@example.com" // Reset to default
                    bio = "Loves SwiftUI and exploring new apps!" // Reset to default
                    // --- End Placeholder ---
                    print("UserProfileView: Cleared username via AppStorage (simulating logout).")
                    // We might want to dismiss this view after logout in a real app.
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        // Example: Visually disable interaction when not editing (add later)
        // .disabled(!isEditing && /* specific fields */)
    }
}

// MARK: - Preview Provider
#Preview {
    NavigationStack { // Needs NavigationStack for title context
        UserProfileView()
            // Set some temporary values for preview if needed
            .onAppear {
                 // UserDefaults.standard.set("PreviewUser", forKey: "settings.username")
                 // UserDefaults.standard.set("preview@email.com", forKey: "profile.email")
            }
    }
}
