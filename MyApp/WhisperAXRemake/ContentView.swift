//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

//  ContentView.swift
//  WhisperAX (Enhanced)
//
//  For licensing see accompanying LICENSE.md file.
//  Copyright © 2024 Argmax, Inc. All rights reserved.
//

import SwiftUI
import WhisperKit

struct ContentView: View {
    // Use @StateObject for the ViewModel lifecycle tied to the View
    @StateObject private var viewModel = ContentViewModel()
    // AppSettings can be passed via environment or directly if preferred
    @StateObject private var settings = AppSettings()

    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isFilePickerPresented = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView()
                .navigationTitle("WhisperAX")
                .navigationSplitViewColumnWidth(min: 300, ideal: 350)
                 // Pass viewModel and settings down
                .environmentObject(viewModel)
                .environmentObject(settings)

        } detail: {
            DetailView()
                 // Pass viewModel and settings down
                .environmentObject(viewModel)
                .environmentObject(settings)
                .fileImporter(
                    isPresented: $isFilePickerPresented,
                    allowedContentTypes: [.audio], // Adjust as needed
                    allowsMultipleSelection: false
                 ) { result in
                     handleFilePicker(result: result)
                 }
        }
        .onAppear {
            // Initial setup if needed, though most is in ViewModel init
        }
        // Alert for showing errors from ViewModel
        .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _,_ in viewModel.errorMessage = nil } )) {
             Button("OK", role: .cancel) { }
         } message: {
             Text(viewModel.errorMessage ?? "An unknown error occurred.")
         }
    }
    
    // Handle file picker result and pass to ViewModel
    func handleFilePicker(result: Result<[URL], Error>) async {
         switch result {
         case .success(let urls):
             guard let url = urls.first else { return }
             await viewModel.transcribeFile(url: url)
         case .failure(let error):
             viewModel.errorMessage = "Failed to pick file: \(error.localizedDescription)"
         }
     }
}

// MARK: - Previews
#Preview {
    ContentView()
    #if os(macOS)
        .frame(width: 900, height: 600)
    #endif
}
