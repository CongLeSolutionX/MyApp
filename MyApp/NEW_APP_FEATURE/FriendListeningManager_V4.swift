////
////  FriendListeningManager_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//import SwiftUI
//
//struct FriendListeningIndicator: View {
//    let isLiveListening: Bool
//    let lastListenDate: Date?
//    let friendName: String
//    
//    var body: some View {
//        if isLiveListening {
//            Label("🎧 \(friendName) is listening now", systemImage: "person.3.fill")
//                .padding(6)
//                .background(Color.green.opacity(0.2))
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//        } else if let date = lastListenDate {
//            Text("💾 Last listened: \(date, formatter: dateFormatter)")
//                .font(.caption2)
//                .padding(4)
//                .background(Color.orange.opacity(0.2))
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//        }
//    }
//}
//
//struct AlbumItem {
//    
//}
//
//struct AlbumImageView : View {
//  var body: some View {
//      EmptyView()
//    }
//}
//
//
//// Usage in Song Detail View
//struct SongDetailView: View {
//    let song: AlbumItem
//    // Simulated data, integrate with backend for real
//    var friendListeningStatus: (Bool, Date?, String) = (true, nil, "Alice") // mock
//    
//    var body: some View {
//        VStack {
//            // Existing song info UI
//            AlbumImageView(url: song.bestImageURL)
//            Text(song.name).font(.title)
//            Text(song.formattedArtists).font(.subheadline)
//            // Friend indicator
//            FriendListeningIndicator(
//                isLiveListening: friendListeningStatus.0,
//                lastListenDate: friendListeningStatus.1,
//                friendName: friendListeningStatus.2
//            )
//            // Play button with interaction
//            Button("Play") {
//                // Check if friend listening
//                if friendListeningStatus.0 {
//                    // Show alert or notification
//                    // e.g., Sheet or Toast "Friend is listening now! Join?"
//                }
//            }
//        }
//        .padding()
//    }
//}
