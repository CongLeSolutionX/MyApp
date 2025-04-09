//
//  NotificationSettingsView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import UserNotifications // Needed for checking system settings status

struct NotificationSettingsView: View {

    // --- Mock User Preferences ---
    // In a real app, load these from UserDefaults or a backend service
    @State private var allowPromotionalPush = true
    @State private var allowFeatureUpdatesPush = true
    @State private var allowRemindersPush = false // Example: A feature-specific notification
    @State private var allowPromotionalEmails = true
    @State private var allowNewsletterEmails = false

    // --- System Settings State ---
    @State private var pushNotificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showSystemSettingsAlert = false

    // --- Environment ---
    // Accessing the scenePhase to refresh settings when returning from background
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Form {
            // --- Master Push Notification Control ---
            Section(header: Text("Push Notifications")) {
                // Display current system permission status
                HStack {
                    Text("App Notification Permissions")
                    Spacer()
                    statusText(for: pushNotificationStatus)
                        .foregroundColor(statusColor(for: pushNotificationStatus))
                }

                // Button to guide user to system settings
                Button("Manage System Notification Settings") {
                    // Attempt to open the app's notification settings in the Settings app
                    guard let settingsUrl = URL(string: UIApplication.openNotificationSettingsURLString),
                          UIApplication.shared.canOpenURL(settingsUrl) else {
                        // Fallback if the deep link isn't available (should be on modern iOS)
                        showSystemSettingsAlert = true
                        return
                    }
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
                .foregroundColor(.accentColor) // Standard link color

                 // Explanation text
                 Text("Control overall permission for this app to send notifications in your device's Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // --- Granular Push Notification Categories ---
            // Only show these if system permissions are granted
            if pushNotificationStatus == .authorized {
                Section(header: Text("Push Notification Types"),
                        footer: Text("Fine-tune the types of push notifications you receive from us.")) {

                    Toggle("Promotions & Offers", isOn: $allowPromotionalPush)
                        .onChange(of: allowPromotionalPush) { newValue in
                            savePreference(key: "promotionalPush", value: newValue)
                        }

                    Toggle("New Feature Updates", isOn: $allowFeatureUpdatesPush)
                         .onChange(of: allowFeatureUpdatesPush) { newValue in
                             savePreference(key: "featureUpdatesPush", value: newValue)
                         }

                    // Example of a feature-specific notification toggle
                    Toggle("Task Reminders", isOn: $allowRemindersPush)
                         .onChange(of: allowRemindersPush) { newValue in
                             savePreference(key: "remindersPush", value: newValue)
                         }
                    // Add more toggles for other relevant categories...
                }
            } else if pushNotificationStatus == .denied {
                 Section(header: Text("Push Notification Types")) {
                    Text("Enable App Notification Permissions in System Settings to manage specific notification types.")
                        .font(.callout)
                        .foregroundColor(.orange)
                }
            }

            // --- Email Notification Preferences (Optional Section) ---
             Section(header: Text("Email Notifications"),
                     footer: Text("Manage emails sent to your registered address.")) {

                 Toggle("Promotions & Offers", isOn: $allowPromotionalEmails)
                     .onChange(of: allowPromotionalEmails) { newValue in
                         savePreference(key: "promotionalEmails", value: newValue)
                     }

                 Toggle("Monthly Newsletter", isOn: $allowNewsletterEmails)
                     .onChange(of: allowNewsletterEmails) { newValue in
                         savePreference(key: "newsletterEmails", value: newValue)
                     }
                 // Add more email toggles if needed...
             }
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: checkNotificationStatus)
        // Refresh status when the app becomes active again (user might have changed settings)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkNotificationStatus()
            }
        }
        // Alert fallback if deep link fails
        .alert("Cannot Open Settings", isPresented: $showSystemSettingsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can manage notification permissions for this app in the main Settings app under Notifications.")
        }
    }

    // --- Helper Functions ---

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { // Update UI on the main thread
                self.pushNotificationStatus = settings.authorizationStatus
                // Load saved preferences when status is known
                loadPreferences()
            }
        }
    }

    // Mock saving function (replace with actual persistence)
    func savePreference(key: String, value: Bool) {
        print("Saving preference: \(key) = \(value)")
        // UserDefaults.standard.set(value, forKey: key)
        // Or, more likely:
        // NotificationPreferencesService.shared.updatePreference(key: key, value: value) { result in ... }
    }

    // Mock loading function (replace with actual persistence)
    func loadPreferences() {
        print("Loading preferences...")
        // In reality, load the @State vars from UserDefaults or backend here.
        // e.g., self.allowPromotionalPush = UserDefaults.standard.bool(forKey: "promotionalPush")
    }

    func statusText(for status: UNAuthorizationStatus) -> Text {
        switch status {
        case .authorized: return Text("Allowed")
        case .denied: return Text("Denied")
        case .notDetermined: return Text("Not Determined")
        case .provisional: return Text("Provisional") // Quiet notifications
        case .ephemeral: return Text("Ephemeral") // App Clips
        @unknown default: return Text("Unknown")
        }
    }

    func statusColor(for status: UNAuthorizationStatus) -> Color {
        switch status {
        case .authorized: return .green
        case .denied: return .red
        case .notDetermined: return .gray
        case .provisional: return .orange
        case .ephemeral: return .blue
        @unknown default: return .gray
        }
    }
}

// --- Previews ---
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationSettingsView()
        }
        .previewDisplayName("Default Preview")
    }
}
