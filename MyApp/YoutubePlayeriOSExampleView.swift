//
//  YoutubePlayeriOSExampleView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//


import SwiftUI

// Main container view mirroring the UITabBarController
struct YoutubePlayeriOSExampleView: View {
    var body: some View {
        TabView {
            // First Tab: Single Video Player
            SingleVideoView()
                .tabItem {
                    Label("Single Video", systemImage: "video") // Using SF Symbols for icons
                }
            
            // Second Tab: Playlist Player
            PlaylistView()
                .tabItem {
                    Label("Playlist", systemImage: "list.bullet") // Using SF Symbols for icons
                }
        }
    }
}

// View representing the SingleVideoViewController's layout
struct SingleVideoView: View {
    // State variables to mimic UI element states
    @State private var sliderValue: Double = 0.5
    @State private var statusText: String = "Status: Ready"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Placeholder for the Video Player View (Blue rectangle in storyboard)
            Rectangle()
                .fill(Color.blue)
                .frame(height: 200) // Give it a fixed height for demo purposes
                .overlay(
                    Text("Video Player Area")
                        .foregroundColor(.white)
                )
            
            // Controls Section
            VStack(alignment: .leading) {
                Text("Controls:")
                    .font(.headline)
                
                HStack {
                    Button("Play") {
                        print("Play button tapped - Single")
                        statusText = "Status: Playing"
                    }
                    Button("Pause") {
                        print("Pause button tapped - Single")
                        statusText = "Status: Paused"
                    }
                    Button("Stop") {
                        print("Stop button tapped - Single")
                        statusText = "Status: Stopped"
                        sliderValue = 0.0
                    }
                    Spacer() // Push buttons to the left
                }
                
                Text(statusText) // Status Text View
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Slider(value: $sliderValue, in: 0...1) { // Slider
                    Text("Timeline") // Accessibility label
                } onEditingChanged: { editing in
                    if !editing {
                        print("Slider value set to: \(sliderValue)")
                        // Action on slider release maybe?
                    }
                }
            }
            .padding(.horizontal) // Add padding to the controls section
            
            Spacer() // Push controls section up
        }
        .navigationTitle("Single Video Demo") // Corresponds to the Navigation Item title (if it were embedded)
        // If this view were intended to be pushed onto a NavigationView,
        // the title would be set using .navigationTitle()
    }
}

// View representing the PlaylistViewController's layout
struct PlaylistView: View {
    // State variables
    @State private var statusText: String = "Status: Ready"
    @State private var currentVideoIndex: Int = 0
    let playlistCount = 5 // Example playlist size
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Placeholder for the Video Player View
            Rectangle()
                .fill(Color.blue)
                .frame(height: 200)
                .overlay(
                    Text("Playlist Player Area - Video \(currentVideoIndex + 1)")
                        .foregroundColor(.white)
                )
            
            // Controls Section
            VStack(alignment: .leading) {
                Text("Control:")
                    .font(.headline)
                
                HStack {
                    Button("Play") {
                        print("Play button tapped - Playlist")
                        statusText = "Status: Playing Video \(currentVideoIndex + 1)"
                    }
                    Button("Pause") {
                        print("Pause button tapped - Playlist")
                        statusText = "Status: Paused Video \(currentVideoIndex + 1)"
                    }
                    Button("Stop") {
                        print("Stop button tapped - Playlist")
                        statusText = "Status: Stopped"
                    }
                    Spacer()
                }
                
                Text("Status:")
                    .font(.headline)
                    .padding(.top, 10)
                
                HStack {
                    Button("Previous Video") {
                        print("Previous Video tapped")
                        if currentVideoIndex > 0 {
                            currentVideoIndex -= 1
                            statusText = "Status: Loaded Video \(currentVideoIndex + 1)"
                        }
                    }
                    .disabled(currentVideoIndex == 0) // Disable if first video
                    
                    Button("Next Video") {
                        print("Next Video tapped")
                        if currentVideoIndex < playlistCount - 1 {
                            currentVideoIndex += 1
                            statusText = "Status: Loaded Video \(currentVideoIndex + 1)"
                        }
                    }
                    .disabled(currentVideoIndex == playlistCount - 1) // Disable if last video
                    Spacer()
                }
                
                Text(statusText) // Status Text View
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                
            }
            .padding(.horizontal) // Add padding to the controls section
            
            Spacer() // Push controls up
        }
        .navigationTitle("Playlist Demo") // Corresponds to the Navigation Item title
    }
}

// Preview Provider for Xcode Previews
#Preview {
    YoutubePlayeriOSExampleView()
}
