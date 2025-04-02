//
//  GeminiEmbedingView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// Represents a single row in the model details section
struct GeminiEmbedingView_V2_PropertyRow<DescriptionContent: View>: View {
    let iconName: String
    let propertyLabel: String
    let descriptionView: DescriptionContent // Use a generic ViewBuilder for flexibility

    // Initializer accepting a ViewBuilder for the description content
    init(iconName: String, propertyLabel: String, @ViewBuilder descriptionView: () -> DescriptionContent) {
        self.iconName = iconName
        self.propertyLabel = propertyLabel
        self.descriptionView = descriptionView()
    }

    // Convenience initializer for simple Text descriptions
    init(iconName: String, propertyLabel: String, descriptionText: String) where DescriptionContent == Text {
        self.init(iconName: iconName, propertyLabel: propertyLabel) {
            Text(descriptionText)
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Property Column
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .frame(width: 20, alignment: .center) // Align icons
                    .foregroundStyle(.blue) // Use a consistent icon color
                Text(propertyLabel)
                    .font(.system(.body))
            }
            .frame(minWidth: 180, alignment: .leading) // Ensure consistent width for property label

            // Description Column
            descriptionView
                .frame(maxWidth: .infinity, alignment: .leading) // Take remaining space
        }
        .padding(.vertical, 10) // Slightly increased padding for better spacing
        .padding(.horizontal) // Add horizontal padding to the row content
    }
}

// A view specifically for the note box
struct NoteBox: View {
    let text: AttributedString

    init() {
        // Construct the attributed string for the note
        var noteString = AttributedString("Note: ")
        noteString.font = .body.weight(.bold) // Bold "Note:"

        var restOfString = AttributedString("Text Embedding is the newer version of the Embedding model. If you're creating a new project, use Text Embedding.")
        restOfString.font = .body

        self.text = noteString + restOfString
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .foregroundStyle(.blue)
            Text(text)
                .font(.callout) // Slightly smaller font for the note
                .fixedSize(horizontal: false, vertical: true) // Allow text wrapping
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Take full width
        .background(Color.blue.opacity(0.1)) // Light blue background
        .clipShape(RoundedRectangle(cornerRadius: 8)) // Rounded corners
    }
}

// Main view to display the Embedding model details
struct EmbeddingModelView: View {
    var body: some View {
        ScrollView { // Use ScrollView if content might exceed screen height
            VStack(alignment: .leading, spacing: 16) {
                // Header Section
                Text("Embedding")
                    .font(.largeTitle) // Larger title
                    .fontWeight(.semibold)

                // Note Box
                NoteBox()

                // Description Text
                Text("You can use the Embedding model to generate **text embeddings** for input text.")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Text("The Embedding model is optimized for creating embeddings with 768 dimensions for text of up to 2,048 tokens.")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                // Model Details Section
                Text("Embedding model details")
                    .font(.title2) // Slightly larger section title
                    .fontWeight(.medium)
                    .padding(.top)

                // Container for the details (mimics the card style)
                VStack(alignment: .leading, spacing: 0) {
                    // Header Row (implicit in the original image, added for clarity)
                    HStack {
                        Text("Property")
                            .font(.headline)
                            .foregroundStyle(.secondary) // Use secondary color for headers
                            .frame(minWidth: 180, alignment: .leading)
                        Text("Description")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                    Divider()

                    // Model Code Row
                    GeminiEmbedingView_V2_PropertyRow(iconName: "person.text.rectangle", propertyLabel: "Model code") {
                        Text("`models/embedding-001`")
                            .font(.system(.body, design: .monospaced))
                    }

                    Divider()

                    // Supported Data Types Row
                    GeminiEmbedingView_V2_PropertyRow(iconName: "doc.text", propertyLabel: "Supported data types") {
                        HStack(alignment: .top, spacing: 30) { // Align Input/Output cols
                            VStack(alignment: .leading) {
                                Text("Input").fontWeight(.medium)
                                Text("Text")
                            }
                            VStack(alignment: .leading) {
                                Text("Output").fontWeight(.medium)
                                Text("Text embeddings")
                            }
                        }
                    }

                    Divider()

                    // Token Limits Row
                    GeminiEmbedingView_V2_PropertyRow(iconName: "clock.arrow.circlepath", propertyLabel: "Token limits") {
                         HStack(alignment: .top, spacing: 30) { // Align Input/Output cols
                            VStack(alignment: .leading) {
                                Text("Input token limit").fontWeight(.medium)
                                Text("2,048")
                            }
                            VStack(alignment: .leading) {
                                Text("Output dimension size").fontWeight(.medium)
                                Text("768")
                            }
                        }
                    }

                    Divider()

                    // Rate Limits Row - New
                    //GeminiEmbedingView_V2_PropertyRow(iconName: "gauge.medium", propertyLabel: "Rate limits", descriptionView: "1,500 requests per minute")

                    Divider()

                    // Adjustable Safety Settings Row - New
                    GeminiEmbedingView_V2_PropertyRow(iconName: "shield.lefthalf.filled", propertyLabel: "Adjustable safety settings") {
                        Text("Not supported")
                            .foregroundStyle(.red) // Use red color for emphasis
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.15)) // Subtle red background
                            .clipShape(Capsule()) // Capsule shape like a tag
                    }

                    Divider()

                    // Latest Update Row
                    GeminiEmbedingView_V2_PropertyRow(iconName: "calendar", propertyLabel: "Latest update", descriptionText: "December 2023")

                }
                .background(Color(.systemGroupedBackground)) // Use standard grouped background
                .clipShape(RoundedRectangle(cornerRadius: 10)) // Rounded corners
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Slightly more subtle border
                )

            }
            .padding() // Add padding around the entire content
        }
    }
}

// Preview Provider
struct EmbeddingModelView_Previews: PreviewProvider {
    static var previews: some View {
        EmbeddingModelView()
           // .previewLayout(.sizeThatFits) // Adjust preview size if needed
           // .frame(width: 600) // Set a width for better preview on larger screens
    }
}
