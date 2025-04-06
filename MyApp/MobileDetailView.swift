//
//  MobileDetailView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// MARK: - Data Models (Placeholders)

struct ListItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
}

struct NowPlayingInfo {
    let title: String
    let artist: String
}

// MARK: - Main Content View

struct MobileDetailView: View {
    // Placeholder data
    let listItems = [
        ListItem(title: "Title", description: "Description duis aute irure dolor in reprehenderit in voluptate velit.", duration: "23 min"),
        ListItem(title: "Title", description: "Description duis aute irure dolor in reprehenderit in voluptate velit.", duration: "23 min"),
        ListItem(title: "Title", description: "Description duis aute irure dolor in reprehenderit in voluptate velit.", duration: "23 min")
    ]

    let nowPlaying = NowPlayingInfo(title: "Title", artist: "Artist")

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        TopSectionView()
                        DescriptionView()
                        SectionHeaderView(title: "Section title")
                        ListView(items: listItems)
                        // Add Spacer to push content up when player is visible
                        Spacer(minLength: 80) // Adjust height based on player bar
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("Title")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button {
                        // Back action
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary) // Use primary color for adaptability
                    },
                    trailing: HStack {
                        Button {
                            // Bookmark action
                        } label: {
                            Image(systemName: "bookmark")
                                .foregroundColor(.primary)
                        }
                        Button {
                            // More options action
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.primary)
                        }
                    }
                )

                BottomPlayerBarView(info: nowPlaying)
                    .background(.regularMaterial) // Add a material background for visual separation
            }
        }
    }
}

// MARK: - Subviews

struct PlaceholderImageView: View {
    var size: CGFloat = 80
    var cornerRadius: CGFloat = 12

    var body: some View {
        // Using system gray for placeholder effect
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.3))
            .frame(width: size, height: size)
            // Adding placeholder shapes inside
            .overlay(
                ZStack {
                    Triangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: size * 0.3, height: size * 0.3)
                        .offset(y: -size * 0.15)
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: size * 0.25, height: size * 0.25)
                        .offset(x: size * 0.15, y: size * 0.2)
                    Rectangle()
                         .fill(Color.gray.opacity(0.6))
                         .frame(width: size * 0.25, height: size * 0.25)
                         .offset(x: -size * 0.15, y: size * 0.2)
                }
            )
    }
}

// Helper Shape for Placeholder
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct TopSectionView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            PlaceholderImageView(size: 100, cornerRadius: 16)

            VStack(alignment: .leading, spacing: 8) {
                Text("Headline")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("supporting text")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer() // Pushes button down
                Button {
                    // Download action
                } label: {
                    Text("Download")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.purple) // Using system purple
                        .cornerRadius(20)
                }
            }
            // Make VStack take available space to align button correctly
            .frame(height: 100)
        }
    }
}

struct DescriptionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Published date")
                .font(.caption)
                .foregroundColor(.gray)

            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                .font(.body)

            Text("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                .font(.body)
        }
    }
}

struct SectionHeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "arrow.right")
                .foregroundColor(.gray)
        }
        .padding(.top) // Add some space before the section
    }
}

struct ListView: View {
    let items: [ListItem]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(items) { item in
                ListItemView(item: item)
            }
        }
    }
}

struct ListItemView: View {
    let item: ListItem

    var body: some View {
        HStack(spacing: 12) {
            PlaceholderImageView(size: 70) // Smaller placeholder for list

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)

                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2) // Limit description lines

                HStack(spacing: 6) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.gray)
                    Text("Today • \(item.duration)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                 .padding(.top, 2)
            }

            Spacer() // Pushes play button to the right

            Image(systemName: "play.fill")
                .foregroundColor(.primary) // Adaptable color
                .font(.title3)
        }
    }
}

struct BottomPlayerBarView: View {
    let info: NowPlayingInfo

    var body: some View {
        HStack(spacing: 12) {
            PlaceholderImageView(size: 48, cornerRadius: 8)

            VStack(alignment: .leading) {
                Text(info.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(info.artist)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 20) {
                Button {
                    // Pause action
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Button {
                    // Next track action
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity) // Take full width
        // Height can be adaptive or fixed
        .frame(height: 70)
    }
}

// MARK: - Preview

struct MobileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MobileDetailView()
    }
}
