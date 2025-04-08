//
//  LevelsInfoView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI

// MARK: - Data Models (Updated & New)

struct LevelInfo: Identifiable, Hashable { // Make Hashable for sheet item
    let id = UUID()
    let title: String
    let subtitle: String?
    let company: String // Added company context
}

struct CompanyLogoInfo: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // SF Symbol name or asset name
}

struct LevelDetailView: View {
    let levelInfo: LevelInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("\(levelInfo.company) Level")
                .font(.title2).fontWeight(.bold)
            Divider()
            HStack {
                Text("Title:")
                    .fontWeight(.semibold)
                Text(levelInfo.title)
            }
            if let subtitle = levelInfo.subtitle {
                HStack {
                    Text("Subtitle/Code:")
                        .fontWeight(.semibold)
                    Text(subtitle)
                }
            }
            Text("Here you could add more details about this level, typical compensation ranges, required experience, responsibilities, etc.")
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
        // Add a dismiss button if needed, or rely on pull-down gesture
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .background(Color(.systemGroupedBackground)) // Use system background for sheet
    }
}

// Sample Data (Includes Company Association)
let roles = ["Software Engineer", "Product Manager", "Designer", "Data Scientist", "Engineering Manager"]

let companyLogos: [CompanyLogoInfo] = [
    CompanyLogoInfo(name: "Amazon", imageName: "a.circle.fill"),
    CompanyLogoInfo(name: "Google", imageName: "g.circle.fill"),
    CompanyLogoInfo(name: "Microsoft", imageName: "square.grid.3x3.fill"),
    CompanyLogoInfo(name: "Meta", imageName: "f.cursive.circle.fill"), // Assuming Facebook -> Meta
    CompanyLogoInfo(name: "Apple", imageName: "apple.logo"),
    CompanyLogoInfo(name: "Netflix", imageName: "n.circle.fill"),
    CompanyLogoInfo(name: "Disney", imageName: "d.circle.fill"), // Adding Disney
]

// --- Existing Level Data (Now with Company Info) ---
let generalLevels: [LevelInfo] = [
    LevelInfo(title: "Software Engineer I", subtitle: nil, company: "General"),
    LevelInfo(title: "Software Engineer II", subtitle: nil, company: "General"),
    LevelInfo(title: "Senior Software Engineer", subtitle: nil, company: "General"),
    LevelInfo(title: "Staff Software Engineer", subtitle: nil, company: "General"),
    LevelInfo(title: "Lead Software Engineer", subtitle: nil, company: "General"),
    LevelInfo(title: "Principal Software Engineer", subtitle: nil, company: "General"),
    LevelInfo(title: "Senior Principal Software Engineer", subtitle: nil, company: "General")
]

let microsoftLevels: [LevelInfo] = [
    LevelInfo(title: "SDE", subtitle: "59", company: "Microsoft"),
    LevelInfo(title: "SDE II", subtitle: "60", company: "Microsoft"),
    LevelInfo(title: "61", subtitle: nil, company: "Microsoft"),
    LevelInfo(title: "Senior SDE", subtitle: "62", company: "Microsoft"),
    LevelInfo(title: "63", subtitle: nil, company: "Microsoft"),
    LevelInfo(title: "Principal SDE", subtitle: "64", company: "Microsoft"),
    LevelInfo(title: "65", subtitle: nil, company: "Microsoft"),
    LevelInfo(title: "66", subtitle: nil, company: "Microsoft"),
    LevelInfo(title: "67", subtitle: nil, company: "Microsoft"),
    LevelInfo(title: "Partner", subtitle: "68", company: "Microsoft"),
    LevelInfo(title: "69", subtitle: nil, company: "Microsoft"),
    LevelInfo(title: "Distinguished Engineer", subtitle: "70", company: "Microsoft"),
    LevelInfo(title: "Technical Fellow", subtitle: "80", company: "Microsoft")
]

let googleLevels: [LevelInfo] = [
    LevelInfo(title: "L3", subtitle: "SWE II", company: "Google"),
    LevelInfo(title: "L4", subtitle: "SWE III", company: "Google"),
    LevelInfo(title: "L5", subtitle: "Senior SWE", company: "Google"),
    LevelInfo(title: "L6", subtitle: "Staff SWE", company: "Google"),
    LevelInfo(title: "L7", subtitle: "Senior Staff SWE", company: "Google"),
    LevelInfo(title: "L8", subtitle: "Principal Engineer", company: "Google"),
    LevelInfo(title: "L9", subtitle: "Distinguished Engineer", company: "Google"),
    LevelInfo(title: "L10", subtitle: "Google Fellow", company: "Google")
]
// --- End Sample Data ---

// MARK: - Reusable Views (Mostly Unchanged, LevelCell gets Button)

struct LevelCell: View {
    let levelInfo: LevelInfo
    let backgroundColor: Color
    let action: () -> Void // Action for tapping the cell
    let minHeight: CGFloat = 65

    var body: some View {
        Button(action: action) { // Make the cell tappable
            VStack(alignment: .center, spacing: 4) {
                Text(levelInfo.title)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)

                if let subtitle = levelInfo.subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .frame(minHeight: minHeight)
            .background(backgroundColor)
            .cornerRadius(8)
            .foregroundColor(.black) // Ensure text color is appropriate
        }
    }
}

struct CompanyLogoView: View {
    let companyInfo: CompanyLogoInfo // Use the struct
    let action: () -> Void // Action for tapping the logo
    let size: CGFloat = 50

    var body: some View {
        Button(action: action) { // Make the logo tappable
            // Using SF Symbols as placeholders - replace with actual logo images if available
            Image(systemName: companyInfo.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.6, height: size * 0.6)
                .foregroundColor(.white.opacity(0.8)) // Make symbol visible
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.3))
                .clipShape(Circle())
        }
    }
}

struct FilterPillView: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                Text(text)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundColor(.white)
            .background(Capsule().fill(Color.gray.opacity(0.4)))
            .overlay(Capsule().stroke(Color.gray, lineWidth: 0.5))
        }
    }
}

struct CustomTabIndicator: View {
    let tabCount: Int
    @Binding var selectedIndex: Int

    var body: some View {
        GeometryReader { geometry in
            let tabWidth = geometry.size.width / CGFloat(tabCount)
            let indicatorWidth: CGFloat = tabWidth * 0.5
            let xOffset = (CGFloat(selectedIndex) * tabWidth) + (tabWidth / 2) - (indicatorWidth / 2)

            Capsule()
                .fill(Color.white)
                .frame(width: indicatorWidth, height: 4)
                .offset(x: xOffset)
                .animation(.easeInOut(duration: 0.25), value: selectedIndex)
        }
        .frame(height: 4)
    }
}

// MARK: - Placeholder Tab Views

struct PlaceholderTabView: View {
    let title: String
    let systemImageName: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImageName)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(title)
                .font(.title2)
                .foregroundColor(.white)
            Text("Content for this section goes here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea()) // Ensure background covers safe area
    }
}

// MARK: - Main Content View (Updated with Functionality)

struct LevelsInfoView_V3: View {
    // State Variables
    @State private var selectedRole: String = roles.first ?? "Software Engineer"
    @State private var activeFilters: [String] = ["Disney", "Microsoft", "Google"]
    @State private var selectedTab: Int = 2 // Start on Levels tab
    @State private var showingLevelDetailSheet: Bool = false
    @State private var selectedLevelInfo: LevelInfo? = nil // Store selected level

    // Constants
    let backgroundDark = Color.black
    let elementBackgroundGray = Color.gray.opacity(0.25)
    let levelPurple = Color(red: 0.7, green: 0.7, blue: 0.9)
    let levelBlue = Color(red: 0.6, green: 0.85, blue: 0.95)
    let levelGreen = Color(red: 0.75, green: 0.9, blue: 0.75)
    let totalTabs = 5

     // --- Helper Function to Add Filter ---
     private func addFilter(_ companyName: String) {
         guard !activeFilters.contains(companyName) else { return } // Don't add duplicates
         activeFilters.append(companyName)
     }

     // --- Helper Function to Remove Filter ---
    private func removeFilter(_ filterName: String) {
        activeFilters.removeAll { $0 == filterName }
    }

    // --- Helper Function to Show Level Detail ---
    private func showLevelDetail(_ level: LevelInfo) {
        selectedLevelInfo = level
         // showingLevelDetailSheet will be toggled by .sheet(item: ...)
    }

    // MARK: - Levels View Content (Extracted & Functional)
    var levelsViewContent: some View {
        ScrollView {
            VStack(spacing: 15) {
                // 1. Role Selector (Functional Menu)
                Menu {
                    ForEach(roles, id: \.self) { role in
                        Button(role) {
                            selectedRole = role
                            // Future: Add logic here to filter data based on role if needed
                        }
                    }
                } label: {
                     HStack {
                        Image(systemName: "briefcase.fill")
                        Text(selectedRole) // Display selected role
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(elementBackgroundGray)
                    .clipShape(Capsule())
                    .foregroundColor(.white) // Ensure menu label text is visible
                }
                .padding(.horizontal)
                .padding(.top)

                 // 4. Company Logos Row (Functional Buttons)
                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack(spacing: 15) {
                         ForEach(companyLogos) { company in
                             CompanyLogoView(companyInfo: company) {
                                 addFilter(company.name)
                             }
                         }
                     }
                     .padding(.horizontal)
                 }

                // 5. Selected Filters Row (Functional Pills)
                if !activeFilters.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(activeFilters, id: \.self) { filter in
                                FilterPillView(text: filter) {
                                    removeFilter(filter)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 35) // Give it a consistent height when visible
                    .transition(.opacity.combined(with: .move(edge: .top))) // Add animation
                    .animation(.easeInOut, value: activeFilters)
                }

                // 6. Levels Grid (Functional Cells)
                HStack(alignment: .top, spacing: 8) {
                    // Note: For simplicity, columns are always shown.
                    // A real app might hide columns if their corresponding filter is removed,
                    // or filter the rows displayed within *all* columns.

                    // Column 1 (General) - Assumed always relevant or filterable differently
                     if activeFilters.contains("General") || activeFilters.isEmpty { // Example logic: Show if "General" filter active or no filters active
                        VStack(spacing: 8) {
                            ForEach(generalLevels) { level in
                                LevelCell(levelInfo: level, backgroundColor: levelPurple) {
                                    showLevelDetail(level)
                                }
                            }
                            Spacer() // Pushes content up
                        }
                    }

                    // Column 2 (Microsoft)
                    if activeFilters.contains("Microsoft") || activeFilters.isEmpty {
                         VStack(spacing: 8) {
                            ForEach(microsoftLevels) { level in
                               LevelCell(levelInfo: level, backgroundColor: levelBlue) {
                                   showLevelDetail(level)
                               }
                           }
                           Spacer()
                        }
                    }

                    // Column 3 (Google)
                    if activeFilters.contains("Google") || activeFilters.isEmpty {
                         VStack(spacing: 8) {
                            ForEach(googleLevels) { level in
                               LevelCell(levelInfo: level, backgroundColor: levelGreen) {
                                   showLevelDetail(level)
                               }
                           }
                            Spacer()
                        }
                    }
                    // Add other company columns here based on filters similarly
                }
                .padding(.horizontal)
                .padding(.bottom)
                 .animation(.easeInOut, value: activeFilters) // Animate column appearance/disappearance

            } // End Main VStack
        } // End ScrollView
        .sheet(item: $selectedLevelInfo) { level in // Use .sheet(item:) for typed data
             LevelDetailView(levelInfo: level)
                 .presentationDetents([.medium, .large]) // Allow resizing
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundDark.ignoresSafeArea()

            VStack(spacing: 0) {
                // Main Content Area managed by TabView
                TabView(selection: $selectedTab) {

                    // Placeholder Tab Views
                    PlaceholderTabView(title: "Chat", systemImageName: "text.bubble.fill")
                        .tag(0)
                         .tabItem { Image(systemName: "text.bubble.fill") }

                    PlaceholderTabView(title: "Finance", systemImageName: "banknote.fill")
                        .tag(1)
                         .tabItem { Image(systemName: "banknote.fill") }

                    // --- Main Levels View ---
                    levelsViewContent
                        .tag(2)
                         .tabItem { Image(systemName: "chart.bar.fill") } // Kept representative icon

                    PlaceholderTabView(title: "Notifications", systemImageName: "bell.fill")
                        .tag(3)
                         .tabItem { Image(systemName: "bell.fill") }

                    PlaceholderTabView(title: "Profile", systemImageName: "person.fill")
                        .tag(4)
                         .tabItem { Image(systemName: "person.fill") }

                } // End TabView
                .environment(\.colorScheme, .dark) // Ensure dark mode for tab items

                // Custom Indicator at the bottom
                CustomTabIndicator(tabCount: totalTabs, selectedIndex: $selectedTab)
                Spacer().frame(height: 10) // Space below indicator
            }

        } // End ZStack
        .statusBar(hidden: false) // Keep status bar visible
    }
}

// MARK: - Preview

#Preview {
    LevelsInfoView_V3()
}
