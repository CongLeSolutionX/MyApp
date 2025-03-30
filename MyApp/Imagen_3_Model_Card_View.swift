//
//  Imagen_3_Model_Card_View.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// Reusable View for a common Icon + Label pattern
struct IconLabel: View {
    let iconName: String
    let label: String
    let iconColor: Color = .accentColor // Use accent color for icons

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.subheadline.weight(.medium)) // Slightly smaller icon font
                .foregroundColor(iconColor)
                .frame(width: 25, alignment: .center) // Fixed width for alignment
            Text(label)
                .font(.headline) // Make property labels stand out more
        }
    }
}

// Reusable View Modifier for the Card Style
struct ModernCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding() // Add padding inside the card
            .background(Color(.secondarySystemGroupedBackground)) // Subtle background color
            .cornerRadius(12) // Standard iOS corner radius
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow for elevation
    }
}

// Extension to easily apply the card background modifier
extension View {
    func modernCardStyle() -> some View {
        modifier(ModernCardBackground())
    }
}

// Main view displaying all Imagen 3 details with modern card styling
struct Imagen3ModernDetailsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { // Increased spacing between elements

                // --- Header Section ---
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Imagen 3")
                            .font(.largeTitle) // More prominent title
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "link")
                            .foregroundColor(.secondary)
                    }

                    Text("Imagen 3 is our highest quality text-to-image model, capable of generating images with even better detail, richer lighting and fewer distracting artifacts than our previous models.")
                        .font(.subheadline) // Slightly smaller description font
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal) // Add horizontal padding to header/description

                // --- Details Card ---
                VStack(alignment: .leading, spacing: 18) { // Generous spacing inside card

                    // Section: Model Identifier
                    VStack(alignment: .leading, spacing: 8) {
                        IconLabel(iconName: "display.and.arrow.down", label: "Model Identifier") // Changed icon, more descriptive label
                        Text("Gemini API: `imagen-3.0-generate-002`")
                            .font(.system(.callout, design: .monospaced)) // Monospaced for code
                            .foregroundColor(.primary)
                            .padding(.leading, 33) // Indent value under the IconLabel's text
                    }

                    Divider().padding(.vertical, 5) // Subtle separator between sections

                    // Section: Capabilities
                    VStack(alignment: .leading, spacing: 12) {
                        // Supported Data Types
                        VStack(alignment: .leading, spacing: 5) {
                            IconLabel(iconName: "arrow.left.arrow.right.square", label: "Data Flow") // Changed icon/label
                            HStack {
                                Text("Input:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Text")
                                    .font(.callout).fontWeight(.medium)
                            }
                            .padding(.leading, 33)

                            HStack {
                                Text("Output:")
                                     .font(.caption)
                                     .foregroundColor(.secondary)
                                Text("Images")
                                     .font(.callout).fontWeight(.medium)
                             }
                             .padding(.leading, 33)
                        }

                        // Token Limits (Grouped under Capabilities)
                        VStack(alignment: .leading, spacing: 5) {
                           IconLabel(iconName: "number.square", label: "Limits") // Changed icon/label
                           HStack {
                               Text("Input Tokens:")
                                   .font(.caption)
                                   .foregroundColor(.secondary)
                               Text("N/A")
                                   .font(.callout).fontWeight(.medium)
                           }
                           .padding(.leading, 33)

                           HStack {
                               Text("Image Outputs:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                               Text("Up to 4")
                                    .font(.callout).fontWeight(.medium)
                            }
                            .padding(.leading, 33)
                        }
                    }

                    Divider().padding(.vertical, 5)

                    // Section: Metadata
                    VStack(alignment: .leading, spacing: 5) {
                        IconLabel(iconName: "calendar.badge.clock", label: "Last Updated") // Changed icon/label
                        Text("February 2025")
                            .font(.callout)
                            .foregroundColor(.primary)
                             .padding(.leading, 33)
                    }
                }
                .modernCardStyle() // Apply the reusable card style
                .padding(.horizontal) // Add horizontal padding around the card

                Spacer() // Pushes content up if screen is large
            }
            .padding(.vertical) // Overall vertical padding
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Background for the whole view area
    }
}

// Preview Provider for Xcode Canvas
struct Imagen3ModernDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Imagen3ModernDetailsView()
            .preferredColorScheme(.light) // Preview in light mode
            .previewDisplayName("Light Mode")

        Imagen3ModernDetailsView()
            .preferredColorScheme(.dark) // Preview in dark mode
             .previewDisplayName("Dark Mode")
    }
}
