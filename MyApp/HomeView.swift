//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Data Models

struct JobCollection: Identifiable {
    let id = UUID()
    let iconName: String // System name or custom asset name
    let label: String
    let iconBackgroundColor: Color
}

struct JobListing: Identifiable {
    let id = UUID()
    let logoName: String // Could be company initial or image asset name
    let logoBackgroundColor: Color
    let title: String
    let company: String
    let location: String
    let salaryInfo: String?
    let alumniInfo: String? // e.g., "1 company alum works here"
    let isVerified: Bool
    let isPromoted: Bool
}

enum TabItem: String, CaseIterable, Identifiable {
    case home = "Home"
    case video = "Video"
    case network = "My Network"
    case notifications = "Notifications"
    case jobs = "Jobs"

    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .video: return "play.tv.fill"
        case .network: return "person.2.fill"
        case .notifications: return "bell.fill"
        case .jobs: return "briefcase.fill"
        }
    }
}

// MARK: - Sample Data

let jobCollectionsData: [JobCollection] = [
    JobCollection(iconName: "newspaper", label: "Publishing", iconBackgroundColor: .gray.opacity(0.3)),
    JobCollection(iconName: "pills", label: "Pharma", iconBackgroundColor: .green.opacity(0.3)),
    JobCollection(iconName: "testtube.2", label: "Biotech", iconBackgroundColor: .blue.opacity(0.3)),
    JobCollection(iconName: "square.grid.2x2", label: "More", iconBackgroundColor: .indigo.opacity(0.3))
]

let jobListingsData: [JobListing] = [
    JobListing(logoName: "F", logoBackgroundColor: .black, title: "Forbes Summer 2025 Technology Intern", company: "Forbes", location: "United States (Remote)", salaryInfo: nil, alumniInfo: "1 company alum works here", isVerified: true, isPromoted: true),
    JobListing(logoName: "S", logoBackgroundColor: .blue.opacity(0.8) , title: "Senior Systems Engineer", company: "Sage", location: "United States (Remote)", salaryInfo: "$114K/yr - $142K/yr • 401(k) benefit", alumniInfo: "7 school alumni work here", isVerified: true, isPromoted: true),
    JobListing(logoName: "G", logoBackgroundColor: .red.opacity(0.8), title: "Software Engineer, Backend", company: "Google", location: "Mountain View, CA", salaryInfo: "$150K/yr - $200K/yr", alumniInfo: "10 school alumni work here", isVerified: true, isPromoted: false),
]

// MARK: - Helper Views & Styles

struct FilterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundColor(.white)
            .background(Color.gray.opacity(configuration.isPressed ? 0.6 : 0.3))
            .clipShape(Capsule())
    }
}

struct ActionButtonStyle: ButtonStyle {
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundColor(isActive ? .white : Color(hex: "#70B5F9")) // Light blue text for inactive
            .background(isActive ? Color(hex: "#70B5F9") : Color.clear) // Blue background for active
            .overlay(
                Capsule().stroke(Color(hex: "#70B5F9"), lineWidth: isActive ? 0 : 1.5) // Border for inactive
            )
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// Utility to use Hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0) // Default to black
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Main Content Views (Jobs Screen Specific)

struct JobsTopBar: View {
    var body: some View {
        HStack(spacing: 15) {
            Image("My-meme-original") // Replace with actual user profile image
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipShape(Circle())

            // Search Bar Placeholder
            HStack {
                 Image(systemName: "briefcase.fill")
                     .foregroundColor(.gray)
                 Text("Search jobs")
                     .foregroundColor(.gray)
                 Spacer()
            }
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

             Button {
                 print("Messages tapped")
             } label: {
                 Image(systemName: "ellipsis.message.fill")
                     .font(.title2)
                     .foregroundColor(.gray)
             }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color("LinkedInDarkBlue")) // Use defined color
    }
}

struct FilterButtonsView: View {
    let filters = ["Preferences", "My jobs", "Post a free job"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button(filter) {
                        print("\(filter) tapped")
                    }
                    .buttonStyle(FilterButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color("LinkedInDarkBlue"))
    }
}

struct LookingForJobCard: View {
    @State private var isVisible = true // To allow dismissing

    var body: some View {
        if isVisible {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Cong, are you looking for a new job?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                         withAnimation { isVisible = false }
                     } label: {
                         Image(systemName: "xmark")
                             .foregroundColor(.gray)
                             .font(.system(size: 14, weight: .bold))
                     }
                }

                Text("Add your preferences to find relevant jobs and get notified about new open roles.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Image("My-meme-with-cap-2") // Replace with actual illustration
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8) // Slight rounding if needed

                HStack(spacing: 10) {
                     Button("Actively looking") { print("Actively looking") }
                        .buttonStyle(ActionButtonStyle(isActive: true))

                     Button("Casually browsing") { print("Casually browsing") }
                        .buttonStyle(ActionButtonStyle(isActive: false))

                    Spacer() // Push buttons left
                }
            }
            .padding()
            .background(Color("LinkedInCardBackground"))
            .cornerRadius(10) // Rounded corners for the card itself
            .padding(.horizontal)
            .transition(.opacity.combined(with: .scale(scale: 0.9))) // Add animation
        }
    }
}

struct ExploreCollectionsView: View {
    var body: some View {
        VStack(alignment: .leading) {
             Text("Explore with job collections")
                 .font(.system(size: 18, weight: .semibold))
                 .foregroundColor(.white)
                 .padding(.horizontal)
                 .padding(.bottom, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                 HStack(alignment: .top, spacing: 25) {
                     ForEach(jobCollectionsData) { collection in
                         VStack(spacing: 8) {
                             Image(systemName: collection.iconName)
                                 .font(.title2)
                                 .foregroundColor(.white)
                                 .frame(width: 50, height: 50)
                                 .background(collection.iconBackgroundColor)
                                 .cornerRadius(8)

                            Text(collection.label)
                                 .font(.system(size: 12))
                                 .foregroundColor(.gray)
                                 .frame(width: 70) // Ensure text wraps if needed
                                 .multilineTextAlignment(.center)

                            // Indicator for selected tab (example: Publishing)
                            if collection.label == "Publishing" {
                                 Rectangle()
                                     .fill(.white)
                                     .frame(width: 50, height: 2)
                            } else {
                                 Rectangle()
                                     .fill(.clear)
                                     .frame(width: 50, height: 2)
                           }
                         }
                    }
                 }
                 .padding(.horizontal)
                 .padding(.bottom, 10)
             }
        }
        .padding(.top) // Add spacing above this section
    }
}

struct JobListingCardView: View {
    let listing: JobListing

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 10) {
                // Logo or Initial
                 Text(listing.logoName) // Simple initial display
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(listing.logoBackgroundColor)
                    .cornerRadius(8) // Or .clipShape(Circle()) if circular

                // Job Details
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(listing.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        if listing.isVerified {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        Spacer() // Push X button right
                         Button { print("Dismiss job \(listing.id)") } label: {
                             Image(systemName: "xmark")
                                 .foregroundColor(.gray)
                         }
                    }
                    Text(listing.company)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                    Text(listing.location)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    if let salary = listing.salaryInfo {
                        Text(salary)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                    }

                    if let alumni = listing.alumniInfo {
                         HStack(spacing: 5) {
                             Image("alumni_icon_placeholder") // Replace with actual icon
                                 .resizable()
                                 .frame(width: 16, height: 16)
                                 .clipShape(Circle()) // Assuming icon is circular
                             Text(alumni)
                                 .font(.system(size: 12))
                                 .foregroundColor(.gray)
                         }
                         .padding(.top, 2)
                    }

                    if listing.isPromoted {
                         Text("Promoted")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                }
            }
            Divider().background(Color.gray.opacity(0.3)).padding(.vertical, 8)
        }
         .padding(.horizontal)
         // No background needed if the main ScrollView background handles it
    }
}

// MARK: - Main Jobs View Container

struct JobsView: View {
    var body: some View {
        VStack(spacing: 0) {
            JobsTopBar()
            FilterButtonsView()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    LookingForJobCard()
                    ExploreCollectionsView()
                        .padding(.bottom, 10) // Space before listings

                    // Title for Recommended Jobs (optional, inferred from UI)
                    Text("Recommended for you")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 5)

                    ForEach(jobListingsData) { listing in
                        JobListingCardView(listing: listing)
                    }
                }
                .padding(.top) // Space between filter buttons and first card
                .padding(.bottom, 80) // Space at the bottom for tab bar overlap
            }
        }
        .background(Color("LinkedInDarkBlue").ignoresSafeArea()) // Match background
    }
}

// MARK: - Placeholder Views for Other Tabs

struct PlaceholderView: View {
    let title: String
    var body: some View {
        ZStack {
            Color("LinkedInDarkBlue").ignoresSafeArea()
            Text("\(title) Screen")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Main TabView Structure

struct LinkedInTabView: View {
    @State private var selectedTab: TabItem = .jobs

    init() {
        // Customize Tab Bar Appearance (Globally)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("LinkedInTabBarBackground")) // Darker background

        // Unselected icon/text color
         appearance.stackedLayoutAppearance.normal.iconColor = .gray
         appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

        // Selected icon/text color
         appearance.stackedLayoutAppearance.selected.iconColor = .white
         appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

         UITabBar.appearance().standardAppearance = appearance
         if #available(iOS 15.0, *) {
             UITabBar.appearance().scrollEdgeAppearance = appearance
         }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabItem.allCases) { item in
                // Use actual views or placeholders
                Group {
                    if item == .jobs {
                        JobsView()
                    } else {
                        PlaceholderView(title: item.rawValue)
                    }
                }
                .tabItem {
                    Label(item.rawValue, systemImage: item.iconName)
                }
                .tag(item) // Tag each view with its corresponding enum case
            }
        }
         // Apply the preferred dark color scheme for the whole app context
         .preferredColorScheme(.dark)
    }
}

// MARK: - App Definition and Color Assets

// Define custom colors used in the UI
// It's better to put these in your Asset Catalog, but defining here for single-file simplicity.
extension Color {
    static let LinkedInDarkBlue = Color(hex: "#1D2226") // Approximate main background
    static let LinkedInCardBackground = Color(hex: "#292E32") // Approximate card background
    static let LinkedInTabBarBackground = Color(hex: "#161A1D") // Approximate tab bar background
    static let LinkedInLightBlue = Color(hex: "#70B5F9") // Action button blue
}
//
//@main
//struct LinkedInJobsCloneApp: App { // Rename if needed
//    var body: some Scene {
//        WindowGroup {
//            LinkedInTabView()
//                // Add necessary environment objects if any
//        }
//    }
//}

// MARK: - Previews

#Preview("Full LinkedIn Jobs Screen") {
     // Ensure color assets are somewhat defined for preview if not using Asset Catalog
    LinkedInTabView()
        .preferredColorScheme(.dark) // force dark mode for preview
}

#Preview("Job Listing Card") {
    JobListingCardView(listing: jobListingsData[0])
        .padding()
        .background(Color("LinkedInCardBackground"))
        .preferredColorScheme(.dark)
}

#Preview("Looking For Job Card") {
    LookingForJobCard()
        .background(Color("LinkedInDarkBlue"))
        .preferredColorScheme(.dark)
}

#Preview("Explore Collections") {
    ExploreCollectionsView()
        .background(Color("LinkedInDarkBlue"))
        .preferredColorScheme(.dark)
}

#Preview("Filter Buttons") {
    FilterButtonsView()
        .preferredColorScheme(.dark)
}
