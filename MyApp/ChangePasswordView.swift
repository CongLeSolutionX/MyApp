//
//  ChangePasswordView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// Placeholder views for NavigationLink destinations
struct ChangePasswordView: View {
    var body: some View { Text("Change Password Screen").navigationTitle("Change Password") }
}

struct ManageTwoFactorView: View {
     @Binding var isTwoFactorEnabled: Bool // Example binding

    var body: some View {
        Form {
             Section("Two-Factor Authentication") {
                 Toggle("Enable 2FA", isOn: $isTwoFactorEnabled)
                 Text("Manage your 2FA methods here (e.g., Authenticator App, SMS).")
                     .font(.caption)
                     .foregroundColor(.gray)
             }
        }
        .navigationTitle("Manage 2FA") }
}

struct ActiveSessionsView: View {
    var body: some View { Text("Active Sessions Screen").navigationTitle("Active Sessions") }
}

struct PrivacyManagementView: View {
    var body: some View { Text("Privacy Management Screen").navigationTitle("Privacy Settings") }
}

// --- Main Security & Privacy View ---

struct SecurityPrivacyView: View {

    // Mock state for 2FA status - fetch from backend in real app
    @State private var isTwoFactorEnabled: Bool = false // Default to off

    // Mock state for Face ID/Touch ID preference - load from UserDefaults usually
    @State private var isBiometricAuthEnabled: Bool = true

    var body: some View {
        Form {
            // --- Account Security Section ---
            Section(header: Text("Account Security"),
                    footer: Text("Keep your account secure by using a strong password and enabling two-factor authentication.")) {

                // Change Password Navigation
                NavigationLink(destination: ChangePasswordView()) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.rhGold) // Use app's accent color
                        Text("Change Password")
                    }
                }

                // Two-Factor Authentication Management
                NavigationLink(destination: ManageTwoFactorView(isTwoFactorEnabled: $isTwoFactorEnabled)) {
                     HStack {
                         Image(systemName: isTwoFactorEnabled ? "lock.shield.fill" : "lock.shield")
                              .foregroundColor(isTwoFactorEnabled ? .green : .rhGold)
                         VStack(alignment: .leading) {
                              Text("Two-Factor Authentication")
                              Text(isTwoFactorEnabled ? "Enabled" : "Disabled")
                                   .font(.caption)
                                   .foregroundColor(.gray)
                         }
                     }
                 }

                // Biometric Authentication (Face ID / Touch ID)
                Toggle(isOn: $isBiometricAuthEnabled) {
                   HStack {
                       Image(systemName: "faceid") // Or "touchid" depending on device/context
                             .foregroundColor(.rhGold)
                       Text("Use Face ID / Touch ID") // Make dynamic based on device capability
                    }
                }
                .tint(.rhGold) // Color the toggle switch
                .onChange(of: isBiometricAuthEnabled) { newValue in
                    // Save preference to UserDefaults or Keychain
                    print("Biometric Auth toggled: \(newValue)")
                    // Add logic to handle enabling/disabling biometrics
                    // This might involve requesting permission or specific setup
                 }
            }

            // --- Session Management Section ---
            Section(header: Text("Session Management")) {
                NavigationLink(destination: ActiveSessionsView()) {
                    HStack {
                        Image(systemName: "desktopcomputer")
                            .foregroundColor(.rhGold)
                        Text("Active Sessions")
                    }
                }
                 .onChange(of: isTwoFactorEnabled) { newValue in
                    // Action when 2FA status changes directly (if toggle was here)
                    // or reflected from the ManageTwoFactorView binding
                    print("2FA Status updated in SecurityPrivacyView: \(newValue)")
                   }
            }

            // --- Privacy Section ---
            Section(header: Text("Privacy"),
                     footer: Text("Manage how your data is used and shared within the app.")) {
                NavigationLink(destination: PrivacyManagementView()) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.rhGold)
                        Text("Privacy Settings")
                    }
                }

                // Example: Link to External Privacy Policy
                if let url = URL(string: "https://www.example.com/privacy") { // Replace with actual URL
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.rhGold)
                            Text("Privacy Policy")
                            Spacer() // Pushes the chevron to the right
                            Image(systemName: "arrow.up.right.square") // Indicates external link
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        // Make the whole row tappable but maintain default link styling for text
                         .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain) // Prevents the entire row from getting button styling
                }
            }
        }
        .navigationTitle("Security & Privacy")
        .navigationBarTitleDisplayMode(.inline) // Consistent with other settings screens
    }
}

// --- Previews ---
struct SecurityPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SecurityPrivacyView()
        }
        .preferredColorScheme(.light)
        .previewDisplayName("Light Mode")

        NavigationView {
            SecurityPrivacyView()
        }
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")

    }
}

// Dummy Color Extension (ensure these exist in your project)
// extension Color {
//     static let rhGold = Color.orange // Placeholder
//     static let rhBeige = Color(UIColor.systemGray6) // Placeholder
// }
