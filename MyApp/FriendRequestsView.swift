//
//  FriendRequestsView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// MARK: - Data Model

struct FriendRequest: Identifiable {
    let id = UUID()
    let name: String
    let profileImageName: String // Placeholder for image asset name or URL
    let mutualFriendsCount: Int?
    let mutualFriendImageNames: [String]? // Placeholders for images

    // Sample Data
    static let sampleData: [FriendRequest] = [
        FriendRequest(name: "Thanh Huynh", profileImageName: "flame.fill", mutualFriendsCount: nil, mutualFriendImageNames: nil),
        FriendRequest(name: "Minh Lê", profileImageName: "person.crop.circle.fill.badge.checkmark", mutualFriendsCount: 4, mutualFriendImageNames: ["person.fill", "person.2.fill", "person.3.fill"]),
        FriendRequest(name: "Lộc Tài", profileImageName: "figure.water.fitness", mutualFriendsCount: 11, mutualFriendImageNames: ["person.fill", "person.2.fill"])
    ]
}

// MARK: - UI Components

struct FriendRequestRow: View {
    let request: FriendRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top part: Profile Image, Name, Mutual Friends
            HStack(spacing: 12) {
                Image(systemName: request.profileImageName) // Use system names as placeholders
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(5) // Add padding to simulate profile pic appearance if needed
                    .background(Color.gray.opacity(0.3)) // Placeholder background
                    .clipShape(Circle())
                    .foregroundColor(.orange) // Example color accent

                VStack(alignment: .leading, spacing: 4) {
                    Text(request.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if let count = request.mutualFriendsCount, let images = request.mutualFriendImageNames {
                        HStack(spacing: -6) { // Overlap images slightly
                            ForEach(images.prefix(3), id: \.self) { imgName in // Show max 3 mutual pics
                                Image(systemName: imgName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                    .padding(2)
                                    .background(Color.gray.opacity(0.5))
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                            }
                            Text("\(count) mutual friends")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 10) // Space between images and text
                        }
                    }
                }
                Spacer() // Push content to the left
            }

            // Bottom part: Buttons
            HStack(spacing: 8) {
                Button {
                    // Confirm action
                    print("Confirmed \(request.name)")
                } label: {
                    Text("Confirm")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity) // Make buttons take equal space
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }

                Button {
                    // Delete action
                    print("Deleted \(request.name)")
                } label: {
                    Text("Delete")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity) // Make buttons take equal space
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.4)) // Dark grey button
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(white: 0.12)) // Dark card background
        .cornerRadius(12)
    }
}

struct FriendRequestsView: View {
    @State private var friendRequests: [FriendRequest] = FriendRequest.sampleData

    var body: some View {
        NavigationView { // Optional, for structure like nav bar elements if needed later
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header Text
                    Text("You have friend requests waiting for you")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Confirm these friend requests to effortlessly share reels with each other.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)

                    // List of Requests
                    LazyVStack(spacing: 12) {
                        ForEach(friendRequests) { request in
                            FriendRequestRow(request: request)
                        }
                    }
                }
                .padding(.horizontal) // Padding for the overall content VStack
            }
            .navigationBarHidden(true) // Hide default nav bar to match screenshot's custom top bar area
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Dark background for the whole view
            .preferredColorScheme(.dark) // Ensure system elements use dark mode
        }
    }
}

// MARK: - Preview

struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestsView()
    }
}
