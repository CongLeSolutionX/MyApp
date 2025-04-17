//
//  FriendListeningManager_V6.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import SwiftUI

// --- Placeholder Data Structures ---
struct FriendListeningInfo: Identifiable, Hashable {
    let id = UUID()
    let friendName: String
    let friendProfilePicUrl: URL? // Placeholder
    let status: ListeningStatus
    let lastListened: Date? // Optional timestamp
}

enum ListeningStatus: String, Hashable {
    case listeningNow = "Listening Now"
    case listenedRecently = "Listened Recently" // e.g., Today/This week
    case listens = "Listens to this track"
}

// --- UI Components ---

// 1. Subtle Indicator on Now Playing Screen
struct SocialIndicatorView: View {
    // This data would come from a ViewModel updated via API
    let primaryFriend: FriendListeningInfo?
    let otherFriendsCount: Int
    
    var body: some View {
        // Only show if there's relevant activity
        if let friend = primaryFriend {
            HStack(spacing: 4) {
                Image(systemName: "headphones.circle.fill") // Or custom icon
                    .foregroundColor(.green) // Spotify green
                
                // Optionally load Friend's Profile Pic
                // AsyncImage(url: friend.friendProfilePicUrl)... .clipShape(Circle())
                
                Text(indicatorText(friend: friend, count: otherFriendsCount))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.secondary.opacity(0.1))
            .clipShape(Capsule())
            // Add tap gesture later to show detail view
        } else {
            EmptyView() // Don't show anything if no relevant friends
        }
    }
    
    private func indicatorText(friend: FriendListeningInfo, count: Int) -> String {
        var text = ""
        switch friend.status {
        case .listeningNow:
            text = "\(friend.friendName) is listening now"
            if count > 0 { text += " & \(count) others" }
        case .listenedRecently:
            text = "\(friend.friendName) listened recently"
            if count > 0 { text += " & \(count) others" }
        case .listens:
            let total = count + 1 // Friend + others
            text = "\(total) friend\(total > 1 ? "s":"") listen" // Simplified if not recent/now
        }
        return text
    }
}

// 2. Detailed View (Example: Modal Sheet Content)
struct FriendListeningDetailView: View {
    let trackName: String
    let artistName: String
    // This data would come from a ViewModel / loaded via API
    let friendsInfo: [FriendListeningInfo]
    
    var body: some View {
        NavigationView { // Often presented modally, may need its own Nav view
            VStack(alignment: .leading) {
                // Header (Optional: Album Art?)
                Text("Friends & \(trackName)")
                    .font(.title2).bold()
                    .padding(.bottom, 5)
                Text("by \(artistName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                // List of Friends
                List(friendsInfo) { info in
                    HStack {
                        // Friend Profile Pic
                        // AsyncImage(url: info.friendProfilePicUrl)... frame(width: 40, height: 40)...
                        
                        VStack(alignment: .leading) {
                            Text(info.friendName).font(.headline)
                            Text(info.status.rawValue).font(.caption).foregroundColor(.secondary)
                            // Optionally add formatted date:
                            // if let date = info.lastListened { Text(date, style: .relative)... }
                        }
                        Spacer()
                        // Optional: Add action button (e.g., message icon)
                    }
                }
                .listStyle(.plain)
                
                Text("Only friends who've enabled listening activity sharing are shown.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding()
            }
            .padding()
            .navigationBarTitle("Shared Vibes", displayMode: .inline)
            // Add dismiss button if presented modally
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // Dismiss the view
                        // presentationMode.wrappedValue.dismiss() // Need @Environment(\.presentationMode)
                    }
                }
            }
        }
    }
}

// --- Previews ---
struct SocialIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SocialIndicatorView(
                primaryFriend: FriendListeningInfo(friendName: "Alice", friendProfilePicUrl: nil, status: .listeningNow, lastListened: Date()),
                otherFriendsCount: 2
            )
            
        }
    }
}
