//
//  ExperimentalModels_MoreCardDesignView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// Data structure remains the same
struct ExperimentalModelInfo: Identifiable {
    let id = UUID()
    let modelCode: String
    let baseModel: String
    let replacementVersion: String
}

// --- Main View ---
struct ExperimentalModelsIndividualCardsView: View {

    // Data for the previous experimental models
    let previousModels: [ExperimentalModelInfo] = [
        ExperimentalModelInfo(modelCode: "gemini-2.0-pro-exp-02-05", baseModel: "Gemini 2.0 Pro Experimental", replacementVersion: "gemini-2.5-pro-exp-03-25"),
        ExperimentalModelInfo(modelCode: "gemini-2.0-flash-exp", baseModel: "Gemini 2.0 Flash", replacementVersion: "gemini-2.0-flash"),
        ExperimentalModelInfo(modelCode: "gemini-exp-1206", baseModel: "Gemini 2.0 Pro", replacementVersion: "gemini-2.0-pro-exp-02-05"),
        ExperimentalModelInfo(modelCode: "gemini-2.0-flash-thinking-exp-1219", baseModel: "Gemini 2.0 Flash Thinking", replacementVersion: "gemini-2.0-flash-thinking-exp-01-21"),
        ExperimentalModelInfo(modelCode: "gemini-exp-1121", baseModel: "Gemini", replacementVersion: "gemini-exp-1206"),
        ExperimentalModelInfo(modelCode: "gemini-exp-1114", baseModel: "Gemini", replacementVersion: "gemini-exp-1206"),
        ExperimentalModelInfo(modelCode: "gemini-1.5-pro-exp-0827", baseModel: "Gemini 1.5 Pro", replacementVersion: "gemini-exp-1206"),
        ExperimentalModelInfo(modelCode: "gemini-1.5-pro-exp-0801", baseModel: "Gemini 1.5 Pro", replacementVersion: "gemini-exp-1206"),
        ExperimentalModelInfo(modelCode: "gemini-1.5-flash-8b-exp-0924", baseModel: "Gemini 1.5 Flash-8B", replacementVersion: "gemini-1.5-flash-8b"),
        ExperimentalModelInfo(modelCode: "gemini-1.5-flash-8b-exp-0827", baseModel: "Gemini 1.5 Flash-8B", replacementVersion: "gemini-1.5-flash-8b")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) { // Increased spacing between elements
                // --- Card 1: Introduction ---
                // (Same as previous Card-Based Design)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Experimental models")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("In addition to the production ready models, the Gemini API offers experimental models (not for production use, as defined in our ")
                    + Text("Terms").foregroundColor(.blue).fontWeight(.medium) // Simulate link
                    + Text(").")

                    Text("We release experimental models to gather feedback, get our latest updates into the hands of developers quickly, and highlight the pace of innovation happening at Google. What we learn from experimental launches informs how we release models more widely. An experimental model can be swapped for another without prior notice. We don’t guarantee that an experimental model will become a stable model in the future.")
                        .font(.callout)
                        .lineSpacing(4)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                // --- Previous Models Section Header (Not a Card) ---
                 VStack(alignment: .leading, spacing: 5) { // Tighter spacing for header text
                     Text("Previous experimental models")
                         .font(.title2)
                         .fontWeight(.semibold)
                         .padding(.top, 5) // Add a bit space above title

                     Text("As new versions or stable releases become available, experimental models are removed or replaced. Below are previously available models:")
                         .font(.caption) // Make explanation smaller
                         .lineSpacing(3)
                         .foregroundColor(.secondary)
                 }
                 // No background/shadow needed for this header section

                // --- Grid of Individual Model Cards ---
                // Using LazyVGrid for potentially better performance with many cards
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) { // One column grid, spacing between cards
                    ForEach(previousModels) { model in
                        ModelCardView(model: model)
                    }
                }

            }
            .padding() // Padding around the main VStack
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Background for the whole screen
        .navigationTitle("Gemini Models") // Example Navigation Title
        .navigationBarTitleDisplayMode(.inline)
    }
}

// --- Subview for a Single Model Card ---
struct ModelCardView: View {
    let model: ExperimentalModelInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Card Title: Model Code
            Text(model.modelCode)
                .font(.system(.headline, design: .monospaced)) // Monospaced headline
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .textSelection(.enabled)

            Divider()

            // Base Model Info
            HStack(alignment: .top) { // Align top for labels/values
                Text("Based on:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 85, alignment: .leading) // Fixed width label

                Text(model.baseModel)
                    .font(.callout)
                    .foregroundColor(.primary.opacity(0.9))
                    .textSelection(.enabled)

                Spacer() // Push to left
            }

             // Replacement Info
            HStack(alignment: .top) {
                 Text("Replaced by:")
                     .font(.caption)
                     .foregroundColor(.secondary)
                     .frame(width: 85, alignment: .leading)

                 Text(model.replacementVersion)
                     .font(.system(.callout, design: .monospaced)) // Monospaced replacement code
                     .foregroundColor(.primary.opacity(0.9))
                     .textSelection(.enabled)

                 Spacer()
             }
        }
        .padding() // Internal padding for the card
        .background(.background) // Use standard background color (adapts)
        .overlay( // Use overlay for border instead of background for better material layering if needed later
            RoundedRectangle(cornerRadius: 12)
                 .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
        // .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1) // Optional subtle shadow
         .cornerRadius(12) // Apply corner radius *after* overlay if stroke is used
    }
}

// --- Preview Provider ---
struct ExperimentalModelsIndividualCardsView_Previews: PreviewProvider {
    static var previews: some View {
         NavigationView { // Embed in NavigationView for Title
            ExperimentalModelsIndividualCardsView()
         }
        .preferredColorScheme(.light)

         NavigationView {
             ExperimentalModelsIndividualCardsView()
         }
        .preferredColorScheme(.dark)
    }
}
