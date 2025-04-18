////
////  SettingsView.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model for Settings Items
//struct SettingItem: Identifiable {
//    let id = UUID()
//    let iconName: String // SF Symbol name
//    let title: String
//    // Add destination view type if needed for navigation
//    // let destination: AnyView? = nil // Example
//}
//
//// MARK: - Main Content View (Holds the TabView)
//struct ContentView: View {
//    @State private var selectedTab = 2 // Start with the "Me" tab selected
//
//    // Define colors based on the screenshot
//    let activeTabColor = Color.yellow // Approximation of the gold/yellow color
//    let inactiveTabColor = Color.gray
//    let backgroundColor = Color.black
//    let textColor = Color.white
//    let secondaryTextColor = Color.gray.opacity(0.8)
//    let iconColor = Color.yellow // Approximation
//
//    init() {
//        // Customize TabView appearance (apply globally)
//        UITabBar.appearance().backgroundColor = UIColor.black // Set tab bar background
//        UITabBar.appearance().unselectedItemTintColor = UIColor(inactiveTabColor) // Set inactive color
//        UITabBar.appearance().barTintColor = UIColor.black // May not be needed with background color
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
//                    Label("Discover", systemImage: "safari.fill") // Or compass equivalent
//                }
//
//            // Settings Screen (Me Tab)
//            SettingsScreen(
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
//        // Apply the active color to the selected tab item
//        .accentColor(activeTabColor)
//        // Ensure the overall app prefers dark mode if needed globally
//         .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - Settings Screen View ("Me" Tab Content)
//struct SettingsScreen: View {
//    // Pass colors down if not using environment values or theme system
//    let backgroundColor: Color
//    let textColor: Color
//    let secondaryTextColor: Color
//    let iconColor: Color
//
//    // Data for the list sections
//    let generalSettings: [SettingItem] = [
//        SettingItem(iconName: "person.crop.circle", title: "Account"),
//        SettingItem(iconName: "gearshape", title: "Common Settings"),
//        SettingItem(iconName: "sparkles", title: "System Assistant"), // Or wand.stars
//        SettingItem(iconName: "brain.head.profile", title: "Language Model"),
//        SettingItem(iconName: "waveform", title: "Text-to-Speech"), // Or mic
//        SettingItem(iconName: "person.badge.key", title: "Default Assistant"), // Example
//        SettingItem(iconName: "info.circle", title: "About")
//    ]
//
//    let appInfoSettings: [SettingItem] = [
//        SettingItem(iconName: "cylinder.split.1x2", title: "Data Storage"), // Or externaldrive
//        SettingItem(iconName: "book.closed", title: "User Manual"),
//        SettingItem(iconName: "pencil.and.outline", title: "Feedback"),
//        SettingItem(iconName: "list.bullet.clipboard", title: "Changelog") // Or clock.arrow.2.circlepath
//    ]
//
//    var body: some View {
//        NavigationStack { // Use NavigationStack for iOS 16+
//            List {
//                // --- User Info Header ---
//                UserInfoHeader(
//                    textColor: textColor,
//                    secondaryTextColor: secondaryTextColor
//                )
//                .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
//                .listRowBackground(backgroundColor)
//                .listRowSeparator(.hidden) // Remove separator below header
//
//                // --- General Settings Section ---
//                Section {
//                    ForEach(generalSettings) { item in
//                       NavigationLink(destination: Text("\(item.title) Detail View")) { // Placeholder for navigation
//                            SettingsRow(item: item, iconColor: iconColor, textColor: textColor)
//                        }
//                    }
//                }
//                .listRowInsets(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
//                .listRowBackground(backgroundColor)
//                .listRowSeparatorTint(Color.gray.opacity(0.3)) // Subtle separator
//
//                // --- App Info Section ---
//                 Section {
//                    ForEach(appInfoSettings) { item in
//                         NavigationLink(destination: Text("\(item.title) Detail View")) { // Placeholder
//                             SettingsRow(item: item, iconColor: iconColor, textColor: textColor)
//                         }
//                     }
//                 }
//                 .listRowInsets(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
//                 .listRowBackground(backgroundColor)
//                 .listRowSeparatorTint(Color.gray.opacity(0.3))
//
//                // --- Footer ---
//                Text("Powered by LobeHub")
//                    .font(.caption)
//                    .foregroundColor(secondaryTextColor)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.vertical, 20)
//                    .listRowBackground(backgroundColor)
//                    .listRowSeparator(.hidden)
//
//            }
//            .listStyle(.plain) // Use plain style to remove default section headers/footers
//            .background(backgroundColor)
//            .scrollContentBackground(.hidden) // Make list background transparent
//            .navigationTitle("Me") // Sets the title, but we'll hide it for this design
//            .navigationBarTitleDisplayMode(.inline) // Hide standard navigation bar title for custom header
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        // Action for dark mode toggle
//                        print("Dark mode toggle tapped")
//                    } label: {
//                        Image(systemName: "moon.fill")
//                            .foregroundColor(secondaryTextColor) // Or specific gray
//                    }
//                }
//            }
//        }
//        // Ensure the view within the stack takes the dark mode background
//        .background(backgroundColor)
//        .ignoresSafeArea(.all, edges: .bottom) // Extend background to bottom edge
//    }
//}
//
//// MARK: - Reusable User Info Header View
//struct UserInfoHeader: View {
//    let textColor: Color
//    let secondaryTextColor: Color
//
//    var body: some View {
//        HStack(spacing: 15) {
//            // Placeholder for Avatar
//            Image(systemName: "person.circle.fill") // Replace with actual avatar loading
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                .foregroundColor(Color.orange) // Placeholder color
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1)) // Optional border
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
//
//            Spacer() // Pushes badge to the right
//
//            Text("Community")
//                .font(.caption)
//                .fontWeight(.medium)
//                .foregroundColor(textColor)
//                .padding(.horizontal, 10)
//                .padding(.vertical, 5)
//                .background(Color.gray.opacity(0.5)) // Badge background
//                .cornerRadius(12)
//        }
//    }
//}
//
//// MARK: - Reusable Settings Row View
//struct SettingsRow: View {
//    let item: SettingItem
//    let iconColor: Color
//    let textColor: Color
//
//    var body: some View {
//        HStack(spacing: 15) {
//            Image(systemName: item.iconName)
//                .foregroundColor(iconColor)
//                .frame(width: 24, alignment: .center) // Consistent icon width
//            Text(item.title)
//                .foregroundColor(textColor)
//            Spacer()
//            // Chevron is implicitly added by NavigationLink
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    ContentView()
//        .preferredColorScheme(.dark) // Preview in dark mode
//}
