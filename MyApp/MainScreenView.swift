//
//  MainScreenView.swift
//  MyApp
//
//  Created by Cong Le on 3/10/25.
//

import SwiftUI

// Enum representing the capture modes.
enum CaptureMode {
    case singleScene
    case multiScene
    case importPhotos
}

// The main view that serves as the scene reconstruction home.
struct MainScreenView: View {
    @State private var showCaptureOptions = false
    @State private var selectedMode: CaptureMode? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Title and information about the main screen.
                Text("Main App Screen")
                    .font(.largeTitle)
                    .padding(.top, 20)
                
                // The Capture button.
                Button(action: {
                    showCaptureOptions = true
                }) {
                    Text("Capture")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Scene Reconstruction")
            .confirmationDialog("Select Capture Mode", isPresented: $showCaptureOptions, titleVisibility: .visible) {
                Button("Single Scene") {
                    selectedMode = .singleScene
                }
                Button("Multi-Scene (Stitching)") {
                    selectedMode = .multiScene
                }
                Button("Import from Photos") {
                    selectedMode = .importPhotos
                }
                Button("Cancel", role: .cancel) {
                    // Do nothing on cancel.
                }
            }
            // Navigation link that activates when a capture mode is selected.
            .background(
                NavigationLink(
                    destination: destinationView(),
                    isActive: Binding(
                        get: { selectedMode != nil },
                        set: { newValue in if !newValue { selectedMode = nil } }
                    )
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    // Chooses the destination view based on the selected capture mode.
    @ViewBuilder
    private func destinationView() -> some View {
        switch selectedMode {
        case .singleScene:
            SingleSceneCaptureScreen_Full_Implementation()
        case .multiScene:
            MultiSceneCaptureScreen()
        case .importPhotos:
            PhotoLibraryPickerScreen()
        case .none:
            EmptyView()
        }
    }
}

// Stub view representing the Single Scene Capture screen.
//struct SingleSceneCaptureScreen: View {
//    var body: some View {
//        VStack {
//            Text("Single Scene Capture Screen")
//                .font(.title)
//                .padding()
//            // Implementation for live camera feed and guidance overlay would go here.
//            Spacer()
//        }
//        .navigationTitle("Single Scene Capture")
//    }
//}

// Stub view representing the Multi-Scene Capture screen.
struct MultiSceneCaptureScreen: View {
    var body: some View {
        VStack {
            Text("Multi-Scene Capture Screen")
                .font(.title)
                .padding()
            // Implementation for managing overlapping scenes and guidance overlay goes here.
            Spacer()
        }
        .navigationTitle("Multi-Scene Capture")
    }
}

// Stub view representing the Photo Library Picker screen.
struct PhotoLibraryPickerScreen: View {
    var body: some View {
        VStack {
            Text("Photo Library Picker")
                .font(.title)
                .padding()
            // Implementation to present and select photos from the library goes here.
            Spacer()
        }
        .navigationTitle("Import from Photos")
    }
}

// Preview for SwiftUI canvas.
struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
    }
}
