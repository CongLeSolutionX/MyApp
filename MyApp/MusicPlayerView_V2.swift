//
//  MusicPlayerView_V2.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//


import SwiftUI

struct MusicPlayerView_V2: View {
    //Dummy data, replace with real data later
    @State private var progress: Double = 0.53
    @State private var isPlaying: Bool = false

    var body: some View {
        ZStack {
            // Background
            Color("BackgroundColor") // Assuming a custom color in Assets.xcassets
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.down")
                    }

                    Spacer()

                    Text("Ngày Mưa Ấy")
                        .font(.headline)

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 50) // Adjust for safe area
                .padding(.bottom, 20)
                .foregroundColor(.white)

                // Album Art
                Image("My-meme-red-wine-glass") // Replace with your image name
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .padding(.horizontal, 30)
                    .padding(.bottom,20)

                // Track Info
                VStack {
                    Text("Ngày Mưa Ấy")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Vicky Nhung")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)

                // Progress Bar
                VStack {
                    Slider(value: $progress)
                        .accentColor(.white)  // Customize slider color
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    HStack {
                        Text("0:53")
                        Spacer()
                        Text("-3:44")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)

                // Controls
                HStack(spacing: 50) {
                    Button(action: {}) {
                        Image(systemName: "shuffle")
                    }
                    Button(action: {}) {
                        Image(systemName: "backward.end.fill")
                    }
                    Button(action: {
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))  // Larger button
                    }
                    Button(action: {}) {
                        Image(systemName: "forward.end.fill")
                    }
                    Button(action: {}) {
                        Image(systemName: "repeat")
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, 30)

                // Bottom Bar
                HStack(spacing: 70) {
                    Button(action: {}) {
                        Image(systemName: "quote.bubble")
                            .font(.title2)
                    }
                    Spacer()

                    Button(action: {}){
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                    }
                    Spacer()

                    Button(action:{}){
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                .foregroundColor(.white)
                .padding(.bottom, 20)

                // Explore Vicky Nhung Section
                VStack(alignment: .leading) { // Align title to leading edge
                    Text("Explore Vicky Nhung")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) { // Spacing between cards
                            ExploreCardView(imageName: "exploreImage1", text: "Songs by\nVicky Nhung")
                            ExploreCardView(imageName: "exploreImage2", text: "Similar to\nVicky Nhung")
                            ExploreCardView(imageName: "exploreImage3", text: "ĐÀ LẠT\nSimilar to\nNgày Mưa Ấy")
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)

                Spacer() // Push content to the top
            }
        }
    }
}

// Custom Card View for Explore Section
struct ExploreCardView: View {
    var imageName: String
    var text: String

    var body: some View {
        HStack(alignment: .bottom) { // Align text to leading edge within card
            Image(imageName) // Replace with your image names
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 180) // Adjust card image size
                .cornerRadius(10)

            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.top, 8)
                .frame(width: 120, alignment: .leading) // Match text width to image, align leading
                .lineLimit(3) // Limit text lines to avoid overflow
        }
        .padding(0) // Padding within the card itself, adjust as needed
        .background(Color(red: 50/255, green: 50/255, blue: 50/255)) // Dark gray background
        .cornerRadius(10)
    }
}

struct MusicPlayerView_V2_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView_V2()
            .preferredColorScheme(.dark) // Ensure preview is in dark mode
    }
}
