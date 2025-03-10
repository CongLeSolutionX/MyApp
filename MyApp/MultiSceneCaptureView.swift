//
//  MultiSceneCaptureView.swift
//  MyApp
//
//  Created by Cong Le on 3/10/25.
//

import SwiftUI
import AVFoundation

struct MultiSceneCaptureView: View {
    // UI state for tracking capture status and stored capture images
    @State private var captureStatus: CaptureStatus = .idle
    @State private var capturedScenes: [UIImage] = []
    @State private var showAlert = false
    @State private var processing = false
    
    enum CaptureStatus {
        case idle
        case capturing
        case captured
        case processing
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // A placeholder for the live camera feed.
                CameraFeedView()
                    .edgesIgnoringSafeArea(.all)
                
                // Guidance overlay with overlap indicator and capture instructions.
                GuidanceOverlayView(capturedScenes: capturedScenes)
                
                // Capture button at the bottom of the screen.
                VStack {
                    Spacer()
                    Button(action: {
                        captureScene()
                    }) {
                        Circle()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.red)
                            .overlay(
                                Image(systemName: "camera")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.bottom, 30)
                }
                
                // An overlay for processing progress.
                if processing {
                    ProcessingOverlayView()
                }
            }
            .navigationBarTitle("Multi-Scene Capture", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Attention"),
                      message: Text("An error occurred during capture or processing."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Simulated method to capture a scene.
    func captureScene() {
        captureStatus = .capturing
        // Simulate a delay to mimic capture using AVFoundation.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // For demonstration, we randomly decide whether capture is successful.
            if Bool.random() {
                // Using a dummy image for demonstration; replace with actual captured frame.
                if let sampleImage = UIImage(systemName: "photo") {
                    capturedScenes.append(sampleImage)
                }
                // Check if enough overlap (arbitrarily set to 3 captures).
                if capturedScenes.count >= 3 {
                    processing = true
                    processCapturedScenes()
                } else {
                    captureStatus = .idle
                }
            } else {
                showAlert = true
                captureStatus = .idle
            }
        }
    }
    
    // Simulated processing of captured scenes.
    func processCapturedScenes() {
        // Simulate a processing delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            processing = false
            // In a full implementation, you would navigate to a preview screen.
            showAlert = true
        }
    }
}

// A simple placeholder view for the live camera feed.
struct CameraFeedView: View {
    var body: some View {
        Color.black.overlay(
            Text("Live Camera Feed")
                .foregroundColor(.white)
                .font(.headline)
        )
    }
}

// An overlay view that shows capture progress and instructions.
struct GuidanceOverlayView: View {
    var capturedScenes: [UIImage]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Overlap: \(capturedScenes.count) captured")
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
            }
            Spacer()
            Text("Move to next viewpoint")
                .padding(8)
                .background(Color.black.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom, 100)
        }
    }
}

// An overlay view that indicates processing progress.
struct ProcessingOverlayView: View {
    var body: some View {
        VStack {
            ProgressView("Processing...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
        }
    }
}

// Preview provider for SwiftUI canvas.
struct MultiSceneCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        MultiSceneCaptureView()
    }
}
