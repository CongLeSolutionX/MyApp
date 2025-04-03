//
//  LibraryView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: --- NEW Data Models for Library Screen ---

enum LibraryTab: String, CaseIterable, Identifiable {
    case yourLists = "Your lists"
    case savedLists = "Saved lists"
    case highlighted = "Highlighted"
    case readingHistory = "Reading history"
    var id: String { self.rawValue }
}

// MARK: - Sample Data (Keep All Previous + New Library Data)


struct ReadingListItem: Identifiable {
    let id = UUID()
    let authorName: String
    let authorImageName: String // Asset name
    let listTitle: String
    let storyCount: Int
    let isPrivate: Bool
    let thumbnailImageNames: [String] // Array of asset names for the previews
}



// --- NEW Sample Data for Library ---
let sampleReadingLists: [ReadingListItem] = [
    ReadingListItem(authorName: "Cong Le",
                    authorImageName: "profile_pic_cong", // Use your profile pic asset
                    listTitle: "Reading list",
                    storyCount: 2,
                    isPrivate: true,
                    thumbnailImageNames: ["list_thumb_1", "list_thumb_2", "list_thumb_3"]), // Add these assets
    ReadingListItem(authorName: "Cong Le",
                     authorImageName: "profile_pic_cong",
                     listTitle: "SwiftUI",
                     storyCount: 4,
                     isPrivate: false,
                     thumbnailImageNames: ["list_thumb_4", "list_thumb_5", "list_thumb_6"]) // Add these assets
    // Add more lists as needed
]

// --- NEW Green Button Style for "New List" ---
struct GreenFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .foregroundColor(.mediumWhite) // White text on green
            .background(Capsule().fill(Color.mediumGreen))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: --- NEW Library Screen Components ---

// --- Library Header (Title + New List Button) ---
struct LibraryHeaderView: View {
    var newListAction: () -> Void

    var body: some View {
        HStack {
            Text("Your library")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.mediumWhite)

            Spacer()

            Button("New list", action: newListAction)
                .buttonStyle(GreenFilledButtonStyle())
        }
        .padding(.horizontal)
        .padding(.top) // Add padding from the top safe area
        .padding(.bottom, 5) // Space below the header
    }
}

// --- Library Tab View (Similar to Profile/Home Tabs) ---
struct LibraryTabView: View {
    @Binding var selectedTab: LibraryTab
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) { // Adjust spacing as needed
                    ForEach(LibraryTab.allCases) { tab in
                        VStack(spacing: 8) { // Add spacing for underline
                            Text(tab.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(selectedTab == tab ? .mediumWhite : .mediumGrayText)
                                .fixedSize() // Prevent text wrapping unnecesarily
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedTab = tab
                                    }
                                }

                            // Underline
                            if selectedTab == tab {
                                Rectangle()
                                    .fill(Color.mediumWhite)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "libraryUnderline", in: animation)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 44) // Standard tap height

            Divider()
                .background(Color.mediumDarkGray)
        }
    }
}

// --- Reading List Card View ---
struct ReadingListCardView: View {
    let item: ReadingListItem
    let thumbnailSize: CGFloat = 100 // Size for the square thumbnails

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Author Info
            HStack(spacing: 8) {
                Image(item.authorImageName) // Use asset name
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                Text(item.authorName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.mediumWhite)
            }

            // List Title
            Text(item.listTitle)
                .font(.system(size: 24, weight: .bold)) // Larger title
                .foregroundColor(.mediumWhite)
                .padding(.top, 2) // Small space above title

            // Metadata (Story Count & Privacy)
            HStack(spacing: 8) {
                Text("\(item.storyCount) stories")
                     .font(.system(size: 14))
                     .foregroundColor(.mediumGrayText)

                if item.isPrivate {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12)) // Smaller lock icon
                        .foregroundColor(.mediumGrayText)
                }

                 Spacer() // Pushes metadata left, leaving space for buttons

                // Action Buttons (Download & More) - Pushed right
                Button {
                    print("Download tapped: \(item.listTitle)")
                    // Add download action
                } label: {
                    Image(systemName: "arrow.down.circle") // Download icon
                        .font(.system(size: 20))
                        .foregroundColor(.mediumGrayText)
                }
                .padding(.horizontal, 5) // Add padding around button

                Button {
                    print("More options tapped: \(item.listTitle)")
                    // Add more options action
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.mediumGrayText)
                }
                 .padding(.leading, 5) // Add padding around button
            }
            .padding(.bottom, 10) // Space between metadata/actions and images

            // Thumbnail ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) { // Spacing between thumbnails
                    ForEach(item.thumbnailImageNames, id: \.self) { imageName in
                         Image(imageName) // Use asset name
                             .resizable()
                             .scaledToFill()
                             .frame(width: thumbnailSize, height: thumbnailSize)
                             .clipped() // Clip to bounds
                             .background(Color.mediumDarkGray) // Placeholder bg if image loads slow
                             .cornerRadius(4) // Slight rounding
                    }
                    // Add placeholder rectangles if needed for layout consistency
                    // ForEach(0..<(3 - item.thumbnailImageNames.count), id: \.self) { _ in
                    //      Rectangle()
                    //          .fill(Color.mediumDarkGray.opacity(0.5))
                    //          .frame(width: thumbnailSize, height: thumbnailSize)
                    //          .cornerRadius(4)
                    // }
                }
                // No horizontal padding needed inside if ScrollView has padding
            }
            // .frame(height: thumbnailSize) // Constrain ScrollView height
        }
        .padding() // Padding inside the card
        .background(Color.libraryCardBackground) // Use the defined subtle background
        .cornerRadius(8) // Rounded corners for the card itself
    }
}

// MARK: - Main Library Screen Content View

struct MediumLibraryContentView: View {
    @State private var selectedLibraryTab: LibraryTab = .yourLists

    // Filtered lists based on the selected tab (Placeholder Logic)
    private var displayedLists: [ReadingListItem] {
        switch selectedLibraryTab {
        case .yourLists:
            // Assume sampleReadingLists are the user's lists for now
            return sampleReadingLists
        case .savedLists:
            return [] // Placeholder - Fetch/filter saved lists
        case .highlighted:
            return [] // Placeholder - Fetch/filter lists with highlights
        case .readingHistory:
            return [] // Placeholder - Fetch/filter reading history lists/articles
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15, pinnedViews: [.sectionHeaders]) { // Pin the header+tabs

                 // Pinned Header Section
                 Section {
                      // List of Reading List Cards
                      if displayedLists.isEmpty {
                           Text("No lists found in \(selectedLibraryTab.rawValue).")
                               .foregroundColor(.mediumGrayText)
                               .padding()
                               .frame(maxWidth: .infinity, alignment: .center)
                      } else {
                           ForEach(displayedLists) { item in
                               ReadingListCardView(item: item)
                                    .padding(.horizontal) // Padding around cards
                           }
                           Spacer(minLength: 80) // Spacer for TAB bar clearance
                      }

                 } header: {
                      // Sticky Header (Title + Tabs)
                       VStack(spacing: 0) {
                           LibraryHeaderView {
                               print("New List Button Tapped")
                               // Add action to create a new list
                           }
                           LibraryTabView(selectedTab: $selectedLibraryTab)
                       }
                         .background(Material.bar) // Use Material for background when sticky
                  }
            }
        }
        .background(Color.mediumBlack.ignoresSafeArea())
        .navigationBarHidden(true) // Hide the default navigation bar
        .ignoresSafeArea(edges: .bottom) // Allow content to scroll under tab bar
    }
}

// MARK: - Previews

#Preview("Main Tab View (Library Selected)") {
    // Helper to select the Library tab
    struct PreviewWrapper: View {
        @State var selectedTab = 2 // Start on Library tab
        var body: some View {
            MediumTabView(selectedSystemTab: selectedTab)
        }
    }
    return PreviewWrapper()
}

#Preview("Library Content View") {
    MediumLibraryContentView()
        .preferredColorScheme(.dark)
}

#Preview("Library Header View") {
    LibraryHeaderView(newListAction: {})
        .background(Color.mediumBlack)
        .preferredColorScheme(.dark)
}

#Preview("Library Tab View") {
    LibraryTabView(selectedTab: .constant(.yourLists))
        .background(Color.mediumBlack)
        .preferredColorScheme(.dark)
}

#Preview("Reading List Card View") {
    ReadingListCardView(item: sampleReadingLists[0])
        .padding()
        .background(Color.mediumBlack)
        .preferredColorScheme(.dark)
}
