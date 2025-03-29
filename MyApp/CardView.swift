////
////  CardView.swift
////  MyApp
////
////  Created by Cong Le on 3/28/25.
////
//import SwiftUI
//
//// MARK: - Data Model (Placeholder for future local storage integration)
//
//struct CardData: Identifiable {
//    let id = UUID()
//    var title: String
//    // Add other properties relevant to your card data here
//    // e.g., description, image name, etc.
//}
//
//// MARK: - ViewModel (Placeholder for managing data)
//
//@MainActor // Ensure UI updates happen on the main thread
//class CardViewModel: ObservableObject {
//    // For now, using a simple array. Replace with local storage logic later.
//    @Published var card: CardData = CardData(title: "Card")
//
//    // --- Local Storage Placeholder Functions ---
//    // func loadCard() { /* Load data from UserDefaults, CoreData, Realm, etc. */ }
//    // func saveCard() { /* Save data to local storage */ }
//
//    // Initialize with placeholder data or load from storage
//    init() {
//        // In a real app, you might call loadCard() here
//    }
//}
//
//// MARK: - Card View Definition
//
//struct CardView: View {
//    // Use the ViewModel to get data
//    @StateObject private var viewModel = CardViewModel()
//
//    // Define dimensions based on CSS (adjust as needed for aesthetics)
//    let cardWidth: CGFloat = 200
//    let cardHeight: CGFloat = 270 // From .img-container height in CSS
//    let cornerRadiusSmall: CGFloat = 8 // Approx .5rem
//    let cornerRadiusLarge: CGFloat = 32 // Approx 2rem
//
//    // Define colors from CSS
//    let gradientStartColor = Color(red: 51/255, green: 0/255, blue: 27/255) // #33001b
//    let gradientEndColor = Color(red: 255/255, green: 0/255, blue: 132/255) // #ff0084
//    let descriptionBackgroundColor = Color.black.opacity(0.2)
//    let descriptionTextColor = Color.white // Similar to aliceblue
//
//    var body: some View {
//        ZStack(alignment: .bottomLeading) {
//            // Main card background gradient
//            LinearGradient(
//                gradient: Gradient(colors: [gradientStartColor, gradientEndColor]),
//                startPoint: .leading,
//                endPoint: .trailing
//            )
//            // Frame must be applied *before* clipping if the clipShape is the primary bounds
//            .frame(width: cardWidth, height: cardHeight)
//             // Apply the specific corner radii based on CSS border-radius: .5rem 2rem;
//             // Order: topLeading, bottomLeading, bottomTrailing, topTrailing
//            .clipShape(UnevenRoundedRectangle(
//                topLeadingRadius: cornerRadiusSmall,   // .5rem
//                bottomLeadingRadius: cornerRadiusLarge, // 2rem
//                bottomTrailingRadius: cornerRadiusSmall, // .5rem
//                topTrailingRadius: cornerRadiusLarge    // 2rem
//            ))
//
//            // Description overlay view
//            descriptionView
//                // Add padding to position from the bottom and leading edges
//                // Corresponds to `bottom: .5rem; left: .5rem;` in CSS
//                .padding(.leading, cornerRadiusSmall) // Use cornerRadiusSmall for consistency
//                .padding(.bottom, cornerRadiusSmall)
//
//        }
//        // Apply shadow to the entire ZStack container
//        // Corresponds to `box-shadow: 0px 15px 20px -5px rgba(0, 0, 0, 0.5);`
//        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 10) // Approximation of CSS shadow
//        // Frame the shadow container if needed, otherwise shadow respects content frame
//        .frame(width: cardWidth, height: cardHeight)
//
//    }
//
//    // Extracted view for the description overlay
//    private var descriptionView: some View {
//        Text(viewModel.card.title) // Use data from ViewModel
//            .font(.headline) // Example font
//            .foregroundColor(descriptionTextColor)
//            .padding(.horizontal, 16) // Approx 1em padding
//            .padding(.vertical, 8)   // Approx .5rem padding
//            // Set width relative to card width (90%)
//            .frame(width: cardWidth * 0.9, alignment: .leading)
//             // Apply background with blur and color
//            .background( // Start background definition
//                 // The background itself is a ZStack to layer blur and color
//                ZStack {
//                     // Bottom layer: the blur effect
//                    // Note: Applying material directly as a background layer
//                    Rectangle().fill(.ultraThinMaterial) // Use a shape filled with the material
//
//                     // Top layer: the semi-transparent color
//                    descriptionBackgroundColor
//                }
//                 // Clip the *entire background ZStack* to the desired shape
//                .clipShape(UnevenRoundedRectangle(
//                    topLeadingRadius: cornerRadiusSmall,
//                    bottomLeadingRadius: cornerRadiusLarge,
//                    bottomTrailingRadius: cornerRadiusSmall,
//                    topTrailingRadius: cornerRadiusLarge
//                ))
//                // Alternatively, if you want the clip shape applied only to the material/color
//                // and not affect the text frame, apply clipShape inside the ZStack:
//                /*
//                ZStack {
//                     Rectangle().fill(.ultraThinMaterial)
//                         .clipShape(...) // Clip material here
//                     descriptionBackgroundColor
//                         .clipShape(...) // Clip color here
//                }
//                */
//
//            ) // End background definition
//            // Ensure text doesn't wrap and uses ellipsis if too long
//            .lineLimit(1)
//            .truncationMode(.tail) // Corresponds to text-overflow: ellipsis; white-space: nowrap;
//    }
//}
//
//// MARK: - Main Content View for Hosting and Preview
//
//struct ContentView: View {
//    var body: some View {
//        ZStack {
//            // Dark background similar to the image context
//            Color.black.opacity(0.85).edgesIgnoringSafeArea(.all)
//
//            // Place the CardView
//            CardView()
//        }
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//// MARK: - Helper for Uneven Rounded Rectangle (Available iOS 16+)
//// Make sure your deployment target is iOS 16 or higher in your project settings.
//// If targeting older versions, you'd need a custom Shape implementation.
//
////// MARK: - App Entry Point
////@main
////struct CardApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
