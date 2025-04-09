//
//  SettingsView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// --- Enum for Appearance Setting ---
enum AppearanceSetting: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { self.rawValue }
}

// --- Main Settings View ---
struct SettingsView: View {

    // Mock User Data (Replace with actual data model/session in a real app)
    let userName: String = "CongLeSolutionX"
    let userEmail: String = "CongLeJobs@gmail.com"

    // State variables for interactive settings
    @State private var isFaceIdEnabled: Bool = true // Default might come from device capability/user pref
    @State private var enableTransactionNotifications: Bool = true
    @State private var enableSecurityNotifications: Bool = true
    @State private var enablePromotionalNotifications: Bool = false
    @State private var selectedAppearance: AppearanceSetting = .system // Default to system

    // Environment variable to dismiss the view if presented modally
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form { // Use Form for standard settings layout and styling

                // --- Account Section ---
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                             .font(.title)
                             .foregroundColor(.rhGold) // Use accent color
                        VStack(alignment: .leading) {
                            Text(userName)
                                .font(.headline)
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 5) // Add a bit of spacing

                    NavigationLink(destination: Text("Edit Profile Screen (Placeholder)")) {
                         Label("Edit Profile", systemImage: "person.fill")
                    }

                    NavigationLink(destination: Text("Linked Accounts Screen (Placeholder)")) {
                        Label("Linked Accounts", systemImage: "link.circle.fill")
                    }
                }

                // --- Security Section ---
                Section(header: Text("Security")) {
                    Toggle(isOn: $isFaceIdEnabled) {
                        Label("Enable Face ID / Touch ID", systemImage: "faceid") // SF Symbol adapts automatically
                    }
                    // Disable toggle if Face ID/Touch ID not available on device (in real app)

                    NavigationLink(destination: Text("Change Password Screen (Placeholder)")) {
                        Label("Change Password", systemImage: "key.fill")
                    }
                     NavigationLink(destination: Text("Two-Factor Auth Screen (Placeholder)")) {
                         Label("Two-Factor Authentication", systemImage: "lock.shield.fill")
                     }
                }

                // --- Notifications Section ---
                 Section(header: Text("Notifications"), footer: Text("Manage how you receive updates.")) {
                     Toggle(isOn: $enableTransactionNotifications) {
                         Label("Transaction Alerts", systemImage: "bell.badge.fill")
                    }
                     Toggle(isOn: $enableSecurityNotifications) {
                         Label("Security Alerts", systemImage: "shield.lefthalf.filled.slash") // Example icon
                     }
                     Toggle(isOn: $enablePromotionalNotifications) {
                         Label("Promotions & Offers", systemImage: "megaphone.fill")
                     }
                      NavigationLink(destination: Text("Advanced Notification Settings (Placeholder)")) {
                          Label("More Notification Settings", systemImage: "slider.horizontal.3")
                      }
                }

                // --- Appearance Section ---
                Section(header: Text("Appearance")) {
                     Picker("Theme", selection: $selectedAppearance) {
                        ForEach(AppearanceSetting.allCases) { appearance in
                            Text(appearance.rawValue).tag(appearance)
                        }
                    }
                     // Add logic here or in App Delegate/Scene Delegate to apply the theme
                     .onChange(of: selectedAppearance) { newValue in
                         print("Appearance changed to: \(newValue.rawValue)")
                         // Apply theme change globally (e.g., override userInterfaceStyle)
                         // This typically requires more setup outside the view itself.
                     }
                }

                 // --- Support Section ---
                Section(header: Text("Support")) {
                    NavigationLink(destination: Text("Help Center Screen (Placeholder)")) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                    }
                     Button {
                         // Action to open mail composer or chat
                         print("Contact Support tapped")
                         openSupportEmail()
                     } label: {
                           Label("Contact Support", systemImage: "envelope.fill")
                               .foregroundColor(.primary) // Ensure label color is standard in button
                       }
                }

                // --- Legal Section ---
                Section(header: Text("Legal")) {
                    // Use Link for external URLs or NavigationLink for in-app views
                    Link(destination: URL(string: "https://example.com/terms")!) { // Replace with actual URL
                        Label("Terms of Service", systemImage: "doc.text.fill")
                             .foregroundColor(.primary)
                    }
                    Link(destination: URL(string: "https://example.com/privacy")!) { // Replace with actual URL
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                             .foregroundColor(.primary)
                    }
                }

                // --- Logout Section ---
                Section {
                    Button(role: .destructive) { // Use destructive role for visual cue
                        // Perform logout action
                        print("Logout tapped")
                        // Clear user session, navigate to login screen etc.
                        // potentially dismiss modal if settings is presented that way
                        // presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                 .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            // .navigationBarTitleDisplayMode(.large) // Or .inline
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea()) // Match form background
            .accentColor(Color.rhGold) // Apply accent color to toggles, links etc.
        }
        // For modal presentation, you might use this instead of NavigationView
        // .navigationViewStyle(.stack) // Can help prevent split view on iPad if unwanted
    }

     // Helper function for Contact Support (Illustrative)
     func openSupportEmail() {
         let email = "support@example.com" // Replace with actual support email
         if let url = URL(string: "mailto:\(email)") {
             #if canImport(UIKit)
             if UIApplication.shared.canOpenURL(url) {
                 UIApplication.shared.open(url)
             } else {
                 print("Cannot open mail app")
                 // Show an alert maybe?
             }
             #endif
         }
     }
}

// --- Previews ---
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
             .preferredColorScheme(.light)
             .previewDisplayName("Light Mode")

         SettingsView()
              .preferredColorScheme(.dark)
              .previewDisplayName("Dark Mode")
    }
}

// Assume rhBeige and rhGold are defined elsewhere
// extension Color { ... }
