//
//  SpotifyView.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI

// MARK: - Main Content View (Entry Point with Tab Bar)

struct SpotifyView: View {
    init() {
        // Customize Tab Bar Appearance (Optional but helps match the style)
        UITabBar.appearance().barTintColor = UIColor.black // Background color
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray // Unselected icon/text color
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                // Apply preferred color scheme if needed consistently
                 .preferredColorScheme(.dark)

            Text("Search Screen")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .preferredColorScheme(.dark)

            Text("Your Library Screen")
                .tabItem {
                    Label("Your Library", systemImage: "books.vertical.fill")
                }
                .preferredColorScheme(.dark)

            Text("Premium Screen")
                .tabItem {
                    Label("Premium", systemImage: "spotify.logo") // Requires custom logo or SF Symbol alternative
                }
                .preferredColorScheme(.dark)
        }
        // Set the accent color for selected tab items
        .accentColor(.white)
    }
}

// MARK: - Home Screen Structure

struct HomeView: View {
    var body: some View {
        NavigationView { // Added NavigationView for the top bar title/button area
            ZStack(alignment: .bottom) {
                // Main Scrolling Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HomeHeaderView()
                        GreetingGridView()
                        MoreLikeSectionView(artistName: "CongLeSolutionX")
                        AdBannerView()
                        // Add more sections as needed...

                        // Spacer to push content up when scrolling ends,
                        // leaving space for the player bar
                        Spacer(minLength: 80) // Adjust height based on PlayerBarView
                    }
                    .padding(.horizontal)
                }
                // Make scroll view background black
                .background(Color.black.edgesIgnoringSafeArea(.all))
                // Hide the default Navigation Bar if HomeHeaderView manages it
                 .navigationBarHidden(true)

                // Mini Player Bar (Overlay)
                PlayerBarView()
                 .padding(.bottom, 49) // Adjust padding to sit above the TabBar (standard height ~49-50)
            }
            // Ensure the entire background, including safe areas maybe, is black
             .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        // Apply modifier to the NavigationView itself if needed
        .navigationViewStyle(StackNavigationViewStyle()) // Use Stack style
        .accentColor(.white) // Ensure back buttons etc. are white
    }
}

// MARK: - Home Screen Components

struct HomeHeaderView: View {
    var body: some View {
        HStack {
            Text("Good morning")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button {
                // Action for settings
            } label: {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.top) // Add padding from the top safe area
    }
}

struct GreetingGridView: View {
    // Sample data structure
    struct GridItemData: Identifiable {
        let id = UUID()
        let imageName: String? // Use nil for color placeholder
        let color: Color?
        let title: String
    }

    let gridItemsData = [
        GridItemData(imageName: nil, color: .blue, title: "A Pandemic Update: The V..."),
        GridItemData(imageName: nil, color: .pink, title: "Discover Weekly"),
        GridItemData(imageName: nil, color: .gray, title: "Daily Mix 2"),
        GridItemData(imageName: nil, color: .red, title: "Reply All"),
        GridItemData(imageName: nil, color: .purple, title: "Lorem"),
        GridItemData(imageName: nil, color: .indigo, title: "Inside Intercom p...")
    ]

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(gridItemsData) { item in
                GridItemView(imageName: item.imageName, color: item.color, title: item.title)
            }
        }
    }
}

struct GridItemView: View {
    let imageName: String?
    let color: Color?
    let title: String

    var body: some View {
        HStack(spacing: 0) {
            if let imgName = imageName {
                Image(imgName) // Placeholder for actual image loading
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipped()
            } else if let bgColor = color {
                 bgColor // Use color as placeholder
                    .frame(width: 50, height: 50)
            }

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .lineLimit(2)

            Spacer() // Pushes text to the left
        }
        .background(Color.gray.opacity(0.3)) // Background of the grid item cell
        .cornerRadius(4)
        .frame(height: 50) // Fixed height for grid items
    }
}

struct MoreLikeSectionView: View {
    let artistName: String

    // Sample data
    struct AlbumData: Identifiable {
        let id = UUID()
        let imageName: String?
        let color: Color?
        let title: String
    }
    let albums = [
        AlbumData(imageName: nil, color: .purple, title: "Low-Key"),
        AlbumData(imageName: nil, color: .orange, title: "Wildfire"),
        AlbumData(imageName: nil, color: .teal, title: "Another Album"),
        AlbumData(imageName: nil, color: .yellow, title: "Sampler"),
    ]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Placeholder for artist image
                Circle()
                    .fill(.gray)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading) {
                    Text("MORE LIKE")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(artistName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(albums) { album in
                        AlbumCoverView(imageName: album.imageName, color: album.color, title: album.title)
                    }
                }
            }
        }
    }
}

struct AlbumCoverView: View {
    let imageName: String?
    let color: Color?
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            if let imgName = imageName {
                 Image(imgName) // Placeholder for actual image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 140)
                    .background(.secondary) // Background while loading/placeholder
                    .cornerRadius(4)
            } else if let bgColor = color {
                bgColor
                    .frame(width: 140, height: 140)
                    .cornerRadius(4)
                     // Overlay the title onto the color placeholder
                    .overlay(
                        Text(title)
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(5),
                        alignment: .bottomLeading
                    )
            } else {
                Rectangle() // Default placeholder
                     .fill(.gray.opacity(0.5))
                     .frame(width: 140, height: 140)
                    .cornerRadius(4)
                     .overlay(
                        Text(title)
                            .foregroundColor(.white)
                            .font(.subheadline),
                            alignment: .center
                    )
            }

            // Title below image if not overlaid
            // Text(title)
            //     .font(.caption)
            //     .foregroundColor(.white)
            //     .frame(width: 140, alignment: .leading)
            //     .lineLimit(1)

        }
    }
}

struct AdBannerView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
               Text("Get 20% off your first bag. Start your next journey today.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            Spacer()
            Button("Buy now") {
                // Action for Buy Now
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(20)
            .font(.system(size: 14, weight: .bold))
        }
        .padding()
        .background(Color.pink) // Ad background color
        .cornerRadius(8)
    }
}

struct PlayerBarView: View {
    var body: some View {
        HStack(spacing: 10) {
            // Placeholder for album art
            Rectangle()
                .fill(.gray)
                .frame(width: 40, height: 40)
                .cornerRadius(4)

            VStack(alignment: .leading) {
                Text("Advertisement") // Or Song Title
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text("Grindstones") // Or Artist Name
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Placeholder for device/cast icon
            Image(systemName: "hifispeaker.and.appletv")
                 .foregroundColor(.white)
                 .font(.title3)

            // Placeholder for Play/Pause
            Image(systemName: "pause.fill")
                .foregroundColor(.white)
                .font(.title3)
        }
        .padding(.horizontal)
        .frame(height: 60)
        .background(Color.gray.opacity(0.5)) // Player bar background
        // Add slight rounded corners if needed
        // .cornerRadius(8)
    }
}

// MARK: - Playlist/Detail Screen Structure (Example - not directly linked in TabView)

struct PlaylistView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                SpotifyView_PlaylistHeaderView()
                PlaylistMetadataView()
                PlaylistActionButtonsView()

                Button("Preview") {
                    // Action
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                 .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                 .background(Color.black) // Button background
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1) // Border like screenshot
                )
                .clipShape(Capsule())
                .padding(.horizontal, 60) // Give horizontal padding

                SongListViewPreview()
                RecentAdvertisersView()
            }
            .padding(.horizontal)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
         // Embed in NavigationView if needed for back button etc.
         // .navigationTitle("Playlist Details") // Or hide title and use custom header
         // .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Playlist Screen Components

struct SpotifyView_PlaylistHeaderView: View {
    var body: some View {
        VStack {
            // Placeholder for large artwork
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.pink.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                 .overlay(
                     VStack {
                         Spacer()
                        Text("Your Discover Weekly")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                     }
                 )
                .aspectRatio(1.0, contentMode: .fit) // Square aspect ratio
                .cornerRadius(8)
                .padding(.top) // Add padding from top

            Text("Soundtrack your gaming with these atmospheric beats.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 5)
        }
         .frame(maxWidth: .infinity) // Take full width
    }
}

struct PlaylistMetadataView: View {
    var body: some View {
        HStack {
            Image(systemName: "spotify.logo") // Placeholder - Use actual logo if available
                 .foregroundColor(.white)
            Text("Spotify")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Spacer() // Pushes metadata to the left if needed
        }
        Text("209,907 likes • 4h 54m")
            .font(.system(size: 12))
            .foregroundColor(.gray)
    }
}

struct PlaylistActionButtonsView: View {
    var body: some View {
        HStack(spacing: 25) {
            Button {} label: { Image(systemName: "heart").foregroundColor(.gray) }
            Button {} label: { Image(systemName: "arrow.down.circle").foregroundColor(.gray) }
            Button {} label: { Image(systemName: "ellipsis").foregroundColor(.gray) }
            Spacer()
            Button {
                // Play Action
            } label: {
                ZStack {
                    Circle()
                         .fill(Color.green) // Spotify Green
                        .frame(width: 55, height: 55)
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
        }
        .font(.title2) // Apply default size to icons
    }
}

struct SongListViewPreview: View {
    var body: some View {
        // Simplified preview - a real implementation would use a List or LazyVStack
        VStack(alignment: .leading) {
             Text("Lindstrøm Blinded By The LEDs • Flume Tiny Cities • Fern Kinney Baby Let Me Kiss You • Lindstrøm Closing Shot • Lindstrøm Midnight Girl • Robyn Indestructable • and more")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .lineSpacing(5) // Add line spacing for readability
        }
    }
}

struct RecentAdvertisersView: View {
    // Sample data
    struct AdvertiserData: Identifiable {
        let id = UUID()
        let iconName: String
        let text: String
    }
    let advertisers = [
        AdvertiserData(iconName: "cup.and.saucer.fill", text: "Grindstones\nFresh beans delivered to you each week."),
        AdvertiserData(iconName: "gamecontroller.fill", text: "Game On\nLevel up your setup."),
        AdvertiserData(iconName: "headphones", text: "Audio Bliss\n Immerse yourself."),
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent advertisers")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                 HStack(spacing: 15) {
                    ForEach(advertisers) { ad in
                        AdvertiserCardView(iconName: ad.iconName, text: ad.text)
                    }
                }
            }
        }
    }
}

struct AdvertiserCardView: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.white)
                 .frame(width: 40, height: 40) // Fixed size for icon area
                 .padding(.trailing, 5)

            VStack(alignment: .leading) {
                 Text(text) // Handles multiline text
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                     .lineLimit(2) // Limit to 2 lines
            }

            Spacer() // Push content left, button right

            Button("Learn more") {
                // Action
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(15)
             .font(.system(size: 12, weight: .bold))
        }
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
         .frame(width: 300) // Set a typical width for horizontal scroll items
    }
}

// MARK: - Preview Provider

struct SpotifyView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview the main tab view
        SpotifyView()

        // You can also preview individual screens if needed:
         // HomeView().preferredColorScheme(.dark)
         // PlaylistView().preferredColorScheme(.dark)
    }
}

// MARK: - Spotify Logo Placeholder (if needed)

extension Image {
    static let spotifyLogo = Image(systemName: "beats.headphones") // Use a relevant SF Symbol as placeholder
}
