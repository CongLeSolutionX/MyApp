//
//  SpotifyHomeView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// --- Data Model ---
struct Song: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let artworkName: String // Use system image names for simplicity here, or actual asset names
    var isPlaying: Bool = false // Basic state for demo
}

// --- Reusable Song Row View ---
struct SongRowView: View {
    let song: Song

    var body: some View {
        HStack(spacing: 15) {
            Image(song.artworkName) // Use actual image loading logic here
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipped() // Ensure image stays within bounds if aspect ratio doesn't match frame

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1) // Prevent wrapping

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1) // Prevent wrapping
            }

            Spacer() // Pushes the button to the right

            Button {
                // Action for ellipsis button
                print("More options for \(song.title)")
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .padding(.leading, 5) // Add some space before the button
            }
        }
        .padding(.vertical, 8) // Add padding top/bottom for spacing between rows
        // Set row background to clear to see the main background color
        .listRowBackground(Color.clear)
        // Remove default list row separators if desired
        // .listRowSeparator(.hidden)
    }
}

// --- Main Screen View ---
struct LikedSongsView: View {
    // Sample Data (Replace with actual data source)
    @State private var songs: [Song] = [
        Song(title: "Back In Time", artist: "Dim3nsion, Rama Duke", artworkName: "music.note.house.fill"),
        Song(title: "Ngày Đẹp Trời Để Nói Chia Tay", artist: "Lou Hoàng", artworkName: "music.mic"),
        Song(title: "Faith", artist: "AVALAN ROKSTON, Avalan, Rokston", artworkName: "moon.stars.fill"),
        Song(title: "Young And Beautiful", artist: "Lana Del Rey", artworkName: "sparkles"),
        Song(title: "Let Her Go", artist: "lost., Honeyfox, Pop Mage", artworkName: "figure.wave"),
        Song(title: "Rest (with Sasha Alex Sloan)", artist: "Dean Lewis, Sasha Alex Sloan", artworkName: "figure.walk"),
        Song(title: "Phân Bội Chính Mình - Lofi", artist: "Quân A.P", artworkName: "headphones"),
        Song(title: "Rất Lâu Rồi Mới Khóc", artist: "Minh Vương M4U, Tuấn Phương, ACV", artworkName: "person.2.fill"),
        Song(title: "... Rất Lâu Rồi Mới Khóc - Live Band Versi...", artist: "Quốc Thiên", artworkName: "music.quarternote.3", isPlaying: true), // Example of playing state
        Song(title: "Cho Nó Vui Trở Lại", artist: "Hiderway, Quỳnh Bei", artworkName: "waveform"),
        Song(title: "Khó Về Nụ Cười (feat. Du Uyen)", artist: "DatKaa, Du Uyen", artworkName: "face.smiling"),
        Song(title: "The Masked Singer Lâm Bảo Ngọc", artist: "The Masked Singer", artworkName: "theatermasks.fill")
    ]

    // State for the mini player (simplified)
    @State private var currentPlayingSong: Song? = Song(title: "... Rất Lâu Rồi Mới Khóc - Live Band Versi...", artist: "Quốc Thiên", artworkName: "music.quarternote.3", isPlaying: true)

    var body: some View {
        NavigationView {
            // Main container allowing layerin
            GeometryReader { geometry in // Use GeometryReader to get safe area insets
                VStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        // Song List
                        List {
                            // Add some space at the top so the first item isn't under the play button area
                            Color.clear.frame(height: 30).listRowBackground(Color.clear)

                            ForEach(songs) { song in
                                SongRowView(song: song)
                                    // Add tap gesture to the row itself
                                    .onTapGesture {
                                        print("Tapped on song: \(song.title)")
                                        currentPlayingSong = song // Update mini player on tap
                                    }
                            }
                        }
                        .listStyle(.plain) // Removes default List styling/backgrounds
                        .background(Color.black) // Background for the list area

                        // Floating Play Button
                        Button {
                            // Action for floating play button
                            print("Floating play button tapped")
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.title2)
                                .foregroundColor(.black)
                                .padding() // Inner padding for the icon
                        }
                        .background(Color.green)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding(.trailing, 20) // Position from the right edge
                        .padding(.top, 10)      // Position from the top edge
                    } // End ZStack

                    // --- Mini Player Placeholder ---
                    // In a real app, this would be a more complex reusable view
                    if let playingSong = currentPlayingSong {
                        MiniPlayerView(song: playingSong)
                            .background(Color(white: 0.15)) // Dark background for mini player
                            .frame(height: 60) // Typical height for a mini player
                    }

                    // --- Tab Bar ---
                    CustomTabView()
                        // Add slight separation line if needed
                         .overlay(Divider().background(Color.gray), alignment: .top)

                } // End VStack
                .background(Color.black.edgesIgnoringSafeArea(.bottom)) // Ensure background covers tab bar area too
                .navigationTitle("Liked Songs")
                .navigationBarTitleDisplayMode(.inline) // Center title
                .navigationBarBackButtonHidden(false) // Show standard back button if needed
                .toolbarColorScheme(.dark, for: .navigationBar) // Make status bar items white
                .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar) // Darker nav bar bg
                .toolbarBackground(.visible, for: .navigationBar)
                 // Add custom back button if needed (replace default)
                 .toolbar {
                     ToolbarItem(placement: .navigationBarLeading) {
                         Button {
                             // Handle back action
                             print("Custom back button tapped")
                         } label: {
                             Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                         }
                     }
                 }

            }// End Geometry Reader
             .ignoresSafeArea(.keyboard, edges: .bottom) // Prevents keyboard overlap issues

        }
        .accentColor(.white) // Sets default tint color for controls like back button

    }
}

// --- Mini Player View (Simplified) ---
struct MiniPlayerView: View {
    let song: Song

    var body: some View {
        HStack {
            Image(song.artworkName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipped()
                .padding(.leading)

            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.leading, 5)

            Spacer()

            // Placeholder for device button
            Button { } label: {
                 Image(systemName: "hifispeaker.and.appletv") // Example icon
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 5)

            Button {
                // Play/Pause action
            } label: {
                Image(systemName: song.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .padding(.trailing)
        }
        // Add a thin progress bar indicator if needed
         .overlay(
             GeometryReader { geo in
                 Rectangle()
                     .fill(Color.gray)
                     .frame(height: 1.5)
                 Rectangle()
                     .fill(Color.white)
                     .frame(width: geo.size.width * 0.6, height: 1.5) // Example progress
             }
             .frame(height: 1.5)
             .offset(y: -30) // Position it just above the content
             , alignment: .top
        )
    }
}

// --- Custom Tab Bar View ---
struct CustomTabView: View {
    @State private var selectedTab: Int = 0 // Track selected tab

    var body: some View {
        HStack {
            Spacer()
            TabItem(iconName: "house.fill", label: "Home", isSelected: selectedTab == 0) { selectedTab = 0 }
            Spacer()
            TabItem(iconName: "magnifyingglass", label: "Search", isSelected: selectedTab == 1) { selectedTab = 1 }
            Spacer()
            TabItem(iconName: "books.vertical.fill", label: "Your Library", isSelected: selectedTab == 2) { selectedTab = 2 }
            Spacer()
            TabItem(iconName: "plus.app", label: "Create", isSelected: selectedTab == 3) { selectedTab = 3 }
            Spacer()
        }
        .padding(.top, 8)
        .frame(height: 50) // Standard tab bar height approx
        .background(Color.black.opacity(0.9)) // Slightly translucent black bg
    }
}

struct TabItem: View {
    let iconName: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 22)
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .white : .gray) // Highlight selected tab
        }
    }
}

// --- Preview ---
#Preview {
    LikedSongsView()
        .preferredColorScheme(.dark) // Ensure preview uses dark mode
}
