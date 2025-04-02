//
//  ExperimentalModelsView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//
//
//import SwiftUI
//
//// Data structure for the table rows
//struct ExperimentalModelInfo: Identifiable {
//    let id = UUID()
//    let modelCode: String
//    let baseModel: String
//    let replacementVersion: String
//}
//
//// View displaying the experimental models information
//struct ExperimentalModels_InfoView: View {
//
//    // Data for the previous experimental models table
//    let previousModels: [ExperimentalModelInfo] = [
//        ExperimentalModelInfo(modelCode: "gemini-2.0-pro-exp-02-05", baseModel: "Gemini 2.0 Pro Experimental", replacementVersion: "gemini-2.5-pro-exp-03-25"),
//        // Note: The original image shows 'gemini-2.0-flash' as both base and replacement for 'gemini-2.0-flash-exp'.
//        // Verify if this is intended or if the replacement should be a newer 'flash' model if available.
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
//            VStack(alignment: .leading, spacing: 15) {
//                // --- Main Title ---
//                Text("Experimental models")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.bottom, 5)
//
//                // --- Introductory Paragraph ---
//                Text("In addition to the production ready models, the Gemini API offers experimental models (not for production use, as defined in our ")
//                + Text("Terms").foregroundColor(.blue) // Simulate link
//                + Text(").")
//
//                Text("We release experimental models to gather feedback, get our latest updates into the hands of developers quickly, and highlight the pace of innovation happening at Google. What we learn from experimental launches informs how we release models more widely. An experimental model can be swapped for another without prior notice. We don’t guarantee that an experimental model will become a stable model in the future.")
//                    .font(.body)
//                    .lineSpacing(4)
//
//                Divider().padding(.vertical, 10)
//
//                // --- Previous Models Section ---
//                Text("Previous experimental models")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .padding(.bottom, 5)
//
//                Text("As new versions or stable releases become available, we remove and replace experimental models. You can find the previous experimental models we released in the following section along with the replacement version:")
//                    .font(.body)
//                    .lineSpacing(4)
//                    .padding(.bottom, 10)
//
//                // --- Models Table ---
//                // Using Grid for better alignment
//                Grid(alignment: .leading, horizontalSpacing: 15, verticalSpacing: 10) {
//                    // Header Row
//                    GridRow {
//                        Text("Model code")
//                            .font(.headline)
//                        Text("Base model")
//                            .font(.headline)
//                        Text("Replacement version")
//                            .font(.headline)
//                    }
//                    .padding(.bottom, 5)
//                    // Separator below header
//                    Divider()
//                        .gridCellUnsizedAxes(.horizontal) // Make divider span grid width
//
//                    // Data Rows
//                    ForEach(previousModels) { model in
//                        GridRow(alignment: .top) { // Align content to the top of the cell
//                            Text(model.modelCode)
//                                .font(.system(.body, design: .monospaced)) // Monospaced for code-like text
//                                .textSelection(.enabled) // Allow text selection
//                            Text(model.baseModel)
//                                .textSelection(.enabled)
//                            Text(model.replacementVersion)
//                                .font(.system(.body, design: .monospaced))
//                                .textSelection(.enabled)
//                        }
//                        // Separator between rows
//                         Divider()
//                            .gridCellUnsizedAxes(.horizontal)
//                     }
//                }
//                .padding(.top) // Padding above the grid
//                .overlay( // Add a border around the grid area for visual structure
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                )
//
//            }
//            .padding() // Padding around the main VStack
//        }
//    }
//}
//
//// Preview Provider for Xcode Canvas
//struct ExperimentalModelsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExperimentalModels_InfoView()
//    }
//}
