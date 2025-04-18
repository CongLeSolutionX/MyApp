////
////  DetailView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//// DetailView.swift
//import SwiftUI
//
//struct DetailView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    // isFilePickerPresented needs to be managed here or passed up
//    @Binding var isFilePickerPresented: Bool // Assuming it's passed down
//
//    var body: some View {
//        VStack {
//            TranscriptionDisplayView() // Uses viewModel, settings
//                .layoutPriority(1) // Allow text view to expand
//
//            Divider()
//
//            ControlsView(isFilePickerPresented: $isFilePickerPresented) // Uses viewModel, settings
//        }
//        .padding()
//        .toolbar {
//            ToolbarItem {
//                Button {
//                    viewModel.copyTranscriptionToClipboard()
//                } label: {
//                    Label("Copy Text", systemImage: "doc.on.doc")
//                }
//                .keyboardShortcut("c", modifiers: .command)
//            }
//        }
//    }
//}
//
//// DetailView needs to be initialized with the binding in ContentView
//// Example modification in ContentView:
//// DetailView(isFilePickerPresented: $isFilePickerPresented)
////     .environmentObject(viewModel)
////     .environmentObject(settings)
////     ... fileImporter ...
