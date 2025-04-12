//
//  TheNextLogicalView.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI

// MARK: - Settings View Model (Optional but Good Practice)

@MainActor // Ensure updates happen on the main thread
class SettingsViewModel: ObservableObject {
    // Example: Load initial state or fetch dynamic data
    @Published var userEmail: String = "example.user@email.com" // Mock data
    @Published var appVersion: String = "Unknown"

    init() {
        fetchAppVersion()
    }

    // Fetch dynamic info (like app version)
    func fetchAppVersion() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
        appVersion = "Version \(version) (\(build))"
    }

    // --- Actions ---
    func clearCache() {
        // --- Production Implementation ---
        // Implement actual cache clearing logic here
        // Example: URLCache.shared.removeAllCachedResponses()
        // Example: Clear custom file caches
        // -------------------------------
        print("Simulating cache clear...")
        // Optionally update UI state if needed (e.g., show confirmation)
    }

    func logOut() {
        // --- Production Implementation ---
        // Implement actual log out logic:
        // - Clear user session/tokens
        // - Reset relevant app state
        // - Navigate user to Login screen
        // -------------------------------
        print("Simulating log out...")
        // For demo, we might just clear the email
        userEmail = "Logged Out"
    }

    func requestNotificationPermissions() {
        // --- Production Implementation ---
        // Use UNUserNotificationCenter.current().requestAuthorization(...)
        // Handle the authorization status (granted, denied, etc.)
        // Update UI based on the result (e.g., disable toggles if denied)
        // -------------------------------
        print("Simulating request for notification permissions...")
    }
}

// MARK: - Settings View

struct SettingsView: View {
    // Use StateObject if ViewModel is created here, or ObservedObject if passed in
    @StateObject private var viewModel = SettingsViewModel()

    // --- Local UI State ---
    // Use @AppStorage for persistence in a real app
    @State private var appearanceMode: AppearanceMode = .system // Default
    @State private var enableNotifications: Bool = true
    @State private var enableSounds: Bool = false
    @State private var useBiometrics: Bool = false
    @State private var showingLogoutAlert = false // For confirmation

    enum AppearanceMode: String, CaseIterable, Identifiable {
        case light = "Light"
        case dark = "Dark"
        case system = "System Default"
        var id: String { self.rawValue }
    }

    var body: some View {
        Form { // Use Form for standard settings styling
            // --- Account Section ---
            Section("Account") {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(viewModel.userEmail)
                        .foregroundColor(.secondary)
                }

                Toggle("Use Face ID / Touch ID", isOn: $useBiometrics)

                Button("Log Out", role: .destructive) {
                    showingLogoutAlert = true // Show confirmation first
                }
            }

            // --- Appearance Section ---
            Section("Appearance") {
                Picker("Theme", selection: $appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                // In production, you'd use .onChange to apply the theme
                // .onChange(of: appearanceMode) { newMode in applyTheme(newMode) }
            }

            // --- Notifications Section ---
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: $enableNotifications)
                    .onChange(of: enableNotifications) {
                        if enableNotifications {
                            // Request permissions if enabling
                            viewModel.requestNotificationPermissions()
                        } else {
                            // Optionally unregister if needed
                        }
                    }

                // Disable sound toggle if notifications are off
                Toggle("Enable Sounds", isOn: $enableSounds)
                    .disabled(!enableNotifications)
                    .foregroundColor(enableNotifications ? .primary : .secondary)
             }

            // --- Data Management Section ---
            Section("Data Management") {
                Button("Clear Cache") {
                    viewModel.clearCache()
                    // Optionally show a temporary confirmation message
                }
            }

            // --- About & Support Section ---
            Section("About") {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundColor(.secondary)
                }
                Link("Privacy Policy", destination: URL(string: "https://www.example.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://www.example.com/terms")!)
                Link("Contact Support", destination: URL(string: "mailto:support@example.com")!)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        // Alert for Logout Confirmation
        .alert("Confirm Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                viewModel.logOut()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        // --- In Production ---
        // You would typically load initial values for toggles/pickers
        // from UserDefaults/@AppStorage or a dedicated settings service
        // in the ViewModel's init or onAppear.
        // .onAppear { loadSettings() }
    }

    // --- Placeholder functions for real implementation ---
    // func applyTheme(_ mode: AppearanceMode) {
    //     print("Applying theme: \(mode.rawValue)")
    //     // Access the window scene and set preferredColorScheme
    // }
    //
    // func loadSettings() {
    //     // Load values from UserDefaults/@AppStorage
    //     print("Loading settings...")
    // }
}

// MARK: - Integration into ContentView

// *Modify your existing ContentView like this:*
struct ContentView: View { // Keep your existing ContentView structure
    @StateObject private var contentViewModel = ContentViewModel() // Existing ViewModel
    // Other @State variables from the previous example...

    var body: some View {
        // *** Ensure ContentView is wrapped in a NavigationView ***
        NavigationView {
            VStack(spacing: 30) {
                 // ... your existing appTitle, contentExamples, actionButtons ...
                appTitle
                Divider()
                contentExamples
                Spacer()
                actionButtons
            }
            .padding()
            .navigationTitle("Share Sheet Demo") // Title for this view
            .navigationBarTitleDisplayMode(.inline)
            // --- Toolbar Item for Settings ---
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        // Navigate to the SettingsView
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
            // --- Existing Sheet and Alert Modifiers ---
            .sheet(isPresented: $contentViewModel.isShareSheetPresented) {
                ActivityView(
                    activityItems: contentViewModel.currentActivityItems,
                    //excludedActivityTypes: [.assignToContact, .addToReadingList],
                    completion: contentViewModel.handleShareResult
                )
            }
            .alert(isPresented: $contentViewModel.isAlertPresented) {
                Alert(
                    title: Text(contentViewModel.alertTitle),
                    message: Text(contentViewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(.stack) // Recommend stack style
    }

    // --- Existing View Components (appTitle, contentExamples, actionButtons) ---
    private var appTitle: some View { /* ... Keep implementation ... */
        Text("Dynamic Sharing").font(.largeTitle.weight(.bold))
    }
    private var contentExamples: some View { /* ... Keep implementation ... */
        VStack(alignment: .leading, spacing: 15) {
            Text("Example Content Available:").font(.headline)
            // Labels for text, url, image
        }
    }
    private var actionButtons: some View { /* ... Keep implementation ... */
        VStack(spacing: 15) {
            // Buttons for sharing
        }
    }
}

// MARK: - Preview Providers

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for Preview
            SettingsView()
        }
    }
}

// Ensure ContentView Preview also works
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
