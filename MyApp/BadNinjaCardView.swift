//
//  CardView.swift
//  MyApp
//
//  Created by Cong Le on 3/10/25.
//

import SwiftUI

struct BadNinjaCardView: View {
    var body: some View {
        ZStack {
            // Background Color (Assuming a dark blue)
            Color(red: 0.1, green: 0.1, blue: 0.2).edgesIgnoringSafeArea(.all)

            VStack {
                // Top Bar (Status Bar + Navigation)
                HStack {
                    Text("7:28") // Time (Could be dynamic)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "wifi")
                        .foregroundColor(.white)
                    Image(systemName: "battery.100")
                        .foregroundColor(.white)
                    Text("48")
                        .font(.system(size: 14))
                         .foregroundColor(.white)

                }
                .padding(.horizontal)
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top) // Adjust for safe area

                // Navigation Bar (Reels + Icons)
                HStack {
                    Image(systemName: "xmark") // Back Button
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text("Reels")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.trailing, 5) // Add some spacing.
                    Image(systemName: "chevron.down") // Dropdown arrow
                        .font(.system(size: 12))
                        .foregroundColor(.white)

                    Spacer() // Push icons to the right

                    HStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        Image(systemName: "camera")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        Image(systemName: "person.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)

                // "Saved audio" Banner
                HStack {
                    Image(systemName: "bookmark.fill") // Bookmark icon
                        .foregroundColor(.white)
                    Text("Saved audio")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer() // Push to left
                }
                .padding()
                .background(Color.gray.opacity(0.3)) // Semi-transparent gray
                .cornerRadius(8)
                .padding(.horizontal)

                Text("Create a reel with the audio you like.")
                   .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.bottom)

                // Main Content Card ("The Walking Dead" Reel)
                VStack {
                    // Reel Image Placeholder (Replace with actual image)
                    ZStack {
                        Color.gray // Placeholder color
                        // Image("reelImage") //  Replace with your image name
                        //    .resizable()
                        //    .aspectRatio(contentMode: .fill)
                        Text("BAD NINJA\nWALKING DEAD") // Overlay Text
                            .font(.system(size: 30, weight: .bold, design: .default)) // Use a bold, large font
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center) // Center align multiple lines
                    }
                    .frame(width: 300, height: 300)
                    .cornerRadius(12)

                    // Audio Information
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.white)
                            Text("The Walking Dead")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Text("BAD NINJA")
                            .font(.subheadline)
                            .foregroundColor(.white)

                        // "Use audio" Button
                        Button(action: {
                            // Action to use the audio
                        }) {
                            HStack {
                                Image(systemName: "camera")
                                    .foregroundColor(.white)
                                Text("Use audio")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.top) // Space between image and info
                }
                .padding()
                .background(Color.gray.opacity(0.5)) // Semi-transparent background
                .cornerRadius(15)
                .padding(.horizontal)

                Spacer() // Push content to top, but allow space at bottom

                 // Bottom Right Corner Button (Three Dots)
                HStack {
                    Spacer() // Push to the right
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding()
                    }
                }

            }

        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        BadNinjaCardView()
    }
}
