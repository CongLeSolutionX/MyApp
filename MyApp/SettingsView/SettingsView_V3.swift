////
////  SettingsView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//
//// MARK: - Mock Data Models
//struct UserProfile {
//    var name: String = "Community User"
//    var email: String = "user@example.com"
//    var membership: String = "Community"
//}
//
//struct LanguageModel: Identifiable, Hashable {
//    let id: String
//    let name: String
//}
//
//// MARK: - Enhanced Data Model for Settings Items (Unchanged)
//enum NavigationType {
//    case detailView(AnyView) // Navigates to a specific view using NavigationLink
//    case sheet(AnyView)      // Presents a view as a sheet
//    case url(URL)           // Opens an external URL
//    case action(() -> Void)  // Performs a custom action (e.g., showing an alert)
//    case none                // No specific action (like the header or footer)
//}
//
//struct SettingItem: Identifiable {
//    let id = UUID()
//    let iconName: String
//    let title: String
//    let navigationType: NavigationType
//}
//
//// MARK: - Main App Structure (Optional but Recommended)
///*
// @main
// struct SettingsDemoApp: App {
//     @AppStorage("isDarkMode") var isDarkMode: Bool = true
//     @AppStorage("appIconBadgeEnabled") var appIconBadgeEnabled: Bool = true // Example persistent setting
//
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//                  .preferredColorScheme(isDarkMode ? .dark : .light)
//                  // Apply other global settings if needed
//         }
//     }
// }
// */
//
//// MARK: - Main Content View (Holds the TabView)
//struct ContentView: View {
//    @State private var selectedTab = 2 // Default to "Me" tab
//    @AppStorage("isDarkMode") var isDarkMode: Bool = true
//    @State private var mockUserProfile = UserProfile() // Mock user profile data
//
//    // Dynamic Colors (respecting isDarkMode)
//    let activeTabColor = Color.yellow
//    let inactiveTabColor = Color.gray
//    var backgroundColor: Color { isDarkMode ? .black : .white }
//    var listRowBackgroundColor: Color { isDarkMode ? Color(UIColor.secondarySystemGroupedBackground) : .white } // Separate bg for rows/sections if desired
//    var textColor: Color { isDarkMode ? .white : .black }
//    var secondaryTextColor: Color { isDarkMode ? .gray.opacity(0.8) : .gray }
//    let iconColor = Color.yellow
//
//    init() {
//        configureTabBarAppearance()
//    }
//
//    // Function to configure Tab Bar (separated for clarity)
//    private func configureTabBarAppearance() {
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        // Use system materials for better adaptation, or specific colors
//        // appearance.backgroundColor = isDarkMode ? UIColor.black.withAlphaComponent(0.8) : UIColor.systemGray6.withAlphaComponent(0.8)
//        // appearance.backgroundEffect = UIBlurEffect(style: isDarkMode ? .dark : .light) // Use blur effect
//
//        // For solid color matching background:
//         appearance.backgroundColor = isDarkMode ? UIColor.black : UIColor.systemGray6
//
//        // Set item colors
//        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(activeTabColor)
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(activeTabColor)]
//        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(inactiveTabColor)
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(inactiveTabColor)]
//
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance
//        UITabBar.appearance().tintColor = UIColor(activeTabColor) // Fallback tint
//    }
//
//    var body: some View {
//        // Update TabBar appearance when isDarkMode changes
//        let _ = configureTabBarAppearance()
//
//        return TabView(selection: $selectedTab) {
//            // --- Placeholder Views ---
//            PlaceholderTabView(title: "Chat View", systemImage: "message.fill", tag: 0, backgroundColor: backgroundColor, textColor: textColor)
//            PlaceholderTabView(title: "Discover View", systemImage: "safari.fill", tag: 1, backgroundColor: backgroundColor, textColor: textColor)
//
//            // --- Settings Screen ---
//            SettingsScreen(
//                isDarkMode: $isDarkMode,
//                userProfile: $mockUserProfile, // Pass binding for profile
//                backgroundColor: backgroundColor,
//                listRowBackgroundColor: listRowBackgroundColor, // Pass list row color
//                textColor: textColor,
//                secondaryTextColor: secondaryTextColor,
//                iconColor: iconColor
//            )
//                .tag(2)
//                .tabItem {
//                    Label("Me", systemImage: "person.fill")
//                }
//        }
//        .preferredColorScheme(isDarkMode ? .dark : .light)
//    }
//}
//
//// MARK: - Placeholder Tab View Helper
//struct PlaceholderTabView: View {
//    let title: String
//    let systemImage: String
//    let tag: Int
//    let backgroundColor: Color
//    let textColor: Color
//
//    var body: some View {
//        Text(title)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(backgroundColor)
//            .foregroundColor(textColor)
//            .tag(tag)
//            .tabItem {
//                Label(title, systemImage: systemImage)
//            }
//    }
//}
//
//// MARK: - Settings Screen View ("Me" Tab Content)
//struct SettingsScreen: View {
//    // Bindings and State
//    @Binding var isDarkMode: Bool
//    @Binding var userProfile: UserProfile // Receive profile binding
//    let backgroundColor: Color
//    let listRowBackgroundColor: Color
//    let textColor: Color
//    let secondaryTextColor: Color
//    let iconColor: Color
//
//    @State private var showingSheetForItem: SettingItem? = nil
//    @State private var showingAlertForItem: SettingItem? = nil
//    @State private var showClearCacheAlert: Bool = false
//    @State private var cacheSizeMB: Double = 150.0 // Mock cache size
//    @State private var showCacheClearedBanner = false
//
//    // Data Dependencies (Mocked or Persisted)
//    @AppStorage("selectedLanguageModelId") var selectedLanguageModelId: String = "gpt-4" // Persist selection
//    @AppStorage("ttsSpeed") var ttsSpeed: Double = 1.0 // Persist TTS speed
//    @AppStorage("defaultAssistantId") var defaultAssistantId: String = "general" // Persist default assistant
//    @AppStorage("commonSettingToggle") var commonSettingToggle: Bool = true // Persist a common setting
//
//    let availableModels = [
//        LanguageModel(id: "gpt-4", name: "GPT-4 (Default)"),
//        LanguageModel(id: "claude-3", name: "Claude 3 Opus"),
//        LanguageModel(id: "gemini-pro", name: "Gemini Pro")
//    ]
//
//    let availableAssistants = [ // Mock Assistants
//        ("general", "General Assistant"),
//        ("coding", "Coding Helper"),
//        ("creative", "Creative Writer")
//    ]
//
//    // --- Lazy generation of settings to avoid instantiating all views upfront ---
//    var generalSettings: [SettingItem] {
//        [
//            SettingItem(iconName: "person.crop.circle", title: "Account", navigationType: .detailView(AnyView(AccountSettingsView(userProfile: $userProfile)))),
//            SettingItem(iconName: "gearshape", title: "Common Settings", navigationType: .detailView(AnyView(CommonSettingsView(commonSettingToggle: $commonSettingToggle)))),
//            SettingItem(iconName: "sparkles", title: "System Assistant", navigationType: .detailView(AnyView(AssistantSettingsView()))),
//            SettingItem(iconName: "brain.head.profile", title: "Language Model", navigationType: .detailView(AnyView(LanguageModelView(availableModels: availableModels, selectedModelId: $selectedLanguageModelId)))),
//            SettingItem(iconName: "waveform", title: "Text-to-Speech", navigationType: .detailView(AnyView(TTSView(speed: $ttsSpeed)))),
//            SettingItem(iconName: "person.badge.key", title: "Default Assistant", navigationType: .detailView(AnyView(DefaultAssistantView(availableAssistants: availableAssistants, selectedAssistantId: $defaultAssistantId)))),
//            SettingItem(iconName: "info.circle", title: "About", navigationType: .detailView(AnyView(AboutView(appVersion: "1.1.0")))) // Pass mock version
//        ]
//    }
//
//    var appInfoSettings: [SettingItem] {
//        [
//            SettingItem(iconName: "cylinder.split.1x2", title: "Data Storage", navigationType: .detailView(AnyView(DataStorageView(cacheSizeMB: $cacheSizeMB, showClearCacheAlert: $showClearCacheAlert)))),
//            SettingItem(iconName: "book.closed", title: "User Manual", navigationType: .url(URL(string: "https://manual.example.com")!)), // Use a more specific URL
//            SettingItem(iconName: "pencil.and.outline", title: "Feedback", navigationType: .sheet(AnyView(FeedbackView()))),
//            SettingItem(iconName: "list.bullet.clipboard", title: "Changelog", navigationType: .sheet(AnyView(ChangelogView())))
//        ]
//    }
//
//    private func openURL(_ url: URL) {
//        UIApplication.shared.open(url) { success in
//            if !success {
//                print("Failed to open URL: \(url)")
//                // TODO: Show user an alert if opening failed
//            }
//        }
//    }
//
//    // --- Mock Clear Cache Action ---
//     private func clearCache() {
//         print("Clearing cache...")
//         // Simulate work
//         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//             cacheSizeMB = Double.random(in: 0.5...5.0) // Simulate cleared cache size
//             print("Cache Cleared!")
//             showCacheClearedBanner = true // Show banner feedback
//             // Hide banner after a delay
//             DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//                  showCacheClearedBanner = false
//             }
//         }
//     }
//
//    // --- Body ---
//    var body: some View {
//        ZStack(alignment: .bottom) { // Use ZStack for layering the banner
//             NavigationStack {
//                List {
//                    // --- User Info Header ---
//                     NavigationLink(destination: ProfileEditView(userProfile: $userProfile)) {
//                         UserInfoHeader(
//                             userProfile: userProfile, // Pass profile data
//                             textColor: textColor,
//                             secondaryTextColor: secondaryTextColor
//                         )
//                    }
//                    .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 15))
//                    .listRowBackground(listRowBackgroundColor) // Use specific row bg
//                    .listRowSeparator(.hidden)
//
//                    // --- Sections ---
//                    Section {
//                        ForEach(generalSettings) { row(for: $0) }
//                     } header: {
//                         Text("General")
//                            .foregroundColor(secondaryTextColor)
//                     }
//                     .listRowInsets(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
//                     .listRowBackground(listRowBackgroundColor)
//                     .listRowSeparatorTint(Color.gray.opacity(0.3))
//
//                    Section {
//                         ForEach(appInfoSettings) { row(for: $0) }
//                    } header: {
//                         Text("Application")
//                            .foregroundColor(secondaryTextColor)
//                    }
//                     .listRowInsets(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
//                     .listRowBackground(listRowBackgroundColor)
//                     .listRowSeparatorTint(Color.gray.opacity(0.3))
//
//                    // --- Footer ---
//                    footer
//                        .listRowBackground(backgroundColor) // Footer matches main background
//                        .listRowSeparator(.hidden)
//
//                }
//                .listStyle(.insetGrouped) // Use insetGrouped for modern look
//                .background(backgroundColor) // Main background
//                .scrollContentBackground(.hidden) // Make List background transparent
//                .navigationTitle("Me")
//                .navigationBarTitleDisplayMode(.large) // Use large title
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        darkModeToggleButton
//                    }
//                }
//                // --- Modifiers ---
//                .sheet(item: $showingSheetForItem, onDismiss: { /* Optional action on dismiss */ }) { item in
//                    sheetContent(for: item)
//                         .presentationDetents([.medium, .large]) // Allow resizing
//                          .preferredColorScheme(isDarkMode ? .dark : .light) // Apply scheme to sheet
//                }
//                .alert("Clear Cache", isPresented: $showClearCacheAlert) {
//                    clearCacheAlertButtons
//                } message: { clearCacheAlertMessage }
//               .alert(item: $showingAlertForItem) { item in // For generic actions
//                    genericActionAlert(for: item)
//               }
//             } // End NavigationStack
//             .background(backgroundColor.edgesIgnoringSafeArea(.all))
//             .ignoresSafeArea(.keyboard) // Prevent keyboard push
//
//            // --- Cache Cleared Banner ---
//             if showCacheClearedBanner {
//                 NotificationBanner(text: "Cache Cleared Successfully!", iconName: "checkmark.circle.fill")
//                     .transition(.move(edge: .bottom).combined(with: .opacity))
//                     .animation(.spring(), value: showCacheClearedBanner)
//                     .padding(.bottom, 50) // Adjust position above tab bar
//             }
//
//        } // End ZStack
//    }
//
//    // --- Row Builder ---
//    @ViewBuilder
//    private func row(for item: SettingItem) -> some View {
//        switch item.navigationType {
//        case .detailView(let destinationView):
//            NavigationLink(destination: destinationView
//                .preferredColorScheme(isDarkMode ? .dark : .light) // Pass scheme preference
//            ) {
//                SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
//            }
//        case .sheet:
//            Button { showingSheetForItem = item } label: {
//                HStack {
//                     SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
//                     Spacer()
//                     Image(systemName: "chevron.right")
//                         .font(.footnote.weight(.semibold))
//                         .foregroundColor(.gray.opacity(0.5))
//                 }
//                 .contentShape(Rectangle())
//            }.buttonStyle(.plain)
//        case .url(let url):
//            Button { openURL(url) } label: {
//                 HStack {
//                     SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
//                     Spacer()
//                     Image(systemName: "arrow.up.right.square")
//                         .font(.footnote.weight(.semibold))
//                         .foregroundColor(.gray.opacity(0.5))
//                 }
//                 .contentShape(Rectangle())
//            }.buttonStyle(.plain)
//        case .action(let action):
//             Button { showingAlertForItem = item } label: { // Trigger generic alert
//                 SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
//                     .contentShape(Rectangle())
//             }.buttonStyle(.plain)
//        case .none: EmptyView()
//        }
//    }
//
//    // --- Extracted Toolbar Button ---
//    private var darkModeToggleButton: some View {
//        Button {
//            withAnimation { isDarkMode.toggle() }
//        } label: {
//            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
//                .foregroundColor(secondaryTextColor)
//        }
//    }
//
//    // --- Sheet Content Builder ---
//     @ViewBuilder
//     private func sheetContent(for item: SettingItem) -> some View {
//         switch item.navigationType {
//         case .sheet(let view):
//             NavigationStack { // Wrap sheet content for title/buttons
//                 view
//                     .navigationBarTitleDisplayMode(.inline)
//                     .toolbar {
//                         ToolbarItem(placement: .navigationBarLeading) {
//                             Button("Done") { showingSheetForItem = nil }
//                               // .foregroundColor(activeTabColor) // Match tab color
//                         }
//                     }
//             }
//        default: EmptyView()
//        }
//     }
//
//    // --- Alert Components ---
//     private var clearCacheAlertButtons: some View {
//         Group { // Group needed for multiple buttons in @ViewBuilder context
//             Button("Clear", role: .destructive) { clearCache() }
//             Button("Cancel", role: .cancel) {}
//         }
//     }
//
//    private var clearCacheAlertMessage: Text {
//         Text("Are you sure you want to clear the application cache (\(String(format: "%.1f", cacheSizeMB)) MB)? This cannot be undone.")
//     }
//
//    private func genericActionAlert(for item: SettingItem) -> Alert {
//         switch item.navigationType {
//         case .action(let action):
//             return Alert(title: Text("Confirm Action"),
//                   message: Text("Perform '\(item.title)'? (Mock Action)"),
//                   primaryButton: .default(Text("OK"), action: action), // Execute the passed action
//                   secondaryButton: .cancel())
//         default:
//             return Alert(title: Text("Error")) // Fallback
//         }
//     }
//
//    // --- Footer View ---
//    private var footer: some View {
//        Text("Powered by CongLeSolutionX - v1.1.0") // Include version from About
//            .font(.caption)
//            .foregroundColor(secondaryTextColor)
//            .frame(maxWidth: .infinity, alignment: .center)
//            .padding(.vertical, 20)
//    }
//}
//
//// MARK: - Reusable User Info Header View (Updated)
//struct UserInfoHeader: View {
//    let userProfile: UserProfile // Use profile data
//    let textColor: Color
//    let secondaryTextColor: Color
//
//    var body: some View {
//        HStack(spacing: 15) {
//            Image(systemName: "person.crop.circle.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                 .foregroundColor(.orange) // Keep default or load user image
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(userProfile.name) // Display name
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .foregroundColor(textColor)
//                Text(userProfile.email) // Display email
//                    .font(.subheadline)
//                    .foregroundColor(secondaryTextColor)
//            }
//            Spacer()
//            Text(userProfile.membership) // Display membership
//                .font(.caption)
//                .fontWeight(.medium)
//                .foregroundColor(textColor)
//                .padding(.horizontal, 10)
//                .padding(.vertical, 5)
//                .background(Color.yellow.opacity(0.7)) // Use accent color ?
//                .cornerRadius(12)
//        }
//         // Removed padding here, rely on listRowInsets
//    }
//}
//
//// MARK: - Reusable Settings Row Content (Unchanged)
//struct SettingsRowContent: View {
//    let item: SettingItem
//    let iconColor: Color
//    let textColor: Color
//
//    var body: some View {
//        HStack(spacing: 15) {
//            Image(systemName: item.iconName)
//                .foregroundColor(iconColor)
//                .frame(width: 24, alignment: .center)
//            Text(item.title)
//                .foregroundColor(textColor)
//        }
//    }
//}
//
//// MARK: - Notification Banner View
//struct NotificationBanner: View {
//    let text: String
//    let iconName: String
//
//    var body: some View {
//        HStack {
//            Image(systemName: iconName)
//                .foregroundColor(.green)
//            Text(text)
//                 .foregroundColor(.primary) // Adapts to light/dark mode
//        }
//        .padding()
//        .background(.thinMaterial) // Use material background
//        .cornerRadius(10)
//        .shadow(radius: 5)
//    }
//}
//
//// MARK: - Interactive Destination/Sheet Views
//
//struct AccountSettingsView: View {
//    @Binding var userProfile: UserProfile
//    var body: some View {
//        Form { // Use Form for standard settings layout
//            Section("Profile Info") {
//                HStack { Text("Name"); Spacer(); Text(userProfile.name) }
//                HStack { Text("Email"); Spacer(); Text(userProfile.email) }
//                HStack { Text("Membership"); Spacer(); Text(userProfile.membership) }
//            }
//            Section {
//                NavigationLink("Edit Profile", destination: ProfileEditView(userProfile: $userProfile))
//                Button("Log Out", role: .destructive) {
//                    // Mock logout action
//                    print("Logout Tapped")
//                    // TODO: Show confirmation alert
//                }
//            }
//        }
//        .navigationTitle("Account")
//    }
//}
//
//struct CommonSettingsView: View {
//     @Binding var commonSettingToggle: Bool
//     @AppStorage("appIconBadgeEnabled") var appIconBadgeEnabled: Bool = true
//
//     var body: some View {
//         Form {
//             Toggle("Enable Feature X", isOn: $commonSettingToggle)
//             Toggle("Show App Icon Badge", isOn: $appIconBadgeEnabled)
//             // Add more common settings
//         }
//         .navigationTitle("Common Settings")
//     }
// }
//
//struct AssistantSettingsView: View {
//    // Mock settings
//    @State private var responseLength: Double = 0.5 // 0=Short, 1=Long
//    @State private var creativityLevel: Int = 1 // 0=Precise, 1=Balanced, 2=Creative
//
//    var body: some View {
//        Form {
//            Section("Response Style") {
//                VStack(alignment: .leading) {
//                     Text("Response Length: \(responseLength > 0.6 ? "Long" : (responseLength < 0.4 ? "Short" : "Medium"))")
//                     Slider(value: $responseLength, in: 0...1)
//                }
//                Picker("Creativity Level", selection: $creativityLevel) {
//                     Text("Precise").tag(0)
//                     Text("Balanced").tag(1)
//                     Text("Creative").tag(2)
//                 }
//                 .pickerStyle(.segmented) // Use segmented style
//            }
//        }
//        .navigationTitle("System Assistant")
//    }
//}
//
//struct LanguageModelView: View {
//    let availableModels: [LanguageModel]
//    @Binding var selectedModelId: String
//
//    var body: some View {
//        Form {
//            Picker("Select Model", selection: $selectedModelId) {
//                ForEach(availableModels) { model in
//                    Text(model.name).tag(model.id)
//                }
//            }
//            // Optionally use .pickerStyle(.inline) or .wheel for different looks
//             Text("Selected: \(availableModels.first(where: {$0.id == selectedModelId})?.name ?? "Unknown")")
//        }
//        .navigationTitle("Language Model")
//    }
//}
//
//struct TTSView: View {
//    @Binding var speed: Double // Use binding to @AppStorage
//
//    var body: some View {
//        Form {
//            Section("Playback Speed") {
//                 VStack(alignment: .leading) {
//                    Text("Speed: \(String(format: "%.1f", speed))x")
//                    Slider(value: $speed, in: 0.5...2.0, step: 0.1)
//                 }
//
//                 Button("Preview Voice") {
//                     print("Previewing TTS at speed \(speed)x")
//                     // TODO: Add actual TTS playback logic
//                 }
//            }
//        }
//        .navigationTitle("Text-to-Speech")
//    }
//}
//
//struct DefaultAssistantView: View {
//    let availableAssistants: [(id: String, name: String)]
//    @Binding var selectedAssistantId: String
//
//    var body: some View {
//        Form {
//            Picker("Default Assistant", selection: $selectedAssistantId) {
//                ForEach(availableAssistants, id: \.id) { assistant in
//                    Text(assistant.name).tag(assistant.id)
//                }
//            }
//            .pickerStyle(.inline) // Inline style for selection list
//             Text("Current Default: \(availableAssistants.first(where: {$0.id == selectedAssistantId})?.name ?? "None")")
//        }
//        .navigationTitle("Default Assistant")
//    }
//}
//
//struct AboutView: View {
//     let appVersion: String
//     var body: some View {
//         VStack(spacing: 20) {
//             Image(systemName: "info.circle.fill") // Or your app logo
//                 .resizable()
//                 .scaledToFit()
//                 .frame(width: 80)
//                 .foregroundColor(.yellow)
//             Text("Ask a Le")
//                 .font(.title)
//             Text("Version \(appVersion)")
//                 .font(.headline)
//                 .foregroundColor(.secondary)
//             Text("© \(Calendar.current.component(.year, from: Date())) CongLeSolutionX")
//                 .font(.caption)
//                .foregroundColor(.gray)
//         }
//         .navigationTitle("About")
//         .frame(maxWidth: .infinity, maxHeight: .infinity) // Center content
//     }
// }
//
//struct DataStorageView: View {
//    @Binding var cacheSizeMB: Double
//    @Binding var showClearCacheAlert: Bool
//
//    var body: some View {
//        Form {
//            Section("Usage") {
//                 HStack {
//                     Text("Estimated Cache Size")
//                     Spacer()
//                      Text("\(String(format: "%.1f", cacheSizeMB)) MB")
//                            .foregroundColor(.secondary)
//                 }
//            }
//            Section {
//                Button("Clear Cache", role: .destructive) {
//                    showClearCacheAlert = true // Trigger the alert in the parent view
//                }
//            }
//        }
//        .navigationTitle("Data Storage")
//    }
//}
//
//struct ProfileEditView: View {
//    @Binding var userProfile: UserProfile
//    @Environment(\.dismiss) var dismiss // To dismiss the view
//
//     // Temporary state for editing
//    @State private var editedName: String
//    @State private var editedEmail: String
//    @State private var showSaveAlert: Bool = false
//
//    // Initialize local state with profile data
//    init(userProfile: Binding<UserProfile>) {
//        self._userProfile = userProfile // Connect the binding
//        self._editedName = State(initialValue: userProfile.wrappedValue.name)
//        self._editedEmail = State(initialValue: userProfile.wrappedValue.email)
//    }
//
//    var body: some View {
//        Form {
//            Section("Edit Information") {
//                TextField("Name", text: $editedName)
//                TextField("Email", text: $editedEmail)
//                    .keyboardType(.emailAddress)
//                    .autocapitalization(.none)
//            }
//
//            Section {
//                Button("Save Changes") {
//                     // Basic validation (optional)
//                    if editedName.isEmpty || !editedEmail.contains("@") {
//                        showSaveAlert = true // Show validation alert
//                    } else {
//                        // Update the actual profile
//                        userProfile.name = editedName
//                        userProfile.email = editedEmail
//                        print("Profile Updated!")
//                        dismiss() // Go back
//                    }
//                }
//                 Button("Cancel", role: .cancel) {
//                     dismiss() // Go back without saving
//                 }
//            }
//        }
//        .navigationTitle("Edit Profile")
//        .navigationBarBackButtonHidden(true) // Hide default back button if using custom Cancel
//         .alert("Invalid Input", isPresented: $showSaveAlert) {
//             Button("OK", role: .cancel) {}
//         } message: {
//             Text("Please ensure name is not empty and email is valid.")
//        }
//    }
//}
//
//struct FeedbackView: View {
//    @State private var feedbackText: String = ""
//    @State private var feedbackType: FeedbackType = .bug
//    @State private var showConfirmation = false
//    @Environment(\.dismiss) var dismiss // To close the sheet
//
//    enum FeedbackType: String, CaseIterable, Identifiable {
//        case bug = "Bug Report"
//        case feature = "Feature Request"
//        case suggestion = "Suggestion"
//        case other = "Other"
//        var id: String { self.rawValue }
//    }
//
//    var body: some View {
//        NavigationView { // Needed for toolbar inside Form
//            Form {
//                Section("Feedback Details") {
//                     Picker("Feedback Type", selection: $feedbackType) {
//                        ForEach(FeedbackType.allCases) { type in
//                            Text(type.rawValue).tag(type)
//                        }
//                    }
//                     TextEditor(text: $feedbackText)
//                         .frame(height: 150) // Set a reasonable height
//                         .overlay(
//                            RoundedRectangle(cornerRadius: 5)
//                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
//                         )
//                         // Placeholder simulation if needed
//                         .background(feedbackText.isEmpty ? Text("Describe your feedback...") .foregroundColor(.gray.opacity(0.6)).padding(8) : nil, alignment: .topLeading)
//
//                }
//                 Section {
//                     Button("Submit Feedback") {
//                         // Mock submission
//                         print("--- Feedback Submitted ---")
//                         print("Type: \(feedbackType.rawValue)")
//                         print("Details: \(feedbackText)")
//                         print("-------------------------")
//                         showConfirmation = true
//                         // Optionally clear text after submission
//                         // feedbackText = ""
//                     }
//                     .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Disable if empty
//                 }
//            }
//            .navigationTitle("Feedback")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }
//                }
//            }
//             .alert("Feedback Sent", isPresented: $showConfirmation) {
//                 Button("OK") { dismiss() } // Dismiss sheet after OK
//             } message: {
//                 Text("Thank you for your feedback!")
//             }
//        }
//    }
//}
//
//struct ChangelogView: View {
//    // Static changelog data
//    let changelog = """
//    **Version 1.1.0**
//    - Added functional sub-views for settings.
//    - Implemented mock data persistence with @AppStorage.
//    - Added interactive elements like Pickers, Sliders, Toggles.
//    - Implemented mock cache clearing and feedback submission.
//    - Refined UI with insetGrouped List style and dynamic colors.
//
//    **Version 1.0.0**
//    - Initial Release
//    - Basic settings layout with TabView.
//    - Dark mode toggle.
//    """
//
//     var body: some View {
//        ScrollView {
//             Text(.init(changelog)) // Use Markdown initializer
//                 .padding()
//         }
//         .navigationTitle("Changelog")
//     }
// }
//
//// MARK: - Preview
//#Preview {
//    ContentView()
//         // .preferredColorScheme(.light) // Force preview scheme if needed
//}
