//
//  ShareView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI

struct ShareView: View {
    var body: some View {
        ZStack {
            // Background Color
            Color(red: 0.8, green: 0.5, blue: 0.2, opacity: 1.0) // Orange color
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Spacer() // Push content to the middle
                
                
                // Media Card
                MediaCardView()
                    .padding(.bottom, 30) // Space between media card and color options
                
                
                // Color Options & Share Button
                HStack {
                    ColorOption(color: .white)
                    ColorOption(color: Color(red: 0.6, green: 0.4, blue: 0.2))
                    ColorOption(color: .black)
                    ShareButton()
                }
                .padding(.bottom, 40) // Space between share options and social icons
                
                
                // Social Share Options
                SocialShareOptions()
                
                
                Spacer() // Equally push content up from the bottom
            }
        }
    }
}


// Media Card View
struct MediaCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8)) // Dark background for the card
                .frame(width: 250, height: 350)
            
            
            VStack {
                Image("album_art") // Replace with actual image
                    .resizable()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.bottom, 10)
                
                
                Text("Ngày Mưa Ấy")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 2)
                
                
                Text("Vicky Nhung")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                
                SpotifyLogo()
            }
        }
    }
}


// Spotify Logo and Text
struct SpotifyLogo: View {
    var body: some View {
        HStack {
            Image("spotify_logo") // Replace with actual image
                .resizable()
                .frame(width: 20, height: 20)
            
            
            Text("Spotify")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}


// Color Option Button (White, Brown, Black)
struct ColorOption: View {
    var color: Color
    
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 30, height: 30)
            .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
    }
}


// Share Button View (Icon in a Square)
struct ShareButton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.white.opacity(0.2))
            .frame(width: 30, height: 30)
            .overlay(
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.white)
            )
    }
}


// Social Share Icons
struct SocialShareOptions: View {
    var body: some View {
        HStack {
            SocialIcon(imageName: "copy_link", label: "Copy link")
            SocialIcon(imageName: "tiktok", label: "TikTok")
            SocialIcon(imageName: "messages", label: "Messages")
            SocialIcon(imageName: "stories", label: "Stories")
            SocialIcon(imageName: "whatsapp", label: "WhatsApp")
            SocialIcon(imageName: "instagram", label: "Instagram")
        }
    }
}


// Individual Social Icon with Label
struct SocialIcon: View {
    var imageName: String
    var label: String
    
    
    var body: some View {
        VStack {
            Image(imageName) // Replace with actual image
                .resizable()
                .frame(width: 30, height: 30)
                .background(Color.black)
                .clipShape(Circle())
            
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white)
        }
    }
}


// Preview
struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView()
    }
}
