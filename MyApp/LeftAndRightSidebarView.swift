//
//  LeftAndRightSidebarView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI

// MARK: - Data Models (Unchanged)

struct LeftAndRightSidebar_MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let destination: AnyView? // Use AnyView for simplicity here

    init(name: String, iconName: String, destination: AnyView? = nil) {
        self.name = name
        self.iconName = iconName
         // Use specific views or a coordinator in a real app
        if let dest = destination {
            self.destination = dest
        } else {
             // Default placeholder if no specific destination is provided
             self.destination = AnyView(LeftAndRightSidebar_PlaceholderDetailView(title: name))
        }
    }
}

struct LeftAndRightSidebar_MenuSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [LeftAndRightSidebar_MenuItem]
}

// MARK: - View Definitions

// New Settings View
struct LeftAndRightSidebar_SettingsView: View {
    // State for the toggle (visual representation only for this example)
     // In a real app, this would likely bind to @AppStorage or an EnvironmentObject
    @State private var isDarkModeOn: Bool = true // Default to match screenshot
    @State private var selectedFontSize: String = "Normal" // Example state
    @Environment(\.presentationMode) var presentationMode // To dismiss the sheet

    var body: some View {
        NavigationView { // Embed in NavigationView for title bar
            Form {
                Section {
                    Toggle(isOn: $isDarkModeOn) {
                        HStack(spacing: 15) {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.gray) // Match icon color
                                .frame(width: 20, alignment: .center)
                            Text("Dark Mode")
                        }
                    }

                    // Font Size Row (Simulating Navigation)
                    HStack {
                         HStack(spacing: 15) {
                            Image(systemName: "textformat.size") // 'Aa' symbol
                                .foregroundColor(.gray)
                                .frame(width: 20, alignment: .center)
                            Text("Font Size")
                        }
                        Spacer()
                        Text(selectedFontSize)
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right") // Indicate navigation
                             .foregroundColor(.gray.opacity(0.5))
                             .font(.footnote.weight(.semibold))
                    }
                     .contentShape(Rectangle()) // Make whole row tappable
                     .onTapGesture {
                         // Action to navigate to font size selection or show picker
                         print("Font Size tapped")
                     }


                    // Notifications Row (Simulating Navigation)
                    HStack(spacing: 15) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20, alignment: .center)
                        Text("Notifications")
                        Spacer()
                        Image(systemName: "chevron.right") // Indicate navigation
                             .foregroundColor(.gray.opacity(0.5))
                             .font(.footnote.weight(.semibold))
                    }
                     .contentShape(Rectangle()) // Make whole row tappable
                     .onTapGesture {
                         // Action to navigate to notification settings
                         print("Notifications tapped")
                     }
                }

                 Section {
                     // Search Row (Simulating Navigation)
                     HStack(spacing: 15) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(width: 20, alignment: .center)
                        Text("Search")
                        Spacer()
                         // No chevron needed if it presents a search bar directly
                    }
                     .contentShape(Rectangle())
                     .onTapGesture {
                         print("Search tapped")
                     }
                 }


                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.30.1 (1.0.30)") // Match screenshot
                            .foregroundColor(.gray)
                    }

                    Button("Recommend this app to a friend") {
                        // Action for recommending
                        print("Recommend tapped")
                    }
                    .foregroundColor(.accentColor) // Standard blue link color
                 }

                // Bottom Links Section
                 Section {
                     HStack {
                        Spacer()
                        Button("Privacy Policy") {
                            print("Privacy Policy tapped")
                        }
                        Spacer()
                         Divider().frame(height: 15) // Vertical divider suggestion
                        Spacer()
                        Button("Terms of Use") {
                            print("Terms of Use tapped")
                        }
                        Spacer()
                    }
                    .buttonStyle(PlainButtonStyle()) // Use plain style to avoid default button backgrounds
                    .foregroundColor(.accentColor)
                     .padding(.vertical, 5) // Add some padding
                 }
                 .listRowInsets(EdgeInsets()) // Remove padding around this section
                 .listRowBackground(Color.clear) // Make background transparent


            }
            .navigationTitle("SETTINGS")
            .navigationBarTitleDisplayMode(.inline) // Center title like screenshot
            .navigationBarItems(trailing: Button("Done") { // Add Done button to dismiss
                 presentationMode.wrappedValue.dismiss()
            })
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea()) // Match grouped background
             .foregroundColor(.primary) // Ensure text is visible
        }
        .preferredColorScheme(.dark) // Ensure the view itself defaults to dark
         .accentColor(Color(UIColor.systemBlue)) // Match accent color
    }
}


// Placeholder for the main content area navigated to (Modified to present Settings)
struct LeftAndRightSidebar_PlaceholderDetailView: View {
    let title: String
    @State private var showingSettings = false // State to control modal presentation

    var body: some View {
        // Basic representation of the right side content
        ZStack(alignment: .bottom) { // Align ZStack content to bottom for easier layout
             Color(UIColor.secondarySystemBackground).ignoresSafeArea() // Darker gray background


            VStack {
                // Top content simulation
                Text(title)
                    .font(.largeTitle)
                    .padding()

                Text("Financial Data Placeholder")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.bottom)

                // --- Mimic data layout ---
                VStack(alignment: .leading, spacing: 8) {
                    DataRow(label: "Principal:", value: "$255.78")
                    DataRow(label: "Interest:", value: "$1,700.00")
                    DataRow(label: "APR:", value: "6.930%") // Example
                    Divider()
                    DataRow(label: "Principal & Interest:", value: "$1,955.78", isBold: true)
                    Divider()
                    DataRow(label: "Taxes:", value: "$333.33")
                    DataRow(label: "Insurance:", value: "$333.33")
                    DataRow(label: "HOA Dues:", value: "$0.00")
                     Divider()
                    DataRow(label: "Total Payment:", value: "$2,622.44", isBold: true)
                }
                .padding(.horizontal)


                Spacer() // Pushes content up, leaving space for chart/buttons if added


                 // Simple Pie Chart Placeholder
                 Circle()
                     .trim(from: 0, to: 0.75) // Example trim
                     .stroke(Color.blue.opacity(0.7), lineWidth: 50)
                     .frame(width: 150, height: 150)
                     .rotationEffect(.degrees(-90))
                     .overlay(
                         Circle() // Add another layer for second color
                             .trim(from: 0.75, to: 1.0)
                             .stroke(Color.orange.opacity(0.7), lineWidth: 50)
                             .rotationEffect(.degrees(-90))
                     )
                     .padding(.bottom, 50) // Space above bottom controls


                Spacer() // Push chart up slightly


            } // End Main VStack


             // --- Floating Buttons Overlay ---
             VStack { // Use a VStack to place buttons relative to bottom
                 Spacer() // Push buttons down

                 HStack {
                     Spacer()
                     Button { } label: {
                         Image(systemName: "square.and.arrow.up.circle.fill")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 50, height: 50)
                             .foregroundColor(Color(UIColor.systemGray2)) // Match color
                             .background(Color(UIColor.systemGray4)) // Match background
                             .clipShape(Circle())
                     }
                     .padding(.trailing, 30)
                     .padding(.bottom, 80) // Position above tab bar
                 }


                 // --- Tab Bar Placeholder ---
                  HStack {
                      TabBarItem(icon: "house.fill", text: "Home", isSelected: false)
                      TabBarItem(icon: "building.columns.fill", text: "Lenders", badgeCount: 6, isSelected: true) // Add badge
                      TabBarItem(icon: "ellipsis", text: "More", isSelected: false) // Common 'More' icon
                 }
                .padding(.vertical, 5)
                .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) // Adjust for safe area
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.tertiarySystemBackground)) // Darker tab bar background
                .overlay(Divider(), alignment: .top) // Add top border


             } // End Floating Buttons/Tab Bar Overlay


        } // End ZStack
        .navigationTitle(title)
         .navigationBarTitleDisplayMode(.inline) // Keep consistent? Or .large for main title?
        .navigationBarItems(
             leading: Button {} label: { Image(systemName: "line.3.horizontal").foregroundColor(.primary) }, // Mimic hamburger
            trailing: HStack {
                 // Button { } label: { Image(systemName: "pencil.circle.fill").foregroundColor(.accentColor) } // Edit button wasn't in settings screenshot context
                 Button {
                     showingSettings = true // Present the Settings sheet
                 } label: { Image(systemName: "gearshape.fill").foregroundColor(.accentColor) }
            }
        )
        .foregroundColor(.primary) // Ensure text is visible in dark mode
         .sheet(isPresented: $showingSettings) {
             LeftAndRightSidebar_SettingsView() // Present the Settings view modally
                 .preferredColorScheme(.dark) // Ensure modal sheet is also dark
         }
    }
}

// Helper View for Data Rows in PlaceholderDetailView
struct DataRow: View {
    let label: String
    let value: String
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(isBold ? .medium : .regular)
                .foregroundColor(isBold ? .primary : .gray)
            Spacer()
            Text(value)
                 .fontWeight(isBold ? .medium : .regular)
                 .foregroundColor(.primary)
        }
    }
}


// Helper View for Tab Bar Items in PlaceholderDetailView
struct TabBarItem: View {
    let icon: String
    let text: String
    var badgeCount: Int? = nil
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22)) // Adjust size as needed
                .overlay(
                    // Add badge if count is provided
                    GeometryReader { geo in
                         if let count = badgeCount {
                             LeftAndRightSidebar_Badge(count: count)
                                 .offset(x: geo.size.width * 0.4, y: -geo.size.height * 0.1) // Adjust badge position
                        }
                     }
                 )
            Text(text)
                .font(.caption)
        }
        .foregroundColor(isSelected ? .accentColor : .gray)
        .frame(maxWidth: .infinity) // Ensure items spread out
    }
}


// Badge view for the tab item (Unchanged but used by TabBarItem)
struct LeftAndRightSidebar_Badge: View {
    let count: Int

    var body: some View {
        Text(String(count))
            .font(.caption2.bold())
            .foregroundColor(.white)
            .padding(5)
            .background(Color.red)
            .clipShape(Circle())
             .minimumScaleFactor(0.5) // Allow text to shrink if needed
             .lineLimit(1)

    }
}


// Main ContentView showing the sidebar list (Unchanged - except MenuItem destination)
struct LeftAndRightSidebarView: View {
    let menuSections: [LeftAndRightSidebar_MenuSection] = [
        LeftAndRightSidebar_MenuSection(title: "MORTGAGE RATES", items: [
            LeftAndRightSidebar_MenuItem(name: "Current Mortgage Rates", iconName: "percent"),
            LeftAndRightSidebar_MenuItem(name: "Mortgage Calculators", iconName: "calculator"),
            LeftAndRightSidebar_MenuItem(name: "Other Rate Averages", iconName: "chart.line.uptrend.xyaxis"),
            LeftAndRightSidebar_MenuItem(name: "Learn", iconName: "doc.text")
        ]),
        LeftAndRightSidebar_MenuSection(title: "NEWS", items: [
            LeftAndRightSidebar_MenuItem(name: "All News", iconName: "newspaper"),
            LeftAndRightSidebar_MenuItem(name: "Mortgage Rate Watch", iconName: "gauge.medium"),
            LeftAndRightSidebar_MenuItem(name: "Rob Chrisman", iconName: "house"),
            LeftAndRightSidebar_MenuItem(name: "MBS Commentary", iconName: "list.bullet")
        ]),
        LeftAndRightSidebar_MenuSection(title: "OTHER DATA", items: [
            LeftAndRightSidebar_MenuItem(name: "MBS Dashboard", iconName: "desktopcomputer")
        ])
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(menuSections) { section in
                    Section(header: Text(section.title)
                                    .font(.system(size: 12, weight: .semibold)) // Slightly smaller/bolder header
                                    .foregroundColor(.gray)
                                    .padding(.leading, -5) // Align header closer to items
                                    .padding(.top)
                    ) {
                        ForEach(section.items) { item in
                            NavigationLink(destination: item.destination) {
                                HStack(spacing: 15) {
                                    Image(systemName: item.iconName)
                                        .foregroundColor(.accentColor)
                                        .frame(width: 20, alignment: .center)
                                    Text(item.name)
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 6) // Slightly more padding
                            }
                        }
                    }
                }

                 Section { // Contact Us Section
                    Button(action: {
                         print("Contact Us tapped")
                     }) {
                         HStack {
                            Spacer()
                            Text("Contact Us")
                                .foregroundColor(.accentColor)
                            Spacer()
                         }
                     }
                     .padding(.vertical, 8)
                 }
                 .listRowInsets(EdgeInsets()) // Remove insets for full-width feel

            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Menu")
            .background(Color(UIColor.systemBackground).ignoresSafeArea())

            // Initial Detail View
            LeftAndRightSidebar_PlaceholderDetailView(title: "Dashboard") // Give a more context-specific title
        }
        .preferredColorScheme(.dark)
        .accentColor(Color(UIColor.systemBlue))
    }
}

#Preview("Left and Right Sidebar View - WIP") {
    LeftAndRightSidebarView()
}
