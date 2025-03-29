////
////  QuoteCardView.swift
////  MyApp
////
////  Created by Cong Le on 3/29/25.
////
//import SwiftUI
//
//// MARK: - Data Model (Simple Local Storage)
//
//struct Quote {
//    let id = UUID() // Unique identifier
//    let text: String
//    let author: String
//    let description: String
//    var isFavorite: Bool = false // Basic state for the heart icon
//}
//
//// MARK: - Main Application Structure
//
////@main
////struct QuoteApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
//
//// MARK: - Main Content View
//
//struct ContentView: View {
//    // Sample quote data stored locally within the view
//    @State private var currentQuote = Quote(
//        text: "Fortune favors the bold.",
//        author: "Virgil",
//        description: "Latin poet",
//        isFavorite: false // Start as not favorite initially
//    )
//
//    var body: some View {
//         ZStack { // Changed from Scene to View for easier composition
//            // Dark background for the whole screen
//            Color(red: 0.15, green: 0.15, blue: 0.15)
//                .edgesIgnoringSafeArea(.all)
//
//            // Center the Quote Card
//            QuoteCardView(quote: $currentQuote) // Pass the binding
//        }
//    }
//}
//
//// MARK: - Quote Card View
//
//struct QuoteCardView: View {
//    @Binding var quote: Quote // Use Binding to allow modification (like favorite status)
//    @State private var isAuthorVisible: Bool = false // State to control author visibility
//
//    // Define custom colors based on the image/CSS
//    let cardBackground = Color(red: 183/255, green: 226/255, blue: 25/255) // rgb(183, 226, 25)
//    let titleAuthorColor = Color(red: 127/255, green: 155/255, blue: 29/255) // rgb(127, 155, 29)
//    let quoteTextColor = Color(red: 70/255, green: 85/255, blue: 18/255)     // #465512
//    let backgroundQuoteMarkColor = Color(red: 223/255, green: 248/255, blue: 134/255).opacity(0.6) // rgb(223, 248, 134) with opacity
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            // Header Text: "QUOTE OF THE MONTH"
//            Text("QUOTE OF THE MONTH")
//                .font(.system(size: 16, weight: .bold))
//                .foregroundColor(titleAuthorColor)
//                .textCase(.uppercase)
//                .padding(.top, 30) // Added top padding
//
//            Spacer() // Pushes quote section down slightly
//
//            // Quote Text and Background Mark Area
//            ZStack {
//                // Background Quotation Mark
//                Text("“")
//                    .font(.system(size: 150, weight: .bold)) // Large size for the mark
//                    .foregroundColor(backgroundQuoteMarkColor)
//                    .offset(y: -20) // Adjust vertical position slightly
//
//                // Actual Quote Text
//                Text(quote.text)
//                    .font(.system(size: 32, weight: .heavy)) // Large and very bold font
//                    .foregroundColor(quoteTextColor)
//                    .multilineTextAlignment(.leading)
//                    .lineSpacing(5) // Adjust line spacing if needed
//                    .padding(.horizontal, 5) // Prevent text touching edges inside ZStack
//            }
//            .frame(maxWidth: .infinity, alignment: .leading) // Ensure ZStack takes width
//            .padding(.horizontal, 25) // Horizontal padding for the quote section
//
//            Spacer() // Pushes attribution section down
//
//            // Attribution and Favorite Icon Area (Conditional Visibility)
//            // Use a minimum height to prevent layout collapse when hidden
//            Group {
//                if isAuthorVisible {
//                    HStack(alignment: .center) {
//                         Text("- by \(quote.author)\n(\(quote.description))")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(titleAuthorColor)
//                            .lineSpacing(3) // Spacing between author and description lines
//                            .transition(.opacity.combined(with: .move(edge: .bottom))) // Add transition
//
//                        Spacer() // Pushes heart icon to the right
//
//                        // Favorite Button (Heart Icon)
//                        Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
//                            .foregroundColor(.black) // Black heart as in the image
//                            .font(.system(size: 20))
//                            .transition(.opacity.combined(with: .move(edge: .bottom))) // Add transition
//                            .onTapGesture {
//                                // Important: Prevent the card's tap gesture from firing
//                                // when tapping ONLY the heart. Toggle favorite here.
//                                quote.isFavorite.toggle()
//                            }
//                    }
//                    .padding(.horizontal, 30) // Horizontal padding for the attribution line
//                } else {
//                    // Placeholder to maintain space when hidden
//                    // Adjust height based on estimated height of the author section
//                     HStack { Spacer() }.frame(height: 40) // Adjust height as needed
//                }
//            }
//            .frame(height: 50) // Give the container a fixed height
//            .padding(.bottom, 30) // Bottom padding for the card content area
//
//        }
//        // Card Styling
//        .frame(width: 300, height: 420) // Adjusted frame size
//        .background(cardBackground)
//        .cornerRadius(15) // Slightly larger corner radius
//        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5) // Optional shadow
//        .contentShape(Rectangle()) // Makes the entire area tappable, including transparent parts
//        .onTapGesture {
//            // Toggle author visibility when the card area (excluding heart) is tapped
//            withAnimation(.easeInOut(duration: 0.3)) { // Add animation
//                 isAuthorVisible.toggle()
//            }
//        }
//        // Optional: Reset visibility if the quote changes
////        .onChange(of: quote.id) { _ in
////            isAuthorVisible = false
////        }
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ContentView_Previews: PreviewProvider {
//     // Need to use @State for the preview binding
//     @State static var previewQuote = Quote(
//        text: "Fortune favors the bold.",
//        author: "Virgil",
//        description: "Latin poet",
//        isFavorite: false
//    )
//
//    static var previews: some View {
//         ZStack {
//            Color(red: 0.15, green: 0.15, blue: 0.15)
//                .edgesIgnoringSafeArea(.all)
//            QuoteCardView(quote: $previewQuote)
//        }
//    }
//}
