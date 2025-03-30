//
//  Imagen_3_Model_Detail_View.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// Represents a single detail item in the model information list
struct ModelDetailRow: View {
    let iconName: String
    let property: String
    let descriptionView: AnyView // Use AnyView to allow different description layouts

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icon and Property Name
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .foregroundColor(.blue) // Match icon color from image
                    .frame(width: 20, alignment: .center) // Ensure consistent icon spacing
                Text(property)
                    .font(.body)
            }
            .frame(minWidth: 180, alignment: .leading) // Minimum width for consistency

            Spacer() // Pushes description to the right

            // Description View
            descriptionView
                .font(.body)
                .multilineTextAlignment(.leading) // Align text to leading edge
                .frame(maxWidth: .infinity, alignment: .leading) // Take remaining space

        }
        .padding(.vertical, 10) // Vertical padding for each row
    }
}

// Main view displaying all Imagen 3 details
struct Imagen3DetailsView: View {
    var body: some View {
        ScrollView { // Allow scrolling if content exceeds screen height
            VStack(alignment: .leading, spacing: 15) {

                // Header: Model Name and Link Icon
                HStack {
                    Text("Imagen 3")
                        .font(.title)
                        .fontWeight(.semibold)
                    Image(systemName: "link")
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 5)

                // Model Description Paragraph
                Text("Imagen 3 is our highest quality text-to-image model, capable of generating images with even better detail, richer lighting and fewer distracting artifacts than our previous models.")
                    .font(.body)
                    .foregroundColor(.secondary) // Match the slightly muted text color
                    .padding(.bottom, 15)

                // Model Details Section Header
                Text("Model details")
                    .font(.headline)
                    .padding(.bottom, 5)

                // Card container for details
                VStack(alignment: .leading, spacing: 0) {
                    // Header Row Separator (mimics the table header line)
                    Divider()

                    // Model Code Row
                    ModelDetailRow(
                        iconName: "display", // System icon similar to computer screen
                        property: "Model code",
                        descriptionView: AnyView(
                            Text("Gemini API\n`imagen-3.0-generate-002`") // Use markdown for code style
                                .font(.system(.body, design: .monospaced))
                        )
                    )
                    Divider() // Separator between rows

                    // Supported Data Types Row
                    ModelDetailRow(
                        iconName: "doc.text", // System icon similar to document
                        property: "Supported data types",
                        descriptionView: AnyView(
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Input:")
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                    Text("Text")
                                }
                                HStack {
                                    Text("Output:")
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                    Text("Images")
                                }
                            }
                        )
                    )
                    Divider()

                    // Token Limits Row
                    ModelDetailRow(
                        iconName: "t.circle", // System icon for 'T'/Token
                        property: "Token limits",
                        descriptionView: AnyView(
                             VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Input token limit:")
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                    Text("N/A")
                                }
                                HStack {
                                    Text("Output images:")
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                    Text("Up to 4")
                                }
                            }
                        )
                    )
                    Divider()

                    // Latest Update Row
                    ModelDetailRow(
                        iconName: "calendar", // System icon for calendar
                        property: "Latest update",
                        descriptionView: AnyView(
                            Text("February 2025")
                        )
                    )
                     Divider() // Final Divider

                }
                .background(Color(.systemBackground)) // Ensure background matches system
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Border like the image
                )

            }
            .padding() // Overall padding for the content
        }
    }
}

// Preview Provider for Xcode Canvas
struct Imagen3DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Imagen3DetailsView()
            .preferredColorScheme(.light) // Preview in light mode
    }
}
