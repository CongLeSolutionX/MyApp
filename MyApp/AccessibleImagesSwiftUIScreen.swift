//
//  AccessibleImagesSwiftUIScreen.swift
//  MyApp
//
//  Created by Cong Le on 11/14/24.
//

import SwiftUI

struct AccessibleImagesSwiftUIScreen: View {
    @State private var profilePictureName = "defaultProfile" // For dynamic image example

    var body: some View {
        ScrollView { // Use ScrollView for longer content
            VStack(alignment: .leading, spacing: 20) {
                Text("Accessible Images Examples").font(.title)

                // 1. Simple Descriptive Text
                Image("Round_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .accessibilityLabel("A around logo of my channel.")


                // 2. Functional Image (Button)
                Button(action: {
                    // Action for adding to cart
                    print("Added to cart")
                }) {
                    Image(systemName: "cart.badge.plus")
                        .font(.largeTitle)
                }
                .accessibilityLabel("Add to cart")



                // 3. Image with Text (Simulated with an overlay)
                ZStack {
                    Image("My-meme-heineken")
                        .resizable()
                        .scaledToFit()
                         .frame(width: 200, height: 100)
                    Text("Sale: 50% off")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
                .accessibilityLabel("Sale: 50% off all items") // Alt text includes embedded text



                // 4. Complex Image
                Image("Square_logo")
                    .resizable()
                    .scaledToFit()
                     .frame(width: 200, height: 100)
                    .accessibilityLabel("A square logo of the same channel as the previous one.")
                    .accessibilityHint("Double-tap to view detailed data.")


                // 5. Decorative Image (used as background, no label usually needed)
                Text("Text with decorative background")
                    .padding()
                    .background(
                        Image("My-meme-microphone")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.5) // Make it subtle
                    )
                    .accessibilityElement(children: .ignore) // Example if a SwiftUI label is accidentally being read for background


                // 6. Group of Images (Panorama)
                // Notes: This example is to large to fit in the current screen for now.
                // TODO: Update assets size add images for this examples
                HStack(spacing: 0) {
                    Image("canyonPart1Placeholder")
                    Image("canyonPart1Placeholder")
                    Image("canyonPart1Placeholder")
                }
                .frame(height: 150) // Adjust as needed
                .clipped()
                .accessibilityElement(children: .combine)
                .accessibilityLabel("A panorama of the Grand Canyon.")



                // 7. Image with Dynamic Content (Profile Picture)
                Image(profilePictureName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .accessibilityLabel("Your profile picture: \(profilePictureName == "defaultProfile" ? "Default" : "Custom")")
                    .onTapGesture {
                        // Simulate changing the profile picture
                        profilePictureName = (profilePictureName == "defaultProfile") ? "customProfile" : "defaultProfile"
                    }


                Spacer() // Push content to the top
            }
            .padding()
        }.navigationTitle("Accessible Images")

    }
}

// MARK: - Previews
struct AccessibleImagesScreen_Previews: PreviewProvider {
    static var previews: some View {
        AccessibleImagesSwiftUIScreen()
    }
}


// Placeholders (replace with real assets) – define actual images in your Asset catalog
struct Placeholders_Previews: PreviewProvider { // Embed in preview struct to avoid errors outside preview
    static var previews: some View {
        VStack { // Just to arrange the placeholders
            RoundedRectangle(cornerRadius: 8).fill(.gray).frame(width: 200, height: 100).overlay(Text("saleBannerPlaceholder"))
            RoundedRectangle(cornerRadius: 8).fill(.gray).frame(width: 200, height: 100).overlay(Text("chartPlaceholder"))
            RoundedRectangle(cornerRadius: 8).fill(.gray).frame(width: 200, height: 100).overlay(Text("decorativeBackgroundPlaceholder"))
            RoundedRectangle(cornerRadius: 8).fill(.gray).frame(width: 100, height: 50).overlay(Text("canyonPart1Placeholder"))
            RoundedRectangle(cornerRadius: 8).fill(.gray).frame(width: 100, height: 50).overlay(Text("canyonPart2Placeholder"))
            RoundedRectangle(cornerRadius: 8).fill(.gray).frame(width: 100, height: 50).overlay(Text("canyonPart3Placeholder"))
            RoundedRectangle(cornerRadius: 8).fill(.gray).frame(width: 100, height: 100).overlay(Text("customProfilePlaceholder"))
            
        }
    }
}
