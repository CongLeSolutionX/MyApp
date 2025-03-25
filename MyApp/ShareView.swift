//
//  ShareView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//
import SwiftUI


struct ShareView: View {
    @State private var selectedColor: Color = Color(red: 0.8, green: 0.5, blue: 0.2, opacity: 1.0) // Orange default
    
    
    var body: some View {
        ZStack {
            // Background Color
            selectedColor
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Spacer()
                
                
                // Media Card
                MediaCardView()
                    .padding(.bottom, 30)
                
                
                // Color Options & Share Button
                HStack {
                    Button(action: {
                        selectedColor = .white
                    }) {
                        ColorOption(color: .white)
                    }
                    
                    
                    Button(action: {
                        selectedColor = Color(red: 0.6, green: 0.4, blue: 0.2) // Brown
                    }) {
                        ColorOption(color: Color(red: 0.6, green: 0.4, blue: 0.2))
                    }
                    
                    
                    Button(action: {
                        selectedColor = .black
                    }) {
                        ColorOption(color: .black)
                    }
                    
                    
                    Button(action: {
                        shareContent()
                    }) {
                        ShareButton()
                    }
                }
                .padding(.bottom, 40)
                
                
                // Social Share Options
                SocialShareOptions()
                
                
                Spacer()
            }
        }
    }
    
    
    // Function to handle sharing
    func shareContent() {
        print("Content shared!")
        // Add actual sharing logic here
    }
}


struct MediaCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
                .frame(width: 250, height: 350)
            
            
            VStack {
                Image(systemName: "music.note") // Default asset
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                
                Text("Title PlaceHolder")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 2)
                
                
                Text("Artist PlaceHolder")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                
                SpotifyLogo()
            }
        }
    }
}


struct SpotifyLogo: View {
    var body: some View {
        HStack {
            Image(systemName: "headphones") // Default asset
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.green)
            
            
            Text("Spotify")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}


struct ColorOption: View {
    var color: Color
    
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 30, height: 30)
            .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
    }
}


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


struct SocialShareOptions: View {
    var body: some View {
        HStack {
            // Use Button to handle clicks
            Button(action: { copyLink() }) {
                SocialIcon(imageName: "link", systemImage: true, label: "Copy link")
            }
            Button(action: { shareToTikTok() }) {
                SocialIcon(imageName: "music.note.tv", systemImage: true, label: "TikTok")
            }
            Button(action: { shareViaMessages() }) {
                SocialIcon(imageName: "message", systemImage: true, label: "Messages")
            }
            Button(action: { shareToStories() }) {
                SocialIcon(imageName: "book", systemImage: true, label: "Stories")
            }
            Button(action: { shareToWhatsApp() }) {
                SocialIcon(imageName: "phone", systemImage: true, label: "WhatsApp")
            }
            Button(action: { shareToInstagram() }) {
                SocialIcon(imageName: "camera", systemImage: true, label: "Instagram")
            }
        }
    }
    
    
    // Example actions for each social media
    func copyLink() { print("Copy Link Tapped") }
    func shareToTikTok() { print("TikTok Tapped") }
    func shareViaMessages() { print("Messages Tapped") }
    func shareToStories() { print("Stories Tapped") }
    func shareToWhatsApp() { print("WhatsApp Tapped") }
    func shareToInstagram() { print("Instagram Tapped") }
}


struct SocialIcon: View {
    var imageName: String
    var systemImage: Bool // Flag to use systemName or assetName
    var label: String
    
    
    var body: some View {
        VStack {
            if systemImage {
                Image(systemName: imageName) // Use SF Symbols
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .clipShape(Circle())
            } else {
                Image(imageName) // Use asset
                    .resizable()
                    .frame(width: 30, height: 30)
                    .background(Color.black)
                    .clipShape(Circle())
            }
            
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white)
        }
    }
}


struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView()
    }
}
