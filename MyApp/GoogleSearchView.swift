//
//  GoogleSearchView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// --- Data Models ---

struct SearchSuggestion: Identifiable {
    let id = UUID()
    let text: String
    let secondaryText: String? = nil // For items like Mt. Fuji
    let iconName: String // System name for SF Symbols (e.g., "clock", "magnifyingglass")
    let imageName: String? = nil // For image previews like Mt. Fuji
}

struct RelatedSearch: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let imageName: String // Placeholder image name
}

// --- View Components ---

// Represents a single row in the left suggestion list
struct SearchSuggestionRow: View {
    let suggestion: SearchSuggestion

    var body: some View {
        HStack(spacing: 12) {
            // Image Preview (if available)
            if let imageName = suggestion.imageName {
                Image(imageName) // Use a placeholder image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .cornerRadius(4)
                    // Placeholder background if image loading fails or is missing
                    .background(Color.gray.opacity(0.1))
                     .clipShape(RoundedRectangle(cornerRadius: 4))

            } else {
                // Standard Icon
                Image(systemName: suggestion.iconName)
                    .foregroundColor(.gray)
                    .frame(width: 20, alignment: .center) // Align icons
            }

            // Text Content
            if let secondaryText = suggestion.secondaryText {
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.text).font(.system(size: 15))
                    Text(secondaryText).font(.caption).foregroundColor(.gray)
                }
            } else {
                Text(suggestion.text)
                    .font(.system(size: 15))
            }

            Spacer() // Push content to the left
        }
        .padding(.vertical, 6) // Add vertical padding to rows
    }
}

// Represents a single item in the "People also search for" section
struct RelatedSearchItemView: View {
    let item: RelatedSearch

    var body: some View {
        VStack(spacing: 4) {
            Image(item.imageName) // Use placeholder image names
                .resizable()
                .scaledToFill() // Fill the frame
                .frame(width: 70, height: 70)
                .cornerRadius(8)
                // Placeholder background if image loading fails or is missing
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(item.title).font(.caption).bold()
            Text(item.category).font(.caption2).foregroundColor(.gray)
        }
        .frame(width: 80) // Give items a consistent width
    }
}

// The main suggestion box appearing below the search bar
struct SuggestionBoxView: View {
    // Sample Data
    let suggestions: [SearchSuggestion] = [
        .init(text: "ramen - Google Search", iconName: "clock"),
//        .init(text: "Mt. Fuji", secondaryText: "Stratovolcano in Japan", iconName: "", imageName: "mtfuji_placeholder"), // Provide a placeholder image name
        .init(text: "ramen recipes", iconName: "clock"),
        .init(text: "best time to visit japan", iconName: "clock"),
        .init(text: "how tall is mt everest", iconName: "clock")
    ]

    let relatedSearches: [RelatedSearch] = [
        .init(title: "Udon", category: "Food", imageName: "My-meme-original"), // Placeholder names
        .init(title: "Instant", category: "Noodle", imageName: "My-meme-red-wine-glass"),
        .init(title: "Soba", category: "Food", imageName: "My-meme-microphone")
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left Column: Search Suggestions
            VStack(alignment: .leading, spacing: 5) {
                // Top icons (Mic & Lens) - positioned within the suggestion box context
                 HStack {
                     Spacer() // Pushes icons to the right end of this column area
                     Image(systemName: "mic")
                         .foregroundColor(.blue)
                         .font(.system(size: 18))
                         .padding(.trailing, 5)
                     Image(systemName: "camera") // Approximation for Google Lens
                         .foregroundColor(.blue)
                         .font(.system(size: 18))

                 }
                 .padding(.bottom, 5) // Space below icons

                // Search input simulation (Magnifying glass + text area hint)
                // In a real app, the actual TextField would be above this box.
                // This HStack simulates the visual structure *within* the dropdown context.
                HStack {
                     Image(systemName: "magnifyingglass")
                         .foregroundColor(.gray)
                     // Placeholder text or actual input would go here in a real scenario
                     Text("ramen") // Simulating user input shown in screenshot
                         .foregroundColor(.black)
                      Spacer()
                }
                .padding(.bottom, 10) // Space below simulated input

                // List of suggestions
                ForEach(suggestions) { suggestion in
                    SearchSuggestionRow(suggestion: suggestion)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10) // Add padding at the top for Mic/Lens icons

            // Vertical Divider
            Divider()
                 .frame(width: 1) // Ensure divider is visible
                 .background(Color.gray.opacity(0.3))
                 .padding(.vertical, 5) // Give divider some vertical space

            // Right Column: People also search for
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                         Text("People also search for")
                            .font(.caption)
                            .foregroundColor(.gray)
                         Image(systemName: "chevron.down")
                             .font(.caption)
                             .foregroundColor(.gray)
                         Spacer()
                     }
                    .padding(.top, 10) // Align roughly with left column's top content

                     // Horizontal list of related items
                     HStack(alignment: .top, spacing: 15) {
                         ForEach(relatedSearches) { item in
                             RelatedSearchItemView(item: item)
                         }
                         Spacer() // Pushes items to the left
                     }
                 }
                .padding(.horizontal)

        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 600) // Limit width for realistic appearance
    }
}

// --- Main Hosting View (Example Usage) ---
struct GoogleSearchView: View {
    @State private var searchText: String = "" // For the actual search bar

    var body: some View {
        ZStack {
            // Background color similar to the screenshot's backdrop
            Color(red: 0.15, green: 0.16, blue: 0.18) // Dark grayish-blue
                .ignoresSafeArea()

             VStack(spacing: 20) {
                 // 1. Google Logo (Approximation)
                 Text("Google")
                     .font(.system(size: 60, weight: .medium)) // Adjust font size and weight
                     .foregroundStyle(
                         LinearGradient(
                             colors: [.blue, .red, .yellow, .blue, .green, .red], // Google colors
                             startPoint: .leading,
                             endPoint: .trailing
                         )
                     )
                      .padding(.top, 50) // Space from top

                 // 2. Simulated Search Bar (Above the suggestion box)
                  HStack {
                      Image(systemName: "magnifyingglass")
                          .foregroundColor(.gray)
                      TextField("Search Google or type a URL", text: $searchText)
                      Image(systemName: "mic.fill")
                           .foregroundColor(.gray) // Or blue if active
                      Image(systemName: "camera.viewfinder") // Different icon possibility
                           .foregroundColor(.gray)
                  }
                  .padding(.horizontal, 12)
                  .padding(.vertical, 10)
                  .background(Color.white)
                  .cornerRadius(25) // Highly rounded corners
                  .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                  .frame(maxWidth: 550) // Limit width

                 // 3. The Suggestion Box
                // Only show suggestions if search text is not empty (basic logic)
                // In the screenshot, it's shown even without active typing focus sometimes.
                // if !searchText.isEmpty { // Or always show for demo
                     SuggestionBoxView()
                // }

                 Spacer() // Pushes content upwards
             }
             .padding() // Overall padding for the content
         }
    }
}

// --- Preview ---
#Preview {
    GoogleSearchView()
        // Add placeholder images to your Assets.xcassets for preview
        // with names like "mtfuji_placeholder", "udon_placeholder", etc.
        // Or use system images / colored rectangles as placeholders:
        // .environment(\.imageResolver, ...) // More advanced
}
