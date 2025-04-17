//
//  FriendListeningManager_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

// Example SwiftUI Components
import SwiftUI

struct FriendListeningBanner: View {
    let friendName: String
    let avatarURL: URL?
    let isListening: Bool
    
    var body: some View {
        HStack {
            AsyncImage(url: avatarURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text("\(friendName) \(isListening ? "is listening now" : "listened earlier")")
                    .font(.headline)
                    .foregroundColor(.primary)
                if !isListening {
                    Text("Earlier today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: isListening ? "dot.circle.fill" : "clock")
                .foregroundColor(isListening ? .green : .gray)
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.95))
        .cornerRadius(8)
        .shadow(radius: 2)
        .onTapGesture {
            // Show detailed history/modal
        }
    }
}

#Preview("FriendListeningBanner"){
    FriendListeningBanner(friendName: "Nguyen", avatarURL: nil, isListening: true)
}
