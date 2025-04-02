//
//  SongRowView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//


import SwiftUI

struct Song: Identifiable {
    let id = UUID()
    let title: String
    var rating: Int? = nil
}


struct SongRowView: View {
    let song: Song // Using Song struct from Custom Container example

    var body: some View {
        HStack {
            Text(song.title)
            Spacer()
            if let rating = song.rating {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .overlay(
                        Text("\(rating)")
                            .font(.caption2)
                            .foregroundColor(.black)
                    )
                    // SwiftUI provides a default label like "Star fill" or similar
                    // We augment it:
                     .accessibilityLabel { existingLabel in
                        // existingLabel represents the default label SwiftUI generated
                        // e.g., "Star fill"
                        Text("Rating: \(rating) out of 5 stars. \(existingLabel)")
                     }
            } else {
                 Image(systemName: "star")
                    .foregroundColor(.gray)
                    .accessibilityLabel("Not rated") // Provide label if none exists
            }
            Button("Add to Setlist") {
                print("Adding \(song.title) to setlist...")
            }
             // SwiftUI provides default "Add to Setlist, Button" label
             // Augment it:
            .accessibilityLabel { existingLabel in
                 // existingLabel is likely "Add to Setlist, Button"
                 Text("\(song.title): \(existingLabel)")
             }
        }
        .padding()
        // Combine children for better navigation, but allow individual elements if needed
         .accessibilityElement(children: .contain)
         .accessibilityLabel("Song: \(song.title)") // Overall label for the row container
    }
}

#Preview {
    VStack {
        SongRowView(song: Song(title: "Swift Charts Serenade", rating: 4))
        SongRowView(song: Song(title: "The Ballad of Optional Chaining"))
    }
}
