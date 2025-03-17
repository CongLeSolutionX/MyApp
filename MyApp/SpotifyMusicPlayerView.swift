//
//  SpotifyMusicPlayerView.swift
//  MyApp
//
//  Created by Cong Le on 3/16/25.
//

import SwiftUI

struct MusicPlayerView: View {
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
                Image("albumArt") // Replace with your image name
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
                .foregroundColor(.green)
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
                .foregroundColor(.gray)
                .padding(.bottom, 20)
                
                //Explore Button
                Button(action: {}){
                    Text("Explore Vicky Nhung")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity) // Full width button
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                    
                    
                }
                .padding(.horizontal)
                
                
                Spacer() // Push content to the top
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView()
    }
}
