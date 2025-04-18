//
//  SettingsView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

import SwiftUI

// MARK: - Mock Data Models & Enums
struct UserProfile: Codable { // Codable for potential persistence
    var name: String = "Community User"
    var email: String = "user@example.com"
    var membership: String = "Community Member"
    var profileImageName: String? = nil // Optional placeholder for custom image
}

struct LanguageModel: Identifiable, Hashable {
    let id: String
    let name: String
    var description: String? = nil // Optional description
}

enum FeedbackType: String, CaseIterable, Identifiable {
    case bug = "Bug Report"
    case feature = "Feature Request"
    case suggestion = "Suggestion"
    case other = "Other"
    var id: String { self.rawValue }
}

// MARK: - Enhanced Data Model for Settings Items (Unchanged)
enum NavigationType {
    case detailView(AnyView)
    case sheet(AnyView)
    case url(URL)
    case action(() -> Void)
    case none
}

struct SettingItem: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let navigationType: NavigationType
}

// MARK: - Main App Structure (Optional but Recommended)
/*
 
 */
@main
struct SettingsDemoApp: App {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false // Default to system or light
    @AppStorage("userProfile") var userProfileData: Data? // For persisting profile
    
    // Load initial profile or default
    var initialProfile: UserProfile {
        if let data = userProfileData, let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return decoded
        }
        return UserProfile() // Default
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(userProfile: initialProfile) // Pass initial profile
                .preferredColorScheme(isDarkMode ? .dark : .light)
            // Pass other global dependencies if needed
        }
    }
}

// MARK: - Main Content View (Holds the TabView)
struct ContentView: View {
    @State private var selectedTab = 2 // Default to "Me" tab
    @AppStorage("isDarkMode") var isDarkMode: Bool = false // Default light/system
    @State var userProfile: UserProfile = UserProfile() // Manage UserProfile state
    
    // Dynamic Colors
    let activeTabColor = Color.orange // Changed accent color slightly
    let inactiveTabColor = Color.gray
    var backgroundColor: Color { isDarkMode ? Color(UIColor.systemBackground) : Color(UIColor.systemGroupedBackground) } // Use standard system colors
    var listRowBackgroundColor: Color { isDarkMode ? Color(UIColor.secondarySystemGroupedBackground) : Color(UIColor.systemBackground) }
    var textColor: Color { Color(UIColor.label) } // Adapts automatically
    var secondaryTextColor: Color { Color(UIColor.secondaryLabel) } // Adapts automatically
    var iconColor: Color { activeTabColor } // Use accent for icons
    
    init(userProfile: UserProfile = UserProfile()) { // Allow passing initial profile
        self._userProfile = State(initialValue: userProfile)
        configureTabBarAppearance()
    }
    
    // Function to configure Tab Bar
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground() // More standard appearance
        
        // Better to use system background colors for adaptation
        appearance.backgroundColor = isDarkMode ? UIColor.secondarySystemGroupedBackground : UIColor.systemBackground
        
        // Set item colors using UIColor for better precision
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(activeTabColor)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(activeTabColor)]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(inactiveTabColor)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(inactiveTabColor)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = UIColor(activeTabColor) // Consistent tint
    }
    
    var body: some View {
        // Re-apply appearance on dark mode change
        let _ = configureTabBarAppearance()
        
        return TabView(selection: $selectedTab) {
            // --- Placeholder Views ---
            PlaceholderTabView(title: "Chat View", systemImage: "message.fill", tag: 0, backgroundColor: backgroundColor, textColor: textColor)
            PlaceholderTabView(title: "Discover View", systemImage: "safari.fill", tag: 1, backgroundColor: backgroundColor, textColor: textColor)
            
            // --- Settings Screen ---
            SettingsScreen(
                isDarkMode: $isDarkMode,
                userProfile: $userProfile, // Pass binding for profile
                backgroundColor: backgroundColor,
                listRowBackgroundColor: listRowBackgroundColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                iconColor: iconColor,
                activeTabColor: activeTabColor // Pass accent color for buttons
            )
            .tag(2)
            .tabItem {
                Label("Me", systemImage: "person.fill")
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        // Persist profile changes (Example using onChange)
        //.onChange(of: userProfile) { saveUserProfile(userProfile) }
        // You might prefer saving only when explicitly done in ProfileEditView
    }
    
    // Example persistence function (Could move to a dedicated data manager)
    private func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            // Using UserDefaults directly here, but typically you'd use @AppStorage
            UserDefaults.standard.set(encoded, forKey: "userProfile")
            print("UserProfile Saved (Example)")
        }
    }
}

// MARK: - Placeholder Tab View Helper (Unchanged)
struct PlaceholderTabView: View {
    let title: String
    let systemImage: String
    let tag: Int
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        // Replace with actual content for Chat/Discover later
        ZStack {
            backgroundColor.ignoresSafeArea()
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 50))
                    .foregroundColor(textColor.opacity(0.5))
                    .padding(.bottom)
                Text(title)
                    .font(.title)
                    .foregroundColor(textColor)
            }
        }
        .tag(tag)
        .tabItem {
            Label(title, systemImage: systemImage)
        }
    }
}

// MARK: - Settings Screen View ("Me" Tab Content)
struct SettingsScreen: View {
    @AppStorage("appLockEnabled") var appLockEnabled: Bool = false
    @AppStorage("shareAnalyticsEnabled") var shareAnalyticsEnabled: Bool = true

    
    // Bindings and State
    @Binding var isDarkMode: Bool
    @Binding var userProfile: UserProfile
    let backgroundColor: Color
    let listRowBackgroundColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let iconColor: Color
    let activeTabColor: Color // Receive accent color
    
    @State private var showingSheetForItem: SettingItem? = nil
    @State private var showingAlertForItem: SettingItem? = nil // Renamed for specific use
    @State private var showClearCacheAlert: Bool = false
    @State private var showLogoutAlert: Bool = false // Specific alert state
    @State private var cacheSizeMB: Double = 150.0 * Double.random(in: 0.8...1.2) // Slightly randomized mock cache
    @State private var showCacheClearedBanner = false
    
    // Data Dependencies (Persisted via @AppStorage)
    @AppStorage("selectedLanguageModelId") var selectedLanguageModelId: String = "gpt-4o" // Updated default
    @AppStorage("ttsSpeed") var ttsSpeed: Double = 1.0
    @AppStorage("defaultAssistantId") var defaultAssistantId: String = "general"
    @AppStorage("enableFeatureX") var enableFeatureX: Bool = true // More specific name
    @AppStorage("appIconBadgeEnabled") var appIconBadgeEnabled: Bool = true
    @AppStorage("systemResponseLength") var systemResponseLength: Double = 0.5
    @AppStorage("systemCreativityLevel") var systemCreativityLevel: Int = 1
    
    // Mock Data Definitions (Moved inside for context)
    let availableModels = [
        LanguageModel(id: "gpt-4o", name: "GPT-4o", description: "Latest flagship model from OpenAI."),
        LanguageModel(id: "claude-3-opus", name: "Claude 3 Opus", description: "Most powerful model from Anthropic."),
        LanguageModel(id: "gemini-1.5-pro", name: "Gemini 1.5 Pro", description: "Latest large model from Google."),
        LanguageModel(id: "llama-3-70b", name: "Llama 3 70B", description: "Large open-weight model from Meta.")
    ]
    
    let availableAssistants = [
        (id: "general", name: "General Assistant"),
        (id: "coding", name: "Coding Helper"),
        (id: "creative", name: "Creative Writer"),
        (id: "research", name: "Research Expert")
    ]
    
    // --- Lazy generation of settings items ---
    // Computed properties to construct SettingItem arrays dynamically
    var generalSettings: [SettingItem] {
        [
            SettingItem(iconName: "person.text.rectangle", title: "Account", navigationType: .detailView(AnyView(AccountSettingsView(userProfile: $userProfile, showLogoutAlert: $showLogoutAlert, activeTabColor: activeTabColor)))),
            SettingItem(iconName: "slider.horizontal.3", title: "Common Settings", navigationType: .detailView(AnyView(CommonSettingsView(enableFeatureX: $enableFeatureX, appIconBadgeEnabled: $appIconBadgeEnabled)))),
            // *** NEW ITEM ADDED HERE ***
            SettingItem(iconName: "shield.lefthalf.filled", title: "Privacy & Security", navigationType: .detailView(AnyView(PrivacySecurityView(appLockEnabled: $appLockEnabled, shareAnalyticsEnabled: $shareAnalyticsEnabled, accentColor: activeTabColor)))),
            // **************************
            SettingItem(iconName: "brain.filled.head.profile", title: "System Assistant", navigationType: .detailView(AnyView(AssistantSettingsView(responseLength: $systemResponseLength, creativityLevel: $systemCreativityLevel)))),
            SettingItem(iconName: "cpu", title: "Language Model", navigationType: .detailView(AnyView(LanguageModelView(availableModels: availableModels, selectedModelId: $selectedLanguageModelId)))),
            SettingItem(iconName: "speaker.wave.3", title: "Text-to-Speech", navigationType: .detailView(AnyView(TTSView(speed: $ttsSpeed, accentColor: activeTabColor)))),
            SettingItem(iconName: "brain", title: "Default Assistant", navigationType: .detailView(AnyView(DefaultAssistantView(availableAssistants: availableAssistants, selectedAssistantId: $defaultAssistantId)))),
            SettingItem(iconName: "info.circle", title: "About", navigationType: .detailView(AnyView(AboutView(appVersion: "1.2.0"))))
        ]
    }
    
    var appInfoSettings: [SettingItem] {
        [
            SettingItem(iconName: "cylinder.split.1x2", title: "Data Storage", navigationType: .detailView(AnyView(DataStorageView(cacheSizeMB: $cacheSizeMB, showClearCacheAlert: $showClearCacheAlert, accentColor: activeTabColor)))),
            SettingItem(iconName: "book.pages", title: "User Manual", navigationType: .url(URL(string: "https://docs.lobehub.com")!)), // Updated URL
            SettingItem(iconName: "paperplane", title: "Feedback", navigationType: .sheet(AnyView(FeedbackView(accentColor: activeTabColor)))),
            SettingItem(iconName: "list.bullet.clipboard", title: "Changelog", navigationType: .sheet(AnyView(ChangelogView()))),
            // Example of a direct action row
            SettingItem(iconName: "arrow.triangle.2.circlepath", title: "Check for Updates", navigationType: .action(checkForUpdates))
        ]
    }
    
    // --- Actions ---
    private func openURL(_ url: URL) {
        UIApplication.shared.open(url) { success in
            if !success {
                print("Failed to open URL: \(url)")
                // TODO: Show an alert to the user indicating the failure
            }
        }
    }
    
    private func clearCache() {
        print("Clearing cache...")
        showCacheClearedBanner = false // Hide previous banner immediately if exists
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { // Simulate work
            cacheSizeMB = Double.random(in: 0.5...5.0) // Simulate new small cache size
            print("Cache Cleared!")
            withAnimation(.spring()) {
                showCacheClearedBanner = true // Show banner feedback
            }
            // Hide banner after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut) {
                    showCacheClearedBanner = false
                }
            }
        }
    }
    
    private func performLogout() {
        print("Logging out user...")
        // 1. Clear sensitive user data (tokens, credentials, potentially profile)
        // Example: Reset profile to default (or fetch logged-out state)
        userProfile = UserProfile(name: "Guest", email: "", membership: "None")
        // 2. Clear any persisted tokens/session info
        // e.g., delete items from Keychain or @AppStorage related to auth
        // 3. Navigate the user to the login screen (would require app architecture change)
        print("User logged out.")
        // For this demo, we just update the profile state.
    }
    
    private func checkForUpdates() {
        print("Checking for updates (mock action)...")
        // Simulate a check
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // In a real app, compare current version with server version
            showingAlertForItem = SettingItem(iconName: "", title: "Check for Updates", navigationType: .none) // Use a dummy item to show alert
        }
    }
    
    // --- Body ---
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                settingsList // Call the @ViewBuilder function for the List
                    .listStyle(.insetGrouped)
                    .background(backgroundColor.ignoresSafeArea()) // Apply background to the list container
                    .scrollContentBackground(.hidden) // Essential for custom background color
                    .navigationTitle("Me")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            darkModeToggleButton
                        }
                    }
                // --- Modifiers (Remain the same) ---
                    .sheet(item: $showingSheetForItem) { item in
                        sheetContent(for: item)
                            .preferredColorScheme(isDarkMode ? .dark : .light)
                            .presentationDetents([.medium, .large])
                    }.alert(item: $showingAlertForItem, content: genericActionAlert)
                // TODO: Update alert types and messages as examples below
                // .alert("Clear Cache", isPresented: $showClearCacheAlert, actions: clearCacheAlertButtons, message: clearCacheAlertMessage)
                // .alert("Log Out", isPresented: $showLogoutAlert, actions: logoutAlertButtons, message: logoutAlertMessage)
            } // End NavigationStack
            .background(backgroundColor.edgesIgnoringSafeArea(.all))
            .ignoresSafeArea(.keyboard)
            
            // --- Cache Cleared Banner ---
            if showCacheClearedBanner {
                NotificationBanner(text: "Cache Cleared Successfully!", iconName: "checkmark.circle.fill", style: .success)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear { UIAccessibility.post(notification: .announcement, argument: "Cache Cleared Successfully!") }
                    .padding(.bottom, 50)
            }
        } // End ZStack
        
    }
    
    // --- @ViewBuilder functions for List Content ---
    // ********** settingsList **********
    @ViewBuilder
    private var settingsList: some View {
        List {
            userInfoSection // Call sub-builder
            generalSettingsSection // Call sub-builder
            appInfoSettingsSection // Call sub-builder
            footer
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
    }
    
    // ********** userInfoSection **********
    @ViewBuilder
    private var userInfoSection: some View {
        NavigationLink(destination: AccountSettingsView(userProfile: $userProfile, showLogoutAlert: $showLogoutAlert, activeTabColor: activeTabColor)) {
            UserInfoHeader(
                userProfile: userProfile,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                iconColor: iconColor
            )
        }
        .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 15))
        .listRowBackground(listRowBackgroundColor)
        .listRowSeparator(.hidden)
    }
    
    // ********** generalSettingsSection **********
    @ViewBuilder
    private var generalSettingsSection: some View {
        Section {
            ForEach(generalSettings) { row(for: $0) }
        } header: {
            Text("General")
                .fontWeight(.medium)
                .foregroundColor(secondaryTextColor)
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
        .listRowBackground(listRowBackgroundColor)
        .listRowSeparatorTint(Color.gray.opacity(0.4))
    }
    
    // ********** appInfoSettingsSection **********
    @ViewBuilder
    private var appInfoSettingsSection: some View {
        Section {
            ForEach(appInfoSettings) { row(for: $0) }
        } header: {
            Text("Application")
                .fontWeight(.medium)
                .foregroundColor(secondaryTextColor)
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
        .listRowBackground(listRowBackgroundColor)
        .listRowSeparatorTint(Color.gray.opacity(0.4))
    }
    
    // --- Row Builder ---
    @ViewBuilder
    private func row(for item: SettingItem) -> some View {
        switch item.navigationType {
        case .detailView(let destinationView):
            NavigationLink(destination: destinationView
                .preferredColorScheme(isDarkMode ? .dark : .light)
            ) {
                SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
            }
        case .sheet:
            Button { showingSheetForItem = item } label: {
                HStack {
                    SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
                    Spacer()
                    Image(systemName: "chevron.up.square") // Icon suggesting a sheet presentation
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .contentShape(Rectangle()) // Ensure entire row is tappable
            }.buttonStyle(.plain) // Use plain style to avoid default button look inside list
        case .url(let url):
            Button { openURL(url) } label: {
                HStack {
                    SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens link in browser") // Accessibility improvement
        case .action(let action):
            Button(action: action, label: {
                SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
            })
            .buttonStyle(.plain)
        case .none: EmptyView()
        }
    }
    
    // --- Extracted Toolbar Button ---
    private var darkModeToggleButton: some View {
        Button {
            withAnimation { isDarkMode.toggle() }
        } label: {
            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                .foregroundColor(secondaryTextColor)
                .imageScale(.medium) // Slightly larger icon
        }
        .accessibilityLabel(isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode")
    }
    
    // --- Sheet Content Builder ---
    @ViewBuilder
    private func sheetContent(for item: SettingItem) -> some View {
        // IMPORTANT: Pass isDarkMode down if sheet content needs it
        if case .sheet(let view) = item.navigationType {
            view
            // If the sheet content itself needs the dark mode state:
             .environment(\.colorScheme, isDarkMode ? .dark : .light)
            // Or pass isDarkMode as a @Binding if it modifies it
            
        } else {
            EmptyView()
        }
    }
    
    // --- Alert Components ---
    @ViewBuilder private var clearCacheAlertButtons: some View {
        Button("Clear", role: .destructive) { clearCache() }
        Button("Cancel", role: .cancel) {}
    }
    
    private var clearCacheAlertMessage: Text {
        Text("This will remove temporary files (\(String(format: "%.1f", cacheSizeMB)) MB) and may require some data to be re-downloaded. Are you sure?")
    }
    
    @ViewBuilder private var logoutAlertButtons: some View {
        Button("Log Out", role: .destructive) { performLogout() }
        Button("Cancel", role: .cancel) {}
    }
    
    private var logoutAlertMessage: Text {
        Text("Are you sure you want to log out? You will need to sign in again to access your account.")
    }
    
    private func genericActionAlert(for item: SettingItem) -> Alert {
        // Handle the "Check for Updates" specific case
        if item.title == "Check for Updates" {
            return Alert(title: Text("Up to Date"),
                         message: Text("You are running the latest version (1.2.0)."),
                         dismissButton: .default(Text("OK")))
        }
        
        // Default fallback for other actions (if any added later)
        guard case .action(let action) = item.navigationType else {
            return Alert(title: Text("Error")) // Should not happen with current setup
        }
        return Alert(title: Text("Confirm Action"),
                     message: Text("Perform '\(item.title)'?"),
                     primaryButton: .default(Text("OK"), action: action),
                     secondaryButton: .cancel())
    }
    
    // --- Footer View ---
    private var footer: some View {
        Text("Ask a Le - v1.0.0\n© \(Calendar.current.component(.year, from: Date())) CongLeSolutionX")
            .font(.caption2) // Smaller caption
            .foregroundColor(secondaryTextColor)
            .multilineTextAlignment(.center) // Center align multi-line text
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 15) // Reduced padding slightly
    }
}

// MARK: - Reusable User Info Header View (Updated)
struct UserInfoHeader: View {
    let userProfile: UserProfile
    let textColor: Color
    let secondaryTextColor: Color
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) { // Increased spacing slightly
            Image(systemName: userProfile.profileImageName ?? "person.crop.circle.fill") // Use placeholder if no custom image name
                .resizable()
                .aspectRatio(contentMode: .fill) // Use fill for potentially non-square images
                .frame(width: 55, height: 55) // Slightly larger image
                .foregroundColor(iconColor.opacity(0.8)) // Use accent color
                .background(Color.gray.opacity(0.15)) // Subtle background
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)) // Thinner overlay
            
            VStack(alignment: .leading, spacing: 4) { // Increased spacing
                Text(userProfile.name)
                    .font(.headline)
                    .fontWeight(.semibold) // Semibold for name
                    .foregroundColor(textColor)
                Text(!userProfile.email.isEmpty ? userProfile.email : "No email provided") // Handle empty email
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
                    .lineLimit(1) // Prevent long emails wrapping awkwardly
            }
            Spacer()
            if userProfile.membership != "None" { // Only show if membership exists
                Text(userProfile.membership)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(textColor) // Adjust color based on background
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(iconColor.opacity(0.2)) // Softer background using accent
                    .clipShape(Capsule()) // Use Capsule shape
            }
        }
    }
}

// MARK: - Reusable Settings Row Content (Unchanged, but reviewed for clarity)
struct SettingsRowContent: View {
    let item: SettingItem
    let iconColor: Color
    let textColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: item.iconName)
                .font(.headline) // Slightly larger icons
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28, alignment: .center) // Ensure consistent icon area size
                .background(iconColor.opacity(0.1)) // Subtle icon background
                .clipShape(RoundedRectangle(cornerRadius: 6)) // Rounded background
            
            Text(item.title)
                .foregroundColor(textColor)
                .padding(.leading, 2) // Add slight padding after icon background
        }
    }
}

// MARK: - Notification Banner View (Enhanced)
struct NotificationBanner: View {
    let text: String
    let iconName: String
    let style: BannerStyle
    
    enum BannerStyle {
        case success, error, info
        
        var iconColor: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundColor(style.iconColor)
            Text(text)
                .font(.footnote)
                .foregroundColor(Color(UIColor.label)) // Use adaptive label color
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial) // Use material for blur effect
        .clipShape(Capsule()) // Use capsule shape
        .shadow(color: .black.opacity(0.1), radius: 5, y: 3) // Softer shadow
    }
}

// MARK: - Interactive Destination/Sheet Views (FUNCTIONAL)

struct AccountSettingsView: View {
    @Binding var userProfile: UserProfile
    @Binding var showLogoutAlert: Bool
    let activeTabColor: Color // Accent color for buttons
    
    var body: some View {
        Form {
            Section("Account Information") {
                HStack { Text("Name"); Spacer(); Text(userProfile.name).foregroundColor(.secondary) }
                HStack { Text("Email"); Spacer(); Text(!userProfile.email.isEmpty ? userProfile.email : "Not Set").foregroundColor(.secondary) }
                HStack { Text("Membership"); Spacer(); Text(userProfile.membership).foregroundColor(.secondary) }
            }
            Section {
                NavigationLink {
                    ProfileEditView(userProfile: $userProfile, accentColor: activeTabColor)
                } label: {
                    Label("Edit Profile", systemImage: "pencil")
                }
            }
            Section {
                Button(role: .destructive) {
                    showLogoutAlert = true // Trigger alert in parent
                } label: {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red) // Explicitly color destructive action
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline) // Use inline for sub-views
    }
}

struct CommonSettingsView: View {
    @Binding var enableFeatureX: Bool
    @Binding var appIconBadgeEnabled: Bool
    
    var body: some View {
        Form {
            Section("General Features") {
                Toggle("Enable Special Feature", isOn: $enableFeatureX)
                    .tint(Color.orange) // Apply accent color to toggle
            }
            Section("Notifications") {
                Toggle("App Icon Badge", isOn: $appIconBadgeEnabled)
                    .tint(Color.orange)
                    .onChange(of: appIconBadgeEnabled) { _, newValue in
                        // Update actual app badge setting here
                        // UIApplication.shared.applicationIconBadgeNumber = newValue ? 1 : 0 // Example
                        //  -[UNUserNotificationCenter setBadgeCount:withCompletionHandler:] instead.
                        print("\(String(describing: UNUserNotificationCenter.setBadgeCount(.current())))")
                        print("App icon badge \(newValue ? "enabled" : "disabled")")
                    }
            }
            // Add more common settings...
            Section("Example Setting") {
                Text("This is another setting example.")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Common Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AssistantSettingsView: View {
    @Binding var responseLength: Double
    @Binding var creativityLevel: Int
    
    func lengthLabel(for value: Double) -> String {
        switch value {
        case ..<0.33: return "Short"
        case 0.33..<0.66: return "Medium"
        default: return "Long"
        }
    }
    
    func creativityLabel(for value: Int) -> String {
        switch value {
        case 0: return "Precise"
        case 1: return "Balanced"
        case 2: return "Creative"
        default: return ""
        }
    }
    
    var body: some View {
        Form {
            Section("Response Configuration") {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Max Response Length: \(lengthLabel(for: responseLength))")
                        .font(.subheadline)
                    Slider(value: $responseLength, in: 0...1) // Use binding to @AppStorage
                        .tint(.orange)
                }
                .padding(.vertical, 5) // Add padding around slider
                
                Picker("Creativity Level", selection: $creativityLevel) { // Use binding to @AppStorage
                    Text("Precise").tag(0)
                    Text("Balanced").tag(1)
                    Text("Creative").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 5)
            }
            Section("Example") {
                Text("Adjust how the AI responds to your prompts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("System Assistant")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LanguageModelView: View {
    let availableModels: [LanguageModel]
    @Binding var selectedModelId: String
    
    var body: some View {
        Form {
            Section {
                Picker("Preferred Model", selection: $selectedModelId) {
                    ForEach(availableModels) { model in
                        VStack(alignment: .leading) {
                            Text(model.name).tag(model.id)
                            if let description = model.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .pickerStyle(.inline) // Good for longer lists with descriptions
                .labelsHidden() // Hide the "Preferred Model" label from the picker itself
            } header: {
                Text("Select the primary AI model") // Use header instead of Picker label
            }
            
            // Display selection clearly below
            Section("Current Selection") {
                Text(availableModels.first(where: {$0.id == selectedModelId})?.name ?? "Unknown Model")
            }
        }
        .navigationTitle("Language Model")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TTSView: View {
    @Binding var speed: Double
    let accentColor: Color
    @State private var isPreviewing = false // State for preview button
    
    var body: some View {
        Form {
            Section("Playback Configuration") {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Voice Speed:")
                        Spacer()
                        Text("\(String(format: "%.1f", speed))x")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    Slider(value: $speed, in: 0.5...2.0, step: 0.1)
                        .tint(accentColor) // Use accent color
                }
                .padding(.vertical, 5)
                
                Button {
                    isPreviewing = true
                    print("Simulating TTS preview at speed \(speed)x...")
                    // TODO: Integrate actual AVFoundation speech synthesis
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isPreviewing = false // End simulation
                    }
                } label: {
                    HStack {
                        Label("Preview Voice", systemImage: isPreviewing ? "stop.circle" : "play.circle")
                        Spacer()
                        if isPreviewing {
                            ProgressView().scaleEffect(0.7) // Show spinner during preview
                        }
                    }
                }
                .disabled(isPreviewing) // Disable while previewing
                .tint(isPreviewing ? .gray : accentColor) // Change tint when disabled/active
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("Text-to-Speech")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DefaultAssistantView: View {
    let availableAssistants: [(id: String, name: String)]
    @Binding var selectedAssistantId: String
    
    var body: some View {
        Form {
            Section {
                Picker("Select Default", selection: $selectedAssistantId) {
                    ForEach(availableAssistants, id: \.id) { assistant in
                        Label(assistant.name, systemImage: assistantIcon(for: assistant.id)) // Add icons
                            .tag(assistant.id)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("Choose the assistant for new chats")
            } footer: {
                Text("You can always switch assistants within a chat.")
            }
        }
        .navigationTitle("Default Assistant")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper for Picker icons
    func assistantIcon(for id: String) -> String {
        switch id {
        case "coding": return "curlybraces.square.fill"
        case "creative": return "paintbrush.pointed.fill"
        case "research": return "magnifyingglass"
        default: return "person.fill"
        }
    }
}

struct AboutView: View {
    let appVersion: String
    @Environment(\.openURL) var openURL // Use environment action
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Spacer(minLength: 30) // Add space at the top
                Image("lobehub-logo") // Assuming you have a logo asset named this
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16)) // Rounded corners for logo
                    .shadow(radius: 3)
                
                VStack(spacing: 5) {
                    Text("LobeHub Companion")
                        .font(.title2.weight(.semibold))
                    Text("Version \(appVersion)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your intelligent chat assistant powered by cutting-edge AI models. Explore, create, and learn with LobeHub.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    Divider()
                    
                    Button { openURL(URL(string: "https://github.com/CongLeSolutionX")!) } label: {
                        Label("GitHub Repository", systemImage: "link")
                    }
                    Button { openURL(URL(string: "https://github.com/CongLeSolutionX")!) } label: {
                        Label("Official Website", systemImage: "safari")
                    }
                    Button { openURL(URL(string: "https://discord.gg/AYFPHvv2jT")!) } label: {
                        Label("Join Discord Community", systemImage: "bubble.left.and.bubble.right")
                    }
                }
                .buttonStyle(.bordered) // Style buttons nicely
                .tint(.orange) // Use accent color
                
                Spacer(minLength: 20)
                Text("© \(Calendar.current.component(.year, from: Date())) CongLeSolutionX")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer(minLength: 30) // Add space at the bottom
            }
            .padding(.horizontal, 30) // Add horizontal padding to content
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea()) // Match background
    }
}

struct DataStorageView: View {
    @Binding var cacheSizeMB: Double
    @Binding var showClearCacheAlert: Bool
    let accentColor: Color
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Label("Application Cache", systemImage: "archivebox")
                    Spacer()
                    Text("\(String(format: "%.1f", cacheSizeMB)) MB")
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
                // Add other storage metrics if relevant (e.g., database size)
            } footer: {
                Text("Cache includes temporary files, downloaded assets, and model data.")
            }
            
            Section {
                Button(role: .destructive) {
                    showClearCacheAlert = true
                } label: {
                    Label("Clear Cache Now", systemImage: "trash")
                        .foregroundColor(.red) // Match destructive role color
                }
            }
        }
        .navigationTitle("Data Storage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileEditView: View {
    @Binding var userProfile: UserProfile
    let accentColor: Color
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme // To adjust UI based on mode
    
    // Temporary state for editing
    @State private var editedName: String
    @State private var editedEmail: String
    @State private var showSaveAlert = false
    
    var isInputValid: Bool {
        !editedName.trimmingCharacters(in: .illegalCharacters).isEmpty &&
        (editedEmail.isEmpty || isValidEmail(editedEmail)) // Allow empty email or validate format
    }
    
    // Simple email validation helper
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    init(userProfile: Binding<UserProfile>, accentColor: Color) {
        self._userProfile = userProfile
        self.accentColor = accentColor
        // Initialize local state *only once* when the view appears
        self._editedName = State(initialValue: userProfile.wrappedValue.name)
        self._editedEmail = State(initialValue: userProfile.wrappedValue.email)
    }
    
    var body: some View {
        NavigationView { // Embed in NavigationView for its own toolbar
            Form {
                Section("Personal Information") {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(accentColor)
                            .frame(width: 20)
                        TextField("Name", text: $editedName)
                            .textContentType(.name)
                    }
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(accentColor)
                            .frame(width: 20)
                        TextField("Email (Optional)", text: $editedEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.emailAddress)
                    }
                }
                Section("Profile Picture (Example)") {
                    Text("Tap to change (not implemented)")
                        .foregroundColor(.secondary)
                    // TODO: Add image picker functionality here
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .tint(accentColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if isInputValid {
                            // Update the actual profile binding
                            userProfile.name = editedName.trimmingCharacters(in: .illegalCharacters)
                            userProfile.email = editedEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                            // Persist changes explicitly if needed (instead of relying only on onChange)
                            // saveUserProfile(userProfile)
                            print("Profile Updated!")
                            dismiss()
                        } else {
                            showSaveAlert = true
                        }
                    }
                    .tint(accentColor)
                    .disabled(!isInputValid) // Disable if input is invalid
                }
            }
            .alert("Invalid Input", isPresented: $showSaveAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please ensure your name is not empty and email format is correct.")
            }
        }
        // Apply color scheme correctly to the NavigationView itself
        .preferredColorScheme(colorScheme == .dark ? .dark : .light)
    }
}

struct FeedbackView: View {
    @State private var feedbackText: String = ""
    @State private var feedbackType: FeedbackType = .suggestion // Default to suggestion
    @State private var showConfirmation = false
    @State private var isSubmitting = false
    let accentColor: Color
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Feedback Category") {
                    Picker("Type", selection: $feedbackType) {
                        ForEach(FeedbackType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    // Consider .pickerStyle(.segmented) if fewer options
                }
                
                Section("Details") {
                    TextEditor(text: $feedbackText)
                        .frame(height: 150, alignment: .top)
                        .colorMultiply(Color(UIColor.secondarySystemGroupedBackground)) // Give subtle background
                        .cornerRadius(8)
                        .overlay(
                            Text("Please provide details...")
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(8)
                                .opacity(feedbackText.isEmpty ? 1 : 0),
                            alignment: .topLeading
                        )
                        .accessibilityLabel("Feedback details input area")
                }
                
                Section {
                    Button {
                        isSubmitting = true
                        // Mock submission with delay
                        print("--- Feedback Submitted ---")
                        print("Type: \(feedbackType.rawValue)")
                        print("Details: \(feedbackText)")
                        print("-------------------------")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isSubmitting = false
                            showConfirmation = true
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView().tint(.white) // White spinner on colored background
                            } else {
                                Text("Submit Feedback")
                            }
                            Spacer()
                        }
                    }
                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                    .listRowBackground(feedbackText.isEmpty ? Color.gray.opacity(0.3) : accentColor) // Change background based on state
                    .foregroundColor(.white) // Text color for button
                    .fontWeight(.medium)
                    
                }
            }
            .navigationTitle("Submit Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.tint(accentColor)
                }
            }
            .alert("Feedback Sent!", isPresented: $showConfirmation) { // More positive title
                Button("OK") { dismiss() }
            } message: {
                Text("Thank you for helping us improve LobeHub!")
            }
        }
    }
}

struct ChangelogView: View {
    // Static changelog data using Markdown
    let changelog = """
     ### Version 1.2.0 (Current)
     *   **Feature:** Fully functional settings sub-screens.
     *   **Feature:** Implemented user profile viewing and editing.
     *   **Feature:** Added mock cache clearing and feedback submission flows.
     *   **Enhancement:** Used `@AppStorage` for persistence of key settings.
     *   **Enhancement:** Refined UI with `Form`, `.insetGrouped` style, dynamic colors, and standard iOS patterns.
     *   **Enhancement:** Added interactive elements (Sliders, Pickers, Toggles) with state management.
     *   **Fix:** Improved dark mode consistency across views.
     
     ### Version 1.1.0
     *   Added basic structure for all settings items.
     *   Implemented navigation to placeholder detail views and sheets.
     *   Initial dark mode toggle functionality.
     
     ### Version 1.0.0
     *   Initial Release: Basic settings layout within a TabView.
     """
    
    var body: some View {
        NavigationView { // Add NavigationView for title and dismiss button
            ScrollView {
                Text(.init(changelog)) // Use Markdown initializer
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure text aligns left
            }
            .navigationTitle("Changelog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // Use trailing for dismiss
                    Button("Done") {
                        // How to dismiss depends on how this view is presented.
                        // If presented as a sheet, use @Environment(\.dismiss)
                        print("Done button tapped - Dismiss logic needed based on presentation")
                    }.tint(.orange) // Use accent color
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with default profile
        ContentView()
            .previewDisplayName("Default Profile (Light)")
        
        ContentView(userProfile: UserProfile(name: "Alice Wonderland", email: "alice@example.com", membership: "Pro User"))
            .preferredColorScheme(.dark) // Preview dark mode
            .previewDisplayName("Pro User Profile (Dark)")
    }
}
