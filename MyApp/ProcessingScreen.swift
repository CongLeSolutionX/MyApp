//
//  ProcessingScreen.swift
//  MyApp
//
//  Created by Cong Le on 3/10/25.
//

import SwiftUI

// Define processing stages for the reconstruction workflow
enum ProcessingStage: String, CaseIterable {
    case stereoMatching = "Performing Stereo Matching..."
    case pointCloud = "Generating Point Cloud..."
    case meshCreation = "Creating Mesh..."
    case textureApplication = "Applying Texture..."
    case complete = "Processing Complete"
}

struct ProcessingScreen: View {
    // Current stage index tracks progress within ProcessingStage.allCases array
    @State private var currentStageIndex: Int = 0
    // Flag to indicate whether processing is currently active
    @State private var isProcessing: Bool = true
    // Timer to simulate asynchronous processing updates
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 40) {
            Text("Scene Reconstruction")
                .font(.title)
                .padding()

            // ProgressView updated based on current processing stage
            ProgressView(value: Double(currentStageIndex), total: Double(ProcessingStage.allCases.count - 1))
                .progressViewStyle(LinearProgressViewStyle())
                .padding()

            // Display current processing status text
            Text(ProcessingStage.allCases[currentStageIndex].rawValue)
                .font(.headline)
                .padding()
            
            // Either show a cancel button during processing or a navigation link when complete
            if isProcessing {
                Button(action: cancelProcessing) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            } else {
                NavigationLink(destination: ResultScreen()) {
                    Text("Go To Result")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
        }
        .onAppear {
            startProcessing()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // Simulate background processing by updating the stage every two seconds
    func startProcessing() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            if currentStageIndex < ProcessingStage.allCases.count - 1 {
                currentStageIndex += 1
            } else {
                isProcessing = false
                timer?.invalidate()
            }
        }
    }
    
    // Cancel processing by invalidating the timer and resetting the view state
    func cancelProcessing() {
        timer?.invalidate()
        // Here you can add logic to navigate back to the main app screen.
        // For this example, we simply reset the progress.
        currentStageIndex = 0
        isProcessing = false
    }
}

// A simple placeholder for the 3D model result screen.
// In a full implementation, SceneKit or RealityKit could be used to display the reconstructed scene.
struct ResultScreen: View {
    var body: some View {
        VStack {
            Text("3D Model Result")
                .font(.largeTitle)
                .padding()
            Spacer()
            Rectangle()
                .fill(Color.gray)
                .frame(width: 300, height: 300)
                .overlay(
                    Text("3D Model Viewer")
                        .foregroundColor(.white)
                )
            Spacer()
        }
        .navigationBarTitle("Result", displayMode: .inline)
    }
}

// Preview for SwiftUI Canvas
struct ProcessingScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProcessingScreen()
        }
    }
}
