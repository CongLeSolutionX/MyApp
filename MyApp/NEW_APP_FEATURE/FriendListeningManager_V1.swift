//
//  FriendListeningSharing.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import SwiftUI
import Combine

// MARK: - Friend Listening Sync Manager
final class FriendListeningManager: ObservableObject {
    // Published property to update the UI when a friend match is found.
    @Published var friendListenedThisSong: Bool = false
    
    // A sample function that accepts a Spotify track ID and checks friend history.
    func checkIfFriendListened(to trackID: String) {
        // In a real implementation, replace the following pseudo-code
        // with network calls to your backend or direct Spotify API requests:
        
        // 1. Fetch friend’s recently played tracks (requires Friend's OAuth access permission)
        // 2. Compare received track IDs with the playing track ID.
        // Here, we simulate a match after a slight delay.
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Suppose we detected a match based on fetched data.
            let detectedMatch = Bool.random() // Replace with actual comparison logic
            DispatchQueue.main.async {
                self.friendListenedThisSong = detectedMatch
            }
        }
    }
}

// MARK: - Music Player View (Simplified)
struct MusicPlayerView: View {
    @StateObject private var friendListeningManager = FriendListeningManager()
    
    // Assume that currentTrackID comes from your current player state (using Spotify SDK or similar)
    let currentTrackID: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Your music player UI components (album art, controls, etc.)
            Text("Now Playing")
                .font(.largeTitle)
            // Image and other controls would be here
            
            // Notification Banner if the friend has listened to the track before.
            if friendListeningManager.friendListenedThisSong {
                HStack {
                    Image(systemName: "person.fill.checkmark")
                    Text("Your friend has listened to this track!")
                }
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: friendListeningManager.friendListenedThisSong)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Trigger the friend listening check when this view appears.
            friendListeningManager.checkIfFriendListened(to: currentTrackID)
        }
    }
}
