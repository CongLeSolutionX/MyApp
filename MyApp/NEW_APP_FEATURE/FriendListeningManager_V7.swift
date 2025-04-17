//
//  FriendListeningManager_V7.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//
import SwiftUI

struct Friend {
    var id: UUID = UUID()
    var name: String = "Kevin Nguyen"
    @State var avatarURL: URL? = URL(string: "https://via.placeholder.com/150")
}
struct ListeningTogetherBadge: View {
    let friendsListening: [Friend] // Friend struct with name and image URL

    var body: some View {
        HStack(spacing: -10) {
            ForEach(friendsListening.prefix(3), id: \.id) { friend in
                AsyncImage(url: friend.avatarURL) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
                .shadow(radius: 2)
            }
            if friendsListening.count > 3 {
                Text("+\(friendsListening.count - 3)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.gray))
                    .foregroundColor(.white)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 2)
            }
        }
        .padding(6)
        .background(Color.green.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview("ListeningTogetherBadge") {
    ListeningTogetherBadge(friendsListening: [Friend](repeating: .init(), count: 5))
}
