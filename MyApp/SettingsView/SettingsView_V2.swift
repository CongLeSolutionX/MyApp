////
////  SettingsView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//
//// MARK: - Enhanced Data Model for Settings Items
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
// // If you have an App struct, apply preferredColorScheme there
// @main
// struct SettingsDemoApp: App {
//     @AppStorage("isDarkMode") var isDarkMode: Bool = true // Default to dark
//
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//                  .preferredColorScheme(isDarkMode ? .dark : .light)
//         }
//     }
// }
// */
//
//// MARK: - Main Content View (Holds the TabView)
//struct ContentView: View {
//    @State private var selectedTab = 2
//    @AppStorage("isDarkMode") var isDarkMode: Bool = true // Default to dark
//
//    // Define colors dynamically based on isDarkMode or use system defaults
//    // Forcing exact colors as before:
//    let activeTabColor = Color.yellow
//    let inactiveTabColor = Color.gray
//    var backgroundColor: Color { isDarkMode ? .black : .white } // Dynamic background
//    var textColor: Color { isDarkMode ? .white : .black } // Dynamic text
//    var secondaryTextColor: Color { isDarkMode ? .gray.opacity(0.8) : .gray }
//    let iconColor = Color.yellow
//
//    init() {
//        // Customize TabView appearance
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = isDarkMode ? UIColor.black : UIColor.systemGray6 // Dynamic tab bar bg
//
//        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(activeTabColor)
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(activeTabColor)]
//        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(inactiveTabColor)
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(inactiveTabColor)]
//
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance // For large titles scrolling
//        UITabBar.appearance().tintColor = UIColor(activeTabColor) // Ensure selection color is applied
//    }
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            // Placeholder for Chat View
//            Text("Chat View")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(backgroundColor)
//                .foregroundColor(textColor)
//                .tag(0)
//                .tabItem {
//                    Label("Chat", systemImage: "message.fill")
//                }
//
//            // Placeholder for Discover View
//            Text("Discover View")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(backgroundColor)
//                .foregroundColor(textColor)
//                .tag(1)
//                .tabItem {
//                    Label("Discover", systemImage: "safari.fill")
//                }
//
//            // Settings Screen (Me Tab)
//            SettingsScreen(
//                isDarkMode: $isDarkMode, // Pass the binding
//                backgroundColor: backgroundColor,
//                textColor: textColor,
//                secondaryTextColor: secondaryTextColor,
//                iconColor: iconColor
//            )
//                .tag(2)
//                .tabItem {
//                    Label("Me", systemImage: "person.fill")
//                }
//        }
//        // Use accentColor for Picker, Slider, etc., if needed, but TabView uses appearance API
//        // .accentColor(activeTabColor)
//        // Apply the color scheme preference at ContentView level or App level
//         .preferredColorScheme(isDarkMode ? .dark : .light)
//    }
//}
//
//// MARK: - Settings Screen View ("Me" Tab Content)
//struct SettingsScreen: View {
//    @Binding var isDarkMode: Bool // Receive the binding
//    let backgroundColor: Color
//    let textColor: Color
//    let secondaryTextColor: Color
//    let iconColor: Color
//
//    // State for presenting sheets/alerts
//    @State private var showingSheetForItem: SettingItem? = nil
//    @State private var showingAlertForItem: SettingItem? = nil
//    @State private var showClearCacheAlert: Bool = false
//
//    // Data for the list sections (now with NavigationType)
//    // --- Lazy generation of settings to avoid instantiating all views upfront ---
//    var generalSettings: [SettingItem] {
//        [
//            SettingItem(iconName: "person.crop.circle", title: "Account", navigationType: .detailView(AnyView(AccountSettingsView()))),
//            SettingItem(iconName: "gearshape", title: "Common Settings", navigationType: .detailView(AnyView(CommonSettingsView()))),
//            SettingItem(iconName: "sparkles", title: "System Assistant", navigationType: .detailView(AnyView(AssistantSettingsView()))),
//            SettingItem(iconName: "brain.head.profile", title: "Language Model", navigationType: .detailView(AnyView(LanguageModelView()))),
//            SettingItem(iconName: "waveform", title: "Text-to-Speech", navigationType: .detailView(AnyView(TTSView()))),
//            SettingItem(iconName: "person.badge.key", title: "Default Assistant", navigationType: .detailView(AnyView(DefaultAssistantView()))),
//            SettingItem(iconName: "info.circle", title: "About", navigationType: .detailView(AnyView(AboutView())))
//        ]
//    }
//
//    var appInfoSettings: [SettingItem] {
//        [
//            SettingItem(iconName: "cylinder.split.1x2", title: "Data Storage", navigationType: .detailView(AnyView(DataStorageView(showClearCacheAlert: $showClearCacheAlert)))),
//            SettingItem(iconName: "book.closed", title: "User Manual", navigationType: .url(URL(string: "https://example.com/user-manual")!)), // Replace with actual URL
//            SettingItem(iconName: "pencil.and.outline", title: "Feedback", navigationType: .sheet(AnyView(FeedbackView()))),
//            SettingItem(iconName: "list.bullet.clipboard", title: "Changelog", navigationType: .sheet(AnyView(ChangelogView())))
//        ]
//    }
//
//    // Helper to open URLs
//    private func openURL(_ url: URL) {
//        UIApplication.shared.open(url) { success in
//            if !success {
//                print("Failed to open URL: \(url)")
//                // Optionally show an alert to the user
//            }
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            List {
//                // --- User Info Header ---
//                 NavigationLink(destination: ProfileEditView()) { // Make header navigable
//                    UserInfoHeader(
//                        textColor: textColor,
//                        secondaryTextColor: secondaryTextColor
//                    )
//                 }
//                 .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 15)) // Adjust leading for link arrow
//                 .listRowBackground(backgroundColor)
//                 .listRowSeparator(.hidden)
//
//                // --- General Settings Section ---
//                Section {
//                    ForEach(generalSettings) { item in
//                        row(for: item) // Use helper function to create row
//                    }
//                }
//                .listRowInsets(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
//                .listRowBackground(backgroundColor)
//                .listRowSeparatorTint(Color.gray.opacity(0.3))
//
//                // --- App Info Section ---
//                 Section {
//                    ForEach(appInfoSettings) { item in
//                         row(for: item) // Use helper function
//                     }
//                 }
//                 .listRowInsets(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
//                 .listRowBackground(backgroundColor)
//                 .listRowSeparatorTint(Color.gray.opacity(0.3))
//
//                // --- Footer ---
//                footer
//                    .listRowBackground(backgroundColor)
//                    .listRowSeparator(.hidden)
//
//            }
//            .listStyle(.plain)
//            .background(backgroundColor)
//            .scrollContentBackground(.hidden)
//            .navigationTitle("Me")
//            .navigationBarTitleDisplayMode(.inline) // Use inline title
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        isDarkMode.toggle() // Toggle the AppStorage value
//                        // Appearance update might take a moment
//                    } label: {
//                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
//                            .foregroundColor(secondaryTextColor)
//                    }
//                }
//            }
//            // --- Sheet Modifier ---
//            .sheet(item: $showingSheetForItem) { item in
//                 // Determine which sheet view to present based on the item's navigationType
//                 switch item.navigationType {
//                 case .sheet(let view):
//                     // Often sheets have their own nav stack or just content
//                     NavigationStack { // Wrap sheet content in NavStack for title/buttons
//                         view
//                             .navigationBarTitleDisplayMode(.inline)
//                             .toolbar {
//                                 ToolbarItem(placement: .navigationBarLeading) {
//                                     Button("Done") { showingSheetForItem = nil }
//                                 }
//                             }
//                     }
//                     .presentationDetents([.medium, .large]) // Allow resizing
//                     // Apply color scheme to the sheet explicitely if needed
//                     // .preferredColorScheme(isDarkMode ? .dark : .light)
//
//                 default: EmptyView() // Should not happen if logic is correct
//                }
//             }
//             // --- Alert Modifier (Example for Clear Cache) ---
//             .alert("Clear Cache", isPresented: $showClearCacheAlert) {
//                 Button("Clear", role: .destructive) {
//                     print("Cache Cleared! (Mock Action)")
//                     // Add actual cache clearing logic here
//                 }
//                 Button("Cancel", role: .cancel) {}
//             } message: {
//                 Text("Are you sure you want to clear the application cache? This cannot be undone.")
//             }
//             // --- Optional Alert for Generic Actions (Example) ---
//               .alert(item: $showingAlertForItem) { item in
//                   switch item.navigationType {
//                   case .action(let action):
//                       // You might customize the Alert based on the item title/action
//                       return Alert(title: Text("Confirm Action"),
//                              message: Text("Perform '\(item.title)'?"),
//                              primaryButton: .default(Text("OK"), action: action),
//                              secondaryButton: .cancel())
//                   default:
//                       return Alert(title: Text("Error")) // Should not happen
//                   }
//               }
//
//        }
//        .background(backgroundColor.edgesIgnoringSafeArea(.all)) // Ensure bg covers entire area
//        .ignoresSafeArea(.keyboard) // Prevent keyboard from pushing up tab bar
//    }
//
//    // --- Helper Function to Create Row Views ---
//    @ViewBuilder
//    private func row(for item: SettingItem) -> some View {
//        switch item.navigationType {
//        case .detailView(let destinationView):
//            NavigationLink(destination: destinationView) {
//                SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
//            }
//        case .sheet:
//            Button {
//                showingSheetForItem = item // Set the item to trigger the .sheet modifier
//            } label: {
//                // Add chevron explicitly for Button rows to match NavigationLink style
//                 HStack {
//                     SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
//                     Spacer()
//                     Image(systemName: "chevron.right")
//                         .font(.footnote.weight(.semibold))
//                         .foregroundColor(.gray.opacity(0.5))
//                 }
//                 .contentShape(Rectangle()) // Make entire row tappable
//            }
//            .buttonStyle(.plain) // Remove default button styling
//        case .url(let url):
//            Button {
//                openURL(url)
//            } label: {
//                 HStack {
//                     SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
//                     Spacer()
//                     Image(systemName: "arrow.up.right.square") // Icon indicating external link
//                         .font(.footnote.weight(.semibold))
//                         .foregroundColor(.gray.opacity(0.5))
//                 }
//                 .contentShape(Rectangle())
//            }
//            .buttonStyle(.plain)
//        case .action(let action):
//             Button {
//                 // Option 1: Show a confirmation alert
//                 showingAlertForItem = item
//                 // Option 2: Directly perform the action if no confirmation needed
//                 // action()
//             } label: {
//                 SettingsRowContent(item: item, iconColor: iconColor, textColor: textColor)
//                     .contentShape(Rectangle()) // Make tappable
//             }
//             .buttonStyle(.plain)
//        case .none:
//             EmptyView() // Should not be used for standard rows
//        }
//    }
//
//    // --- Footer View ---
//    private var footer: some View {
//         Text("Powered by LobeHub")
//             .font(.caption)
//             .foregroundColor(secondaryTextColor)
//             .frame(maxWidth: .infinity, alignment: .center)
//             .padding(.vertical, 20)
//    }
//}
//
//// MARK: - Reusable User Info Header View (Unchanged)
//struct UserInfoHeader: View {
//    let textColor: Color
//    let secondaryTextColor: Color
//    // ... (same implementation as before) ...
//    var body: some View {
//        HStack(spacing: 15) {
//            Image(systemName: "person.crop.circle.fill") // Replace with actual avatar
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                .foregroundColor(.orange)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text("Community User")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .foregroundColor(textColor)
//                Text("LobeChat")
//                    .font(.subheadline)
//                    .foregroundColor(secondaryTextColor)
//            }
//            Spacer()
//            Text("Community")
//                .font(.caption)
//                .fontWeight(.medium)
//                .foregroundColor(textColor)
//                .padding(.horizontal, 10)
//                .padding(.vertical, 5)
//                .background(Color.gray.opacity(0.5))
//                .cornerRadius(12)
//        }
//    }
//}
//
//// MARK: - Reusable Settings Row Content (Extracted from old SettingsRow)
//// This is just the content part (icon, text), used by both NavigationLink and Button
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
//// MARK: - Placeholder Destination Views
//struct AccountSettingsView: View { var body: some View { Text("Account Settings").navigationTitle("Account") } }
//struct CommonSettingsView: View { var body: some View { Text("Common Settings").navigationTitle("Common Settings") } }
//struct AssistantSettingsView: View { var body: some View { Text("Assistant Settings").navigationTitle("System Assistant") } }
//struct LanguageModelView: View { var body: some View { Text("Language Model Config").navigationTitle("Language Model") } }
//struct TTSView: View { var body: some View { Text("Text-to-Speech Options").navigationTitle("Text-to-Speech") } }
//struct DefaultAssistantView: View { var body: some View { Text("Select Default Assistant").navigationTitle("Default Assistant") } }
//struct AboutView: View { var body: some View { Text("App Version 1.0.0").navigationTitle("About") } }
//struct ProfileEditView: View { var body: some View { Text("Edit User Profile").navigationTitle("Profile") } }
//
//struct DataStorageView: View {
//     @Binding var showClearCacheAlert: Bool
//     var body: some View {
//         List {
//             Text("Storage Usage: 150 MB (Mock Data)")
//             Button("Clear Cache", role: .destructive) {
//                 showClearCacheAlert = true
//             }
//         }
//         .navigationTitle("Data Storage")
//     }
// }
//
//// --- Placeholder Sheet Views ---
//struct FeedbackView: View {
//     @State private var feedbackText: String = ""
//     var body: some View {
//         VStack {
//             Text("Please provide your feedback:")
//             TextEditor(text: $feedbackText)
//                 .border(Color.gray.opacity(0.5))
//                 .frame(height: 200)
//             Button("Submit Feedback") {
//                 print("Feedback Submitted: \(feedbackText)")
//                 // Add actual submission logic
//             }
//             Spacer()
//         }
//         .padding()
//         .navigationTitle("Feedback") // Title shown in sheet's NavStack
//     }
// }
//
//struct ChangelogView: View {
//     var body: some View {
//         ScrollView {
//             VStack(alignment: .leading) {
//                 Text("Version 1.0.0").font(.headline)
//                 Text("- Initial Release\n- Added cool features\n- Fixed minor bugs")
//                 Divider().padding(.vertical)
//                 Text("Version 0.9.0 (Beta)").font(.headline)
//                 Text("- Introduced dark mode\n- Performance improvements")
//             }
//             .padding()
//         }
//         .navigationTitle("Changelog")
//     }
// }
//
//// MARK: - Preview
//#Preview {
//    ContentView()
//       // .preferredColorScheme(.dark) // Preview respects AppStorage now, but can force here too
//}
