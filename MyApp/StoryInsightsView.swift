////
////  StoryInsightsView.swift
////  MyApp
////
////  Created by Cong Le on 4/5/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model (Placeholders)
//
//struct StoryPreview: Identifiable {
//    let id = UUID()
//    let imageName: String // Placeholder for image name/URL
//    let isAddButton: Bool = false
//}
//
//struct Viewer: Identifiable {
//    let id = UUID()
//    let name: String
//    let profileImageName: String // Placeholder for image name/URL
//    let source: String? = nil // Optional subtitle like "Instagram"
//}
//
//// MARK: - Main Content View
//
//struct StoryInsightsView: View {
//    @State private var selectedTab: Tab = .viewers
//    @State private var stories: [StoryPreview] = [
//        StoryPreview(imageName: "story_placeholder_1"),
//        StoryPreview(imageName: "story_placeholder_2")
//    ]
//    @State private var viewers: [Viewer] = [
//        Viewer(name: "Anh Tran", profileImageName: "person.crop.circle.fill"),
//        Viewer(name: "Khoa Le", profileImageName: "person.crop.circle.fill"),
//        Viewer(name: "Hoang Mai", profileImageName: "person.crop.circle.fill"),
//        Viewer(name: "Eric Nguyen", profileImageName: "person.crop.circle.fill"),
//        Viewer(name: "Yen Nhi Nguyen", profileImageName: "person.crop.circle.fill"),
//        Viewer(name: "Lan Giao", profileImageName: "person.crop.circle.fill"),
//        Viewer(name: "timmy.cuts", profileImageName: "person.crop.circle.fill")
//    ]
//
//    enum Tab {
//        case viewers
//        case insights
//    }
//
//    var body: some View {
//        NavigationView {
//            ScrollView(.vertical, showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 0) {
//                    // 1. Story Previews Section
//                    StoryPreviewSection(stories: stories)
//                        .padding(.top) // Add some top padding if needed below nav bar
//
//                    // 2. Tab Bar Section
//                    TabBarSection(selectedTab: $selectedTab)
//
//                    // Divider Line
//                    Rectangle()
//                         .frame(height: 0.5)
//                         .foregroundColor(Color(.systemGray4))
//
//
//                    // 3. Content based on Tab
//                    if selectedTab == .viewers {
//                        ViewersListSection(viewers: viewers)
//                            .padding(.horizontal) // Apply horizontal padding to the list section
//                    } else {
//                        // Placeholder for Insights View
//                        Text("Insights View Placeholder")
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .center)
//                    }
//                }
//            }
//            .background(Color(.systemBackground)) // Use system background for adaptability
//            .navigationBarTitleDisplayMode(.inline) // Avoid large titles
//            .toolbar {
//                // Navigation Bar Items
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        // Action for globe button
//                        print("Globe tapped")
//                    } label: {
//                        Image(systemName: "globe")
//                            .foregroundColor(.primary) // Adjust color as needed
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    HStack(spacing: 15) {
//                        Button {
//                            // Action for history button
//                            print("History tapped")
//                        } label: {
//                            Image(systemName: "clock")
//                                .foregroundColor(.primary)
//                        }
//                        Button {
//                             // Action for close button
//                            print("Close tapped")
//                        } label: {
//                            Image(systemName: "xmark")
//                                .foregroundColor(.primary)
//                        }
//                    }
//                }
//            }
//            .preferredColorScheme(.dark) // Force dark mode as per screenshot
//        }
//    }
//}
//
//// MARK: - Subviews
//
//struct StoryPreviewSection: View {
//    let stories: [StoryPreview]
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 10) {
//                 // Prepend the "Add to Story" button
//                 AddToStoryButton()
//
//                ForEach(stories) { story in
//                    StoryThumbnail(imageName: story.imageName)
//                }
//            }
//            .padding(.horizontal) // Add horizontal padding to the HStack content
//            .padding(.bottom) // Add padding below the stories
//        }
//    }
//}
//
//struct AddToStoryButton: View {
//     var body: some View {
//         VStack {
//             Image(systemName: "plus.circle.fill")
//                 .font(.system(size: 30))
//                 .foregroundColor(.blue) // Or systemBlue
//             Spacer()
//              Text("Add to\nStory") // Use \n for newline
//                 .font(.caption)
//                 .foregroundColor(.primary)
//                 .multilineTextAlignment(.center) // Center align text
//                 .lineLimit(2) // Ensure it fits in two lines
//         }
//         .frame(width: 80, height: 120)
//         .background(Color(.systemGray5)) // Background color similar to screenshot
//         .cornerRadius(10)
//
//     }
// }
//
//
//struct StoryThumbnail: View {
//    let imageName: String
//
//    var body: some View {
//        // Use a placeholder color/image for the story background
//        ZStack {
//             Color(.systemGray4) // Placeholder background
//             // If you had actual images, you'd load them here
//             // Image(imageName).resizable().scaledToFill()
//             Text("Story") // Placeholder text
//                 .foregroundColor(.white)
//                 .font(.caption)
//
//        }
//        .frame(width: 80, height: 120)
//        .cornerRadius(10)
//        .overlay( // Add a subtle border if desired
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
//        )
//    }
//}
//
//struct TabBarSection: View {
//    @Binding var selectedTab: StoryInsightsView.Tab
//
//    var body: some View {
//        HStack(spacing: 0) {
//            TabBarButton(title: "Viewers",
//                         iconName: "eye",
//                         isSelected: selectedTab == .viewers) {
//                selectedTab = .viewers
//            }
//
//            TabBarButton(title: "Insights",
//                         iconName: "chart.bar.xaxis",
//                         isSelected: selectedTab == .insights) {
//                selectedTab = .insights
//            }
//        }
//        .padding(.horizontal) // Add padding if needed, adjust layout
//        .frame(height: 50) // Define a height for the tab bar area
//        .overlay(alignment: .bottom) {
//            // Indicator Line Logic
//            HStack {
//                 if selectedTab == .viewers {
//                     Capsule()
//                         .fill(Color.blue)
//                         .frame(height: 3)
//                         .matchedGeometryEffect(id: "underline", in: namespace)
//                     Spacer() // Push line left
//                 } else {
//                    Spacer() // Push line right
//                     Capsule()
//                         .fill(Color.blue)
//                         .frame(height: 3)
//                         .matchedGeometryEffect(id: "underline", in: namespace)
//
//                }
//            }
//            .frame(width: UIScreen.main.bounds.width / 2 - 30) // Adjust width as needed
//            .padding(.horizontal, 15) // Adjust padding to center
//            .animation(.spring(), value: selectedTab) // Add animation
//        }
//    }
//    @Namespace private var namespace // Namespace for animation
//}
//
//struct TabBarButton: View {
//    let title: String
//    let iconName: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 5) {
//                Image(systemName: iconName)
//                Text(title)
//                    .fontWeight(.medium)
//            }
//            .foregroundColor(isSelected ? .blue : .secondary) // Use blue for selected
//            .frame(maxWidth: .infinity) // Make buttons expand equally
//            .frame(height: 50) // Ensure consistent height
//        }
//        .buttonStyle(.plain) // Remove default button styling
//    }
//}
//
//
//struct ViewersListSection: View {
//    let viewers: [Viewer]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) { // Add spacing between header and list
//            // Header: Viewer Count & Refresh Button
//            HStack {
//                Text("\(viewers.count) viewers")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                Spacer()
//                Button {
//                    // Action for refresh
//                    print("Refresh tapped")
//                } label: {
//                    Label("Refresh", systemImage: "arrow.clockwise")
//                         .labelStyle(.titleAndIcon) // Show both title and icon
//                        .font(.system(size: 14)) // Slightly smaller font
//                }
//                .buttonStyle(.bordered) // A style similar to the screenshot
//                .tint(.secondary) // Adjust tint color
//                .controlSize(.small) // Make button smaller
//            }
//            .padding(.top) // Add padding above the header
//
//            // List of Viewers
//            ForEach(viewers) { viewer in
//                ViewerRow(viewer: viewer)
//                // Add divider if desired, but screenshot doesn't explicitly show them between rows
//                 // Divider().padding(.leading, 60) // Indent divider
//            }
//        }
//        .padding(.bottom) // Add padding at the bottom of the list
//    }
//}
//
//struct ViewerRow: View {
//    let viewer: Viewer
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: viewer.profileImageName) // Use placeholder system image
//                .resizable()
//                .scaledToFit()
//                .frame(width: 44, height: 44)
//                .clipShape(Circle())
//                 // You might add an overlay for online status or story ring if needed
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(viewer.name)
//                    .font(.subheadline)
//                    .fontWeight(.regular)
//                    .foregroundColor(.primary)
//                if let source = viewer.source {
//                    Text(source)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//            }
//
//            Spacer() // Pushes content left and button right
//
//            Button {
//                // Action for ellipsis button
//                print("Options for \(viewer.name) tapped")
//            } label: {
//                Image(systemName: "ellipsis")
//                    .foregroundColor(.secondary)
//            }
//            .buttonStyle(.plain)
//        }
//    }
//}
//
//
//// MARK: - Preview
//
//struct StoryInsightsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StoryInsightsView()
//            .preferredColorScheme(.dark)
//    }
//}
