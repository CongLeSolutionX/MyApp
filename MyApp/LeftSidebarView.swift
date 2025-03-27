//
//  LeftSidebarView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI

// MARK: - Data Models

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    // We add a destination view type for navigation example
    let destination: AnyView? // Use AnyView for simplicity here, could be enum or specific types

    init(name: String, iconName: String, destination: AnyView? = AnyView(PlaceholderDetailView(title: "Detail"))) {
        self.name = name
        self.iconName = iconName
        // Attach the item name to the placeholder for context
        self.destination = AnyView(PlaceholderDetailView(title: name))
    }
}

struct MenuSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [MenuItem]
}

// MARK: - View Definitions

// Placeholder for the main content area navigated to
struct PlaceholderDetailView: View {
    let title: String

    var body: some View {
        // Basic representation of the right side content
        ZStack {
            Color(UIColor.systemGray5).ignoresSafeArea() // Slightly lighter gray for contrast demo
            VStack {
                Text(title)
                    .font(.largeTitle)
                    .padding()
                Spacer()
                // Add placeholder representations of right-side elements if needed
                 Text("Financial Data Placeholder")
                     .font(.title2)
                     .foregroundColor(.gray)
                 // Partial Pie Chart Placeholder (Simple Circle)
                 Circle()
                     .trim(from: 0, to: 0.75)
                     .stroke(Color.blue, lineWidth: 40)
                     .frame(width: 150, height: 150)
                     .rotationEffect(.degrees(-90))
                     .padding()
                
                Text("$1,955.78")
                    .font(.title)
                    .padding(.bottom)

                Spacer()

                 // Placeholder buttons similar to screenshot
                 HStack {
                     Spacer()
                     Button { } label: {
                         Image(systemName: "square.and.arrow.up.circle.fill")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 50, height: 50)
                             .foregroundColor(.gray)
                     }
                     .padding(.trailing, 30)
                     .padding(.bottom, 30)
                 }

                // Tab Bar Placeholder
                HStack {
                     Spacer()
                     VStack {
                         Image(systemName: "house.fill") // Placeholder icon
                         Text("Home")
                     }
                     Spacer()
                    VStack {
                         Image(systemName: "building.columns.fill")
                              .overlay(Badge(count: 6)) // Example badge
                         Text("Lenders")
                     }
                     .foregroundColor(.blue) // Simulate selection
                     Spacer()
                     VStack {
                         Image(systemName: "gearshape.fill") // Placeholder icon
                         Text("Settings")
                     }
                     Spacer()
                 }
                 .padding(.top)
                 .frame(maxWidth: .infinity)
                 .background(Color(UIColor.systemGray6))


            }
        }
        .navigationTitle(title) // Show title in nav bar if needed
        .navigationBarItems(trailing: HStack { // Mimic top-right icons
             Button { } label: { Image(systemName: "pencil.circle.fill").foregroundColor(.accentColor) }
             Button { } label: { Image(systemName: "gearshape.fill").foregroundColor(.accentColor) }
        })
        .foregroundColor(.primary) // Ensure text is visible in dark mode
    }
}

// Badge view for the tab item
struct Badge: View {
    let count: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear // Invisible placeholder
            Text(String(count))
                .font(.caption2.bold())
                .foregroundColor(.white)
                .padding(5)
                .background(Color.red)
                .clipShape(Circle())
                // Offset the badge slightly
                .offset(x: 10, y: -10)
        }
    }
}


// Main ContentView showing the sidebar list
struct LeftSidebarView: View {
    // Define the menu structure data
    let menuSections: [MenuSection] = [
        MenuSection(title: "MORTGAGE RATES", items: [
            MenuItem(name: "Current Mortgage Rates", iconName: "percent"),
            MenuItem(name: "Mortgage Calculators", iconName: "calculator"),
            MenuItem(name: "Other Rate Averages", iconName: "chart.line.uptrend.xyaxis"),
            MenuItem(name: "Learn", iconName: "doc.text")
        ]),
        MenuSection(title: "NEWS", items: [
            MenuItem(name: "All News", iconName: "newspaper"),
            MenuItem(name: "Mortgage Rate Watch", iconName: "gauge.medium"), // Adjusted icon
            MenuItem(name: "Rob Chrisman", iconName: "house"), // Adjusted icon
            MenuItem(name: "MBS Commentary", iconName: "list.bullet")
        ]),
        MenuSection(title: "OTHER DATA", items: [
            MenuItem(name: "MBS Dashboard", iconName: "desktopcomputer")
        ])
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(menuSections) { section in
                    Section(header: Text(section.title)
                                    .font(.caption) // Smaller font for header
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray) // Gray color for header
                                    .padding(.top) // Add some spacing above section headers
                    ) {
                        ForEach(section.items) { item in
                            // Use NavigationLink for rows that should navigate
                            NavigationLink(destination: item.destination) {
                                HStack(spacing: 15) { // Add spacing between icon and text
                                    Image(systemName: item.iconName)
                                        .foregroundColor(.accentColor) // Use accent color for icons
                                        .frame(width: 20, alignment: .center) // Align icons
                                    Text(item.name)
                                        .foregroundColor(.primary) // Primary text color (adapts to light/dark)
                                }
                                .padding(.vertical, 4) // Add small vertical padding to rows
                            }
                        }
                    }
                }

                // Spacer to push Contact Us down (might not be needed depending on content length)
                 // Spacer() // List handles scrolling, Spacer might not work as expected here.

                // Contact Us Button at the bottom
                 Section { // Put it in its own section for list styling
                     Button(action: {
                         print("Contact Us tapped")
                     }) {
                         HStack {
                            Spacer()
                            Text("Contact Us")
                                .foregroundColor(.accentColor)
                                .padding(.vertical, 8)
                            Spacer()
                         }
                     }
                     .listRowInsets(EdgeInsets()) // Remove default insets if needed
                 }


            }
            .listStyle(SidebarListStyle()) // Use SidebarListStyle for iPadOS/macOS look
            .navigationTitle("Menu") // Title for the sidebar navigation view
            .background(Color(UIColor.systemBackground).ignoresSafeArea()) // Adapts background
            
            // Initial Detail View for iPad split view or main view for iPhone
            PlaceholderDetailView(title: "Welcome")
        }
        .preferredColorScheme(.dark) // Force dark mode to match screenshot
        .accentColor(Color(UIColor.systemBlue)) // Set a global accent color (icons, Contact Us)

    }
}

#Preview("Left Sidebar View") {
    LeftSidebarView()
    
}
