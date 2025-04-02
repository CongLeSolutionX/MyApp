////
////  ExperimentalModels_CardDesignView.swift
////  MyApp
////
////  Created by Cong Le on 4/1/25.
////
//
//import SwiftUI
//
//// Data structure remains the same
//struct ExperimentalModelInfo: Identifiable {
//    let id = UUID()
//    let modelCode: String
//    let baseModel: String
//    let replacementVersion: String
//}
//
//// The main view adopting the card design
//struct ExperimentalModelsCardView: View {
//    
//    // Data for the previous experimental models
//    let previousModels: [ExperimentalModelInfo] = [
//        ExperimentalModelInfo(modelCode: "gemini-2.0-pro-exp-02-05", baseModel: "Gemini 2.0 Pro Experimental", replacementVersion: "gemini-2.5-pro-exp-03-25"),
//        ExperimentalModelInfo(modelCode: "gemini-2.0-flash-exp", baseModel: "Gemini 2.0 Flash", replacementVersion: "gemini-2.0-flash"),
//        ExperimentalModelInfo(modelCode: "gemini-exp-1206", baseModel: "Gemini 2.0 Pro", replacementVersion: "gemini-2.0-pro-exp-02-05"),
//        ExperimentalModelInfo(modelCode: "gemini-2.0-flash-thinking-exp-1219", baseModel: "Gemini 2.0 Flash Thinking", replacementVersion: "gemini-2.0-flash-thinking-exp-01-21"),
//        ExperimentalModelInfo(modelCode: "gemini-exp-1121", baseModel: "Gemini", replacementVersion: "gemini-exp-1206"),
//        ExperimentalModelInfo(modelCode: "gemini-exp-1114", baseModel: "Gemini", replacementVersion: "gemini-exp-1206"),
//        ExperimentalModelInfo(modelCode: "gemini-1.5-pro-exp-0827", baseModel: "Gemini 1.5 Pro", replacementVersion: "gemini-exp-1206"),
//        ExperimentalModelInfo(modelCode: "gemini-1.5-pro-exp-0801", baseModel: "Gemini 1.5 Pro", replacementVersion: "gemini-exp-1206"),
//        ExperimentalModelInfo(modelCode: "gemini-1.5-flash-8b-exp-0924", baseModel: "Gemini 1.5 Flash-8B", replacementVersion: "gemini-1.5-flash-8b"),
//        ExperimentalModelInfo(modelCode: "gemini-1.5-flash-8b-exp-0827", baseModel: "Gemini 1.5 Flash-8B", replacementVersion: "gemini-1.5-flash-8b")
//    ]
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) { // Spacing between cards
//                // --- Card 1: Introduction ---
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Experimental models")
//                        .font(.title) // Slightly smaller than largeTitle for card context
//                        .fontWeight(.bold)
//                    
//                    Text("In addition to the production ready models, the Gemini API offers experimental models (not for production use, as defined in our ")
//                    + Text("Terms").foregroundColor(.blue).fontWeight(.medium) // Simulate link
//                    + Text(").")
//                    
//                    Text("We release experimental models to gather feedback, get our latest updates into the hands of developers quickly, and highlight the pace of innovation happening at Google. What we learn from experimental launches informs how we release models more widely. An experimental model can be swapped for another without prior notice. We don’t guarantee that an experimental model will become a stable model in the future.")
//                        .font(.callout) // Slightly smaller body text for cards
//                        .lineSpacing(4)
//                        .foregroundColor(.secondary) // Subtle contrast
//                }
//                .padding() // Internal padding for the card content
//                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous)) // Use material background
//                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2) // Subtle shadow
//                
//                // --- Card 2: Previous Models ---
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Previous experimental models")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                    
//                    Text("As new versions or stable releases become available, we remove and replace experimental models. Below are previous models and their replacements:")
//                        .font(.callout)
//                        .lineSpacing(4)
//                        .foregroundColor(.secondary)
//                        .padding(.bottom, 8) // Space before the list starts
//                    
//                    // --- List of Models (within the card) ---
//                    VStack(spacing: 0) { // No spacing, divider handles it
//                        ForEach(previousModels) { model in
//                            ExperimentalModelsCardView_ModelDetailRow(model: model)
//                            // Add divider unless it's the last item
//                            if model.id != previousModels.last?.id {
//                                Divider().padding(.leading) // Indent divider slightly
//                            }
//                        }
//                    }
//                    .background(Color(.systemBackground)) // Ensure list area has solid background if needed
//                    .clipShape(RoundedRectangle(cornerRadius: 10)) // Clip inner list slightly
//                    .overlay( // Add subtle border to the list container
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                    )
//                    
//                }
//                .padding() // Internal padding for the card content
//                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
//                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//                
//            }
//            .padding() // Padding around the main VStack containing the cards
//        }
//        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Background for the whole screen
//    }
//}
//
//// Subview for displaying each model's details in a structured row
//struct ExperimentalModelsCardView_ModelDetailRow: View {
//    let model: ExperimentalModelInfo
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text("Model Code:")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .frame(width: 100, alignment: .leading) // Align labels
//                Text(model.modelCode)
//                    .font(.system(.callout, design: .monospaced))
//                    .fontWeight(.medium)
//                    .textSelection(.enabled)
//                Spacer() // Push content to the left
//            }
//            
//            HStack {
//                Text("Base Model:")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .frame(width: 100, alignment: .leading)
//                Text(model.baseModel)
//                    .font(.callout)
//                    .textSelection(.enabled)
//                Spacer()
//            }
//            
//            HStack {
//                Text("Replaced By:")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .frame(width: 100, alignment: .leading)
//                Text(model.replacementVersion)
//                    .font(.system(.callout, design: .monospaced))
//                    .fontWeight(.medium)
//                    .textSelection(.enabled)
//                Spacer()
//            }
//        }
//        .padding(.vertical, 12) // Padding top/bottom for each row
//        .padding(.horizontal) // Padding left/right for each row
//    }
//}
//
//// Preview Provider
//struct ExperimentalModelsCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExperimentalModelsCardView()
//            .preferredColorScheme(.light) // Preview in light mode
//        
//        ExperimentalModelsCardView()
//            .preferredColorScheme(.dark) // Preview in dark mode
//    }
//}
