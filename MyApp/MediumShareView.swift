//
//  MediumShareView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

struct MediumShareView: View {

    // State for simulating dismiss action
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // 1. Background Color
            Color.black.opacity(0.9).ignoresSafeArea()

            // 2. Main Vertical Layout
            VStack(spacing: 0) {
                // 3. Top Bar
                HStack {
                    Button {
                        dismiss() // Action to close the view
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .padding(.leading)

                    Text("Share")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center) // Center title

                    Spacer() // Push button and title correctly
                        .frame(width: 40) // Balance the button width
                }
                .padding(.vertical)
                .background(Color.black.opacity(0.7)) // Slightly different shade for bar maybe

                Spacer() // Pushes content card down slightly

                // 4. Content Card
                contentCardView()
                    .padding(.horizontal, 20) // Give card horizontal padding

                Spacer() // Pushes action bar to bottom

                // 5. Bottom Action Bar
                actionBarView()
            }
        }
    }

    // --- Subviews ---

    @ViewBuilder
    private func contentCardView() -> some View {
        VStack(spacing: 0) {
            // Blurred Image Placeholder
            Rectangle() // Use Rectangle as placeholder
                .fill(.gray.opacity(0.5)) // Placeholder color
                .frame(height: 180) // Approximate height
                .overlay(
                    // Add a subtle gradient or blur effect if needed
                     LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.clear]), startPoint: .top, endPoint: .bottom)
                )
                .blur(radius: 5) // Add blur like the screenshot
                .clipped() // Clip the blur to the frame

            // White Content Area with Vertical Text
            HStack(alignment: .top, spacing: 0) {
                 // Main Content Stack (Left Side)
                 VStack(alignment: .leading, spacing: 12) {
                     Text("8 min read")
                         .font(.caption)
                         .foregroundColor(.gray)
                         .padding(.top) // Give it some top padding within the white area

                     Text("Creating Paging ScrollView using _VariadicView")
                         .font(.title2)
                         .fontWeight(.bold)
                         .foregroundColor(.black)
                         .lineLimit(3) // Allow multiple lines
                         .multilineTextAlignment(.leading)

                     Text("Creating Paging ScrollView using _VariadicView")
                         .font(.subheadline)
                         .foregroundColor(.black.opacity(0.8))
                         .lineLimit(2)
                         .multilineTextAlignment(.leading)

                     Divider().padding(.vertical, 8) // Separator line

                     // Author Info Row
                     HStack {
                         Image(systemName: "person.crop.circle.fill") // Placeholder Profile Pic
                             .resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(width: 30, height: 30)
                             .clipShape(Circle())
                             .foregroundColor(.purple) // Example color like screenshot

                         Text("CongLeSolutionX")
                             .font(.footnote)
                             .fontWeight(.medium)
                             .foregroundColor(.black)

                         Spacer()

                         Text("Medium")
                             .font(.footnote)
                             .fontWeight(.bold)
                             .foregroundColor(.black)
                     }
                     .padding(.bottom) // Bottom padding for author row
                 }
                 .padding(.horizontal) // Padding inside the white area

                 Spacer() // Push vertical text to the right edge

                 // Vertical URL Label (Right Side)
                Text("medium.com/@CongLeSolutionX")
                     .font(.caption2)
                     .foregroundColor(.gray)
                     .kerning(0.5) // Add slight letter spacing
                     .rotationEffect(.degrees(-90))
                     .fixedSize() // Prevent text wrapping during rotation
                     // Adjust position with offset or padding if needed after rotation
                     .frame(width: 150, height: 20, alignment: .trailing) // Adjust frame for rotation space
                     .padding(.trailing, -65) // Negative padding to pull it closer to the edge
                     .padding(.top, 80) // Vertical positioning adjustment

            }
            .background(Color.white) // White background for this section
        }
        .cornerRadius(15) // Rounded corners for the card
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5) // Subtle shadow
        .clipped() // Clip everything to the rounded corners
    }

    @ViewBuilder
    private func actionBarView() -> some View {
         // Action Bar sits on top of a slightly translucent background
         ScrollView(.horizontal, showsIndicators: false) {
             HStack(spacing: 25) { // Spacing between action buttons
                 actionButton(iconName: "link", label: "Copy link")
                 actionButton(iconName: "heart.text.square", label: "Friend Link...") // Approximate icon
                 actionButton(iconName: "square.and.arrow.up", label: "Share via...")
                 actionButton(iconName: "arrow.down.to.line.alt", label: "Save image")
                 actionButton(iconName: "camera.circle", label: "Insta sto...") // Placeholder
                 actionButton(iconName: "ellipsis", label: "More") // Example additional button
             }
             .padding(.horizontal, 20) // Padding for the scroll content
             .padding(.vertical, 15)
         }
         .background(Color.black.opacity(0.8)) // Background for the action bar area
         .frame(height: 100) // Give the action bar area a fixed height
    }

    // Reusable component for action buttons in the bottom bar
    @ViewBuilder
    private func actionButton(iconName: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
                .frame(height: 25) // Ensure icons align vertically

            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
        .frame(width: 65) // Give each button a reasonable width
    }
}

// MARK: - Preview
struct MediumShareView_Previews: PreviewProvider {
    static var previews: some View {
        MediumShareView()
    }
}
