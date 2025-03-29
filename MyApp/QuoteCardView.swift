//
//  QuoteCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/29/25.
//

import SwiftUI

// MARK: - Data Model (Simple Local Storage)

struct Quote {
    let id = UUID() // Unique identifier
    let text: String
    let author: String
    let description: String
    var isFavorite: Bool = false // Basic state for the heart icon
}

// MARK: - Main Application Structure

//@main
//struct QuoteApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

// MARK: - Main Content View

struct ContentView: View {
    // Sample quote data stored locally within the view
    // In a real app, this might come from UserDefaults, Core Data, etc.
    @State private var currentQuote = Quote(
        text: "Fortune favors the bold.",
        author: "Virgil",
        description: "Latin poet",
        isFavorite: true // Example initial state
    )

    var body: some View {
//        WindowGroup {
            ZStack {
                // Dark background for the whole screen
                Color(red: 0.15, green: 0.15, blue: 0.15)
                    .edgesIgnoringSafeArea(.all)

                // Center the Quote Card
                QuoteCardView(quote: $currentQuote)
            }
//        }
    }
}

// MARK: - Quote Card View

struct QuoteCardView: View {
    @Binding var quote: Quote // Use Binding to allow modification (like favorite status)

    // Define custom colors based on the image/CSS
    let cardBackground = Color(red: 183/255, green: 226/255, blue: 25/255) // rgb(183, 226, 25)
    let titleAuthorColor = Color(red: 127/255, green: 155/255, blue: 29/255) // rgb(127, 155, 29)
    let quoteTextColor = Color(red: 70/255, green: 85/255, blue: 18/255)     // #465512
    let backgroundQuoteMarkColor = Color(red: 223/255, green: 248/255, blue: 134/255).opacity(0.6) // rgb(223, 248, 134) with opacity

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header Text: "QUOTE OF THE MONTH"
            Text("QUOTE OF THE MONTH")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(titleAuthorColor)
                .textCase(.uppercase)
                .padding(.top, 30) // Added top padding

            Spacer() // Pushes quote section down slightly

            // Quote Text and Background Mark Area
            ZStack {
                // Background Quotation Mark
                Text("“")
                    .font(.system(size: 150, weight: .bold)) // Large size for the mark
                    .foregroundColor(backgroundQuoteMarkColor)
                    .offset(y: -20) // Adjust vertical position slightly

                // Actual Quote Text
                Text(quote.text)
                    .font(.system(size: 32, weight: .heavy)) // Large and very bold font
                    .foregroundColor(quoteTextColor)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5) // Adjust line spacing if needed
                    .padding(.horizontal, 5) // Prevent text touching edges inside ZStack
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure ZStack takes width
            .padding(.horizontal, 25) // Horizontal padding for the quote section

            Spacer() // Pushes attribution section down

            // Attribution and Favorite Icon Area
            HStack(alignment: .center) {
                 Text("- by \(quote.author)\n(\(quote.description))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(titleAuthorColor)
                    .lineSpacing(3) // Spacing between author and description lines

                Spacer() // Pushes heart icon to the right

                // Favorite Button (Heart Icon)
                Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.black) // Black heart as in the image
                    .font(.system(size: 20))
                    .onTapGesture {
                        // Toggle favorite status when tapped
                        // In a real app, persist this change
                        quote.isFavorite.toggle()
                    }
            }
             .padding(.horizontal, 30) // Horizontal padding for the attribution line
             .padding(.bottom, 30) // Bottom padding for the card

        }
        // Card Styling
        .frame(width: 300, height: 420) // Adjusted frame size to better fit content based on image proportions
        .background(cardBackground)
        .cornerRadius(15) // Slightly larger corner radius
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5) // Optional shadow
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
        @State static var previewQuote = Quote(
        text: "Fortune favors the bold.",
        author: "Virgil",
        description: "Latin poet",
        isFavorite: true
    )

    static var previews: some View {
         ZStack {
            // Dark background for the preview
            Color(red: 0.15, green: 0.15, blue: 0.15)
                .edgesIgnoringSafeArea(.all)
            QuoteCardView(quote: $previewQuote)
        }
    }
}
