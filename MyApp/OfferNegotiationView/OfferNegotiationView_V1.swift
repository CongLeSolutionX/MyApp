////
////  OfferNegotiationView.swift
////  MyApp
////
////  Created by Cong Le on 4/7/25.
////
//
//import SwiftUI
//
//// Represents the data for a single package
//struct OfferPackage: Identifiable {
//    let id = UUID()
//    let title: String
//    let description: String
//    let price: String
//    let guaranteedIncrease: String // Could be parsed further if needed
//}
//
//struct OfferNegotiationView_V1: View {
//    // State to track the selected package
//    @State private var selectedPackageId: UUID?
//
//    // Sample package data
//    let packages = [
//        OfferPackage(title: "Professional Package", description: "Guaranteed increase of $2,500 from initial offer. At least 1+ years of experience.", price: "$1,250", guaranteedIncrease: "$2,500"),
//        OfferPackage(title: "Senior Package", description: "Guaranteed increase of $5,000 from initial offer. For third level ICs or higher.", price: "$2,450", guaranteedIncrease: "$5,000"),
//        OfferPackage(title: "Leadership Package", description: "Guaranteed increase of $20,000 from initial offer. Principal level or senior manager+.", price: "$5,000", guaranteedIncrease: "$20,000")
//    ]
//
//    // Placeholder for company logos - replace with actual images or more sophisticated views
//    let companyLogos = ["g.circle.fill", "s.circle.fill", "figure.wave.circle.fill", "chart.bar.fill", "apps.iphone", "questionmark.circle.fill"]
//    let prominentLogoIndex = 2 // Index for the larger logo (Facebook placeholder)
//
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            // Background Color
//            Color.black
//                .ignoresSafeArea()
//
//            // Main Scrollable Content
//            ScrollView {
//                VStack(spacing: 30) { // Increased spacing between major sections
//                    Spacer() // Pushes content down slightly from the top (adjust as needed)
//                        .frame(height: 40) // Space for close button and status bar
//
//                    // Icon Row and Bubble Area
//                    IconBubbleArea(logos: companyLogos, prominentIndex: prominentLogoIndex)
//
//                    // Header Text Section
//                    TextHeader()
//
//                    // Packages Selection List
//                    PackagesListView(packages: packages, selectedPackageId: $selectedPackageId)
//
//                    // Action Buttons Section
//                    ActionButtons()
//
//                    Spacer() // Pushes content up from bottom
//                }
//                .padding(.horizontal) // Add horizontal padding to the main VStack
//            }
//            .padding(.top, 20) // Add padding to prevent content from going under potential custom top bars or close button
//
//            // Close Button Overlay
//            CloseButton {
//                // Add close action here
//                print("Close button tapped")
//            }
//            .padding(.trailing) // Padding for the close button
//            .padding(.top, 10)  // Padding from top edge
//        }
//        .preferredColorScheme(.dark) // Ensure dark mode appearance
//    }
//}
//
//// MARK: - Subviews
//
//struct IconBubbleArea: View {
//    let logos: [String]
//    let prominentIndex: Int
//
//    var body: some View {
//        ZStack(alignment: .top) {
//            // Company Logos Row
//            HStack(spacing: 15) {
//                ForEach(logos.indices, id: \.self) { index in
//                    Image(systemName: logos[index]) // Use system names as placeholders
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: index == prominentIndex ? 55 : 35, height: index == prominentIndex ? 55 : 35)
//                        .foregroundColor(index == prominentIndex ? .blue : .gray.opacity(0.8)) // Example prominent color
//                        .clipShape(index == prominentIndex ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 8))) // Style differently
//                        .opacity(index == prominentIndex ? 1.0 : 0.6) // Dim non-prominent logos
//                }
//            }
//            .padding(.top, 35) // Push logos down to make space for the bubble
//
//            // "+$100K" Bubble
//            Text("+$100K")
//                .font(.headline)
//                .fontWeight(.bold)
//                .foregroundColor(.green)
//                .padding(.horizontal, 15)
//                .padding(.vertical, 8)
//                .background(Color(white: 0.15)) // Dark gray background
//                .clipShape(Capsule())
//                .overlay(
//                    Capsule()
//                        .stroke(Color(white: 0.3), lineWidth: 1) // Subtle border
//                )
//                // Simple offset for positioning - more complex geometry needed for exact pointer
//                .offset(y: -10)
//        }
//    }
//}
//
//struct TextHeader: View {
//    var body: some View {
//        VStack(spacing: 10) {
//            Text("Get Paid, Not Played")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//
//            Text("Interviewing or negotiating an offer? We'll help you maximize your offer. Risk-free.")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal) // Constrain width slightly
//        }
//    }
//}
//
//struct PackagesListView: View {
//    let packages: [OfferPackage]
//    @Binding var selectedPackageId: UUID?
//
//    var body: some View {
//        VStack(spacing: 15) {
//            ForEach(packages) { package in
//                PackageView(
//                    package: package,
//                    isSelected: package.id == selectedPackageId
//                )
//                .onTapGesture {
//                    selectedPackageId = package.id
//                }
//            }
//        }
//    }
//}
//
//struct PackageView: View {
//    let package: OfferPackage
//    let isSelected: Bool
//
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) {
//            // Radio Button
//            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
//                .foregroundColor(isSelected ? .blue : .gray) // Indicate selection visually
//                .font(.title2)
//
//            // Title and Description
//            VStack(alignment: .leading, spacing: 4) {
//                Text(package.title)
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white)
//                Text(package.description)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .lineLimit(2) // Limit description lines if needed
//            }
//
//            Spacer() // Pushes price to the right
//
//            // Price
//            Text(package.price)
//                .font(.headline)
//                .fontWeight(.semibold)
//                .foregroundColor(.white)
//        }
//        .padding() // Padding inside the card
//        .background(Color(white: 0.1)) // Dark gray background for the card
//        .cornerRadius(12)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(isSelected ? Color.blue.opacity(0.7) : Color(white: 0.3), lineWidth: isSelected ? 2 : 1) // Highlight selected border
//        )
//    }
//}
//
//struct ActionButtons: View {
//    var body: some View {
//        VStack(spacing: 15) {
//            // Maximize Offer Button
//            Button {
//                // Add action for maximizing offer
//                print("Maximize Offer tapped")
//            } label: {
//                Text("Maximize Offer")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.blue) // Text color as per screenshot
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color(white: 0.25)) // Button background color
//                    .cornerRadius(12)
//            }
//
//            // Terms & Conditions Link
//            Button {
//                // Add action for viewing terms
//                print("View Terms & Conditions tapped")
//            } label: {
//                Text("View Terms & Conditions")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .underline() // Make it look like a link
//            }
//        }
//    }
//}
//
//struct CloseButton: View {
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: "xmark")
//                .font(.system(size: 12, weight: .bold))
//                .foregroundColor(.black) // Icon color
//                .padding(8)
//                .background(Color.gray.opacity(0.8)) // Background color similar to screenshot
//                .clipShape(Circle())
//        }
//    }
//}
//
//// Custom shape for easier previewing
//struct AnyShape: Shape {
//    private let builder: (CGRect) -> Path
//
//    init<S: Shape>(_ shape: S) {
//        builder = { rect in
//            shape.path(in: rect)
//        }
//    }
//
//    func path(in rect: CGRect) -> Path {
//        builder(rect)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    OfferNegotiationView_V1()
//}
