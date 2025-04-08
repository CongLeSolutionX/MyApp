////
////  LevelsInfoView.swift
////  MyApp
////
////  Created by Cong Le on 4/7/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models (Updated Example Data)
//
//struct LevelInfo: Identifiable {
//    let id = UUID()
//    let title: String
//    let subtitle: String?
//}
//
//// Assumed full titles where abbreviated in screenshot
//let generalLevels: [LevelInfo] = [
//    LevelInfo(title: "Software Engineer I", subtitle: nil),
//    LevelInfo(title: "Software Engineer II", subtitle: nil),
//    LevelInfo(title: "Senior Software Engineer", subtitle: nil),
//    LevelInfo(title: "Staff Software Engineer", subtitle: nil),
//    LevelInfo(title: "Lead Software Engineer", subtitle: nil),
//    LevelInfo(title: "Principal Software Engineer", subtitle: nil),
//    LevelInfo(title: "Senior Principal Software Engineer", subtitle: nil) // Expanded title
//]
//
//let microsoftLevels: [LevelInfo] = [
//    LevelInfo(title: "SDE", subtitle: "59"),
//    LevelInfo(title: "SDE II", subtitle: "60"),
//    LevelInfo(title: "61", subtitle: nil),
//    LevelInfo(title: "Senior SDE", subtitle: "62"),
//    LevelInfo(title: "63", subtitle: nil),
//    LevelInfo(title: "Principal SDE", subtitle: "64"), // Screenshot has 64 below Principal
//    LevelInfo(title: "65", subtitle: nil), // Screenshot has Principal SDE label next to 65, associating 64 with text above
//    LevelInfo(title: "66", subtitle: nil),
//    LevelInfo(title: "67", subtitle: nil),
//    LevelInfo(title: "Partner", subtitle: "68"),
//    LevelInfo(title: "69", subtitle: nil),
//    LevelInfo(title: "Distinguished Engineer", subtitle: "70"),
//    LevelInfo(title: "Technical Fellow", subtitle: "80") // Skipped 71-79? Assuming 80 is correct.
//]
//
//let googleLevels: [LevelInfo] = [
//    LevelInfo(title: "L3", subtitle: "SWE II"),
//    LevelInfo(title: "L4", subtitle: "SWE III"),
//    LevelInfo(title: "L5", subtitle: "Senior SWE"),
//    LevelInfo(title: "L6", subtitle: "Staff SWE"),
//    LevelInfo(title: "L7", subtitle: "Senior Staff SWE"),
//    LevelInfo(title: "L8", subtitle: "Principal Engineer"),
//    LevelInfo(title: "L9", subtitle: "Distinguished Engineer"),
//    LevelInfo(title: "L10", subtitle: "Google Fellow")
//]
//
//// MARK: - Reusable Views (Unchanged from previous)
//
//struct LevelCell: View {
//    let levelInfo: LevelInfo
//    let backgroundColor: Color
//    let minHeight: CGFloat = 65
//
//    var body: some View {
//        VStack(alignment: .center, spacing: 4) {
//            Text(levelInfo.title)
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(.black)
//                .multilineTextAlignment(.center)
//
//            if let subtitle = levelInfo.subtitle {
//                Text(subtitle)
//                    .font(.system(size: 12))
//                    .foregroundColor(.black.opacity(0.8))
//                    .multilineTextAlignment(.center)
//            }
//        }
//        .padding(8)
//        .frame(maxWidth: .infinity)
//        .frame(minHeight: minHeight)
//        .background(backgroundColor)
//        .cornerRadius(8)
//    }
//}
//
//struct CompanyLogoView: View {
//    let imageName: String
//    let size: CGFloat = 50
//
//    var body: some View {
//        // Using SF Symbols as placeholders - replace "a.circle.fill" etc. with actual logo images
//        Image(systemName: imageName)
//            .resizable()
//            .scaledToFit()
//            .frame(width: size * 0.6, height: size * 0.6)
//            .foregroundColor(.white.opacity(0.8)) // Make symbol visible
//            .frame(width: size, height: size)
//            .background(Color.gray.opacity(0.3))
//            .clipShape(Circle())
//    }
//}
//
//struct FilterPillView: View {
//    let text: String
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 4) {
//                Image(systemName: "xmark")
//                    .font(.system(size: 10, weight: .bold))
//                Text(text)
//                    .font(.system(size: 14))
//            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 6)
//            .foregroundColor(.white)
//            .background(Capsule().fill(Color.gray.opacity(0.4)))
//            .overlay(Capsule().stroke(Color.gray, lineWidth: 0.5))
//        }
//    }
//}
//
//// MARK: - Custom Tab Indicator
//
//struct CustomTabIndicator: View {
//    let tabCount: Int
//    @Binding var selectedIndex: Int
//
//    var body: some View {
//        GeometryReader { geometry in
//            let tabWidth = geometry.size.width / CGFloat(tabCount)
//            let indicatorWidth: CGFloat = tabWidth * 0.5 // Adjust width of the indicator
//            let xOffset = (CGFloat(selectedIndex) * tabWidth) + (tabWidth / 2) - (indicatorWidth / 2)
//
//            Capsule()
//                .fill(Color.white)
//                .frame(width: indicatorWidth, height: 4) // Adjust height
//                .offset(x: xOffset)
//                .animation(.easeInOut(duration: 0.25), value: selectedIndex) // Animate movement
//        }
//        .frame(height: 4) // Height of the indicator container
//    }
//}
//
//// MARK: - Main Content View (Updated)
//
//struct LevelsInfoView_V2: View {
//    @State private var searchText: String = ""
//    @State private var activeFilters: [String] = ["Disney", "Microsoft", "Google"] // Keep filters from screenshot
//    @State private var selectedTab: Int = 2 // Start on the 'Levels' tab (index 2)
//
//    // Colors matching the screenshot
//    let backgroundDark = Color.black
//    let elementBackgroundGray = Color.gray.opacity(0.25)
//    let borderGray = Color.gray.opacity(0.5)
//    let levelPurple = Color(red: 0.7, green: 0.7, blue: 0.9)
//    let levelBlue = Color(red: 0.6, green: 0.85, blue: 0.95)
//    let levelGreen = Color(red: 0.75, green: 0.9, blue: 0.75)
//
//    // Total number of tabs
//    let totalTabs = 5
//
//    // MARK: - Levels View Content (Extracted for clarity)
//    var levelsViewContent: some View {
//        ScrollView {
//            VStack(spacing: 15) {
//                // 1. Role Selector
//                HStack {
//                    Image(systemName: "briefcase.fill")
//                    Text("Software Engineer")
//                        .fontWeight(.medium)
//                    Spacer()
//                    Image(systemName: "chevron.down")
//                }
//                .padding(.horizontal, 15)
//                .padding(.vertical, 10)
//                .background(elementBackgroundGray)
//                .clipShape(Capsule())
//                .padding(.horizontal)
//                .padding(.top) // Add padding from status bar
//
//                 // REMOVED Section Header & Search for brevity in this view
//                 // Keep if needed, structure remains same as before
//
//                // 4. Company Logos Row (Using SF Symbol Placeholders)
//                 ScrollView(.horizontal, showsIndicators: false) {
//                     HStack(spacing: 15) {
//                         CompanyLogoView(imageName: "a.circle.fill") // Amazon Placeholder
//                         CompanyLogoView(imageName: "g.circle.fill") // Google Placeholder
//                         CompanyLogoView(imageName: "square.grid.3x3.fill") // Microsoft Placeholder
//                         CompanyLogoView(imageName: "f.cursive.circle.fill") // Facebook Placeholder
//                         CompanyLogoView(imageName: "apple.logo") // Apple Placeholder
//                     }
//                     .padding(.horizontal)
//                 }
//
//                // 5. Selected Filters Row
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        ForEach(activeFilters, id: \.self) { filter in
//                            FilterPillView(text: filter) {
//                                if let index = activeFilters.firstIndex(of: filter) {
//                                    activeFilters.remove(at: index)
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .frame(height: activeFilters.isEmpty ? 0 : nil)
//                .opacity(activeFilters.isEmpty ? 0 : 1)
//
//                // 6. Levels Grid
//                HStack(alignment: .top, spacing: 8) {
//                    // Column 1 (General?) - Purple
//                    VStack(spacing: 8) {
//                        ForEach(generalLevels) { level in
//                            LevelCell(levelInfo: level, backgroundColor: levelPurple)
//                        }
//                        Spacer()
//                    }
//
//                    // Column 2 (Microsoft?) - Blue
//                    VStack(spacing: 8) {
//                        ForEach(microsoftLevels) { level in
//                            LevelCell(levelInfo: level, backgroundColor: levelBlue)
//                        }
//                        Spacer()
//                    }
//
//                    // Column 3 (Google?) - Green
//                    VStack(spacing: 8) {
//                        ForEach(googleLevels) { level in
//                            LevelCell(levelInfo: level, backgroundColor: levelGreen)
//                        }
//                        Spacer()
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom)
//
//            }
//        }
//    }
//
//    // MARK: - Body
//    var body: some View {
//        ZStack {
//            backgroundDark.ignoresSafeArea()
//
//            VStack(spacing: 0) { // Use VStack to place indicator above TabView
//                // Custom Indicator - Placed Above TabView Content Area
//                // Note: This indicator shows *above* the TabView items, not below the content
//                 // If you want it strictly above the tab BAR, structure is different
//                 // This approach puts it at the top of the screen area managed by the VStack
//
//                // Main Content Area managed by TabView
//                TabView(selection: $selectedTab) {
//
//                    // Placeholder content for other tabs
//                    Text("Chat Tab").foregroundColor(.white).tag(0)
//                        .tabItem { Image(systemName: "text.bubble.fill") } // Updated Icon
//
//                    Text("Finance Tab").foregroundColor(.white).tag(1)
//                         .tabItem { Image(systemName: "banknote.fill") } // Updated Icon
//
//                    // Main Levels View Content
//                    levelsViewContent
//                        .tag(2)
//                        // No .tabItem here if using custom bar, but needed for standard TabView
//
//                    Text("Notifications Tab").foregroundColor(.white).tag(3)
//                        .tabItem { Image(systemName: "bell.fill") } // Updated Icon
//
//                    Text("Profile Tab").foregroundColor(.white).tag(4)
//                        .tabItem { Image(systemName: "person.fill") } // Updated Icon
//
//                } // End TabView
//                .environment(\.colorScheme, .dark) // Apply dark scheme for tab bar icons etc.
//                // Standard TabView doesn't easily allow placing things *above* items
//                // Reverting to standard tabView appearance as custom overlay is complex
//
//                 // Custom Indicator Logic - Simplified (goes above the entire view)
//                 // For indicator strictly above icons, would need full custom TabBar
//                 CustomTabIndicator(tabCount: totalTabs, selectedIndex: $selectedTab)
//                 Spacer().frame(height: 10) // Space below indicator before bottom edge
//            }
//
//        } // End ZStack
//        .statusBar(hidden: false)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    LevelsInfoView_V2()
//        // Ensure you have placeholder assets or use SF Symbols in CompanyLogoView
//}
