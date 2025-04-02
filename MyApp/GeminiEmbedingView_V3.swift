//
//  GeminiEmbedingView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// --- Reusable Components (Slightly Refined) ---

// Represents a single row in the model details card
struct DetailRow<DescriptionContent: View>: View {
    let iconName: String
    let propertyLabel: String
    let descriptionView: DescriptionContent

    init(iconName: String, propertyLabel: String, @ViewBuilder descriptionView: () -> DescriptionContent) {
        self.iconName = iconName
        self.propertyLabel = propertyLabel
        self.descriptionView = descriptionView()
    }

    init(iconName: String, propertyLabel: String, descriptionText: String) where DescriptionContent == Text {
        self.init(iconName: iconName, propertyLabel: propertyLabel) {
            Text(descriptionText)
                .foregroundStyle(.secondary) // Use secondary color for simple text values
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Property Column
             HStack(spacing: 10) { // Slightly more spacing
                Image(systemName: iconName)
                    .frame(width: 20, alignment: .center)
                    .foregroundStyle(.blue) // Keep theme color for icon
                Text(propertyLabel)
                    .font(.callout) // Use callout for slightly smaller property labels
                    .foregroundStyle(.primary) // Ensure property label is primary
            }
            .frame(width: 180, alignment: .leading) // Fixed width for alignment

            // Description Column
            descriptionView
                 .font(.callout) // Match font size for description content generally
                 .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12) // More vertical padding per row
    }
}

// Refined Note Box
struct InfoNoteBox: View {
    let text: AttributedString

    init() {
        var noteString = AttributedString("Note: ")
        noteString.font = .subheadline.weight(.semibold) // Slightly bolder/larger "Note"
        noteString.foregroundColor = .blue // Use accent color

        var restOfString = AttributedString("Text Embedding is the newer version of the Embedding model. If you're creating a new project, use Text Embedding.")
        restOfString.font = .subheadline
        restOfString.foregroundColor = .secondary // Make note text less prominent

        self.text = noteString + restOfString
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill") // Use info icon
                .foregroundStyle(.blue)
                .font(.headline) // Slightly larger icon
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12) // Generous padding
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.blue.opacity(0.1)) // Subtle background tint
        .clipShape(RoundedRectangle(cornerRadius: 10)) // Softer corners
    }
}

// --- Main View with Modern Card Design ---

struct EmbeddingModelModernView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { // Increased overall spacing
                // Header
                Text("Embedding Model") // Simplified Title
                    .font(.largeTitle.weight(.bold)) // Bolder title
                    .padding(.bottom, -8) // Adjust spacing below title

                // Info Note (Outside the main card)
                InfoNoteBox()

                // Description Text (clearer separation)
                VStack(alignment: .leading, spacing: 8) {
                     Text("Use this model to generate **text embeddings** for input text.")
                        .font(.body)
                        .foregroundStyle(.secondary) // Use secondary for descriptive text
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Optimized for creating embeddings with 768 dimensions for text up to 2,048 tokens.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // --- The Modern Card ---
                VStack(alignment: .leading, spacing: 0) { // No spacing handled by rows/dividers

                    // Card Header (Optional, but adds structure)
                     Text("Model Details")
                         .font(.headline.weight(.semibold))
                         .padding([.top, .horizontal])
                         .padding(.bottom, 8)

                    Divider().padding(.horizontal) // Inset divider

                    // Model Code Row
                    DetailRow(iconName: "number.square", propertyLabel: "Model ID") { // Changed icon/label slightly
                        Text("`models/embedding-001`")
                            .font(.system(.callout, design: .monospaced))
                             .foregroundStyle(.secondary)
                             .padding(.vertical, 2) // Add padding for background
                             .background(Color.secondary.opacity(0.1)) // Subtle code background
                             .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // Supported Data Types Row
                    DetailRow(iconName: "doc.plaintext", propertyLabel: "Data Types") { // Changed icon
                        HStack(alignment: .top, spacing: 24) {
                            VStack(alignment: .leading) {
                                Text("Input").font(.caption.weight(.medium)).textCase(.uppercase).foregroundStyle(.tertiary)
                                Text("Text").foregroundStyle(.secondary)
                            }
                            VStack(alignment: .leading) {
                                Text("Output").font(.caption.weight(.medium)).textCase(.uppercase).foregroundStyle(.tertiary)
                                Text("Text embeddings").foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // Token Limits Row
                     DetailRow(iconName: "arrow.left.arrow.right.square", propertyLabel: "Limits") { // Changed icon
                         HStack(alignment: .top, spacing: 24) {
                            VStack(alignment: .leading) {
                                Text("Input Tokens").font(.caption.weight(.medium)).textCase(.uppercase).foregroundStyle(.tertiary)
                                Text("2,048") .foregroundStyle(.secondary)
                            }
                            VStack(alignment: .leading) {
                                Text("Output Dim.").font(.caption.weight(.medium)).textCase(.uppercase).foregroundStyle(.tertiary)
                                Text("768").foregroundStyle(.secondary)
                            }
                        }
                    }
                     .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // Rate Limits Row
                    DetailRow(iconName: "speedometer", propertyLabel: "Rate Limit", descriptionText: "1,500 / minute") // Streamlined text
                        .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // Adjustable Safety Settings Row
                    DetailRow(iconName: "shield.slash", propertyLabel: "Safety Settings") { // Changed icon
                        Text("Not supported")
                            .font(.caption.weight(.medium)) // Smaller text for tag
                            .foregroundStyle(.orange) // Use orange for warning/unsupported
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15)) // Subtle background
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // Latest Update Row
                    DetailRow(iconName: "calendar.badge.clock", propertyLabel: "Last Updated", descriptionText: "December 2023") // Changed icon
                        .padding(.horizontal)

                }
                // --- Card Styling ---
                 .background(.regularMaterial) // Use background material!
                 .clipShape(RoundedRectangle(cornerRadius: 16)) // Slightly larger corner radius
                 .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4) // Subtle shadow

            }
            .padding() // Padding for the whole ScrollView content
        }
         .background(Color(.systemGroupedBackground)) // Set a background for the ScrollView area
         .navigationTitle("Embedding Model") // Example if used in Navigation
         .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview Provider
struct EmbeddingModelModernView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Add NavigationView for context
             EmbeddingModelModernView()
        }
        .previewDisplayName("Light Mode")

         NavigationView {
             EmbeddingModelModernView()
         }
        .preferredColorScheme(.dark) // Preview Dark Mode
        .previewDisplayName("Dark Mode")

    }
}
