////
////  ModelSelectorView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//// ModelSelectorView.swift
//import SwiftUI
//import WhisperKit
//
//struct ModelSelectorView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//
//    var body: some View {
//        GroupBox("Model Management") { // Using GroupBox for card style
//            VStack {
//                HStack {
//                    // Model Status Indicator
//                    Image(systemName: "circle.fill")
//                        .foregroundStyle(viewModel.modelState.color)
//                        .symbolEffect(.variableColor.iterative.reversing, isActive: viewModel.modelState.isProcessing)
//                    Text(viewModel.modelState.description)
//                        .font(.headline)
//
//                    Spacer()
//
//                    // Model Picker
//                    if !viewModel.availableModels.isEmpty {
//                         Picker("", selection: $settings.selectedModel) {
//                             ForEach(viewModel.availableModels, id: \.self) { model in
//                                 HStack {
//                                     Image(systemName: viewModel.localModels.contains(model) ? "checkmark.circle.fill" : "arrow.down.circle")
//                                         .foregroundColor(viewModel.localModels.contains(model) ? .green : .blue)
//                                     Text(model.friendlyName).tag(model) // Use extension for friendly name
//                                }
//                             }
//                         }
//                         .pickerStyle(.menu)
//                         .disabled(viewModel.modelState.isProcessing) // Disable during load/download
//                     } else {
//                         ProgressView().scaleEffect(0.8) // Show loading indicator if models aren't loaded yet
//                     }
//
//                    // Action Buttons
//                    deleteButton
//                    folderButton // macOS only
//                    repoLinkButton
//                }
//
//                 // Loading / Progress View
//                if viewModel.modelState == .loading || viewModel.modelState == .prewarming || viewModel.modelState == .downloading {
//                     VStack(alignment: .leading) {
//                         ProgressView(value: viewModel.downloadProgress, total: 1.0)
//                         Text(viewModel.modelState == .prewarming ? "Specializing model (\(String(format: "%.0f", viewModel.downloadProgress * 100))%)..." : "\(viewModel.modelState.description) (\(String(format: "%.0f", viewModel.downloadProgress * 100))%)...")
//                             .font(.caption)
//                             .foregroundColor(.secondary)
//                     }
//                     .padding(.top, 5)
//                 } else if viewModel.modelState == .unloaded {
//                     // Load Button
//                    Button {
//                        viewModel.loadSelectedModel()
//                    } label: {
//                        Label("Load Model", systemImage: "bolt.fill")
//                             .frame(maxWidth: .infinity)
//                    }
//                     .buttonStyle(.borderedProminent)
//                     .padding(.top, 5)
//                     .disabled(settings.selectedModel.isEmpty) // Disable if no model selected
//                }
//            }
//        }
//    }
//
//    // --- Subviews for Buttons ---
//
//    private var deleteButton: some View {
//        Button {
//            viewModel.deleteSelectedModel()
//        } label: {
//            Image(systemName: "trash")
//        }
//        .help("Delete Selected Model")
//        .buttonStyle(.borderless)
//        .foregroundColor(.red)
//        .disabled(!viewModel.localModels.contains(settings.selectedModel) || viewModel.modelState.isProcessing)
//    }
//
//    #if os(macOS)
//    private var folderButton: some View {
//        Button {
//            viewModel.openModelFolder()
//        } label: {
//            Image(systemName: "folder")
//        }
//        .help("Show Model Folder")
//        .buttonStyle(.borderless)
//        .disabled(!viewModel.modelFolderExists || viewModel.modelState.isProcessing) // Check if folder exists via ViewModel
//    }
//    #else
//    private var folderButton: some View { EmptyView() }
//    #endif
//
//    private var repoLinkButton: some View {
//        Button {
//            viewModel.openRepoURL()
//        } label: {
//            Image(systemName: "link.circle")
//        }
//        .help("Open Model Repository")
//        .buttonStyle(.borderless)
//    }
//}
//
//// MARK: - Helpers / Extensions
//
//extension String {
//    // Simple helper to make model names more readable in the picker
//    var friendlyName: String {
//        self.replacingOccurrences(of: "_", with: " ").capitalized
//    }
//}
//
//extension ModelState {
//    var color: Color {
//        switch self {
//        case .loaded: .green
//        case .loading, .prewarming, .downloading: .yellow
//        case .unloaded: .red
//        default: .gray // Handle potential future cases
//        }
//    }
//
//    var isProcessing: Bool {
//        switch self {
//         case .loading, .prewarming, .downloading: true
//         default: false
//        }
//    }
//}
