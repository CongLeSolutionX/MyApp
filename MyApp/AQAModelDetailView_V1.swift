//
//  AQAModelDetailView_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//
import SwiftUI

// Data structure to hold the model property details
struct AQAModel_ModelProperty: Identifiable {
    let id = UUID()
    let iconName: String
    let propertyName: String
    let description: String
    let isSupportedBadge: Bool = false // Flag for special styling like the "Supported" badge
    let descriptionDetail: String? // For multi-line descriptions like token limits
}

// The main view displaying the AQA model details
struct AQAModelDetailView_V1: View {
    // Array containing the properties from the screenshot
    let properties: [AQAModel_ModelProperty] = [
        AQAModel_ModelProperty(iconName: "number.square", propertyName: "Model code", description: "models/aqa", descriptionDetail: nil),
        AQAModel_ModelProperty(iconName: "doc.text", propertyName: "Supported data types", description: "Input", descriptionDetail: "Text"),
        AQAModel_ModelProperty(iconName: "globe", propertyName: "Supported language", description: "English", descriptionDetail: nil),
        AQAModel_ModelProperty(iconName: "timer", propertyName: "Token limits[*]", description: "Input token limit", descriptionDetail: "7,168"),
        AQAModel_ModelProperty(iconName: "gauge", propertyName: "Rate limits[**]", description: "1,500 requests per minute", descriptionDetail: nil),
        AQAModel_ModelProperty(iconName: "shield.lefthalf.filled", propertyName: "Adjustable safety settings", description: "Supported", descriptionDetail: nil),
        AQAModel_ModelProperty(iconName: "calendar", propertyName: "Latest update", description: "December 2023", descriptionDetail: nil)
    ]

    // Separate properties for multi-part descriptions
    let outputDataType = AQAModel_ModelProperty(iconName: "", propertyName: "", description: "Output", descriptionDetail: "Text")
    let outputTokenLimit = AQAModel_ModelProperty(iconName: "", propertyName: "", description: "Output token limit", descriptionDetail: "1,024")

    var body: some View {
        ScrollView { // Use ScrollView for potentially longer content
            VStack(alignment: .leading, spacing: 16) {
                // Header Section
                HStack {
                    Text("AQA")
                        .font(.title.bold())
                    Image(systemName: "link") // Link icon next to title
                        .foregroundColor(.gray)
                    Spacer() // Push title to the left
                }

                Text("You can use the AQA model to perform **Attributed Question-Answering (AQA)**-related tasks over a document, corpus, or a set of passages. The AQA model returns answers to questions that are grounded in provided sources, along with estimating answerable probability.")
                    .font(.body)
                    .foregroundColor(.secondary)

                // Model Details Section
                GroupBox("Model details") {
                    VStack(spacing: 12) {
                        // Table Header (Optional, for clarity)
                        HStack {
                            Text("Property")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Description")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundColor(.secondary)
                        Divider()

                        // Dynamically create rows for each property
                        ForEach(properties) { property in
                            AQAModel_PropertyRow(property: property)
                            // Handle special cases for multi-part descriptions
                            if property.propertyName == "Supported data types" {
                                AQAModel_PropertyRow(property: outputDataType, isSubItem: true) // Indent or align differently if needed
                            }
                            if property.propertyName == "Token limits[*]" {
                                AQAModel_PropertyRow(property: outputTokenLimit, isSubItem: true)
                            }
                            Divider() // Separator after each property group
                        }
                    }
                }

                // Footer Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("See the [examples](https://example.com/aqa-examples) to explore the capabilities of these model variations.") // Placeholder URL
                        .font(.footnote)

                    Text("[*] A token is equivalent to about 4 characters for Gemini models. 100 tokens are about 60-80 English words.")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("[**] Rate limits footnote if needed.") // Placeholder for second footnote if it exists
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .hidden() // Hide if not present in the original full image
                }

            }
            .padding() // Add padding around the entire content
        }
    }
}

// Reusable view for displaying a single property row
struct AQAModel_PropertyRow: View {
    let property: AQAModel_ModelProperty
    var isSubItem: Bool = false // To handle indentation/alignment for sub-items

    var body: some View {
        HStack(alignment: .top) {
            // Property Column (Icon and Name)
            HStack(spacing: 8) {
                if !isSubItem { // Only show icon for main properties
                    Image(systemName: property.iconName)
                        .foregroundColor(.blue) // Match icon color
                        .frame(width: 20, alignment: .center) // Fixed width for alignment
                } else {
                    Spacer().frame(width: 20) // Placeholder for alignment
                }
                Text(property.propertyName)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Description Column
            VStack(alignment: .leading) {
                if property.isSupportedBadge {
                    Text(property.description)
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                } else {
                    Text(property.description)
                        .lineLimit(nil) // Allow text wrapping
                }

                if let detail = property.descriptionDetail {
                    Text(detail)
                       .foregroundColor(.secondary)
                       .lineLimit(nil)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
         }
         .padding(.leading, isSubItem ? 28 : 0) // Indent sub-items
    }
}

// Preview Provider for Xcode Canvas
struct AQAModelDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AQAModelDetailView_V1()
    }
}

// Helper to hide views conditionally
extension View {
    @ViewBuilder func hidden() -> some View {
        self.opacity(0).frame(height: 0)
    }
}
