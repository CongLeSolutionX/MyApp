//
//  geminiEmbeddedView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// Represents a single row in the model details section
struct PropertyRow<DescriptionContent: View>: View {
    let iconName: String
    let propertyLabel: String
    let descriptionView: DescriptionContent // Use a generic ViewBuilder for flexibility

    init(iconName: String, propertyLabel: String, @ViewBuilder descriptionView: () -> DescriptionContent) {
        self.iconName = iconName
        self.propertyLabel = propertyLabel
        self.descriptionView = descriptionView()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Property Column
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .frame(width: 20, alignment: .center) // Align icons
                    .foregroundStyle(.blue)
                Text(propertyLabel)
                    .font(.system(.body))
            }
            .frame(minWidth: 180, alignment: .leading) // Ensure consistent width for property label

            // Description Column
            descriptionView
                .frame(maxWidth: .infinity, alignment: .leading) // Take remaining space
        }
        .padding(.vertical, 8)
    }
}

// Main view to display the Gemini Embedding details
struct GeminiEmbeddingView_V1: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header Section
            HStack(alignment: .center) {
                Image(systemName: "minus.circle.fill") // Mimic the icon next to the title
                    .foregroundStyle(.gray)
                Text("Gemini Embedding Experimental")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            // Description Text
            Text("Gemini embedding achieves a **SOTA performance** across many key dimensions including code, multi-lingual, and retrieval.")
                .font(.body)
                 .fixedSize(horizontal: false, vertical: true) // Allow text wrapping

            // Model Details Section
            Text("Model details")
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top)

            // Container for the details (mimics the card style)
            VStack(alignment: .leading, spacing: 0) {
                // Header Row (implicit in the original image, added for clarity)
                HStack {
                    Text("Property")
                        .font(.headline)
                        .frame(minWidth: 180, alignment: .leading)
                    Text("Description")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .foregroundStyle(.secondary)

                Divider()

                // Model Code Row
                PropertyRow(iconName: "person.text.rectangle", propertyLabel: "Model code") {
                    VStack(alignment: .leading){
                         Text("Gemini API")
                         Text("`gemini-embedding-exp-03-07`")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Supported Data Types Row
                PropertyRow(iconName: "doc.text", propertyLabel: "Supported data types") {
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
                .padding(.horizontal)

                Divider()

                // Token Limits Row
                PropertyRow(iconName: "clock.arrow.circlepath", propertyLabel: "Token limits") {
                     HStack(alignment: .top, spacing: 30) { // Align Input/Output cols
                        VStack(alignment: .leading) {
                            Text("Input token limit").fontWeight(.medium)
                            Text("8,192")
                        }
                        VStack(alignment: .leading) {
                            Text("Output dimension size").fontWeight(.medium)
                            Text("Elastic, supports: 3072, 1536, or 768")
                                .fixedSize(horizontal: false, vertical: true) // Allow wrap
                        }
                    }
                }
                .padding(.horizontal)

                Divider()

                // Latest Update Row
                PropertyRow(iconName: "calendar", propertyLabel: "Latest update") {
                    Text("March 2025")
                }
                .padding(.horizontal)

            }
            .background(Color(.secondarySystemBackground)) // Use a subtle background color
            .clipShape(RoundedRectangle(cornerRadius: 10)) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Subtle border
            )

            Spacer() // Pushes content to the top
        }
        .padding() // Add padding around the entire content
    }
}

// Preview Provider
struct GeminiEmbeddingView_Previews: PreviewProvider {
    static var previews: some View {
        GeminiEmbeddingView_V1()
            .previewLayout(.sizeThatFits) // Adjust preview size
    }
}
