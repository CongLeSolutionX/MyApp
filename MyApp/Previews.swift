//
//  Previews.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI
// MARK: - Share Sheet Preview

#Preview("Music Player View") {
    MusicPlayerView()
        .preferredColorScheme(.dark) // Preview in dark mode
        .onAppear {
            // Placeholder image setup for preview if needed
            // You might need to add an actual image named "album_art_placeholder.jpg"
            // to your Assets.xcassets for the preview to show the image.
        }
}
#Preview("Share Sheet View") {
    ShareSheetView()
        .preferredColorScheme(.dark)
        .onAppear {
            // Add placeholder images to Assets:
            // album_art_placeholder.jpg
            // spotify_icon.png (ideally a template image)
            // facebook_logo.png
            // tiktok_logo.png
            // whatsapp_logo.png
            // instagram_logo.png
            // messenger_logo.png
        }
}
#Preview("ShareSheetView With Edit/Custom Button") {
    // Preview in both states
    VStack {
        Text("Default State").font(.caption).foregroundColor(.gray)
        ShareSheetView()
        Divider()
        Text("Editing State").font(.caption).foregroundColor(.gray)
        ShareSheetView(isEditing: true) // Pass initial state for preview
    }
    .preferredColorScheme(.dark)
    .onAppear {
        // Add placeholder images to Assets:
        // album_art_placeholder.jpg
        // spotify_icon.png
        // facebook_logo.png
        // tiktok_logo.png
        // whatsapp_logo.png
        // instagram_logo.png
        // messenger_logo.png
        // *** NEW ASSETS ***
        // lined_paper_background.png (or .jpg)
        // doodle_star_scribble.png
        // doodle_heart_notes.png
        // doodle_pink_marks.png
        // doodle_red_marks.png
    }
}
