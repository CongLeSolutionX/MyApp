//
//  GeminiModelVariantsView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// MARK: - Data Model

struct GeminiModel: Identifiable {
    let id = UUID() // Conformance to Identifiable for ForEach
    let name: String
    let identifier: String
    let inputs: String
    let outputs: String
    let optimizedFor: String
}

// MARK: - Data Source

// Populate the data based on the provided image
let geminiModels: [GeminiModel] = [
    GeminiModel(
        name: "Gemini 2.5 Pro Experimental",
        identifier: "gemini-2.5-pro-exp-03-25",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "Enhanced thinking and reasoning, multimodal understanding, advanced coding, and more"
    ),
    GeminiModel(
        name: "Gemini 2.0 Flash",
        identifier: "gemini-2.0-flash",
        inputs: "Audio, images, videos, and text",
        outputs: "Text, images (experimental), and audio (coming soon)",
        optimizedFor: "Next generation features, speed, thinking, realtime streaming, and multimodal generation"
    ),
    GeminiModel(
        name: "Gemini 2.0 Flash-Lite",
        identifier: "gemini-2.0-flash-lite",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "Cost efficiency and low latency"
    ),
    GeminiModel(
        name: "Gemini 1.5 Flash",
        identifier: "gemini-1.5-flash",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "Fast and versatile performance across a diverse variety of tasks"
    ),
    GeminiModel(
        name: "Gemini 1.5 Flash-8B",
        identifier: "gemini-1.5-flash-8b",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "High volume and lower intelligence tasks"
    ),
    GeminiModel(
        name: "Gemini 1.5 Pro",
        identifier: "gemini-1.5-pro",
        inputs: "Audio, images, videos, and text",
        outputs: "Text",
        optimizedFor: "Complex reasoning tasks requiring more intelligence"
    ),
    GeminiModel(
        name: "Gemini Embedding",
        identifier: "gemini-embedding-exp",
        inputs: "Text",
        outputs: "Text embeddings",
        optimizedFor: "Measuring the relatedness of text strings"
    ),
    GeminiModel(
        name: "Imagen 3",
        identifier: "imagen-3.0-generate-002",
        inputs: "Text",
        outputs: "Images",
        optimizedFor: "Our most advanced image generation model"
    )
]

// MARK: - Reusable Row View (Optional but good practice)

struct ModelRowView: View {
    let model: GeminiModel
    let columnMinWidth: CGFloat = 80 // Adjust as needed for layout

    var body: some View {
        HStack(alignment: .top, spacing: 15) { // Align content to the top for varying heights
            // Model Variant Column
            VStack(alignment: .leading) {
                Text(model.name)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(model.identifier)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(minWidth: columnMinWidth, maxWidth: .infinity, alignment: .leading)

            // Input(s) Column
            Text(model.inputs)
                .font(.body)
                .frame(minWidth: columnMinWidth, maxWidth: .infinity, alignment: .leading)

            // Output Column
            Text(model.outputs)
                .font(.body)
                .frame(minWidth: columnMinWidth, maxWidth: .infinity, alignment: .leading)

            // Optimized For Column
            Text(model.optimizedFor)
                .font(.body)
                .frame(minWidth: columnMinWidth * 1.5, maxWidth: .infinity, alignment: .leading) // Give this column more space potentially
        }
        .padding(.vertical, 8) // Add some vertical padding within the row
    }
}

// MARK: - Main Content View

struct GeminiModelVariantsView_V1: View {
    let models: [GeminiModel] = geminiModels // Use the populated data
    let headerMinWidth: CGFloat = 80 // Match min width for alignment if needed

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { // Use spacing 0 and add padding manually or via Divider
                // Title
                Text("Model variants")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                // Description
                Text("The Gemini API offers different models that are optimized for specific use cases. Here’s a brief overview of Gemini variants that are available:")
                    .font(.body)
                    .padding(.bottom, 16)

                // Table Header
                HStack(alignment: .top, spacing: 15) {
                    Text("Model variant")
                        .font(.headline)
                        .frame(minWidth: headerMinWidth, maxWidth: .infinity, alignment: .leading)
                    Text("Input(s)")
                         .font(.headline)
                        .frame(minWidth: headerMinWidth, maxWidth: .infinity, alignment: .leading)
                    Text("Output")
                         .font(.headline)
                        .frame(minWidth: headerMinWidth, maxWidth: .infinity, alignment: .leading)
                    Text("Optimized for")
                         .font(.headline)
                        .frame(minWidth: headerMinWidth * 1.5, maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 5)

                Divider() // Separator below header

                // Table Rows
                ForEach(models) { model in
                    ModelRowView(model: model) // Use the reusable row view
                    Divider() // Separator between rows
                }

                // Footer Text
                // Note: Making "rate limits page" a real link requires Link view and a URL.
                // Here we simulate the appearance.
                 HStack {
                     Text("You can view the rate limits for each model on the ")
                     + Text("rate limits page.") // Append text
                         .foregroundColor(.blue) // Simulate link color
                     + Text(".") // Add the final period if needed (or adjust above)

                 }
                 .font(.footnote)
                 .padding(.top, 16)

            }
            .padding() // Add padding around the entire VStack content
        }
    }
}

// MARK: - Preview

#Preview {
    GeminiModelVariantsView_V1()
}
