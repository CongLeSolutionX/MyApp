//
//  V2.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// MARK: - Data Model (Placeholders)

struct StoryPreview: Identifiable {
    let id = UUID()
    let imageName: String // Placeholder for image name/URL
    let isAddButton: Bool = false
}

struct Viewer: Identifiable {
    let id = UUID()
    let name: String
    let profileImageName: String // Placeholder for image name/URL
    let source: String? // Optional subtitle like "Instagram"
}

// MARK: - Main Content View

struct StoryInsightsView: View {
    @State private var selectedTab: Tab = .viewers
    @State private var stories: [StoryPreview] = [
        StoryPreview(imageName: "story_placeholder_1"),
        StoryPreview(imageName: "story_placeholder_2")
    ]
    @State private var viewers: [Viewer] = [
        Viewer(name: "Anh Tran", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Khoa Le", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Hoang Mai", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Eric Nguyen", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Yen Nhi Nguyen", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Lan Giao", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "timmy.cuts", profileImageName: "person.crop.circle.fill", source: "Instagram")
    ]
    // Data for Insights (Placeholder)
    @State private var uniqueAccountViews: Int = 7

    enum Tab {
        case viewers
        case insights
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // 1. Story Previews Section
                    StoryPreviewSection(stories: stories)
                        .padding(.top) // Add some top padding if needed below nav bar

                    // 2. Tab Bar Section
                    TabBarSection(selectedTab: $selectedTab)

                    // Divider Line
                    Rectangle()
                         .frame(height: 0.5)
                         .foregroundColor(Color(.systemGray4))
                         .padding(.bottom) // Add padding below divider for separation


                    // 3. Content based on Tab
                    // Use a container to apply padding consistently
                    VStack {
                        if selectedTab == .viewers {
                           ViewersListSection(viewers: viewers)
                        } else {
                           InsightsViewContent(uniqueAccountViews: uniqueAccountViews)
                        }
                    }
                    .padding(.horizontal) // Apply horizontal padding to the content area below tabs


                }
            }
            .background(Color(.systemBackground)) // Use system background for adaptability
            .navigationBarTitleDisplayMode(.inline) // Avoid large titles
            .toolbar {
                // Navigation Bar Items
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Action for globe button
                        print("Globe tapped")
                    } label: {
                        Image(systemName: "globe")
                            .foregroundColor(.primary) // Adjust color as needed
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        Button {
                            // Action for history button
                            print("History tapped")
                        } label: {
                            Image(systemName: "clock")
                                .foregroundColor(.primary)
                        }
                        Button {
                             // Action for close button
                            print("Close tapped")
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .preferredColorScheme(.dark) // Force dark mode as per screenshot
        }
    }
}

// MARK: - Subviews

struct StoryPreviewSection: View {
    let stories: [StoryPreview]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                 // Prepend the "Add to Story" button
                 AddToStoryButton()

                ForEach(stories) { story in
                    StoryThumbnail(imageName: story.imageName)
                }
            }
            .padding(.horizontal) // Add horizontal padding to the HStack content
            .padding(.bottom) // Add padding below the stories
        }
    }
}

struct AddToStoryButton: View {
     var body: some View {
         VStack {
             Image(systemName: "plus.circle.fill")
                 .font(.system(size: 30))
                 .foregroundColor(.blue) // Or systemBlue
                 .padding(.bottom, 5) // Space between icon and text

             Text("Add to\nStory") // Use \n for newline
                 .font(.caption)
                 .foregroundColor(.primary)
                 .multilineTextAlignment(.center) // Center align text
                 .lineLimit(2) // Ensure it fits in two lines
                 .fixedSize(horizontal: false, vertical: true) // Prevent text from causing excessive height

              Spacer() // Push content to top
         }
         .padding(.top, 15) // Padding from the top edge
         .padding(.bottom) // Ensure bottom padding for spacing
         .frame(width: 80, height: 120)
         .background(Color(.systemGray5)) // Background color similar to screenshot
         .cornerRadius(10)
     }
 }


struct StoryThumbnail: View {
    let imageName: String

    var body: some View {
        // Use a placeholder color/image for the story background
        ZStack {
             Color(.systemGray4) // Placeholder background
             // If you had actual images, you'd load them here
             // Image(imageName).resizable().scaledToFill()
             Text("Story") // Placeholder text
                 .foregroundColor(.white)
                 .font(.caption)

        }
        .frame(width: 80, height: 120)
        .cornerRadius(10)
        .overlay( // Add a subtle border if desired
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
        )
    }
}

struct TabBarSection: View {
    @Binding var selectedTab: StoryInsightsView.Tab
    @Namespace private var namespace // Namespace for animation

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(title: "Viewers",
                         iconName: "eye",
                         isSelected: selectedTab == .viewers,
                         namespace: namespace) { // Pass namespace
                withAnimation(.spring()) {
                     selectedTab = .viewers
                }
            }

            TabBarButton(title: "Insights",
                         iconName: "chart.bar.xaxis",
                         isSelected: selectedTab == .insights,
                         namespace: namespace) { // Pass namespace
                 withAnimation(.spring()) {
                      selectedTab = .insights
                 }
            }
        }
        .padding(.horizontal) // Add padding if needed, adjust layout
        .frame(height: 50) // Define a height for the tab bar area
         // Removed the overlay here, underline handled within TabBarButton
    }
}

struct TabBarButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let namespace: Namespace.ID // Receive namespace
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) { // Use VStack for text/icon and underline
                HStack(spacing: 5) {
                    Image(systemName: iconName)
                    Text(title)
                        .fontWeight(.medium)
                }
                .foregroundColor(isSelected ? .blue : .secondary) // Use blue for selected

                // Underline Logic
                if isSelected {
                    Capsule()
                        .fill(Color.blue)
                        .frame(height: 3)
                        .matchedGeometryEffect(id: "underline", in: namespace) // Apply effect here
                } else {
                    Color.clear.frame(height: 3) // Placeholder for unselected
                }
            }
             .frame(maxWidth: .infinity) // Make buttons expand equally
             .contentShape(Rectangle()) // Ensure entire area is tappable
        }
        .buttonStyle(.plain) // Remove default button styling
    }
}


struct ViewersListSection: View {
    let viewers: [Viewer]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) { // Add spacing between header and list
            // Header: Viewer Count & Refresh Button
            HStack {
                Text("\(viewers.count) viewers")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    // Action for refresh
                    print("Refresh tapped")
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                         .labelStyle(.titleAndIcon) // Show both title and icon
                        .font(.system(size: 14)) // Slightly smaller font
                }
                .buttonStyle(.bordered) // A style similar to the screenshot
                .tint(.secondary) // Adjust tint color
                .controlSize(.small) // Make button smaller
            }
            .padding(.top) // Add padding above the header

            // List of Viewers
            ForEach(viewers) { viewer in
                ViewerRow(viewer: viewer)
            }
        }
        .padding(.bottom) // Add padding at the bottom of the list
    }
}

struct ViewerRow: View {
    let viewer: Viewer

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: viewer.profileImageName) // Use placeholder system image
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(viewer.name)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                if let source = viewer.source {
                    Text(source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer() // Pushes content left and button right

            Button {
                // Action for ellipsis button
                print("Options for \(viewer.name) tapped")
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Insights View Content NEW

struct InsightsViewContent: View {
    let uniqueAccountViews: Int
    @State private var showBanner: Bool = true // State to control banner visibility

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
             // 1. Dismissible Banner
             if showBanner {
                 DismissibleBannerView(showBanner: $showBanner)
                      .transition(.opacity.combined(with: .move(edge: .top))) // Add transition
             }

            // 2. "Seen by" Section
            SeenBySection(count: uniqueAccountViews)

             Spacer() // Pushes content upwards if needed, or fill space
        }
         .padding(.top) // Add padding at the top of the VStack if needed
    }
}

struct DismissibleBannerView: View {
     @Binding var showBanner: Bool

     var body: some View {
          HStack(alignment: .center, spacing: 10) {
               VStack(alignment: .leading, spacing: 2) {
                    Text("Instagram accounts are not included")
                         .font(.subheadline)
                         .fontWeight(.semibold)
                         .foregroundColor(.primary)
                    Text("You'll see insights about Facebook viewers here.")
                         .font(.caption)
                         .foregroundColor(.secondary)
               }
               Spacer() // Push button to the right
               Button {
                    withAnimation {
                         showBanner = false // Dismiss the banner
                    }
               } label: {
                    Image(systemName: "xmark")
                         .foregroundColor(.secondary)
                         .padding(8) // Increase tap area slightly
                         .background(Color.secondary.opacity(0.2)) // Subtle background like screenshot
                         .clipShape(Circle())
               }
          }
          .padding(.horizontal, 15) // Inner horizontal padding
          .padding(.vertical, 10) // Inner vertical padding
          .background(Color(.systemGray5)) // Background color for the banner
          .cornerRadius(10) // Rounded corners for the banner
     }
}


struct SeenBySection: View {
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Align content to the leading edge
            Text("Seen by")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            // Center the count and subtitle horizontally
            HStack {
                Spacer() // Push content to center
                VStack(alignment: .center, spacing: 5) { // Center the text vertically
                     Text("\(count)")
                             .font(.system(size: 48, weight: .bold)) // Large, bold font for the count
                             .foregroundColor(.primary)
                     Text("Unique accounts")
                         .font(.subheadline)
                         .foregroundColor(.secondary)
                 }
                Spacer() // Push content to center
            }
            .padding(.top, 10) // Add some space above the count
        }
        // Removed frame(maxWidth: .infinity) to allow leading alignment of "Seen by"
    }
}


// MARK: - Preview

struct StoryInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview Viewers Tab
        StoryInsightsView()
             .previewDisplayName("Viewers Tab")

        // Preview Insights Tab
         StoryInsightsView()
            .previewDisplayName("Insights Tab")
    }
}
