//
//  AccountManagementView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

struct AccountManagementView: View {

    // --- State ---
    @State private var showSignOutConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showChangePasswordFlow = false // Mock: Triggers a sheet/navigation

    // --- Mock Data / User Info ---
    // In a real app, this would come from an environment object or auth service
    let userEmail = "CongLeJobs@gmail.com"
    let hasPasswordAuth = true // Mock: Assume user can change password
    let connectedServices = ["Apple", "Google"] // Mock: Services user linked

    var body: some View {
        Form {
            // --- User Info (Read-only reference) ---
             Section(header: Text("Logged In As")) {
                 Text(userEmail)
                     .foregroundColor(.secondary)
             }

            // --- Security Section ---
            Section(header: Text("Security")) {
                // Change Password
                if hasPasswordAuth {
                    Button("Change Password") {
                        // Trigger the actual change password flow (e.g., present a sheet or navigate)
                        print("Triggering Change Password flow...")
                        showChangePasswordFlow = true // Mock action
                    }
                    // Apply foregroundColor to Button's label if needed for styling consistency
                    // .foregroundColor(Color.accentColor) // Or .primary
                } else {
                    Text("Password management handled by \(connectedServices.first ?? "your identity provider").")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Future: Add options like Two-Factor Authentication setup here
            }

            // --- Connected Services Section ---
            if !connectedServices.isEmpty {
                Section(header: Text("Connected Services")) {
                    // List connected services - usually not actionable here,
                    // just informational or links to OS settings.
                     ForEach(connectedServices, id: \.self) { service in
                         HStack {
                             Image(systemName: service == "Apple" ? "apple.logo" : "g.circle.fill") // Example icons
                                 .foregroundColor(service == "Apple" ? .primary : .blue) // Example colors
                             Text("Connected with \(service)")
                             Spacer()
                             // Often, managing these requires going to OS Settings or the provider's site
                             // Button("Manage") { /* Link to settings or provider */ }
                         }
                     }
                     Text("Manage connections via the respective service provider platforms or device settings.")
                         .font(.caption)
                         .foregroundColor(.secondary)
                }
            }

            // --- Account Actions Section ---
            Section(header: Text("Account Actions")) {
                // Sign Out Button
                Button("Sign Out") {
                    showSignOutConfirmation = true
                }
                .foregroundColor(.orange) // Use color to indicate a less common, but not destructive action
            }

            Section(header: Text("Danger Zone")) {
                // Delete Account Button
                Button("Delete Account") {
                    showDeleteConfirmation = true
                }
                .foregroundColor(.red) // Use red to indicate a destructive action
            }
        }
        .navigationTitle("Account Management")
        .navigationBarTitleDisplayMode(.inline)

        // --- Modals & Alerts ---

        // Mock Sheet for Change Password Flow
        .sheet(isPresented: $showChangePasswordFlow) {
            // Replace with your actual Change Password View/Flow
            VStack {
                Text("Change Password Flow")
                    .font(.headline)
                    .padding()
                Text("This screen would typically ask for the current password and the new password.")
                    .padding()
                Button("Dismiss (Mock)") {
                    showChangePasswordFlow = false
                }
                .buttonStyle(.borderedProminent)
                .padding()
                Spacer()
            }
        }

        // Confirmation Alert for Signing Out
        .alert("Sign Out?", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                // --- Execute Sign Out Logic ---
                 print("Signing out user...")
                 // In a real app:
                 // 1. Call your authentication service to clear tokens/session.
                 // 2. Reset local user data.
                 // 3. Navigate the user back to the login screen (often by changing root view state).
                 // Example: AuthViewModel.shared.signOut()
                 // Example: AppState.shared.isAuthenticated = false
            }
        } message: {
            Text("Are you sure you want to sign out? You will need to log in again to access your account.")
        }

        // Confirmation Alert for Deleting Account
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Account", role: .destructive) {
                 // --- Execute Account Deletion Logic ---
                 print("Deleting user account...")
                 // In a real app:
                 // 1. Call your backend API to initiate account deletion.
                 //    This might be asynchronous (e.g., scheduled deletion).
                 // 2. Handle success/failure response from the backend.
                 // 3. If successful, sign the user out locally (see Sign Out logic).
                 // Example: AccountService.requestAccountDeletion { success in ... }
            }
        } message: {
            // Make this message very clear about the consequences!
            Text("This action is permanent and cannot be undone. All your data associated with this account will be permanently deleted according to our data retention policy. Are you absolutely sure?")
        }
    }
}

// --- Previews ---
struct AccountManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountManagementView()
        }
        .previewDisplayName("Default Preview")

        NavigationView {
            AccountManagementView()
            //AccountManagementView(hasPasswordAuth: false) // Preview for social login only
        }
        .previewDisplayName("Social Login Only")
    }
}
