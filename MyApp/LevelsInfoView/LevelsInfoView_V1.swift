////
////  V1.swift
////  MyApp
////
////  Created by Cong Le on 4/7/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models (Example Data)
//
//struct LevelInfo: Identifiable {
//    let id = UUID()
//    let title: String
//    let subtitle: String?
//}
//
//let generalLevels: [LevelInfo] = [
//    LevelInfo(title: "Software Engineer I", subtitle: nil),
//    LevelInfo(title: "Software Engineer II", subtitle: nil),
//    LevelInfo(title: "Senior Software Engineer", subtitle: nil),
//    LevelInfo(title: "Staff Software Engineer", subtitle: nil),
//    LevelInfo(title: "Lead Software Engineer", subtitle: nil),
//    LevelInfo(title: "Principal Software Engineer", subtitle: nil),
//    // Add more as needed... Looks like one is cut off
//    LevelInfo(title: "Senior Principal S...", subtitle: nil)
//]
//
//let microsoftLevels: [LevelInfo] = [
//    LevelInfo(title: "SDE", subtitle: "59"),
//    LevelInfo(title: "SDE II", subtitle: "60"),
//    LevelInfo(title: "61", subtitle: nil), // Assuming label changed or missing
//    LevelInfo(title: "Senior SDE", subtitle: "62"), // Label moved
//    LevelInfo(title: "63", subtitle: nil), // Assuming label changed or missing
//    LevelInfo(title: "Principal SDE", subtitle: "65"), // Label moved
//    LevelInfo(title: "66", subtitle: nil),
//    LevelInfo(title: "67", subtitle: nil)
//]
//
//let googleLevels: [LevelInfo] = [
//    LevelInfo(title: "L3", subtitle: "SWE II"),
//    LevelInfo(title: "L4", subtitle: "SWE III"),
//    LevelInfo(title: "L5", subtitle: "Senior SWE"),
//    LevelInfo(title: "L6", subtitle: "Staff SWE"),
//    LevelInfo(title: "L7", subtitle: "Senior Staff SWE") // Assuming based on pattern
//    // Add L8 etc. if needed
//]
//
//// MARK: - Reusable Views
//
//struct LevelCell: View {
//    let levelInfo: LevelInfo
//    let backgroundColor: Color
//    let minHeight: CGFloat = 65 // Adjusted height based on visuals
//
//    var body: some View {
//        VStack(alignment: .center, spacing: 4) {
//            Text(levelInfo.title)
//                .font(.system(size: 14, weight: .medium)) // Adjusted font size slightly
//                .foregroundColor(.black) // Text color appears black/dark in cells
//                .multilineTextAlignment(.center)
//
//            if let subtitle = levelInfo.subtitle {
//                Text(subtitle)
//                    .font(.system(size: 12))
//                    .foregroundColor(.black.opacity(0.8))
//                    .multilineTextAlignment(.center)
//            }
//        }
//        .padding(8) // Padding inside the cell
//        .frame(maxWidth: .infinity) // Take available width in the column
//        .frame(minHeight: minHeight)
//        .background(backgroundColor)
//        .cornerRadius(8) // Rounded corners for cells
//    }
//}
//
//struct CompanyLogoView: View {
//    let imageName: String // Use actual asset names or SF Symbols if placeholders
//    let size: CGFloat = 50
//
//    var body: some View {
//        Image(imageName) // Placeholder - replace with actual logo images/assets
//            .resizable()
//            .scaledToFit()
//            .frame(width: size * 0.6, height: size * 0.6) // Adjust logo size within circle
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
//            .background(Capsule().fill(Color.gray.opacity(0.4))) // Darker capsule fill
//            .overlay(Capsule().stroke(Color.gray, lineWidth: 0.5)) // Subtle border
//        }
//    }
//}
//
//// MARK: - Main Content View
//
//struct LevelsInfoView: View {
//    @State private var searchText: String = ""
//    // Example state for filters, replace with actual logic
//    @State private var activeFilters: [String] = ["Disney", "Microsoft", "Google"]
//    // Example state for selected tab
//    @State private var selectedTab: Int = 2 // Start on the 'levels' tab
//
//    // Colors matching the screenshot
//    let backgroundDark = Color.black
//    let elementBackgroundGray = Color.gray.opacity(0.25)
//    let borderGray = Color.gray.opacity(0.5)
//    let levelPurple = Color(red: 0.7, green: 0.7, blue: 0.9) // Approximated color
//    let levelBlue = Color(red: 0.6, green: 0.85, blue: 0.95) // Approximated color
//    let levelGreen = Color(red: 0.75, green: 0.9, blue: 0.75) // Approximated color
//
//    var body: some View {
//        ZStack {
//            backgroundDark.ignoresSafeArea()
//
//            TabView(selection: $selectedTab) {
//
//                // Placeholder content for other tabs
//                Text("Chat Tab").tag(0)
//                    .tabItem { Label("Chat", systemImage: "message") }
//                Text("Finance Tab").tag(1)
//                     .tabItem { Label("Finance", systemImage: "creditcard") } // Placeholder icon
//
//                // Main Levels View Content
//                ScrollView { // Make the main content scrollable if grid exceeds screen height
//                    VStack(spacing: 15) {
//                        // 1. Role Selector
//                        HStack {
//                            Image(systemName: "briefcase.fill")
//                            Text("Software Engineer")
//                                .fontWeight(.medium)
//                            Spacer()
//                            Image(systemName: "chevron.down")
//                        }
//                        .padding(.horizontal, 15)
//                        .padding(.vertical, 10)
//                        .background(elementBackgroundGray)
//                        .clipShape(Capsule())
//                        .padding(.horizontal)
//                        .padding(.top) // Add padding from status bar
//
//                        // 2. Section Header
//                        HStack {
//                            Image(systemName: "chart.bar.xaxis")
//                                .font(.title2)
//                            Text("Software Engineer Levels")
//                                .fontWeight(.semibold)
//                            Image(systemName: "info.circle")
//                            Spacer() // Pushes content to the left
//                        }
//                        .padding(.horizontal)
//
//                        // 3. Search Bar
//                        HStack {
//                            Image(systemName: "magnifyingglass")
//                                .foregroundColor(.gray)
//                            TextField("Search companies", text: $searchText)
//                                .foregroundColor(.white)
//                                .tint(.blue) // Set cursor/highlight color
//                        }
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 10)
//                        .background(elementBackgroundGray) // Match capsule background
//                        .cornerRadius(8)
//                        .overlay(
//                             RoundedRectangle(cornerRadius: 8)
//                                 .stroke(borderGray, lineWidth: 1) // Add border
//                         )
//                        .padding(.horizontal)
//
//                        // 4. Company Logos Row
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 15) {
//                                // Replace "logo_amazon", etc. with your actual asset names
//                                CompanyLogoView(imageName: "logo_amazon") // Example SFSymbol
//                                CompanyLogoView(imageName: "logo_google") // Example SFSymbol
//                                CompanyLogoView(imageName: "logo_microsoft") // Example SFSymbol
//                                CompanyLogoView(imageName: "logo_facebook") // Example SFSymbol
//                                CompanyLogoView(imageName: "logo_apple") // Example SFSymbol
//                            }
//                            .padding(.horizontal) // Padding for the scroll view content
//                        }
//
//                        // 5. Selected Filters Row
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 10) {
//                                ForEach(activeFilters, id: \.self) { filter in
//                                    FilterPillView(text: filter) {
//                                        // Action to remove filter
//                                        if let index = activeFilters.firstIndex(of: filter) {
//                                            activeFilters.remove(at: index)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                        // Only show filters if there are any
//                        .frame(height: activeFilters.isEmpty ? 0 : nil)
//                        .opacity(activeFilters.isEmpty ? 0 : 1)
//
//                        // 6. Levels Grid
//                        HStack(alignment: .top, spacing: 8) { // Align columns to top, add spacing
//                            // Column 1 (General?) - Purple
//                            VStack(spacing: 8) {
//                                ForEach(generalLevels) { level in
//                                    LevelCell(levelInfo: level, backgroundColor: levelPurple)
//                                }
//                                Spacer() // Pushes cells up if column heights differ
//                            }
//
//                            // Column 2 (Microsoft?) - Blue
//                            VStack(spacing: 8) {
//                                ForEach(microsoftLevels) { level in
//                                    LevelCell(levelInfo: level, backgroundColor: levelBlue)
//                                }
//                                Spacer()
//                            }
//
//                            // Column 3 (Google?) - Green
//                            VStack(spacing: 8) {
//                                ForEach(googleLevels) { level in
//                                    LevelCell(levelInfo: level, backgroundColor: levelGreen)
//                                }
//                                Spacer()
//                            }
//                        }
//                        .padding(.horizontal) // Padding around the entire grid
//                        .padding(.bottom) // Padding at the bottom of the scroll content
//
//                    } // End Main VStack
//                } // End ScrollView
//                .tag(2)
//                .tabItem { Label("Levels", systemImage: "chart.stairs") } // Custom icon name
//
//                Text("Notifications Tab").tag(3)
//                    .tabItem { Label("Notifications", systemImage: "bell") }
//                Text("Profile Tab").tag(4)
//                    .tabItem { Label("Profile", systemImage: "person") }
//
//            } // End TabView
//            .accentColor(.white) // Set the selected tab item color
//            .preferredColorScheme(.dark) // Force dark mode appearance for tab bar etc.
//
//        } // End ZStack
//        .statusBar(hidden: false) // Ensure status bar is visible
//        // Use .toolbarColorScheme(.dark, for: .tabBar) on TabView for more specific control if needed
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    LevelsInfoView()
//        // Add dummy logo images to Assets.xcassets for preview
//        // with names "logo_amazon", "logo_google", etc.
//        // Or replace CompanyLogoView's Image with system images for preview
//}
//
//// MARK: - Helper SF Symbol names (Example - Replace with actual assets)
//
//// You would typically have these images in your Asset Catalog
//extension Image {
//    // Example using SF Symbols as placeholders if you don't have logos
//    // To use these, replace Image("logo_amazon") with Image.logoAmazon in CompanyLogoView
//    static var logoAmazon: Image { Image(systemName: "a.circle.fill") }
//    static var logoGoogle: Image { Image(systemName: "g.circle.fill") }
//    static var logoMicrosoft: Image { Image(systemName: "square.grid.3x3.fill") } // Placeholder
//    static var logoFacebook: Image { Image(systemName: "f.cursive.circle.fill") }
//    static var logoApple: Image { Image(systemName: "apple.logo") }
//    static var chartStairs: Image { Image(systemName: "chart.bar.doc.horizontal") } // Example matching icon
//}
