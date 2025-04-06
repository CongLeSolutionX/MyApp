//
//  CarouselView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// Simple shapes for placeholder preview (reusable)
struct Triangle_V4: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Represents the content visual within a carousel item
struct PlaceholderItemView: View {
    let label: String
    let itemWidth: CGFloat // Allow specifying width
    let itemHeight: CGFloat // Allow specifying height

    // Adjust shape size based on container size
    private var shapeScaleFactor: CGFloat { min(itemWidth / 100, itemHeight / 120 ) }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background for the item itself
            RoundedRectangle(cornerRadius: 10) // Smaller corner radius for item
                .fill(Color(.systemGray4))
                .frame(width: itemWidth, height: itemHeight)

            // Shapes within the item
            VStack(spacing: 8 * shapeScaleFactor) {
                Spacer()
                Triangle_V4()
                    .fill(Color(.systemGray))
                    .frame(width: 40 * shapeScaleFactor, height: 30 * shapeScaleFactor)

                Rectangle() // Square shape
                    .fill(Color(.systemGray))
                    .frame(width: 30 * shapeScaleFactor, height: 30 * shapeScaleFactor)
                Spacer()
                 Spacer() // Add more space to push shapes up a bit
            }
            .frame(height: itemHeight * 0.8) // Limit shape vertical space

            // Label like "1st", "2nd"
            Text(label)
                .font(.system(size: 10 * shapeScaleFactor)) // Scale font size
                .padding(4 * shapeScaleFactor)
                .background(Circle().fill(Color(.systemGray2)))
                .foregroundColor(.white)
                .padding(6 * shapeScaleFactor) // Padding from the corner
        }
    }
}

// Main View showing the two preview types
struct CarouselPreviewsView: View {
    let cardCornerRadius: CGFloat = 16
    let previewBackgroundColor = Color(.systemGroupedBackground) // Light background for previews
    let outerBackgroundColor = Color(.darkGray) // Dark background overall

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // 1. Simplified Navigation Bar
            HStack {
                Image(systemName: "chevron.left")
                    .font(.title3)
                Text("Material Design Kit / Carousel") // Approximate Title
                    .font(.headline)
                 Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
             .foregroundColor(.white) // Text color on dark background

            // 2. Previews Area
            HStack(alignment: .top, spacing: 20) {
                // Standard Carousel Preview
                VStack(spacing: 8) {
                    ZStack {
                        // Background card for the preview
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .fill(previewBackgroundColor)
                            .frame(height: 150) // Approx height

                        // Simulate horizontal scroll/peek
                        HStack(spacing: 10) {
                            PlaceholderItemView(label: "1st", itemWidth: 100, itemHeight: 120)
                            PlaceholderItemView(label: "2nd", itemWidth: 100, itemHeight: 120)
                        }
                         .padding(.leading, 15) // Indent items slightly
                    }
                    .clipped() // Clip the peeking item

                    Text("Carousel")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel)) // Lighter text for caption
                }

                // Full Screen Carousel Preview
                VStack(spacing: 8) {
                    ZStack {
                        // Background card for the preview
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .fill(previewBackgroundColor)
                            .frame(height: 200) // Taller for full screen

                        // Single centered item
                        PlaceholderItemView(label: "1st", itemWidth: 80, itemHeight: 180) // Narrower item
                         .padding(.vertical, 10) // Add vertical padding within card
                    }

                    Text("Carousel - Full screen")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            .padding(.horizontal)

            Spacer() // Push content to the top
        }
        .padding(.top) // Add padding at the very top
        .background(outerBackgroundColor.ignoresSafeArea()) // Set overall background
        .preferredColorScheme(.dark) // Match dark theme
    }
}

#Preview {
    CarouselPreviewsView()
}
