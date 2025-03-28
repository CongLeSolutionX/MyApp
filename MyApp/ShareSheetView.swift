//
//  ShareSheetView.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//


import SwiftUI

struct ShareSheetView: View {
    // State for potential dismissal action
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Bar
            NavigationBarView {
                dismiss() // Action for the close button
            }

            Spacer() // Pushes content towards top and bottom

            // 2. Article Preview Card
            ArticlePreviewCard()
                .padding(.horizontal) // Add some horizontal padding

            Spacer() // Pushes content towards top and bottom

            // 3. Action Buttons
            ActionButtonsView()
                .padding(.bottom) // Add padding at the bottom
                .padding(.top)    // Add padding above the buttons

        }
        .background(Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)) // Dark background
        .foregroundColor(.white) // Default text color for this sheet
    }
}

// MARK: - Navigation Bar Component
struct NavigationBarView: View {
    var closeAction: () -> Void

    var body: some View {
        HStack {
            Button(action: closeAction) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("Share")
                .font(.headline)
                .foregroundColor(.white)

            Spacer()

            // Invisible element to balance the close button
            Image(systemName: "xmark")
                .font(.title2)
                .opacity(0)
        }
        .padding()
        .frame(height: 50) // Typical nav bar height
    }
}

// MARK: - Article Preview Card Component
struct ArticlePreviewCard: View {
    let articleTitle = "Creating Paging ScrollView using _VariadicView"
    let articleSubtitle = "Creating Paging ScrollView using _VariadicView"
    let authorName = "Omar Elsayed"
    let readTime = "8 min read"
    let mediumHandle = "medium.com/@Eng.OmarElsayed"
    let platformName = "Medium"

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Card Content
            VStack(alignment: .leading, spacing: 0) {
                // Blurred Top Area Placeholder
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 180) // Adjust height as needed
                    .blur(radius: 10)
                    .overlay( // Simulate some subtle gradient/lighting
                        LinearGradient(
                            gradient: Gradient(colors: [.black.opacity(0.2), .clear, .black.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Text Content Area
                VStack(alignment: .leading, spacing: 12) {
                    Text(readTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top) // Add padding only at the top of text section

                    Text(articleTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8) // Allow text to shrink slightly

                    Text(articleSubtitle)
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineLimit(2)

                    Divider()
                        .padding(.vertical, 8)

                    // Author Info Footer
                    HStack {
                        Image(systemName: "person.crop.circle.fill") // Placeholder profile pic
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .foregroundColor(.purple) // Placeholder color

                        Text(authorName)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.black)

                        Spacer()

                        Text(platformName)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal) // Padding for text content
                .padding(.bottom)   // Padding at the very bottom of the card
            }

            // Vertical Text // Rotated Text
             Text(mediumHandle)
                 .font(.caption2)
                 .foregroundColor(.gray)
                 .lineLimit(1)
                 .fixedSize() // Prevent text from wrapping
                 .rotationEffect(.degrees(-90))
                 .frame(width: 180, height: 20) // Use fixed frame to help positioning
                 .offset(x: 80, y: 100) // Adjust offset carefully based on frame

        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5) // Add shadow
    }
}

// MARK: - Action Buttons Area Component
struct ActionButtonsView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 15) { // Adjust spacing
            ActionButton(iconName: "link", label: "Copy link")
            ActionButton(iconName: "heart", label: "Friend Link...") // Simplified icon
            ActionButton(iconName: "square.and.arrow.up", label: "Share via...")
            ActionButton(iconName: "arrow.down.to.line", label: "Save image")
            ActionButton(iconName: "camera", label: "Insta sto...") // Placeholder for Instagram
        }
        .padding(.horizontal) // Add padding to the sides of the button row
    }
}

// MARK: - Individual Action Button Component
struct ActionButton: View {
    let iconName: String
    let label: String

    var body: some View {
        Button(action: {
            // Action for each button would go here
            print("\(label) tapped")
        }) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.title2)
                    .frame(height: 30) // Ensure icons have consistent height
                    .foregroundColor(.white)

                Text(label)
                    .font(.caption)
                    .lineLimit(2) // Allow two lines for text like "Friend Link..."
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .frame(width: 70) // Give buttons some width
            }
        }
    }
}

// MARK: - Preview Provider
struct ShareSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheetView()
    }
}
