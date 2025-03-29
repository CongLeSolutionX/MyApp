//
//  ProfileCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// --- Data Model (Simple representation) ---
// For now, data is static. If loaded/saved, this would be more complex.
struct ProfileData {
    let name: String = "Cong Le"
    // Using SF Symbols - using 'link' as a placeholder for GitHub
    let socialIcons: [SocialLink] = [
        SocialLink(iconName: "link", destinationURL: "https://github.com"), // Placeholder for GitHub
        SocialLink(iconName: "camera.fill", destinationURL: "https://instagram.com"),
        SocialLink(iconName: "f.cursive.circle.fill", destinationURL: "https://facebook.com"),
        SocialLink(iconName: "bird.fill", destinationURL: "https://twitter.com") // Or x.squareroot
    ]
}

struct SocialLink: Identifiable {
    let id = UUID()
    let iconName: String
    let destinationURL: String // URL for potential linking action
}

//// --- Main Application Structure ---
//@main
//struct ProfileCardApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

// --- Main Content View ---
struct ContentView: View {
    var body: some View {
        ZStack {
            // Background for the entire screen
            Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)

            // The Profile Card View
            ProfileCardView(profileData: ProfileData())
        }
    }
}

// --- Profile Card View ---
struct ProfileCardView: View {
    let profileData: ProfileData

    // Define colors based on CSS for consistency
    let cardBackgroundColor = Color(red: 25/255, green: 25/255, blue: 25/255) // #191919
    let shadowDarkColor = Color.black.opacity(0.6)
    let shadowLightColor = Color(white: 0.25).opacity(0.5) // Approximation of rgb(57, 57, 57)

    var body: some View {
        VStack(spacing: 0) { // Use spacing 0 and control with padding
            // Profile Image
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .padding(10) // Add padding inside the circle if needed, or keep it tight
                .background(
                    Circle().fill(cardBackgroundColor) // Match card background or make transparent
                           .shadow(color: shadowDarkColor, radius: 5, x: 3, y: 3)
                            .shadow(color: shadowLightColor, radius: 5, x: -3, y: -3)
                )
                .clipShape(Circle())
                .padding(.top, 30) // Margin-top equivalent

            // Name
            Text(profileData.name)
                .font(.system(size: 22, weight: .medium)) // Using system font
                .foregroundColor(.white)
                .padding(.top, 25) // Combined padding/margin
                .padding(.bottom, 25) // Space before social bar

            // Social Bar
            HStack(spacing: 25) { // Adjust spacing between icons
                ForEach(profileData.socialIcons) { socialLink in
                    Button(action: {
                        // Action to open the URL (requires importing Foundation and using UIApplication or Link)
                        print("Tapped \(socialLink.iconName)")
                        if let url = URL(string: socialLink.destinationURL) {
                            // In a real app, you'd use Link or UIApplication.shared.open
                           // Link(destination: url) { Image(...) } is another option
                           print("Would open: \(url)")
                        }
                    }) {
                        Image(systemName: socialLink.iconName)
                            .font(.system(size: 18)) // Control icon size
                            .foregroundColor(.white.opacity(0.8)) // Slightly muted white
                    }
                }
            }
            .padding(.vertical, 16) // Vertical padding inside the bar
            .padding(.horizontal, 25) // Horizontal padding to control width/spacing
            .background(cardBackgroundColor)
            .cornerRadius(30) // Capsule-like rounding
             // Inner Neumorphic shadow for the social bar
            .shadow(color: shadowDarkColor, radius: 4, x: 2, y: 2)
            .shadow(color: shadowLightColor, radius: 4, x: -2, y: -2)
            .padding(.horizontal, 20) // Controls the 90% width effect
            .padding(.bottom, 30) // Space at the bottom

        }
        .frame(width: 240, height: 310) // Adjusted frame slightly for padding
        .background(cardBackgroundColor)
        .cornerRadius(35) // Rounded corners (approximating 2em)
        // Outer Neumorphic shadow for the main card
        .shadow(color: shadowDarkColor, radius: 10, x: 6, y: 6)
        .shadow(color: shadowLightColor, radius: 10, x: -6, y: -6)

    }
}

// --- Preview Provider ---
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
