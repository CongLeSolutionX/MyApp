//
//  FriendListeningManager_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import SwiftUI

// MARK: - Friend Model
struct Friend: Identifiable, Hashable {
    let id: String
    let name: String
    let avatarURL: URL?
}

// MARK: - Friend Listening Service (Mock Implementation)
class FriendListeningService {
    // In a real implementation, this method would hit a server or query a persistent store
    func checkIfFriendListened(to trackID: String, completion: @escaping (Friend?) -> Void) {
        // For demonstration, we simulate a delay and then return a friend if the track ID matches a sample
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // Assume "sampleTrackID" is a predetermined ID known from friend history
            let sampleTrackID = "6KJgxZYve2dbchVjw3MxBQ"
            if trackID == sampleTrackID {
                let friend = Friend(id: "friend1", name: "Alex", avatarURL: URL(string: "https://example.com/alex_avatar.png"))
                completion(friend)
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: - Playback View with Friend Listening Indicator
struct PlaybackView: View {
    // This represents the track currently playing (could be part of a larger playback manager)
    let currentTrackID: String
    @State private var friendWhoListened: Friend?
    @State private var isLoading: Bool = false
    
    // Instantiate the service (could be injected via EnvironmentObject)
    let friendService = FriendListeningService()
    
    var body: some View {
        VStack(spacing: 20) {
            // Placeholder Playback UI (e.g., player controls, track info, etc.)
            Text("Now Playing Track \(currentTrackID)")
                .font(.title2)
                .padding()
            
            // If a friend was found, show the indicator
            if let friend = friendWhoListened {
                HStack(alignment: .center, spacing: 10) {
                    // Friend Avatar
                    AsyncImage(url: friend.avatarURL) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else if phase.error != nil {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        } else {
                            ProgressView()
                                .frame(width: 40, height: 40)
                        }
                    }
                    
                    // Notification Text
                    Text("Your friend \(friend.name) listened to this song!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .transition(.opacity.animation(.easeInOut))
            }
            
            // Other playback controls might be here...
            Spacer()
        }
        .onAppear {
            isLoading = true
            friendService.checkIfFriendListened(to: currentTrackID) { friend in
                DispatchQueue.main.async {
                    self.friendWhoListened = friend
                    isLoading = false
                }
            }
        }
        .padding()
        .navigationTitle("Now Playing")
    }
}

// MARK: - Preview
struct PlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlaybackView(currentTrackID: "6KJgxZYve2dbchVjw3MxBQ")
        }
    }
}
